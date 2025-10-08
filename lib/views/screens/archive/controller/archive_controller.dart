import 'dart:io';

import 'package:cached_video_player_plus/cached_video_player_plus.dart';
import 'package:card_swiper/card_swiper.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:socials_app/models/post_models.dart';
import 'package:socials_app/repositories/post_repo.dart';
import 'package:socials_app/services/custom_snackbar.dart';

import '../../../../models/usermodel.dart';
import '../../../../repositories/notification_repo.dart';
import '../../../../repositories/profile_repo.dart';
import '../../../../services/notification_sevices.dart';
import '../../../../services/session_services.dart';
import '../../../../services/videoservices.dart';
import '../../../../utils/common_code.dart';
import '../../home/controller/home_controller.dart';

class ArchiveController extends GetxController {
  GlobalKey<ScaffoldState> scaffoldKeyArchive = GlobalKey<ScaffoldState>();
  GlobalKey<ScaffoldState> scaffoldKeyFilter = GlobalKey<ScaffoldState>();
  GlobalKey<ScaffoldState> scaffoldKeySearch = GlobalKey<ScaffoldState>();
  GlobalKey<ScaffoldState> scaffoldKeySwipe = GlobalKey<ScaffoldState>();
  RxString imageUrl = ''.obs;
  Rx<UserDetailModel?> userData = Rx<UserDetailModel?>(null);
  RxList<PostModel> userPosts = <PostModel>[].obs;
  RxBool isLoading = false.obs;
  // VideoPlayerController? videoController;
  RxBool isVideoLoading = false.obs;
  RxBool isGettingPosts = false.obs;
  NotificationService notificationService = NotificationService();
  RxBool isPlaying = false.obs;
  RxBool isShowIssueButton = false.obs;
  ScrollController scrollController = ScrollController();
  @override
  void onInit() {
    getData();
    super.onInit();
    scrollController.addListener(() {
      if (scrollController.position.maxScrollExtent == scrollController.offset && hasMorePosts.isTrue) {
        loadMorePosts();
      }
    });
  }

  @override
  void onClose() {
    // videoController?.dispose();
    super.onClose();
  }

  void getData() async {
    // clear all data
    userPosts.clear();

    // favoritePostsThumbnails.clear();
    userData.value = null;
    isLoading.value = true;
    await getUserProfile();
    getUserPosts(isFirstTime: true);
    isLoading.value = false;
  }

  /// fn to get user Profile
  Future<void> getUserProfile() async {
    try {
      final userID = SessionService().user?.id;
      final email = SessionService().user?.email;

      final value = await ProfileRepo().getUserProfile(userId: userID ?? '');
      if (value != null) {
        userData.value = value;
        SessionService().userDetail = value;
        SessionService().saveUserDetails();
      } else {
        CustomSnackbar.showSnackbar('Error in getting user profile');
      }
    } catch (e) {
      CustomSnackbar.showSnackbar('Error in getting user profile');
    }
    isLoading.value = false;
  }

  /// fn to get user Posts
  RxList<RxBool> isPostDownloading = <RxBool>[].obs;
  RxList<RxInt> downloadProgress = <RxInt>[].obs;
  RxList<RxBool> reportIssueWithClip = <RxBool>[].obs;

  RxInt currentPageNum = 1.obs;
  RxInt totalPostPages = 1.obs;
  RxBool hasMorePosts = false.obs;
  RxBool isLoadingMorePosts = false.obs;

  Future<List<PostModel>?> getUserPosts({required bool isFirstTime}) async {
    try {
      if (isFirstTime) {
        isGettingPosts.value = true;
      } else {
        isLoadingMorePosts.value = true;
      }
      final userID = SessionService().user?.id;

      Map<String, dynamic> body = {
        "userId": userID,
      };
      final value = await PostRepo().getUserPosts(
        userId: userID ?? '',
        body: body,
        isArchivedPosts: true,
        pageNum: currentPageNum.value,
      );
      if (value != null) {
        totalPostPages.value = value.totalPages;

        if (isFirstTime) {
          userPosts.clear();
          userPosts.value = value.posts;
        } else {
          userPosts.addAll(value.posts);
        }

        userPosts.sort((a, b) => (b.date ?? DateTime(0)).compareTo(a.date ?? DateTime(0)));
        isGettingPosts.value = false;
        isLoadingMorePosts.value = false;
        isPostDownloading.assignAll(List.generate(userPosts.length, (index) {
          return false.obs;
        }));
        downloadProgress.assignAll(List.generate(userPosts.length, (index) {
          return 0.obs;
        }));

        reportIssueWithClip.assignAll(List.generate(userPosts.length, (index) {
          return false.obs;
        }));

        hasMorePosts.value = currentPageNum.value < totalPostPages.value;
        currentPageNum.value++;
        return userPosts;
      } else {
        CustomSnackbar.showSnackbar('Error in getting user posts');
      }
    } catch (e) {
      CustomSnackbar.showSnackbar('Error in getting user posts');
      isGettingPosts.value = false;
      isLoadingMorePosts.value = false;
    }
    isGettingPosts.value = false;
    isLoadingMorePosts.value = false;
    return null;
  }

  loadMorePosts() {
    if (hasMorePosts.isTrue) {
      getUserPosts(isFirstTime: false);
    }
  }

  var thumbnailCache = <String, Uint8List?>{}.obs;
  Future<Uint8List?> getThumbnail(String videoUrl) async {
    if (!thumbnailCache.containsKey(videoUrl)) {
      final thumbnail = await VideoServices().getThumbnailData(videoUrl);
      thumbnailCache[videoUrl] = thumbnail;
    }
    return thumbnailCache[videoUrl];
  }

/*  void initializeVideoController(String videoUrl) {
    videoController = VideoPlayerController.networkUrl(Uri.parse(videoUrl));
    videoController?.initialize().then((_) {
      videoController?.play();
      videoController?.setLooping(true);
      update();
    });
  }*/

  // RxInt downloadProgress = 0.obs;
  Future<void> saveVideoLocally(int index, {required String videoUrl}) async {
    isPostDownloading[index].value = true;
    downloadProgress[index].value = 0; // Reset progress
    CustomSnackbar.showSnackbar("Starting video download...");
    isPostDownloading.refresh();

    // Initial notification
    notificationService.showDownloadNotificationArchive(
        title: 'Downloading video', body: 'Download started', progress: 0, ongoing: true, silent: true, channelID: index);

    // Use compute to run download in separate isolate
    VideoServices().downloadVideoCallback(
        videoUrl: videoUrl,
        notificationService: notificationService,
        useCallback: true,
        onProgressCallback: (received, total) {
          // This runs on the UI thread, but is very lightweight
          final progress = (received / total * 100).toDouble();

          final progressInt = progress.round();

          // Handle notification using main isolate
          /*notificationService.showDownloadNotificationArchive(
            title: 'Downloading video',
            body: progress > 0 ? 'Downloaded ${downloadProgress[index].value}% ' : 'Downloading video',
            progress: downloadProgress[index].value,
            ongoing: true,
            silent: true,
            channelID: index);*/

          if (progressInt % 5 == 0) {
            // Update progress on UI thread via GetX
            downloadProgress[index].value = progress.round();
            if (Platform.isAndroid) {
              notificationService.showDownloadNotificationArchive(
                  title: 'Downloading video',
                  body: 'Downloaded $progressInt%',
                  progress: progressInt,
                  ongoing: progressInt < 100,
                  silent: progressInt < 100,
                  channelID: index);
            }
          }

          if (progressInt >= 100) {
            isPostDownloading[index].value = false;
            downloadProgress[index].value = 0; // Reset progress
            isPostDownloading.refresh();
            /* notificationService.showDownloadNotificationArchive(
                title: 'Download complete', body: 'Video downloaded successfully', silent: false, channelID: index, progress: 101);*/
          }
        },
        onDoneCallback: () {
          isPostDownloading[index].value = false;
          downloadProgress[index].value = 0; // Reset progress
          isPostDownloading.refresh();
          notificationService.showDownloadNotificationArchive(
              title: 'Download complete', body: 'Video downloaded successfully', silent: false, channelID: index, progress: 101);
        });
    /* .then((value) async {
      if (value) {
        CustomSnackbar.showSnackbar("Video saved successfully");
        await notificationService.showDownloadNotification(title: 'Download complete', body: 'Video downloaded successfully', silent: false);
      } else {
        CustomSnackbar.showSnackbar('Error saving the video');
        await notificationService.showDownloadNotification(
          title: 'Download Failed',
          body: 'Failed to Download the video',
          progress: 100,
        );
      }
      isPostDownloading[index].value = false;
      downloadProgress.value = 0; // Reset progress
      isPostDownloading.refresh();
    });*/
  }

  Future<void> saveVideoLocallyOld(int index, {required String videoUrl}) async {
    isPostDownloading[index].value = true;
    CustomSnackbar.showSnackbar("Saving the Video....");
    isPostDownloading.refresh();
    VideoServices()
        .downloadVideo(
      videoUrl: videoUrl,
      notificationService: notificationService,
    )
        .then((value) async {
      if (value) {
        CustomSnackbar.showSnackbar("Video is Saved");
        await notificationService.showDownloadNotification(title: 'Download complete', body: 'Video downloaded successfully', silent: false);
      } else {
        CustomSnackbar.showSnackbar('Error saving the video');
        await notificationService.showDownloadNotification(
          title: 'Download Failed',
          body: 'Failed to Download the video',
          progress: 100,
        );
      }
      isPostDownloading[index].value = false;
      isPostDownloading.refresh();
    });
  }

  ///// Swipe code /////......
  SwiperController swiperController = SwiperController();
  RxBool isRatingTapped = false.obs;
  RxDouble userRating = 0.0.obs;
  RxList<CachedVideoPlayerPlus> videoControllers = <CachedVideoPlayerPlus>[].obs;
  // RxList<VideoPlayerController> videoControllers = <VideoPlayerController>[].obs;

  Future<void> initializeAllControllers(int startIndex, int limit) async {
    isVideoLoading.value = true;

    if (startIndex < 0 || limit > userPosts.length) {
      CustomSnackbar.showSnackbar("Error: Index out of range");
      return;
    }
    for (int i = startIndex; i < startIndex + limit && i < userPosts.length; i++) {
      try {
        await initializeVideoPlayer(userPosts[i].video);
      } catch (e) {}
    }
    isVideoLoading.value = false;
  }

  Future<void> initializeVideoPlayer(String videoUrl) async {
    videoControllers.add(CachedVideoPlayerPlus.networkUrl(Uri.parse(videoUrl), invalidateCacheIfOlderThan: const Duration(minutes: 30)));
    /*videoControllers.add(VideoPlayerController.networkUrl(
      Uri.parse(videoUrl),
    ));*/
    await videoControllers.last.initialize().then((_) {
      videoControllers.last.controller.setLooping(true);
      videoControllers.last.controller.setVolume(1.0);
      videoControllers.last.controller.pause();
    });
  }

  void disposeVideoPlayer() {
    for (var controller in videoControllers) {
      controller.dispose();
    }
    videoControllers.clear();
  }

  bool isIndexOutOfRange(int index) {
    return index >= userPosts.length;
  }

  RxInt tappedPostIndex = 0.obs;
  void onTapPost(int index) {
    if (isIndexOutOfRange(index)) {
      CustomSnackbar.showSnackbar("Error: Post not found");
      return;
    } else {
      tappedPostIndex.value = index;
    }
  }

  void onIndexChanged(int index) async {
    if (index - 1 != -1) {
      await videoControllers[index - 1].pause();
    }
    if (isIndexOutOfRange(index)) {
      CustomSnackbar.showSnackbar("Error: Post not found");
      return;
    } else {
      tappedPostIndex.value = index;

      /// if videoControllers is last index then load more videos
      if (index == videoControllers.length - 1) {
        initializeAllControllers(index + 1, 3);
      }
      if (videoControllers.isNotEmpty) {
        videoControllers[index].setLooping(true);
        videoControllers[index].setVolume(1.0);
        videoControllers[index].play();
      }
    }
  }

  Future<void> updateLikeDislike({required String postId}) async {
    try {
      final userId = SessionService().user?.id ?? '';
      int postIndex = userPosts.indexWhere((element) => element.id == postId);
      HomeScreenController homeController = Get.find<HomeScreenController>();
      if (postIndex != -1) {
        if (userPosts[postIndex].likes.contains(userId)) {
          // userPosts[postIndex].likes.remove(userId);
          // userPosts[postIndex].likesCount -= 1;
          // userPosts.refresh();
          // Get.log("refresed ");
        } else {
          userPosts[postIndex].likes.add(userId);
          userPosts[postIndex].likesCount += 1;
          userPosts.refresh();
          await PostRepo().updateUserActivity(postId: postId, likes: userId);
          int index = homeController.posts.indexWhere((element) => element.id == postId);
          homeController.posts[index].likes.add(userId);
          homeController.posts[index].likesCount += 1;
        }
        homeController.posts.refresh();
      }
    } catch (e) {}
  }

  Future<void> updateShareCount({required String postId}) async {
    try {
      int postIndex = userPosts.indexWhere((element) => element.id == postId);
      HomeScreenController homeController = Get.find<HomeScreenController>();
      if (postIndex != -1) {
        userPosts[postIndex].share.add(SessionService().user?.id ?? '');
        userPosts[postIndex].sharesCount += 1;
        userPosts.refresh();
        await PostRepo().updateUserActivity(postId: postId, share: SessionService().user?.id ?? '');
        int index = homeController.posts.indexWhere((element) => element.id == postId);
        homeController.posts[index].share.add(SessionService().user?.id ?? '');
        homeController.posts[index].sharesCount += 1;
        homeController.posts.refresh();
        NotificationRepo().sendNotification(
            title: 'Post Shared', body: 'Your post has been shared by ${userData.value?.name}', userId: homeController.posts[index].userId.id);
      }
    } catch (e) {}
  }

  ////........bottom sheet code.............
  TextEditingController searchController = TextEditingController();
  RxList<UserDetailModel> viewedUsers = <UserDetailModel>[].obs;
  RxBool isViewedUsersLoading = false.obs;
  RxBool isFollowersLoading = false.obs;
  RxList<UserDetailModel> searchBottomSheetList = <UserDetailModel>[].obs;

  Future<List<UserDetailModel>> getUsersFromIds(List<String> ids) async {
    viewedUsers.clear();
    isViewedUsersLoading.value = true;
    try {
      for (var id in ids) {
        if (!viewedUsers.any((element) => element.id == id)) {
          final user = await ProfileRepo().getUserProfile(userId: id);
          if (user != null) {
            viewedUsers.add(user);
          }
        }
      }
      searchBottomSheetList.assignAll(viewedUsers);
      isViewedUsersLoading.value = false;
    } catch (e) {
      isViewedUsersLoading.value = false;
    }
    return viewedUsers;
  }

  void filterBottomSheetSearch(String value) {
    if (value.isEmpty) {
      searchBottomSheetList.assignAll(viewedUsers);
    } else {
      searchBottomSheetList.assignAll(viewedUsers.where((element) => element.name.toLowerCase().contains(value.toLowerCase())).toList());
    }
  }

  Future<void> updateFollowStatus({
    required String followedUserId,
    required int index,
  }) async {
    final currentUserId = SessionService().user?.id;
    if (currentUserId == null) {
      CustomSnackbar.showSnackbar('Error: User not found');
      return;
    }

    isFollowersLoading.value = true;

    try {
      if (userData.value?.following.contains(followedUserId) ?? false) {
        final response = await ProfileRepo().unFollowUser(userId: currentUserId, followedUserId: followedUserId);

        if (response != null) {
          userData.value?.followers.remove(followedUserId);
          viewedUsers[index].followers.remove(currentUserId);
          searchBottomSheetList[index].followers.remove(followedUserId);
          getUserProfile();
          // ProfileRepo()
          //     .getFollowingUsers(userId: SessionService().user!.id)
          //     .then((data) {
          //   SessionService().replaceFollowingList(data);
          // });
        }
      } else {
        final response = await ProfileRepo().followUser(userId: currentUserId, followUserId: followedUserId);
        if (response != null) {
          userData.value?.followers.add(followedUserId);
          viewedUsers[index].followers.add(currentUserId);
          NotificationRepo()
              .sendNotification(title: 'New Follower', body: 'You have a new follower: ${userData.value?.name}', userId: followedUserId);
          getUserProfile();
          // ProfileRepo().getFollowingUsers(userId: currentUserId).then((value) {
          //   SessionService().replaceFollowingList(value);
          // });
        }
      }
      userData.refresh();
      viewedUsers.refresh();
      searchBottomSheetList.refresh();
    } catch (e) {}

    isFollowersLoading.value = false;
  }

  Future<void> updateRating({required String postId, required double rating}) async {
    try {
      int postIndex = userPosts.indexWhere((element) => element.id == postId);
      final userId = SessionService().user?.id ?? '';
      if (postIndex != -1) {
        ///TODO
        final response = await PostRepo().setRating(rating, userPosts[postIndex].id, userId);
        if (response != null) {
          userPosts[postIndex].averageRating = response.averageRating;
          userPosts.refresh();
          NotificationRepo().sendNotification(
              title: 'Post Rated', body: 'Your post has been rated by ${userData.value?.name}', userId: userPosts[postIndex].userId.id);
        }
        userRating.value = rating;
        isRatingTapped.value = false;
      }
    } catch (e) {}
  }

  /*Future<void> reportClip({required String postId, required double rating, required String selectedReason}) async {
    try {
      int postIndex = userPosts.indexWhere((element) => element.id == postId);
      final userId = SessionService().user?.id ?? '';
      if (postIndex != -1) {
        ///TODO
        final response = await PostRepo().reportPost(reason: selectedReason, postId: userPosts[postIndex].id, userID: userId);
        if (response != null && response.message =="blocked successfully") {
          userPosts.removeAt(postIndex);
          userPosts.refresh();
          NotificationRepo().sendNotification(
              title: 'Reported Post', body: 'Your post has been reported', userId: userPosts[postIndex].userId.id);
          CustomSnackbar.showSnackbar("Clip reported successfully");
        }else{
          CustomSnackbar.showSnackbar("Unable to report the clip");
        }

      }
    } catch (e) {
      CustomSnackbar.showSnackbar("Something went wrong");
      printLogs('Error: $e');
    }
  }*/

  /// blocking the user
  RxList<String> blockingReasons = RxList();
  RxString selectedReason = 'Select Reason'.obs;
  RxString selectedReasonId = ''.obs;
  Future<void> getReasonsOfBlocking() async {
    try {
      final userId = SessionService().user?.id ?? '';

      final response = await PostRepo().getReasonsToBlockReport(isReport: false);
      if (response != null) {
        blockingReasons.clear();
        blockingReasons.add("Select Reason");
        response.reasons?.forEach((reason) {
          if (reason.reason != null && reason.reason!.isNotEmpty && !blockingReasons.contains(reason.reason)) {
            blockingReasons.add(reason.reason ?? '');
          }
        });
      } else {
        CustomSnackbar.showSnackbar("Unable to get reasons");
      }
    } catch (e) {
      CustomSnackbar.showSnackbar("Something went wrong");
      printLogs('Error getReasonsOfBlocking archive: $e');
    }
  }

  Future<void> blockUser({required String blockedUserId, required String reason}) async {
    try {
      isLoading.value = true;
      final userId = SessionService().user?.id ?? '';

      final response = await PostRepo().blockUser(reasonId: reason, blockedUserId: blockedUserId, userID: userId);
      if (response != null && response.message == "User blocked successfully") {
        NotificationRepo().sendNotification(title: 'Reported Post', body: 'User has been blocked successfully', userId: userId);
        CustomSnackbar.showSnackbar("User blocked successfully");
        selectedReason.value = 'Select Reason';
      } else {
        CustomSnackbar.showSnackbar("Unable to block the user");
      }
      isLoading.value = false;
    } catch (e) {
      CustomSnackbar.showSnackbar("Something went wrong");
      printLogs('Error blockUser archive: $e');
      isLoading.value = false;
    }
  }

  onReasonDropDownChange(newValue) {
    if (newValue != null) {
      selectedReason.value = newValue;
      selectedReasonId.value = blockingReasons.indexOf(newValue).toString();
    }
  }

  void downloadVideo(String videoUrl) {
    VideoServices().downloadVideo(
      videoUrl: videoUrl,
      notificationService: notificationService,
    );
  }

/*
  addWaterMarkToVideo({
    required String downloadPath,
    required String videoUrl,
    required String watermarkPath,
    double watermarkOpacity = 0.5,
    required WatermarkAlignment position, //WatermarkAlignment.botomRight
  }) async {
    // Add watermark to downloaded video
    // final String watermarkedVideoPath = '${tempDir.path}/${fileName}_watermarked.mp4';
    final savedVideoDirectory = await getExternalStorageDirectory();
    final watermarkedVideoPath = "${savedVideoDirectory?.path}/Download/vupop/watermarked_${DateTime.now().millisecondsSinceEpoch}.mp4";

    VideoWatermark videoWatermark = VideoWatermark(
      sourceVideoPath: downloadPath,
      savePath: "${savedVideoDirectory?.path}/Download/vupop/",
      videoFileName: "watermarked_${DateTime.now().millisecondsSinceEpoch}.mp4",
      watermark: Watermark(image: WatermarkSource.file(watermarkPath)),
      onSave: (path) {
        // Get output file path
        printLogs('=================save watermark video path $path');
      },
      progress: (value) {
        // Get video generation progress
        printLogs('=================save progress of watermark video :: $value');
      },
    );
    */ /* await VideoWatermark.(
      videoPath: downloadPath,
      outputPath: watermarkedVideoPath,
      watermarkPath: watermarkPath,
      opacity: watermarkOpacity,
      position: position,
    );*/ /*
    await videoWatermark.generateVideo();
  }*/
}
