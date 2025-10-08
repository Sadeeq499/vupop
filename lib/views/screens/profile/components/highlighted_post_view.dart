import 'package:cached_video_player_plus/cached_video_player_plus.dart';
import 'package:card_swiper/card_swiper.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:socials_app/models/highlight_reel_model.dart';
import 'package:socials_app/utils/app_colors.dart';
import 'package:socials_app/utils/app_strings.dart';
import 'package:socials_app/utils/app_styles.dart';
import 'package:socials_app/views/custom_widgets/custom_button.dart';
import 'package:socials_app/views/custom_widgets/custom_scaffold.dart';
import 'package:socials_app/views/screens/profile/controller/profile_controller.dart';

class HighlightedPostView extends GetView<ProfileScreenController> {
  const HighlightedPostView({super.key});

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        controller.disposeVideoControllerDetail();
        return true;
      },
      child: Obx(
        () => ModalProgressHUD(
          inAsyncCall: controller.isVideoLoadingDetail.value,
          child: CustomScaffold(
            className: runtimeType.toString(),
            screenName: 'Highlighted Reels',
            isBackIcon: true,
            scaffoldKey: controller.scaffoldKeyDetailPost,
            floatingActionButton: Obx(() => Visibility(
                  visible: controller.highlightVideoControllers.length < 5,
                  child: FloatingActionButton(
                    onPressed: () {
                      Get.toNamed(kCreateHighlightedPost);
                    },
                    backgroundColor: kPrimaryColor,
                    child: const Icon(
                      Icons.add,
                      color: kBlackColor,
                    ),
                  ),
                )),
            body: Center(
              child: SizedBox(
                height: Get.height,
                width: Get.width,
                // decoration: BoxDecoration(
                //   color: Colors.transparent,
                //   border: Border.all(color: kPrimaryColor),
                //   borderRadius: BorderRadius.circular(40.w),
                // ),
                child: Obx(
                  () => Swiper(
                    itemCount: 6,
                    scrollDirection: Axis.horizontal,
                    transformer: ScaleAndFadeTransformer(),
                    layout: SwiperLayout.DEFAULT,
                    loop: false,
                    controller: controller.swiperController,
                    onIndexChanged: (index) async {},
                    itemBuilder: (BuildContext context, int index) {
                      if (controller.highlightVideoControllers.length < 5) {
                        if (index >= controller.highlightVideoControllers.length) {
                          return GestureDetector(
                            onTap: () {
                              Get.toNamed(kCreateHighlightedPost);
                            },
                            child: SizedBox(
                              height: 200.h,
                              width: 200.w,
                              child: Center(
                                child: DottedBorder(
                                  options: RoundedRectDottedBorderOptions(
                                    radius: const Radius.circular(12),
                                    color: kPrimaryColor,
                                  ),
                                  child: const Icon(Icons.add, size: 40, color: kPrimaryColor),
                                ),
                              ),
                            ),
                          );
                        }
                      } else {
                        final reel = controller.highlightReels[index];
                        final videoCont = controller.highlightVideoControllers[index];
                        final isOdd = (index % 2 == 0);

                        return Obx(
                          () => controller.isVideoLoadingDetail.value
                              ? const Center(child: SizedBox())
                              : Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    // Conditionally render the caption
                                    if (isOdd) ...[
                                      _buildCaption(reel, context),
                                      SizedBox(height: 20.h),
                                      _buildVideoPlayer(videoCont),
                                    ] else ...[
                                      _buildVideoPlayer(videoCont),
                                      SizedBox(height: 20.h),
                                      _buildCaption(reel, context),
                                    ],
                                  ],
                                ),
                        );
                      }
                      return const SizedBox();
                    },
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Helper methods to build the caption, video player, and edit button
  Widget _buildCaption(Reel reel, context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              "Caption",
              maxLines: 1,
              textAlign: TextAlign.justify,
              style: AppStyles.labelTextStyle().copyWith(fontSize: 19.sp, color: kPrimaryColor, fontWeight: FontWeight.bold),
            ),
            const Spacer(),
            _buildEditButton(reel, context)
          ],
        ),
        SizedBox(height: 10.h),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 10.w),
          child: Text(
            reel.caption,
            maxLines: 3,
            textAlign: TextAlign.justify,
            style: AppStyles.labelTextStyle().copyWith(
              fontSize: 17.sp,
              color: kPrimaryColor,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildVideoPlayer(CachedVideoPlayerPlus videoCont) {
    return Center(
      child: GestureDetector(
        onTap: () {
          if (videoCont.controller.value.isPlaying) {
            videoCont.controller.pause();
          } else {
            videoCont.controller.play();
          }
        },
        child: Center(
          child: FittedBox(
            fit: BoxFit.contain,
            child: Container(
              height: videoCont.controller.value.size.height,
              width: videoCont.controller.value.size.width,
              decoration: BoxDecoration(
                border: Border.all(color: kPrimaryColor),
              ),
              child: AspectRatio(
                aspectRatio: videoCont.controller.value.aspectRatio,
                child: VideoPlayer(videoCont.controller),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEditButton(reel, context) {
    return Align(
      alignment: Alignment.centerRight,
      child: GestureDetector(
        onTap: () {
          controller.caption.text = reel.caption;
          showModalBottomSheet(
            context: context,
            backgroundColor: kGreyContainerColor,
            builder: (_) {
              return _buildEditModal(reel);
            },
          );
        },
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 5.h, horizontal: 10.w),
          decoration: BoxDecoration(
            color: kPrimaryColor,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            'Edit',
            style: AppStyles.labelTextStyle().copyWith(
              color: kBlackColor,
              fontSize: 16.sp,
            ),
          ),
        ),
      ),
    );
  }

// Modal sheet for editing caption
  Widget _buildEditModal(reel) {
    return Container(
      height: 300.h,
      width: Get.width,
      padding: const EdgeInsets.all(10),
      child: Column(
        children: [
          Text(
            'Update the Caption',
            maxLines: 3,
            textAlign: TextAlign.justify,
            style: AppStyles.labelTextStyle().copyWith(fontSize: 20.sp, fontWeight: FontWeight.bold, color: kPrimaryColor),
          ),
          SizedBox(height: 20.h),
          TextField(
            maxLines: 3,
            controller: controller.caption,
            decoration: InputDecoration(
              enabledBorder: const UnderlineInputBorder(
                borderSide: BorderSide(color: kPrimaryColor),
              ),
              hintText: 'Write Your Caption',
              hintStyle: AppStyles.labelTextStyle().copyWith(
                color: Colors.white.withOpacity(0.6),
                fontSize: 12.sp,
              ),
              focusedBorder: const UnderlineInputBorder(
                borderSide: BorderSide(color: kPrimaryColor),
              ),
              fillColor: Colors.black,
              filled: true,
            ),
            style: TextStyle(
              color: kPrimaryColor,
              fontSize: 16.sp,
            ),
          ),
          SizedBox(height: 20.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              CustomButton(
                  textColor: kYouTubeTileColor,
                  width: 180.w,
                  height: 50.h,
                  title: "Delete the Reel",
                  onPressed: () {
                    Get.back();
                    controller.deleteHighlight(reel.id);
                  }),
              CustomButton(
                  width: 180.w,
                  height: 50.h,
                  title: "Update Caption",
                  onPressed: () {
                    Get.back();
                    controller.updateHighlight(reel.id);
                  }),
            ],
          ),
        ],
      ),
    );
  }
}
