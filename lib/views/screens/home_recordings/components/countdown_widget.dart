import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:socials_app/services/custom_snackbar.dart';
import 'package:socials_app/utils/app_colors.dart';
import 'package:socials_app/utils/app_images.dart';
import 'package:socials_app/views/screens/home_recordings/controller/recording_cont.dart';
import 'package:timer_count_down/timer_count_down.dart';

class CountDownWidget extends StatelessWidget {
  const CountDownWidget({
    super.key,
    required this.controller,
  });

  final RecordingController controller;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
        height: 160.h,
        width: 100.w,
        child: Countdown(
          seconds: 20,
          build: (BuildContext context, double time) {
            return Stack(
              alignment: Alignment.center,
              children: [
                Positioned(
                  bottom: 80,
                  child: Container(
                    height: 50.h,
                    width: 60.w,
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: AssetImage(kbubble),
                        fit: BoxFit.fill,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        "${time.toInt().toString()}s",
                        style: TextStyle(
                          color: kBlackColor,
                          fontSize: 20.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  bottom: 0,
                  child: Container(
                    height: 75.h,
                    width: 75.w,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: kOverdueRedColor,
                      // image: DecorationImage(
                      //   image: AssetImage(kAppLogo),
                      //   fit: BoxFit.fill,
                      // ),
                    ),
                    child: Transform(
                      alignment: Alignment.center,
                      transform: Matrix4.rotationY(math.pi),
                      child: CircularProgressIndicator(
                        value: time / 20,
                        strokeWidth: 7,
                        backgroundColor: kPrimaryColor,
                        color: kBlackColor.withOpacity(0.5),
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
          interval: const Duration(seconds: 1),
          onFinished: () {
            CustomSnackbar.showSnackbar('Recording finished');
            controller.stopRecordingForNonDual();
          },
        ));
  }
}
