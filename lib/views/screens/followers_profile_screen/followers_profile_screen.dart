import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_swipe_button/flutter_swipe_button.dart';
import 'package:get/get.dart';
import 'package:shimmer/shimmer.dart';
import 'package:socials_app/services/session_services.dart';
import 'package:socials_app/utils/app_colors.dart';
import 'package:socials_app/utils/app_images.dart';
import 'package:socials_app/utils/app_strings.dart';
import 'package:socials_app/utils/app_styles.dart';
import 'package:socials_app/views/custom_widgets/customImage.dart';
import 'package:socials_app/views/custom_widgets/custom_scaffold.dart';
import 'package:socials_app/views/custom_widgets/custom_shimmer_image_widget.dart';
import 'package:socials_app/views/screens/bottom/controller/bottom_bar_controller.dart';

import '../../../utils/common_code.dart';
import 'controller/followers_profile_controller.dart';

class FollowersProfileScreen extends GetView<FollowersProfileController> {
  const FollowersProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => controller.isLoading.value
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : CustomScaffold(
              className: 'Profile Screen',
              screenName: "Follower Profile ",
              scaffoldKey: controller.scaffoldKeyProfile,
              isFullBody: false,
              backIconColor: kPrimaryColor,
              isBackIcon: true,
              // leadingWidget: Row(
              //   children: [
              //     IconButton(
              //       icon: const Icon(Icons.arrow_back_ios),
              //       color: kPrimaryColor,
              //       onPressed: () {
              //         ///TODO back to home screen
              //         Get.find<BottomBarController>().selectedIndex.value = 0;
              //       },
              //     ),
              //     // SizedBox(width: 20.w),
              //     // Image.asset(kAppLogo, width: 50.w, height: 20.h),
              //   ],
              // ),
              onWillPop: () {
                Get.find<BottomBarController>().selectedIndex.value = 0;
              },

              body: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                        width: Get.width,
                        height: 200.h,
                        color: kGreyContainerColor,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            SizedBox(
                              width: 100.w,
                              height: 250.h,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  GestureDetector(
                                    onTap: () {
                                      // showModalBottomSheet(
                                      //     context: context,
                                      //     backgroundColor: kBackgroundColor,
                                      //     isScrollControlled: true,
                                      //     shape: const RoundedRectangleBorder(
                                      //       borderRadius: BorderRadius.only(
                                      //         topLeft: Radius.circular(30),
                                      //         topRight: Radius.circular(30),
                                      //       ),
                                      //     ),
                                      //     builder: (context) {
                                      //       return FollowersFollowingBottomSheet(
                                      //           controller: controller,
                                      //           isFollowersSheet: false);
                                      //     }).then((ab) {
                                      //   controller.searchController.clear();
                                      // });
                                    },
                                    child: Text(
                                      "Following \n ${controller.followerDetail.value?.following.length.toString() ?? '0'}",
                                      style: AppStyles.labelTextStyle().copyWith(
                                        color: kPrimaryColor,
                                        fontSize: 16.sp,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  GestureDetector(
                                    onTap: () {
                                      // Get.toNamed(kFollowingScreen);
                                    },
                                    child: Text(
                                      "Avg Video Rating \n 0",
                                      style: AppStyles.labelTextStyle().copyWith(
                                        color: kPrimaryColor,
                                        fontSize: 16.sp,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              width: 160.w,
                              // height: 160.h,
                              clipBehavior: Clip.antiAlias,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: kPrimaryColor,
                                  width: 1,
                                ),
                              ),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const SizedBox(height: 10),
                                  CachedImage(
                                    url: controller.followerDetail.value?.image ?? "",
                                    isCircle: true,
                                    width: 100.w,
                                    height: 100.h,
                                  ),
                                  const SizedBox(height: 10),
                                  Text(
                                    controller.followerDetail.value?.name ?? 'n/a',
                                    textAlign: TextAlign.center,
                                    style: AppStyles.labelTextStyle().copyWith(
                                      color: kWhiteColor,
                                      fontSize: 22.sp,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 5),
                            SizedBox(
                              width: 100.w,
                              height: 250.h,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  GestureDetector(
                                    onTap: () {
                                      // showModalBottomSheet(
                                      //     context: context,
                                      //     backgroundColor: kBackgroundColor,
                                      //     isScrollControlled: true,
                                      //     shape: const RoundedRectangleBorder(
                                      //       borderRadius: BorderRadius.only(
                                      //         topLeft: Radius.circular(30),
                                      //         topRight: Radius.circular(30),
                                      //       ),
                                      //     ),
                                      //     builder: (context) {
                                      //       return FollowersFollowingBottomSheet(
                                      //           controller: controller,
                                      //           isFollowersSheet: true);
                                      //     }).then((ab) {
                                      //   controller.searchController.clear();
                                      // });
                                    },
                                    child: Text(
                                      "Followers \n ${controller.followerDetail.value?.followers.length.toString() ?? '0'}",
                                      style: AppStyles.labelTextStyle().copyWith(
                                        color: kPrimaryColor,
                                        fontSize: 16.sp,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  GestureDetector(
                                    onTap: () {
                                      // Get.toNamed(kFollowingScreen);
                                    },
                                    child: Text(
                                      "Total Videos \n ${controller.followerPosts.length.toString()}",
                                      style: AppStyles.labelTextStyle().copyWith(
                                        color: kPrimaryColor,
                                        fontSize: 16.sp,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        )),
                    SizedBox(height: 20.h),

                    /// unfollow button
                    Obx(() {
                      final isFollowing = controller.followerDetail.value?.followers.contains(SessionService().user?.id) ?? false;
                      return GestureDetector(
                        onTap: () {
                          controller.updateFollowStatus(followedUserId: controller.followerDetail.value?.id ?? '');
                        },
                        child: Container(
                          width: Get.width * 0.9,
                          height: 50.h,
                          decoration: BoxDecoration(
                            color: kPrimaryColor,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Center(
                            child: Obx(
                              () => Text(
                                controller.followerDetail.value != null &&
                                        controller.followerDetail.value!.followers.contains(SessionService().user?.id)
                                    ? "Unfollow"
                                    : "Follow",
                                style: AppStyles.labelTextStyle().copyWith(
                                  color: kBlackColor,
                                  fontSize: isFollowing ? 18.sp : 20.sp,
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    }),
                    SizedBox(height: 20.h),
                    Center(
                      child: Text("My Passions", style: AppStyles.labelTextStyle().copyWith(color: kWhiteColor, fontSize: 20.sp)),
                    ),
                    SizedBox(height: 10.h),
                    SizedBox(
                      width: Get.width,
                      child: Obx(() => Wrap(
                            spacing: 2.w,
                            alignment: WrapAlignment.center,
                            runAlignment: WrapAlignment.center,
                            children: controller.userPassions.isEmpty
                                ? [
                                    Padding(
                                      padding: EdgeInsets.all(8.0),
                                      child: Text(
                                        "No Passions",
                                        style: TextStyle(
                                          color: kWhiteColor,
                                          fontSize: 16.sp,
                                        ),
                                      ),
                                    )
                                  ]
                                : List.generate(
                                    controller.userPassions.length,
                                    (index) => Padding(
                                      padding: const EdgeInsets.only(bottom: 5),
                                      child: SizedBox(
                                        height: 50.h,
                                        child: Chip(
                                          label: Text(
                                            controller.userPassions[index].title ?? '',
                                            style: AppStyles.labelTextStyle().copyWith(
                                              color: kBlackColor,
                                              fontSize: 16.sp,
                                            ),
                                          ),
                                          backgroundColor: kPrimaryColor,
                                        ),
                                      ),
                                    ),
                                  ),
                          )),
                    ),
                    SizedBox(height: 20.h),
                    SizedBox(
                      height: 280.h,
                      width: Get.width,
                      child: Obx(
                        () => controller.isGettingPosts.value == true
                            ? Shimmer.fromColors(
                                baseColor: kShimmerbaseColor,
                                highlightColor: kShimmerhighlightColor,
                                child: Container(
                                  width: 180.w,
                                  height: 200.h,
                                  color: Colors.grey,
                                ),
                              )
                            : SizedBox(
                                height: 260.h,
                                width: Get.width * 0.9,
                                child: PageView.builder(
                                  itemCount: controller.followerPosts.length,
                                  controller: controller.pageController,
                                  itemBuilder: (BuildContext context, int index) {
                                    if (controller.followerPosts.isEmpty) {
                                      return const Center(child: CustomImageShimmer());
                                    }

                                    return ListenableBuilder(
                                      listenable: controller.pageController,
                                      builder: (context, child) {
                                        double scale = 1.0;
                                        if (controller.pageController.position.hasContentDimensions) {
                                          scale = 1 - (controller.pageController.page! - index).abs() * 0.3;
                                        }

                                        bool isPortrait = controller.followerPosts[index].isPortrait ?? false;
                                        printLogs('isPortrait: $isPortrait');

                                        return Center(
                                          child: GestureDetector(
                                            onTap: () async {
                                              ///TODO
                                              controller.isVideoLoading.value = true;
                                              controller.tappedPostIndex.value = index;
                                              controller.disposeVideoPlayer();
                                              if (controller.followerPosts.length < 3) {
                                                controller.initializeAllControllers(index, controller.followerPosts.length).then((a) {
                                                  controller.videoControllers.first.play();
                                                });
                                              } else {
                                                controller.initializeAllControllers(index, 3).then((val) {
                                                  controller.videoControllers.first.play();
                                                });
                                              }
                                              Get.toNamed(kFollowerSwipeViewPosts);
                                            },
                                            child: Transform.scale(
                                              scale: scale,
                                              child: Stack(
                                                alignment: AlignmentDirectional.center,
                                                children: [
                                                  Padding(
                                                    padding: const EdgeInsets.all(8.0),
                                                    child: Container(
                                                      width: 180.w,
                                                      height: 240.h,
                                                      decoration: BoxDecoration(
                                                        borderRadius: BorderRadius.circular(8),
                                                        border: Border.all(color: kGreyContainerColor, width: 1),
                                                        boxShadow: [
                                                          BoxShadow(
                                                            color: kGreyContainerColor2.withOpacity(0.5),
                                                            spreadRadius: 1,
                                                            blurRadius: 5,
                                                            offset: const Offset(0, 3),
                                                          ),
                                                        ],
                                                      ),
                                                      child: SizedBox(
                                                        height: 50.h,
                                                        child: Image.network(
                                                          controller.followerPosts[index].thumbnail ?? '',
                                                          fit: BoxFit.contain,
                                                          loadingBuilder: (context, child, loadingProgress) {
                                                            if (loadingProgress == null) {
                                                              return SizedBox(
                                                                width: Get.width,
                                                                height: Get.height,
                                                                child: child,
                                                              );
                                                            } else {
                                                              return const CustomImageShimmer();
                                                            }
                                                          },
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                  Positioned(
                                                    bottom: 10,
                                                    left: 10,
                                                    child: Visibility(
                                                      visible: controller.followerPosts[index].views?.isNotEmpty ?? false,
                                                      child: SizedBox(
                                                        child: Row(
                                                          children: [
                                                            Image.asset(
                                                              kVideoImage,
                                                              color: kWhiteColor,
                                                              scale: 3.0,
                                                            ),
                                                            SizedBox(
                                                              width: 10.w,
                                                            ),
                                                            Text(
                                                              "${controller.followerPosts[index].views?.length}",
                                                              style: const TextStyle(color: kWhiteColor),
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
                                        );
                                      },
                                    );
                                  },
                                ),
                              ),
                      ),
                    ),
                    SizedBox(height: 10.h),
                    Obx(() {
                      //TODO
                      if (controller.followerPosts.isNotEmpty) {
                        return Visibility(
                          visible: false, //TODO
                          child: SwipeButton.expand(
                            thumb: const Icon(
                              Icons.double_arrow_rounded,
                              color: kBlackColor,
                            ),
                            activeTrackColor: kPrimaryColor.withOpacity(0.25),
                            inactiveTrackColor: kGreyContainerColor.withOpacity(0.5),
                            activeThumbColor: kPrimaryColor,
                            inactiveThumbColor: kGreyContainerColor.withOpacity(0.5),
                            onSwipeStart: () {
                              // Set isSwiping to true when swipe starts
                              // controller.isSwiping.value = true;
                            },
                            onSwipeEnd: () {
                              // controller.isSwiping.value = false;
                              controller.selectPost(controller.followerPosts[0]);
                              Get.toNamed(kFollowerHighlightedPostView);
                            },
                            child: SizedBox(
                              width: Get.width,
                              child: Center(
                                child: Text("My Highlight real \n Swipe --->",
                                    textAlign: TextAlign.center, style: AppStyles.labelTextStyle().copyWith(color: kPrimaryColor, fontSize: 18.sp)),
                              ),
                            ),
                          ),
                        );
                      } else {
                        return const SizedBox();
                      }
                    }),
                  ],
                ),
              ),
            ),
    );
  }
}
