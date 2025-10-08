import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:pinput/pinput.dart';
import 'package:socials_app/views/screens/account_details/controller/account_details_controller.dart';

import '../../../../utils/app_colors.dart';
import '../../../../utils/app_styles.dart';
import 'count_down_timer_widget.dart';

class VerifyEmailWidget extends StatelessWidget {
  AccountDetailsController controller;
  String codeSentTo;

  VerifyEmailWidget({super.key, required this.controller, required this.codeSentTo});

  @override
  Widget build(BuildContext context) {
    final defaultPinTheme = PinTheme(
      width: 55,
      height: 55,
      textStyle: const TextStyle(
        fontSize: 22,
        color: kPrimaryColor,
        fontWeight: FontWeight.bold,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(5.0),
        border: Border.all(color: kGreyContainerColor),
        color: kGreyContainerColor,
      ),
    );

    return Container(
      width: Get.width,
      decoration: const ShapeDecoration(
        color: kGreyContainerColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(32),
            topRight: Radius.circular(32),
          ),
        ),
      ),
      child: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: [
                  Text(
                    "Verify Your Email",
                    textAlign: TextAlign.center,
                    style: AppStyles.appBarHeadingTextStyle().copyWith(
                      fontSize: 18,
                    ),
                  ),
                  SizedBox(
                    height: 12,
                  ),
                  Text.rich(
                    TextSpan(
                      children: [
                        const TextSpan(
                          text: 'Code has been sent to ',
                          style: TextStyle(
                            color: kPrimaryColor,
                            fontSize: 16,
                            fontFamily: 'Urbanist',
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        TextSpan(
                          text: codeSentTo,
                          style: const TextStyle(
                            color: kPrimaryColor,
                            fontSize: 16,
                            fontFamily: 'Urbanist',
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(
                    height: 10.h,
                  ),
                  const Text(
                    'Enter the code to verify your email.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: kPrimaryColor,
                      fontSize: 16,
                      fontFamily: 'Urbanist',
                      fontWeight: FontWeight.w500,
                      height: 1.5,
                      letterSpacing: 0.20,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 25.h,
            ),
            Padding(
              padding: const EdgeInsets.only(left: 20, right: 20),
              child: Pinput(
                length: 4,
                onCompleted: (value) async {
                  Get.back();
                  controller.isLoading.value = true;
                  controller.verifyOtp(
                    otp: controller.tecOtp.text,
                  );
                },
                controller: controller.tecOtp,
                defaultPinTheme: defaultPinTheme,
                focusedPinTheme: defaultPinTheme.copyWith(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(5.0),
                    color: kBackgroundColor,
                    border: Border.all(color: kPrimaryColor),
                  ),
                ),
                submittedPinTheme: defaultPinTheme.copyWith(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(5.0),
                    border: Border.all(color: kPrimaryColor),
                  ),
                ),
                followingPinTheme: defaultPinTheme.copyWith(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(5.0),
                    color: kBackgroundColor,
                    border: Border.all(color: Colors.grey),
                  ),
                ),
              ),
            ),
            SizedBox(
              height: 40.h,
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Didn’t Receive Code?',
                  textAlign: TextAlign.right,
                  style: TextStyle(
                    color: kHintGreyColor,
                    fontSize: 12,
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w400,
                  ),
                ),
                const SizedBox(width: 3),
                Obx(
                  () => InkWell(
                    onTap: controller.isTimerComplete.isTrue
                        ? () async {
                            controller.reSendOtp();
                          }
                        : null,
                    child: Text(
                      'Resend Code',
                      textAlign: TextAlign.right,
                      style: TextStyle(
                        color: controller.isTimerComplete.isTrue ? kPrimaryColor : kHintGreyColor,
                        fontSize: 12,
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w500,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(
              height: 12,
            ),
            CustomCountdown(
              animation: StepTween(
                begin: controller.otpTimer.value, // THIS IS A USER ENTERED NUMBER
                end: 0,
              ).animate(controller.timerController!),
            ),
            SizedBox(
              height: 20,
            )
            /*const Text(
              'Resend code in 00:59',
              textAlign: TextAlign.right,
              style: TextStyle(
                color: Color(0xFF494949),
                fontSize: 12,
                fontFamily: 'Inter',
                fontWeight: FontWeight.w400,
                height: 0,
              ),
            ),*/
          ],
        ),
      ),
    );
  }
}
