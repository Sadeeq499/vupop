import 'dart:io';
import 'dart:typed_data';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:socials_app/models/highlight_reel_model.dart';
import 'package:socials_app/models/passion_model.dart';
import 'package:socials_app/models/post_models.dart';
import 'package:socials_app/repositories/profile_repo.dart';
import 'package:socials_app/services/common_imagepicker.dart';
import 'package:socials_app/services/custom_snackbar.dart';
import 'package:socials_app/services/session_services.dart';
import 'package:socials_app/services/videoservices.dart';
import 'package:socials_app/utils/common_code.dart';
import 'package:socials_app/views/screens/profile/controller/profile_controller.dart';
import 'package:video_player/video_player.dart';

class EditProfileController extends GetxController {
  GlobalKey<ScaffoldState> editProfileKey = GlobalKey<ScaffoldState>();
  GlobalKey<ScaffoldState> recordKey = GlobalKey<ScaffoldState>();
  RxString addedPickedImage = ''.obs;
  // RxList favImagesSelected = [].obs;
  TextEditingController nameController = TextEditingController();
  TextEditingController aboutYouController = TextEditingController();
  RxBool isLoading = false.obs;
  ProfileScreenController profileScreenController = Get.find<ProfileScreenController>();
  RxList<String> allPostUrls = <String>[].obs;
  RxList<Uint8List> allPostThumbNails = <Uint8List>[].obs;
  RxList<String> selectedFavPost = <String>[].obs;
  RxList<Reel> favPosts = <Reel>[].obs;
  RxBool isFavLoading = false.obs;
  @override
  void onInit() {
    getUserProfileImage();
    getPassions();
    // favImagesSelected.clear();
    selectedFavPost.clear();
    allPostThumbNails.clear();
    allPostUrls.clear();
    // favImagesSelected = profileScreenController.favoritePostsThumbnails;
    allPostUrls = profileScreenController.userPosts.map((e) => e.video).toList().obs;

    /// add the userpost favorite ids to selectedFavPost
    selectedFavPost.value = profileScreenController.userData.value?.favourite ?? [];
    setTextField();
    // createThumbnail();
    // getFavPosts();
    getUserPassions();
    super.onInit();
  }

  //set textfield
  void setTextField() {
    nameController.text = profileScreenController.userData.value?.name ?? '';
    aboutYouController.text = profileScreenController.userData.value?.about ?? '';
  }

  /// fn to create thumbnail
  /// not in use
  RxBool thumbnailLoading = false.obs;
  List<PostModel> allPosts = [];
  /*Future<List<String>?> createThumbnail() async {
    thumbnailLoading.value = true;
    try {
      final resp = await PostRepo().getAllPosts(lng: 0.0, lat: 0.0);
      if (resp != null) {
        allPostUrls.clear();
        allPostUrls = resp.posts.map((e) => e.video).toList().obs;
        allPosts = resp.posts;
        thumbnailLoading.value = false;
      }
      thumbnailLoading.value = false;
      return allPostUrls;
    } catch (e) {
      CustomSnackbar.showSnackbar('Error in creating thumbnail');
    }
    thumbnailLoading.value = false;
    return null;
  }*/

  Future<void> changeImage(ImageSource source) async {
    try {
      final String? pickedImage = await CommonServices().imagePicker(source);
      if (pickedImage != null) {
        addedPickedImage.value = pickedImage;
      }
    } catch (e) {
      CustomSnackbar.showSnackbar('Error in picking image');
    }
  }

  /// update user profile
  Future<void> updateProfile() async {
    isLoading.value = true;
    try {
      // final userID = SessionService().user?.id;
      if (!CommonCode().isValidURL(addedPickedImage.value) && addedPickedImage.value != '') {
        await updateProfileImage();
      }
      bool isDataUpdated = false;
      printLogs('=========aboutYouController.text.isNotEmpty ${aboutYouController.text.isNotEmpty}');
      if (nameController.text.isNotEmpty || aboutYouController.text.isNotEmpty || selectedFavPost.isNotEmpty || userPassions.isNotEmpty) {
        isDataUpdated = await updateAboutInfo();
      }
      // profileScreenController.getData();

      if (addedPickedImage.value != SessionService().userDetail?.image ||
          nameController.text != SessionService().userDetail?.name ||
          aboutYouController.text != SessionService().userDetail?.about) {
        profileScreenController.getData(isProfileUpdated: true);
      } else {
        profileScreenController.getData(isProfileUpdated: false);
      }
      if (isDataUpdated) {
        aboutYouController.clear();
        nameController.clear();
        selectedFavPost.clear();
      }

      isLoading.value = false;

      Get.back();
      CustomSnackbar.showSnackbar('Profile updated successfully');
    } catch (e) {
      CustomSnackbar.showSnackbar('Error in updating profile');
    }
    isLoading.value = false;
  }

  /// update user profile image
  Future<void> updateProfileImage() async {
    try {
      if (addedPickedImage.value.isNotEmpty) {
        final userID = SessionService().user?.id;
        final value = await ProfileRepo().changeProfileImage(
            userId: userID ?? '', // userID,
            imagePath: addedPickedImage.value);

        if (value != null) {
          // CustomSnackbar.showSnackbar('Profile image updated successfully');
        } else {
          CustomSnackbar.showSnackbar('Error in updating profile image');
        }
      } else {
        CustomSnackbar.showSnackbar('Please select an image');
      }
    } catch (e) {
      CustomSnackbar.showSnackbar('Error in updating profile image');
    }
  }

  /// get user profile image
  Future<void> getUserProfileImage() async {
    try {
      final userID = SessionService().user?.id;
      final value = await ProfileRepo().getUserProfileImage(userId: userID ?? ''); // userID
      if (value != null) {
        addedPickedImage.value = value;
      } else {}
    } catch (e) {
      CustomSnackbar.showSnackbar('Error in getting profile image');
    }
  }

  /// update your about info and favorite
  Future<bool> updateAboutInfo() async {
    try {
      final userID = SessionService().user?.id;
      final value = await ProfileRepo().updateUserInfoFav(
          userId: userID ?? '', // userID,
          name: nameController.text,
          favorite: selectedFavPost.toList(),
          about: aboutYouController.text,
          passion: userPassions.where((element) => element.id != null).map((e) => e.id!).toList());
      if (value != null && value.success) {
        // aboutYouController.clear();
        // nameController.clear();
        // selectedFavPost.clear();
        // profileScreenController.getData();
        return true;
      } else {
        CustomSnackbar.showSnackbar('Error in updating about info');
      }
    } catch (e) {
      CustomSnackbar.showSnackbar('Error in updating about info');
    }
    return false;
  }

  /// fn for adding fav
  RxBool isAddingFav = false.obs;
  Future<void> addFav(
    Reel post, {
    required String videoPath,
  }) async {
    isAddingFav.value = true;
    try {
      final userID = SessionService().user?.id;
      final thumbnailData = await VideoServices().getThumbnailData(videoPath);
      final thumbnailFile = await CommonCode().generateFile(thumbnailData ?? Uint8List(0), 'thumbnail.jpg');
      if (!isSound.value) {
        await VideoServices().muteVideo(videoPath);
      }
      final value = await ProfileRepo().addFavClip(
        userId: userID ?? '',
        filePath: videoPath,
        visibilityList: [],
        caption: "Fav",
        thumbnail: thumbnailFile.path,
        onProgress: (int sent, int total) {},
      );
      if (value != null) {
        CustomSnackbar.showSnackbar('Added to favorite');
        // getFavPosts();
      } else {
        CustomSnackbar.showSnackbar('Error in adding to favorite');
      }
    } catch (e) {
      CustomSnackbar.showSnackbar('Error in adding to favorite');
    }
    isAddingFav.value = false;
    clearUploadedData();
    await resetRecording();
    videoController.value?.dispose();
    videoController.value = null;
    cameraController.value?.dispose();
    cameraController.value = null;
  }

  /// fn for deleting fav
  Future<void> deleteFav(String id) async {
    isAddingFav.value = true;
    try {
      final value = await ProfileRepo().deleteFavClip(reelId: id);
      if (value) {
        CustomSnackbar.showSnackbar('Deleted from favorite');
      } else {
        CustomSnackbar.showSnackbar('Error in deleting from favorite');
      }
      // getFavPosts();
    } catch (e) {
      CustomSnackbar.showSnackbar('Error in deleting from favorite');
    }
    isAddingFav.value = false;
  }

  /// fn to get fav posts
  Future<void> getFavPosts() async {
    try {
      isFavLoading.value = true;
      favPosts.clear();
      final value = await ProfileRepo().getFavClips(userId: SessionService().user?.id ?? '');
      if (value.isNotEmpty) {
        favPosts.assignAll(value);
      }
      isFavLoading.value = false;
    } catch (e) {
      CustomSnackbar.showSnackbar('Error in getting fav posts');
      isFavLoading.value = false;
    }
    isFavLoading.value = false;
  }

  RxList<Passion> passions = <Passion>[].obs;
  // RxList<Passion> selectedPassions = <Passion>[].obs;
  RxBool isPassionLoading = false.obs;
  Future<void> getPassions() async {
    isPassionLoading.value = true;
    try {
      final response = await ProfileRepo().getAllPassions();
      if (response.isNotEmpty) {
        passions.assignAll(response);
      } else {}
    } catch (e) {
      CustomSnackbar.showSnackbar("Something went wrong");
      printLogs('Error getPassions: $e');
    }
    isPassionLoading.value = false;
  }

  /// fn for getting user passions
  RxList<Passion> userPassions = <Passion>[].obs;
  Future<void> getUserPassions() async {
    try {
      isPassionLoading.value = true;
      final userID = SessionService().user?.id;
      final value = await ProfileRepo().getUserPassions(userId: userID ?? '');
      userPassions.clear();
      if (value.isNotEmpty) {
        userPassions.assignAll(value);
      }
      userPassions.refresh();
      isPassionLoading.value = false;
    } catch (e) {
      CustomSnackbar.showSnackbar('Error in getting user passions');
    }
    isPassionLoading.value = false;
  }

  void addPassion(Passion passion) {
    if (userPassions.contains(passion)) {
      userPassions.remove(passion);
    } else {
      userPassions.add(passion);
    }
    update();
  }

  void removePassion(int index) {
    userPassions.removeAt(index);
    update();
  }

  ////............code for fave video Recording and uploading............////
  List<CameraDescription> cameras = [];
  Rx<CameraController?> cameraController = Rx<CameraController?>(null);
  Rx<VideoPlayerController?> videoController = Rx<VideoPlayerController?>(null);
  RxDouble minZoom = 0.0.obs;
  RxDouble maxZoom = 0.0.obs;
  //// initilize the camera
  /// Initialize cameras
  Future<void> initializeCameras() async {
    isLoading.value = true;
    cameras = await availableCameras();
    if (cameras.isEmpty) {
      CustomSnackbar.showSnackbar('No cameras available');
      return;
    }
    cameraController.value?.dispose();
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
      videoController.value?.initialize();

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
  Future<void> startRecording() async {
    if (!cameraController.value!.value.isInitialized) {
      CustomSnackbar.showSnackbar('Camera is not initialized');
      return;
    }
    isRecording.value = true;
    isRecordingStarted.value = true;

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
  }

  /// stop video recording
  RxBool isRecordignFinished = false.obs;
  RxString videoPath = ''.obs;
  Future<void> stopRecording() async {
    isLoading.value = true;
    if (cameraController.value != null) {
      final file = await cameraController.value!.stopVideoRecording();
      videoPath.value = file.path;
      isLandScape.value = false;
      videoController.value = VideoPlayerController.file(File(videoPath.value));

      await videoController.value?.initialize().then((_) {
        videoController.value?.play();
        videoController.value?.setLooping(true);
      });
      videoController.refresh();
      isRecordignFinished.value = true;
      isRecording.value = false;
      isFinishedRecording.value = true;

      resetRecording();
      update();
    }
    isLoading.value = false;
  }

  /// reset camera controller
  Future<void> resetRecording() async {
    await cameraController.value?.unlockCaptureOrientation();
    isRecording.value = false;
    isRecordingStarted.value = false;
    isRecordignFinished.value = false;
    isFinishedRecording.value = false;
  }

  void clearUploadedData() {
    videoPath.value = '';
    isRecordignFinished.value = false;
    isFinishedRecording.value = false;
    isRecording.value = false;
    isRecordingStarted.value = false;
  }

  RxBool isPotraitDialogShown = false.obs;

  RxBool isSound = true.obs;
  void muteVideo() {
    isSound.value = !isSound.value;
    videoController.value?.setVolume(isSound.value ? 1.0 : 0.0);
  }
}
