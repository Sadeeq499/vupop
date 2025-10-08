import 'dart:async';
import 'dart:io';

import 'package:cached_video_player_plus/cached_video_player_plus.dart';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:native_device_orientation/native_device_orientation.dart';
import 'package:socials_app/services/custom_snackbar.dart';
import 'package:socials_app/services/session_services.dart';
import 'package:socials_app/utils/app_colors.dart';
import 'package:socials_app/utils/app_images.dart';
import 'package:socials_app/utils/app_strings.dart';
import 'package:socials_app/utils/common_code.dart';
import 'package:socials_app/views/screens/home_recordings/components/videosharingbottom.dart';
import 'package:video_trimmer/video_trimmer.dart';

import '../../../services/permission_service.dart';
import '../../../utils/app_styles.dart';
import '../bottom/controller/bottom_bar_controller.dart';
import 'components/combining_video_loading_widget.dart';
import 'components/countdown_widget.dart';
import 'controller/recording_cont.dart';

class RecordingScreen extends GetView<RecordingController> {
  final bool isFromBottomBar;
  const RecordingScreen({super.key, required this.isFromBottomBar});

  @override
  Widget build(BuildContext context) {
    if (!isFromBottomBar) {
      Future.microtask(() {
        controller.firstInit(isFromBottomBar: isFromBottomBar);
      });
    }
    return isFromBottomBar
        ? WillPopScope(
            onWillPop: () {
              print('============on will pop called');
              controller.resetRecording();
              Get.find<BottomBarController>().selectedIndex.value = 0;
              return Future.value(false);
            },
            child: Scaffold(
              body: NativeDeviceOrientationReader(
                builder: (context) {
                  final orientation =
                      NativeDeviceOrientationReader.orientation(context);
                  return allViewBuild();
                },
              ),
            ),
          )
        : Scaffold(
            body: NativeDeviceOrientationReader(
              builder: (context) {
                final orientation =
                    NativeDeviceOrientationReader.orientation(context);
                if (!controller.isRecordingStarted.value) {
                  if (orientation == NativeDeviceOrientation.landscapeLeft) {
                    controller.rotateValue.value = 1;
                  } else if (orientation ==
                      NativeDeviceOrientation.landscapeRight) {
                    controller.rotateValue.value = -1;
                  } else {
                    controller.rotateValue.value = 0;
                  }
                }
                return allViewBuild();
              },
            ),
          );
  }

  Obx allViewBuild() {
    return Obx(
      () {
        return controller.isDualCamera.value
            ? controller.isLoading.value
                ? const Center(child: CircularProgressIndicator())
                : controller.isFinishedRecording.value != true
                    ? cameraBuildDual()
                    : videoPlayBack()
            : controller.isCombining.value
                ? VideoCombiningLoadingWIdget(controller: controller)
                : controller.isLoading.value
                    ? const Center(child: CircularProgressIndicator())
                    : controller.isFinishedRecording.value != true
                        ? camerabuild()
                        : videoPlayBackUpdated();
      },
    );
  }

  GetBuilder<RecordingController> videoPlayBackUpdated() {
    return GetBuilder(
      init: controller,
      builder: (RecordingController controller) {
        return controller.isFinishedRecording.value
            ? Stack(
                children: [
                  // Show different UI based on whether video is from gallery or recorded
                  Obx(() => controller.isFileSelected.value
                      ? _buildTrimmerView()
                      : _buildCustomVideoPlayer()),

                  // Top controls
                  Positioned(
                    top: 50.h,
                    left: 20.w,
                    child: InkWell(
                      onTap: () {
                        controller.resetRecording();
                      },
                      child: Image.asset(kCloseIcon, width: 32.w, height: 32.h),
                    ),
                  ),

                  // Bottom sharing controls
                  Positioned(
                    bottom: isFromBottomBar ? 12 : 0.h,
                    right: 0.w,
                    child: VideoSharingBottom(
                      onPressed: () async {
                        await controller.getLocation();
                        if (controller.isFileSelected.isTrue) {
                          await controller.getLocalVideoDetails(
                              controller.outPutFile.value!.path);
                          await controller
                              .trimVideoUpdated(); // Use updated trim method
                        }
                        Get.toNamed(kSharePostScreen);
                      },
                    ),
                  ),

                  // Play/Pause button for trimmer
                  Obx(
                    () => controller.isFileSelected.value
                        ? Positioned(
                            top: 0,
                            bottom: 0,
                            left: 0,
                            right: 0,
                            child: Center(
                              child: Container(
                                height: 80,
                                child: Obx(() => TextButton(
                                      child: controller.isPlaying.value
                                          ? Icon(
                                              Icons.pause,
                                              size: 60.0,
                                              color: Colors.white,
                                            )
                                          : Icon(
                                              Icons.play_arrow,
                                              size: 60.0,
                                              color: Colors.white,
                                            ),
                                      onPressed: () async {
                                        try {
                                          bool newPlaybackState =
                                              await controller.trimmer.value
                                                  .videoPlaybackControl(
                                            startValue:
                                                controller.startValue.value,
                                            endValue: controller.endValue.value,
                                          );
                                          controller.isPlaying.value =
                                              newPlaybackState;
                                          print(
                                              'Play button clicked. New playback state: $newPlaybackState');
                                          print(
                                              'Start: ${controller.startValue.value}, End: ${controller.endValue.value}');
                                        } catch (e) {
                                          print(
                                              'Error controlling video playback: $e');
                                        }
                                      },
                                    )),
                              ),
                            ),
                          )
                        : SizedBox.shrink(),
                  ),
                ],
              )
            : const SizedBox();
      },
    );
  }

  // Helper method for trimmer view (gallery videos)
  Widget _buildTrimmerView() {
    return Container(
      color: Colors.black,
      child: Column(
        children: [
          // Video viewer for trimmer
          Expanded(
            child: Obx(() => controller.trimmer.value != null
                ? VideoViewer(trimmer: controller.trimmer.value)
                : const Center(child: CircularProgressIndicator())),
          ),

          // Trim viewer controls
          Container(
            height: 80,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Obx(
              () => TrimViewer(
                trimmer: controller.trimmer.value,
                viewerHeight: Platform.isIOS ? 70 : 50.0,
                viewerWidth: Get.width - 40,
                maxVideoLength: const Duration(seconds: 20),
                onChangeStart: (value) {
                  controller.startValue.value = value;
                },
                onChangeEnd: (value) {
                  controller.endValue.value = value;
                },
                onChangePlaybackState: (value) {
                  controller.isPlaying.value = value;
                },
                durationStyle: DurationStyle.FORMAT_MM_SS,
                editorProperties: TrimEditorProperties(
                  borderPaintColor: kPrimaryColor,
                  borderWidth: 4,
                  borderRadius: 5,
                  circlePaintColor: kPrimaryColor2,
                ),
                areaProperties: TrimAreaProperties.edgeBlur(
                  thumbnailQuality: 10,
                ),
              ),
            ),
          ),
          Container(
            height: Platform.isIOS ? 110 : 80,
          )
        ],
      ),
    );
  }

  // Helper method for custom video player (recorded videos)
  Widget _buildCustomVideoPlayer() {
    return Stack(
      children: [
        // iOS video player
        if (Platform.isIOS) ...[
          Obx(
            () => controller.videoPlayerController.value == null
                ? const Center(child: CircularProgressIndicator())
                : Center(
                    child: Obx(
                      () => AspectRatio(
                        aspectRatio: controller
                            .videoPlayerController.value!.value.aspectRatio,
                        child: CachedVideoPlayerPlus(
                            controller.videoPlayerController.value!),
                      ),
                    ),
                  ),
          ),
        ],

        // Android video player with better handling
        if (Platform.isAndroid) ...[
          SizedBox.expand(
            child: Obx(() {
              if (controller.videoPlayerController.value == null) {
                return const Center(child: CircularProgressIndicator());
              }

              final videoController = controller.videoPlayerController.value!;
              final videoValue = videoController.value;
              double width = videoValue.size.width;
              double height = videoValue.size.height;

              // For portrait recorded videos
              if (Platform.isAndroid &&
                  !controller.isFileSelected.value &&
                  controller.rotateValue.value == 0 &&
                  controller.isLandScape.isFalse) {
                Widget videoWidget = CachedVideoPlayerPlus(videoController);
                videoWidget = RotatedBox(quarterTurns: 0, child: videoWidget);

                return Container(
                  color: Colors.black,
                  child: ClipRect(
                    child: FittedBox(
                      fit: BoxFit.cover,
                      child: SizedBox(
                        width: !controller.isFileSelected.value &&
                                controller.rotateValue.value == 0 &&
                                height > width
                            ? height
                            : width,
                        height: !controller.isFileSelected.value &&
                                controller.rotateValue.value == 0 &&
                                height > width
                            ? width
                            : height,
                        child: videoWidget,
                      ),
                    ),
                  ),
                );
              } else {
                double aspectRatio =
                    controller.videoPlayerController.value!.value.aspectRatio;
                return Center(
                  child: AspectRatio(
                    aspectRatio: aspectRatio,
                    child: Container(
                      color: Colors.black,
                      child: CachedVideoPlayerPlus(videoController),
                    ),
                  ),
                );
              }
            }),
          ),
        ],

        // Trim viewer overlay for recorded videos
        Positioned(
          top: 100,
          left: 20,
          right: 20,
          child: Obx(
            () => TrimViewer(
              trimmer: controller.trimmer.value,
              viewerHeight: 50.0,
              paddingFraction: 8,
              type: ViewerType.auto,
              viewerWidth: Get.width,
              maxVideoLength: const Duration(seconds: 20),
              onChangeStart: (value) => controller.startValue.value = value,
              onChangeEnd: (value) => controller.endValue.value = value,
              onChangePlaybackState: (value) =>
                  controller.isPlaying.value = value,
              durationStyle: DurationStyle.FORMAT_MM_SS,
              editorProperties: TrimEditorProperties(
                borderPaintColor: kPrimaryColor,
                borderWidth: 4,
                borderRadius: 5,
                circlePaintColor: kPrimaryColor2,
              ),
              areaProperties: TrimAreaProperties.edgeBlur(
                thumbnailQuality: 10,
              ),
            ),
          ),
        ),
      ],
    );
  }

  GetBuilder<RecordingController> videoPlayBack() {
    return GetBuilder(
      init: controller,
      builder: (RecordingController controller) {
        return controller.isFinishedRecording.value
            ? Stack(
                children: [
                  // Video player section
                  if (Platform.isIOS) ...[
                    Obx(
                      () => controller.videoPlayerController.value == null
                          ? const Center(child: CircularProgressIndicator())
                          : Center(
                              child: Obx(
                                () => AspectRatio(
                                  aspectRatio: controller.videoPlayerController
                                      .value!.value.aspectRatio,
                                  child: CachedVideoPlayerPlus(
                                      controller.videoPlayerController.value!),
                                ),
                              ),
                            ),
                    ),
                  ],

                  if (Platform.isAndroid) ...[
                    SizedBox.expand(
                      child: Obx(() {
                        if (controller.videoPlayerController.value == null) {
                          return const Center(
                              child: CircularProgressIndicator());
                        }

                        final videoController =
                            controller.videoPlayerController.value!;
                        final videoValue = videoController.value;
                        double width = videoValue.size.width;
                        double height = videoValue.size.height;

                        // For portrait recorded videos
                        if (Platform.isAndroid &&
                            !controller.isFileSelected.value &&
                            controller.rotateValue.value == 0 &&
                            controller.isLandScape.isFalse) {
                          Widget videoWidget =
                              CachedVideoPlayerPlus(videoController);
                          videoWidget =
                              RotatedBox(quarterTurns: 0, child: videoWidget);

                          return Container(
                            color: Colors.black,
                            child: ClipRect(
                              child: FittedBox(
                                fit: BoxFit.cover,
                                child: SizedBox(
                                  width: !controller.isFileSelected.value &&
                                          controller.rotateValue.value == 0 &&
                                          height > width
                                      ? height
                                      : width,
                                  height: !controller.isFileSelected.value &&
                                          controller.rotateValue.value == 0 &&
                                          height > width
                                      ? width
                                      : height,
                                  child: videoWidget,
                                ),
                              ),
                            ),
                          );
                        } else {
                          double aspectRatio = controller
                              .videoPlayerController.value!.value.aspectRatio;
                          return Center(
                            child: AspectRatio(
                              aspectRatio: aspectRatio,
                              child: Container(
                                color: Colors.black,
                                child: CachedVideoPlayerPlus(videoController),
                              ),
                            ),
                          );
                        }
                      }),
                    ),
                  ],

                  // Trim viewer
                  Positioned(
                    top: 100,
                    left: 20,
                    right: 20,
                    child: Obx(
                      () => TrimViewer(
                        trimmer: controller.trimmer.value,
                        viewerHeight: 50.0,
                        paddingFraction: 8,
                        type: ViewerType.auto,
                        viewerWidth: Get.width,
                        maxVideoLength: const Duration(seconds: 20),
                        onChangeStart: (value) =>
                            controller.startValue.value = value,
                        onChangeEnd: (value) =>
                            controller.endValue.value = value,
                        onChangePlaybackState: (value) =>
                            controller.isPlaying.value = value,
                        durationStyle: DurationStyle.FORMAT_MM_SS,
                        editorProperties: TrimEditorProperties(
                          borderPaintColor: kPrimaryColor,
                          borderWidth: 4,
                          borderRadius: 5,
                          circlePaintColor: kPrimaryColor2,
                        ),
                        areaProperties: TrimAreaProperties.edgeBlur(
                          thumbnailQuality: 10,
                        ),
                      ),
                    ),
                  ),

                  // Bottom sharing controls
                  Positioned(
                    bottom: 0.h,
                    right: 0.w,
                    child: VideoSharingBottom(
                      onPressed: () async {
                        await controller.getLocation();
                        if (controller.isFileSelected.isTrue) {
                          await controller.getLocalVideoDetails(
                              controller.outPutFile.value!.path);
                          await controller.trimVideo();
                        }
                        Get.toNamed(kSharePostScreen);
                      },
                    ),
                  ),

                  // Close button
                  Positioned(
                    top: 50.h,
                    left: 20.w,
                    child: InkWell(
                      onTap: () {
                        controller.resetRecording();
                      },
                      child: Image.asset(kCloseIcon, width: 32.w, height: 32.h),
                    ),
                  ),
                ],
              )
            : const SizedBox();
      },
    );
  }

  // FIXED: Camera build with better error handling
  camerabuild() {
    return GetBuilder<RecordingController>(
      init: controller,
      builder: (_) {
        return Stack(
          children: [
            // Camera preview with error handling
            if (Platform.isIOS) ...[
              Center(
                child: Obx(
                  () {
                    // Show error state
                    if (controller.isCameraError.value) {
                      return _buildCameraErrorWidget();
                    }

                    // Show loading
                    if (controller.isLoading.value) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    return RotatedBox(
                      quarterTurns: controller.isLandScape.value ? 1 : 0,
                      child: GestureDetector(
                        onDoubleTap: controller.doubleTapZoom,
                        onScaleStart: (details) {
                          controller.onScaleStart(details);
                        },
                        onScaleUpdate: (details) {
                          controller.onScaleUpdate(details);
                        },
                        child: Obx(
                          () {
                            final cameraController =
                                controller.cameraController.value;
                            if (cameraController == null ||
                                !cameraController.value.isInitialized) {
                              return const Center(
                                  child: CircularProgressIndicator());
                            }
                            return CameraPreview(cameraController);
                          },
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],

            if (Platform.isAndroid) ...[
              SizedBox.expand(
                child: GetBuilder<RecordingController>(
                  id: 'camera_preview',
                  builder: (controller) {
                    // Show error state
                    if (controller.isCameraError.value) {
                      return _buildCameraErrorWidget();
                    }

                    // Show loading
                    if (controller.isLoading.value) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    final cameraController = controller.cameraController.value;
                    if (cameraController == null ||
                        !cameraController.value.isInitialized) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    // Check for camera errors
                    if (cameraController.value.hasError) {
                      return _buildCameraErrorWidget();
                    }

                    return RotatedBox(
                      quarterTurns: controller.isLandScape.value ? 1 : 0,
                      child: ClipRect(
                        child: OverflowBox(
                          alignment: Alignment.center,
                          child: AspectRatio(
                            aspectRatio: cameraController.value.aspectRatio,
                            child: GestureDetector(
                              onDoubleTap: controller.doubleTapZoom,
                              onScaleStart: (details) {
                                controller.onScaleStart(details);
                              },
                              onScaleUpdate: (details) {
                                controller.onScaleUpdate(details);
                              },
                              child: CameraPreview(cameraController),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              )
            ],

            // Back/Skip button
            Positioned(
              top: !SessionService().isUserLoggedIn ? 48.h : 38.h,
              right: SessionService().isUserLoggedIn ? Get.width * 0.85 : 10.w,
              left: SessionService().isUserLoggedIn ? 0.w : Get.width * 0.82,
              child: GestureDetector(
                onTap: () async {
                  await controller.cameraController.value
                      ?.unlockCaptureOrientation();
                  if (SessionService().isUserLoggedIn) {
                    controller.resetRecording();
                    Get.find<BottomBarController>().selectedIndex.value = 0;
                    Get.find<BottomBarController>()
                        .previousSelectedIndex
                        .value = 0;
                  } else {
                    printLogs("Calling Login Route from skip");
                    controller.resetRecording();
                    Get.find<BottomBarController>().selectedIndex.value = 0;
                    Get.find<BottomBarController>()
                        .previousSelectedIndex
                        .value = 0;
                    Get.offAndToNamed(kSignInRoute);
                  }
                },
                child: Padding(
                    padding: EdgeInsets.only(left: 10.w),
                    child: SessionService().isUserLoggedIn
                        ? const Icon(
                            Icons.arrow_back_ios,
                            size: 36,
                            color: kPrimaryColor,
                          )
                        : ClipRRect(
                            borderRadius:
                                const BorderRadius.all(Radius.circular(100)),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 4, vertical: 5),
                              color: kWhiteColor.withAlpha(70),
                              child: Text(
                                'Skip',
                                textAlign: TextAlign.center,
                                style: AppStyles.labelTextStyle().copyWith(
                                    fontWeight: FontWeight.w400,
                                    fontSize: 12.sp,
                                    color: kPrimaryColor),
                              ),
                            ),
                          )),
              ),
            ),

            // App logo
            Positioned(
              top: 8.h,
              left: 0.w,
              right: 0.w,
              child: Center(
                child: Image.asset(kAppLogo, height: 100.h, width: 100.w),
              ),
            ),

            // Record button for non-logged in users
            if (!SessionService().isUserLoggedIn)
              Positioned(
                bottom: 25.h,
                right: 50.w,
                left: 50.w,
                child: _buildRecordButton(),
              ),

            // Record button for logged in users
            if (SessionService().isUserLoggedIn)
              Positioned(
                bottom: 25.h,
                right: 50.w,
                left: 50.w,
                child: Obx(
                  () => controller.isRecording.value
                      ? _buildRecordButton()
                      : SizedBox.shrink(),
                ),
              ),

            // Camera switch button
            Positioned(
                bottom: 20.h,
                right: 40.w,
                child: Obx(
                  () => controller.isRecording.value
                      ? SizedBox.shrink()
                      : IconButton(
                          icon: Icon(
                            Icons.cameraswitch_sharp,
                            color: kPrimaryColor,
                            size: 50.sp,
                          ),
                          onPressed: () {
                            final currentTime = DateTime.now();
                            if (currentTime
                                    .difference(controller.lastSwitchTime.value)
                                    .inSeconds >=
                                3) {
                              controller.lastSwitchTime.value = currentTime;
                              controller.isFaceCam.value =
                                  !controller.isFaceCam.value;
                              controller.switchCameraForNonDual();
                            } else {
                              CustomSnackbar.showSnackbar(
                                  'Too Early to switch camera');
                            }
                          },
                        ),
                )),

            // Orientation tabs
            Positioned(
              bottom: !SessionService().isUserLoggedIn ? 135 : 20,
              right: 0.w,
              left: 0,
              child: Obx(
                () => controller.isRecording.value
                    ? SizedBox.shrink()
                    : Container(
                        padding: EdgeInsets.symmetric(horizontal: 20.w),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // Portrait Tab
                            GestureDetector(
                              onTap: () {
                                final currentTime = DateTime.now();
                                if (currentTime
                                        .difference(
                                            controller.lastSwitchTime.value)
                                        .inMicroseconds >=
                                    500) {
                                  controller.lastSwitchTime.value = currentTime;
                                  if (controller.isPortrait.isFalse) {
                                    controller.isLandScape.value = false;
                                    controller.isPortrait.value = true;
                                    controller.resetRecording(
                                        isFrom: 'Portrait');
                                  }
                                } else {
                                  CustomSnackbar.showSnackbar(
                                      'Too Early to switch orientation');
                                }
                              },
                              child: Container(
                                padding: EdgeInsets.symmetric(
                                    horizontal: 5.w, vertical: 5.h),
                                decoration: BoxDecoration(
                                  color: controller.isPortrait.isTrue
                                      ? kPrimaryColor.withOpacity(0.2)
                                      : Colors.transparent,
                                  borderRadius: BorderRadius.circular(5.r),
                                  border: Border.all(
                                    color: controller.isPortrait.isTrue
                                        ? kPrimaryColor
                                        : kPrimaryColor.withOpacity(0.5),
                                    width: 2,
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.screen_lock_portrait,
                                      color: controller.isPortrait.isTrue
                                          ? kPrimaryColor
                                          : kPrimaryColor.withOpacity(0.7),
                                      size: 12.sp,
                                    ),
                                    SizedBox(width: 8.w),
                                    Text(
                                      'Portrait',
                                      style: TextStyle(
                                        color: controller.isPortrait.isTrue
                                            ? kPrimaryColor
                                            : kPrimaryColor.withOpacity(0.7),
                                        fontSize: 14.sp,
                                        fontWeight: controller.isPortrait.isTrue
                                            ? FontWeight.bold
                                            : FontWeight.normal,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),

                            SizedBox(width: 12.w),

                            // Landscape Tab
                            GestureDetector(
                              onTap: () {
                                final currentTime = DateTime.now();
                                if (currentTime
                                        .difference(
                                            controller.lastSwitchTime.value)
                                        .inMicroseconds >=
                                    500) {
                                  controller.lastSwitchTime.value = currentTime;
                                  if (controller.isLandScape.isFalse) {
                                    controller.isPortrait.value = false;
                                    controller.isLandScape.value = true;
                                    controller.resetRecording(
                                        isFrom: "LandScape");
                                  }
                                } else {
                                  CustomSnackbar.showSnackbar(
                                      'Too Early to switch orientation');
                                }
                              },
                              child: Container(
                                padding: EdgeInsets.symmetric(
                                    horizontal: 5.w, vertical: 5.h),
                                decoration: BoxDecoration(
                                  color: controller.isLandScape.isTrue
                                      ? kPrimaryColor.withOpacity(0.2)
                                      : Colors.transparent,
                                  borderRadius: BorderRadius.circular(5.r),
                                  border: Border.all(
                                    color: controller.isLandScape.isTrue
                                        ? kPrimaryColor
                                        : kPrimaryColor.withOpacity(0.5),
                                    width: 2,
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.videocam,
                                      color: controller.isLandScape.isTrue
                                          ? kPrimaryColor
                                          : kPrimaryColor.withOpacity(0.7),
                                      size: 12.sp,
                                    ),
                                    SizedBox(width: 8.w),
                                    Text(
                                      'Landscape',
                                      style: TextStyle(
                                        color: controller.isLandScape.isTrue
                                            ? kPrimaryColor
                                            : kPrimaryColor.withOpacity(0.7),
                                        fontSize: 14.sp,
                                        fontWeight:
                                            controller.isLandScape.isTrue
                                                ? FontWeight.bold
                                                : FontWeight.normal,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
              ),
            ),

            // Upload/Gallery button
            Positioned(
              bottom: 20.h,
              left: 50.w,
              child: Obx(
                () => controller.isRecording.value
                    ? SizedBox.shrink()
                    : GestureDetector(
                        onTap: () {
                          Get.find<RecordingController>()
                              .showQualityRulesSheet();
                        },
                        child: Image.asset(
                          kUploadIcon,
                          width: 50.w,
                        ),
                      ),
              ),
            ),

            // Zoom slider
            Positioned(
              right: 20.w,
              bottom: Get.height * 0.10,
              child: Obx(() => RotatedBox(
                    quarterTurns: 3,
                    child: SliderTheme(
                      data: SliderThemeData(
                        trackHeight: 8,
                        activeTrackColor: kPrimaryColor,
                        inactiveTrackColor: kPrimaryColor.withOpacity(0.3),
                        thumbColor: kPrimaryColor,
                        overlayColor: kPrimaryColor.withOpacity(0.2),
                        activeTickMarkColor: kPrimaryColor,
                        inactiveTickMarkColor: kPrimaryColor.withOpacity(0.5),
                        tickMarkShape:
                            RoundSliderTickMarkShape(tickMarkRadius: 3),
                      ),
                      child: Slider(
                        value: controller.sliderZoomValue.value,
                        min: 1.0,
                        max: 8.0,
                        divisions: 15,
                        onChanged: (value) {
                          controller.onZoomSliderChanged(value);
                        },
                      ),
                    ),
                  )),
            ),

            // Countdown overlay
            buildCountdownOverlay(),
          ],
        );
      },
    );
  }

  // Helper method to build camera error widget
  Widget _buildCameraErrorWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.camera_alt_outlined,
            size: 80,
            color: Colors.grey,
          ),
          SizedBox(height: 16),
          Text(
            'Camera Error',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Failed to initialize camera',
            style: TextStyle(
              color: Colors.grey,
              fontSize: 14,
            ),
          ),
          SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              controller.retryCameraInitialization();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: kPrimaryColor,
              foregroundColor: Colors.black,
            ),
            child: Text('Retry'),
          ),
        ],
      ),
    );
  }

  // Helper method to build record button
  Widget _buildRecordButton() {
    return GestureDetector(
      onTap: () async {
        if (controller.isRecordingStarted.value) {
          await controller.stopRecordingForNonDual();
          controller.isRecordingStarted.value = false;
        } else {
          if (await PermissionsService().hasCameraPermission()) {
            controller.startCountdown();
            controller.isRecordingStarted.value = true;
          } else {
            await PermissionsService().requestCameraPermission(
              onPermissionGranted: () {
                printLogs("Camera permission granted");
              },
              onPermissionDenied: () {
                printLogs("Camera permission denied");
                CustomSnackbar.showSnackbar(
                    "Camera permission is required for recording, please enable it from settings");
              },
            );
          }
        }
      },
      child: Stack(
        alignment: Alignment.center,
        children: [
          Obx(() => controller.isRecording.value
              ? const SizedBox()
              : RotatedBox(
                  quarterTurns: controller.rotateValue.value.toInt(),
                  child: SizedBox(
                    height: 80.h,
                    width: 80.w,
                    child: Image.asset(kAppLogo, height: 100.h, width: 100.w),
                  ),
                )),
          Obx(
            () => controller.isRecording.value
                ? RotatedBox(
                    quarterTurns: controller.rotateValue.value.toInt(),
                    child: CountDownWidget(controller: controller))
                : SizedBox(
                    height: 100.h,
                    width: 100.w,
                    child: Image.asset(kRecordingCircle,
                        height: 100.h, width: 100.w),
                  ),
          ),
        ],
      ),
    );
  }

  Stack cameraBuildDual() {
    return Stack(
      children: [
        SizedBox(
            height: Get.height,
            width: Get.width,
            child: CameraPreview(controller.backCameraController.value!)),
        Obx(() => Positioned(
              top: 60.h,
              left: 240.w,
              right: 0.w,
              child: SizedBox(
                height: 200.h,
                width: 200.w,
                child: CameraPreview(controller.frontCameraController.value!),
              ),
            )),
        Positioned(
          bottom: 18.h,
          right: 50.w,
          left: 50.w,
          child: GestureDetector(
            onTap: () {
              if (controller.isRecordingStarted.value) {
                controller.stopRecordingForDual();
                controller.isRecordingStarted.value = false;
              } else {
                controller.startRecordingForDual();
                controller.isRecordingStarted.value = true;
              }
            },
            child: Obx(
              () => controller.isRecording.value
                  ? CountDownWidget(controller: controller)
                  : SizedBox(
                      height: 100.h,
                      width: 100.w,
                      child: Image.asset(kRecordingCircle,
                          height: 100.h, width: 100.w),
                    ),
            ),
          ),
        ),
        Obx(() => Visibility(
              visible: controller.isRecording.value,
              child: Positioned(
                bottom: 45.h,
                left: 80.w,
                child: SizedBox(
                  height: 35.h,
                  width: 35.w,
                  child: Image.asset(kLockIcon),
                ),
              ),
            )),
      ],
    );
  }

  Widget buildCountdownOverlay() {
    return Obx(() {
      if (controller.isCountingDown.value) {
        return Container(
          width: double.infinity,
          height: double.infinity,
          color: Colors.black.withOpacity(0.5),
          child: Center(
            child: Text(
              "${controller.countdownValue.value}",
              style: TextStyle(
                fontSize: 80,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        );
      } else {
        return const SizedBox.shrink();
      }
    });
  }
}
