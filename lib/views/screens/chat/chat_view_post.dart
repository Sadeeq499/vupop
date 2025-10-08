import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:socials_app/models/post_models.dart';
import 'package:socials_app/services/custom_snackbar.dart';
import 'package:socials_app/services/session_services.dart';
import 'package:socials_app/utils/app_colors.dart';
import 'package:socials_app/utils/app_dialogs.dart';
import 'package:socials_app/utils/common_code.dart';
import 'package:socials_app/views/custom_widgets/custom_scaffold.dart';
import 'package:socials_app/views/custom_widgets/share_bottom_sheet.dart';
import 'package:socials_app/views/custom_widgets/video_player_bottomsheet.dart';
import 'package:socials_app/views/screens/home/controller/home_controller.dart';

import '../../../utils/app_strings.dart';
import '../home/components/reasons_bottom_modal.dart';
import 'controller/chat_controller.dart';

class ChatVideoViewPosts extends GetView<ChatScreenController> {
  const ChatVideoViewPosts({
    super.key,
  });
  @override
  Widget build(BuildContext context) {
    return CustomScaffold(
      onWillPop: () {
        return false;
      },
      className: runtimeType.toString(),
      screenName: '',
      isBackIcon: false,
      leadingWidth: 0,
      isFullBody: true,
      appBarSize: 0,
      scaffoldKey: controller.scaffoldKeySwipe,
      onNotificationListener: (notificationInfo) {
        controller.isRatingTapped.value = false;
        if (notificationInfo.runtimeType == UserScrollNotification) {
          CommonCode().removeTextFieldFocus();
        }
        return false;
      },
      body: Obx(
        () => ModalProgressHUD(
          inAsyncCall: controller.isVideoLoading.value,
          child: SafeArea(
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 15.w, vertical: 15.h),
              decoration: const BoxDecoration(
                shape: BoxShape.rectangle,
              ),
              child: Obx(
                () => controller.isVideoLoading.value
                    ? const Center(child: CircularProgressIndicator())
                    : GestureDetector(
                        onTap: () {
                          controller.isRatingTapped.value = false;
                        },
                        child: Obx(
                          () => VideoPlayerBottomSheet(
                            onProfileTap: () {
                              Get.toNamed(kFollowersProfileScreen, arguments: controller.post?.userId.id);
                            },
                            followedUserId: controller.post?.userId.id ?? "",
                            onDownloadClick: () {
                              //controller.downloadVideo(post.video);
                            },
                            isPlaying: controller.isPlaying.value,
                            onPlayButtonTap: (v) {
                              controller.isPlaying.value = v;
                            },
                            isDowloadButtonShow: false,
                            uploadedUserPic: controller.post!.userId.image ?? '',
                            uploadedUserName: controller.post!.userId.name ?? '',
                            isBottomSheet: false,
                            videoController: controller.videoController!,
                            progress: 0,
                            // controller
                            //         .videoController!.value.position.inMilliseconds /
                            //     controller
                            //         .videoController!.value.duration.inMilliseconds,
                            isRatingTapped: controller.isRatingTapped.value,
                            ratings: controller.post!.averageRating.toDouble(),
                            post: controller.post!,
                            likeDislikeTapped: () {
                              controller.isRatingTapped.value = false;
                              controller.post!.likes.add(SessionService().user?.id ?? '');
                              controller.post!.likesCount++;
                              Get.find<HomeScreenController>().updateLikeDislike(postId: controller.post!.id, index: controller.index);
                            },
                            reportTapped: () {
                              showDialog(
                                context: context,
                                builder: (context) => Obx(
                                  () => ReasonBottomSheet(
                                    titleText: "Report Clip",
                                    reasons: Get.find<HomeScreenController>().reportingReasons.value,
                                    onCloseButton: () {
                                      Get.find<HomeScreenController>().selectedReason.value = 'Select Reason';
                                      Get.back();
                                    },
                                    onButtonTap: () {
                                      if (Get.find<HomeScreenController>().selectedReason.value != "Select Reason") {
                                        Get.find<HomeScreenController>()
                                            .reportClip(postId: controller.post!.id, reason: Get.find<HomeScreenController>().selectedReason.value);
                                      } else {
                                        CustomSnackbar.showSnackbar("Select reason");
                                      }
                                    },
                                    onChange: Get.find<HomeScreenController>().onReasonDropDownChange,
                                    selectedReason: Get.find<HomeScreenController>().selectedReason.value,
                                    btnText: 'Report',
                                  ),
                                ),
                              );
                            },
                            blockUserTapped: () {
                              showDialog(
                                  context: context,
                                  builder: (context) => Obx(
                                        () => ReasonBottomSheet(
                                          titleText: 'Block User',
                                          reasons: Get.find<HomeScreenController>().blockingReasons,
                                          onCloseButton: () {
                                            Get.find<HomeScreenController>().selectedReason.value = 'Select Reason';
                                            Get.back();
                                          },
                                          onButtonTap: () {
                                            if (Get.find<HomeScreenController>().selectedReason.value != "Select Reason") {
                                              AppDialogs().showBlockUserConfirmationDialog(onPressed: () async {
                                                Get.back();
                                                await Get.find<HomeScreenController>()
                                                    .blockUser(
                                                        blockedUserId: controller.post!.userId.id,
                                                        reason: Get.find<HomeScreenController>().selectedReason.value)
                                                    .then((value) {
                                                  Navigator.pop(context);
                                                });
                                              });
                                            } else {
                                              CustomSnackbar.showSnackbar("Select reason");
                                            }
                                          },
                                          onChange: Get.find<HomeScreenController>().onReasonDropDownChange,
                                          selectedReason: Get.find<HomeScreenController>().selectedReason.value,
                                          btnText: 'Block',
                                        ),
                                      ));
                            },
                            ratingTapped: () {
                              controller.isRatingTapped.value = !controller.isRatingTapped.value;
                            },
                            onRatingChanged: (rating) {
                              Get.find<HomeScreenController>().setRating(rating, controller.index);
                            },
                            userRating: Get.find<HomeScreenController>().ratingValue.value,
                            shareTapped: () async {
                              printLogs('-----on share');
                              controller.isRatingTapped.value = false;
                              showShareOptions(
                                index: controller.index,
                                context,
                                post: controller.post!,
                              );
                            },
                            ratingDisappear: (value) {
                              controller.isRatingTapped.value = value;
                            },
                            isFollowed: SessionService().isFollowingById(controller.post!.userId.id),
                            onFollowButtonTap: () {},
                          ),
                        ),
                      ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void showShareOptions(
    BuildContext context, {
    required PostModel post,
    required int index,
  }) {
    showModalBottomSheet(
      context: context,
      backgroundColor: kBackgroundColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      builder: (BuildContext context) {
        return ShareOptionsBottomSheet(
          onInAppShare: () async {
            CommonCode().withInAppShare(context, post);
          },
          videoLink: post.maskVideo == "" ? post.video : post.maskVideo,
          onShareSuccess: () {
            Get.find<HomeScreenController>().updateShareCount(index: index, postId: post.id, postedUserId: post.userId.id);
          },
        );
      },
    );
  }
}
