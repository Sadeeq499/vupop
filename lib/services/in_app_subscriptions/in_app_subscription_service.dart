import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_inapp_purchase/flutter_inapp_purchase.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

import '../custom_snackbar.dart';

class SubscriptionService extends GetxService {
  static SubscriptionService get instance => Get.find();

  // Your subscription product IDs
  static const String premiumMonthlyId = 'com.app.vupop.test.monthly';

  RxBool isSubscriptionActive = false.obs;
  RxBool isLoading = false.obs;
  RxList<IAPItem> availableProducts = <IAPItem>[].obs;

  late StreamSubscription _purchaseUpdatedSubscription;
  late StreamSubscription _purchaseErrorSubscription;
  late StreamSubscription _connectionSubscription;

  @override
  void onInit() {
    super.onInit();
    _initializeInAppPurchase();
  }

  Future<void> _initializeInAppPurchase() async {
    try {
      // Initialize the connection
      await FlutterInappPurchase.instance.initialize();

      // Listen for purchase updates
      _purchaseUpdatedSubscription = FlutterInappPurchase.purchaseUpdated.listen(
        _onPurchaseUpdate,
        onError: (error) => print('Purchase error: $error'),
      );

      _purchaseErrorSubscription = FlutterInappPurchase.purchaseError.listen(
        _onPurchaseError,
      );

      _connectionSubscription = FlutterInappPurchase.connectionUpdated.listen(
        _onConnectionUpdate,
      );

      await _loadProducts();
      await checkSubscriptionStatus();
    } catch (e) {
      if (kDebugMode) print('Error initializing IAP: $e');
    }
  }

  Future<void> _loadProducts() async {
    try {
      final List<String> productIds = [premiumMonthlyId];

      final List<IAPItem> products = await FlutterInappPurchase.instance.getSubscriptions(productIds);
      availableProducts.value = products;

      if (kDebugMode) {
        print('Loaded ${products.length} subscription products');
        for (var product in products) {
          print('Product: ${product.productId} - ${product.price}');
        }
      }
    } catch (e) {
      if (kDebugMode) print('Error loading products: $e');
    }
  }

  Future<bool> checkSubscriptionStatus() async {
    try {
      isLoading.value = true;

      // Get available purchases
      final List<PurchasedItem> purchases = await FlutterInappPurchase.instance.getAvailablePurchases() ?? [];

      bool hasActiveSubscription = false;

      for (PurchasedItem purchase in purchases) {
        if (purchase.productId == premiumMonthlyId) {
          // Validate the receipt
          final bool isValid = await _validateReceipt(purchase);
          if (isValid) {
            hasActiveSubscription = true;
            break;
          }
        }
      }

      isSubscriptionActive.value = hasActiveSubscription;
      return hasActiveSubscription;
    } catch (e) {
      if (kDebugMode) print('Error checking subscription status: $e');
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> purchaseSubscription() async {
    if (availableProducts.isEmpty) {
      CustomSnackbar.showSnackbar('No subscription products available');
      return false;
    }

    try {
      isLoading.value = true;

      final IAPItem product = availableProducts.first;

      // Purchase the subscription
      await FlutterInappPurchase.instance.requestSubscription(product.productId!);

      return true;
    } catch (e) {
      if (kDebugMode) print('Error purchasing subscription: $e');
      CustomSnackbar.showSnackbar('Failed to purchase subscription');
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  void _onPurchaseUpdate(PurchasedItem? purchasedItem) async {
    if (kDebugMode) {
      print('Purchase updated: ${purchasedItem?.productId}');
      print('Transaction ID: ${purchasedItem?.transactionId}');
    }

    if (purchasedItem != null && purchasedItem?.productId == premiumMonthlyId) {
      // Validate the receipt
      final bool isValid = await _validateReceipt(purchasedItem);

      if (isValid) {
        isSubscriptionActive.value = true;
        CustomSnackbar.showSnackbar('Premium subscription activated!');

        // Acknowledge the purchase
        await _acknowledgePurchase(purchasedItem);
      } else {
        CustomSnackbar.showSnackbar('Receipt validation failed');
      }
    }
  }

  void _onPurchaseError(PurchaseResult? result) {
    if (result != null) {
      CustomSnackbar.showSnackbar('Purchase failed: ${result.message}');
    }
    isLoading.value = false;
  }

  void _onConnectionUpdate(ConnectionResult connected) {
    if (kDebugMode) print('IAP Connection: ${connected.connected}');
  }

  Future<bool> _validateReceipt(PurchasedItem purchase) async {
    try {
      if (Platform.isIOS) {
        return await _validateIOSReceipt(purchase);
      } else if (Platform.isAndroid) {
        return await _validateAndroidReceipt(purchase);
      }
      return false;
    } catch (e) {
      if (kDebugMode) print('Receipt validation error: $e');
      return false;
    }
  }

  Future<bool> _validateIOSReceipt(PurchasedItem purchase) async {
    try {
      // Get the shared secret from your app-specific shared secret
      const String sharedSecret = 'YOUR_APP_SPECIFIC_SHARED_SECRET';

      final Map<String, dynamic> requestBody = {
        'receipt-data': purchase.transactionReceipt,
        'password': sharedSecret,
        'exclude-old-transactions': true,
      };

      // Use sandbox for testing, production for live app
      const String verifyUrl = kDebugMode ? 'https://sandbox.itunes.apple.com/verifyReceipt' : 'https://buy.itunes.apple.com/verifyReceipt';

      final response = await http.post(
        Uri.parse(verifyUrl),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(requestBody),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        final int status = responseData['status'] ?? -1;

        if (status == 0) {
          // Receipt is valid
          final receipt = responseData['receipt'];
          final latestReceiptInfo = responseData['latest_receipt_info'];

          if (latestReceiptInfo != null && latestReceiptInfo.isNotEmpty) {
            // Check if subscription is still active
            final latestInfo = latestReceiptInfo.last;
            final int expiresDateMs = int.parse(latestInfo['expires_date_ms']);
            final DateTime expiryDate = DateTime.fromMillisecondsSinceEpoch(expiresDateMs);

            return DateTime.now().isBefore(expiryDate);
          }
        } else if (status == 21007) {
          // Receipt is from sandbox, try sandbox URL
          return await _validateIOSReceiptSandbox(purchase);
        }
      }

      return false;
    } catch (e) {
      if (kDebugMode) print('iOS receipt validation error: $e');
      return false;
    }
  }

  Future<bool> _validateIOSReceiptSandbox(PurchasedItem purchase) async {
    // Same logic as above but with sandbox URL
    // Implementation similar to _validateIOSReceipt but with sandbox URL
    return true; // Simplified for demo
  }

  Future<bool> _validateAndroidReceipt(PurchasedItem purchase) async {
    try {
      // Get the service account JSON from method channel
      const MethodChannel channel = MethodChannel('subscription_channel');
      final String serviceAccountJson = await channel.invokeMethod('getServiceAccountJson');

      // Get access token
      final String accessToken = await _getGooglePlayAccessToken(serviceAccountJson);

      // Validate with Google Play API
      final String packageName = 'your.package.name'; // Replace with your package name
      final String subscriptionId = purchase.productId!;
      final String purchaseToken = purchase.purchaseToken!;

      final String url = 'https://androidpublisher.googleapis.com/androidpublisher/v3/applications/'
          '$packageName/purchases/subscriptions/$subscriptionId/tokens/$purchaseToken';

      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $accessToken',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        final int expiryTimeMillis = int.parse(responseData['expiryTimeMillis'] ?? '0');
        final DateTime expiryDate = DateTime.fromMillisecondsSinceEpoch(expiryTimeMillis);

        return DateTime.now().isBefore(expiryDate);
      }

      return false;
    } catch (e) {
      if (kDebugMode) print('Android receipt validation error: $e');
      return false;
    }
  }

  Future<String> _getGooglePlayAccessToken(String serviceAccountJson) async {
    try {
      final Map<String, dynamic> credentials = json.decode(serviceAccountJson);

      // This is a simplified version. In production, you'd use proper JWT signing
      // For now, return a placeholder
      return 'ACCESS_TOKEN'; // You need to implement proper JWT token generation
    } catch (e) {
      if (kDebugMode) print('Error getting access token: $e');
      return '';
    }
  }

  Future<void> _acknowledgePurchase(PurchasedItem purchase) async {
    try {
      if (Platform.isAndroid) {
        // For Android, you need to acknowledge the purchase
        await FlutterInappPurchase.instance.acknowledgePurchaseAndroid(purchase.purchaseToken!);
      }

      // Finish the transaction
      await FlutterInappPurchase.instance.finishTransaction(purchase);

      if (kDebugMode) print('Purchase acknowledged: ${purchase.productId}');
    } catch (e) {
      if (kDebugMode) print('Error acknowledging purchase: $e');
    }
  }

  String getSubscriptionPrice() {
    if (availableProducts.isNotEmpty) {
      return availableProducts.first.localizedPrice ?? '£2.99';
    }
    return '£2.99'; // Fallback price
  }

  // Cancel subscription method
  Future<bool> cancelSubscription() async {
    try {
      if (Platform.isIOS) {
        return await _cancelSubscriptionIOS();
      } else if (Platform.isAndroid) {
        return await _cancelSubscriptionAndroid();
      }
      return false;
    } catch (e) {
      if (kDebugMode) print('Error canceling subscription: $e');
      return false;
    }
  }

  Future<bool> _cancelSubscriptionIOS() async {
    try {
      await Get.dialog(
        AlertDialog(
          backgroundColor: Color(0xFF1A1A1A),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text(
            'Cancel Subscription',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'To cancel your subscription on iOS:',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                ),
              ),
              SizedBox(height: 12),
              _buildCancelStep('1', 'Open Settings app'),
              _buildCancelStep('2', 'Tap your name at the top'),
              _buildCancelStep('3', 'Tap "Subscriptions"'),
              _buildCancelStep('4', 'Find and tap "VUPOP Premium"'),
              _buildCancelStep('5', 'Tap "Cancel Subscription"'),
              SizedBox(height: 16),
              Text(
                'Your subscription will remain active until the end of the current billing period.',
                style: TextStyle(
                  color: Color(0xFFE6FF4D),
                  fontSize: 12,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Get.back(),
              child: Text(
                'Got it',
                style: TextStyle(color: Color(0xFFE6FF4D)),
              ),
            ),
          ],
        ),
      );
      return true;
    } catch (e) {
      if (kDebugMode) print('Error showing iOS cancel dialog: $e');
      return false;
    }
  }

  Widget _buildCancelStep(String step, String instruction) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 20,
            height: 20,
            decoration: BoxDecoration(
              color: Color(0xFFE6FF4D),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(
              child: Text(
                step,
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              instruction,
              style: TextStyle(
                color: Colors.white70,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<bool> _cancelSubscriptionAndroid() async {
    try {
      await Get.dialog(
        AlertDialog(
          backgroundColor: Color(0xFF1A1A1A),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text(
            'Cancel Subscription',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'To cancel your subscription on Android:',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                ),
              ),
              SizedBox(height: 12),
              _buildCancelStep('1', 'Open Google Play Store'),
              _buildCancelStep('2', 'Tap Menu > Subscriptions'),
              _buildCancelStep('3', 'Find "VUPOP Premium"'),
              _buildCancelStep('4', 'Tap "Cancel subscription"'),
              _buildCancelStep('5', 'Follow the instructions'),
              SizedBox(height: 16),
              Text(
                'Your subscription will remain active until the end of the current billing period.',
                style: TextStyle(
                  color: Color(0xFFE6FF4D),
                  fontSize: 12,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Get.back(),
              child: Text(
                'Got it',
                style: TextStyle(color: Color(0xFFE6FF4D)),
              ),
            ),
          ],
        ),
      );
      return true;
    } catch (e) {
      if (kDebugMode) print('Error showing Android cancel dialog: $e');
      return false;
    }
  }

  // Method to restore purchases
  Future<bool> restorePurchases() async {
    try {
      isLoading.value = true;

      // Get available purchases
      final List<PurchasedItem> purchases = await FlutterInappPurchase.instance.getAvailablePurchases() ?? [];

      for (PurchasedItem purchase in purchases) {
        if (purchase.productId == premiumMonthlyId) {
          final bool isValid = await _validateReceipt(purchase);
          if (isValid) {
            isSubscriptionActive.value = true;
            CustomSnackbar.showSnackbar('Subscription restored successfully!');
            return true;
          }
        }
      }

      CustomSnackbar.showSnackbar('No active subscription found');
      return false;
    } catch (e) {
      if (kDebugMode) print('Error restoring purchases: $e');
      CustomSnackbar.showSnackbar('Failed to restore purchases');
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void onClose() {
    _purchaseUpdatedSubscription.cancel();
    _purchaseErrorSubscription.cancel();
    _connectionSubscription.cancel();
    FlutterInappPurchase.instance.finalize();
    super.onClose();
  }
}
