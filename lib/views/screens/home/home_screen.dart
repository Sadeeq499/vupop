import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:socials_app/utils/app_images.dart';
import 'package:socials_app/utils/app_strings.dart';
import 'package:socials_app/views/custom_widgets/custom_button.dart';
import 'package:socials_app/views/screens/bottom/controller/bottom_bar_controller.dart';
import 'package:socials_app/views/screens/home/components/video_player_widget.dart';
import 'package:socials_app/views/screens/home/controller/home_controller.dart';

import '../../../utils/app_colors.dart';
import '../../../utils/app_styles.dart';
import '../../../utils/common_code.dart';
import '../../custom_widgets/custom_scaffold.dart';
import 'controller/video_player_controller.dart';

class HomeScreen extends GetView<HomeScreenController> {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    printLogs("======controller.posts.isEmpty ${controller.posts.isEmpty}");
    return CustomScaffold(
      className: runtimeType.toString(),
      screenName: "",
      isBackIcon: true,
      isFullBody: true,
      appBarSize: 40,
      showAppBarBackButton: true,
      leadingWidget: const SizedBox(),
      scaffoldKey: controller.scaffoldKeyHome,
      onNotificationListener: (notificationInfo) {
        if (notificationInfo.runtimeType == UserScrollNotification) {
          CommonCode().removeTextFieldFocus();
        }
        return false;
      },
      onWillPop: () {
        CommonCode.logOutConfirmation();
      },
      actions: [
        Image.asset(
          kAppLogo,
          width: 100.w,
          height: 20.h,
        ),
        const Spacer(),
        GestureDetector(
          onTap: () {
            controller.isVideoChanged.value = false;
            Get.find<VideoPlayerControllerX>().videoPlayer?.dispose();
            Get.find<VideoPlayerControllerX>().videoPlayer = null;

            controller.videoControllers[controller.previousValue.bitLength].value.controller.pause();
            // Get.toNamed(kChatScreenRoute);
            Get.toNamed(kNotificationRoute);
          },
          child: Image.asset(
            kNotificationIcon,
            width: 50.w,
            height: 20.h,
          ),
        ),
        // SizedBox(width: 10.w),
        // GestureDetector(
        //   onTap: () {
        //     controller.isVideoChanged.value = false;
        //     Get.find<VideoPlayerControllerX>().videoPlayerController?.dispose();
        //     Get.find<VideoPlayerControllerX>().videoPlayerController = null;
        //
        //     controller.videoControllers[controller.previousValue.bitLength].value.pause();
        //     Get.toNamed(kChatScreenRoute);
        //   },
        //   child: Image.asset(
        //     kMessageInactive,
        //     width: 50.w,
        //     height: 20.h,
        //   ),
        // )
      ],
      gestureDetectorOnTap: () {
        CommonCode().removeTextFieldFocus();
        controller.isRatingTapped.value = false;
      },
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.only(left: 0.w, right: 0.w, top: 0.h, bottom: 0.h),
          child: SizedBox(
              height: Get.height,
              child:
                  //  VideoPlayer(
                  //   VideoPlayerController.networkUrl(
                  //     Uri.parse(
                  //         "https://vupop-public.s3.eu-north-1.amazonaws.com/uploads/1726054122073_1726054104069.mp4"),
                  //   ),
                  // )
                  //       CachedVideoPlayerPlus(
                  //     CachedVideoPlayerPlusController.networkUrl(
                  //       skipCache: true,
                  //       Uri.parse(
                  //           "https://vupop-public.s3.eu-north-1.amazonaws.com/uploads/1726054122073_1726054104069.mp4"),
                  //     ),
                  //   ),
                  // )
                  Obx(() => controller.isVideoLoading.isFalse && controller.posts.isEmpty
                      ? Center(
                          child: Padding(
                            padding: EdgeInsets.symmetric(horizontal: 20.w),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.video_library_outlined,
                                  size: 80.sp,
                                  color: kPrimaryColor,
                                ),
                                SizedBox(height: 15.h),
                                Text(
                                  "No videos to show",
                                  style:
                                      AppStyles.appBarHeadingTextStyle().copyWith(fontSize: 20.sp, fontWeight: FontWeight.w700, color: kPrimaryColor),
                                  textAlign: TextAlign.center,
                                ),
                                SizedBox(height: 8.h),
                                Text(
                                  "It looks like the accounts you follow haven't posted any videos yet. Start exploring to discover new content!",
                                  style: AppStyles.labelTextStyle().copyWith(fontSize: 16.sp, fontWeight: FontWeight.w500, color: kWhiteColor),
                                  textAlign: TextAlign.center,
                                ),
                                SizedBox(height: 25.h),
                                CustomButton(
                                    width: 150.w,
                                    height: 50.h,
                                    title: 'Explore',
                                    onPressed: () {
                                      Get.find<BottomBarController>().selectedIndex.value = 1;
                                    }),
                              ],
                            ),
                          ),
                        )
                      : VideoPlayerWidget(controller: controller))),
        ),
      ),
    );
  }
}
