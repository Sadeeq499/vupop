import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:native_device_orientation/native_device_orientation.dart';
import 'package:socials_app/models/highlight_reel_model.dart';
import 'package:socials_app/services/custom_snackbar.dart';
import 'package:socials_app/services/session_services.dart';
import 'package:socials_app/utils/app_colors.dart';
import 'package:socials_app/utils/app_images.dart';
import 'package:socials_app/utils/app_styles.dart';
import 'package:socials_app/views/screens/edit_profile/controller/edit_profile_controller.dart';
import 'package:socials_app/views/screens/profile/components/count_down.dart';
import 'package:video_player/video_player.dart';

class EditFavoritePost extends StatelessWidget {
  const EditFavoritePost({
    super.key,
    required this.controller,
  });

  final EditProfileController controller;

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => WillPopScope(
        onWillPop: () async {
          await controller.resetRecording();
          controller.clearUploadedData();
          controller.videoController.value?.dispose();
          controller.videoController.value = null;
          return true;
        },
        child: ModalProgressHUD(
            inAsyncCall: controller.isAddingFav.value,
            child: Container(
              child: NativeDeviceOrientationReader(
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
                  return Obx(
                    () => controller.videoController.value == null ? _recordingView() : _buildVideoPlayer(),
                  );
                },
              ),
            )),
      ),
    );
  }

  Widget _buildVideoPlayer() {
    return Stack(
      children: [
        Center(
          child: GestureDetector(
            onTap: () {
              if (controller.videoController.value!.value.isPlaying) {
                controller.videoController.value!.pause();
              } else {
                controller.videoController.value!.play();
              }
            },
            child: Center(
              child: FittedBox(
                fit: BoxFit.contain,
                child: Stack(
                  children: [
                    Obx(() => (controller.videoController.value?.value.isInitialized == true)
                        ? Container(
                            height: controller.videoController.value!.value.size.height,
                            width: controller.videoController.value!.value.size.width,
                            decoration: BoxDecoration(
                              border: Border.all(color: kPrimaryColor),
                            ),
                            child: AspectRatio(
                              aspectRatio: controller.videoController.value!.value.aspectRatio,
                              child: VideoPlayer(controller.videoController.value!),
                            ),
                          )
                        : CircularProgressIndicator()),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      left: 0,
                      child: Obx(
                        () => Visibility(
                          visible: controller.videoController.value?.value.isInitialized == true,
                          child: Center(
                            child: Container(
                              width: 100.w,
                              height: 70.h,
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
                                    height: 40.h,
                                    width: 50.w,
                                    child: Column(
                                      children: [
                                        Center(
                                          child: Image.asset(
                                            kICsoundicon,
                                            scale: 2.0,
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
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        Positioned(
          top: 15.h,
          right: 15.w,
          child: InkWell(
            onTap: () async {
              controller.clearUploadedData();
              controller.videoController.value?.dispose();
              controller.videoController.value = null;
              controller.videoController.refresh();
            },
            child: Image.asset(kCloseIcon, width: 32.w, height: 32.h),
          ),
        ),
        Positioned(
          bottom: 0.h,
          right: 10.w,
          child: Obx(() => Visibility(
                visible: controller.videoController.value != null,
                child: ElevatedButton(
                  onPressed: () {
                    Get.back();
                    controller.addFav(
                      Reel(
                          visibility: [],
                          id: "${DateTime.now()}",
                          userId: SessionService().user?.id ?? '',
                          caption: "Fav",
                          video: "",
                          thumbnail: "",
                          date: DateTime.now(),
                          version: 1),
                      videoPath: controller.videoPath.value,
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: kPrimaryColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: Text(
                    'Add to Favorite',
                    style: AppStyles.labelTextStyle().copyWith(
                      color: kBlackColor,
                      fontSize: 16.sp,
                    ),
                  ),
                ),
              )),
        ),
      ],
    );
  }

  _recordingView() {
    return SizedBox(
      height: Get.height,
      width: Get.width,
      child: Center(child: liveCameraPreView),
    );
  }

  Widget get liveCameraPreView {
    return Stack(
      children: [
        Obx(() => controller.cameraController.value == null
            ? Center(child: const CircularProgressIndicator())
            : RotatedBox(quarterTurns: controller.isLandScape.value ? 1 : 0, child: CameraPreview(controller.cameraController.value!))),
        Positioned(
          top: 15.h,
          right: 15.w,
          child: InkWell(
            onTap: () async {
              await controller.resetRecording();
              controller.clearUploadedData();
              Get.back();
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
              if (controller.isRecording.value) {
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
                          onFinished: () async {
                            CustomSnackbar.showSnackbar('Recording finished');
                            await controller.stopRecording();
                            controller.isRecording.value = false;
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
    );
  }
}

// ElevatedButton(
//                 onPressed: () {
//                   Get.back();
//                   controller.addFav(
//                     Reel(
//                         visibility: [],
//                         id: "${DateTime.now()}",
//                         userId: SessionService().user?.id ?? '',
//                         caption: "Fav",
//                         video: "",
//                         thumbnail: "",
//                         date: DateTime.now(),
//                         version: 1),
//                     videoPath: controller.videoPath.value,
//                   );
//                 },
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: kPrimaryColor,
//                   shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(10),
//                   ),
//                 ),
//                 child: Text(
//                   'Add to Favorite',
//                   style: AppStyles.labelTextStyle().copyWith(
//                     color: kBlackColor,
//                     fontSize: 16.sp,
//                   ),
//                 ),
//               ),
