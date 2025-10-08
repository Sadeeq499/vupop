import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:socials_app/services/session_services.dart';
import 'package:socials_app/views/custom_widgets/custom_scaffold.dart';
import 'package:socials_app/views/custom_widgets/video_player_bottomsheet.dart';
import 'package:socials_app/views/screens/followers_profile_screen/controller/followers_profile_controller.dart';

import '../../../../utils/app_strings.dart';

class FollowerHighlightedPostView extends GetView<FollowersProfileController> {
  const FollowerHighlightedPostView({super.key});

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        controller.videoControllerDetail.value.pause();
        controller.disposeVideoControllerDetail();
        return true;
      },
      child: Obx(
        () => ModalProgressHUD(
          inAsyncCall: controller.isVideoLoadingDetail.value,
          child: CustomScaffold(
            className: runtimeType.toString(),
            screenName: '',
            isBackIcon: false,
            leadingWidth: 0,
            isFullBody: true,
            appBarSize: 0,
            scaffoldKey: controller.scaffoldKeyDetailPost,
            body: SafeArea(
              child: Center(
                child: Obx(() {
                  if (controller.postDetail.value != null) {
                    return SizedBox(
                      height: Get.height,
                      width: Get.width,
                      // decoration: BoxDecoration(
                      //   color: Colors.transparent,
                      //   border: Border.all(color: kPrimaryColor),
                      //   borderRadius: BorderRadius.circular(40.w),
                      // ),
                      child: Obx(() => VideoPlayerBottomSheet(
                            followersProfileController: controller,
                            onFollowButtonTap: () async {
                              await controller.updateFollowStatus(
                                followedUserId: controller.postDetail.value?.userId.id ?? "",
                              );
                            },
                            onProfileTap: () {
                              Get.toNamed(kFollowersProfileScreen, arguments: controller.postDetail.value?.userId.id);
                            },
                            followedUserId: controller.postDetail.value?.userId.id ?? "",
                            isPlaying: controller.isPlaying.value,
                            onPlayButtonTap: (v) {
                              controller.isPlaying.value = v;
                            },
                            blockUserTapped: () {},
                            onDownloadClick: () {},
                            isDowloadButtonShow: false,
                            videoController: controller.videoControllerDetail.value,
                            post: controller.postDetail.value!,
                            likeDislikeTapped: () {},
                            ratingTapped: () {},
                            shareTapped: () {},
                            reportTapped: () {},
                            progress: 0.0,
                            ratings: 0.0,
                            isRatingTapped: false,
                            onRatingChanged: (p0) {},
                            userRating: 0.0,
                            uploadedUserPic: '',
                            uploadedUserName: '',
                            ratingDisappear: (po) {},
                            // onFollowButtonTap: () {},
                            isFollowed: SessionService().isFollowingById(controller.postDetail.value!.userId.id),
                            isBottomSheet: false,
                            isProfileView: true,
                          )),
                    );
                  } else {
                    return const CircularProgressIndicator();
                  }
                }),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
