/*
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:socials_app/services/custom_snackbar.dart';
import 'package:socials_app/services/session_services.dart';
import 'package:socials_app/utils/app_strings.dart';
import 'package:socials_app/views/custom_widgets/customImage.dart';
import 'package:socials_app/views/screens/home/components/video_player.dart';
import 'package:socials_app/views/screens/home/controller/home_controller.dart';

import '../../../../utils/app_colors.dart';
import '../../../../utils/common_code.dart';

///with pagination logic
class VideoPlayerWidget extends StatelessWidget {
  final HomeScreenController controller;

  const VideoPlayerWidget({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    printLogs("======VideoPlayerWidget controller.posts.isEmpty ${controller.posts.isEmpty}");
    return Obx(
      () => ModalProgressHUD(
        inAsyncCall: controller.isVideoLoading.value,
        child: Container(
          height: Get.height,
          width: Get.width,
          decoration: BoxDecoration(
            shape: BoxShape.rectangle,
          ),
          child: Obx(
            () => CarouselSlider.builder(
              carouselController: controller.carouselController,
              itemCount: controller.hasMorePosts.value ? controller.posts.length + 1 : controller.posts.length,
              itemBuilder: (context, index, realIndex) {
                // Check if index is within posts range
                if (index < controller.posts.length) {
                  final check = SessionService().isFollowingById(controller.posts[index].userId.id);

                  return Obx(
                    () => controller.moreLoading.value && index + 1 == controller.posts.length
                        ? Center(
                            child: ModalProgressHUD(
                              inAsyncCall: controller.moreLoading.value,
                              progressIndicator: const SizedBox(),
                              child: SizedBox(
                                height: Get.height,
                                width: Get.width,
                                child: CachedImage(
                                  isCircle: false,
                                  url: controller.posts[index].thumbnail ?? '',
                                  height: Get.height,
                                  width: Get.width,
                                ),
                              ),
                            ),
                          )
                        : VideoPlayerScreen(
                            post: controller.posts[index],
                            index: index,
                            homeController: controller,
                            videoUrl: controller.posts[index].video,
                            isFollowed: check,
                            onFollowButtonTap: () async {
                              await controller.updateFollowStatus(followedUserId: controller.posts[index].userId.id, index: index);
                            },
                            onProfileTap: () {
                              Get.toNamed(kFollowersProfileScreen, arguments: controller.posts[index].userId.id);
                            },
                            followedUserId: controller.posts[index].userId.id),
                  );
                } else {
                  // Loading indicator for pagination
                  return Center(
                    child: CircularProgressIndicator(
                      color: kPrimaryColor,
                    ),
                  );
                }
              },
              options: CarouselOptions(
                height: Get.height,
                viewportFraction: 0.85,
                enlargeCenterPage: true,
                enableInfiniteScroll: false,
                onPageChanged: (index, reason) async {
                  */
/*if (index == controller.posts.length && controller.hasMorePosts.isTrue) {
                    // Safety check before pausing video
                    if (controller.previousValue.value < controller.videoControllers.length) {
                      controller.videoControllers[controller.previousValue.value].value.controller.pause();
                    }
                    controller.previousValue.value = index;
                    controller.isVideoChanged.value = true;
                    controller.getAllPosts(isFirstTime: false, isFromOnChange: true);
                  } else {*/ /*

                  controller.updateViewCount(postId: controller.posts[index].id, index: index);

                  // Safety check before pausing previous video
                  if (controller.previousValue.value < controller.videoControllers.length) {
                    await controller.videoControllers[controller.previousValue.value].value.controller.pause();
                  }
                  controller.isPlaying.value = false;
                  controller.isRatingTapped.value = false;

                  if (controller.isMoreLoading.value) {
                    // Safety check before pausing current video
                    if (index < controller.videoControllers.length) {
                      await controller.videoControllers[index].value.controller.pause();
                    }
                    CustomSnackbar.showSnackbar('Loading in progress, please wait');
                    controller.carouselController.animateToPage(controller.previousValue.value);
                    return; // Exit early to prevent further processing
                  } else {
                    // No need to pause previous video again, already done above
                    controller.previousValue.value = index;

                    // Safety check before playing current video
                    if (index < controller.videoControllers.length) {
                      await controller.videoControllers[index].value.controller.play();
                      controller.isPlaying.value = true;
                    }

                    if (index == controller.posts.length - 1 && controller.hasMorePosts.isFalse) {
                      CustomSnackbar.showSnackbar('No more videos available');
                      // Safety check before operations
                      if (controller.previousValue.value < controller.videoControllers.length && index < controller.videoControllers.length) {
                        controller.videoControllers[controller.previousValue.value].value.controller.pause();
                        controller.previousValue.value = index;
                        await controller.videoControllers[index].value.controller.play();
                        controller.isPlaying.value = true;
                      }
                    } else if (controller.videoControllers.length - index <= 2) {
                      // Safety check before operations
                      if (controller.previousValue.value < controller.videoControllers.length) {
                        controller.videoControllers[controller.previousValue.value].value.controller.pause();
                      }
                      controller.previousValue.value = index;
                      controller.isVideoChanged.value = true;
                      controller.onPageChange(index);
                    }
                  }
                  //  }
                },
              ),
              */
/*options: CarouselOptions(
                height: Get.height,
                viewportFraction: 0.85,
                enlargeCenterPage: true,
                enableInfiniteScroll: false,
                onPageChanged: (index, reason) async {
                  if (index == controller.posts.length && controller.hasMorePosts.isTrue) {
                    controller.videoControllers[controller.previousValue.value].value.controller.pause();
                    controller.previousValue.value = index;
                    controller.isVideoChanged.value = true;
                    // controller.onPageChange(index);
                    controller.getAllPosts(isFirstTime: false, isFromOnChange: true);
                  } else {
                    controller.updateViewCount(postId: controller.posts[index].id, index: index);

                    await controller.videoControllers[controller.previousValue.value].value.controller.pause();
                    controller.isPlaying.value = false;
                    controller.isRatingTapped.value = false;

                    if (controller.isMoreLoading.value) {
                      await controller.videoControllers[index].value.controller.pause();
                      CustomSnackbar.showSnackbar('Loading in progress, please wait');
                    } else {
                      await controller.videoControllers[controller.previousValue.value].value.controller.pause();
                      controller.previousValue.value = index;
                      await controller.videoControllers[index].value.controller.play();
                      controller.isPlaying.value = true;

                      if (index == controller.posts.length - 1 && controller.hasMorePosts.isFalse) {
                        CustomSnackbar.showSnackbar('No more videos available');
                        controller.videoControllers[controller.previousValue.value].value.controller.pause();
                        controller.previousValue.value = index;
                        await controller.videoControllers[index].value.controller.play();
                        controller.isPlaying.value = true;
                      } else if (controller.videoControllers.length - index <= 2) {
                        controller.videoControllers[controller.previousValue.value].value.controller.pause();
                        controller.previousValue.value = index;
                        controller.isVideoChanged.value = true;
                        controller.onPageChange(index);
                      }
                    }
                  }
                },
              ),*/ /*

            ),
          ),
        ),
      ),
    );
  }
}
*/
