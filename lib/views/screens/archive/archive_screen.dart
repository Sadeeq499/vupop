import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:shimmer/shimmer.dart';
import 'package:socials_app/utils/app_colors.dart';
import 'package:socials_app/utils/app_images.dart';
import 'package:socials_app/utils/app_strings.dart';
import 'package:socials_app/views/custom_widgets/custom_shimmer_image_widget.dart';
import 'package:socials_app/views/screens/archive/controller/archive_controller.dart';

import '../../../utils/app_styles.dart';
import '../../custom_widgets/custom_scaffold.dart';

class ArchiveScreen extends GetView<ArchiveController> {
  const ArchiveScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => controller.isLoading.value
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : CustomScaffold(
              className: 'Archive Screen',
              screenName: "Archives ",
              scaffoldKey: controller.scaffoldKeyArchive,
              isFullBody: false,
              backIconColor: kPrimaryColor,
              leadingWidget: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_ios),
                    color: kPrimaryColor,
                    onPressed: () {
                      Get.back();
                    },
                  ),
                ],
              ),
              onWillPop: () {
                Get.back();
              },
              body: Padding(
                padding: const EdgeInsets.only(top: 20, bottom: 40),
                child: controller.isGettingPosts.value == true
                    ? Shimmer.fromColors(
                        baseColor: kShimmerbaseColor,
                        highlightColor: kShimmerhighlightColor,
                        child: Container(
                          width: 180.w,
                          height: 200.h,
                          color: Colors.grey,
                        ),
                      )
                    : controller.userPosts.isNotEmpty
                        ? NotificationListener<ScrollNotification>(
                            onNotification: (ScrollNotification scrollInfo) {
                              if (scrollInfo.metrics.pixels == scrollInfo.metrics.maxScrollExtent && !controller.isLoadingMorePosts.value) {
                                controller.loadMorePosts();
                                return true;
                              }
                              return false;
                            },
                            child: Column(
                              children: [
                                Expanded(
                                  child: GridView.builder(
                                    controller: controller.scrollController,
                                    itemCount: controller.userPosts.length,
                                    shrinkWrap: true,
                                    physics: const AlwaysScrollableScrollPhysics(),
                                    gridDelegate:
                                        const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, crossAxisSpacing: 10, mainAxisSpacing: 10),
                                    itemBuilder: (BuildContext context, int index) {
                                      if (controller.userPosts.isEmpty) {
                                        return const Center(child: CustomImageShimmer());
                                      }
                                      if (controller.userPosts[index] == null) {
                                        return const Center(child: CustomImageShimmer());
                                      }
                                      return Obx(
                                        () => GestureDetector(
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

                                            Get.toNamed(kArchiveSwipeViewPosts);
                                          },
                                          child: Stack(
                                            alignment: AlignmentDirectional.center,
                                            children: [
                                              Image.network(controller.userPosts[index].thumbnail ?? '', fit: BoxFit.cover,
                                                  loadingBuilder: (context, child, loadingProgress) {
                                                if (loadingProgress == null) {
                                                  return SizedBox(width: Get.width, height: Get.height, child: child);
                                                } else {
                                                  return const CustomImageShimmer();
                                                }
                                              }),
                                              Positioned(
                                                top: 0,
                                                right: 10,
                                                child: GestureDetector(
                                                  onTap: () {
                                                    controller.reportIssueWithClip[index].value = !controller.reportIssueWithClip[index].value;
                                                  },
                                                  child: Image.asset(
                                                    kMenuIcon,
                                                    fit: BoxFit.fill,
                                                    height: 24,
                                                    width: 24,
                                                  ),
                                                ),
                                              ),
                                              /* Positioned(
                                                child: TopRightNotchContainer(
                                                  margin: EdgeInsets.symmetric(horizontal: 1),
                                                  color: Colors.white,
                                                  borderRadius: 10,
                                                  notchSize: 1,
                                                  child: Padding(
                                                    padding: EdgeInsets.all(16),
                                                    child: Text(
                                                      'Raise an issue',
                                                      style: TextStyle(
                                                        fontWeight: FontWeight.bold,
                                                        color: Colors.black87,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ),*/
                                              Obx(
                                                () => controller.reportIssueWithClip[index].value
                                                    ? Positioned(
                                                        top: 22,
                                                        right: 20,
                                                        child: GestureDetector(
                                                          onTap: () {
                                                            controller.reportIssueWithClip[index].value = false;
                                                            Get.toNamed(kRaiseAnIssueScreen, arguments: {'postId': controller.userPosts[index].id});
                                                          },
                                                          child: Container(
                                                            padding: EdgeInsets.symmetric(vertical: 5, horizontal: 12),
                                                            decoration: BoxDecoration(
                                                              color: kPrimaryColor,
                                                              borderRadius: BorderRadius.circular(5),
                                                            ),
                                                            child: Text(
                                                              'Raise an issue',
                                                              style: TextStyle(
                                                                fontWeight: FontWeight.bold,
                                                                color: Colors.black87,
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                      )
                                                    : SizedBox.shrink(),
                                              ),
                                              Positioned(
                                                bottom: 15,
                                                right: 10,
                                                child: Obx(
                                                  () => controller.isPostDownloading[index].value == true
                                                      ? Container(
                                                          padding: const EdgeInsets.all(4),
                                                          decoration: BoxDecoration(
                                                            color: Colors.black54,
                                                            borderRadius: BorderRadius.circular(20),
                                                          ),
                                                          child: Row(
                                                            mainAxisSize: MainAxisSize.min,
                                                            children: [
                                                              SizedBox(
                                                                width: 24.w,
                                                                height: 24.h,
                                                                child: Stack(
                                                                  alignment: Alignment.center,
                                                                  children: [
                                                                    CircularProgressIndicator(
                                                                      value: controller.downloadProgress[index].value / 100,
                                                                      valueColor: AlwaysStoppedAnimation(kPrimaryColor),
                                                                      strokeWidth: 2.0,
                                                                      backgroundColor: Colors.grey.withOpacity(0.3),
                                                                    ),
                                                                    Text(
                                                                      "${controller.downloadProgress[index].value.toInt()}%",
                                                                      style: TextStyle(
                                                                        color: kWhiteColor,
                                                                        fontSize: 8.sp,
                                                                        fontWeight: FontWeight.bold,
                                                                      ),
                                                                    ),
                                                                  ],
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                        )
                                                      : GestureDetector(
                                                          onTap: () {
                                                            controller.saveVideoLocally(index, videoUrl: controller.userPosts[index].video);
                                                          },
                                                          child: Image.asset(kdownloadIcon, fit: BoxFit.fill),
                                                        ),
                                                ),
                                              ),
                                              /* Positioned(
                                                bottom: 15,
                                                right: 10,
                                                child: Obx(
                                                  () => controller.isPostDownloading[index].value == true
                                                      ? Row(
                                                          children: [
                                                            const CircularProgressIndicator(),
                                                            const SizedBox(width: 10),
                                                            Obx(() => Text(controller.downloadProgress.value.toStringAsFixed(2),
                                                                style: const TextStyle(color: kWhiteColor))),
                                                          ],
                                                        )
                                                      : GestureDetector(
                                                          onTap: () {
                                                            controller.saveVideoLocally(index, videoUrl: controller.userPosts[index].video);
                                                          },
                                                          child: Image.asset(kdownloadIcon, fit: BoxFit.fill),
                                                        ),
                                                ),
                                              ),*/
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
                                                          SizedBox(width: 10.w),
                                                          Text("${controller.userPosts[index].views?.length}",
                                                              style: const TextStyle(color: kWhiteColor))
                                                        ],
                                                      ),
                                                    ),
                                                  ))
                                            ],
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                                // Bottom loader for loading more posts
                                Obx(() => controller.isLoadingMorePosts.value
                                    ? const Padding(
                                        padding: EdgeInsets.all(8.0),
                                        child: CircularProgressIndicator(),
                                      )
                                    : const SizedBox.shrink()),
                              ],
                            ),
                          )
                        : Center(
                            child: Text(
                              "No Archives",
                              style: AppStyles.labelTextStyle().copyWith(
                                color: kPrimaryColor,
                                fontSize: 18.sp,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
              ),
            ),
    );
  }
}
