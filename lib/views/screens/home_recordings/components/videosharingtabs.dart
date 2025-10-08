import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:socials_app/utils/app_colors.dart';
import 'package:socials_app/utils/app_images.dart';
import 'package:socials_app/views/screens/home_recordings/controller/recording_cont.dart';

import 'videosharingtabicons.dart';

class VideoSharingTab extends StatelessWidget {
  const VideoSharingTab({
    super.key,
    required this.controller,
    this.height = 75,
    this.width = 150,
    this.iconScale = 3.0,
  });

  final RecordingController controller;
  final double height;
  final double width;
  final double iconScale;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: width.w,
        height: height.h,
        decoration: ShapeDecoration(
          color: kBlackColor.withOpacity(0.5),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            InkWell(
              onTap: () {
                controller.muteVideo();
              },
              child: Obx(() => VideoSharingTabIcons(
                    iconPath: kICsoundicon,
                    iconText: 'Sound',
                    isSelected: controller.isSound.value,
                    scale: iconScale != 3.0 ? iconScale : null,
                  )),
            ),

            ///removed on Dave's suggestion
            /*InkWell(
              onTap: () {
                controller.isFacecam.value = !controller.isFacecam.value;
              },
              child: Obx(() => VideoSharingTabIcons(
                    iconPath: kICDualCameraicon,
                    iconText: 'Facecam',
                    isSelected: controller.isFacecam.value,
                    scale: iconScale != 30 ? iconScale : null,
                    width: width * 0.4,
                  )),
            ),*/

            ///removed on Dave's suggestion
            /*InkWell(
              onTap: () {
                Get.toNamed(kMentionScreenRoute);
              },
              child: Obx(() => VideoSharingTabIcons(
                    iconPath: kICmentionicon,
                    iconText: 'Mention',
                    isSelected: controller.isMention.value,
                  )),
            ),
            InkWell(
              onTap: () {
                Get.toNamed(kHashTagScreenRoute);
              },
              child: Obx(() => VideoSharingTabIcons(
                    iconPath: kICtagicon,
                    iconText: 'Tags',
                    isSelected: controller.isTags.value,
                  )),
            ),*/
          ],
        ),
      ),
    );
  }
}
