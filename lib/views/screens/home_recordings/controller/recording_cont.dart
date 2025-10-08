import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:cached_video_player_plus/cached_video_player_plus.dart';
import 'package:camera/camera.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:mime/mime.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:socials_app/models/post_response_model.dart';
import 'package:socials_app/models/recordings_models/mention_model.dart';
import 'package:socials_app/models/tending_hashtag_model.dart';
import 'package:socials_app/repositories/post_repo.dart';
import 'package:socials_app/services/custom_snackbar.dart';
import 'package:socials_app/services/geo_services.dart';
import 'package:socials_app/services/notification_sevices.dart';
import 'package:socials_app/services/permission_service.dart';
import 'package:socials_app/services/session_services.dart';
import 'package:socials_app/services/sharedprefrence_service.dart';
import 'package:socials_app/services/videoservices.dart';
import 'package:socials_app/utils/app_colors.dart';
import 'package:socials_app/utils/app_images.dart';
import 'package:socials_app/utils/app_strings.dart';
import 'package:socials_app/utils/app_styles.dart';
import 'package:socials_app/utils/common_code.dart';
import 'package:socials_app/views/screens/bottom/controller/bottom_bar_controller.dart';
import 'package:socials_app/views/screens/profile/controller/profile_controller.dart';
import 'package:socials_app/views/screens/profile/screen/profile_screen.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;
import 'package:socket_io_client/socket_io_client.dart';
import 'package:super_tooltip/super_tooltip.dart';
import 'package:video_trimmer/video_trimmer.dart';

import '../../../../main.dart';
import '../../../../models/editors_model.dart';
import '../../../../services/common_imagepicker.dart';
import '../../../../services/endpoints.dart';
import '../components/quality_rules_bottom_sheet.dart';

class RecordingController extends GetxController {
  RxBool isLoading = false.obs;
  GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  GlobalKey<ScaffoldState> scaffoldKeyMention = GlobalKey<ScaffoldState>();
  GlobalKey<ScaffoldState> scaffoldKeyPost = GlobalKey<ScaffoldState>();
  List<CameraDescription> cameras = [];
  Rx<CameraController?> cameraController = Rx<CameraController?>(null);
  RxBool isFinishedRecording = false.obs;
  RxBool isRecording = false.obs;
  RxBool isRecordingContinue = false.obs;
  RxList<String> recordedFiles = <String>[].obs;
  RxBool isDualCamera = false.obs;
  RxBool isRecordingStarted = false.obs;
  Rx<DateTime> lastSwitchTime = DateTime.now().obs;
  RxDouble lattitude = 0.0.obs;
  RxDouble longitude = 0.0.obs;
  ////.........Variables after recording Finished/////......
  RxBool isSound = true.obs;
  RxBool isFacecam = false.obs;
  RxBool isMention = false.obs;
  RxBool isTags = false.obs;
  RxBool isLockedIconTapped = false.obs;
  Rx<CachedVideoPlayerPlus?> videoPlayerController = Rx<CachedVideoPlayerPlus?>(null);
  Rx<File?> outPutFile = Rx<File?>(null);
  RxBool isKeyboardTapped = false.obs;
  TextEditingController tecHashTag = TextEditingController(), tecMentions = TextEditingController();

  ////.........END Variables after recording Finished/////......
  ///
  ///......... Variables for Switching Camera /////......
  RxDouble progress = 0.0.obs;
  RxBool isCombining = false.obs;
  RxBool isPopupShown = false.obs;
  RxBool isFirstPopupShown = false.obs;
  RxBool isFileSelected = false.obs;
  ////.........END Variables for Switching Camera /////......
  ///
  ///........ Vatiabls for DualCamera supported /////......
  RxBool isDualRecording = false.obs;
  Rx<CameraController?> frontCameraController = Rx<CameraController?>(null);
  Rx<CameraController?> backCameraController = Rx<CameraController?>(null);
  RxBool isCameraFirstTimeInit = true.obs;
  RxBool isFaceCam = false.obs;
  RxBool isPortrait = true.obs;
  NotificationService notificationService = NotificationService();

  SuperTooltipController tooltipControllerMentions = SuperTooltipController();
  SuperTooltipController tooltipControllerTags = SuperTooltipController();
  SuperTooltipController tooltipControllerLocation = SuperTooltipController();

  RxInt currentLensDirection = 0.obs;
  RxInt countdownValue = 3.obs;
  RxBool isCountingDown = false.obs;
  Timer? countdownTimer;

  RxBool isCameraError = false.obs;
  bool _isDisposing = false;

  DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
  // Add this method to handle the countdown
  void startCountdown() {
    isCountingDown.value = true;
    countdownValue.value = 3;

    countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (countdownValue.value > 1) {
        countdownValue.value--;
      } else {
        // Countdown finished, start recording
        timer.cancel();
        isCountingDown.value = false;

        // Call the appropriate recording method based on your camera setup
        if (isDualCamera.value) {
          // Call your dual camera recording method here
        } else {
          startRecordingForNonDual();
        }
      }
    });
  }

  /// fn to initialize cameras for dual camera
  Future<void> initializeCamerasForDual() async {
    cameras = await availableCameras();
    if (cameras.isEmpty) {
      CustomSnackbar.showSnackbar('No cameras available');
      return;
    }

    frontCameraController.value = CameraController(
      cameras.firstWhere((camera) => camera.lensDirection == CameraLensDirection.front),
      kDebugMode && Platform.isAndroid
          ? ResolutionPreset.max
          : kDebugMode && Platform.isIOS
              ? ResolutionPreset.ultraHigh
              : Platform.isAndroid && memoryInfo != null && memoryInfo!.totalMem != null && memoryInfo!.totalMem! <= 4
                  ? ResolutionPreset.max
                  : ResolutionPreset.ultraHigh,
    );

    backCameraController.value = CameraController(
      cameras.firstWhere((camera) => camera.lensDirection == CameraLensDirection.back),
      kDebugMode && Platform.isAndroid
          ? ResolutionPreset.max
          : kDebugMode && Platform.isIOS
              ? ResolutionPreset.ultraHigh
              : Platform.isAndroid && memoryInfo != null && memoryInfo!.totalMem != null && memoryInfo!.totalMem! <= 4
                  ? ResolutionPreset.max
                  : ResolutionPreset.ultraHigh,
    );

    try {
      await frontCameraController.value?.initialize();
      await backCameraController.value?.initialize();
    } catch (e) {}
  }

  /// fn to start recording for dual camera
  Future<void> startRecordingForDual() async {
    if (!frontCameraController.value!.value.isInitialized || !backCameraController.value!.value.isInitialized) {
      CustomSnackbar.showSnackbar('Camera is not initialized');
      return;
    }
    isDualRecording.value = true;
    try {
      isRecordingStarted.value = true;
      await frontCameraController.value!.startVideoRecording(onAvailable: (image) {});

      await backCameraController.value!.startVideoRecording(onAvailable: (image) {});
    } catch (e) {
      CustomSnackbar.showSnackbar('Error starting recording');
    }
  }

  /// fn to stop recording for dual camera
  Future<void> stopRecordingForDual() async {
    try {
      isLoading.value = true;
      if (frontCameraController.value != null && backCameraController.value != null) {
        final frontFile = await frontCameraController.value!.stopVideoRecording();
        final backFile = await backCameraController.value!.stopVideoRecording();
        File frontTempFile = File(frontFile.path);
        File backTempFile = File(backFile.path);
        recordedFiles.add(frontTempFile.path);
        recordedFiles.add(backTempFile.path);
        await Future.delayed(const Duration(seconds: 1));
        final outputPath = await VideoServices().getOutputPath();

        isCombining.value = true;

        ///after removing ffmpeg
        if (outputPath != null) {
          videoPlayerController.value = CachedVideoPlayerPlus.file(File(outputPath));
          videoPlayerController.value!.initialize().then((_) {
            // Apply current sound settings after initialization
            videoPlayerController.value!.controller.setVolume(isSound.value ? 1.0 : 0.0);
            videoPlayerController.value!.controller.play();
            videoPlayerController.value!.controller.setLooping(true);
            isCombining.value = false;
          });
          outPutFile.value = File(outputPath);
        }

        ///before
        /*await VideoServices().mergeVideos(
          videoPaths: recordedFiles,
          outputPath: outputPath!,
          onProgress: (pro) {
            progress.value = pro;
          },
          onMergeComplete: (p0) {
            videoPlayerController.value = CachedVideoPlayerPlus.file(File(outputPath));
            videoPlayerController.value!.initialize().then((_) {
              videoPlayerController.value!.controller.play();
              videoPlayerController.value!.controller.setLooping(true);
              isCombining.value = false;
            });
            outPutFile.value = File(outputPath);
          },
        );*/
      } else {}
      isDualRecording.value = false;
      isFinishedRecording.value = true;
      isLoading.value = false;
    } catch (e) {
      CustomSnackbar.showSnackbar('Error stopping recording');
    }
    isLoading.value = false;
  }

  ////........END Vatiabls for DualCamera supported /////......

  @override
  void onInit() {
    super.onInit();
    trimmer = Trimmer().obs;
    printLogs('==========calling oninit');
  }

  firstInit({bool isFromBottomBar = true}) {
    if (!isFromBottomBar) {
      startInPortraitMode();
    }
    if (isFileSelected.isFalse) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _checkAndShowPopup();
      });
      initalization(isFromOnInit: true);
      startCameraTimer();
    } else {
      pickVideoUpdated();
    }
    getActiveEditors();
    Future.delayed(const Duration(seconds: 0), () async {
      try {
        // Initialize the socket connection
        PostSocketService.instance.initializeSocket(kSocketPostURL, queryParams: {});
        // PostSocketService.instance.initializeSocket("https://staging-content.vupop.io/", queryParams: {});
        // PostSocketService.instance.initializeSocket("https://content.vupop.io/", queryParams: {});
        setupSocketListeners();
        // Initialize the socket connection for Notifications
        NotificationSocketService.instance.initializeSocket(kSocketNotificationURL, queryParams: {});
        // NotificationSocketService.instance.initializeSocket("https://staging-backend-notifications.vupop.io", queryParams: {});
        // NotificationSocketService.instance.initializeSocket("https://backend-notifications.vupop.io", queryParams: {});
        setupNotificationSocketListeners();
      } catch (error, stackTrace) {
        log("Error in onInit: $error");
        log("StackTrace: $stackTrace");
      }
    });
  }

  RxDouble rotateValue = 0.0.obs;

  void initalization({bool isFromOnInit = false}) async {
    // isLoading.value = true;

    if (Platform.isIOS) {
      await PermissionsService().requestStoragePermission(
        onPermissionGranted: () {
          printLogs("Permission Granted");
        },
        onPermissionDenied: () => printLogs("initalization : NAN Permission for Storage"),
      );
    } else {
      AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
      if ((Platform.isAndroid && androidInfo.version.sdkInt > 32)) {
        await VideoServices.requestPhotoVideoPermission();
      } else if (!(await PermissionsService().hasStoragePermission())) {
        await PermissionsService().requestStoragePermission(
          onPermissionGranted: () {
            printLogs("Permission Granted");
          },
          onPermissionDenied: () => printLogs("initalization : NAN Permission for Storage"),
        );
      }
    }

    await PermissionsService().requestCameraPermission(
      onPermissionGranted: () {
        printLogs("Camera permission granted");
      },
      onPermissionDenied: () {
        printLogs("Camera permission denied");
        CustomSnackbar.showSnackbar("Camera permission is required for recording");
      },
    );

    // await VideoServices.requestCameraPermission();

    // isDualCamera.value = await VideoServices.isDualCameraAvailable();
    isDualCamera.value = false;
    if (isDualCamera.value) {
      await initializeCamerasForDual();
      if (!isFromOnInit &&
          isPotraitDialogShown.value == false &&
          (isFirstPopupShown.isTrue || Get.find<BottomBarController>().selectedIndex.value != 0)) {
        // if(SessionService().isUserLoggedIn){
        Platform.isIOS ? isPotraitShowPopupIOS() : isPotraitShowPopupAndroid();
        // }
      }
    } else {
      // await initializeCamerasForNonDual();
      if (!isFromOnInit &&
          isPotraitDialogShown.value == false &&
          (isFirstPopupShown.isTrue || Get.find<BottomBarController>().selectedIndex.value != 0)) {
        // await Future.delayed(const Duration(milliseconds: 500));
        // isLoading.value = false;
        // if(SessionService().isUserLoggedIn){
        // Platform.isIOS ? isPotraitShowPopupIOS() : isPotraitShowPopupAndroid();

        if (isLandScape.isTrue) {
          startCountdown();
        } else {
          startCountdown();
        }
        // }
      }
    }
    // isLoading.value = false;
    getLocation();
  }

  /// pick video
  Future<void> pickVideo() async {
    try {
      isLoading.value = true;
      AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
      if (Platform.isAndroid && androidInfo.version.sdkInt > 32) {
        await VideoServices.requestPhotoVideoPermission();
      } else if (!(await PermissionsService().hasStoragePermission())) {
        await PermissionsService().requestStoragePermission(
          onPermissionGranted: () {
            printLogs("Permission Granted");
          },
          onPermissionDenied: () => printLogs("NAN Permission for Storage"),
        );
      }
      final video = await CommonServices().videoPicker();
      if (video != null) {
        isSelectingVideo.value = true;
        trimmer = Trimmer().obs;
        videoPlayerController.value = CachedVideoPlayerPlus.file(
          File(video),
        );
        // Wait for initialization to complete before proceeding
        await videoPlayerController.value!.initialize();

        // Apply current sound settings immediately after initialization
        await videoPlayerController.value!.controller.setVolume(isSound.value ? 1.0 : 0.0);
        printLogs('===========Initial volume set to: ${isSound.value ? 1.0 : 0.0}');

        videoPlayerController.value!.controller.play();
        videoPlayerController.value!.controller.setLooping(true);
        isCombining.value = false;
        outPutFile.value = File(video);
        isDualRecording.value = false;
        isFinishedRecording.value = true;
        isLoading.value = false;
        getLocation();
        print('===========video loaded from assets==============');
        await Future.delayed(const Duration(milliseconds: 100));
        await loadVideo(filePath: video);
        // Force UI update after initialization
        videoPlayerController.value = videoPlayerController.value; // Reassign to trigger Obx
        update(); // Notify GetBuilder
      } else {
        isSelectingVideo.value = false;
        isLoading.value = false;
      }
    } catch (e) {
      isSelectingVideo.value = false;
      isLoading.value = false;
      CustomSnackbar.showSnackbar("Error while picking video, try again");
      printLogs("================Catch Exception pickVideo $e");
    }
  }

  RxDouble minZoom = 1.0.obs;
  RxDouble maxZoom = 4.0.obs;
  RxDouble currentZoom = 1.0.obs;
  Timer? zoomTimer;
  RxDouble baseZoom = 1.0.obs; // Add this new variable

  void setZoom(double zoom) async {
    if (cameraController.value != null) {
      /// smooth zoom
      zoomTimer?.cancel();
      if (currentZoom.value < zoom) {
        currentZoom.value += 0.1;
      } else if (currentZoom.value > zoom) {
        currentZoom.value -= 0.1;
      } else {}
      onZoomSliderChanged(currentZoom.value);
      // cameraController.value!.setZoomLevel(currentZoom.value);
    }
  }

  // Replace your existing onScaleStart method:
  onScaleStart(ScaleStartDetails details) {
    baseZoom.value = currentZoom.value; // Capture current zoom level
    zoomTimer?.cancel(); // Cancel any ongoing slider animations
  }

// Replace your existing onScaleUpdate method:
  void onScaleUpdate(ScaleUpdateDetails details) {
    if (cameraController.value != null) {
      // Calculate new zoom based on the initial zoom and scale factor
      double newZoom = baseZoom.value * details.scale;

      // Clamp within limits
      if (newZoom < minZoom.value) {
        newZoom = minZoom.value;
      } else if (newZoom > maxZoom.value) {
        newZoom = maxZoom.value;
      }

      // Apply zoom directly without animation for smooth gesture response
      currentZoom.value = newZoom;
      sliderZoomValue.value = newZoom; // Update slider to match gesture
      cameraController.value!.setZoomLevel(newZoom);
    }
  }

  void onScaleUpdateold(ScaleUpdateDetails details) {
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

  /// Initialize cameras
  Future<void> initializeCamerasForNonDual() async {
    if (_isDisposing) return;

    printLogs('=====Starting camera initialization=====');
    isLoading.value = true;
    isCameraError.value = false;

    try {
      // Check permissions first
      if (!await PermissionsService().hasCameraPermission()) {
        bool granted = false;
        await PermissionsService().requestCameraPermission(
          onPermissionGranted: () => granted = true,
          onPermissionDenied: () => granted = false,
        );
        if (!granted) throw Exception('Camera permission denied');
      }

      cameras = await availableCameras();
      if (cameras.isEmpty) throw Exception('No cameras available');

      // Dispose existing controller properly
      await _disposeSingleCameraController();
      await Future.delayed(Duration(milliseconds: 300));

      if (_isDisposing) return;

      final selectedCamera = cameras.firstWhere(
        (camera) => camera.lensDirection == (currentLensDirection.value == 1 ? CameraLensDirection.front : CameraLensDirection.back),
        orElse: () => cameras.first,
      );

      cameraController.value = CameraController(
        selectedCamera,
        kDebugMode && Platform.isAndroid
            ? ResolutionPreset.max
            : kDebugMode && Platform.isIOS
                ? ResolutionPreset.ultraHigh
                : Platform.isAndroid && memoryInfo != null && memoryInfo!.totalMem != null && memoryInfo!.totalMem! <= 4
                    ? ResolutionPreset.max
                    : ResolutionPreset.ultraHigh,
        enableAudio: true,
      );

      await cameraController.value!.initialize().timeout(
            Duration(seconds: 10),
            onTimeout: () => throw Exception('Camera initialization timeout'),
          );

      if (cameraController.value != null && cameraController.value!.value.isInitialized) {
        try {
          minZoom.value = await cameraController.value!.getMinZoomLevel();
          maxZoom.value = await cameraController.value!.getMaxZoomLevel();
          currentZoom.value = 1.0;
          sliderZoomValue.value = 1.0;
        } catch (zoomError) {
          minZoom.value = 1.0;
          maxZoom.value = 4.0;
        }
        update(['camera_preview']);
      } else {
        throw Exception('Camera controller failed to initialize properly');
      }
    } catch (e) {
      printLogs('=====Camera initialization error: $e=====');
      isCameraError.value = true;
      CustomSnackbar.showSnackbar('Camera initialization failed. Please try again.');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> initializeCamerasForNonDualIOS() async {
    isLoading.value = true;
    cameras = await availableCameras();
    if (cameras.isEmpty) {
      CustomSnackbar.showSnackbar('No cameras available');
      return;
    }

    cameraController.value = CameraController(
      cameras
          .firstWhere((camera) => camera.lensDirection == (currentLensDirection.value == 1 ? CameraLensDirection.front : CameraLensDirection.back)),
      kDebugMode && Platform.isAndroid
          ? ResolutionPreset.max
          : kDebugMode && Platform.isIOS
              ? ResolutionPreset.ultraHigh
              : Platform.isAndroid && memoryInfo != null && memoryInfo!.totalMem != null && memoryInfo!.totalMem! <= 4
                  ? ResolutionPreset.max
                  : ResolutionPreset.ultraHigh,
    );

    try {
      // await cameraController.value?.lockCaptureOrientation(orient);
      await cameraController.value?.initialize();
      minZoom.value = await cameraController.value!.getMinZoomLevel();
      maxZoom.value = await cameraController.value!.getMaxZoomLevel();
      videoPlayerController.value?.initialize();
      print('============initializeCamerasForNonDual Successful');
    } catch (e) {
      print("============Camera Exception");
    }
    isLoading.value = false;
  }

  RxBool isLandScape = false.obs;
  Future<void> startRecordingForNonDual() async {
    if (!cameraController.value!.value.isInitialized) {
      CustomSnackbar.showSnackbar('Camera is not initialized');
      return;
    }
    isRecording.value = true;
    isRecordingStarted.value = true;
    isRecordingContinue.value = true;
    try {
      /// set aspect ratio
      print("roatedt value ${rotateValue.value}");
      if (isPortrait.value) {
        // await cameraController.value!
        //     .lockCaptureOrientation(DeviceOrientation.portraitUp);
        isLandScape.value = false;
      } else {
        if (rotateValue.value != 1) {
          print("roatedt right value ${rotateValue.value}");
          // await cameraController.value!
          //     .lockCaptureOrientation(DeviceOrientation.landscapeRight);
          isLandScape.value = true;
        } else if (rotateValue.value != -1) {
          print("roatedt left value ${rotateValue.value}");
          // await cameraController.value!
          //     .lockCaptureOrientation(DeviceOrientation.landscapeLeft);
          isLandScape.value = true;
        } else {}
      }

      // await cameraController.value?.lockCaptureOrientation();
      await cameraController.value?.startVideoRecording();
      // await cameraController.value?.unlockCaptureOrientation();
    } catch (e) {
      CustomSnackbar.showSnackbar('Error starting recording');
    }
  }

  Future<void> stopRecordingForNonDual() async {
    try {
      isLoading.value = true;
      isRecordingContinue.value = false;
      if (cameraController.value != null) {
        final file = await cameraController.value!.stopVideoRecording();
        cameraController.value!.unlockCaptureOrientation();
        isLandScape.value = false;
        File tempFile = File(file.path);
        recordedFiles.add(tempFile.path);
        await Future.delayed(const Duration(seconds: 1));

        ///before
        // final outputPath = await VideoServices().getOutputPath();
        ///after removing ffmpeg
        final outputPath = tempFile.path;

        isCombining.value = true;

        printLogs('==========outputPath $outputPath');

        ///after removing ffmpeg
        if (outputPath != null) {
          File videoFile = File(outputPath);
          if (!videoFile.existsSync()) {
            printLogs('Error: Video file does not exist at path: $outputPath');
            return;
          }
          progress.value = 1;
          videoPlayerController.value = CachedVideoPlayerPlus.file(File(outputPath));
          printLogs('==========outputPath 2 $outputPath');
          videoPlayerController.value!.initialize().then((_) {
            printLogs('==========outputPath init $outputPath');
            // Apply current sound settings after initialization
            videoPlayerController.value!.controller.setVolume(isSound.value ? 1.0 : 0.0);
            videoPlayerController.value!.controller.play();
            videoPlayerController.value!.controller.setLooping(true);
            isCombining.value = false;
          });
          printLogs('==========outputPath after init $outputPath');
          outPutFile.value = File(outputPath);
          // VideoServices().deleteFile(file.path);
        }

        ///before
        /*await VideoServices().mergeVideos(
          videoPaths: recordedFiles,
          outputPath: outputPath!,
          onProgress: (pro) {
            printLogs('Merge progress: ${(pro * 100).toStringAsFixed(1)}%');
            progress.value = pro;
          },
          onMergeComplete: (p0) {
            printLogs('Merge completed: $p0');
            printLogs('Merge completed outputPath: $outputPath');
            videoPlayerController.value = CachedVideoPlayerPlus.file(File(outputPath));
            videoPlayerController.value!.initialize().then((_) {
              videoPlayerController.value!.controller.play();
              videoPlayerController.value!.controller.setLooping(true);
              isCombining.value = false;
            });
            outPutFile.value = File(outputPath);
            VideoServices().deleteFile(file.path);
          },
        );*/
      } else {}
      isRecording.value = false;
      isFinishedRecording.value = true;
      isLoading.value = false;
    } catch (e) {
      printLogs('==========Error stopping recording $e');
      CustomSnackbar.showSnackbar('Error stopping recording');
    }
    isLoading.value = false;
    isRecordingStarted.value = false;
    isRecording.value = false;
  }

  Future<void> switchCameraForNonDual() async {
    if (cameras.isEmpty) return;
    try {
      if (cameraController.value != null) {
        final file = await cameraController.value!.stopVideoRecording();
        File tempFile = File(file.path);
        recordedFiles.add(tempFile.path);
      } else {}
    } catch (e) {}
    CameraDescription newCamera =
        cameraController.value?.description == cameras.firstWhere((camera) => camera.lensDirection == CameraLensDirection.back)
            ? cameras.firstWhere((camera) => camera.lensDirection == CameraLensDirection.front)
            : cameras.firstWhere((camera) => camera.lensDirection == CameraLensDirection.back);

    currentLensDirection.value = newCamera.lensDirection == CameraLensDirection.front ? 1 : 0;
    cameraController.value = CameraController(
        newCamera,
        kDebugMode && Platform.isAndroid
            ? ResolutionPreset.max
            : kDebugMode && Platform.isIOS
                ? ResolutionPreset.ultraHigh
                : Platform.isAndroid && memoryInfo != null && memoryInfo!.totalMem != null && memoryInfo!.totalMem! <= 4
                    ? ResolutionPreset.max
                    : ResolutionPreset.ultraHigh);
    await cameraController.value?.initialize();
    if (isRecording.value) {
      await startRecordingForNonDual();
    }
    update();
  }

  void resetRecording({String isFrom = ''}) {
    printLogs('=============resetRecording called');
    isFinishedRecording.value = false;
    isFileSelected.value = false;
    isRecording.value = false;
    isCameraError.value = false;

    // Safely handle video player controller
    if (videoPlayerController.value != null) {
      try {
        videoPlayerController.value?.setLooping(false);
        videoPlayerController.value?.setVolume(0);
        videoPlayerController.value?.pause();
        // Only dispose if initialized to avoid the error
        if (videoPlayerController.value!.value.isInitialized) {
          videoPlayerController.value?.dispose();
        }
      } catch (e) {
        printLogs("Error in resetRecording video controller: $e");
      }
    }

    recordedFiles.clear();
    progress.value = 0.0;
    isSound.value = true;
    isFacecam.value = false;
    isMention.value = false;
    isTags.value = false;
    for (var element in mentionList) {
      element.isSelected = false;
    }
    selectedHashTags.clear();
    searchHashTagList.clear();
    searchMentionList.clear();
    searchMentionList.clear();
    address.value = '';
    isRecordingStarted.value = false;
    videoPlayerController.value = null;
    isRecordingContinue.value = false;

    // Safely dispose trimmer
    try {
      trimmer.value.dispose();
    } catch (e) {
      printLogs("Error disposing trimmer in reset: $e");
    }

    if (isFrom.isNotEmpty && isFrom == 'LandScape') {
      startInLandscapeMode();
    } else if (isFrom.isNotEmpty && isFrom == 'Portrait') {
      startInPortraitMode();
    } else {
      isPortrait = true.obs;
      isLandScape = false.obs;
      startInPortraitMode();
    }
  }

  /// fn to mute the video - UPDATED VERSION
  void muteVideo() async {
    printLogs("=========muteVideo called with isSound: ${isSound.value}");
    printLogs("=========videoPlayerController.value != null: ${videoPlayerController.value != null}");
    printLogs("=========isFileSelected.value: ${isFileSelected.value}");
    printLogs("=========isAudioAvailable.value: ${isAudioAvailable.value}");

    // Check if audio is available in the video
    if (!isAudioAvailable.value && cameraController.value == null) {
      printLogs("=========No audio track available in video");
      CustomSnackbar.showSnackbar('This video has no audio track');
      return;
    }

    // Toggle the sound state first
    isSound.value = !isSound.value;
    printLogs("=========New isSound value: ${isSound.value}");

    if (videoPlayerController.value != null) {
      try {
        // Check if the video player is initialized
        if (!videoPlayerController.value!.value.isInitialized) {
          printLogs("=========Video player not initialized, waiting for initialization");
          await videoPlayerController.value!.initialize();
        }

        // Check current volume before setting
        printLogs("=========Current volume: ${videoPlayerController.value!.value.volume}");

        // Set the volume
        double targetVolume = isSound.value ? 1.0 : 0.0;

        // printLogs("=========isAudioAvailable.value: ${isAudioAvailable.value}");
        // printLogs("=========targetVolume ${targetVolume}");
        if (cameraController.value == null) {
          await videoPlayerController.value!.controller.setVolume(targetVolume);
        } else {
          for (int i = 0; i < 3; i++) {
            await Future.delayed(const Duration(milliseconds: 50));
            await videoPlayerController.value!.controller.setVolume(targetVolume);
          }
        }
// Check current volume after setting
//         printLogs("=========after changing volume Current volume: ${videoPlayerController.value!.value.volume}");
        // Verify the volume was set
        await Future.delayed(const Duration(milliseconds: 100));
        // printLogs("=========Volume after setting: ${videoPlayerController.value!.value.volume}");
        // printLogs("=========Target volume was: $targetVolume");

        // Force update the UI
        update();
      } catch (e) {
        printLogs("=========Error setting volume: $e");
        // Revert the sound state if setting volume failed
        isSound.value = !isSound.value;
      }
    } else {
      printLogs("=========videoPlayerController.value is null");
      // Revert the sound state if no controller
      isSound.value = !isSound.value;
    }
  }

  /// fn to combine the videos and share
  RxString address = ''.obs;
  RxBool isVideoAvailable = false.obs;
  RxList<Map> listUploadingVideos = <Map>[].obs;
  RxBool isUploading = false.obs;
  RxList<String> uloadingProgress = <String>[].obs;
  Future<void> shareVideo() async {
    printToFirebase("Share Video button clicked");
    bool isVideoPortrait = isPortrait.value;
    // Check if the user is logged in
    if (SessionService().user == null) {
      isVideoAvailable.value = true;
      videoPlayerController.value!.controller.setVolume(0.0);
      Get.toNamed(kSignInRoute);
      return;
    }
    printLogs('inside shareVideo 1');
    isLoading.value = true;
    String userId = SessionService().user?.id ?? '';
    printLogs('inside shareVideo 2');
    printLogs('inside shareVideo isSound.value ${isSound.value} --- isFileSelected: ${isFileSelected.value}');
    if (isSound.value == false) {
      await VideoServices().muteVideo(outPutFile.value!.path);
    }
    printLogs('inside shareVideo 3 ${outPutFile.value!.path}');
    final video = Platform.isIOS
        ? await VideoServices().saveVideoForIOSTemp(videoPath: outPutFile.value!.path)
        : await VideoServices().saveVideoForAndroidTemp(videoPath: outPutFile.value!.path);

    final thumbnail = await VideoServices().getThumbnailData(outPutFile.value!.path);
    // printLogs("===========thumbnail shareVideo $thumbnail");
    final thumbnailFile = await CommonCode().generateFile(thumbnail ?? Uint8List(0), 'thumbnail_${video?.split("/").last.split(".")[0]}.jpg');
    if (isFileSelected.isTrue) {
      VideoServices().removeTempVideo(outPutFile.value!.path);
    }
    Get.back();
    //TODO: testing
    // Get.back();
    printLogs('inside shareVideo 4');
    if (address.value == '') {
      try {
        List<Placemark> placemarks = await placemarkFromCoordinates(lattitude.value, longitude.value);
        address.value = "${placemarks[0].street}, ${placemarks[0].subLocality}, ${placemarks[0].locality}, ${placemarks[0].country}";
      } catch (e) {
        address.value = '';
      }
    }
    printLogs('inside shareVideo 5');
    if (video != null) {
      printLogs('inside shareVideo 6');
      Map<String, String> fieldsMention = {};
      List<String> mentionIdsList = [];
      // List<String> mentionNamesList = [];
      for (var i = 0; i < mentionList.length; i++) {
        if (mentionList[i].isSelected) {
          fieldsMention['mentions[$i]'] = mentionList[i].userID;
          mentionIdsList.add(mentionList[i].userID);
          // mentionNamesList.add(mentionList[i].name);
        }
      }
      Map<String, String> fieldsTags = {};
      for (var i = 0; i < selectedHashTags.length; i++) {
        fieldsTags['tags[$i]'] = selectedHashTags[i];
      }
      if (address.value == '') {
        try {
          List<Placemark> placemarks = await placemarkFromCoordinates(lattitude.value, longitude.value);
          address.value = "${placemarks[0].street}, ${placemarks[0].subLocality}, ${placemarks[0].locality}, ${placemarks[0].country}";
        } catch (e) {
          address.value = '';
        }
      }
      listUploadingVideos.add({
        'userId': userId,
        'videoPath': video,
        'thumbnailFile': thumbnailFile,
        ...fieldsMention,
        ...fieldsTags,
        "location[coordinates][0]": lattitude.value.toString(),
        "location[coordinates][1]": longitude.value.toString(),
        "facecam": '$isFaceCam',
        "isPortrait": '${isVideoPortrait}',
        'area': address.value,
        'mentionIdsList': mentionIdsList,
        'lat': lattitude.value,
        'lng': longitude.value,
        'locationAdress': address.value == '' ? 'No location' : address.value,
        'recordedByVupop': !isFileSelected.value,
      });

      await SharedPrefrenceService.addToTempVideos({
        'userId': userId,
        'videoPath': video,
        'thumbnailFile': thumbnailFile,
        "mentions": fieldsMention,
        "tags": fieldsTags,
        "location[coordinates][0]": lattitude.toString(),
        "location[coordinates][1]": longitude.toString(),
        "facecam": '$isFaceCam',
        "isPortrait": '${isVideoPortrait}',
        'area': address.value,
        'mentionIdsList': mentionIdsList,
        'lat': lattitude.value,
        'lng': longitude.value,
        'locationAdress': address.value == '' ? 'No location' : address.value,
        'recordedByVupop': !isFileSelected.value,
        'videoProgress': 0,
        'status': UploadStatus.uploading.name
      });
      printLogs("Calling From uploadNextVideo UploadStatus.hold");
      SharedPrefrenceService.saveUploadStatus(video, UploadStatus.hold);
      SharedPrefrenceService.saveUploadProgress(video, 0.0);
      // resetRecording();
    } else {
      printLogs('inside shareVideo 7');
      CustomSnackbar.showSnackbar('Error Processing video');

      videoPlayerController.value?.setLooping(false);

      videoPlayerController.value!.controller.setVolume(0.0);
      videoPlayerController.value?.pause();
      isLoading.value = false;
      return;
    }
    // resetRecording();
    printLogs('inside shareVideo 8');
    resetRecording();

    ///Removed as now its showing on starting recording
    /*if (isPotraitDialogShown.value == false && (isFirstPopupShown.isTrue || Get.find<BottomBarController>().selectedIndex.value != 0)) {
      await Future.delayed(const Duration(milliseconds: 500));
      // isLoading.value = false;
      isPotraitShowPopup();
    }*/
    printLogs('inside shareVideo 9');
    // Start uploading if not already uploading
    if (!isUploading.value) {
      printLogs('inside shareVideo 10');
      _uploadNextVideo();
      // _uploadNextVideoWithSocket();
    }

    isLoading.value = false;
  }

  Future<void> _uploadNextVideo() async {
    printLogs('inside _uploadNextVideo 1');
    if (listUploadingVideos.isEmpty) {
      isUploading.value = false;
      return;
    }
    printLogs('inside _uploadNextVideo 2');

    isUploading.value = true;
    Map videoData = listUploadingVideos.first;

    try {
      printLogs('===========debugPrint creating post ');
      PostRepo()
          .createPost(
        recordedByVupop: videoData['recordedByVupop'],
        userId: videoData['userId'],
        file: File(videoData['videoPath']),
        fileType: 'file',
        locationAdress: videoData['locationAdress'],
        lat: videoData['lat'],
        lng: videoData['lng'],
        mentions: videoData.entries.where((element) => element.key.contains('mentions')).map((e) => e.value as String).toList(),
        tags: videoData.entries.where((element) => element.key.contains('tags')).map((e) => e.value as String).toList(),
        thumbnailFile: videoData['thumbnailFile'],
        isFaceCam: videoData['facecam'] == 'true',
        isPortrait: videoData['isPortrait'] == 'true',
        progress: (progress) async {
          uloadingProgress.add(progress.toString());
          Get.find<ProfileScreenController>().startTracking(videoData['videoPath'], progress);

          if (progress % 5 == 0) {
            await notificationService.showUploadNotification(
              title: 'Uploading Video',
              body: 'Uploading video to server $progress%',
              progress: progress.toInt(),
              ongoing: true,
            );
          }
        },
      )
          .then((result) async {
        if (result is PostResponseModelData && result.id != null && result.id!.isNotEmpty) {
          List<String> mentionedManagersIds = videoData["mentionIdsList"];
          for (String managerID in mentionedManagersIds) {
            sendMentionNotification(managerID: managerID);
          }

          await SharedPrefrenceService.removeTempVideo(videoData['videoPath']);
          CustomSnackbar.showSnackbar('Post Submitted Successfully');
          Get.find<ProfileScreenController>().needDataRefresh = true;
          if (isRecordingContinue.isFalse) {
            isVideoAvailable.value = false;
            isRecording.value = false;
          }
          // VideoServices().deleteFile(videoData['videoPath']);
          VideoServices().removeTempVideo(videoData['videoPath']);
          VideoServices().removeTempThumbnail(videoData['thumbnailFile'] is File ? videoData['thumbnailFile'].path : videoData['thumbnailFile']);

          ///delete video after uploading done
          VideoServices().deleteFile(videoData['videoPath']);
        } else {
          printLogs("Calling From recording cont uploadNextVideo UploadStatus.failed");
          SharedPrefrenceService.saveUploadStatus(videoData['videoPath'], UploadStatus.failed);
          SharedPrefrenceService.saveUploadProgress(videoData['videoPath'], 0.0);
          Get.find<ProfileScreenController>().startTracking(videoData['videoPath'], 0);

          CustomSnackbar.showSnackbar('Error creating post');
        }

        printLogs('========listUploadingVideos before${listUploadingVideos.length}');
        listUploadingVideos.removeAt(0);
        printLogs('========listUploadingVideos after ${listUploadingVideos.length}');

        _uploadNextVideo(); // Start the next upload
      });
    } catch (e) {
      CustomSnackbar.showSnackbar('Error creating post');

      printLogs("Calling From recording cont uploadNextVideo Catch UploadStatus.failed");
      SharedPrefrenceService.saveUploadStatus(videoData['videoPath'], UploadStatus.failed);
      SharedPrefrenceService.saveUploadProgress(videoData['videoPath'], 0.0);
      Get.find<ProfileScreenController>().startTracking(videoData['videoPath'], 0);
      // listUploadingVideos.removeAt(0);
      isUploading.value = false;
    }
  }

  Future<void> _uploadNextVideoWithSocket() async {
    if (listUploadingVideos.isEmpty) {
      isUploading.value = false;
      return;
    }
    if (address.value == '') {
      try {
        List<Placemark> placemarks = await placemarkFromCoordinates(lattitude.value, longitude.value);
        address.value = "${placemarks[0].street}, ${placemarks[0].subLocality}, ${placemarks[0].locality}, ${placemarks[0].country}";
      } catch (e) {
        address.value = '';
      }
    }

    isUploading.value = true;
    Map videoData = listUploadingVideos.first;

    try {
      createPostWithSocket(
          userId: videoData['userId'],
          file: File(videoData['videoPath']),
          fileType: 'file',
          locationAdress: address.value == '' ? 'No location' : address.value,
          lat: lattitude.value,
          lng: longitude.value,
          mentions: videoData.entries.where((element) => element.key.contains('mentions')).map((e) => e.value as String).toList(),
          tags: videoData.entries.where((element) => element.key.contains('tags')).map((e) => e.value as String).toList(),
          thumbnailFile: videoData['thumbnailFile'],
          isFaceCam: videoData['facecam'] == 'true',
          isPortrait: videoData['isPortrait'] == 'true',
          progress: (progress) async {
            uloadingProgress.add(progress.toString());
            if (progress % 5 == 0) {
              await notificationService.showUploadNotification(
                title: 'Uploading Video',
                body: 'Uploading video to server $progress%',
                progress: progress.toInt(),
                ongoing: true,
              );
            }
          },
          isRecordedByVupop: true,
          videoData: videoData);
      /* .then((result) {
        if (result is PostResponseModelData && result.id != null && result.id!.isNotEmpty) {
          CustomSnackbar.showSnackbar('Post Submitted Successfully');
          isVideoAvailable.value = false;
          isRecording.value = false;
          VideoServices().removeTempVideo(videoData['videoPath']);
          SharedPrefrenceService.removeTempVideo(videoData['videoPath']);
        } else {
          CustomSnackbar.showSnackbar('Error creating post');
        }
        listUploadingVideos.removeAt(0);
        _uploadNextVideo(); // Start the next upload
      });*/
    } catch (e) {
      CustomSnackbar.showSnackbar('Error creating post');
      listUploadingVideos.removeAt(0);
    }
  }

  /// fn to get location from lat and long and adress
  Future<void> getLocation() async {
    // TODO get location
    try {
      // isLoading.value = true;
      Position position = await GeoServices.determinePosition();

      lattitude.value = position.latitude;
      longitude.value = position.longitude;

      print('===========getLocation lattitude before $lattitude');
      print('===========getLocation longitude before $longitude');

      /// Get address from lat and long
      address.value = await GeoServices.getAddress(lattitude.value, longitude.value);
      print('===========getLocation address $address');
      print('===========getLocation lattitude $lattitude');
      print('===========getLocation longitude $longitude');
      try {
        List<Placemark> placemarks = await placemarkFromCoordinates(lattitude.value, longitude.value);
        address.value = "${placemarks[0].street}, ${placemarks[0].subLocality}, ${placemarks[0].locality}, ${placemarks[0].country}";
        isLoading.value = false;
      } catch (e) {
        address.value = '';
      }

      isLoading.value = false;
    } catch (e) {
      printLogs(e.toString());
      isLoading.value = false;
    }
    isLoading.value = false;
  }

  @override
  void dispose() {
    //TODO dispose
    cameraController.value?.dispose();
    videoPlayerController.value?.dispose();
    frontCameraController.value?.dispose();
    backCameraController.value?.dispose();

    super.dispose();
  }

  getActiveEditors() async {
    List<Editor> editorList = await PostRepo().getActiveEditors();
    mentionList.clear();
    for (Editor editor in editorList) {
      mentionList.add(MentionModel(
          userID: editor.id ?? "",
          name: editor.name ?? "",
          imageUrl: editor.image ?? kProfileImage,
          isSelected: false,
          accountName: editor.name ?? ""));
    }
  }

  RxList<MentionModel> mentionList = RxList();
  void selectMention(int index) {
    isMention.value = false;
    var updatedItem = mentionList[index];
    updatedItem.isSelected = !updatedItem.isSelected;
    mentionList[index] = updatedItem;

    /// check if oneof them is true than set isMention to true
    isMention.value = mentionList.any((element) => element.isSelected);
  }

  // remove mention
  void removeMention(int index) {
    var updatedItem = mentionList[index];
    updatedItem.isSelected = false;
    mentionList[index] = updatedItem;
  }

  RxList<MentionModel> searchMentionList = <MentionModel>[].obs;
  // search in mention screen
  void searchMention(String query) {
    searchMentionList.clear();
    if (query.isEmpty) {
      searchMentionList.clear();
      return;
    }
    searchMentionList.addAll(mentionList
        .where(
            (element) => element.name.toLowerCase().contains(query.toLowerCase()) || element.accountName.toLowerCase().contains(query.toLowerCase()))
        .toList());
  }

  /// code related to tags screen
  RxList<String> hashTagList = [
    'Travel',
    'Food',
    'Science',
    'Nature',
    'Pets',
    'Comedy',
    'Books',
    'Movies',
    'TV Shows',
    'News',
    'Politics',
    'Religion',
    'History',
    'Culture',
    'Languages',
    'Travel',
    'Food',
    'Fashion',
    'Music',
  ].obs;
  RxList<String> selectedHashTags = <String>[].obs;

  RxList<String> searchHashTagList = <String>[].obs;
  // search in tags screen
  void searchHashTag(String query) {
    searchHashTagList.clear();
    if (query.isEmpty) {
      searchHashTagList.clear();
      return;
    }
    searchHashTagList.addAll(hashTagList.where((element) => element.toLowerCase().contains(query.toLowerCase())).toList());
  }

  /// share video first time
  Future<bool> videoUploadFirstTime() async {
    final userId = SessionService().user?.id ?? '';

    if (isSound.value == false) {
      await VideoServices().muteVideo(outPutFile.value!.path);
    }
    printLogs('inside videoUploadFirstTime 1 ${outPutFile.value!.path}');
    final video = Platform.isIOS
        ? await VideoServices().saveVideoForIOSTemp(videoPath: outPutFile.value!.path)
        : await VideoServices().saveVideoForAndroidTemp(videoPath: outPutFile.value!.path);

    final thumbnail = await VideoServices().getThumbnailData(video!);
    // final thumbnailFIle = await CommonCode().generateFile(thumbnail ?? Uint8List(0), 'thumbnail.jpg');
    final thumbnailFile = await CommonCode().generateFile(thumbnail ?? Uint8List(0), 'thumbnail_${video.split("/").last.split(".")[0]}.jpg');

    printLogs("===========thumbnail videoUploadFirstTime thumbnail file : $thumbnailFile");
    printLogs("===========thumbnail videoUploadFirstTime video file : $video");

    Map<String, String> fieldsMention = {};
    List<String> mentionIdsList = [];
    // List<String> mentionNamesList = [];
    for (var i = 0; i < mentionList.length; i++) {
      if (mentionList[i].isSelected) {
        fieldsMention['mentions[$i]'] = mentionList[i].userID;
        mentionIdsList.add(mentionList[i].userID);
        // mentionNamesList.add(mentionList[i].name);
      }
    }
    Map<String, String> fieldsTags = {};
    for (var i = 0; i < selectedHashTags.length; i++) {
      fieldsTags['tags[$i]'] = selectedHashTags[i];
    }
    await SharedPrefrenceService.addToTempVideos({
      'userId': userId,
      'videoPath': video,
      'thumbnailFile': thumbnailFile,
      "mentions": fieldsMention,
      "tags": fieldsTags,
      // "mentions": mentionList.where((element) => element.isSelected).map((e) => e.userID).toList(),
      // "tags": selectedHashTags.toList(),
      "location[coordinates][0]": lattitude.toString(),
      "location[coordinates][1]": longitude.toString(),
      "facecam": '$isFaceCam',
      "isPortrait": '$isPortrait',
      'area': address.value,
      'mentionIdsList': mentionList.where((element) => element.isSelected).map((e) => e.userID).toList(),
      'lat': lattitude.value,
      'lng': longitude.value,
      'locationAdress': address.value == '' ? 'No location' : address.value,
      'recordedByVupop': !isFileSelected.value,
      'videoProgress': 0,
      'status': UploadStatus.uploading.name
    });

    printLogs("Calling From recording cont firstTimeRecord UploadStatus.hold");
    SharedPrefrenceService.saveUploadStatus(video, UploadStatus.hold);
    SharedPrefrenceService.saveUploadProgress(video, 0.0);
    resetRecording();
    printLogs('=======uploading videos first time creating post');
    return true;
  }

/*  void checkAndReinitializeCamera() async {
    if (cameraController.value == null || !cameraController.value!.value.isInitialized) {
      // Camera is not initialized or needs reinitialization
      await initializeCamerasForNonDual();
    } else {}
    startCameraTimer();
  }*/

  Timer? cameraTimer;
  RxBool isCameraTimerRunning = false.obs;
  RxBool isSelectingVideo = false.obs;
  void startCameraTimer() {
    cameraTimer?.cancel();
    cameraTimer = Timer(const Duration(seconds: 40), () {
      print(
          '==================stop camera auto isRecordingStarted.value : ${isRecordingStarted.value}, isFinishedRecording.value : ${isFinishedRecording.value}, isSelectingVideo.value : ${isSelectingVideo.value}, isFileSelected.value: ${isFileSelected.value}');
      if (!isRecordingStarted.value && !isFinishedRecording.value && !isSelectingVideo.value && !isFileSelected.value) {
        stopCamera();
      } else {
        startCameraTimer();
      }
    });
  }

  Future<void> stopCamera() async {
    // print('================stopCamera Method cameraController : ${cameraController.value?.value.isInitialized}');
    // print('================stopCamera Method isCameraFirstTimeInit.value: ${isCameraFirstTimeInit.value}');
    if ((cameraController.value?.value.isInitialized ?? false) && !isFileSelected.value) {
      if (isCameraFirstTimeInit.value) {
        isCameraFirstTimeInit.value = false;
        // CustomSnackbar.showSnackbar('Camera stopped due to inactivity');
        // await cameraController.value?.dispose();
        // Get.toNamed(kSignInRoute);
        return;
      }
      await cameraController.value?.dispose();
      cameraController.value = null;
      isLoading.value = false;
      isRecordingContinue.value = false;
      if (Get.find<BottomBarController>().selectedIndex.value == 1) {
        Get.find<BottomBarController>().selectedIndex.value = 0;
        Get.find<BottomBarController>().previousSelectedIndex.value = 0;
      }
      // CustomSnackbar.showSnackbar('Camera stopped due to inactivity');
    }
  }

  void toggleOrientation() async {
    if (cameraController.value != null) {
      isPortrait.value = !isPortrait.value;
    }
  }

  void _checkAndShowPopup() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool isPopupAlreadyShown = prefs.getBool('isPopupShown') ?? false;

    if (!isPopupAlreadyShown) {
      isPopupShown.value = true;
      isFirstPopupShown.value = true;
      await prefs.setBool('isPopupShown', true);
      // Show popup using Get.dialog for simplicity
      Get.dialog(
        barrierColor: kBlackColor.withOpacity(0.5),
        AlertDialog(
          backgroundColor: kBlackColor.withOpacity(0.8),
          content: SizedBox(
            width: 300.w,
            height: 250.h,
            child: Column(
              children: [
                Image.asset(
                  kAppLogo,
                  height: 100,
                  width: 100,
                ),
                Text(
                  'Welcome to Vupop',
                  style: AppStyles.labelTextStyle(),
                ),
                SizedBox(height: 10.h),
                Text(
                  'Record and share your moments with the world press the record button to start recording',
                  style: AppStyles.labelTextStyle().copyWith(color: kPrimaryColor),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                Get.back();
              },
            ),
          ],
        ),
      );
    }
  }

  RxBool isPotraitDialogShown = false.obs;
  startInPortraitMode() async {
    await initializeCamerasForNonDual();
    print('======starting in PortraitMode');
    await Future.delayed(const Duration(milliseconds: 500));
    // resetRecording();
    isPortrait.value = true;
    isLandScape.value = false;
    await cameraController.value!.unlockCaptureOrientation();
    cameraController.value!.lockCaptureOrientation(DeviceOrientation.portraitUp);
    isPotraitDialogShown.value = false;
    rotateValue.value = 0;
    print('======starting in PortraitMode Ends');
    // startCountdown();
  }

  startInLandscapeMode() async {
    await initializeCamerasForNonDual();
    await Future.delayed(const Duration(milliseconds: 500));
    print('======starting in LandscapeMode');
    // resetRecording();
    isPortrait.value = false;
    isLandScape.value = true;
    await cameraController.value!.unlockCaptureOrientation();
    cameraController.value!.lockCaptureOrientation(DeviceOrientation.landscapeLeft);
    isPotraitDialogShown.value = false;
    rotateValue.value = 1;
    print('======starting in LandscapeMode ends');
    // startCountdown();
  }

  void isPotraitShowPopupIOS() async {
    isFirstPopupShown.value = false;
    Get.dialog(
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
            Container(
              decoration: BoxDecoration(
                color: Colors.grey[800],
                borderRadius: BorderRadius.circular(30),
              ),
              padding: const EdgeInsets.all(8),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Obx(() => ToggleOption(
                        isSelected: isPortrait.isTrue,
                        onTap: () async {
                          /*if (Get.isSnackbarOpen) {
                            Get.close(2);
                          } else {
                            Get.back();
                          }*/
                          // Get.snackbar('', '', duration: Duration.zero);
                          Get.closeAllSnackbars();
                          Get.back();
                          //CommonCode.closeDialogAndSnackbar();
                          isPortrait.value = true;
                          isLandScape.value = false;
                          await cameraController.value!.unlockCaptureOrientation();
                          cameraController.value!.lockCaptureOrientation(DeviceOrientation.portraitUp);
                          isPotraitDialogShown.value = false;
                          rotateValue.value = 0;
                          // await startRecordingForNonDual();
                          startCountdown();
                        },
                        icon: Icons.stay_current_portrait,
                        label: 'Portrait',
                        selectedColor: Colors.yellow,
                      )),
                  const SizedBox(width: 8),
                  Obx(() => ToggleOption(
                        isSelected: isLandScape.isTrue,
                        onTap: () async {
                          /*if (Get.isSnackbarOpen) {
                            Get.close(2);
                          } else {
                            Get.back();
                          }*/
                          // Get.snackbar('', '', duration: Duration.zero);
                          Get.closeAllSnackbars();
                          Get.back();
                          //CommonCode.closeDialogAndSnackbar();
                          isPortrait.value = false;
                          isLandScape.value = true;
                          await cameraController.value!.unlockCaptureOrientation();
                          cameraController.value!.lockCaptureOrientation(DeviceOrientation.landscapeLeft);
                          isPotraitDialogShown.value = false;
                          rotateValue.value = 1;
                          // await startRecordingForNonDual();
                          startCountdown();
                        },
                        icon: Icons.stay_current_landscape,
                        label: 'Landscape',
                        selectedColor: Colors.yellow,
                      )),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  void isPotraitShowPopupAndroid() async {
    isFirstPopupShown.value = false;
    Get.dialog(
      barrierColor: kBlackColor.withOpacity(0.5),
      AlertDialog(
        backgroundColor: kBlackColor.withOpacity(0.8),
        contentPadding:
            Get.mediaQuery.size.width > 360 ? EdgeInsets.only(right: 8, left: 8, bottom: 20) : EdgeInsets.only(right: 20, left: 20, bottom: 20),
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
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            Container(
              decoration: BoxDecoration(
                color: Colors.grey[800],
                borderRadius: BorderRadius.circular(30),
              ),
              padding: const EdgeInsets.all(8),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Portrait Option - Remove Expanded wrapper
                  Obx(() => Flexible(
                        child: ToggleOption(
                          isSelected: isPortrait.isTrue,
                          onTap: () async {
                            Get.closeAllSnackbars();
                            Get.back();
                            isPortrait.value = true;
                            isLandScape.value = false;
                            await cameraController.value!.unlockCaptureOrientation();
                            cameraController.value!.lockCaptureOrientation(DeviceOrientation.portraitUp);
                            isPotraitDialogShown.value = false;
                            rotateValue.value = 0;
                            startCountdown();
                          },
                          icon: Icons.stay_current_portrait,
                          label: 'Portrait',
                          selectedColor: Colors.yellow,
                        ),
                      )),
                  // SizedBox(width: Get.mediaQuery.size.width > 360 ? 8 : 4),
                  // Landscape Option - Remove Expanded wrapper
                  Flexible(
                    child: Obx(() => ToggleOption(
                          isSelected: isLandScape.isTrue,
                          onTap: () async {
                            Get.closeAllSnackbars();
                            Get.back();
                            isPortrait.value = false;
                            isLandScape.value = true;
                            await cameraController.value!.unlockCaptureOrientation();
                            cameraController.value!.lockCaptureOrientation(DeviceOrientation.landscapeLeft);
                            isPotraitDialogShown.value = false;
                            rotateValue.value = 1;
                            startCountdown();
                          },
                          icon: Icons.stay_current_landscape,
                          label: 'Landscape',
                          selectedColor: Colors.yellow,
                        )),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  RxDouble sliderZoomValue = 1.0.obs;

  void onZoomSliderChanged(double value) async {
    sliderZoomValue.value = value;
    if (cameraController.value != null) {
      // Smoothly interpolate between current and target zoom
      final double startZoom = currentZoom.value;
      final double endZoom = value;
      const int steps = 20; // Increase for smoother transition

      for (int i = 1; i <= steps; i++) {
        final double progress = i / steps;
        final double interpolatedZoom = startZoom + (endZoom - startZoom) * progress;

        await cameraController.value!.setZoomLevel(interpolatedZoom);
        await Future.delayed(Duration(milliseconds: 10)); // Adjust delay to control speed

        currentZoom.value = interpolatedZoom;
      }
    }
  }

  RxBool isSocketConnect = false.obs;
  void setupSocketListeners() {
    final socket = PostSocketService.instance.socket;

    socket?.onConnect((_) {
      isSocketConnect.value = true;
      //fetchChats();
      printLogs("=======socket connected");
    });

    socket?.onDisconnect((_) {
      isSocketConnect.value = false;
      printLogs("=======socket disconnected");
    });

    socket?.onReconnect((_) {
      printLogs("=======socket reconnected");
    });

    socket?.onError((data) {
      isSocketConnect.value = false;
      printLogs("=======socket error");
    });

    socket?.onConnectError((data) {
      isSocketConnect.value = false;
      printLogs("=======socket connect error");
    });
  }

  ///fun to create post via socket
  Future<void> createPostWithSocket({
    required String userId,
    required File file,
    List<String>? mentions,
    String fileType = 'file',
    required String locationAdress,
    required double lat,
    required double lng,
    List<String>? tags,
    required File thumbnailFile,
    required bool isFaceCam,
    required bool isPortrait,
    required bool isRecordedByVupop,
    required Map videoData,
    void Function(int)? progress,
  }) async {
    final socket = PostSocketService.instance.socket;
    if (socket == null) {
      printLogs('Socket is not initialized');
      return;
    }
    var arg1 = {
      "userId": userId,
      "location": {
        "coordinates": [lat, lng]
      },
      "mention": mentions ?? [],
      "tags": tags ?? [],
      "isPortrait": isPortrait,
      "facecam": isFaceCam,
      "recordedByVupop": isRecordedByVupop,
      "area": locationAdress
    };

    var arg2 = {
      "fieldname": fileType,
      "originalname": file.path.split("/").last,
      "encoding": await checkForFileEncoding(file: file),
      "mimetype": getMimeType(file: file) ?? "video/mp4",
      "buffer": await convertFileToBuffer(file),
      "size": await getFileSize(file)
    };

    var arg3 = {
      "fieldname": "thumbnail",
      "originalname": thumbnailFile.path.split("/").last,
      "encoding": await checkForFileEncoding(file: thumbnailFile),
      "mimetype": getMimeType(file: thumbnailFile) ?? "image/png",
      "buffer": await convertFileToBuffer(thumbnailFile),
      "size": await getFileSize(thumbnailFile)
    };

    printLogs('======arg1 $arg1');
    printLogs('======arg2 $arg2');
    printLogs('======arg3 $arg3');

    socket?.on('searchPost', (data) {
      printLogs('searchPost response: $data');
    });

    socket?.on('getPost', (data) {
      final response = data as Map<String, dynamic>;
      if (response['success'] == true) {
        printLogs('Post created successfully');
        CustomSnackbar.showSnackbar('Post Submitted Successfully');
      } else {
        printLogs('Error creating post: ${response['message']}');
      }
    });

    socket?.on('error', (data) {
      printLogs('Error: $data');
    });

    socket?.emit('sendPost', [arg1, arg2, arg3]);

    socket?.on('disconnect', (_) {
      printLogs('Socket disconnected');
    });

    socket?.on('getPost', (data) {
      final response = data as Map<String, dynamic>;
      if (response['success'] == true) {
        printLogs('Post created successfully');
        List<String> mentionedManagersIds = videoData["mentionIdsList"];
        for (String managerID in mentionedManagersIds) {
          sendMentionNotification(managerID: managerID);
        }
        CustomSnackbar.showSnackbar('Post Submitted Successfully');
      } else {
        printLogs('Error creating post: ${response['message']}');
      }
    });

    printLogs('===========Post create emitted');
    isVideoAvailable.value = false;
    isRecording.value = false;
    VideoServices().removeTempVideo(videoData['videoPath']);
    SharedPrefrenceService.removeTempVideo(videoData['videoPath']);

    listUploadingVideos.removeAt(0);
    _uploadNextVideoWithSocket();
  }

  Future<List<String>> convertFileToBuffer(File file) async {
    List<int> fileBuffer = await file.readAsBytes();
    return fileBuffer.map((b) => b.toRadixString(16).padLeft(2, '0')).toList();
  }

  Future<String> checkForFileEncoding({required File file}) async {
    List<int> fileBytes = await file.readAsBytes();
    // Try decoding with UTF-8
    try {
      String content = utf8.decode(fileBytes);
      printLogs('Encoding: UTF-8');
      return "utf8";
    } catch (e) {
      printLogs('Not UTF-8. Trying Latin1...');
      try {
        String content = latin1.decode(fileBytes);
        printLogs('Encoding: Latin1');
        return "latin1";
      } catch (e) {
        printLogs('Unknown Encoding');
        return "unknown";
      }
    }
  }

  String? getMimeType({required File file}) {
    String filePath = file.path;

    // Get MIME type
    String? mimeType = lookupMimeType(filePath);

    printLogs('MIME type: $mimeType'); // Output: video/mp4
    return mimeType;
  }

  Future<int> getFileSize(File file) async {
    int sizeInBytes = await file.length();
    printLogs('File size: $sizeInBytes bytes');
    return sizeInBytes;
  }

  RxBool isNotificationSocketConnect = false.obs;
  void setupNotificationSocketListeners() {
    final socket = NotificationSocketService.instance.socket;

    socket?.onConnect((_) {
      isNotificationSocketConnect.value = true;
      //fetchChats();
      printLogs("=======Notification socket connected");
    });

    socket?.onDisconnect((_) {
      isNotificationSocketConnect.value = false;
      printLogs("=======Notification socket disconnected");
    });

    socket?.onReconnect((_) {
      printLogs("=======Notification socket reconnected");
    });

    socket?.onError((data) {
      isNotificationSocketConnect.value = false;
      printLogs("=======Notification socket error");
    });

    socket?.onConnectError((data) {
      isNotificationSocketConnect.value = false;
      printLogs("=======Notification socket connect error");
    });
  }

  sendMentionNotification({required String managerID}) async {
    final socket = NotificationSocketService.instance.socket;
    if (socket == null) {
      printLogs('sendMentionNotification Socket is not initialized');
      return;
    }

    //Manager ID
    var arg1 = managerID;

    // user ID
    var arg2 = SessionService().user?.id;

    //Message body
    var arg3 = '${SessionService().user?.name} mentioned you in a clip';

    printLogs('======arg1 $arg1');
    printLogs('======arg2 $arg2');
    printLogs('======arg3 $arg3');

    socket?.on('managerNotification', (data) {
      printLogs('managerNotification response: $data');
    });

    socket?.on('adminNotification', (data) {
      printLogs('adminNotification response: $data');
    });

    socket.on('error', (data) {
      printLogs('Error: $data');
    });

    socket.emit('sendNotification', [arg1, arg2, arg3]);

    socket.on('disconnect', (_) {
      printLogs('Socket disconnected');
    });

    socket?.on('managerNotification', (data) {
      printLogs('After event managerNotification response: $data');
    });

    socket?.on('adminNotification', (data) {
      printLogs('After event adminNotification response: $data');
    });

    printLogs('===========Send Notification to Manager emitted');
  }

  RxList<TendingHashTagsData> trendingHashtags = RxList();
  getTendingHashTags() async {
    trendingHashtags.value = await PostRepo().getTrendingHashTags() ?? [];
  }

  //// new changes
  RxBool isAudioAvailable = false.obs;
  Future<Map<String, dynamic>> getLocalVideoDetails(String path) async {
    final mimeDetail = await VideoServices().getLocalVideoDetails(path);
    // address.value = '';
    // lattitude.value = 0.0;
    // longitude.value = 0.0;
    if (mimeDetail['latitude'] != null && mimeDetail['longitude'] != null) {
      address.value = await GeoServices.getAddress(mimeDetail['latitude'], mimeDetail['longitude']);
      lattitude.value = mimeDetail['latitude'];
      longitude.value = mimeDetail['longitude'];
    }
    printLogs('MimeDetail: $mimeDetail');
    isAudioAvailable.value = mimeDetail['hasAudio'];
    isSound.value = isAudioAvailable.value;

    // isPortrait.value = mimeDetail['orientation'] == 'Portrait';
    isPortrait.value = (trimmer.value.videoPlayerController?.value.aspectRatio ?? 1.0) < 1.0;
    /*if (mimeDetail['duration'] > 20) {
      CustomSnackbar.showSnackbar('Video duration should be less than 20 seconds, Triming video to 20 seconds');
      final value = await VideoServices().extractFirst20Seconds(path);
      if (value != null) {
        outPutFile.value = File(value);
        videoPlayerController.value = CachedVideoPlayerPlus.file(File(value));
        videoPlayerController.value!.initialize().then((_) {
          // Apply current sound settings after initialization
          videoPlayerController.value!.controller.setVolume(isSound.value ? 1.0 : 0.0);
          videoPlayerController.value!.controller.play();
          videoPlayerController.value!.controller.setLooping(true);
          isCombining.value = false;
        });
      }
      return {};
    }*/
    printLogs('Videocontroller: ${videoPlayerController.value}');
    return mimeDetail;
  }

  /// Trimmer Implementation
  Rx<Trimmer> trimmer = Trimmer().obs;
  RxDouble startValue = 0.0.obs;
  RxDouble endValue = 20.0.obs;
  RxBool isPlaying = false.obs;
  RxBool progressVisibility = false.obs;

  Future<void> loadVideo({String? filePath}) async {
    print('====== video loaded for trimming $filePath');
    try {
      print('====== load video try block');
      if (filePath != null) {
        print('====== load video path not null');
        await trimmer.value.loadVideo(videoFile: File(filePath));
        // Reinitialize videoPlayerController after trimmer loads the video
        if (videoPlayerController.value != null) {
          await videoPlayerController.value!.initialize();
          // Apply current sound settings after initialization
          await videoPlayerController.value!.controller.setVolume(isSound.value ? 1.0 : 0.0);
          videoPlayerController.value!.controller.play();
          videoPlayerController.value!.controller.setLooping(true);
        }
        trimmer.value = trimmer.value; // Retain this for trimmer state update
        print('====== load video after loading video');
        print('====== load video end');
        videoPlayerController.value = videoPlayerController.value; // Trigger Obx update
        update(); // Notify GetBuilder
        print('====== updating from inside');
      }
    } catch (e) {
      Get.snackbar("Error", "Failed to load video: $e");
    }
  }

  /// Function to trim video - UPDATED VERSION
  Future<void> trimVideo() async {
    progressVisibility.value = true;
    await trimmer.value.saveTrimmedVideo(
      startValue: startValue.value,
      endValue: endValue.value,
      onSave: (String? outputPath) async {
        if (outputPath != null) {
          outPutFile.value = File(outputPath);
          print('===========Trimmed video path ${outPutFile.value!.path}');

          // Dispose old controller first
          if (videoPlayerController.value != null) {
            await videoPlayerController.value!.dispose();
          }

          // Create new controller
          videoPlayerController.value = CachedVideoPlayerPlus.file(
            File(outputPath),
          );
          await videoPlayerController.value!.initialize();

          // Apply current sound settings immediately after initialization
          await videoPlayerController.value!.controller.setVolume(isSound.value ? 1.0 : 0.0);
          print('===========Volume set to: ${isSound.value ? 1.0 : 0.0} after trimming');

          videoPlayerController.value!.controller.play();
          videoPlayerController.value!.controller.setLooping(true);

          // Calculate and print the trimmed video duration
          final duration = endValue.value - startValue.value;
          print(
            '===========Trimmed video duration: ${duration.toStringAsFixed(2)} seconds',
          );
          isSelectingVideo.value = false;
          update();
        }
        progressVisibility.value = false;
        isSelectingVideo.value = false;
      },
    );
  }

  /// pick video
  Future<void> pickVideoUpdated() async {
    try {
      isLoading.value = true;
      if (Platform.isIOS) {
        await PermissionsService().requestStoragePermission(
          onPermissionGranted: () {
            printLogs("Permission Granted");
          },
          onPermissionDenied: () => printLogs("NAN Permission for Storage"),
        );
      } else {
        AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
        if (Platform.isAndroid && androidInfo.version.sdkInt > 32) {
          await PermissionsService.requestPhotosPermission();
        } else if (!(await PermissionsService().hasStoragePermission())) {
          await PermissionsService().requestStoragePermission(
            onPermissionGranted: () {
              printLogs("Permission Granted");
            },
            onPermissionDenied: () => printLogs("NAN Permission for Storage"),
          );
        }
      }
      final video = await CommonServices().videoPicker();
      if (video != null) {
        isSelectingVideo.value = true;
        trimmer = Trimmer().obs;

        // For gallery videos, we'll primarily use the trimmer
        // But still initialize the video player controller for fallback/compatibility
        videoPlayerController.value = CachedVideoPlayerPlus.file(
          File(video),
        );

        // Initialize but don't auto-play since trimmer will handle playback
        await videoPlayerController.value!.initialize();
        await videoPlayerController.value!.controller.setVolume(isSound.value ? 1.0 : 0.0);
        // Don't auto-play for gallery videos as trimmer will control playback
        // videoPlayerController.value!.controller.play();
        // videoPlayerController.value!.controller.setLooping(true);

        isCombining.value = false;
        outPutFile.value = File(video);
        isDualRecording.value = false;
        isFinishedRecording.value = true;
        isLoading.value = false;
        getLocation();
        print('===========video loaded from assets==============');
        await Future.delayed(const Duration(milliseconds: 100));
        await loadVideoUpdated(filePath: video);

        // Force UI update after initialization
        update();
      } else {
        isSelectingVideo.value = false;
        isLoading.value = false;
      }
    } catch (e) {
      isSelectingVideo.value = false;
      isLoading.value = false;
      CustomSnackbar.showSnackbar("Error while picking video, try again");
      printLogs("================Catch Exception pickVideo $e");
    }
  }

  Future<void> loadVideoUpdated({String? filePath}) async {
    print('====== video loaded for trimming $filePath');
    try {
      print('====== load video try block');
      if (filePath != null) {
        print('====== load video path not null');

        // Load video into trimmer
        await trimmer.value.loadVideo(videoFile: File(filePath));

        // For gallery videos, we don't need the custom video player controller
        // since the trimmer will handle video playback
        if (isFileSelected.value) {
          // Safely dispose existing video player controller if any
          if (videoPlayerController.value != null) {
            try {
              // Check if controller is initialized before disposing
              if (videoPlayerController.value!.value.isInitialized) {
                await videoPlayerController.value!.dispose();
              }
            } catch (e) {
              printLogs("Error disposing video controller: $e");
            }
            videoPlayerController.value = null;
          }
        } else {
          // For recorded videos, keep the custom video player
          if (videoPlayerController.value != null) {
            try {
              // Only initialize if not already initialized
              if (!videoPlayerController.value!.value.isInitialized) {
                await videoPlayerController.value!.initialize();
              }
              await videoPlayerController.value!.controller.setVolume(isSound.value ? 1.0 : 0.0);
              videoPlayerController.value!.controller.play();
              videoPlayerController.value!.controller.setLooping(true);
            } catch (e) {
              printLogs("Error initializing video controller: $e");
            }
          }
        }

        // Force UI update
        trimmer.value = trimmer.value;
        print('====== load video after loading video');
        print('====== load video end');
        update();
        print('====== updating from inside');
      }
    } catch (e) {
      print("=======Exception: LoadVideoUpdated $e");
      Get.snackbar("Error", "Failed to load video: $e");
    }
  }

  /// Function to trim video - UPDATED VERSION
  /// Function to trim video - UPDATED VERSION
  Future<void> trimVideoUpdated() async {
    progressVisibility.value = true;
    await trimmer.value.saveTrimmedVideo(
      startValue: startValue.value,
      endValue: endValue.value,
      onSave: (String? outputPath) async {
        if (outputPath != null) {
          outPutFile.value = File(outputPath);
          print('===========Trimmed video path ${outPutFile.value!.path}');

          // For gallery videos, update the trimmer with the new trimmed video
          if (isFileSelected.value) {
            // Safely dispose old trimmer first
            try {
              trimmer.value.dispose();
            } catch (e) {
              printLogs("Error disposing trimmer: $e");
            }

            // Create new trimmer with trimmed video
            trimmer.value = Trimmer();
            await trimmer.value.loadVideo(videoFile: File(outputPath));

            // Reset trim values for the new trimmed video
            startValue.value = 0.0;
            endValue.value = await _getVideoDuration(outputPath);
          }

          // Also update video controller for compatibility
          if (videoPlayerController.value != null) {
            try {
              // Check if controller is initialized before disposing
              if (videoPlayerController.value!.value.isInitialized) {
                await videoPlayerController.value!.dispose();
              }
            } catch (e) {
              printLogs("Error disposing video controller in trim: $e");
            }
          }

          // Create new video controller
          try {
            videoPlayerController.value = CachedVideoPlayerPlus.file(
              File(outputPath),
            );
            await videoPlayerController.value!.initialize();
            await videoPlayerController.value!.controller.setVolume(isSound.value ? 1.0 : 0.0);

            // For gallery videos, don't auto-play as trimmer controls playback
            if (!isFileSelected.value) {
              videoPlayerController.value!.controller.play();
              videoPlayerController.value!.controller.setLooping(true);
            }
          } catch (e) {
            printLogs("Error creating new video controller: $e");
          }

          // Calculate and print the trimmed video duration
          final duration = endValue.value - startValue.value;
          print(
            '===========Trimmed video duration: ${duration.toStringAsFixed(2)} seconds',
          );
          isSelectingVideo.value = false;
          update();
        }
        progressVisibility.value = false;
        isSelectingVideo.value = false;
      },
    );
  }

// Helper method to get video duration
  Future<double> _getVideoDuration(String videoPath) async {
    final controller = CachedVideoPlayerPlus.file(File(videoPath));
    await controller.initialize();
    final duration = controller.value.duration.inMilliseconds / 1000.0;
    await controller.dispose();
    return duration;
  }

  void showQualityRulesSheet() {
    Get.bottomSheet(
      QualityRulesBottomSheet(
        // Optional: put your brand/logo widget here to match the screenshot
        logo: Image.asset(kAppLogo, height: 32),
        allowedRules: const [
          'Original content that you own the rights to',
          'Clear, high-quality video and audio',
          'Properly titled and tagged clips',
          'Respectful and non-offensive material',
          'Uploaded videos needs to be a minimum of 10 seconds in length and not more than 500mb in size',
          'You can only upload or record videos up to 20 seconds long.'
        ],
        avoidRules: const [
          'Copyrighted material without permission',
          'Blurry, low-resolution videos',
          'Misleading titles or spam content',
          'Nudity, hate speech, or violent content',
        ],
        onConfirm: () {
          // initalization();
          /*Get.dialog(
            barrierColor: kBlackColor.withOpacity(0.5),
            AlertDialog(
              backgroundColor: kBlackColor.withOpacity(0.8),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'User Agreement',
                    style: AppStyles.labelTextStyle().copyWith(fontSize: 16.sp),
                  ),
                  SizedBox(height: 10.h),
                  ListTile(
                    horizontalTitleGap: 5.w,
                    leading: CircleAvatar(radius: 3.r, backgroundColor: kPrimaryColor),
                    title: Text(
                      'The uploaded video is original and not from another platform.',
                      style: AppStyles.labelTextStyle().copyWith(color: kPrimaryColor, fontSize: 14.sp),
                    ),
                  ),
                  ListTile(
                    horizontalTitleGap: 5.w,
                    leading: CircleAvatar(radius: 3.r, backgroundColor: kPrimaryColor),
                    title: Text(
                      'Altering the video or using external content violates terms.',
                      style: AppStyles.labelTextStyle().copyWith(color: kPrimaryColor, fontSize: 14.sp),
                    ),
                  ),
                  ListTile(
                    horizontalTitleGap: 5.w,
                    leading: CircleAvatar(radius: 3.r, backgroundColor: kPrimaryColor),
                    title: Text(
                      'Uploaded videos need to be a minimum of 10 seconds in length and not more than 500mb in size',
                      style: AppStyles.labelTextStyle().copyWith(color: kPrimaryColor, fontSize: 14.sp),
                    ),
                  ),
                  // ListTile(
                  //   horizontalTitleGap: 5.w,
                  //   leading: CircleAvatar(radius: 3.r, backgroundColor: kPrimaryColor),
                  //   title: Text(
                  //     'The selected file size should be less than 500MB',
                  //     style: AppStyles.labelTextStyle().copyWith(color: kPrimaryColor, fontSize: 14.sp),
                  //   ),
                  // ),
                ],
              ),
              actions: [
                TextButton(
                    onPressed: () {
                      Get.back();
                    },
                    child: Text(
                      'Cancel',
                      style: AppStyles.labelTextStyle().copyWith(color: kGreyRecentSearch, fontSize: 16.sp, fontWeight: FontWeight.w700),
                    )),
                TextButton(
                    onPressed: () {
                      Get.back();
                      Get.dialog(
                        barrierColor: kBlackColor.withOpacity(0.5),
                        AlertDialog(
                          alignment: Alignment.center,
                          actionsAlignment: MainAxisAlignment.center,
                          backgroundColor: kBlackColor.withOpacity(0.8),
                          content: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'Recording Limit',
                                style: AppStyles.labelTextStyle().copyWith(fontSize: 16.sp),
                              ),
                              SizedBox(height: 10.h),
                              Text(
                                textAlign: TextAlign.center,
                                'You can only upload or record videos up to 20 seconds long.',
                                style: AppStyles.labelTextStyle().copyWith(color: kPrimaryColor, fontSize: 14.sp),
                              ),
                            ],
                          ),
                          actions: [
                            CustomButton(
                                width: 160.w,
                                height: 30.h,
                                title: 'Select Video',
                                onPressed: () {
                                  Get.back();
                                  resetRecording();
                                  isFileSelected.value = true;
                                  pickVideo();
                                }),
                          ],
                        ),
                      );
                    },
                    child: Text(
                      'I Agree',
                      style: AppStyles.labelTextStyle().copyWith(color: kPrimaryColor, fontSize: 16.sp, fontWeight: FontWeight.w700),
                    ))
              ],
            ),
          );*/
          Get.back();
          resetRecording();
          isFileSelected.value = true;
          pickVideoUpdated();
        },
      ),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black54,
    );
  }

  ///Camera Helper methods

  Future<void> _disposeSingleCameraController() async {
    if (cameraController.value != null) {
      try {
        _isDisposing = true;
        if (cameraController.value!.value.isInitialized) {
          if (cameraController.value!.value.isRecordingVideo) {
            await cameraController.value!.stopVideoRecording();
          }
          await cameraController.value!.dispose();
        }
        cameraController.value = null;
      } catch (e) {
        printLogs('=====Error disposing camera controller: $e=====');
      } finally {
        _isDisposing = false;
      }
    }
  }

  Future<void> retryCameraInitialization() async {
    isCameraError.value = false;
    if (isDualCamera.value) {
      await initializeCamerasForDual();
    } else {
      await initializeCamerasForNonDual();
    }
  }
}

class ToggleOption extends StatelessWidget {
  const ToggleOption({
    super.key,
    required this.isSelected,
    required this.onTap,
    required this.icon,
    required this.label,
    required this.selectedColor,
  });

  final bool isSelected;
  final VoidCallback onTap;
  final IconData icon;
  final String label;
  final Color selectedColor;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: isSelected ? selectedColor : Colors.transparent,
          borderRadius: BorderRadius.circular(22),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isSelected ? Colors.black : selectedColor,
              size: 24,
            ),
            if (Platform.isIOS) ...[
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  color: isSelected ? Colors.black : selectedColor,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
            if (Platform.isAndroid && Get.mediaQuery.size.width > 360) ...[
              const SizedBox(width: 4),
              Text(
                label,
                style: TextStyle(
                  color: isSelected ? Colors.black : selectedColor,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
            if (Platform.isAndroid && Get.mediaQuery.size.width <= 360) ...[
              SizedBox(width: Get.mediaQuery.size.width > 360 ? 8 : 4),
              Flexible(
                child: AutoSizeText(
                  label,
                  style: TextStyle(
                    color: isSelected ? Colors.black : selectedColor,
                    fontSize: Get.mediaQuery.size.width > 360 ? 16 : 12,
                    fontWeight: FontWeight.w600,
                  ),
                  minFontSize: 10,
                  maxFontSize: 16,
                  overflow: TextOverflow.ellipsis,
                  wrapWords: false,
                ),
              ),
            ]
          ],
        ),
      ),
    );
  }
}

class VideoMetadata {
  final String fieldname;
  final String originalname;
  final String encoding;
  final String mimetype;
  final List<int> buffer;
  final int size;

  VideoMetadata({
    required this.fieldname,
    required this.originalname,
    required this.encoding,
    required this.mimetype,
    required this.buffer,
    required this.size,
  });

  factory VideoMetadata.fromMap(Map<String, dynamic> data) {
    return VideoMetadata(
      fieldname: data['fieldname'],
      originalname: data['originalname'],
      encoding: data['encoding'],
      mimetype: data['mimetype'],
      buffer: List<int>.from(data['buffer']),
      size: data['size'],
    );
  }
}

class PostSocketService {
  static final PostSocketService _instance = PostSocketService._internal();

  io.Socket? socket;

  PostSocketService._internal();

  static PostSocketService get instance => _instance;

  void initializeSocket(String uri, {required Map<dynamic, dynamic> queryParams}) {
    socket = io.io(uri, io.OptionBuilder().setTransports(['websocket']).disableAutoConnect().build());

    socket?.connect();

    /*socket?.onConnect((_) {
      printLogs('Socket connected');
    });*/
    printLogs("Socket initialized and connected for posts");
  }

  void disconnectSocket() {
    socket?.disconnect();
    socket = null;
    if (kDebugMode) {
      printLogs("Socket disconnected");
    }
  }
}

class NotificationSocketService {
  static final NotificationSocketService _instance = NotificationSocketService._internal();

  io.Socket? socket;

  NotificationSocketService._internal();

  static NotificationSocketService get instance => _instance;

  void initializeSocket(String uri, {required Map<dynamic, dynamic> queryParams}) {
    socket = io.io(uri, io.OptionBuilder().setTransports(['websocket']).disableAutoConnect().build());

    socket?.connect();

    /*socket?.onConnect((_) {
      printLogs('Socket connected');
    });*/
    printLogs("Notification Socket initialized and connected for posts");
  }

  void disconnectSocket() {
    socket?.disconnect();
    socket = null;
    if (kDebugMode) {
      printLogs("Notification Socket disconnected");
    }
  }
}
