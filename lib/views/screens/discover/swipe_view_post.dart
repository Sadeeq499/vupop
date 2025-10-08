import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:socials_app/models/post_models.dart';
import 'package:socials_app/services/custom_snackbar.dart';
import 'package:socials_app/services/session_services.dart';
import 'package:socials_app/utils/app_colors.dart';
import 'package:socials_app/utils/app_dialogs.dart';
import 'package:socials_app/utils/app_images.dart';
import 'package:socials_app/utils/app_styles.dart';
import 'package:socials_app/utils/common_code.dart';
import 'package:socials_app/views/custom_widgets/customImage.dart';
import 'package:socials_app/views/custom_widgets/custom_scaffold.dart';
import 'package:socials_app/views/custom_widgets/custom_textfield.dart';
import 'package:socials_app/views/custom_widgets/share_bottom_sheet.dart';
import 'package:socials_app/views/custom_widgets/user_follow_row.dart';
import 'package:socials_app/views/custom_widgets/video_player_bottomsheet.dart';

import '../../../utils/app_strings.dart';
import '../home/components/reasons_bottom_modal.dart';
import 'controller/discover_controller.dart';

class DiscoverSwipeViewPosts extends GetView<DiscoverController> {
  const DiscoverSwipeViewPosts({super.key});

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
          inAsyncCall: false,
          // controller.isLoading.value,
          child: SafeArea(
            child: Container(
              padding: EdgeInsets.only(top: 15.h),
              decoration: const BoxDecoration(
                shape: BoxShape.rectangle,
              ),
              child: CarouselSlider.builder(
                itemCount: controller.videoControllers.length,
                options: CarouselOptions(
                  height: Get.height,
                  viewportFraction: 0.85,
                  enlargeCenterPage: true,
                  enableInfiniteScroll: false,
                  onPageChanged: (index, reason) async {
                    controller.tappedPostIndex.value = index;
                    controller.isRatingTapped.value = false;
                    controller.isPlaying.value = true;
                    await controller.videoControllers[index].play();
                    if (index != 0) {
                      await controller.videoControllers[index - 1].pause();
                    }
                    if (index == controller.filteredPosts.length - 1) {
                      await controller.videoControllers[index].pause();
                      CustomSnackbar.showSnackbar('No more posts to show');
                    } else {
                      controller.onIndexChanged(index);
                      // controller.updateViewCount
                    }
                  },
                ),
                itemBuilder: (context, index, realIndex) {
                  var post = controller.filteredPosts[controller.tappedPostIndex.value];
                  return Obx(
                    () => controller.isVideoLoading.value && index + 1 == controller.videoControllers.length
                        ? Center(
                            child: ModalProgressHUD(
                              inAsyncCall: controller.isVideoLoading.value,
                              child: SizedBox(
                                height: Get.height,
                                width: Get.width,
                                child: CachedImage(
                                  isCircle: false,
                                  url: controller.filteredPosts[index].thumbnail ?? '',
                                  height: Get.height,
                                  width: Get.width,
                                ),
                              ),
                            ),
                          )
                        : controller.isVideoLoading.value
                            ? Center(
                                child: Stack(
                                  alignment: Alignment.center,
                                  children: [
                                    // Show thumbnail while loading
                                    CachedImage(
                                      isCircle: false,
                                      url: controller.filteredPosts[index].thumbnail ?? '',
                                      height: Get.height,
                                      width: Get.width,
                                      fit: BoxFit.cover,
                                    ),
                                    // Loading indicator on top of thumbnail
                                    ModalProgressHUD(
                                      inAsyncCall: true,
                                      opacity: 0.5,
                                      child: SizedBox(
                                        height: Get.height,
                                        width: Get.width,
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            : GestureDetector(
                                onTap: () {
                                  controller.isRatingTapped.value = false;
                                },
                                child: Obx(
                                  () => VideoPlayerBottomSheet(
                                    onDownloadClick: () {
                                      controller.downloadVideo(post.video);
                                    },
                                    isPlaying: controller.isPlaying.value,
                                    onPlayButtonTap: (v) {
                                      controller.isPlaying.value = v;
                                      controller.isPlaying.refresh();
                                    },
                                    isDowloadButtonShow: false,
                                    uploadedUserPic: post.userId.image ?? '',
                                    uploadedUserName: post.userId.name ?? '',
                                    isBottomSheet: false,
                                    videoController: controller.videoControllers[index],
                                    progress: 0,
                                    // controller
                                    //         .videoController!.value.position.inMilliseconds /
                                    //     controller
                                    //         .videoController!.value.duration.inMilliseconds,
                                    isRatingTapped: controller.isRatingTapped.value,
                                    ratings: post.averageRating.toDouble(),
                                    post: controller.filteredPosts[controller.tappedPostIndex.value],
                                    likeDislikeTapped: () {
                                      controller.isRatingTapped.value = false;
                                      controller.updateLikeDislike(postId: controller.filteredPosts[controller.tappedPostIndex.value].id);
                                    },
                                    reportTapped: () {
                                      showDialog(
                                        context: context,
                                        builder: (context) => Obx(
                                          () => ReasonBottomSheet(
                                            titleText: "Report Clip",
                                            reasons: controller.reportingReasons.value,
                                            onCloseButton: () {
                                              controller.selectedReason.value = 'Select Reason';
                                              Get.back();
                                            },
                                            onButtonTap: () {
                                              if (controller.selectedReason.value != "Select Reason") {
                                                controller.reportClip(
                                                    postId: controller.filteredPosts[controller.tappedPostIndex.value].id,
                                                    reason: controller.selectedReason.value);
                                              } else {
                                                CustomSnackbar.showSnackbar("Select reason");
                                              }
                                            },
                                            onChange: controller.onReasonDropDownChange,
                                            selectedReason: controller.selectedReason.value,
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
                                                  reasons: controller.blockingReasons,
                                                  onCloseButton: () {
                                                    controller.selectedReason.value = 'Select Reason';
                                                    Get.back();
                                                  },
                                                  onButtonTap: () {
                                                    if (controller.selectedReason.value != "Select Reason") {
                                                      AppDialogs().showBlockUserConfirmationDialog(onPressed: () async {
                                                        Get.back();
                                                        await controller
                                                            .blockUser(
                                                                blockedUserId: controller.filteredPosts[index].userId.id,
                                                                reason: controller.selectedReason.value)
                                                            .then((value) {
                                                          Navigator.pop(context);
                                                        });
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
                                    ratingTapped: () {
                                      controller.isRatingTapped.value = !controller.isRatingTapped.value;
                                    },
                                    onRatingChanged: (rating) {
                                      controller.updateRating(postId: post.id, rating: rating);
                                    },
                                    userRating: controller.userRating.value,
                                    shareTapped: () async {
                                      printLogs('-----on share');
                                      controller.isRatingTapped.value = false;
                                      showShareOptions(
                                        context,
                                        post: post,
                                      );
                                    },
                                    ratingDisappear: (value) {
                                      controller.isRatingTapped.value = value;
                                    },
                                    // isFollowed: false,
                                    // isFollowed: SessionService().isFollowing(controller.posts[index].userId.id),
                                    isFollowed: SessionService()
                                            .userDetail
                                            ?.following
                                            .contains(controller.filteredPosts[controller.tappedPostIndex.value].userId.id) ??
                                        false,
                                    // onFollowButtonTap: () {
                                    //   printLogs('========Hi its tapped');
                                    // },
                                    onFollowButtonTap: () async {
                                      await controller.updateFollowStatus(
                                        followedUserId: controller.posts[index].userId.id,
                                      );
                                    },
                                    onProfileTap: () {
                                      Get.toNamed(kFollowersProfileScreen, arguments: controller.posts[index].userId.id);
                                    },
                                    followedUserId: controller.posts[index].userId.id,
                                    discoverController: controller,
                                    onViewTapped: () {
                                      controller.onTapPost(controller.tappedPostIndex.value);
                                      controller.getUsersFromIds(controller.filteredPosts[index].views!.map((e) => e.id).toList());
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
                                                                        ' ${controller.filteredPosts[index].views?.length} plays',
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
                                                                      ' ${controller.filteredPosts[index].likesCount} likes',
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
                                                                              onProfileTap: () {
                                                                                Get.back();
                                                                                controller.onOtherUserView(user.id);
                                                                              },
                                                                              name: user.name,
                                                                              imageUrl: user.image ?? '',
                                                                              isFollowed: isFollowed.obs,
                                                                              isFollowLoading: controller.isFollowStatusLoading,
                                                                              btnText: isFollowed ? 'Following' : 'Follow',
                                                                              onTap: () {
                                                                                controller.updateFollowStatus(
                                                                                  followedUserId: user.id,
                                                                                );
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
                                                                                  ),
                                                                                );
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
                                      });
                                    },
                                  ),
                                ),
                              ),
                  );
                },
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

// Swiper(
//               itemCount: controller.videoControllers.length,
//               scrollDirection: Axis.horizontal,
//               transformer: ScaleAndFadeTransformer(),
//               layout: SwiperLayout.DEFAULT,
//               loop: false,
//               controller: controller.swiperController,
//               onIndexChanged: (index) async {
//                 controller.tappedPostIndex.value = index;
//                 controller.isRatingTapped.value = false;
//                 if (index != 0) {
//                   await controller.videoControllers[index - 1].pause();
//                 }
//                 if (index == controller.filteredPosts.length - 1) {
//                   await controller.videoControllers[index].pause();
//                   CustomSnackbar.showSnackbar('No more posts to show');
//                 } else {
//                   controller.onIndexChanged(index);
//                   // controller.updateViewCount
//                 }
//               },
//               itemBuilder: (BuildContext context, int index) {
//                 var post = controller
//                     .filteredPosts[controller.tappedPostIndex.value];
//                 return Obx(
//                   () => controller.isVideoLoading.value
//                       ? const Center(child: CircularProgressIndicator())
//                       : GestureDetector(
//                           onTap: () {
//                             controller.isRatingTapped.value = false;
//                           },
//                           child: Obx(
//                             () => VideoPlayerBottomSheet(
//                               onDownloadClick: () {
//                                 controller.downloadVideo(post.video);
//                               },
//                               isDowloadButtonShow: false,
//                               uploadedUserPic: post.userId.image ?? '',
//                               uploadedUserName: post.userId.name ?? '',
//                               isBottomSheet: false,
//                               videoController:
//                                   controller.videoControllers[index],
//                               progress: 0,
//                               // controller
//                               //         .videoController!.value.position.inMilliseconds /
//                               //     controller
//                               //         .videoController!.value.duration.inMilliseconds,
//                               isRatingTapped: controller.isRatingTapped.value,
//                               ratings: post.averageRating.toDouble(),
//                               post: controller.filteredPosts[
//                                   controller.tappedPostIndex.value],
//                               likeDislikeTapped: () {
//                                 printLogs('========on like tapped');
//                                 controller.isRatingTapped.value = false;
//                                 controller.updateLikeDislike(
//                                     postId: controller
//                                         .filteredPosts[
//                                             controller.tappedPostIndex.value]
//                                         .id);
//                               },
//                               reportTapped: () {
//                                 showDialog(
//                                   context: context,
//                                   builder: (context) => Obx(
//                                     () => ReasonBottomSheet(
//                                       titleText: "Report Clip",
//                                       reasons:
//                                           controller.reportingReasons.value,
//                                       onCloseButton: () {
//                                         controller.selectedReason.value =
//                                             'Select Reason';
//                                         Get.back();
//                                       },
//                                       onButtonTap: () {
//                                         if (controller.selectedReason.value !=
//                                             "Select Reason") {
//                                           controller.reportClip(
//                                               postId: controller
//                                                   .filteredPosts[controller
//                                                       .tappedPostIndex.value]
//                                                   .id,
//                                               reason: controller
//                                                   .selectedReason.value);
//                                         } else {
//                                           CustomSnackbar.showSnackbar(
//                                               "Select reason");
//                                         }
//                                       },
//                                       onChange:
//                                           controller.onReasonDropDownChange,
//                                       selectedReason:
//                                           controller.selectedReason.value,
//                                       btnText: 'Report',
//                                     ),
//                                   ),
//                                 );
//                               },
//                               blockUserTapped: () {
//                                 showDialog(
//                                     context: context,
//                                     builder: (context) => Obx(
//                                           () => ReasonBottomSheet(
//                                             titleText: 'Block User',
//                                             reasons:
//                                                 controller.blockingReasons,
//                                             onCloseButton: () {
//                                               controller.selectedReason
//                                                   .value = 'Select Reason';
//                                               Get.back();
//                                             },
//                                             onButtonTap: () {
//                                               if (controller
//                                                       .selectedReason.value !=
//                                                   "Select Reason") {
//                                                 AppDialogs()
//                                                     .showBlockUserConfirmationDialog(
//                                                         onPressed: () async {
//                                                   Get.back();
//                                                   await controller
//                                                       .blockUser(
//                                                           blockedUserId:
//                                                               controller
//                                                                   .posts[
//                                                                       index]
//                                                                   .userId
//                                                                   .id,
//                                                           reason: controller
//                                                               .selectedReason
//                                                               .value)
//                                                       .then((value) {
//                                                     Navigator.pop(context);
//                                                   });
//                                                 });
//                                               } else {
//                                                 CustomSnackbar.showSnackbar(
//                                                     "Select reason");
//                                               }
//                                             },
//                                             onChange: controller
//                                                 .onReasonDropDownChange,
//                                             selectedReason: controller
//                                                 .selectedReason.value,
//                                             btnText: 'Block',
//                                           ),
//                                         ));
//                               },
//                               ratingTapped: () {
//                                 controller.isRatingTapped.value =
//                                     !controller.isRatingTapped.value;
//                                 log('=======ratingTapped ${controller.isRatingTapped.value}');
//                               },
//                               onRatingChanged: (rating) {
//                                 controller.updateRating(
//                                     postId: post.id, rating: rating);
//                               },
//                               userRating: controller.userRating.value,
//                               shareTapped: () async {
//                                 printLogs('-----on share');
//                                 controller.isRatingTapped.value = false;
//                                 showShareOptions(
//                                   context,
//                                   post: post,
//                                 );
//                               },
//                               ratingDisappear: (value) {
//                                 controller.isRatingTapped.value = value;
//                               },
//                               isFollowed: SessionService().isFollowing(
//                                   controller.posts[index].userId.id),
//                               onFollowButtonTap: () {},
//                               onViewTapped: () {
//                                 controller.onTapPost(
//                                     controller.tappedPostIndex.value);
//                                 controller.getUsersFromIds(controller
//                                     .posts[index].views!
//                                     .map((e) => e.id)
//                                     .toList());
//                                 showModalBottomSheet(
//                                     context: context,
//                                     backgroundColor: kBackgroundColor,
//                                     isScrollControlled: true,
//                                     shape: const RoundedRectangleBorder(
//                                       borderRadius: BorderRadius.only(
//                                         topLeft: Radius.circular(30),
//                                         topRight: Radius.circular(30),
//                                       ),
//                                     ),
//                                     builder: (context) {
//                                       return FractionallySizedBox(
//                                         heightFactor: 0.7,
//                                         child: SizedBox(
//                                           child: Padding(
//                                             padding: EdgeInsets.symmetric(
//                                                 horizontal: 15.w,
//                                                 vertical: 15.h),
//                                             child: Obx(
//                                               () => controller
//                                                       .isViewedUsersLoading
//                                                       .value
//                                                   ? const Center(
//                                                       child:
//                                                           CircularProgressIndicator())
//                                                   : Column(
//                                                       children: [
//                                                         Center(
//                                                           child: Text(
//                                                             'Plays and Reaction',
//                                                             style: AppStyles
//                                                                     .labelTextStyle()
//                                                                 .copyWith(
//                                                               color: Colors
//                                                                   .white,
//                                                               fontSize: 18.sp,
//                                                               fontFamily:
//                                                                   'League Spartan',
//                                                               fontWeight:
//                                                                   FontWeight
//                                                                       .w600,
//                                                             ),
//                                                           ),
//                                                         ),
//                                                         SizedBox(
//                                                             height: 20.h),
//                                                         CustomTextField(
//                                                           isPassword: false,
//                                                           hint: "Search",
//                                                           controller: controller
//                                                               .searchController,
//                                                           icon: Icons.search,
//                                                           onChanged: (value) {
//                                                             controller
//                                                                 .filterBottomSheetSearch(
//                                                                     value);
//                                                           },
//                                                         ),
//                                                         SizedBox(
//                                                             height: 20.h),
//                                                         Center(
//                                                           child: SizedBox(
//                                                             width: Get.width,
//                                                             child: Row(
//                                                               mainAxisAlignment:
//                                                                   MainAxisAlignment
//                                                                       .center,
//                                                               crossAxisAlignment:
//                                                                   CrossAxisAlignment
//                                                                       .center,
//                                                               children: [
//                                                                 Image.asset(
//                                                                   kVideoImage,
//                                                                   color:
//                                                                       kWhiteColor,
//                                                                   scale: 5.0,
//                                                                 ),
//                                                                 SizedBox(
//                                                                     width:
//                                                                         10.w),
//                                                                 Text(
//                                                                   ' ${controller.posts[index].views?.length} plays',
//                                                                   style: AppStyles.labelTextStyle().copyWith(
//                                                                       fontSize: 14
//                                                                           .sp,
//                                                                       fontWeight:
//                                                                           FontWeight.w400),
//                                                                 ),
//                                                               ],
//                                                             ),
//                                                           ),
//                                                         ),
//                                                         SizedBox(
//                                                             height: 20.h),
//                                                         SizedBox(
//                                                           width: Get.width,
//                                                           child: Row(
//                                                             mainAxisAlignment:
//                                                                 MainAxisAlignment
//                                                                     .spaceBetween,
//                                                             crossAxisAlignment:
//                                                                 CrossAxisAlignment
//                                                                     .center,
//                                                             children: [
//                                                               Text(
//                                                                 'Liked by',
//                                                                 style: AppStyles
//                                                                         .labelTextStyle()
//                                                                     .copyWith(
//                                                                   fontSize:
//                                                                       14.sp,
//                                                                   fontWeight:
//                                                                       FontWeight
//                                                                           .w400,
//                                                                 ),
//                                                               ),
//                                                               Text(
//                                                                 ' ${controller.posts[index].likesCount} likes',
//                                                                 style: AppStyles
//                                                                         .labelTextStyle()
//                                                                     .copyWith(
//                                                                   color:
//                                                                       kGreyRecentSearch,
//                                                                   fontSize:
//                                                                       14.sp,
//                                                                   fontWeight:
//                                                                       FontWeight
//                                                                           .w400,
//                                                                 ),
//                                                               ),
//                                                             ],
//                                                           ),
//                                                         ),
//                                                         SizedBox(
//                                                             height: 20.h),
//                                                         Expanded(
//                                                           child: Obx(() => controller
//                                                                   .searchBottomSheetList
//                                                                   .isEmpty
//                                                               ? Center(
//                                                                   child: Text(
//                                                                       'No Viewer Found',
//                                                                       style: AppStyles.labelTextStyle()
//                                                                           .copyWith(
//                                                                         color:
//                                                                             kGreyRecentSearch,
//                                                                         fontSize:
//                                                                             14.sp,
//                                                                         fontWeight:
//                                                                             FontWeight.w400,
//                                                                       )))
//                                                               : ListView
//                                                                   .builder(
//                                                                   itemCount: controller
//                                                                       .searchBottomSheetList
//                                                                       .length,
//                                                                   itemBuilder:
//                                                                       (context,
//                                                                           index) {
//                                                                     final user =
//                                                                         controller
//                                                                             .searchBottomSheetList[index];
//                                                                     bool isFollowed = controller
//                                                                         .searchBottomSheetList[
//                                                                             index]
//                                                                         .followers
//                                                                         .contains(SessionService()
//                                                                             .user
//                                                                             ?.id);

//                                                                     return Padding(
//                                                                       padding: const EdgeInsets
//                                                                           .all(
//                                                                           8.0),
//                                                                       child:
//                                                                           UserFollowRow(
//                                                                         onProfileTap:
//                                                                             () {
//                                                                           Get.back();
//                                                                           controller.onOtherUserView(user.id);
//                                                                         },
//                                                                         name:
//                                                                             user.name,
//                                                                         imageUrl:
//                                                                             user.image ?? '',
//                                                                         isFollowed:
//                                                                             isFollowed,
//                                                                         isFollowLoading:
//                                                                             false,
//                                                                         btnText: isFollowed
//                                                                             ? 'Following'
//                                                                             : 'Follow',
//                                                                         onTap:
//                                                                             () {
//                                                                           log('Follow Tapped');
//                                                                           controller.updateFollowStatus(
//                                                                               followedUserId: user.id,
//                                                                               index: index);
//                                                                         },
//                                                                         onBlockTap:
//                                                                             () {
//                                                                           printLogs('on reasons lst === ${controller.blockingReasons}');
//                                                                           controller.isRatingTapped.value =
//                                                                               false;
//                                                                           showDialog(
//                                                                             context: context,
//                                                                             builder: (context) => Obx(
//                                                                               () => ReasonBottomSheet(
//                                                                                 titleText: 'Block User',
//                                                                                 reasons: controller.blockingReasons.value,
//                                                                                 onCloseButton: () {
//                                                                                   controller.selectedReason.value = 'Select Reason';
//                                                                                   Get.back();
//                                                                                 },
//                                                                                 onButtonTap: () {
//                                                                                   if (controller.selectedReason.value != "Select Reason") {
//                                                                                     AppDialogs().showBlockUserConfirmationDialog(onPressed: () async {
//                                                                                       Get.back();
//                                                                                       await controller.blockUser(blockedUserId: user.id, reason: controller.selectedReason.value);
//                                                                                     });
//                                                                                   } else {
//                                                                                     CustomSnackbar.showSnackbar("Select reason");
//                                                                                   }
//                                                                                 },
//                                                                                 onChange: controller.onReasonDropDownChange,
//                                                                                 selectedReason: controller.selectedReason.value,
//                                                                                 btnText: 'Block',
//                                                                               ),
//                                                                             ),
//                                                                           );
//                                                                         },
//                                                                       ),
//                                                                     );
//                                                                   },
//                                                                 )),
//                                                         )
//                                                       ],
//                                                     ),
//                                             ),
//                                           ),
//                                         ),
//                                       );
//                                     }).then((ab) {
//                                   controller.searchController.clear();
//                                 });
//                               },
//                             ),
//                           ),
//                         ),
//                 );
//               },
//             ),
