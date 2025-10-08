import 'package:cached_video_player_plus/cached_video_player_plus.dart';
import 'package:video_player/video_player.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:socials_app/models/recordings_models/mention_model.dart';
import 'package:socials_app/utils/app_colors.dart';
import 'package:socials_app/utils/app_images.dart';
import 'package:socials_app/utils/app_styles.dart';
import 'package:socials_app/views/screens/home_recordings/components/mention_widget.dart';
import 'package:socials_app/views/screens/home_recordings/controller/recording_cont.dart';

class MentionScreen extends GetView<RecordingController> {
  const MentionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    if (controller.mentionList.isEmpty) {
      Future.microtask(() {
        controller.getActiveEditors();
      });
    }
    return SafeArea(
      maintainBottomViewPadding: true,
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        body: SafeArea(
          child: Stack(
            children: [
              Obx(
                () => controller.videoPlayerController.value == null
                    ? const Center(child: CircularProgressIndicator())
                    : Center(
                        child: Obx(
                          () => AspectRatio(
                            aspectRatio: controller.videoPlayerController.value!.controller.value.aspectRatio,
                            child: VideoPlayer(controller.videoPlayerController.value!.controller),
                          ),
                        ),
                      ),
              ),
              // CachedVideoPlayerPlus(controller.videoPlayerController.value!),
              Container(
                height: Get.height,
                width: Get.width,
                color: kBlackColor.withOpacity(0.5),
                padding: EdgeInsets.only(
                  left: 20.w,
                  right: 20.w,
                  top: 20.h,
                ),
                child: Column(
                  children: [
                    SizedBox(
                      width: Get.width,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          GestureDetector(
                            onTap: () {
                              if (controller.mentionList.any((element) => element.isSelected)) {
                                controller.isMention.value = true;
                              }
                              Get.back();
                            },
                            child: Image.asset(kBackIcon, width: 34.w, height: 34.h),
                          ),
                          SizedBox(width: 15.w),
                          Text(
                            'Mention',
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
                    SizedBox(height: 20.h),
                    TextFormField(
                      controller: controller.tecMentions,
                      autofocus: false,
                      style: AppStyles.labelTextStyle().copyWith(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w500,
                        color: kWhiteColor,
                      ),
                      onChanged: (value) => controller.searchMention(value),
                      decoration: InputDecoration(
                        hintText: "Mention any broadcasters you want",
                        hintStyle: AppStyles.labelTextStyle().copyWith(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w500,
                          color: kHintGreyColor,
                        ),
                        suffixIcon: IconButton(
                          icon: Icon(Icons.close),
                          color: kPrimaryColor,
                          onPressed: () {
                            controller.tecMentions.clear();
                          },
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(4.r),
                          borderSide: const BorderSide(
                            color: kGreyContainerColor,
                            width: 2.0,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(4.r),
                          borderSide: const BorderSide(
                            color: kPrimaryColor,
                            width: 2.0,
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(4.r),
                          borderSide: const BorderSide(
                            color: kGreyContainerColor,
                          ),
                        ),
                        filled: true,
                        contentPadding: const EdgeInsets.symmetric(vertical: 5, horizontal: 16),
                        fillColor: kGreyContainerColor,
                      ),
                    ),
                    SizedBox(height: 40.h),
                    SizedBox(
                      width: Get.width,
                      height: Get.height * 0.6,
                      child: Obx(
                        () => ListView.builder(
                          shrinkWrap: true,
                          itemCount: controller.searchMentionList.isNotEmpty ? controller.searchMentionList.length : controller.mentionList.length,
                          itemBuilder: (context, index) {
                            MentionModel value =
                                controller.searchMentionList.isNotEmpty ? controller.searchMentionList[index] : controller.mentionList[index];
                            return GestureDetector(
                              onTap: () {
                                controller.selectMention(index);
                              },
                              child: MentionWidget(
                                value: value,
                              ),
                            );
                          },
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
    );
  }
}
