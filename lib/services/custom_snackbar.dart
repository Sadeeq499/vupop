import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:socials_app/utils/app_colors.dart';

class CustomSnackbar {
  static void showSnackbar(String message) {
    Get.snackbar(
      "",
      message,
      colorText: kPrimaryColor,
      titleText: const SizedBox(),
      padding: const EdgeInsets.symmetric(horizontal: 1, vertical: 10),
      snackStyle: SnackStyle.FLOATING,
      duration: const Duration(seconds: 2),
      snackPosition: SnackPosition.TOP,
      margin: EdgeInsets.symmetric(vertical: 50.h, horizontal: 20.w),
      backgroundColor: kGreyContainerColor2.withOpacity(0.3),
      isDismissible: true,
      leftBarIndicatorColor: kPrimaryColor,
      // messageText:
      messageText: Padding(
        padding: EdgeInsets.only(left: 8.0.w),
        child: Text(
          message,
          style: const TextStyle(
            color: kPrimaryColor,
            fontSize: 16,
          ),
        ),
      ),
    );

    // Fluttertoast.showToast(
    //   msg: message,
    //   toastLength: Toast.LENGTH_SHORT,
    //   gravity: ToastGravity.TOP,
    //   timeInSecForIosWeb: 1,
    //   backgroundColor: kGreyContainerColor,
    //   textColor: kPrimaryColor,
    //   fontSize: 16.0,
    // );
  }

  static void showTimerSnackbar(String message) {
    Get.snackbar(
      "",
      message,
      colorText: kBlackColor,
      titleText: const SizedBox(),
      padding: const EdgeInsets.symmetric(horizontal: 1, vertical: 10),
      snackStyle: SnackStyle.FLOATING,
      duration: const Duration(seconds: 5),
      snackPosition: SnackPosition.TOP,
      margin: EdgeInsets.symmetric(vertical: 50.h, horizontal: 20.w),
      backgroundColor: kYellowLight,
      isDismissible: true,
      borderRadius: 5,
      leftBarIndicatorColor: kPrimaryColor,
      // messageText:
      messageText: Padding(
        padding: EdgeInsets.only(left: 8.0.w),
        child: Text(
          message,
          style: const TextStyle(
            color: kBlackColor,
            fontSize: 16,
          ),
        ),
      ),
    );
  }
}
