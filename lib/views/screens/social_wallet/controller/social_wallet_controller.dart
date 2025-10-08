import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../models/payment_models/get_payment_methods_model.dart';
import '../../../../models/payment_models/wallet_balance_model.dart';
import '../../../../repositories/payment_repo.dart';
import '../../../../repositories/wallet_repo.dart';
import '../../../../services/custom_snackbar.dart';
import '../../../../services/in_app_subscriptions/in_app_subscription_service.dart';
import '../../../../services/session_services.dart';
import '../../../custom_widgets/custom_app_dialogs.dart';
import '../../profile/controller/profile_controller.dart';

class SocialWalletController extends GetxController {
  GlobalKey<ScaffoldState> socialWalletKey = GlobalKey<ScaffoldState>();
  Rx<WalletBalanceModel?> walletData = Rx<WalletBalanceModel?>(null);
  RxBool isLoading = false.obs;
  RxBool isPaymentSuccessful = true.obs;
  RxBool isPaymentMethodFound = false.obs;

  // Add subscription service
  final SubscriptionService _subscriptionService = Get.find<SubscriptionService>();

  @override
  void onInit() {
    super.onInit();
  }

  PaymentMethodData? paymentMethodData;

  Future<void> getWalletBalance() async {
    final resp = await WalletRepo().getWalletBalance();
    if (resp != null) {
      walletData.value = resp;
      paymentMethodData = await PaymentRepo().getUserPaymentMethod(userId: SessionService().user!.id);
      if (paymentMethodData != null) {
        isPaymentMethodFound.value = true;
      } else {
        isPaymentMethodFound.value = false;
      }
    } else {
      CustomSnackbar.showSnackbar('Network Error: Unable to get wallet balance');
    }
  }

  Future<void> onWithdrawPaymentPressed() async {
    // Check if user has premium subscription
    final bool hasSubscription = await _subscriptionService.checkSubscriptionStatus();

    if (!hasSubscription) {
      // Show premium subscription dialog
      _showPremiumSubscriptionDialog();
    } else {
      // Proceed with withdrawal
      _proceedWithWithdrawal();
    }
  }

  void _showPremiumSubscriptionDialog() {
    final String price = _subscriptionService.getSubscriptionPrice();

    Get.dialog(
      AlertDialog(
        backgroundColor: Color(0xFF0F0F0F),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: Color(0xFFE6FF4D), width: 2),
        ),
        contentPadding: EdgeInsets.all(24),
        content: Container(
          width: 300,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Premium',
                style: TextStyle(
                  color: Color(0xFFE6FF4D),
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 16),
              Text(
                price,
                style: TextStyle(
                  color: Color(0xFFE6FF4D),
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 24),
              RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                    height: 1.4,
                  ),
                  children: [
                    TextSpan(text: 'Need '),
                    TextSpan(
                      text: 'Premium',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    TextSpan(text: ' in order to withdraw funds from\nvupop wallet'),
                  ],
                ),
              ),
              SizedBox(height: 32),
              Obx(() => SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _subscriptionService.isLoading.value ? null : _handleSubscription,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFFE6FF4D),
                        foregroundColor: Colors.black,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                      child: _subscriptionService.isLoading.value
                          ? CircularProgressIndicator(color: Colors.black)
                          : Text(
                              'Subscribe',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                  )),
              SizedBox(height: 12),
              TextButton(
                onPressed: _subscriptionService.restorePurchases,
                child: Text(
                  'Restore Purchases',
                  style: TextStyle(
                    color: Color(0xFFE6FF4D),
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      barrierDismissible: true,
    );
  }

  Future<void> _handleSubscription() async {
    final bool success = await _subscriptionService.purchaseSubscription();

    if (success) {
      Get.back(); // Close dialog
      // Wait a moment for subscription to be processed
      await Future.delayed(Duration(seconds: 1));
      _proceedWithWithdrawal();
    }
  }

  void _proceedWithWithdrawal() {
    if (isPaymentMethodFound.isTrue && SessionService().isEmailVerified != null && SessionService().isEmailVerified!) {
      showWithdrawDialog(
        onContinueBtnClick: () async {
          Get.back();
          if (walletData.value != null && walletData.value?.readyToWithdrawAmount != null && walletData.value!.readyToWithdrawAmount! > 0) {
            requestPaymentToAdmin();
          } else {
            CustomSnackbar.showSnackbar('Withdrawal amount must be greater than zero.');
          }
        },
      );
    } else {
      bankAccountMissingDialog();
    }
  }

  Future<void> requestPaymentToAdmin() async {
    isLoading.value = true;
    try {
      final resp = await WalletRepo().requestPaymentToAdmin();

      if (resp) {
        isPaymentSuccessful.value = false;
        getWalletBalance();
        CustomSnackbar.showSnackbar('Withdrawal Request sent successfully');
        Get.find<ProfileScreenController>().getWalletBalance();
        showCongratulationsDialog(
          customerName: paymentMethodData?.userName ?? "-",
          iban: paymentMethodData?.iban ?? "-",
          amountToWithdraw: walletData.value?.readyToWithdrawAmount?.toStringAsFixed(2) ?? "0",
          requestStatus: 'Success',
        );
      } else {
        isPaymentSuccessful.value = true;
      }
    } catch (e) {
      isPaymentSuccessful.value = true;
      if (kDebugMode) {
        print('Error in requestPaymentToAdmin: $e');
      }
      CustomSnackbar.showSnackbar('Error occurred while sending withdrawal request, please try again');
    }
    isLoading.value = false;
  }
}
