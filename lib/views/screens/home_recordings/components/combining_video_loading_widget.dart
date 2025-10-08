import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:socials_app/utils/app_colors.dart';
import 'package:socials_app/views/screens/home_recordings/controller/recording_cont.dart';

class VideoCombiningLoadingWIdget extends StatelessWidget {
  const VideoCombiningLoadingWIdget({
    super.key,
    required this.controller,
  });

  final RecordingController controller;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        height: Get.height * 0.2,
        width: Get.width * 0.9,
        decoration: const BoxDecoration(
          color: kGreyContainerColor,
          borderRadius: BorderRadius.all(Radius.circular(20)),
          border: Border.fromBorderSide(BorderSide(color: kPrimaryColor, width: 2)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const CircularProgressIndicator(color: kPrimaryColor),
            const SizedBox(height: 20),
            Obx(
              () => Text(
                'Processing Videos... ${(controller.progress.value.toDouble() * 100).toStringAsFixed(2)} %',
                style: TextStyle(
                  color: kWhiteColor,
                  fontSize: 20.sp,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
