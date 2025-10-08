import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:get/get.dart';
import 'package:pull_to_refresh_flutter3/pull_to_refresh_flutter3.dart';
import 'package:socials_app/models/post_models.dart';
import 'package:socials_app/utils/app_colors.dart';
import 'package:socials_app/utils/app_images.dart';
import 'package:socials_app/utils/app_strings.dart';
import 'package:socials_app/views/custom_widgets/custom_shimmer_image_widget.dart';
import 'package:socials_app/views/screens/discover/controller/discover_controller.dart';
import 'package:super_tooltip/super_tooltip.dart';

import '../../../utils/app_styles.dart';
import '../../../utils/common_code.dart';
import '../../custom_widgets/custom_scaffold.dart';
import '../bottom/controller/bottom_bar_controller.dart';

class DiscoverScreen extends GetView<DiscoverController> {
  const DiscoverScreen({super.key});

  @override
  Widget build(BuildContext context) {
    Future.microtask(() {
      if (controller.filteredPosts.isEmpty) {
        printLogs("=======Going to init as posts are empty");
        controller.initializeController();
      } else if (controller.isLoading.isTrue) {
        printLogs("=======Going to init as loading is true");
        controller.initializeController();
      }
    });
    return Obx(
      () => controller.isLoading.value
          ? const Center(child: CircularProgressIndicator())
          : CustomScaffold(
              className: runtimeType.toString(),
              screenName: "",
              isBackIcon: false,
              isFullBody: false,
              appBarSize: 30,
              leadingWidth: Get.width,
              showAppBarBackButton: false,
              scaffoldKey: controller.scaffoldKeyDiscover,
              floatingActionButton: Obx(
                () => controller.isScrolled.isTrue
                    ? FloatingActionButton(
                        backgroundColor: kPrimaryColor,
                        onPressed: () {
                          controller.scrollController.animateTo(
                            0,
                            duration: const Duration(milliseconds: 500),
                            curve: Curves.easeInOut,
                          );
                        },
                        child: const Icon(Icons.arrow_upward),
                      )
                    : SizedBox.shrink(),
              ),
              leadingWidget: Center(
                child: Image.asset(
                  kAppLogo,
                  width: 100.w,
                  height: 30.h,
                ),
              ),
              onNotificationListener: (notificationInfo) {
                controller.isRatingTapped.value = false;
                if (notificationInfo.runtimeType == UserScrollNotification) {
                  CommonCode().removeTextFieldFocus();
                }
                return false;
              },
              onWillPop: () {
                Get.find<BottomBarController>().selectedIndex.value = 0;
              },
              padding: EdgeInsets.only(left: 15.w, top: 20.h, right: 15.w),
              gestureDetectorOnTap: CommonCode().removeTextFieldFocus,
              body: Column(
                children: [
                  GestureDetector(
                    onTap: () {
                      Get.toNamed(kDiscoverSearchRoute);
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                            width: Get.width * 0.83,
                            height: 45.h,
                            decoration: BoxDecoration(color: kGreyContainerColor, borderRadius: BorderRadius.circular(4.r)),
                            child: Padding(
                              padding: EdgeInsets.only(left: 15.w),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  const Icon(
                                    Icons.search,
                                    color: kHintGreyColor,
                                    size: 25,
                                  ),
                                  SizedBox(
                                    width: 7.w,
                                  ),
                                  Text(
                                    'Search for friends, broadcasters or hashtags',
                                    style: AppStyles.labelTextStyle().copyWith(fontSize: 14.sp, fontWeight: FontWeight.w500, color: kHintGreyColor),
                                  ),
                                ],
                              ),
                            )),

                        GestureDetector(
                          onTap: () async {
                            await controller.tooltipControllerFilters.showTooltip();
                          },
                          child: SuperTooltip(
                            arrowLength: 0.h,
                            arrowTipDistance: 20.h,
                            borderColor: kPrimaryColor2,
                            backgroundColor: kGreyContainerColor,
                            showBarrier: true,
                            controller: controller.tooltipControllerFilters,
                            content: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                GestureDetector(
                                    onTap: () {
                                      controller.tooltipControllerFilters.hideTooltip();
                                      Get.toNamed(kFilterRoute);
                                    },
                                    child: Padding(
                                      padding: EdgeInsets.symmetric(horizontal: 15.w, vertical: 10.h),
                                      child: Text(
                                        'Filter by Hashtag',
                                        style:
                                            AppStyles.labelTextStyle().copyWith(fontSize: 14.sp, fontWeight: FontWeight.w700, color: kPrimaryColor),
                                      ),
                                    )),
                                Container(
                                    width: Get.width * 0.35,
                                    child: Divider(
                                      color: kWhiteColor.withOpacity(0.10),
                                    )),
                                GestureDetector(
                                    onTap: () async {
                                      controller.tooltipControllerFilters.hideTooltip();
                                      printLogs('Selected Location: ${controller.address.value}');
                                      // log('Selected Location: ${controller.address.value}');

                                      await Get.toNamed(kSetLocationScreen)?.then((value) {
                                        if (value != null) {
                                          controller.address.value = value['address'];
                                          controller.lat.value = value['lat'];
                                          controller.long.value = value['long'];
                                          controller.selectedLocation.value = controller.address.value;
                                          controller.selectedLocationName.value = controller.address.value;
                                          controller.locationSearch.text = controller.address.value;
                                          controller.search.text = controller.address.value;
                                          controller.selectedLat.value = controller.lat.value;
                                          controller.selectedLong.value = controller.long.value;
                                          controller.filterPostByLocation(controller.address.value);
                                          controller.isExpanded.value = !controller.isExpanded.value;
                                        }
                                      });
                                    },
                                    child: Padding(
                                      padding: EdgeInsets.symmetric(horizontal: 15.w, vertical: 10.h),
                                      child: Text(
                                        'Filter by Location',
                                        style:
                                            AppStyles.labelTextStyle().copyWith(fontSize: 14.sp, fontWeight: FontWeight.w700, color: kPrimaryColor),
                                      ),
                                    )),
                              ],
                            ),
                            child: Image.asset(
                              kFilter2Icon,
                              width: 32.w,
                            ),
                          ),
                        ),
                        // GestureDetector(
                        //     onTap: () {
                        //       Get.toNamed(kFilterRoute);
                        //     },
                        //     child: Image.asset(kFilter2Icon,width: 32.w,))
                      ],
                    ),
                  ),
                  SizedBox(height: 20.h),
                  // GestureDetector(
                  //   onTap: () {
                  //     Get.toNamed(kFilterRoute);
                  //   },
                  //   child: Row(
                  //     children: [
                  //       Image.asset(
                  //         kFilterIcon,
                  //         width: 20.w,
                  //         height: 20.h,
                  //       ),
                  //       SizedBox(width: 5.w),
                  //       Text(
                  //         'Filters',
                  //         style: AppStyles.labelTextStyle().copyWith(fontSize: 16.sp, color: kPrimaryColor),
                  //       ),
                  //     ],
                  //   ),
                  // ),
                  SizedBox(
                    height: 8.h,
                  ),
                  // InkWell(
                  //   onTap: () async {
                  //     debugPrint(
                  //         'Selected Location: ${controller.address.value}');
                  //     // log('Selected Location: ${controller.address.value}');
                  //
                  //     await Get.toNamed(kSetLocationScreen)?.then((value) {
                  //       if (value != null) {
                  //         controller.address.value = value['address'];
                  //         controller.lat.value = value['lat'];
                  //         controller.long.value = value['long'];
                  //         controller.selectedLocation.value =
                  //             controller.address.value;
                  //         controller.selectedLocationName.value =
                  //             controller.address.value;
                  //         controller.locationSearch.text =
                  //             controller.address.value;
                  //         controller.search.text = controller.address.value;
                  //         controller.selectedLat.value = controller.lat.value;
                  //         controller.selectedLong.value = controller.long.value;
                  //         controller
                  //             .filterPostByLocation(controller.address.value);
                  //         controller.isExpanded.value =
                  //             !controller.isExpanded.value;
                  //       }
                  //     });
                  //   },
                  //   child: Text(
                  //     'Search Location',
                  //     style: AppStyles.labelTextStyle().copyWith(
                  //       fontSize: 18.sp,
                  //       fontWeight: FontWeight.bold,
                  //       color: kPrimaryColor,
                  //     ),
                  //   ),
                  // ),
                  Visibility(
                    visible: controller.selectedLat.value != 0,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SizedBox(
                          height: 8.h,
                        ),
                        Text(
                          controller.address.value,
                          style: AppStyles.labelTextStyle().copyWith(
                            fontSize: 16.sp,
                            color: kGreyRecentSearch,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(
                          height: 12.h,
                        ),
                        Text(
                          'Select Radius',
                          style: AppStyles.labelTextStyle().copyWith(
                            fontSize: 16.sp,
                            color: kPrimaryColor,
                          ),
                        ),
                        SliderTheme(
                          data: SliderTheme.of(context).copyWith(
                            thumbColor: kPrimaryColor,
                            activeTrackColor: kPrimaryColor,
                            inactiveTrackColor: kGreyContainerColor,
                            overlayColor: kBlackColor.withOpacity(0.2),
                            valueIndicatorColor: kPrimaryColor,
                            valueIndicatorTextStyle: TextStyle(
                              color: kBlackColor,
                            ),
                          ),
                          child: Obx(
                            () => Slider(
                              inactiveColor: kWhiteColor,
                              value: controller.radius.value,
                              onChanged: (v) => controller.onRadiusChange(v),
                              min: controller.radiusMinLimit.value,
                              max: controller.radiusMaxLimit.value,
                              divisions: 5,
                              label: controller.radius.value < 1
                                  ? '${(controller.radius.value * 1000).toInt()} m'
                                  : '${(controller.radius.value / 1000).toStringAsFixed(1)} km',
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 12.h),
                  Expanded(
                    child: Obx(
                      () => controller.filteredPosts.isEmpty
                          ? Center(
                              child: Text(
                                'No posts found',
                                style: AppStyles.labelTextStyle().copyWith(fontSize: 16.sp, color: kPrimaryColor),
                              ),
                            )
                          : SmartRefresher(
                              // footer: Text(
                              //   'you\'ve hit the end of the posts, pull to refresh and discover more!',
                              //   style: AppStyles.labelTextStyle().copyWith(fontSize: 16.sp, color: kPrimaryColor),
                              // ),
                              footer: CustomFooter(
                                builder: (context, mode) {
                                  return controller.totalPostPages.value == controller.currentPage.value
                                      ? Container(
                                          padding: EdgeInsets.symmetric(vertical: 15.h),
                                          alignment: Alignment.center,
                                          child: Text(
                                            'you\'ve hit the end of the posts, pull to refresh and discover more!',
                                            style: AppStyles.labelTextStyle().copyWith(fontSize: 16.sp, color: kPrimaryColor),
                                          ),
                                        )
                                      : Center(child: Container(margin: EdgeInsets.symmetric(vertical: 20), child: CircularProgressIndicator()));
                                },
                              ),
                              enablePullDown: true,
                              enablePullUp: true,
                              controller: controller.refreshController,
                              onRefresh: () async {
                                await controller.getAllPosts(isFirstTime: true);
                                controller.refreshController.refreshCompleted();
                              },
                              onLoading: () {
                                printLogs('=======on loading');
                                // Implement pagination logic here if needed
                                controller.loadMorePosts();
                                controller.refreshController.loadComplete();
                              },
                              header: const WaterDropMaterialHeader(
                                backgroundColor: kPrimaryColor,
                                color: kBlackColor,
                                distance: 20,
                              ),
                              child: GridView.custom(
                                gridDelegate: SliverWovenGridDelegate.count(
                                  crossAxisCount: 3,
                                  mainAxisSpacing: 5.h,
                                  crossAxisSpacing: 5.w,
                                  pattern: [
                                    WovenGridTile(1),
                                    WovenGridTile(
                                      5 / 7,
                                      crossAxisRatio: 0.9,
                                      alignment: AlignmentDirectional.centerEnd,
                                    ),
                                    WovenGridTile(1),
                                  ],
                                ),
                                childrenDelegate: SliverChildBuilderDelegate(
                                  childCount: controller.filteredPosts.length,
                                  (context, index) {
                                    PostModel post = controller.filteredPosts[index];
                                    if (post.thumbnail == null || post.thumbnail?.isEmpty == true) {
                                      return const CustomImageShimmer();
                                    }
                                    return GestureDetector(
                                      onTap: () async {
                                        controller.isVideoLoading.value = true;
                                        int index = controller.filteredPosts.indexWhere((element) => element.id == post.id);
                                        controller.tappedPostIndex.value = index;

                                        /*await controller.disposeVideoPlayer();
                                        await controller
                                            .initializeAllControllers(
                                                index, controller.filteredPosts.length > 3 ? 3 : controller.filteredPosts.length - 1)
                                            .then((value) {
                                          printLogs('==============discover index $index');
                                          printLogs(
                                              '==============discover controller.videoControllers.length ${controller.videoControllers.length}');
                                          if (index < controller.videoControllers.length) {
                                            controller.videoControllers[index].setLooping(true);
                                            controller.videoControllers[index].play();
                                          }
                                        });*/
                                        printLogs('==============discover index $index');
                                        printLogs('==============discover controller.videoControllers.length ${controller.videoControllers.length}');
                                        if (index < controller.videoControllers.length) {
                                          controller.videoControllers[index].setLooping(true);
                                          controller.videoControllers[index].play();
                                        }
                                        controller.updateViewCount(
                                          postId: controller.filteredPosts[index].id,
                                        );
                                        Get.toNamed(kDiscoverSwipeViewRoute);
                                      },
                                      child: Image.network(post.thumbnail!, fit: BoxFit.cover, loadingBuilder: (context, child, loadingProgress) {
                                        if (loadingProgress == null) {
                                          return child;
                                        } else {
                                          return const CustomImageShimmer();
                                        }
                                      }),
                                    );
                                  },
                                ),
                              ) /*StaggeredGrid.count(
                                crossAxisCount: 3,
                                // Random().nextInt(3) + 2,
                                mainAxisSpacing: 5.h,
                                crossAxisSpacing: 5.w,
                                children: controller.filteredPosts.map((post) {
                                  if (post.thumbnail == null || post.thumbnail?.isEmpty == true) {
                                    return const CustomImageShimmer();
                                  }
                                  return GestureDetector(
                                    onTap: () async {
                                      controller.isVideoLoading.value = true;
                                      int index = controller.filteredPosts.indexWhere((element) => element.id == post.id);
                                      controller.tappedPostIndex.value = index;
                                      await controller.disposeVideoPlayer();
                                      await controller
                                          .initializeAllControllers(
                                              index, controller.filteredPosts.length > 3 ? 3 : controller.filteredPosts.length - 1)
                                          .then((value) {
                                        controller.videoControllers[index].setLooping(true);
                                        controller.videoControllers[index].play();
                                      });

                                      controller.updateViewCount(
                                        postId: controller.filteredPosts[index].id,
                                      );
                                      Get.toNamed(kDiscoverSwipeViewRoute);
                                    },
                                    child: Image.network(post.thumbnail!, fit: BoxFit.cover, loadingBuilder: (context, child, loadingProgress) {
                                      if (loadingProgress == null) {
                                        return child;
                                      } else {
                                        return const CustomImageShimmer();
                                      }
                                    }),
                                  );
                                }).toList(),
                              )*/
                              ),
                    ),
                  ),
                  /* Obx(() => controller.isLoadMore.value
                      ? Center(child: Container(margin: EdgeInsets.symmetric(vertical: 20), child: CircularProgressIndicator()))
                      : SizedBox.shrink()),*/
                  /*Obx(() => controller.currentPage.value == 0
                      ? Center(
                          child: Container(
                            margin: EdgeInsets.symmetric(vertical: 20),
                            child: Text(
                              'you\'ve hit the end of the posts, pull to refresh and discover more!',
                              style: AppStyles.labelTextStyle().copyWith(fontSize: 16.sp, color: kPrimaryColor),
                            ),
                          ),
                        )
                      : SizedBox.shrink())*/
                ],
              ),
            ),
    );
  }
}
