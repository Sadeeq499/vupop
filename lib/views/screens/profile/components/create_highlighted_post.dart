import 'dart:async';
import 'dart:io';

import 'package:cached_video_player_plus/cached_video_player_plus.dart';
import 'package:video_player/video_player.dart';
import 'package:camera/camera.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:native_device_orientation/native_device_orientation.dart';
import 'package:socials_app/models/highlight_reel_model.dart';
import 'package:socials_app/services/custom_snackbar.dart';
import 'package:socials_app/utils/app_colors.dart';
import 'package:socials_app/utils/app_images.dart';
import 'package:socials_app/utils/app_styles.dart';
import 'package:socials_app/views/custom_widgets/custom_button.dart';
import 'package:socials_app/views/custom_widgets/custom_scaffold.dart';
import 'package:socials_app/views/screens/profile/components/count_down.dart';
import 'package:socials_app/views/screens/profile/controller/create_highlight_controller.dart';

import '../../../../utils/common_code.dart';

class CreateHighlightedPost extends GetView<CreateHighlightedPostController> {
  const CreateHighlightedPost({super.key});

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        controller.resetRecording();
        controller.clearUploadedData();
        return true;
      },
      child: Obx(
        () => ModalProgressHUD(
          inAsyncCall: controller.isVideoLoadingDetail.value,
          progressIndicator: SizedBox(),
          child: CustomScaffold(
            className: 'CreateHighlightedPost',
            screenName: 'Highlighted Post',
            scaffoldKey: controller.createHighlightedPostScaffoldKey,
            isBackIcon: true,
            bottomNavigationBar: Obx(
              () => Visibility(
                visible: controller.isFileSelected.value,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: CustomButton(
                    width: Get.width,
                    height: 50.h,
                    title: 'Upload Post',
                    onPressed: () async {
                      await controller.highLightVideoController.value?.setVolume(0.0);
                      await controller.highLightVideoController.value?.pause();
                      await controller.uploadHighlight().then((value) async {
                        if (value) {
                          Get.back();
                          // await controller.resetRecording();
                        }
                      });
                    },
                  ),
                ),
              ),
            ),
            body: Obx(
              () => controller.isVideoLoadingDetail.value
                  ? const Center(child: CircularProgressIndicator())
                  : controller.isUploading.value
                      ? const Center(child: CircularProgressIndicator())
                      : SizedBox(
                          height: Get.height,
                          width: Get.width,
                          child: PageView.builder(
                            itemCount: 6,
                            controller: controller.pageController2,
                            scrollBehavior: const MaterialScrollBehavior(),
                            scrollDirection: Axis.horizontal,
                            itemBuilder: (context, index) {
                              final isOdd = (index % 2 == 0);

                              if (index < controller.highlightReels.length) {
                                return SizedBox(
                                  height: Get.height,
                                  width: Get.width,
                                  child: SingleChildScrollView(
                                    child: Container(
                                      height: Get.height * 0.85,
                                      padding: const EdgeInsets.all(8.0),
                                      child: Column(
                                        mainAxisSize: MainAxisSize.max,
                                        children: [
                                          if (isOdd) ...[
                                            _buildCaption(controller.highlightReels[index], context),
                                            SizedBox(height: 20.h),
                                            Expanded(
                                                child: (controller.highlightReels[index].video.contains(".jpg?") ||
                                                        controller.highlightReels[index].video.contains(".jpeg?") ||
                                                        controller.highlightReels[index].video.contains(".png?"))
                                                    ? _buildImageViewer(controller.highlightReels[index].video)
                                                    : _buildVideoPlayer(controller.highlightVideoControllers[index])),
                                          ] else ...[
                                            (controller.highlightReels[index].video.contains(".jpg?") ||
                                                    controller.highlightReels[index].video.contains(".jpeg?") ||
                                                    controller.highlightReels[index].video.contains(".png?"))
                                                ? _buildImageViewer(controller.highlightReels[index].video)
                                                : _buildVideoPlayer(controller.highlightVideoControllers[index]),
                                            // SizedBox(height: 20.h),
                                            Expanded(child: _buildCaption(controller.highlightReels[index], context)),
                                          ]
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                              } else {
                                return _noVideoFound(isOdd);
                              }
                            },
                          ),
                        ),
            ),
          ),
        ),
      ),
    );
  }

  _noVideoFound(bool isOdd) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: SingleChildScrollView(
        child: Column(
          children: [
            if (isOdd) ...[
              _captionField(),
              SizedBox(height: 20.h),
              _roundBorder(),
            ] else ...[
              _roundBorder(),
              SizedBox(height: 20.h),
              _captionField(),
            ],
          ],
        ),
      ),
    );
  }

  Container _roundBorder() {
    return Container(
      height: Get.height * 0.7,
      width: Get.width * 0.9,
      decoration: BoxDecoration(
        // color: kPrimaryColor,
        borderRadius: BorderRadius.circular(10),
      ),
      child: roundedRectBorderWidget,
    );
  }

  TextField _captionField() {
    return TextField(
      controller: controller.captionController,
      decoration: InputDecoration(
        enabledBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: kPrimaryColor),
        ),
        hintText: 'Enter the caption for the post.',
        hintStyle: AppStyles.labelTextStyle().copyWith(
          color: Colors.white.withOpacity(0.6),
          fontSize: 12.sp,
        ),
        focusedBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: kPrimaryColor),
        ),
        fillColor: Colors.black,
        filled: true,
      ),
      style: TextStyle(
        color: kPrimaryColor,
        fontSize: 16.sp,
      ),
    );
  }

  Widget get liveCameraPreView {
    return Obx(() => controller.cameraController.value == null
        ? const CircularProgressIndicator()
        : controller.isUploading.value
            ? const CircularProgressIndicator()
            : RotatedBox(quarterTurns: controller.isLandScape.value ? 1 : 0, child: CameraPreview(controller.cameraController.value!)));
  }

  Widget get roundedRectBorderWidget {
    return DottedBorder(
      options: RoundedRectDottedBorderOptions(
        color: kPrimaryColor,
        radius: const Radius.circular(12),
        padding: const EdgeInsets.all(6),
      ),
      child: Obx(
        () => ClipRRect(
          borderRadius: const BorderRadius.all(Radius.circular(12)),
          child: controller.isFileSelected.value
              ? Center(
                  child: Stack(
                    children: [
                      controller.imagePath.value.isNotEmpty
                          ? FittedBox(
                              fit: BoxFit.contain,
                              child: Image.file(File(controller.imagePath.value)),
                            )
                          : FittedBox(
                              fit: BoxFit.contain,
                              child: Obx(
                                () => GestureDetector(
                                  onTap: () {
                                    if (controller.highLightVideoController.value!.value.isPlaying) {
                                      controller.highLightVideoController.value?.pause();
                                    } else {
                                      controller.highLightVideoController.value?.play();
                                    }
                                  },
                                  child: SizedBox(
                                    width: controller.highLightVideoController.value!.value.size.width,
                                    height: controller.highLightVideoController.value!.value.size.height,
                                    child: AspectRatio(
                                      aspectRatio: controller.highLightVideoController.value!.value.aspectRatio,
                                      child: CachedVideoPlayerPlus(controller.highLightVideoController.value!),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                      Positioned(
                        top: 10.h,
                        right: 10.w,
                        child: InkWell(
                          onTap: () async {
                            await controller.resetRecording();
                            controller.clearUploadedData();
                          },
                          child: Image.asset(kCloseIcon, width: 32.w, height: 32.h),
                        ),
                      ),
                      if (controller.imagePath.value.isEmpty)
                        Positioned(
                          bottom: 0,
                          right: 0,
                          left: 0,
                          child: Center(
                            child: Container(
                              width: 100.w,
                              height: 55.h,
                              decoration: ShapeDecoration(
                                color: kBlackColor.withOpacity(0.5),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                              ),
                              child: InkWell(
                                onTap: () {
                                  controller.muteVideo();
                                },
                                child: Obx(
                                  () => SizedBox(
                                    height: 10.h,
                                    width: 50.w,
                                    child: Column(
                                      children: [
                                        Center(
                                          child: Image.asset(
                                            kICsoundicon,
                                            scale: 3.0,
                                            color: controller.isSound.value ? kPrimaryColor : kWhiteColor,
                                          ),
                                        ),
                                        // const Spacer(),
                                        Text(
                                          "Sound",
                                          textAlign: TextAlign.center,
                                          style: GoogleFonts.leagueSpartan(
                                              color: controller.isSound.value ? kPrimaryColor : kWhiteColor,
                                              fontSize: 13.sp,
                                              fontWeight: FontWeight.w600),
                                        )
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                )
              : GestureDetector(
                  onTap: () {
                    showModalBottomSheet(
                      context: Get.context!,
                      backgroundColor: kGreyContainerColor,
                      builder: (context) {
                        return SizedBox(
                          // height: 150.h,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              ListTile(
                                title: const Text('Record Video', style: TextStyle(color: Colors.white, fontSize: 16)),
                                leading: Icon(Icons.videocam_rounded, color: kPrimaryColor.withOpacity(0.8)),
                                onTap: () async {
                                  Get.back();
                                  await controller.initializeCameras().then((a) async {
                                    await isPotraitShowPopup();
                                  });
                                },
                              ),
                              ListTile(
                                title: Text(
                                  'Select Video',
                                  style: AppStyles.labelTextStyle().copyWith(
                                    color: Colors.white,
                                    fontSize: 16,
                                  ),
                                ),
                                leading: Icon(
                                  Icons.video_collection,
                                  color: kPrimaryColor.withOpacity(0.8),
                                ),
                                onTap: () {
                                  controller.pickVideo();
                                  Get.back();
                                },
                              ),
                              ListTile(
                                title: Text(
                                  'Select Image',
                                  style: AppStyles.labelTextStyle().copyWith(
                                    color: Colors.white,
                                    fontSize: 16,
                                  ),
                                ),
                                leading: Icon(
                                  Icons.image,
                                  color: kPrimaryColor.withOpacity(0.8),
                                ),
                                onTap: () {
                                  controller.pickImage();
                                  Get.back();
                                },
                              ),
                            ],
                          ),
                        );
                      },
                    );
                  },
                  child: const Center(
                    child: Icon(Icons.add, color: kPrimaryColor),
                  ),
                ),
        ),
      ),
    );
  }

  _recordingView() {
    return NativeDeviceOrientationReader(
      useSensor: true,
      builder: (context) {
        final orientation = NativeDeviceOrientationReader.orientation(context);
        if (!controller.isRecordingStarted.value) {
          if (orientation == NativeDeviceOrientation.landscapeLeft) {
            controller.rotateValue.value = 1;
            // if (controller.isFinishedRecording.isFalse) {
            controller.isPortrait.value = false;
            // }
          } else if (orientation == NativeDeviceOrientation.landscapeRight) {
            controller.rotateValue.value = -1;
            // if (controller.isFinishedRecording.isFalse) {
            controller.isPortrait.value = false;
            // }
          } else {
            controller.rotateValue.value = 0;

            if (controller.isFinishedRecording.isFalse) {
              controller.isPortrait.value = true;
            }
          }
        }

        return SizedBox(
          height: Get.height,
          width: Get.width,
          child: Stack(
            children: [
              liveCameraPreView,
              Positioned(
                top: 15.h,
                right: 15.w,
                child: InkWell(
                  onTap: () async {
                    Get.back();
                    await controller.resetRecording();
                    controller.clearUploadedData();
                  },
                  child: Image.asset(kCloseIcon, width: 32.w, height: 32.h),
                ),
              ),
              Positioned(
                bottom: 18.h,
                right: 50.w,
                left: 50.w,
                child: GestureDetector(
                  onTap: () async {
                    if (controller.cameraController.value?.value.isRecordingVideo == true) {
                      await controller.stopRecording();
                      controller.isRecording.value = false;
                    } else {
                      await controller.startRecording();
                      controller.isRecording.value = true;
                    }
                  },
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Obx(
                        () => controller.isRecording.value
                            ? const SizedBox()
                            : RotatedBox(
                                quarterTurns: controller.rotateValue.value.toInt(),
                                child: SizedBox(
                                  height: 80.h,
                                  width: 80.w,
                                  child: Image.asset(kAppLogo, height: 100.h, width: 100.w),
                                ),
                              ),
                      ),
                      Obx(
                        () => controller.isRecording.value
                            ? CountDownWidget(
                                key: UniqueKey(),
                                onFinished: () {
                                  CustomSnackbar.showSnackbar('Recording finished');
                                  controller.stopRecording();
                                },
                              )
                            : SizedBox(
                                height: 100.h,
                                width: 100.w,
                                child: Image.asset(kRecordingCircle, height: 100.h, width: 100.w),
                              ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // Helper methods to build the caption, video player, and edit button
  Widget _buildCaption(Reel reel, context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Align(alignment: Alignment.centerLeft, child: _buildEditButton(reel, context)),
        // SizedBox(height: 10.h),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 10.w),
          child: Text(
            reel.caption,
            maxLines: 3,
            textAlign: TextAlign.justify,
            style: AppStyles.labelTextStyle().copyWith(
              fontSize: 17.sp,
              color: kPrimaryColor,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildVideoPlayer(CachedVideoPlayerPlus videoCont) {
    printLogs('==============videoCont.controller.value.size.heigh ${videoCont.controller.value.size.height}');
    printLogs('==============videoCont.controller.value.aspectRatio, ${videoCont.controller.value.aspectRatio}');
    return Center(
      child: GestureDetector(
        onTap: () {
          if (videoCont.controller.value.isPlaying) {
            videoCont.controller.pause();
          } else {
            videoCont.controller.play();
          }
        },
        child: Center(
          child: Container(
            // height: Get.height * 0.75,
            width: videoCont.controller.value.size.width,
            decoration: BoxDecoration(
              border: Border.all(color: kPrimaryColor),
            ),
            child: AspectRatio(
              aspectRatio: videoCont.controller.value.aspectRatio,
              child: VideoPlayer(videoCont.controller),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildImageViewer(String imageUrl) {
    // printLogs('==============videoCont.value.size.heigh ${videoCont.value.size.height}');
    // printLogs('==============videoCont.value.aspectRatio, ${videoCont.value.aspectRatio}');
    return Center(
      child: Center(
          child: Container(
        // height: Get.height * 0.75,
        width: Get.width,
        decoration: BoxDecoration(
          border: Border.all(color: kPrimaryColor),
        ),
        child: FittedBox(fit: BoxFit.contain, child: Image.network(imageUrl)),
      )),
    );
  }

  Widget _buildEditButton(reel, context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        IconButton(
            onPressed: () {
              showModalBottomSheet(
                  context: context,
                  backgroundColor: kGreyContainerColor,
                  builder: (_) {
                    return Container(
                      // height: 150.h,
                      padding: const EdgeInsets.all(10),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Row(
                            children: [
                              Text(
                                'Are you sure you want to delete this Highlight?',
                                style: AppStyles.labelTextStyle().copyWith(
                                  color: kPrimaryColor,
                                  fontSize: 18.sp,
                                ),
                              ),
                              const Spacer(),
                              IconButton(
                                onPressed: () {
                                  Get.back();
                                },
                                icon: const Icon(
                                  Icons.close,
                                  color: kPrimaryColor,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 10.h),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              ElevatedButton(
                                onPressed: () {
                                  Get.back();
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: kPrimaryColor,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                                child: Text(
                                  'Cancel',
                                  style: AppStyles.labelTextStyle().copyWith(
                                    color: kBlackColor,
                                    fontSize: 16.sp,
                                  ),
                                ),
                              ),
                              SizedBox(width: 10.w),
                              ElevatedButton(
                                onPressed: () {
                                  Get.back();
                                  controller.deleteHighlight(reel.id);
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: kPrimaryColor,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                                child: Text(
                                  'Delete',
                                  style: AppStyles.labelTextStyle().copyWith(
                                    color: kBlackColor,
                                    fontSize: 16.sp,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  });
            },
            icon: const Icon(Icons.delete, color: kYouTubeTileColor)),
        GestureDetector(
          onTap: () {
            controller.caption.text = reel.caption;
            showModalBottomSheet(
              context: context,
              backgroundColor: kGreyContainerColor,
              builder: (_) {
                return _buildEditModal(reel);
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
              'Edit',
              style: AppStyles.labelTextStyle().copyWith(
                color: kBlackColor,
                fontSize: 16.sp,
              ),
            ),
          ),
        ),
      ],
    );
  }

// Modal sheet for editing caption
  Widget _buildEditModal(Reel reel) {
    return Container(
      height: 300.h,
      width: Get.width,
      padding: const EdgeInsets.all(10).copyWith(top: 20.h),
      child: Column(
        children: [
          Row(
            children: [
              SizedBox(width: 10.w),
              Text(
                'Update the Caption',
                maxLines: 3,
                textAlign: TextAlign.justify,
                style: AppStyles.labelTextStyle().copyWith(fontSize: 20.sp, fontWeight: FontWeight.bold, color: kPrimaryColor),
              ),
              const Spacer(),
              IconButton(
                onPressed: () {
                  Get.back();
                },
                icon: const Icon(
                  Icons.close,
                  color: kPrimaryColor,
                ),
              ),
            ],
          ),
          SizedBox(height: 20.h),
          TextField(
            maxLines: 3,
            controller: controller.caption,
            decoration: InputDecoration(
              enabledBorder: const UnderlineInputBorder(
                borderSide: BorderSide(color: kPrimaryColor),
              ),
              hintText: 'Write Your Caption',
              hintStyle: AppStyles.labelTextStyle().copyWith(
                color: Colors.white.withOpacity(0.6),
                fontSize: 12.sp,
              ),
              focusedBorder: const UnderlineInputBorder(
                borderSide: BorderSide(color: kPrimaryColor),
              ),
              fillColor: Colors.black,
              filled: true,
            ),
            style: TextStyle(
              color: kPrimaryColor,
              fontSize: 16.sp,
            ),
          ),
          SizedBox(height: 20.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              ElevatedButton(
                onPressed: () {
                  Get.back();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: kPrimaryColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: Text(
                  'Cancel',
                  style: AppStyles.labelTextStyle().copyWith(
                    color: kBlackColor,
                    fontSize: 16.sp,
                  ),
                ),
              ),
              SizedBox(width: 10.w),
              ElevatedButton(
                onPressed: () async {
                  Get.back();
                  await controller.updateHighlight(reel.id);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: kPrimaryColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: Text(
                  'Update',
                  style: AppStyles.labelTextStyle().copyWith(
                    color: kBlackColor,
                    fontSize: 16.sp,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> isPotraitShowPopup() async {
    await Get.dialog(
      barrierColor: kBlackColor.withOpacity(0.5),
      AlertDialog(
        backgroundColor: kBlackColor.withOpacity(0.8),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(
              kAppLogo,
              height: 100,
              width: 100,
            ),
            Text(
              'Which orientation do you want to record in?',
              style: AppStyles.labelTextStyle(),
            ),
          ],
        ),
        actions: [
          TextButton(
            child: const Text('Portrait'),
            onPressed: () async {
              Get.back();
              controller.isPortrait.value = true;
              controller.isLandScape.value = false;
              await controller.cameraController.value!.unlockCaptureOrientation();
              controller.cameraController.value!.lockCaptureOrientation(DeviceOrientation.portraitUp);
              controller.isPotraitDialogShown.value = false;
              await showModalBottomSheet(
                  context: Get.context!,
                  isDismissible: false,
                  isScrollControlled: true,
                  backgroundColor: kBackgroundColor,
                  builder: (context) {
                    return FractionallySizedBox(
                      heightFactor: 0.9,
                      child: _recordingView(),
                    );
                  });
            },
          ),
          TextButton(
            child: const Text('Landscape'),
            onPressed: () async {
              Get.back();

              controller.isPortrait.value = false;
              controller.isLandScape.value = true;
              await controller.cameraController.value!.unlockCaptureOrientation();
              controller.cameraController.value!.lockCaptureOrientation(DeviceOrientation.landscapeLeft);
              controller.isPotraitDialogShown.value = false;
              await showModalBottomSheet(
                  context: Get.context!,
                  isDismissible: false,
                  isScrollControlled: true,
                  backgroundColor: kBackgroundColor,
                  builder: (context) {
                    return FractionallySizedBox(
                      heightFactor: 0.9,
                      child: _recordingView(),
                    );
                  });
            },
          ),
        ],
      ),
    );
  }
}
