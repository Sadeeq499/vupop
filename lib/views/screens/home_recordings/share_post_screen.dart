import 'package:cached_video_player_plus/cached_video_player_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:socials_app/services/custom_snackbar.dart';
import 'package:socials_app/utils/app_colors.dart';
import 'package:socials_app/utils/app_images.dart';
import 'package:socials_app/utils/app_strings.dart';
import 'package:socials_app/utils/app_styles.dart';
import 'package:socials_app/views/custom_widgets/custom_scaffold.dart';
import 'package:socials_app/views/screens/home_recordings/components/videosharingbottom.dart';
import 'package:socials_app/views/screens/home_recordings/components/videosharingtabs.dart';
import 'package:socials_app/views/screens/home_recordings/controller/recording_cont.dart';
import 'package:super_tooltip/super_tooltip.dart';

import '../../../utils/common_code.dart';

class SharePostScreen extends GetView<RecordingController> {
  const SharePostScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => ModalProgressHUD(
        inAsyncCall: controller.isLoading.value,
        child: CustomScaffold(
          className: "ShareScreen",
          screenName: "New Post",
          backIconColor: kPrimaryColor,
          onBackButtonPressed: () {
            controller.resetRecording();
            Get.back();
          },
          title: Text(
            "New Post",
            style: AppStyles.appBarHeadingTextStyle()
                .copyWith(fontFamily: "Norwester", fontSize: 20.sp, fontWeight: FontWeight.w800, color: kWhiteColor),
          ),
          scaffoldKey: controller.scaffoldKeyPost,
          body: SingleChildScrollView(
            child: Column(
              children: [
                SizedBox(
                  height: 30.h,
                ),
                SizedBox(
                  width: Get.width,
                  height: 350.h,
                  child: Obx(
                    () => controller.videoPlayerController.value == null
                        ? const Center(child: CircularProgressIndicator())
                        : Stack(
                            alignment: Alignment.center,
                            children: [
                              Center(
                                child: Obx(
                                  () => AspectRatio(
                                    aspectRatio: controller.isFileSelected.isTrue
                                        ? controller.trimmer.value.videoPlayerController!.value.aspectRatio
                                        : controller.videoPlayerController.value!.value.aspectRatio,
                                    child: CachedVideoPlayerPlus(controller.videoPlayerController.value!),
                                  ),
                                ),
                              ),
                              Positioned(
                                  bottom: 0.h,
                                  // left: 0.w,
                                  child: controller.isFileSelected.isTrue && controller.isAudioAvailable.isFalse
                                      ? SizedBox.shrink()
                                      : controller.isPortrait.value
                                          ? VideoSharingTab(
                                              controller: controller,
                                              height: 40,
                                              width: 100,
                                              iconScale: 6,
                                            )
                                          : VideoSharingTab(height: 65, width: 140, iconScale: 3.3, controller: controller)),
                            ],
                          ),
                  ),
                ),
                SizedBox(height: 20.h),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Selected video orientation',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18.sp,
                      fontFamily: 'League Spartan',
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ),
                SizedBox(height: 20.h),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Container(
                    width: 280.w,
                    height: 50.h,
                    decoration: ShapeDecoration(
                      color: kWebAppTabsBackgroundColo,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 130.w,
                          height: 50.h,
                          decoration: ShapeDecoration(
                            color: controller.isPortrait.isTrue ? kPrimaryColor : kWebAppTabsBackgroundColo,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Image.asset(
                                kPotraitIcon,
                                width: 25.w,
                                height: 25.h,
                                color: !controller.isPortrait.isTrue ? kPrimaryColor : Colors.black,
                              ),
                              SizedBox(width: 5.w),
                              Center(
                                child: Text(
                                  'Portrait',
                                  style: TextStyle(
                                    color: !controller.isPortrait.isTrue ? kPrimaryColor : Colors.black,
                                    fontSize: 18.sp,
                                    fontFamily: 'League Spartan',
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(width: 10.w),
                        Container(
                          width: 130.w,
                          height: 50.h,
                          decoration: ShapeDecoration(
                            color: controller.isPortrait.isFalse ? kPrimaryColor : kWebAppTabsBackgroundColo,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                          child: Row(
                            children: [
                              Image.asset(
                                kLandscapeIcon,
                                width: 25.w,
                                height: 25.h,
                                color: !controller.isPortrait.isFalse ? kPrimaryColor : Colors.black,
                              ),
                              SizedBox(width: 5.w),
                              Center(
                                child: Text(
                                  'Landscape',
                                  style: TextStyle(
                                    color: !controller.isPortrait.isFalse ? kPrimaryColor : Colors.black,
                                    fontSize: 18.sp,
                                    fontFamily: 'League Spartan',
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                ///removed location while sharing video as suggested by @Dave
                /*SizedBox(height: 20.h),
                SizedBox(
                  width: Get.width,
                  // height: 20.h,
                  child: Row(
                    children: [
                      //location icon
                      Icon(
                        Icons.location_on,
                        color: kWhiteColor,
                        size: 25.sp,
                      ),
                      SizedBox(
                        width: 10.w,
                      ),
                      Text(
                        "Location",
                        style: AppStyles.labelTextStyle().copyWith(fontSize: 20.sp, fontWeight: FontWeight.w400, color: kWhiteColor),
                      ),
                      const Spacer(),
                      GestureDetector(
                        onTap: () async {
                          await Get.toNamed(kSetLocationScreen)?.then((value) {
                            if (value != null) {
                              controller.address.value = value['address'];
                              controller.lattitude.value = value['lat'];
                              controller.longitude.value = value['lng'];
                            }
                          });
                        },
                        child: Icon(
                          Icons.arrow_forward_ios,
                          color: kPrimaryColor,
                          size: 25.sp,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 20.h),
                SizedBox(
                  width: Get.width,
                  // height: 50.h,
                  child: Obx(
                    () => Text(
                      "${controller.address.value} ${controller.lattitude.value} N ${controller.longitude.value} W",
                      style: AppStyles.labelTextStyle().copyWith(fontSize: 20.sp, fontWeight: FontWeight.w400, color: kPrimaryColor),
                      maxLines: 4,
                    ),
                  ),
                ),*/
                SizedBox(height: 20.h),
                if (controller.isFileSelected.isTrue) ...{
                  /// @ Location section
                  SizedBox(
                    width: Get.width,
                    //height: 20.h,
                    child: Row(
                      children: [
                        //location icon
                        Icon(
                          Icons.location_on,
                          color: kWhiteColor,
                          size: 25.sp,
                        ),
                        SizedBox(
                          width: 10.w,
                        ),
                        Text(
                          "Location",
                          style: AppStyles.labelTextStyle().copyWith(fontSize: 20.sp, fontWeight: FontWeight.w400, color: kWhiteColor),
                        ),
                        SizedBox(
                          width: 10.w,
                        ),
                        GestureDetector(
                          onTap: () async {
                            await controller.tooltipControllerLocation.showTooltip();
                          },
                          child: SuperTooltip(
                            backgroundColor: kGreyContainerColor,
                            showBarrier: true,
                            controller: controller.tooltipControllerLocation,
                            content: Text(
                              "Add location to your upload to help people find your clip",
                              softWrap: true,
                              style: AppStyles.labelTextStyle().copyWith(fontSize: 14.sp, fontWeight: FontWeight.w400, color: kPrimaryColor),
                            ),
                            child: Container(
                              width: 24.0,
                              height: 24.0,
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                color: kPrimaryColor,
                              ),
                              child: const Icon(
                                size: 18,
                                Icons.question_mark_sharp,
                                color: kBlackColor,
                              ),
                            ),
                          ),
                        ),
                        const Spacer(),
                        GestureDetector(
                          onTap: () {
                            Get.toNamed(kSetLocationScreen)?.then((value) {
                              if (value != null) {
                                controller.address.value = value['address'];
                                controller.lattitude.value = value['lat'];
                                controller.longitude.value = value['long'];
                              }
                            });
                          },
                          child: Icon(
                            Icons.arrow_forward_ios,
                            color: kPrimaryColor,
                            size: 25.sp,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 20.h),
                  Obx(() => Container(
                        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
                        decoration: BoxDecoration(
                          color: controller.address.value.isEmpty ? null : kGreyContainerColor,
                          borderRadius: BorderRadius.circular(4.r),
                        ),
                        child: Obx(() => Text(
                              controller.address.value,
                              style: AppStyles.labelTextStyle().copyWith(
                                fontSize: 16.sp,
                                color: kPrimaryColor,
                              ),
                            )),
                      )),
                  SizedBox(height: 20.h),
                },

                /// @ Mention section
                SizedBox(
                  width: Get.width,
                  //height: 20.h,
                  child: Row(
                    children: [
                      //location icon
                      Icon(
                        Icons.alternate_email,
                        color: kWhiteColor,
                        size: 25.sp,
                      ),
                      SizedBox(
                        width: 10.w,
                      ),
                      Text(
                        "Mentions",
                        style: AppStyles.labelTextStyle().copyWith(fontSize: 20.sp, fontWeight: FontWeight.w400, color: kWhiteColor),
                      ),
                      SizedBox(
                        width: 10.w,
                      ),
                      GestureDetector(
                        onTap: () async {
                          await controller.tooltipControllerMentions.showTooltip();
                        },
                        child: SuperTooltip(
                          backgroundColor: kGreyContainerColor,
                          showBarrier: true,
                          controller: controller.tooltipControllerMentions,
                          content: Text(
                            "Mention broadcaster or brand accounts to get more engagements on your clips",
                            softWrap: true,
                            style: AppStyles.labelTextStyle().copyWith(fontSize: 14.sp, fontWeight: FontWeight.w400, color: kPrimaryColor),
                          ),
                          child: Container(
                            width: 24.0,
                            height: 24.0,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: kPrimaryColor,
                            ),
                            child: const Icon(
                              size: 18,
                              Icons.question_mark_sharp,
                              color: kBlackColor,
                            ),
                          ),
                        ),
                      ),
                      const Spacer(),
                      GestureDetector(
                        onTap: () {
                          Get.toNamed(kMentionScreenRoute);
                        },
                        child: Icon(
                          Icons.arrow_forward_ios,
                          color: kPrimaryColor,
                          size: 25.sp,
                        ),
                      ),
                      // IconButton(
                      //   icon: Icon(
                      //     Icons.arrow_forward_ios,
                      //     color: kPrimaryColor,
                      //     size: 25.sp,
                      //   ),
                      //   onPressed: () {
                      //
                      //   },
                      // ),
                    ],
                  ),
                ),
                SizedBox(height: 20.h),
                Container(
                  padding: EdgeInsets.symmetric(vertical: 12),
                  // height: 60.h,
                  child: Obx(
                    () => Wrap(
                      alignment: WrapAlignment.start, // Align items to the start
                      spacing: 10.w,
                      runSpacing: 10.h,
                      children: controller.mentionList.where((e) => e.isSelected).map((e) {
                        return Container(
                          // width: Get.width * 0.3, // Ensure this is commented out
                          height: 35.h,
                          decoration: BoxDecoration(
                            color: kHintGreyColor,
                            borderRadius: BorderRadius.circular(5),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              SizedBox(width: 6.w),
                              ClipRRect(
                                  borderRadius: BorderRadius.circular(4.r),
                                  child: Image.network(
                                    e.imageUrl,
                                    width: 30.w,
                                    height: 30.h,
                                    errorBuilder: (context, error, stackTrace) {
                                      return Image.asset(
                                        kdummyPerson,
                                        width: 30.w,
                                        height: 30.h,
                                      );
                                    },
                                  )),
                              SizedBox(width: 10.w),
                              Text(
                                e.name,
                                style: GoogleFonts.leagueSpartan(
                                  fontSize: 14.sp,
                                  fontWeight: FontWeight.w600,
                                  color: kPrimaryColor,
                                ),
                              ),
                              SizedBox(width: 16.w),
                              GestureDetector(
                                onTap: () {
                                  controller.removeMention(controller.mentionList.indexOf(e));
                                  controller.update();
                                },
                                child: CircleAvatar(
                                  radius: 8.r,
                                  backgroundColor: kPrimaryColor,
                                  child: Center(
                                    child: Icon(
                                      Icons.close,
                                      color: kBlackColor,
                                      size: 16.sp,
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(width: 5.w),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ),

                SizedBox(height: 40.h),
                SizedBox(
                  width: Get.width,
                  // height: 20.h,
                  child: Row(
                    children: [
                      //location icon
                      Icon(
                        Icons.tag,
                        color: kWhiteColor,
                        size: 25.sp,
                      ),
                      SizedBox(
                        width: 10.w,
                      ),
                      Text(
                        "Hashtags",
                        style: AppStyles.labelTextStyle().copyWith(fontSize: 20.sp, fontWeight: FontWeight.w400, color: kWhiteColor),
                      ),

                      SizedBox(
                        width: 10.w,
                      ),
                      GestureDetector(
                        onTap: () async {
                          await controller.tooltipControllerTags.showTooltip();
                        },
                        child: SuperTooltip(
                          backgroundColor: kGreyContainerColor,
                          showBarrier: true,
                          controller: controller.tooltipControllerTags,
                          content: Text(
                            "Add context to your upload to help people find your clip",
                            softWrap: true,
                            style: AppStyles.labelTextStyle().copyWith(fontSize: 14.sp, fontWeight: FontWeight.w400, color: kPrimaryColor),
                          ),
                          child: Container(
                            width: 24.0,
                            height: 24.0,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: kPrimaryColor,
                            ),
                            child: const Icon(
                              size: 18,
                              Icons.question_mark_sharp,
                              color: kBlackColor,
                            ),
                          ),
                        ),
                      ),
                      const Spacer(),
                      GestureDetector(
                        onTap: () {
                          Get.toNamed(kHashTagScreenRoute);
                        },
                        child: Icon(
                          Icons.arrow_forward_ios,
                          color: kPrimaryColor,
                          size: 25.sp,
                        ),
                      ),
                      // IconButton(
                      //   icon: Icon(
                      //     Icons.arrow_forward_ios,
                      //     color: kPrimaryColor,
                      //     size: 25.sp,
                      //   ),
                      //   onPressed: () {
                      //     Get.toNamed(kHashTagScreenRoute);
                      //   },
                      // ),
                    ],
                  ),
                ),
                SizedBox(height: 20.h),
                SizedBox(
                  width: Get.width,
                  height: 40.h,
                  child: Wrap(
                    spacing: 10.w,
                    runSpacing: 10.h,
                    children: controller.selectedHashTags
                        .map((e) => Container(
                              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
                              decoration: BoxDecoration(
                                color: kGreyContainerColor,
                                borderRadius: BorderRadius.circular(4.r),
                              ),
                              child: Text(
                                e,
                                style: AppStyles.labelTextStyle().copyWith(
                                  fontSize: 16.sp,
                                  color: kPrimaryColor,
                                ),
                              ),
                            ))
                        .toList(),
                  ),
                ),
                SizedBox(height: 20.h),
                // const Spacer(),

                /// share b

                SizedBox(
                  height: 10,
                )
              ],
            ),
          ),
          bottomNavigationBar: VideoSharingBottom(
            onPressed: () {
              if (controller.isFileSelected.value) {
                print('===========getLocation address before on btn ${controller.address.value} ${controller.address}');
                print('===========getLocation lattitude before on btn ${controller.longitude.value} ${controller.longitude}');
                print('===========getLocation longitude before on btn ${controller.lattitude.value} ${controller.lattitude}');
                if (controller.longitude.value == 0.0 || controller.lattitude.value == 0.0) {
                  CustomSnackbar.showSnackbar("Please select a location!");
                  return;
                }
              }
              printLogs('Share button pressed ${controller.isPortrait.isTrue}');

              //if (controller.mentionList.isNotEmpty && controller.hashTagList.isNotEmpty) {
              // controller.videoPlayerController.value?.dispose();
              controller.shareVideo();
              // } else {
              //   if (controller.isMention.isFalse) {
              //     CustomSnackbar.showSnackbar("Add at least one mention");
              //   }
              //   if (controller.selectedHashTags.isEmpty) {
              //     CustomSnackbar.showSnackbar("Add at least one tag");
              //   }
              // }
              // Get.toNamed(kSignInRoute);
            },
          ),
        ),
      ),
    );
  }
}
