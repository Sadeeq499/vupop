import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_swipe_button/flutter_swipe_button.dart';
import 'package:get/get.dart';
import 'package:shimmer/shimmer.dart';
import 'package:socials_app/services/session_services.dart';
import 'package:socials_app/utils/app_colors.dart';
import 'package:socials_app/utils/app_images.dart';
import 'package:socials_app/utils/app_strings.dart';
import 'package:socials_app/views/custom_widgets/CustomImage.dart';
import 'package:socials_app/views/custom_widgets/custom_scaffold.dart';
import 'package:socials_app/views/custom_widgets/custom_shimmer_image_widget.dart';
import 'package:socials_app/views/custom_widgets/drawer.dart';
import 'package:socials_app/views/screens/bottom/controller/bottom_bar_controller.dart';
import 'package:socials_app/views/screens/profile/components/followers_following_bottomsheet.dart';

import '../../../../utils/app_styles.dart';
import '../../../../utils/common_code.dart';
import '../controller/profile_controller.dart';

class ProfileScreen extends GetView<ProfileScreenController> {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => CustomScaffold(
        className: 'Profile Screen',
        screenName: "Profile ",
        scaffoldKey: controller.scaffoldKeyProfile,
        isFullBody: false,
        backIconColor: kPrimaryColor,
        // isBackIcon: true,
        leadingWidget: Row(
          children: [
            IconButton(
              icon: const Icon(Icons.arrow_back_ios),
              color: kPrimaryColor,
              onPressed: () {
                ///TODO back to home screen
                Get.find<BottomBarController>().selectedIndex.value = 0;
              },
            ),
            // SizedBox(width: 20.w),
            // Image.asset(kAppLogo, width: 50.w, height: 20.h),
          ],
        ),
        onWillPop: () {
          Get.find<BottomBarController>().selectedIndex.value = 0;
        },
        actions: [
          GestureDetector(
            onTap: () {
              Get.toNamed(kNotificationRoute);
            },
            child: Image.asset(
              kNotificationIcon,
              width: 50.w,
              height: 20.h,
            ),
          ),
          Obx(() => controller.isOtherUser.value
              ? const SizedBox()
              : Padding(
                  padding: const EdgeInsets.only(right: 20),
                  child: GestureDetector(
                    onTap: () {
                      controller.scaffoldKeyProfile.currentState?.openDrawer();
                    },
                    child: const Icon(Icons.menu, color: kPrimaryColor),
                  ),
                )),
        ],
        drawer: ProfileDrawer(),
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
                                      return FollowersFollowingBottomSheet(controller: controller, isFollowersSheet: false);
                                    }).then((ab) {
                                  controller.searchController.clear();
                                });
                              },
                              child: Text(
                                "Following \n ${controller.userData.value?.following.length.toString() ?? SessionService().userDetail?.following.length.toString() ?? '0'}",
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
                              url: controller.userData.value?.image ?? "",
                              isCircle: true,
                              width: 100.w,
                              height: 100.h,
                            ),
                            const SizedBox(height: 10),
                            Text(
                              controller.userData.value?.name ?? SessionService().user?.name ?? 'N/A',
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
                                      return FollowersFollowingBottomSheet(controller: controller, isFollowersSheet: true);
                                    }).then((ab) {
                                  controller.searchController.clear();
                                });
                              },
                              child: Text(
                                "Followers \n ${controller.userData.value?.followers.length.toString() ?? SessionService().userDetail?.followers.length.toString() ?? '0'}",
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
                                "Total Videos \n ${controller.userPosts.length.toString()}",
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
                  )

                  // Stack(
                  //   children: [
                  //     Positioned(
                  //       top: 60,
                  //       child: Container(
                  //         width: 390.w,
                  //         height: 250.h,
                  //         clipBehavior: Clip.antiAlias,
                  //         decoration: BoxDecoration(
                  //           color: kPrimaryColor,
                  //           borderRadius: BorderRadius.circular(8),
                  //         ),
                  //         child: Column(
                  //           children: [
                  //             const SizedBox(
                  //               height: 100,
                  //             ),
                  //             Obx(
                  //               () => Text(
                  //                 controller.userData.value?.name ?? 'n/a',
                  //                 textAlign: TextAlign.center,
                  //                 style: AppStyles.labelTextStyle().copyWith(
                  //                   color: kBlackColor,
                  //                   fontSize: 24.sp,
                  //                   fontFamily: 'Norwester',
                  //                   height: 0.03,
                  //                 ),
                  //               ),
                  //             ),
                  //             SizedBox(
                  //               height: 20.h,
                  //             ),
                  //             //TODO commited on client request
                  //             // Row(
                  //             //   mainAxisAlignment: MainAxisAlignment.center,
                  //             //   children: [
                  //             //     const Icon(Icons.location_on),
                  //             //     SizedBox(
                  //             //       width: 300.w,
                  //             //       child: Text(
                  //             //         SessionService().userAddress ?? 'n/a',
                  //             //         maxLines: 2,
                  //             //         textAlign: TextAlign.center,
                  //             //         style: AppStyles.labelTextStyle()
                  //             //             .copyWith(
                  //             //           color: kBlackColor,
                  //             //           height:
                  //             //               1.5, // Adjusted for better readability
                  //             //         ),
                  //             //       ),
                  //             //     ),
                  //             //     // Text(
                  //             //     //   SessionService().userAddress ?? 'n/a',
                  //             //     //   // 'Albany, Newyork',
                  //             //     //   maxLines: 2,
                  //             //     //   textAlign: TextAlign.center,
                  //             //     //   style:
                  //             //     //       AppStyles.labelTextStyle().copyWith(
                  //             //     //     color: kBlackColor,
                  //             //     //     height: 0.10,
                  //             //     //   ),
                  //             //     // ),
                  //             //   ],
                  //             // ),
                  //             SizedBox(
                  //               height: 30.h,
                  //             ),
                  //             SizedBox(
                  //               width: 300.w,
                  //               child: Row(
                  //                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  //                 children: [
                  //                   SizedBox(
                  //                     width: 60.w,
                  //                     child: Column(
                  //                       children: [
                  //                         Text(
                  //                           'Posts',
                  //                           textAlign: TextAlign.center,
                  //                           style: AppStyles.labelTextStyle().copyWith(
                  //                             color: kBlackColor,
                  //                             fontSize: 16.sp,
                  //                             height: 0.08,
                  //                           ),
                  //                         ),
                  //                         SizedBox(
                  //                           height: 20.h,
                  //                         ),
                  //                         Text(
                  //                           controller.userPosts.length.toString(),
                  //                           textAlign: TextAlign.center,
                  //                           style: AppStyles.labelTextStyle().copyWith(
                  //                             color: Colors.black,
                  //                             fontSize: 24.sp,
                  //                             fontFamily: 'Norwester',
                  //                             height: 0.03,
                  //                           ),
                  //                         )
                  //                       ],
                  //                     ),
                  //                   ),
                  //                   SizedBox(
                  //                     width: 80.w,
                  //                     child: Column(
                  //                       children: [
                  //                         Text(
                  //                           'Followers',
                  //                           textAlign: TextAlign.center,
                  //                           style: AppStyles.labelTextStyle().copyWith(
                  //                             color: kBlackColor,
                  //                             fontSize: 16.sp,
                  //                             height: 0.08,
                  //                           ),
                  //                         ),
                  //                         SizedBox(
                  //                           height: 20.h,
                  //                         ),
                  //                         Text(
                  //                           controller.userData.value?.followers.length.toString() ?? '0',
                  //                           textAlign: TextAlign.center,
                  //                           style: AppStyles.labelTextStyle().copyWith(
                  //                             color: kBlackColor,
                  //                             fontSize: 24.sp,
                  //                             fontFamily: 'Norwester',
                  //                             height: 0.03,
                  //                           ),
                  //                         )
                  //                       ],
                  //                     ),
                  //                   ),
                  //                   SizedBox(
                  //                     width: 90.w,
                  //                     child: Column(
                  //                       children: [
                  //                         Text(
                  //                           'Following',
                  //                           textAlign: TextAlign.center,
                  //                           style: AppStyles.labelTextStyle().copyWith(
                  //                             color: kBlackColor,
                  //                             fontSize: 16.sp,
                  //                             height: 0.08,
                  //                           ),
                  //                         ),
                  //                         SizedBox(
                  //                           height: 20.h,
                  //                         ),
                  //                         Text(
                  //                           controller.userData.value?.following.length.toString() ?? '0',
                  //                           textAlign: TextAlign.center,
                  //                           style: AppStyles.labelTextStyle().copyWith(
                  //                             color: kBlackColor,
                  //                             fontSize: 24.sp,
                  //                             fontFamily: 'Norwester',
                  //                             height: 0.03,
                  //                           ),
                  //                         )
                  //                       ],
                  //                     ),
                  //                   )
                  //                 ],
                  //               ),
                  //             )
                  //           ],
                  //         ),
                  //       ),
                  //     ),
                  //     Positioned(
                  //       top: 0,
                  //       left: 125,
                  //       child: Obx(
                  //         () => CachedImage(
                  //           isCircle: true,
                  //           width: 120.w,
                  //           height: 120.h,
                  //           url: controller.userData.value?.image ?? "",
                  //           // borderRadius: BorderRadius.circular(9.60.r),
                  //         ),
                  //       ),
                  //     ),
                  //   ],
                  // ),

                  ),
              SizedBox(height: 20.h),
              Text(
                'About you',
                style: AppStyles.labelTextStyle().copyWith(
                  color: kPrimaryColor,
                  fontSize: 16,
                  fontFamily: 'Norwester',
                  // height: 0.08,
                ),
              ),
              Text(
                  controller.userData.value != null && controller.userData.value?.about != null && controller.userData.value!.about!.isNotEmpty
                      ? controller.userData.value!.about!
                      : SessionService().userDetail?.about ?? 'N/A',
                  style: AppStyles.labelTextStyle().copyWith(color: kWhiteColor, fontSize: 16.sp)),
              /* SizedBox(height: 20.h),
                    Center(
                      child: Text("My Passions", style: AppStyles.labelTextStyle().copyWith(color: kWhiteColor, fontSize: 20.sp)),
                    ),
                    SizedBox(height: 10.h),
                    SizedBox(
                      width: Get.width,
                      child: Obx(
                        () => Wrap(
                          spacing: 2.w,
                          alignment: WrapAlignment.center,
                          runAlignment: WrapAlignment.center,
                          children: controller.userPassions.isEmpty
                              ? [
                                  GestureDetector(
                                    onTap: () {
                                      showModalBottomSheet(
                                        context: context,
                                        isScrollControlled: true,
                                        builder: (BuildContext context) {
                                          return FractionallySizedBox(
                                            heightFactor: controller.passions.isEmpty
                                                ? 0.3
                                                : controller.passions.length < 4
                                                    ? 0.5
                                                    : 0.7,
                                            child: Container(
                                              width: Get.width,
                                              height: Get.height,
                                              padding: EdgeInsets.symmetric(vertical: 20.h, horizontal: 20.w),
                                              decoration: const BoxDecoration(
                                                color: kGreyContainerColor,
                                                borderRadius: BorderRadius.only(
                                                  topLeft: Radius.circular(20),
                                                  topRight: Radius.circular(20),
                                                ),
                                              ),
                                              child: SingleChildScrollView(
                                                child: Column(
                                                  children: [
                                                    Text(
                                                      'Select your passion',
                                                      style: AppStyles.labelTextStyle().copyWith(
                                                        color: kWhiteColor,
                                                        fontSize: 20.sp,
                                                      ),
                                                    ),
                                                    SizedBox(height: 20.h),
                                                    Obx(
                                                      () => Wrap(
                                                        spacing: 2.w,
                                                        alignment: WrapAlignment.center,
                                                        runAlignment: WrapAlignment.center,
                                                        children: List.generate(
                                                          controller.passions.length,
                                                          (index) {
                                                            final passion = controller.passions[index];
                                                            final isSelected = controller.userPassions.contains(passion);
                                                            return Padding(
                                                              padding: const EdgeInsets.only(bottom: 5),
                                                              child: GestureDetector(
                                                                onTap: () {
                                                                  controller.addPassion(passion);
                                                                },
                                                                child: Chip(
                                                                  label: Row(
                                                                    mainAxisSize: MainAxisSize.min,
                                                                    children: [
                                                                      Text(
                                                                        passion.title ?? '',
                                                                        style: AppStyles.labelTextStyle().copyWith(
                                                                          color: kBlackColor,
                                                                          fontSize: 16.sp,
                                                                        ),
                                                                      ),
                                                                      if (isSelected)
                                                                        Icon(
                                                                          Icons.check,
                                                                          color: kBlackColor,
                                                                          size: 16.sp,
                                                                        ),
                                                                    ],
                                                                  ),
                                                                  backgroundColor: isSelected ? kPrimaryColor.withOpacity(0.7) : kPrimaryColor,
                                                                ),
                                                              ),
                                                            );
                                                          },
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
                                    child: Container(
                                      padding: EdgeInsets.symmetric(vertical: 5.h, horizontal: 10.w),
                                      decoration: BoxDecoration(
                                        color: kPrimaryColor,
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: Text(
                                        'Add Passions',
                                        style: AppStyles.labelTextStyle().copyWith(
                                          color: kBlackColor,
                                          fontSize: 16.sp,
                                        ),
                                      ),
                                    ),
                                  ),
                                ]
                              : List.generate(
                                  controller.userPassions.length,
                                  (index) => Padding(
                                    padding: const EdgeInsets.only(bottom: 5),
                                    child: SizedBox(
                                      height: 40.h,
                                      // width: 100.w,
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
                        ),
                      ),
                    ),*/
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
                          child: Obx(
                            () => controller.userPosts.isEmpty
                                ? Center(
                                    child: Text(
                                      'No posts found',
                                      style: AppStyles.labelTextStyle().copyWith(fontSize: 16.sp, color: kPrimaryColor),
                                    ),
                                  )
                                : PageView.builder(
                                    itemCount: controller.userPosts.length,
                                    controller: controller.pageController,
                                    itemBuilder: (BuildContext context, int index) {
                                      printLogs('inside the builder');
                                      if (controller.userPosts.isEmpty) {
                                        //return const Center(child: CustomImageShimmer());
                                        return Center(
                                          child: Text(
                                            'No posts found',
                                            style: AppStyles.labelTextStyle().copyWith(fontSize: 16.sp, color: kPrimaryColor),
                                          ),
                                        );
                                      }

                                      return ListenableBuilder(
                                        listenable: controller.pageController,
                                        builder: (context, child) {
                                          double scale = 1.0;
                                          if (controller.pageController.position.hasContentDimensions) {
                                            scale = 1 - (controller.pageController.page! - index).abs() * 0.3;
                                          }

                                          bool isPortrait = controller.userPosts[index].isPortrait ?? false;

                                          return Center(
                                            child: GestureDetector(
                                              onTap: () async {
                                                controller.isVideoLoading.value = true;
                                                controller.tappedPostIndex.value = index;
                                                controller.disposeVideoPlayer();
                                                if (controller.userPosts.length < 3) {
                                                  controller.initializeAllControllers(index, controller.userPosts.length).then((a) {
                                                    controller.videoControllers.first.play();
                                                  });
                                                } else {
                                                  controller.initializeAllControllers(index, 3).then((val) {
                                                    controller.videoControllers.first.play();
                                                  });
                                                }
                                                Get.toNamed(kProfileSwipeViewPosts);
                                              },
                                              // Modified onTap for navigating to swipe view
                                              /*onTap: () async {
                                                controller.isVideoLoading.value = true;
                                                controller.tappedPostIndex.value = index;
                                                await controller.disposeVideoPlayer();

                                                // Determine how many videos to load based on available posts
                                                int videosToLoad = min(3, controller.userPosts.length - index);

                                                // Play the first video
                                                if (controller.videoControllers.isNotEmpty) {
                                                  controller.videoControllers.first.play();
                                                } else {
                                                  // Initialize controllers
                                                  await controller.initializeAllControllers(index, videosToLoad);
                                                }

                                                Get.toNamed(kProfileSwipeViewPosts);
                                              },*/
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
                                                            controller.userPosts[index].thumbnail ?? '',
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
                                                        visible: controller.userPosts[index].views?.isNotEmpty ?? false,
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
                                                                "${controller.userPosts[index].views?.length}",
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
              ),
              SizedBox(height: 10.h),
            ],
          ),
        ),
        bottomNavigationBar: Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.h),
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
              controller.isSwiping.value = true;
            },
            onSwipeEnd: () {
              controller.isSwiping.value = false;
              Get.toNamed(kCreateHighlightedPost);
            },
            child: SizedBox(
              width: Get.width,
              child: Center(
                child: Text("My Highlight real \n Swipe --->",
                    textAlign: TextAlign.center, style: AppStyles.labelTextStyle().copyWith(color: kPrimaryColor, fontSize: 18.sp)),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
