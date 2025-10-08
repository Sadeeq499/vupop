import 'dart:async';
import 'dart:developer';
import 'dart:io';

import 'package:cached_video_player_plus/cached_video_player_plus.dart';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:socials_app/models/highlight_reel_model.dart';
import 'package:socials_app/models/post_models.dart';
import 'package:socials_app/repositories/profile_repo.dart';
import 'package:socials_app/services/common_imagepicker.dart';
import 'package:socials_app/services/custom_snackbar.dart';
import 'package:socials_app/services/session_services.dart';
import 'package:socials_app/services/videoservices.dart';
import 'package:socials_app/utils/common_code.dart';

class CreateHighlightedPostController extends GetxController {
  GlobalKey<ScaffoldState> createHighlightedPostScaffoldKey = GlobalKey<ScaffoldState>();
  PageController pageController2 = PageController();
  RxList<CachedVideoPlayerPlus> highlightVideoControllers = <CachedVideoPlayerPlus>[].obs;
  RxList<Reel> highlightReels = <Reel>[].obs;
  TextEditingController captionController = TextEditingController();
  RxBool isVideoLoadingDetail = false.obs;
  Rxn<PostModel> postDetail = Rxn<PostModel>();
  RxBool isSound = true.obs;
  RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    getUserHighlitedReels();
  }

  @override
  void onClose() {
    super.onClose();
    disposeVideoControllerDetail();
    videoPath.value = '';
    imagePath.value = '';
    captionController.clear();
    cameraController.value?.dispose();
    highLightVideoController.value?.dispose();
    isFileSelected.value = false;
    isRecording.value = false;
    isRecordingStarted.value = false;
    isFinishedRecording.value = false;
    isButtonTapped.value = false;
    isRecordignFinished.value = false;
    isPotraitDialogShown.value = false;
    isLandScape.value = false;
    isPortrait.value = false;
    isSound.value = true;
    isLoading.value = false;
    isVideoLoadingDetail.value = false;
    postDetail.value = null;
    captionController.clear();
    videoPath.value = '';
    imagePath.value = '';
    highLightVideoController.value?.pause();
    highLightVideoController.value = null;
    resetRecording();
    clearUploadedData();
  }

  Future<void> getUserHighlitedReels() async {
    isVideoLoadingDetail.value = true;
    try {
      highlightReels.clear();
      highlightVideoControllers.clear();
      final response = await ProfileRepo().getHighlithedReels(userId: SessionService().user?.id ?? '');
      if (response.isNotEmpty) {
        highlightReels.assignAll(response);

        List<Future> futureResponses = [];
        for (var reel in highlightReels) {
          futureResponses.add(initializeReelsController(reel.video));
        }
        await Future.wait(futureResponses);
        isVideoLoadingDetail.value = false;
      }
    } catch (e, stackTrace) {}
    isVideoLoadingDetail.value = false;
  }

  Future<void> initializeReelsController(String url) async {
    try {
      highlightVideoControllers
          .add(CachedVideoPlayerPlus.networkUrl(Uri.parse(url), invalidateCacheIfOlderThan: const Duration(minutes: 30)));
      await highlightVideoControllers.last.initialize().then((_) {
        highlightVideoControllers.last.controller.setLooping(true);
        highlightVideoControllers.last.controller.setVolume(1.0);
        highlightVideoControllers.last.controller.pause();
      });
    } catch (e) {}
  }

  void disposeVideoControllerDetail() {
    for (var controller in highlightVideoControllers) {
      controller.dispose();
    }
    highlightVideoControllers.clear();
    isVideoLoadingDetail.value = false;
    postDetail.value = null;
  }

  //////TODO upload highlight
  RxBool isFileSelected = false.obs;
  RxString videoPath = ''.obs;
  RxString imagePath = ''.obs;
  Rx<CachedVideoPlayerPlus?> highLightVideoController = Rx<CachedVideoPlayerPlus?>(null);

  RxDouble minZoom = 1.0.obs;
  RxDouble maxZoom = 4.0.obs;
  RxDouble currentZoom = 1.0.obs;
  void doubleTapZoom() {
    if (cameraController.value != null) {
      if (currentZoom.value == 1.0 || currentZoom.value == 0.0) {
        cameraController.value!.setZoomLevel(2.0);
        currentZoom.value = 2.0;
      } else if (currentZoom.value == 2.0) {
        cameraController.value!.setZoomLevel(1.0);
        currentZoom.value = 1.0;
      } else {
        cameraController.value!.setZoomLevel(1.0);
        currentZoom.value = 1.0;
      }
    }
  }

  void onScaleUpdate(ScaleUpdateDetails details) {
    if (cameraController.value != null) {
      double newZoom = currentZoom.value * details.scale;
      if (newZoom < minZoom.value) {
        newZoom = minZoom.value;
      } else if (newZoom > maxZoom.value) {
        newZoom = maxZoom.value;
      }
      setZoom(newZoom);
    }
  }

  Timer? zoomTimer;
  void setZoom(double zoom) async {
    if (cameraController.value != null) {
      /// smooth zoom
      zoomTimer?.cancel();
      if (currentZoom.value < zoom) {
        currentZoom.value += 0.1;
      } else if (currentZoom.value > zoom) {
        currentZoom.value -= 0.1;
      } else {}
      cameraController.value!.setZoomLevel(currentZoom.value);
    }
  }

  /// record video
  List<CameraDescription> cameras = [];
  Rx<CameraController?> cameraController = Rx<CameraController?>(null);
  //// initilize the camera
  /// Initialize cameras
  Future<void> initializeCameras() async {
    isLoading.value = true;
    if (cameraController.value != null) {
      cameraController.value!.dispose();
      cameraController.value = null;
    }
    cameras = await availableCameras();
    if (cameras.isEmpty) {
      CustomSnackbar.showSnackbar('No cameras available');
      return;
    }
    cameraController.value = null;
    cameraController.value = CameraController(
      cameras.firstWhere((camera) => camera.lensDirection == CameraLensDirection.back),
      ResolutionPreset.ultraHigh,
    );

    try {
      // await cameraController.value?.lockCaptureOrientation(orient);
      await cameraController.value?.initialize();
      minZoom.value = await cameraController.value!.getMinZoomLevel();
      maxZoom.value = await cameraController.value!.getMaxZoomLevel();
      highLightVideoController.value?.initialize();

      cameraController.refresh();
    } catch (e) {}
    isLoading.value = false;
  }

  RxBool isLandScape = false.obs;
  RxBool isRecording = false.obs;
  RxDouble rotateValue = 0.0.obs;
  RxBool isPortrait = false.obs;
  RxBool isRecordingStarted = false.obs;
  RxBool isFinishedRecording = false.obs;
  RxBool isButtonTapped = false.obs;
  Future<void> startRecording() async {
    if (!cameraController.value!.value.isInitialized) {
      CustomSnackbar.showSnackbar('Camera is not initialized');
      return;
    }
    isRecording.value = true;
    isRecordingStarted.value = true;
    isButtonTapped.value = true;
    try {
      /// set aspect ratio
      // log("roatedt value ${rotateValue.value}");
      // if (isPortrait.value) {
      //   await cameraController.value!
      //       .lockCaptureOrientation(DeviceOrientation.portraitUp);
      //   isLandScape.value = false;
      // } else {
      //   if (rotateValue.value != 1) {
      //     log("roatedt right value ${rotateValue.value}");
      //     await cameraController.value!
      //         .lockCaptureOrientation(DeviceOrientation.landscapeRight);
      //     isLandScape.value = true;
      //   } else if (rotateValue.value != -1) {
      //     log("roatedt left value ${rotateValue.value}");
      //     await cameraController.value!
      //         .lockCaptureOrientation(DeviceOrientation.landscapeLeft);
      //     isLandScape.value = true;
      //   } else {}
      // }

      await cameraController.value?.startVideoRecording();
      isRecording.value = true;
    } catch (e) {
      CustomSnackbar.showSnackbar('Error starting recording');
    }
    isButtonTapped.value = false;
  }

  /// stop video recording
  RxBool isRecordignFinished = false.obs;
  Future<void> stopRecording() async {
    isLoading.value = true;
    isButtonTapped.value = true;
    if (cameraController.value != null) {
      final file = await cameraController.value!.stopVideoRecording();
      videoPath.value = file.path;
      cameraController.value!.unlockCaptureOrientation();
      isLandScape.value = false;
      highLightVideoController.value = CachedVideoPlayerPlus.file(File(file.path));
      await highLightVideoController.value?.initialize().then((_) {
        highLightVideoController.value?.controller.play();
        highLightVideoController.value?.controller.setLooping(true);
      });
      isRecordignFinished.value = true;
      isFileSelected.value = true;
      isRecording.value = false;
      isFinishedRecording.value = true;
      Get.back();
    }
    isLoading.value = false;
    isButtonTapped.value = false;
  }

  /// reset camera controller
  Future<void> resetRecording() async {
    isVideoLoadingDetail.value = true;
    if (cameraController.value?.value.isRecordingVideo ?? false) {
      await cameraController.value?.stopVideoRecording();
    }

    if (cameraController.value != null && cameraController.value!.value.isInitialized) {
      await cameraController.value?.unlockCaptureOrientation();
      await cameraController.value?.dispose();
    }
    if (highLightVideoController.value != null) {
      await highLightVideoController.value?.pause();
      await highLightVideoController.value?.dispose();
    }
    isVideoLoadingDetail.value = false;
    cameraController.value = null;
    highLightVideoController.value = null;
    isRecording.value = false;
    isRecordingStarted.value = false;
    isRecordignFinished.value = false;
    isFinishedRecording.value = false;
    isFileSelected.value = false;
    isButtonTapped.value = false;
  }

  /// pick video
  Future<void> pickVideo() async {
    try {
      imagePath.value = '';
      highLightVideoController.value?.pause();
      highLightVideoController.value = null;
      videoPath.value = '';
      final video = await CommonServices().videoPicker();
      if (video != null) {
        videoPath.value = video;
        isFileSelected.value = true;
        highLightVideoController.value = CachedVideoPlayerPlus.file(File(video));
        await highLightVideoController.value?.initialize();
        highLightVideoController.value?.controller.setLooping(true);
        highLightVideoController.value?.controller.setVolume(1.0);
        highLightVideoController.value?.controller.play();
        highLightVideoController.refresh();
      }
    } catch (e) {
      CustomSnackbar.showSnackbar("Error while picking video, try again");
      printLogs("================Catch Exception pickVideo $e");
    }
  }

  /// pick image
  Future<void> pickImage() async {
    try {
      videoPath.value = '';
      highLightVideoController.value = null;
      imagePath.value = '';
      final image = await CommonServices().imagePicker(ImageSource.gallery);
      if (image != null) {
        imagePath.value = image;
        isFileSelected.value = true;
      }
    } catch (e) {
      CustomSnackbar.showSnackbar("Error while picking image, try again");
      printLogs("================Catch Exception pickImage $e");
    }
  }

  TextEditingController caption = TextEditingController();

  RxBool isPotraitDialogShown = false.obs;

  //// upload highlight
  RxBool isUploading = false.obs;
  Future<bool> uploadHighlight() async {
    if (captionController.text.isEmpty) {
      CustomSnackbar.showSnackbar('Please enter caption');
      return false;
    }
    if (!isFileSelected.value) {
      CustomSnackbar.showSnackbar('Please select image or video');
      return false;
    }
    try {
      isVideoLoadingDetail.value = true;
      isUploading.value = true;
      String filePath = '', thumbnailPath = '';
      if (imagePath.value.isNotEmpty) {
        filePath = imagePath.value;
        thumbnailPath = imagePath.value;
      } else if (videoPath.value.isNotEmpty) {
        filePath = videoPath.value;
        final data = await VideoServices().getThumbnailData(videoPath.value);
        final file = await CommonCode().generateFile(data!, 'thumbnail.jpg');
        if (!isSound.value) {
          await VideoServices().muteVideo(videoPath.value);
        }
        thumbnailPath = file.path;
      }
      final response = await ProfileRepo().createHighlithedReel(
          file: filePath,
          caption: captionController.text,
          thumbnail: thumbnailPath,
          visibilityList: SessionService().userDetail?.followers ?? [],
          userId: SessionService().user?.id ?? '');
      if (response != null) {
        captionController.clear();
        videoPath.value = '';
        imagePath.value = '';
        highLightVideoController.value = null;
        isFileSelected.value = false;

        isVideoLoadingDetail.value = false;
        await getUserHighlitedReels();
        isUploading.value = false;
        // Get.back();
        await highLightVideoController.value?.pause();
        await highLightVideoController.value?.dispose();
        highLightVideoController.value = null;
        await cameraController.value?.dispose();
        cameraController.value = null;

        CustomSnackbar.showSnackbar('Highlight uploaded successfully');
        return true;
      } else {
        CustomSnackbar.showSnackbar('Error in uploading highlight');
      }
      isVideoLoadingDetail.value = false;
      isUploading.value = false;
    } catch (e) {
      CustomSnackbar.showSnackbar('Error in uploading highlight $e');
    }
    isVideoLoadingDetail.value = false;
    isUploading.value = false;
    return false;
  }

  /// clear uploaded data
  void clearUploadedData() {
    captionController.clear();
    videoPath.value = '';
    imagePath.value = '';
    highLightVideoController.value = null;
    isFileSelected.value = false;
    isRecordignFinished.value = false;
  }

  //// update the highlight
  Future<void> updateHighlight(String id) async {
    try {
      isVideoLoadingDetail.value = true;
      final resp = await ProfileRepo().updateHighlithedReel(reelId: id, caption: caption.text);
      if (resp) {
        Reel reel = highlightReels.firstWhere((element) => element.id == id);
        Reel updatedReel = Reel(
          visibility: reel.visibility,
          id: reel.id,
          video: reel.video,
          caption: caption.text,
          thumbnail: reel.thumbnail,
          userId: reel.userId,
          date: reel.date,
          version: reel.version,
        );
        highlightReels[highlightReels.indexWhere((element) => element.id == id)] = updatedReel;

        // await getUserHighlitedReels();
        CustomSnackbar.showSnackbar("Highlight Updated Successfully");
      }
    } catch (e) {
      log("error updating: $e");
    }
    isVideoLoadingDetail.value = false;
  }

  Future<void> deleteHighlight(String id) async {
    try {
      isVideoLoadingDetail.value = true;
      final resp = await ProfileRepo().deleteHighlight(id);
      if (resp) {
        highlightVideoControllers
            .removeWhere((controller) => controller.dataSource == highlightReels.firstWhere((element) => element.id == id).video);
        highlightReels.removeWhere((element) => element.id == id);
        CustomSnackbar.showSnackbar("Highlight Deleted Successfully");
      }
    } catch (e) {
      log("error deleting: $e");
      CustomSnackbar.showSnackbar("Error in deleting highlight");
    }
    isVideoLoadingDetail.value = false;
  }

  void muteVideo() {
    isSound.value = !isSound.value;
    highLightVideoController.value?.setVolume(isSound.value ? 1.0 : 0.0);
  }
}
