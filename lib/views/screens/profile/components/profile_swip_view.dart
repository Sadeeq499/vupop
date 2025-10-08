import 'package:card_swiper/card_swiper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:socials_app/models/post_models.dart';
import 'package:socials_app/services/custom_snackbar.dart';
import 'package:socials_app/services/session_services.dart';
import 'package:socials_app/utils/app_colors.dart';
import 'package:socials_app/utils/common_code.dart';
import 'package:socials_app/views/custom_widgets/custom_scaffold.dart';
import 'package:socials_app/views/custom_widgets/share_bottom_sheet.dart';
import 'package:socials_app/views/custom_widgets/video_player_bottomsheet.dart';
import 'package:socials_app/views/screens/profile/controller/profile_controller.dart';

import '../../../custom_widgets/CustomImage.dart';

class ProfileSwipeViewPosts extends GetView<ProfileScreenController> {
  const ProfileSwipeViewPosts({super.key});

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
      body: Obx(
        () => ModalProgressHUD(
          inAsyncCall: controller.isLoading.value,
          child: SafeArea(
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 15.w, vertical: 15.h),
              decoration: const BoxDecoration(
                shape: BoxShape.rectangle,
              ),
              child: Obx(
                () => Swiper(
                  index: controller.tappedPostIndex.value,
                  itemCount: controller.videoControllers.length,
                  scrollDirection: Axis.horizontal,
                  transformer: ScaleAndFadeTransformer(),
                  layout: SwiperLayout.DEFAULT,
                  loop: false,
                  controller: controller.swiperController,
                  //TODO: comment it back if doesnt work
                  pagination: SwiperPagination(builder: DotSwiperPaginationBuilder(color: kWhiteColorTrans, activeColor: kPrimaryColor)),
                  /*onIndexChanged: (index) async {
                    controller.tappedPostIndex.value = index;
                    controller.isPlaying.value = true;
                    await controller.videoControllers[index].play();
                    if (index != 0) {
                      await controller.videoControllers[index - 1].pause();
                    }
                    if (index == controller.userPosts.length - 1) {
                      controller.isPlaying.value = true;
                      await controller.videoControllers[index].play();
                      CustomSnackbar.showSnackbar('No more posts to show');
                    } else {
                      controller.onIndexChanged(index);
                      // controller.updateViewCount
                    }
                  },*/
                  //new impl
                  onIndexChanged: (index) async {
                    // printLogs("=========Swiper index $index");

                    controller.tappedPostIndex.value = index;
                    controller.isPlaying.value = true;

                    // Stop any currently playing videos
                    for (int i = 0; i < controller.videoControllers.length; i++) {
                      if (i != index && controller.videoControllers[i].value.controller.value.isPlaying) {
                        await controller.videoControllers[i].pause();
                      }
                    }

                    // Play the current video
                    if (controller.videoControllers[index].value.controller.value.isInitialized) {
                      await controller.videoControllers[index].play();
                    } else {
                      // If not initialized yet, wait for it
                      controller.isVideoLoading.value = true;
                      await controller.videoControllers[index].initialize();
                      controller.isVideoLoading.value = false;
                      await controller.videoControllers[index].play();
                    }

                    // Prebuffer the next video
                    //TODO: uncomment it back if doesnt work
                    controller.preBufferNextVideo(index);

                    if (index == controller.userPosts.length - 1) {
                      CustomSnackbar.showSnackbar('No more posts to show');
                    } else {
                      controller.onIndexChanged(index);
                    }
                  },
                  itemBuilder: (BuildContext context, int index) {
                    // print('=============Swipe view index $index');
                    final post = controller.userPosts[controller.tappedPostIndex.value];
                    return Obx(
                      () => controller.isVideoLoading.value
                          // ? const Center(child: CircularProgressIndicator())
                          ? Center(
                              child: Stack(
                                children: [
                                  ModalProgressHUD(
                                    inAsyncCall: controller.isVideoLoading.value,
                                    progressIndicator: const SizedBox(),
                                    child: SizedBox(
                                      height: Get.height,
                                      width: Get.width,
                                      child: CachedImage(
                                        isCircle: false,
                                        url: controller.userPosts[controller.tappedPostIndex.value].thumbnail ?? '',
                                        height: Get.height,
                                        width: Get.width,
                                      ),
                                    ),
                                  ),

                                  // Cross icon with delayed appearance
                                  Positioned(
                                    top: 20, // Adjust this value as needed for proper positioning
                                    right: 20, // Adjust this value as needed for proper positioning
                                    child: FutureBuilder(
                                      future: Future.delayed(const Duration(seconds: 5)),
                                      builder: (context, snapshot) {
                                        return snapshot.connectionState == ConnectionState.done
                                            ? GestureDetector(
                                                onTap: () {
                                                  controller.videoControllers[controller.tappedPostIndex.value].pause();
                                                  Navigator.of(context).pop();
                                                  // Add your close functionality here
                                                  // For example: Get.back() or controller.closeVideo()
                                                },
                                                child: Container(
                                                  padding: const EdgeInsets.all(8),
                                                  decoration: BoxDecoration(
                                                    color: Colors.black.withOpacity(0.5),
                                                    shape: BoxShape.circle,
                                                  ),
                                                  child: const Icon(
                                                    Icons.close,
                                                    color: Colors.white,
                                                    size: 24,
                                                  ),
                                                ),
                                              )
                                            : const SizedBox.shrink(); // Invisible until 5 seconds pass
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            )
                          : VideoPlayerBottomSheet(
                              isOwnPost: true,
                              isPlaying: controller.isPlaying.value,
                              onPlayButtonTap: (v) {
                                controller.isPlaying.value = v;
                              },
                              isProfileView: true,
                              isDowloadButtonShow: false,
                              isFollowed: SessionService().isFollowingById(post.userId.id),
                              onFollowButtonTap: () {},

                              onProfileTap: () {},
                              followedUserId: controller.postDetail.value?.userId.id ?? "",
                              uploadedUserName: post.userId.name,
                              uploadedUserPic: post.userId.image ?? '',
                              isBottomSheet: false,
                              videoController: controller.videoControllers[index],
                              progress: controller.videoControllers[index].value.controller.value.position.inMilliseconds /
                                  controller.videoControllers[index].value.controller.value.duration.inMilliseconds,
                              // controller
                              //         .videoController!.value.position.inMilliseconds /
                              //     controller
                              //         .videoController!.value.duration.inMilliseconds,
                              isRatingTapped: controller.isRatingTapped.value,
                              ratings: post.averageRating,
                              post: controller.userPosts[controller.tappedPostIndex.value],
                              likeDislikeTapped: () {
                                // controller.updateLikeDislike(postId: post.id);
                                CustomSnackbar.showSnackbar("You can't like your own post");
                              },
                              reportTapped: () {
                                CustomSnackbar.showSnackbar("You can't report your own post");
                              },
                              ratingTapped: () {
                                CustomSnackbar.showSnackbar("You can't rate your own post");
                                // controller.isRatingTapped.value =
                                //     !controller.isRatingTapped.value;
                                // log('=======ratingTapped ${controller.isRatingTapped.value}');
                              },
                              onRatingChanged: (rating) {
                                controller.updateRating(postId: post.id, rating: rating);
                              },
                              userRating: controller.userRating.value,
                              shareTapped: () async {
                                showShareOptions(context, post: post);
                              },
                              onViewTapped: () {
                                /*controller.onTapPost(controller.tappedPostIndex.value);
                                controller.getUsersFromIds(post.views!.map((e) => e.id).toList());
                                showModalBottomSheet(
                                    context: context,
                                    backgroundColor: kBackgroundColor,
                                    isScrollControlled: true,
                                    shape: const RoundedRectangleBorder(
                                      borderRadius: BorderRadius.only(
                                        topLeft: Radius.circular(30),
                                        topRight: Radius.circular(30),
                                      ),
                                    ),
                                    builder: (context) {
                                      return FractionallySizedBox(
                                        heightFactor: 0.7,
                                        child: SizedBox(
                                          child: Padding(
                                            padding: EdgeInsets.symmetric(horizontal: 15.w, vertical: 15.h),
                                            child: Obx(
                                              () => controller.isViewedUsersLoading.value
                                                  ? const Center(child: CircularProgressIndicator())
                                                  : Column(
                                                      children: [
                                                        Center(
                                                          child: Text(
                                                            'Plays and Reaction',
                                                            style: AppStyles.labelTextStyle().copyWith(
                                                              color: Colors.white,
                                                              fontSize: 18.sp,
                                                              fontFamily: 'League Spartan',
                                                              fontWeight: FontWeight.w600,
                                                            ),
                                                          ),
                                                        ),
                                                        SizedBox(height: 20.h),
                                                        CustomTextField(
                                                          isPassword: false,
                                                          hint: "Search",
                                                          controller: controller.searchController,
                                                          icon: Icons.search,
                                                          onChanged: (value) {
                                                            controller.filterBottomSheetSearch(value);
                                                          },
                                                        ),
                                                        SizedBox(height: 20.h),
                                                        Center(
                                                          child: SizedBox(
                                                            width: Get.width,
                                                            child: Row(
                                                              mainAxisAlignment: MainAxisAlignment.center,
                                                              crossAxisAlignment: CrossAxisAlignment.center,
                                                              children: [
                                                                Image.asset(
                                                                  kVideoImage,
                                                                  color: kWhiteColor,
                                                                  scale: 5.0,
                                                                ),
                                                                SizedBox(width: 10.w),
                                                                Text(
                                                                  ' ${post.views?.length} plays',
                                                                  style: AppStyles.labelTextStyle()
                                                                      .copyWith(fontSize: 14.sp, fontWeight: FontWeight.w400),
                                                                ),
                                                              ],
                                                            ),
                                                          ),
                                                        ),
                                                        SizedBox(height: 20.h),
                                                        SizedBox(
                                                          width: Get.width,
                                                          child: Row(
                                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                            crossAxisAlignment: CrossAxisAlignment.center,
                                                            children: [
                                                              Text(
                                                                'Liked by',
                                                                style: AppStyles.labelTextStyle().copyWith(
                                                                  fontSize: 14.sp,
                                                                  fontWeight: FontWeight.w400,
                                                                ),
                                                              ),
                                                              Text(
                                                                ' ${post.likesCount} likes',
                                                                style: AppStyles.labelTextStyle().copyWith(
                                                                  color: kGreyRecentSearch,
                                                                  fontSize: 14.sp,
                                                                  fontWeight: FontWeight.w400,
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                        SizedBox(height: 20.h),
                                                        Expanded(
                                                          child: Obx(() => controller.searchBottomSheetList.isEmpty
                                                              ? Center(
                                                                  child: Text('No Viewer Found',
                                                                      style: AppStyles.labelTextStyle().copyWith(
                                                                        color: kGreyRecentSearch,
                                                                        fontSize: 14.sp,
                                                                        fontWeight: FontWeight.w400,
                                                                      )))
                                                              : ListView.builder(
                                                                  itemCount: controller.searchBottomSheetList.length,
                                                                  itemBuilder: (context, index) {
                                                                    final user = controller.searchBottomSheetList[index];
                                                                    bool isFollowed = controller.searchBottomSheetList[index].followers
                                                                        .contains(SessionService().user?.id);

                                                                    return Padding(
                                                                      padding: const EdgeInsets.all(8.0),
                                                                      child: UserFollowRow(
                                                                        onProfileTap: () {},
                                                                        name: user.name,
                                                                        imageUrl: user.image ?? '',
                                                                        isFollowed: isFollowed.obs,
                                                                        isFollowLoading: controller.viewedUsersLoadingMap[user.id] ?? false.obs,
                                                                        btnText: isFollowed ? 'Following' : 'Follow',
                                                                        onTap: () {
                                                                          controller.updateFollowStatus(
                                                                              followedUserId: user.id, index: index, isFromBottomSheet: true);
                                                                        },
                                                                        onBlockTap: () {
                                                                          printLogs('on reasons lst === ${controller.blockingReasons}');
                                                                          controller.isRatingTapped.value = false;
                                                                          showDialog(
                                                                              context: context,
                                                                              builder: (context) => Obx(
                                                                                    () => ReasonBottomSheet(
                                                                                      titleText: 'Block User',
                                                                                      reasons: controller.blockingReasons.value,
                                                                                      onCloseButton: () {
                                                                                        controller.selectedReason.value = 'Select Reason';
                                                                                        Get.back();
                                                                                      },
                                                                                      onButtonTap: () {
                                                                                        if (controller.selectedReason.value != "Select Reason") {
                                                                                          AppDialogs().showBlockUserConfirmationDialog(
                                                                                              onPressed: () async {
                                                                                            Get.back();
                                                                                            await controller.blockUser(
                                                                                                blockedUserId: user.id,
                                                                                                reason: controller.selectedReason.value);
                                                                                          });
                                                                                        } else {
                                                                                          CustomSnackbar.showSnackbar("Select reason");
                                                                                        }
                                                                                      },
                                                                                      onChange: controller.onReasonDropDownChange,
                                                                                      selectedReason: controller.selectedReason.value,
                                                                                      btnText: 'Block',
                                                                                    ),
                                                                                  ));
                                                                        },
                                                                      ),
                                                                    );
                                                                  },
                                                                )),
                                                        )
                                                      ],
                                                    ),
                                            ),
                                          ),
                                        ),
                                      );
                                    }).then((ab) {
                                  controller.searchController.clear();
                                });*/
                              },
                              ratingDisappear: (value) {
                                controller.isRatingTapped.value = value;
                              },
                              onDownloadClick: () {
                                controller.saveVideoLocally(index, videoUrl: post.maskVideo == "" ? post.video : post.maskVideo);
                              },
                              blockUserTapped: () {},
                            ),
                    );
                  },
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
            controller.updateShareCount(
              postId: post.id,
            );
          },
        );
      },
    );
  }
}
