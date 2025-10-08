import 'package:cached_video_player_plus/cached_video_player_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:socials_app/utils/app_colors.dart';
import 'package:socials_app/utils/app_images.dart';
import 'package:socials_app/utils/app_styles.dart';
import 'package:socials_app/views/screens/home_recordings/controller/recording_cont.dart';

import '../../../utils/common_code.dart';

class HashTagScreen extends GetView<RecordingController> {
  const HashTagScreen({super.key});

  @override
  Widget build(BuildContext context) {
    Future.microtask(() {
      controller.getTendingHashTags();
    });
    return GestureDetector(
      onTap: () {
        controller.isKeyboardTapped.value = false;
        CommonCode().removeTextFieldFocus();
      },
      child: NotificationListener(
        onNotification: (notificationInfo) {
          printLogs('=============notificationInfo.runtimeType ${notificationInfo.runtimeType}');
          if (notificationInfo.runtimeType == UserScrollNotification) {
            controller.isKeyboardTapped.value = false;
            CommonCode().removeTextFieldFocus();
          }
          return false;
        },
        child: SafeArea(
          maintainBottomViewPadding: true,
          child: Scaffold(
            resizeToAvoidBottomInset: false,
            body: WillPopScope(
              onWillPop: () async {
                if (controller.selectedHashTags.isNotEmpty) {
                  controller.isTags.value = true;
                }
                controller.isKeyboardTapped.value = false;
                FocusScope.of(context).unfocus();
                CommonCode().removeTextFieldFocus();
                // return true;
                return false;
              },
              child: GestureDetector(
                onTap: () {
                  controller.isKeyboardTapped.value = false;
                  FocusScope.of(context).unfocus();
                },
                child: SafeArea(
                  child: Stack(
                    children: [
                      Obx(
                        () => controller.videoPlayerController.value == null
                            ? const Center(child: CircularProgressIndicator())
                            : Center(
                                child: Obx(
                                  () => AspectRatio(
                                    aspectRatio: controller.videoPlayerController.value!.value.aspectRatio,
                                    child: CachedVideoPlayerPlus(controller.videoPlayerController.value!),
                                  ),
                                ),
                              ),
                      ),
                      // CachedVideoPlayerPlus(controller.videoPlayerController.value!),
                      Container(
                        height: Get.height,
                        width: Get.width,
                        color: kBlackColor.withOpacity(0.5),
                      ),
                      Positioned(
                        top: 20.h,
                        left: 20.w,
                        child: SizedBox(
                          width: Get.width,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              GestureDetector(
                                onTap: () {
                                  if (controller.selectedHashTags.isNotEmpty) {
                                    controller.isTags.value = true;
                                  }
                                  controller.isKeyboardTapped.value = false;
                                  CommonCode().removeTextFieldFocus();
                                  Get.back();
                                },
                                child: Image.asset(
                                  kBackIcon,
                                  width: 34.w,
                                  height: 34.h,
                                ),
                              ),
                              SizedBox(width: 15.w),
                              Text(
                                'Hashtag',
                                style: AppStyles.appBarHeadingTextStyle().copyWith(
                                  fontFamily: "Norwester",
                                  fontSize: 20.sp,
                                  fontWeight: FontWeight.w800,
                                  color: kWhiteColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      // Trending Hashtags Section
                      if (controller.trendingHashtags.isNotEmpty)
                        Positioned(
                          top: 80.h,
                          right: 0.w,
                          left: 0.w,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Align(
                                alignment: Alignment.centerLeft,
                                child: Container(
                                  margin: EdgeInsets.only(left: 16),
                                  child: Text(
                                    'Trending Hashtags',
                                    style: AppStyles.labelTextStyle().copyWith(
                                      fontSize: 16.sp,
                                      fontWeight: FontWeight.w600,
                                      color: kWhiteColor,
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(height: 12.h),
                              Obx(
                                () => Wrap(
                                  spacing: 8.w,
                                  runSpacing: 8.h,
                                  // clipBehavior: Clip.hardEdge,
                                  // alignment: WrapAlignment.center,
                                  children: controller.trendingHashtags
                                      .map((tag) => GestureDetector(
                                            onTap: () {
                                              if (controller.selectedHashTags.contains(tag.id)) {
                                                controller.selectedHashTags.remove(tag.id);
                                              } else {
                                                controller.selectedHashTags.add(tag.id ?? "");
                                              }
                                            },
                                            child: Container(
                                              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
                                              decoration: BoxDecoration(
                                                color: kGreyContainerColor,
                                                borderRadius: BorderRadius.circular(4.r),
                                              ),
                                              child: Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  Text(
                                                    tag.id ?? "",
                                                    style: AppStyles.labelTextStyle().copyWith(
                                                      fontSize: 16.sp,
                                                      color: controller.selectedHashTags.contains(tag.id) ? kPrimaryColor : kWhiteColor,
                                                    ),
                                                  ),
                                                  if (controller.selectedHashTags.contains(tag.id)) ...[
                                                    SizedBox(width: 8.w),
                                                    Icon(
                                                      Icons.check,
                                                      size: 16.sp,
                                                      color: kPrimaryColor,
                                                    ),
                                                  ],
                                                ],
                                              ),
                                            ),
                                          ))
                                      .toList(),
                                ),
                              ),
                              SizedBox(height: 20.h),
                            ],
                          ),
                        ),

                      Positioned(
                        top: 0.h,
                        child: Container(
                          height: Get.height,
                          width: Get.width,
                          padding: EdgeInsets.only(
                            left: 20.w,
                            right: 20.w,
                            top: 20.h,
                            bottom: controller.isKeyboardTapped.value ? 20.h : 36.h,
                          ),
                          child: Obx(
                            () => Column(
                              mainAxisAlignment: controller.isKeyboardTapped.value ? MainAxisAlignment.center : MainAxisAlignment.end,
                              children: [
                                TextFormField(
                                  onTap: () {
                                    controller.isKeyboardTapped.value = true;
                                  },
                                  controller: controller.tecHashTag,
                                  autofocus: false,
                                  style: AppStyles.labelTextStyle().copyWith(
                                    fontSize: 14.sp,
                                    fontWeight: FontWeight.w500,
                                    color: kWhiteColor,
                                  ),
                                  onChanged: (value) => controller.searchHashTag(value),
                                  onFieldSubmitted: (value) {
                                    if (value.trim().isNotEmpty) {
                                      if (value.startsWith('#')) {
                                        controller.selectedHashTags.addIf(!controller.selectedHashTags.contains(value), value);
                                      } else {
                                        controller.selectedHashTags.addIf(!controller.selectedHashTags.contains('#$value'), '#$value');
                                      }
                                      controller.tecHashTag.clear();
                                    }
                                    controller.isKeyboardTapped.value = false;
                                    controller.isTags.value = true;
                                    FocusScope.of(context).unfocus();
                                  },
                                  validator: (value) {
                                    if (value == null) {
                                      return 'Please add hashtags';
                                    }
                                    if (value.length < 2) {
                                      return 'Please add at least 2 characters';
                                    }
                                    return null;
                                  },
                                  decoration: InputDecoration(
                                    hintText: "Add hashtags",
                                    hintStyle: AppStyles.labelTextStyle().copyWith(
                                      fontSize: 14.sp,
                                      fontWeight: FontWeight.w500,
                                      color: kHintGreyColor,
                                    ),
                                    suffixIcon: IconButton(
                                      icon: Icon(Icons.close),
                                      color: kPrimaryColor,
                                      onPressed: () {
                                        controller.tecHashTag.clear();
                                      },
                                    ),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(4.r),
                                      borderSide: BorderSide.none,
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(4.r),
                                      borderSide: BorderSide.none,
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(4.r),
                                      borderSide: BorderSide.none,
                                    ),
                                    filled: true,
                                    contentPadding: const EdgeInsets.symmetric(vertical: 5, horizontal: 16),
                                    fillColor: kGreyContainerColor,
                                  ),
                                ),
                                SizedBox(height: 20.h),

                                // Selected Hashtags Section
                                Obx(
                                  () => SizedBox(
                                    width: Get.width,
                                    height: controller.selectedHashTags.isEmpty
                                        ? 30.h
                                        : controller.selectedHashTags.length == 1
                                            ? controller.selectedHashTags.length * 100.h
                                            : controller.selectedHashTags.length * 50.h,
                                    child: Wrap(
                                      spacing: 8.w,
                                      runSpacing: 8.h,
                                      children: controller.selectedHashTags
                                          .map((hashTag) => GestureDetector(
                                                onTap: () {
                                                  controller.selectedHashTags.remove(hashTag);
                                                },
                                                child: Container(
                                                  padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
                                                  decoration: BoxDecoration(
                                                    color: kGreyContainerColor,
                                                    borderRadius: BorderRadius.circular(4.r),
                                                  ),
                                                  child: Row(
                                                    mainAxisSize: MainAxisSize.min,
                                                    children: [
                                                      Text(
                                                        hashTag,
                                                        style: AppStyles.labelTextStyle().copyWith(
                                                          fontSize: 16.sp,
                                                          color: kPrimaryColor,
                                                        ),
                                                      ),
                                                      SizedBox(width: 8.w),
                                                      Icon(Icons.close, size: 16.sp, color: kPrimaryColor),
                                                    ],
                                                  ),
                                                ),
                                              ))
                                          .toList(),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
