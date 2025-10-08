import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:socials_app/utils/app_colors.dart';

class ReportSubmittedDialog {
  static void show({VoidCallback? onBackToArchiveScreen}) {
    Get.dialog(
      Dialog(
        elevation: 15,
        backgroundColor: Colors.transparent,
        child: Container(
          // margin: const EdgeInsets.all(20),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 30),
          decoration: BoxDecoration(
            color: kBlackColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: kPrimaryColor.withOpacity(0.5), // Yellow border
              width: 2,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Title
              const Text(
                'Report Submitted',
                style: TextStyle(
                  color: kPrimaryColor, // Yellow text
                  fontSize: 26,
                  fontWeight: FontWeight.w700,
                  fontFamily: 'poppins',
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 20),

              // Message
              const Text(
                'Your issue has been submitted. Vupop support will review and respond shortly.',
                style: TextStyle(color: kWhiteColor, fontSize: 14, fontFamily: 'League Spartan', fontWeight: FontWeight.w400),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 30),

              // Button
              SizedBox(
                width: double.infinity,
                height: 40,
                child: ElevatedButton(
                  onPressed: () {
                    Get.back(); // Close dialog
                    if (onBackToArchiveScreen != null) {
                      onBackToArchiveScreen();
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: kPrimaryColor, // Yellow button
                    foregroundColor: kBlackColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    'Back to Profile',
                    style: TextStyle(
                      fontSize: 16,
                      fontFamily: 'League Spartan',
                      fontWeight: FontWeight.w700,
                      color: kBlackColor,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      barrierDismissible: false, // Can't dismiss by tapping outside
    );
  }
}
