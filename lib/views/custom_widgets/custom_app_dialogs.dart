import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';
import 'package:socials_app/utils/common_code.dart';

import '../../utils/app_colors.dart';
import '../../utils/app_images.dart';
import '../../utils/app_strings.dart';
import '../../utils/app_styles.dart';
import '../screens/bottom/controller/bottom_bar_controller.dart';

void showWithdrawDialog({VoidCallback? onContinueBtnClick, String? heading}) async {
  Get.dialog(
    barrierColor: kBlackColor.withOpacity(0.5),
    AlertDialog(
      backgroundColor: kBlackColor.withOpacity(0.8),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.asset(
            kAppLogo,
            height: 100,
            width: 100,
          ),
          Text(
            heading ?? 'Your bank account details are already added and verified.',
            style: AppStyles.labelTextStyle(),
          ),
        ],
      ),
      actions: [
        TextButton(
          child: const Text('Check Details'),
          onPressed: () async {
            Get.back();
            Get.toNamed(kAccountDetailsRoute);
          },
        ),
        TextButton(onPressed: onContinueBtnClick, child: const Text('Continue')),
      ],
    ),
  );
}

void bankAccountMissingDialog() async {
  Get.dialog(
    barrierColor: kBlackColor.withOpacity(0.5),
    AlertDialog(
      backgroundColor: kBlackColor.withOpacity(0.8),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.asset(
            kAppLogo,
            height: 100,
            width: 100,
          ),
          Text(
            'Your bank account details are missing, to withdraw amount please add details to continue',
            style: AppStyles.labelTextStyle(),
          ),
        ],
      ),
      actions: [
        TextButton(
          child: const Text('Add Details'),
          onPressed: () async {
            Get.back();
            Get.toNamed(kAccountDetailsRoute);
          },
        ),
        TextButton(
          child: const Text('Close'),
          onPressed: () async {
            Get.back();
            // Get.toNamed(kAccountDetailsRoute);
            //requestPaymentToAdmin();
            // Get.back();
          },
        ),
      ],
    ),
  );
}

void showPaymentStatusDialog(
    {required String customerName, required String iban, required String amountToWithdraw, required String requestStatus}) async {
  final GlobalKey _receiptKey = GlobalKey();
  Get.dialog(
    barrierColor: kBlackColor.withOpacity(0.5),
    AlertDialog(
      contentPadding: EdgeInsets.zero,
      icon: Image.asset(
        kAppLogo,
        height: 30,
        width: 100,
      ),
      backgroundColor: kBlackTransparentColor,
      content: RepaintBoundary(
        // Wrap with RepaintBoundary
        key: _receiptKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              height: 20,
            ),
            Image.asset(
              requestStatus == 'Success' ? kPaymentSuccessful : kPaymentFailed,
              height: 100,
              width: 100,
            ),
            const SizedBox(height: 16),
            Text(
              'Payment Successful',
              style: AppStyles.appBarHeadingTextStyle(),
            ),
            Text(
              'Successfully requested to withdraw £$amountToWithdraw.',
              style: AppStyles.labelTextStyle(),
            ),

            SizedBox(
              height: 8,
            ),

            Container(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: DashedDivider(
                color: kHintGreyColor,
                height: 2,
                dashWidth: 10,
                dashSpace: 5,
              ),
            ),
            // Transaction Details Card
            Container(
              width: Get.width,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.transparent,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: const Text(
                      textAlign: TextAlign.center,
                      'Transaction Details',
                      style: TextStyle(
                        color: kPrimaryColor,
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // _buildDetailRow('Transaction ID', controller.transactionId),
                  _buildDetailRow('Account Title', customerName),
                  _buildDetailRow('IBAN', iban),
                  _buildDetailRow('Date', DateFormat("dd-MM-yyyy HH:mm").format(DateTime.now())),
                  _buildDetailRow('Type of Transaction', 'Bank Transfer'),
                  _buildDetailRow('Amount', '£$amountToWithdraw'),
                  _buildDetailRow('Status', requestStatus),
                ],
              ),
            ),
          ],
        ),
      ),
      actionsAlignment: MainAxisAlignment.center,
      actions: [
        TextButton(
          style: ButtonStyle(
              backgroundColor: WidgetStatePropertyAll(
                kBlackColor.withOpacity(0.8),
              ),
              shape: WidgetStatePropertyAll(
                RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12), // Circular rectangle
                ),
              ),
              elevation: WidgetStatePropertyAll(8)),
          child: Column(
            children: [
              Icon(
                Icons.share_sharp,
                color: kPrimaryColor,
              ),
              SizedBox(
                height: 2,
              ),
              const Text('Share'),
            ],
          ),
          onPressed: () async {
            /* ShareResult shareResult = await Share.share(image, subject: 'Check out this video');
            if (shareResult.status == ShareResultStatus.success) {
              CustomSnackbar.showSnackbar('Shared successfully');
            }*/
            await CommonCode.captureAndSharePng(_receiptKey);
          },
        ),
        TextButton(
          style: ButtonStyle(
              backgroundColor: WidgetStatePropertyAll(
                kBlackColor.withOpacity(0.8),
              ),
              shape: WidgetStatePropertyAll(
                RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12), // Circular rectangle
                ),
              ),
              elevation: WidgetStatePropertyAll(8)),
          child: Column(
            children: [
              Icon(
                Icons.save_outlined,
                color: kPrimaryColor,
              ),
              SizedBox(
                height: 2,
              ),
              const Text('Save'),
            ],
          ),
          onPressed: () async {
            await CommonCode.captureAndSavePng(_receiptKey);
          },
        ),
        TextButton(
          style: ButtonStyle(
              backgroundColor: WidgetStatePropertyAll(
                kBlackColor.withOpacity(0.8),
              ),
              shape: WidgetStatePropertyAll(
                RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12), // Circular rectangle
                ),
              ),
              elevation: WidgetStatePropertyAll(8)),
          child: Column(
            children: [
              Icon(
                Icons.home_outlined,
                color: kPrimaryColor,
              ),
              SizedBox(
                height: 2,
              ),
              const Text('Home'),
            ],
          ),
          onPressed: () async {
            Get.back();

            ///TODO back to home screen
            Get.find<BottomBarController>().selectedIndex.value = 0;
          },
        ),
      ],
    ),
  );
}

Widget _buildDetailRow(String label, String value) {
  return Container(
    width: Get.width * 0.80,
    padding: const EdgeInsets.symmetric(vertical: 8),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start, // Align to top for multi-line text
      children: [
        // Label column (50%)
        Expanded(
          flex: 1, // Takes 50% of available space
          child: Text(
            '$label ',
            style: TextStyle(
              color: kPrimaryColor,
              fontSize: 14,
            ),
            softWrap: true, // Enables text wrapping
            maxLines: null, // Allows unlimited lines
          ),
        ),
        const SizedBox(width: 8), // Spacing between columns
        // Value column (50%)
        Expanded(
          flex: 1, // Takes 50% of available space
          child: Text(
            '$value',
            style: const TextStyle(
              color: kPrimaryColor,
              fontWeight: FontWeight.w500,
              fontSize: 14,
            ),
            textAlign: TextAlign.right,
            softWrap: true, // Enables text wrapping
            maxLines: null, // Allows unlimited lines
          ),
        ),
      ],
    ),
  );
}

// Custom painter version for more control
class DashedDivider extends StatelessWidget {
  final double height;
  final Color color;
  final double dashWidth;
  final double dashSpace;

  const DashedDivider({
    super.key,
    this.height = 1,
    this.color = Colors.grey,
    this.dashWidth = 5,
    this.dashSpace = 3,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(double.infinity, height),
      painter: _DashPainter(
        color: color,
        dashWidth: dashWidth,
        dashSpace: dashSpace,
      ),
    );
  }
}

class _DashPainter extends CustomPainter {
  final Color color;
  final double dashWidth;
  final double dashSpace;

  _DashPainter({
    required this.color,
    required this.dashWidth,
    required this.dashSpace,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = size.height
      ..strokeCap = StrokeCap.square;

    double startX = 0;
    while (startX < size.width) {
      canvas.drawLine(
        Offset(startX, size.height / 2),
        Offset(startX + dashWidth, size.height / 2),
        paint,
      );
      startX += dashWidth + dashSpace;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// Simpler version using Container
Widget simpleDashedDivider() {
  return Container(
    height: 1,
    width: double.infinity,
    decoration: BoxDecoration(
      border: Border(
        bottom: BorderSide(
          color: Colors.grey,
          width: 1,
          style: BorderStyle.values[1], // This gives the dashed style
        ),
      ),
    ),
  );
}

// Function to show the Congratulations dialog
void showCongratulationsDialogWith(
    {required String customerName, required String iban, required String amountToWithdraw, required String requestStatus}) {
  final GlobalKey _receiptKey = GlobalKey();
  Get.dialog(
    barrierColor: kBlackColor.withOpacity(0.5),
    AlertDialog(
      contentPadding: EdgeInsets.zero,
      icon: Image.asset(
        kAppLogo,
        height: 30,
        width: 100,
      ),
      backgroundColor: kBlackTransparentColor,
      content: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
        decoration: BoxDecoration(
          color: kBlackTransparentColor,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Confetti inside dialog
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: SizedBox(
                width: double.infinity,
                height: 200, // Adjust height as needed
                child: Lottie.asset(
                  'assets/animations/confetti.json',
                  fit: BoxFit.fill,
                ),
              ),
            ),

            // Content
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Success animation
                /*Lottie.asset(
                  height: 100,
                  width: 100,
                  'assets/animations/successs.json',
                  fit: BoxFit.fill,
                ),*/
                // Green check mark circle
                Container(
                  width: 70,
                  height: 70,
                  decoration: const BoxDecoration(
                    color: Color(0xFF4CAF50),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check,
                    color: Colors.white,
                    size: 45,
                  ),
                ),
                const SizedBox(height: 16),

                // Text content
                Text(
                  'Congratulations',
                  style: AppStyles.appBarHeadingTextStyle(),
                ),
                Text(
                  'Successfully requested to withdraw £$amountToWithdraw.',
                  style: AppStyles.labelTextStyle(),
                ),
              ],
            ),
          ],
        ),
      ),
      actionsAlignment: MainAxisAlignment.center,
      actions: [
        TextButton(
          style: ButtonStyle(
              backgroundColor: WidgetStatePropertyAll(
                kBlackColor.withOpacity(0.8),
              ),
              shape: WidgetStatePropertyAll(
                RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              elevation: WidgetStatePropertyAll(8)),
          child: Column(
            children: [
              Icon(
                Icons.share_sharp,
                color: kPrimaryColor,
              ),
              SizedBox(
                height: 2,
              ),
              const Text('Share'),
            ],
          ),
          onPressed: () async {
            await CommonCode.captureAndSharePng(_receiptKey);
          },
        ),
        TextButton(
          style: ButtonStyle(
              backgroundColor: WidgetStatePropertyAll(
                kBlackColor.withOpacity(0.8),
              ),
              shape: WidgetStatePropertyAll(
                RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              elevation: WidgetStatePropertyAll(8)),
          child: Column(
            children: [
              Icon(
                Icons.save_outlined,
                color: kPrimaryColor,
              ),
              SizedBox(
                height: 2,
              ),
              const Text('View Receipt'),
            ],
          ),
          onPressed: () async {
            Get.back();
            showPaymentStatusDialog(
              customerName: customerName,
              iban: iban,
              amountToWithdraw: amountToWithdraw,
              requestStatus: requestStatus,
            );
          },
        ),
        TextButton(
          style: ButtonStyle(
              backgroundColor: WidgetStatePropertyAll(
                kBlackColor.withOpacity(0.8),
              ),
              shape: WidgetStatePropertyAll(
                RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              elevation: WidgetStatePropertyAll(8)),
          child: Column(
            children: [
              Icon(
                Icons.home_outlined,
                color: kPrimaryColor,
              ),
              SizedBox(
                height: 2,
              ),
              const Text('Home'),
            ],
          ),
          onPressed: () async {
            Get.back();
            Get.back();
            Get.find<BottomBarController>().selectedIndex.value = 0;
          },
        ),
      ],
    ),
    barrierDismissible: false,
  );
}

void showCongratulationsDialog(
    {required String customerName, required String iban, required String amountToWithdraw, required String requestStatus}) {
  final GlobalKey _receiptKey = GlobalKey();
  Get.dialog(
    barrierColor: kBlackColor.withOpacity(0.5),
    Stack(
      alignment: Alignment.center,
      children: [
        // Full-screen confetti animation
        Positioned.fill(
          child: Lottie.asset(
            'assets/animations/confetti.json',
            fit: BoxFit.fill,
          ),
        ),

        // Dialog content
        AlertDialog(
          contentPadding: EdgeInsets.zero,
          icon: Image.asset(
            kAppLogo,
            height: 30,
            width: 100,
          ),
          backgroundColor: kBlackTransparentColor,
          content: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
            decoration: BoxDecoration(
              color: kBlackTransparentColor,
              borderRadius: BorderRadius.circular(8),
            ),
            child: RepaintBoundary(
              // Wrap with RepaintBoundary
              key: _receiptKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Green check mark circle
                  /*Container(
                    width: 70,
                    height: 70,
                    decoration: const BoxDecoration(
                      color: Color(0xFF4CAF50),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.check,
                      color: Colors.white,
                      size: 45,
                    ),
                  ),*/
                  Lottie.asset(
                    height: 100,
                    width: 100,
                    'assets/animations/successs.json',
                    fit: BoxFit.fill,
                  ),
                  const SizedBox(height: 12),

                  // Text content
                  Text(
                    'Congratulations',
                    style: AppStyles.appBarHeadingTextStyle(),
                  ),
                  Text(
                    'Successfully requested to withdraw £$amountToWithdraw.',
                    style: AppStyles.labelTextStyle(),
                  ),
                ],
              ),
            ),
          ),
          actionsAlignment: MainAxisAlignment.center,
          actions: [
            TextButton(
              style: ButtonStyle(
                  backgroundColor: WidgetStatePropertyAll(
                    kBlackColor.withOpacity(0.8),
                  ),
                  shape: WidgetStatePropertyAll(
                    RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12), // Circular rectangle
                    ),
                  ),
                  elevation: WidgetStatePropertyAll(8)),
              child: Column(
                children: [
                  Icon(
                    Icons.share_sharp,
                    color: kPrimaryColor,
                  ),
                  SizedBox(
                    height: 2,
                  ),
                  const Text('Share'),
                ],
              ),
              onPressed: () async {
                await CommonCode.captureAndSharePng(_receiptKey);
              },
            ),
            TextButton(
              style: ButtonStyle(
                  backgroundColor: WidgetStatePropertyAll(
                    kBlackColor.withOpacity(0.8),
                  ),
                  shape: WidgetStatePropertyAll(
                    RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12), // Circular rectangle
                    ),
                  ),
                  elevation: WidgetStatePropertyAll(8)),
              child: Column(
                children: [
                  Icon(
                    Icons.save_outlined,
                    color: kPrimaryColor,
                  ),
                  SizedBox(
                    height: 2,
                  ),
                  const Text('View Receipt'),
                ],
              ),
              onPressed: () async {
                Get.back();
                showPaymentStatusDialog(
                  customerName: customerName,
                  iban: iban,
                  amountToWithdraw: amountToWithdraw,
                  requestStatus: requestStatus,
                );
              },
            ),
            TextButton(
              style: ButtonStyle(
                  backgroundColor: WidgetStatePropertyAll(
                    kBlackColor.withOpacity(0.8),
                  ),
                  shape: WidgetStatePropertyAll(
                    RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12), // Circular rectangle
                    ),
                  ),
                  elevation: WidgetStatePropertyAll(8)),
              child: Column(
                children: [
                  Icon(
                    Icons.home_outlined,
                    color: kPrimaryColor,
                  ),
                  SizedBox(
                    height: 2,
                  ),
                  const Text('Home'),
                ],
              ),
              onPressed: () async {
                Get.back();
                Get.back();
                Get.find<BottomBarController>().selectedIndex.value = 0;
              },
            ),
          ],
        ),
      ],
    ),
    barrierDismissible: false,
  );
}

void showCongratulationsDialogNew({required String requestStatus, required bool isFromProfile}) {
  final GlobalKey _receiptKey = GlobalKey();
  Get.dialog(
    barrierColor: kBlackColor.withOpacity(0.5),
    Stack(
      alignment: Alignment.center,
      children: [
        // Full-screen confetti animation
        Positioned.fill(
          child: Lottie.asset(
            'assets/animations/confetti.json',
            fit: BoxFit.fill,
          ),
        ),

        // Dialog content
        AlertDialog(
          contentPadding: EdgeInsets.zero,
          icon: Image.asset(
            kAppLogo,
            height: 30,
            width: 100,
          ),
          backgroundColor: kBlackTransparentColor,
          content: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
            decoration: BoxDecoration(
              color: kBlackTransparentColor,
              borderRadius: BorderRadius.circular(8),
            ),
            child: RepaintBoundary(
              // Wrap with RepaintBoundary
              key: _receiptKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Green check mark circle
                  /*Container(
                    width: 70,
                    height: 70,
                    decoration: const BoxDecoration(
                      color: Color(0xFF4CAF50),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.check,
                      color: Colors.white,
                      size: 45,
                    ),
                  ),*/
                  Lottie.asset(
                    height: 100,
                    width: 100,
                    'assets/animations/successs.json',
                    fit: BoxFit.fill,
                  ),
                  const SizedBox(height: 12),

                  // Text content
                  Text(
                    'Congratulations',
                    style: AppStyles.appBarHeadingTextStyle(),
                  ),
                  Text(
                    'You\'ve Successfully verified payout request',
                    style: AppStyles.labelTextStyle(),
                  ),
                ],
              ),
            ),
          ),
          actionsAlignment: MainAxisAlignment.center,
          actions: [
            TextButton(
              style: ButtonStyle(
                  backgroundColor: WidgetStatePropertyAll(
                    kBlackColor.withOpacity(0.8),
                  ),
                  shape: WidgetStatePropertyAll(
                    RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12), // Circular rectangle
                    ),
                  ),
                  elevation: WidgetStatePropertyAll(8)),
              child: Column(
                children: [
                  Icon(
                    Icons.share_sharp,
                    color: kPrimaryColor,
                  ),
                  SizedBox(
                    height: 2,
                  ),
                  const Text('Share'),
                ],
              ),
              onPressed: () async {
                await CommonCode.captureAndSharePng(_receiptKey);
              },
            ),
            /*TextButton(
              style: ButtonStyle(
                  backgroundColor: WidgetStatePropertyAll(
                    kBlackColor.withOpacity(0.8),
                  ),
                  shape: WidgetStatePropertyAll(
                    RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12), // Circular rectangle
                    ),
                  ),
                  elevation: WidgetStatePropertyAll(8)),
              child: Column(
                children: [
                  Icon(
                    Icons.save_outlined,
                    color: kPrimaryColor,
                  ),
                  SizedBox(
                    height: 2,
                  ),
                  const Text('View Receipt'),
                ],
              ),
              onPressed: () async {
                Get.back();
                showPaymentStatusDialog(
                  customerName: customerName,
                  iban: iban,
                  amountToWithdraw: amountToWithdraw,
                  requestStatus: requestStatus,
                );
              },
            ),*/
            TextButton(
              style: ButtonStyle(
                  backgroundColor: WidgetStatePropertyAll(
                    kBlackColor.withOpacity(0.8),
                  ),
                  shape: WidgetStatePropertyAll(
                    RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12), // Circular rectangle
                    ),
                  ),
                  elevation: WidgetStatePropertyAll(8)),
              child: Column(
                children: [
                  Icon(
                    Icons.home_outlined,
                    color: kPrimaryColor,
                  ),
                  SizedBox(
                    height: 2,
                  ),
                  const Text('Home'),
                ],
              ),
              onPressed: () async {
                if (!isFromProfile) {
                  Get.back();
                  Get.back();
                  Get.find<BottomBarController>().isPayoutVerified.value = true;
                  Get.find<BottomBarController>().selectedIndex.value = 0;
                } else {
                  Get.back();
                  Get.find<BottomBarController>().isPayoutVerified.value = true;
                }
              },
            ),
          ],
        ),
      ],
    ),
    barrierDismissible: false,
  );
}

class CongratulationsDialog extends StatelessWidget {
  CongratulationsDialog({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Lottie confetti animation that fills the screen
          Positioned.fill(
            child: Lottie.network(
              'https://assets3.lottiefiles.com/packages/lf20_kJPQoM6Pun.json', // Confetti animation
              fit: BoxFit.cover,
              animate: true,
            ),
          ),

          // Main content container
          Container(
            width: 300,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  spreadRadius: 1,
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Green check mark
                Container(
                  width: 80,
                  height: 80,
                  decoration: const BoxDecoration(
                    color: Color(0xFF4CAF50),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check,
                    color: Colors.white,
                    size: 50,
                  ),
                ),
                const SizedBox(height: 24),

                // Congratulations text
                const Text(
                  'Congratulations!',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),

                // You're Approved text
                const Text(
                  'You\'re Approved',
                  style: TextStyle(
                    fontSize: 18,
                    color: Color(0xFF4CAF50),
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),

                // Continue button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Get.back();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF4CAF50),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      elevation: 2,
                    ),
                    child: const Text(
                      'Continue',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

void showPremiumDialog({required double premiumPrice, VoidCallback? onSubscriptionBtnClick}) {
  Get.dialog(
    AlertDialog(
      backgroundColor: Color(0xFF0F0F0F),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: kPrimaryColor, width: 2),
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
                color: kPrimaryColor,
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '\$${premiumPrice % 1 == 0 ? premiumPrice.toInt().toString() : premiumPrice.toStringAsFixed(2)}',
                  style: TextStyle(
                    color: kPrimaryColor,
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '/mo',
                  style: TextStyle(
                    color: kPrimaryColor,
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
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
                  TextSpan(text: ' in order to withdraw funds from vupop wallet'),
                ],
              ),
            ),
            SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: onSubscriptionBtnClick,
                style: ElevatedButton.styleFrom(
                  backgroundColor: kPrimaryColor,
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                child: Text(
                  'Subscribe',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
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
