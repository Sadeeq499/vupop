import 'dart:async';
import 'dart:developer';
import 'dart:io';

import 'package:cached_video_player_plus/cached_video_player_plus.dart';
import 'package:camera/camera.dart';
import 'package:card_swiper/card_swiper.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:socials_app/models/highlight_reel_model.dart';
import 'package:socials_app/models/passion_model.dart';
import 'package:socials_app/models/post_models.dart';
import 'package:socials_app/models/reasons_report_block_model.dart';
import 'package:socials_app/models/usermodel.dart';
import 'package:socials_app/repositories/notification_repo.dart';
import 'package:socials_app/repositories/post_repo.dart';
import 'package:socials_app/repositories/profile_repo.dart';
import 'package:socials_app/services/common_imagepicker.dart';
import 'package:socials_app/services/custom_snackbar.dart';
import 'package:socials_app/services/notification_sevices.dart';
import 'package:socials_app/services/session_services.dart';
import 'package:socials_app/services/sharedprefrence_service.dart';
import 'package:socials_app/services/videoservices.dart';
import 'package:socials_app/utils/app_strings.dart';
import 'package:socials_app/utils/common_code.dart';
import 'package:socials_app/views/screens/discover/controller/discover_controller.dart';
import 'package:socials_app/views/screens/home/controller/home_controller.dart';
import 'package:super_tooltip/super_tooltip.dart';

import '../../../../models/payment_models/get_payment_methods_model.dart';
import '../../../../models/payment_models/wallet_balance_model.dart';
import '../../../../models/payout_notification_model.dart';
import '../../../../models/post_response_model.dart';
import '../../../../models/recordings_models/local_video_post_model.dart';
import '../../../../repositories/payment_repo.dart';
import '../../../../repositories/wallet_repo.dart';
import '../../../custom_widgets/custom_app_dialogs.dart';
import '../../home_recordings/controller/recording_cont.dart';
import '../screen/profile_screen.dart';

class ProfileScreenController extends GetxController {
  GlobalKey<ScaffoldState> scaffoldKeyProfile = GlobalKey<ScaffoldState>();
  GlobalKey<ScaffoldState> scaffoldKeySwipe = GlobalKey<ScaffoldState>();
  GlobalKey<ScaffoldState> scaffoldKeyDetailPost = GlobalKey<ScaffoldState>();
  GlobalKey<ScaffoldState> createHighlightedPostScaffoldKey = GlobalKey<ScaffoldState>();
  RxString imageUrl = ''.obs;
  Rx<UserDetailModel?> userData = Rx<UserDetailModel?>(null);
  RxList<PostModel> userPosts = <PostModel>[].obs;
  RxBool isLoading = false.obs;
  RxBool isSwiping = false.obs;
  RxBool isPlaying = true.obs;
  RxBool isVideoLoading = false.obs;
  RxBool isGettingPosts = false.obs;
  NotificationService notificationService = NotificationService();
  ScrollController scrollController = ScrollController();
  RxInt leftmostVisibleIndex = 0.obs;
  PageController pageController = PageController(viewportFraction: 0.4);
  PageController pageController2 = PageController();
  RxString profileImageUrl = "".obs;

  SuperTooltipController tooltipControllerPending = SuperTooltipController();
  SuperTooltipController tooltipControllerWithdrawal = SuperTooltipController();

  @override
  void onInit() {
    getData();
    scrollController.addListener(_onScroll);
    getDirectoryPath();
    super.onInit();
  }

  @override
  void onClose() {
    scrollController.removeListener(_onScroll);
    scrollController.dispose();
    super.onClose();
  }

  void _onScroll() {
    double offset = scrollController.offset;
    int newIndex = (offset / 180.w).floor();
    if (newIndex != leftmostVisibleIndex.value) {
      leftmostVisibleIndex.value = newIndex;
    }
  }

  void getData({bool isProfileUpdated = false}) async {
    userPosts.clear();
    if (SessionService().userDetail == null) {
      getUserProfile(SessionService().user?.id);
    } else {
      await SessionService().getEmailVerificationDetails();
      userData.value = SessionService().userDetail;
      profileImageUrl.value =
          SessionService().userDetail != null && SessionService().userDetail!.image != null && SessionService().userDetail!.image!.isNotEmpty
              ? SessionService().userDetail!.image!
              : 'No Image';
    }

    printLogs("========controller.profileImageUrl.value ${profileImageUrl.value}");
    printLogs("========controller.profileImageUrl.value ${profileImageUrl.value == 'null'}");
    printLogs("========controller.profileImageUrl.value ${userData.value?.image}");
    isLoading.value = true;
    currentPageNum.value = 1;
    if (isProfileUpdated) {
      await getUserProfile(SessionService().user?.id);
    }
    getPayoutNotifications();
    getUserPosts(SessionService().user?.id, isFirstTime: true);
    // getReasonsOfBlocking();
    getPassions();
    isOtherUser.value = false;
    isLoading.value = false;
  }

  /// fn to get user Profile
  ///
  RxList<Passion> userPassions = <Passion>[].obs;
  Future<void> getUserProfile(String? userId) async {
    try {
      final userID = userId;
      // if (kDebugMode) {
      // debugPrint('User ID: ${userID ?? 'No User ID Found'}');
      // }
      final value = await ProfileRepo().getUserProfile(userId: userID ?? '');
      if (value != null) {
        userData.value = value;
        profileImageUrl.value = userData.value!.image != null && userData.value!.image!.isNotEmpty ? userData.value!.image! : "No Image";
        userData.value?.following = userData.value?.following.toSet().toList() ?? [];
        userData.value?.followers = userData.value?.followers.toSet().toList() ?? [];
        SessionService().userDetail = value;
        SessionService().saveUserDetails();

        List<Future> futureResponses = [];
/*        futureResponses.add(getFollowingUsers());
        futureResponses.add(getFollowersUsers());*/
        futureResponses.add(getUserPassions());
        // futureResponses.add(getUserPaymentMethod());
        await Future.wait(futureResponses);
      } else {
        CustomSnackbar.showSnackbar('Error in getting user profile');
      }
    } catch (e) {
      CustomSnackbar.showSnackbar('Error in getting user profile');
    }
    isLoading.value = false;
  }

  void loadMorePosts() {
    getUserPosts(SessionService().user?.id, isFirstTime: false);
  }

  /// fn to get user Posts
  RxList<RxBool> isPostDownloading = <RxBool>[].obs;
  RxInt currentPageNum = 1.obs;
  RxInt totalPostPages = 1.obs;
  Future<List<PostModel>?> getUserPosts(String? userId, {required bool isFirstTime}) async {
    try {
      if (isFirstTime) {
        isGettingPosts.value = true;
      }
      final userID = userId;

      Map<String, dynamic> body = {
        "userId": userID,
      };
      final value = await PostRepo().getUserPosts(
        userId: userID ?? '',
        body: body,
        pageNum: currentPageNum.value,
      );
      /* if (value != null && value.totalPages != currentPageNum.value && isFirstTime) {
        await getUserPosts(userId, isFirstTime: false);
      } else*/
      if (value != null) {
        totalPostPages.value = value.totalPages;
        if (isFirstTime) {
          userPosts.clear();
          userPosts.value = value.posts;
          /*userPosts.removeWhere(
            (element) => (element.landscapeVideo.isEmpty && element.landscapeVideo.isEmpty),
          );*/
          setupPaginationListener();
        } else {
          userPosts.addAll(value.posts);
        }

        // userPosts.sort((a, b) => (b.date ?? DateTime(0)).compareTo(a.date ?? DateTime(0)));
        userPosts.sort((a, b) => b.views?.length ?? 0.compareTo(a.views?.length ?? 0));
        isGettingPosts.value = false;
        isPostDownloading.assignAll(List.generate(userPosts.length, (index) {
          return false.obs;
        }));
        currentPageNum.value++;
        return value.posts;
      } else {
        CustomSnackbar.showSnackbar('Error in getting user posts');
      }
    } catch (e) {
      CustomSnackbar.showSnackbar('Error in getting user posts');
      isGettingPosts.value = false;
    }
    isGettingPosts.value = false;
    return null;
  }

  var thumbnailCache = <String, Uint8List?>{}.obs;
  Future<Uint8List?> getThumbnail(String videoUrl) async {
    if (!thumbnailCache.containsKey(videoUrl)) {
      final thumbnail = await VideoServices().getThumbnailData(videoUrl);
      thumbnailCache[videoUrl] = thumbnail;
    }
    return thumbnailCache[videoUrl];
  }

  // void initializeVideoController(String videoUrl) {
  //   videoController = VideoPlayerController.networkUrl(Uri.parse(videoUrl));
  //   videoController?.initialize().then((_) {
  //     videoController?.play();
  //     videoController?.setLooping(true);
  //     update();
  //   });
  // }

  RxInt downloadProgress = 0.obs;
  Future<void> saveVideoLocally(int index, {required String videoUrl}) async {
    isPostDownloading[index].value = true;
    CustomSnackbar.showSnackbar("Saving the Video....");
    isPostDownloading.refresh();
    VideoServices()
        .downloadVideo(
      videoUrl: videoUrl,
      notificationService: notificationService,
    )
        .then((value) {
      if (value) {
        CustomSnackbar.showSnackbar("Video is Saved");
      } else {
        CustomSnackbar.showSnackbar('Error saving the video');
      }
      isPostDownloading[index].value = false;
      isPostDownloading.refresh();
    });
  }

  ///// Swipe code /////......
  SwiperController swiperController = SwiperController();
  RxBool isRatingTapped = false.obs;
  RxDouble userRating = 0.0.obs;
  // RxList<VideoPlayerController> videoControllers = <VideoPlayerController>[].obs;
  RxList<CachedVideoPlayerPlus> videoControllers = <CachedVideoPlayerPlus>[].obs;

  Future<void> initializeAllControllers(int startIndex, int limit) async {
    try {
      isVideoLoading.value = true;

      if (startIndex < 0 || limit > userPosts.length) {
        CustomSnackbar.showSnackbar("Error: Index out of range");
        return;
      }

      // Clear existing controllers first
      await disposeVideoPlayer();
      videoControllers.clear();

      // Create a list to hold all initialization futures
      List<Future> initializationFutures = [];

      // Create controllers and collect their initialization futures
      for (int i = startIndex; i < startIndex + limit && i < userPosts.length; i++) {
        final controller = CachedVideoPlayerPlus.networkUrl(
          Uri.parse(userPosts[i].video),
          httpHeaders: {'Connection': 'keep-alive'}, // Add keep-alive header
          invalidateCacheIfOlderThan: (userPosts[i].isPortrait != null && userPosts[i].isPortrait! && userPosts[i].portraitVideo.isEmpty)
              ? const Duration(seconds: 30)
              : (userPosts[i].isPortrait != null && !(userPosts[i].isPortrait!) && userPosts[i].landscapeVideo.isEmpty)
                  ? const Duration(seconds: 30)
                  : const Duration(hours: 1),
        );

        videoControllers.add(controller);

        // Add listener for prebuffering the next video
        if (i == startIndex) {
          controller.addListener(() {
            final position = controller.controller.value.position;
            final duration = controller.controller.value.duration;

            // If we're at least 80% through the video, prebuffer the next one
            if (position != null && duration != null && position.inMilliseconds > (duration.inMilliseconds * 0.8) && i < userPosts.length - 1) {
              preBufferNextVideo(i);
            }
          });
        }

        // Add the initialization to our futures list
        initializationFutures.add(controller.initialize().then((_) {
          controller.setLooping(true);
          controller.setVolume(1.0);
        }));
      }

      // Wait for all initializations to complete
      await Future.wait(initializationFutures);

      // Prebuffer the next video outside current view if available
      if (startIndex + limit < userPosts.length) {
        preBufferNextVideo(startIndex + limit - 1);
      }

      isVideoLoading.value = false;
    } catch (e) {
      printLogs("====================exception from profile while loading video $e");
      isVideoLoading.value = false;
      // CustomSnackbar.showSnackbar("Error loading videos: ${e.toString().substring(0, math.min(e.toString().length, 100))}");
    }
  }

  Future<void> initializeVideoPlayer({required String videoUrl, bool isInvalidateCache = false, bool addToList = true}) async {
    final controller = CachedVideoPlayerPlus.networkUrl(
      Uri.parse(videoUrl),
      httpHeaders: {'Connection': 'keep-alive'},
      invalidateCacheIfOlderThan: isInvalidateCache ? const Duration(seconds: 5) : const Duration(minutes: 30),
    );

    if (addToList) {
      videoControllers.add(controller);
    }

    // Add error listener
    controller.addListener(() {
      if (controller.value.hasError) {
        // printLogs("Video playback error: ${controller.value.errorDescription}");
        // If it's in our list and has an error, try to reinitialize
        if (addToList && videoControllers.contains(controller)) {
          int index = videoControllers.indexOf(controller);
          if (index >= 0 && index < userPosts.length) {
            // Reinitialize with cache invalidation
            controller.dispose();
            videoControllers[index] = CachedVideoPlayerPlus.networkUrl(
              Uri.parse(userPosts[index].video),
              invalidateCacheIfOlderThan: const Duration(seconds: 0), // Force refresh
            );
            videoControllers[index].initialize().then((_) {
              videoControllers[index].controller.setLooping(true);
              videoControllers[index].controller.setVolume(1.0);
              if (index == tappedPostIndex.value) {
                videoControllers[index].controller.play();
              }
            });
          }
        }
      }
    });

    await controller.initialize().then((_) {
      controller.setLooping(true);
      controller.setVolume(1.0);
      if (addToList) {
        controller.pause();
      }
    }).catchError((error) {
      printLogs("Error initializing video: $error");
      // Try once more with cache invalidation if this was a normal init
      if (!isInvalidateCache) {
        initializeVideoPlayer(videoUrl: videoUrl, isInvalidateCache: true, addToList: addToList);
      }
    });

    if (!addToList) {
      // Just initialize for cache but don't keep the controller
      await controller.dispose();
    }
  }

  Future<void> disposeVideoPlayer() async {
    for (var controller in videoControllers) {
      try {
        await controller.pause();
        await controller.dispose();
      } catch (e) {
        printLogs("Error disposing video controller: $e");
      }
    }
    videoControllers.clear();
  }

  void preBufferNextVideo(int currentIndex) {
    if (currentIndex + 1 < userPosts.length &&
        (videoControllers.length <= currentIndex + 1 || !videoControllers[currentIndex + 1].controller.value.isInitialized)) {
      // printLogs("Prebuffering video at index ${currentIndex + 1}");
      initializeVideoPlayer(videoUrl: userPosts[currentIndex + 1].video, addToList: videoControllers.length <= currentIndex + 1);
    }
  }
  //
  // Future<void> initializeAllControllersNew(int startIndex, int limit, {bool isFromProfileScreen = false}) async {
  //   try {
  //     printLogs('========limit $limit');
  //     printLogs('========startIndex $startIndex');
  //     isVideoLoading.value = true;
  //
  //     if (startIndex < 0 || limit > userPosts.length) {
  //       CustomSnackbar.showSnackbar("Error: Index out of range");
  //       return;
  //     }
  //     if (isFromProfileScreen && startIndex > 0) {
  //       for (int i = 0; i < startIndex; i++) {
  //         videoControllers.add(CachedVideoPlayerPlusController.networkUrl(Uri.parse(userPosts[i].video),
  //             httpHeaders: {
  //               'Cache-Control': 'max-age=3600', // Cache for an hour
  //             },
  //             videoPlayerOptions: VideoPlayerOptions(
  //               mixWithOthers: false,
  //               allowBackgroundPlayback: false,
  //             ),
  //             formatHint: VideoFormat.hls,
  //             skipCache: true,
  //             invalidateCacheIfOlderThan: Duration(minutes: 30)));
  //
  //         /*videoControllers.add(VideoPlayerController.networkUrl(
  //           Uri.parse(userPosts[i].video),
  //           httpHeaders: {
  //             'Cache-Control': 'max-age=3600', // Cache for an hour
  //           },
  //           videoPlayerOptions: VideoPlayerOptions(
  //             mixWithOthers: false,
  //             allowBackgroundPlayback: false,
  //           ),
  //           formatHint: VideoFormat.hls,
  //         ));*/
  //       }
  //     }
  //     // printLogs("======videoControllers.length ${videoControllers.length}");
  //     List<Future> futureResponses = [];
  //     for (int i = startIndex; i < startIndex + limit && i < (startIndex > 0 ? userPosts.length : userPosts.length); i++) {
  //       // printLogs("=============playing from ${userPosts[i].video}");
  //       await initializeVideoPlayerNew(userPosts[i].video);
  //       /*await initializeVideoPlayer(
  //           'https://firebasestorage.googleapis.com/v0/b/torch-discover-your-style.appspot.com/o/1743166231800_1743166131302%20(1).mp4?alt=media&token=11aaf7ce-edea-47d0-bf5b-f67e84a7d4e4');
  //     */
  //     }
  //     // try {
  //     //   await Future.wait(futureResponses);
  //     // } catch (e) {
  //     //   Get.log('Error: $e');
  //     // }
  //     isVideoLoading.value = false;
  //   } catch (e) {
  //     print("====================exception from profile while loading video $e");
  //     isVideoLoading.value = false;
  //   }
  // }
  //
  // Future<void> initializeVideoPlayerNew(String videoUrl) async {
  //   printLogs("=========initializeVideoPlayer");
  //   videoControllers.add(CachedVideoPlayerPlusController.networkUrl(Uri.parse(videoUrl),
  //       httpHeaders: {
  //         'Cache-Control': 'max-age=3600', // Cache for an hour
  //       },
  //       videoPlayerOptions: VideoPlayerOptions(
  //         mixWithOthers: false,
  //         allowBackgroundPlayback: false,
  //       ),
  //       formatHint: VideoFormat.hls,
  //       invalidateCacheIfOlderThan: Duration(minutes: 30)));
  //   /* videoControllers.add(VideoPlayerController.networkUrl(Uri.parse(videoUrl),
  //       httpHeaders: {
  //         'Cache-Control': 'max-age=3600', // Cache for an hour
  //       },
  //       videoPlayerOptions: VideoPlayerOptions(
  //         mixWithOthers: false,
  //         allowBackgroundPlayback: false,
  //       ),
  //       formatHint: VideoFormat.hls,));*/
  //
  //   printLogs("=========initializeVideoPlayer after uri");
  //   // videoControllers.add(CachedVideoPlayerPlusController.networkUrl(Uri.parse(videoUrl), invalidateCacheIfOlderThan: const Duration(minutes: 30)));
  //   await videoControllers.last.initialize().then((_) {
  //     printLogs("=========initializeVideoPlayer inside video init");
  //     videoControllers.last.setLooping(true);
  //     videoControllers.last.setVolume(1.0);
  //     videoControllers.last.pause();
  //   });
  // }
  //
  // void disposeVideoPlayerNew() {
  //   for (var controller in videoControllers) {
  //     controller.dispose();
  //   }
  //   videoControllers.clear();
  // }

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
    if (index > 0) {
      await videoControllers[index - 1].controller.pause();
    } else if ((videoControllers.length - 1) > index) {
      await videoControllers[index + 1].controller.pause();
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
      // if (videoControllers.isNotEmpty) {
      //   videoControllers[index].controller.setLooping(true);
      //   videoControllers[index].controller.setVolume(1.0);
      //   videoControllers[index].controller.play();
      // }
      await videoControllers[index].controller.play();

      if (index == userPosts.length - 16 && currentPageNum.value <= totalPostPages.value) {
        loadMorePosts();
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
      for (UserDetailModel model in searchBottomSheetList) {
        viewedUsersLoadingMap[model.id] = false.obs;
      }
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

  RxBool isFollowStatusLoading = false.obs;
  RxMap<String, RxBool> followLoadingMap = <String, RxBool>{}.obs;
  RxMap<String, RxBool> viewedUsersLoadingMap = <String, RxBool>{}.obs;

  Future<void> updateFollowStatus({required String followedUserId, required int index, bool isFromBottomSheet = false}) async {
    final userId = SessionService().user?.id ?? '';

    /// check if the user is already following the user
    bool isFollowing = false;
    // Set loading for this specific user
    if (!isFromBottomSheet) {
      followLoadingMap[followedUserId] = true.obs;
      followLoadingMap.refresh();
    } else {
      viewedUsersLoadingMap[followedUserId] = true.obs;
      viewedUsersLoadingMap.refresh();
    }

    isFollowing = SessionService().isFollowingById(followedUserId);
    isFollowStatusLoading.value = true;
    try {
      if (isFollowing) {
        await ProfileRepo().unFollowUser(userId: SessionService().user!.id, followedUserId: followedUserId).then((d) {
          // SessionService().userDetail?.following.remove(followedUserId);
          userData.value?.followers.remove(followedUserId);
          if (isFromBottomSheet) {
            viewedUsers[index].followers.remove(
                  SessionService().user!.id,
                );
            searchBottomSheetList[index].followers.remove(followedUserId);
          }
          getUserProfile(SessionService().user?.id);
          CustomSnackbar.showSnackbar("You have unfollowed the user");
        });
      } else {
        await ProfileRepo().followUser(userId: SessionService().user!.id, followUserId: followedUserId).then((value) {
          print('==========SessionService().followingUsersIDs ${SessionService().followingUsersIDs}');
          userData.value?.followers.add(followedUserId);
          if (isFromBottomSheet) {
            viewedUsers[index].followers.remove(
                  SessionService().user!.id,
                );
            searchBottomSheetList[index].followers.remove(followedUserId);
          }
          // viewedUsers[index].followers.add(
          //       SessionService().user!.id,
          //     );

          // SessionService().userDetail?.following.add(followedUserId);
          //SessionService().replaceFollowingList(SessionService().following);
          // print('==========SessionService().followingUsersIDs after add ${SessionService().followingUsersIDs}');
          NotificationRepo().sendNotification(
            userId: followedUserId,
            title: 'New Follower',
            body: '${SessionService().user!.name} started following you',
          );
          getUserProfile(SessionService().user?.id);
          CustomSnackbar.showSnackbar("You have followed the user");
        });
      }

      // Clear loading for this specific user
      if (!isFromBottomSheet) {
        followLoadingMap[followedUserId] = false.obs;
        followLoadingMap.refresh();
      } else {
        viewedUsersLoadingMap[followedUserId] = false.obs;
        viewedUsersLoadingMap.refresh();
      }
      userData.refresh();
      viewedUsers.refresh();
      searchBottomSheetList.refresh();
    } catch (e) {
      print('===============exception $e');
      // Clear loading for this specific user
      if (!isFromBottomSheet) {
        followLoadingMap[followedUserId] = false.obs;
        followLoadingMap.refresh();
      } else {
        viewedUsersLoadingMap[followedUserId] = false.obs;
        viewedUsersLoadingMap.refresh();
      }
      CustomSnackbar.showSnackbar("Unable to Update Follow Status");
    }
    isFollowStatusLoading.value = false;
  }

  Future<void> updateFollowStatusOld({
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
          getUserProfile(SessionService().user?.id);
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
          getUserProfile(SessionService().user?.id);
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

  //// blocking user
  RxList<String> blockingReasons = RxList();
  RxString selectedReason = 'Select Reason'.obs;
  RxList<ReasonModel> reportingReasons = <ReasonModel>[].obs;
  RxString selectedReasonId = '0'.obs;
  Future<void> getReasonsOfBlocking() async {
    try {
      final userId = SessionService().user?.id ?? '';

      final response = await PostRepo().getReasonsToBlockReport(isReport: false);
      if (response != null) {
        blockingReasons.clear();
        blockingReasons.add("Select Reason");
        reportingReasons.assignAll(response.reasons ?? []);
        response.reasons?.forEach((reason) {
          if (reason.reason != null && reason.reason!.isNotEmpty && !blockingReasons.contains(reason.reason)) {
            blockingReasons.add(reason.reason ?? '');
          }
        });
        blockingReasons.refresh();
      } else {
        CustomSnackbar.showSnackbar("Unable to get reasons");
      }
    } catch (e) {
      CustomSnackbar.showSnackbar("Something went wrong");
      if (kDebugMode) {
        debugPrint('Error: Profile Controller $e');
      }
    }
  }

  Future<void> blockUser({required String blockedUserId, required String reason}) async {
    try {
      isLoading.value = true;
      final userId = SessionService().user?.id ?? '';
      final response = await PostRepo().blockUser(reasonId: selectedReasonId.value, blockedUserId: blockedUserId, userID: userId);
      if (response != null && response.message == "User blocked successfully") {
        // await getFollowersUsers();
        // await getFollowingUsers();
        if (userData.value?.followers.contains(blockedUserId) ?? false) {
          userData.value?.followers.remove(blockedUserId);
          if (followersUsers.any((element) => element.id == blockedUserId)) {
            followersUsers.remove(followersUsers.firstWhere((element) => element.id == blockedUserId));
          }
        }
        if (userData.value?.following.contains(blockedUserId) ?? false) {
          userData.value?.following.remove(blockedUserId);
          if (followingUsers.any((element) => element.id == blockedUserId)) {
            followingUsers.remove(followingUsers.firstWhere((element) => element.id == blockedUserId));
          }
        }
        followersUsers.refresh();
        followingUsers.refresh();
        NotificationRepo().sendNotification(title: 'Reported Post', body: 'User has been blocked successfully', userId: userId);
        CustomSnackbar.showSnackbar("User blocked successfully");
        selectedReason.value = 'Select Reason';
        isLoading.value = false;
        HomeScreenController homeController = Get.isRegistered() ? Get.find<HomeScreenController>() : HomeScreenController();
        homeController.posts.removeWhere((element) => element.userId.id == userId);
        homeController.posts.refresh();
        homeController.videoControllers.clear();
        homeController.videoControllers.refresh();
        if (homeController.posts.isNotEmpty && homeController.posts.length < homeController.videoLimitForLoading.value) {
          await initializeAllControllers(0, homeController.posts.length);
        } else {
          await initializeAllControllers(0, homeController.videoLimitForLoading.value);
        }
        DiscoverController discoverController = Get.isRegistered() ? Get.find<DiscoverController>() : DiscoverController();
        discoverController.posts.removeWhere((element) => element.userId.id == userId);
        discoverController.posts.refresh();
      } else {
        CustomSnackbar.showSnackbar("Unable to block the user");
      }
      isLoading.value = false;
    } catch (e) {
      CustomSnackbar.showSnackbar("Something went wrong");
      if (kDebugMode) {
        debugPrint('Error: Profile Controller $e');
      }
      isLoading.value = false;
    }
  }

  onReasonDropDownChange(newValue) {
    if (newValue != null) {
      selectedReason.value = newValue;
      selectedReasonId.value = reportingReasons.firstWhere((element) => element.reason == newValue).id.toString();
    }
  }

  RxList<CachedVideoPlayerPlus> highlightVideoControllers = <CachedVideoPlayerPlus>[].obs;
  RxList<Reel> highlightReels = <Reel>[].obs;
  TextEditingController captionController = TextEditingController();
  RxBool isVideoLoadingDetail = false.obs;
  Rxn<PostModel> postDetail = Rxn<PostModel>();
  void getUserHighlitedReels() async {
    isVideoLoadingDetail.value = true;
    try {
      highlightReels.clear();
      highlightVideoControllers.clear();
      final response = await ProfileRepo().getHighlithedReels(userId: userData.value?.id ?? SessionService().user?.id ?? '');
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
      CustomSnackbar.showSnackbar("Error: Profile Controller $e");
    }
  }

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
    cameraController.value?.dispose();
    cameraController.value = null;
    cameraController.value = CameraController(
      cameras.firstWhere((camera) => camera.lensDirection == CameraLensDirection.back),
      ResolutionPreset.high,
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
    if (cameraController.value?.value.isRecordingVideo ?? false) {
      await cameraController.value?.stopVideoRecording();
    }
    await cameraController.value?.unlockCaptureOrientation();
    await cameraController.value?.dispose();
    await highLightVideoController.value?.pause();
    cameraController.value = null;
    highLightVideoController.value = null;
    isRecording.value = false;
    isRecordingStarted.value = false;
    isRecordignFinished.value = false;
    isFinishedRecording.value = false;
    isFileSelected.value = false;
    isButtonTapped.value = false;
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
    } catch (e) {}
  }

  TextEditingController caption = TextEditingController();
  //// upload highlight
  Future<void> uploadHighlight() async {
    if (captionController.text.isEmpty) {
      CustomSnackbar.showSnackbar('Please enter caption');
      return;
    }
    if (!isFileSelected.value) {
      CustomSnackbar.showSnackbar('Please select image or video');
      return;
    }
    try {
      isVideoLoadingDetail.value = true;
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
          visibilityList: userData.value?.followers ?? [],
          userId: SessionService().user?.id ?? '');
      if (response != null) {
        Get.back();
        Get.back();
        CustomSnackbar.showSnackbar('Highlight uploaded successfully');
        captionController.clear();
        videoPath.value = '';
        imagePath.value = '';
        highLightVideoController.value = null;
        isFileSelected.value = false;
        // getUserHighlitedReels();
        clearUploadedData();
        resetRecording();
        isVideoLoadingDetail.value = false;
      } else {
        CustomSnackbar.showSnackbar('Error in uploading highlight');
      }
      isVideoLoadingDetail.value = false;
    } catch (e) {
      CustomSnackbar.showSnackbar('Error in uploading highlight $e');
    }
    isVideoLoadingDetail.value = false;
  }

  /// clear uploaded data
  void clearUploadedData() {
    captionController.clear();
    videoPath.value = '';
    imagePath.value = '';
    highLightVideoController.value?.pause();
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
        Get.back();
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
        Get.back();
        CustomSnackbar.showSnackbar("Highlight Deleted Successfully");
      }
    } catch (e) {
      log("error deleting: $e");
      CustomSnackbar.showSnackbar("Error in deleting highlight");
    }
    isVideoLoadingDetail.value = false;
  }

  /// get following users
  RxList<UserDetailModel> followingUsers = <UserDetailModel>[].obs;
  RxBool isFollowingUsersLoading = false.obs;
  Future<void> getFollowingUsers() async {
    followingUsers.clear();
    isFollowingUsersLoading.value = true;
    try {
      List<Future<UserDetailModel?>> futureResponses = [];

      for (var id in userData.value?.following ?? []) {
        if (!followingUsers.any((element) => element.id == id)) {
          futureResponses.add(ProfileRepo().getUserProfile(userId: id));
        }
      }
      final responses = await Future.wait(futureResponses);
      followingUsers.assignAll(responses.whereType<UserDetailModel>());
    } catch (e) {
      CustomSnackbar.showSnackbar("Something went wrong");
      if (kDebugMode) {
        debugPrint('Error: Profile Controller $e');
      }
    }
    isFollowingUsersLoading.value = false;
  }

  /// get followers users
  RxList<UserDetailModel> followersUsers = <UserDetailModel>[].obs;
  RxBool isFollowersUsersLoading = false.obs;
  Future<void> getFollowersUsers() async {
    followersUsers.clear();
    isFollowersUsersLoading.value = true;
    try {
      List<Future<UserDetailModel?>> futureResponses = [];
      for (var id in userData.value?.followers ?? []) {
        futureResponses.add(ProfileRepo().getUserProfile(userId: id));
      }
      final responses = await Future.wait(futureResponses);
      followersUsers.assignAll(responses.whereType<UserDetailModel>());
      for (UserDetailModel model in followersUsers) {
        followLoadingMap[model.id] = false.obs;
      }
    } catch (e) {
      CustomSnackbar.showSnackbar("Something went wrong");
      if (kDebugMode) {
        debugPrint('Error: Profile Controller $e');
      }
    }
    isFollowersUsersLoading.value = false;
  }

  RxBool isOtherUser = false.obs;
  Future<void> onOtherUserView(String userId) async {
    isLoading.value = true;
    Get.toNamed(kFollowersProfileScreen, arguments: userId);
    isLoading.value = false;
  }

  RxBool isPassionLoading = false.obs;
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

  RxList<Passion> passions = <Passion>[].obs;
  // RxList<Passion> selectedPassions = <Passion>[].obs;
  Future<void> getPassions() async {
    isPassionLoading.value = true;
    try {
      final response = await ProfileRepo().getAllPassions();
      if (response.isNotEmpty) {
        passions.assignAll(response);
        passions.refresh();
      } else {}
    } catch (e) {
      CustomSnackbar.showSnackbar("Something went wrong");
      if (kDebugMode) {
        debugPrint('Error: Profile Controller $e');
      }
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

  RxBool isPotraitDialogShown = false.obs;

  RxBool isSound = true.obs;

  void setupPaginationListener() {
    pageController.addListener(() {
      // Check if we're near the end of the current posts
      if (pageController.position.pixels >= pageController.position.maxScrollExtent * 0.7 && currentPageNum.value <= totalPostPages.value) {
        loadMorePosts();
      }
    });
  }

  // PaymentMethodData? paymentMethodData;

  Rx<WalletBalanceModel?> walletData = Rx<WalletBalanceModel?>(null);
  Future<void> getWalletBalance() async {
    final resp = await WalletRepo().getWalletBalance();
    if (resp != null) {
      walletData.value = resp;
    } else {
      CustomSnackbar.showSnackbar('Network Error: Unable to get wallet balance');
    }
  }

  RxBool isUploadingInProgress = false.obs;
  retryUpload(int index) async {
    if (await VideoServices().checkVideoExist(listUploadingVideos[index].videoPath ?? "") &&
        await VideoServices().checkVideoExist(listUploadingVideos[index].thumbnailFile?.path ?? "")) {
      tryUploadVideo(index);
    } else {
      CustomSnackbar.showSnackbar('Video has been removed or deleted');
      removeItem(index);
    }
  }

  removeItem(int index) async {
    RecordingController recordingController = Get.find<RecordingController>();
    if (recordingController.listUploadingVideos.isNotEmpty) {
      recordingController.listUploadingVideos.removeAt(index);
    }

    await SharedPrefrenceService.removeTempVideo(listUploadingVideos[index].videoPath!);
    listUploadingVideos.removeAt(index);
    listUploadingVideos.refresh(); // <-- forces update
    if (listUploadingVideos.isEmpty) {
      isUploadingInProgress.value = false;
    }
  }

  RxList<LocalUserVideoPostModel> listUploadingVideos = RxList();

  var progressMap = <String, RxDouble>{}.obs;
  var statusMap = <String, Rx<UploadStatus>>{}.obs;

  getUploadingVideos() async {
    printLogs("===========getUploadingVideos ProfileController");
    try {
      listUploadingVideos.clear();
      List<Map> videos = await SharedPrefrenceService.getTempVideos();
      printLogs("===========getUploadingVideos ProfileController videos ${videos.length}");
      for (int i = 0; i < videos.length; i++) {
        printLogs("===========getUploadingVideos ProfileController inside for ${videos.length} $i");
        listUploadingVideos.add(LocalUserVideoPostModel.fromJson(videos[i]));

        printLogs("===========getUploadingVideos ProfileController inside for listUploadingVideos ${listUploadingVideos.length} $i");
      }
      printLogs("===========getUploadingVideos ProfileController outside for listUploadingVideos ${listUploadingVideos.length}");
      // if (listUploadingVideos.isNotEmpty) {
      //   for (LocalUserVideoPostModel item in listUploadingVideos) {
      //     startTracking(item.videoPath!);
      //   }
      // }
      if (listUploadingVideos.isNotEmpty) {
        for (LocalUserVideoPostModel item in listUploadingVideos) {
          String status = await SharedPrefrenceService.getUploadStatus(item.videoPath!);
          printLogs("============profileController status $status");
          statusMap.putIfAbsent(
              item.videoPath!,
              () => (status == 'success'
                      ? UploadStatus.success
                      : status == "uploading"
                          ? UploadStatus.uploading
                          : status == "hold"
                              ? UploadStatus.hold
                              : UploadStatus.failed)
                  .obs);
        }

        listUploadingVideos.refresh();
        update();
        Future.delayed(Duration(seconds: 1), () async {
          printLogs("get data after 1 seconds");
          if (listUploadingVideos.isNotEmpty && await SharedPrefrenceService.getIsFirstVideo()) {
            printLogs("get data after 1 seconds inside if");
            SharedPrefrenceService.removeIsFirstVideo();
            retryUpload(listUploadingVideos.length - 1);
          } else if (await SharedPrefrenceService.getIsFirstVideo()) {
            getUploadingVideos();
          }
        });
      } else if (await SharedPrefrenceService.getIsFirstVideo()) {
        getUploadingVideos();
      }
    } catch (e) {
      print("=======upload video issue $e");
    }
    isUploadingInProgress.value = listUploadingVideos.isNotEmpty;
  }

  Directory? savedVideoDirectory;
  getDirectoryPath() async {
    savedVideoDirectory = Platform.isIOS ? await getApplicationDocumentsDirectory() : await getExternalStorageDirectory();
    Directory tempDir = await getTemporaryDirectory();
    if (Platform.isAndroid) {
      CommonCode.clearAppCache();
    }
  }

  bool needDataRefresh = false;
  void startTracking(String filePath, int progressMain) async {
    print('=================startTracking progress $filePath ==> $progressMain');
    if (!progressMap.containsKey(filePath)) {
      progressMap[filePath] = 0.0.obs;
    }

    if (!statusMap.containsKey(filePath)) {
      statusMap[filePath] = UploadStatus.uploading.obs;
    }

    // Watch progress to trigger UI updates
    ever(progressMap[filePath]!, (_) => update());

    // Watch status and remove from list when successful
    ever(statusMap[filePath]!, (status) {
      if (status == UploadStatus.success && progressMain == 100) {
        listUploadingVideos.removeWhere((item) => item.videoPath == filePath);
        listUploadingVideos.refresh(); // <-- forces update
        isUploadingInProgress.value = listUploadingVideos.isNotEmpty;
        if (needDataRefresh) {
          Future.delayed(Duration(seconds: 2), () {
            printLogs("get data after 2 seconds");
            getData();
          });
        }
      }
    });

    double progress = await SharedPrefrenceService.getUploadProgress(filePath);
    String status = await SharedPrefrenceService.getUploadStatus(filePath);
    print('===================ProfileController startTracking progress Timer.periodic for $filePath --> $progress');
    print('===================ProfileController startTracking status $filePath --> $status');
    progressMap[filePath]?.value = progress;
    statusMap[filePath]?.value = status == 'success'
        ? UploadStatus.success
        : status == "uploading"
            ? UploadStatus.uploading
            : status == "hold"
                ? UploadStatus.hold
                : UploadStatus.failed;

    if (progress >= 1.0 || progressMain >= 100) {
      statusMap[filePath]?.value = UploadStatus.success;
    }
    /*Timer.periodic(Duration(milliseconds: 300), (timer) async {
      double progress = await SharedPrefrenceService.getUploadProgress(filePath);
      String status = await SharedPrefrenceService.getUploadStatus(filePath);
      print('===================progress Timer.periodic for $filePath --> $progress');
      progressMap[filePath]?.value = progress;
      statusMap[filePath]?.value = status == 'success'
          ? UploadStatus.success
          : status == "uploading"
              ? UploadStatus.uploading
              : UploadStatus.failed;

      if (progress >= 1.0) {
        timer.cancel(); // stop tracking
        statusMap[filePath]?.value = UploadStatus.success;
      } else if (progressMain >= 100) {
        timer.cancel(); // stop tracking
        statusMap[filePath]?.value = UploadStatus.success;
      }
    });*/
  }

  void startTrackingold(String filePath) async {
    if (!progressMap.containsKey(filePath)) {
      progressMap[filePath] = 0.0.obs;
    }
    if (!statusMap.containsKey(filePath)) {
      statusMap[filePath] = UploadStatus.uploading.obs;
    }

    // Start polling
    ever(progressMap[filePath]!, (_) => update());

    Timer.periodic(Duration(milliseconds: 300), (timer) async {
      //final prefs = await SharedPreferences.getInstance();
      double progress = await SharedPrefrenceService.getUploadProgress(filePath);
      print('===================progress Timer.periodic $progress');
      progressMap[filePath]?.value = progress;
      statusMap[filePath] = UploadStatus.uploading.obs;

      if (progress >= 1.0) {
        timer.cancel(); // stop tracking
        statusMap[filePath] = UploadStatus.success.obs;
        // getUploadingVideos();
      }
    });
  }

  // RxDouble getProgress(String filePath) {
  //   return (progressMap[filePath]?.value ?? 0.0).obs;
  // }
  //
  // Rx<UploadStatus> getStatus(String filePath) {
  //   return (statusMap[filePath]?.value ?? UploadStatus.success).obs;
  // }

  RxDouble getProgress(String filePath) {
    // print('============progressMap $statusMap');
    // print("progressMap All file keys: ${progressMap.keys}");
    // Return the existing RxDouble, or insert a new one if it doesn't exist
    return progressMap.putIfAbsent(filePath, () => 0.0.obs);
  }

  Rx<UploadStatus> getStatus(String filePath) {
    // print('============statusMap $statusMap');
    // print("statusMap All file keys: ${statusMap.keys}");
    return statusMap.putIfAbsent(filePath, () => UploadStatus.uploading.obs);
  }

  Future<void> addStatusInitial(String filePath) async {
    print('============statusMap $statusMap');

    String status = await SharedPrefrenceService.getUploadStatus(filePath);
    statusMap.putIfAbsent(filePath, () => UploadStatus.uploading.obs);
  }

  RxBool isUploading = false.obs;
  Future<void> tryUploadVideo(int index) async {
    printLogs('inside _uploadNextVideo 1');

    if (isUploading.isTrue) {
      return;
    }
    isUploading.value = true;
    LocalUserVideoPostModel videoData = listUploadingVideos[index];

    try {
      printLogs('===========debugPrint creating post ');

      // SharedPrefrenceService.saveUploadStatus(videoData.videoPath ?? "", UploadStatus.uploading);
      // SharedPrefrenceService.saveUploadProgress(videoData.videoPath ?? "", 0.0);
      PostRepo()
          .createPost(
        recordedByVupop: videoData.recordedByVupop ?? true,
        userId: videoData.userId ?? "",
        file: File(videoData.videoPath!),
        fileType: 'file',
        locationAdress: videoData.locationAdress!,
        lat: videoData.lat!,
        lng: videoData.lng!,
        mentions: videoData.mentions?.values.toList() ?? [],
        tags: videoData.tags?.values.toList() ?? [],
        thumbnailFile: videoData.thumbnailFile!,
        isFaceCam: videoData.facecam! == 'true',
        isPortrait: videoData.isPortrait! == 'true',
        progress: (progress) async {
          startTracking(videoData.videoPath!, progress);
          if (progress == 1) {
            needDataRefresh = true;
          }
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
          .then((result) {
        if (result is PostResponseModelData && result.id != null && result.id!.isNotEmpty) {
          List<String> mentionedManagersIds = videoData.mentionIdsList!;
          for (String managerID in mentionedManagersIds) {
            sendMentionNotification(managerID: managerID);
          }

          CustomSnackbar.showSnackbar('Post Submitted Successfully');

          // VideoServices().deleteFile(videoData.videoPath!);
          VideoServices().removeTempVideo(videoData.videoPath!);
          VideoServices().removeTempThumbnail(videoData.thumbnailFile!.path);
          SharedPrefrenceService.removeTempVideo(videoData.videoPath!);

          printLogs('========listUploadingVideos before${listUploadingVideos.length}');
          listUploadingVideos.removeAt(index);

          ///delete video after uploading done

          VideoServices().deleteFile(videoData.videoPath!);
        } else {
          SharedPrefrenceService.saveUploadStatus(videoData.videoPath!, UploadStatus.failed);
          SharedPrefrenceService.saveUploadProgress(videoData.videoPath!, 0.0);
          Get.find<ProfileScreenController>().startTracking(videoData.videoPath!, 0);
          CustomSnackbar.showSnackbar('Error creating post');
        }

        printLogs('========listUploadingVideos after ${listUploadingVideos.length}');

        isUploading.value = false;
      });
    } catch (e) {
      printLogs("==========retry post exception $e");
      CustomSnackbar.showSnackbar('Error creating post');
      SharedPrefrenceService.saveUploadStatus(videoData.videoPath!, UploadStatus.failed);
      SharedPrefrenceService.saveUploadProgress(videoData.videoPath!, 0.0);
      Get.find<ProfileScreenController>().startTracking(videoData.videoPath!, 0);
      // listUploadingVideos.removeAt(0);
      isUploading.value = false;
    }
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

  /// get user profile image
  Future<void> getUserProfileImage() async {
    try {
      final userID = SessionService().user?.id;
      final value = await ProfileRepo().getUserProfileImage(userId: userID ?? ''); // userID
      if (value != null) {
        profileImageUrl.value = value.isNotEmpty ? value : "No Image";
        userData.value?.image = value;
        SessionService().userDetail?.image = value;
      } else {}
    } catch (e) {
      CustomSnackbar.showSnackbar('Error in getting profile image');
    }
  }

  RxBool isEmailVerified = false.obs;
  RxBool isAccountDetailsAdded = false.obs;
  RxBool isLoadingPayoutNotifications = false.obs;
  Rxn<PayoutNotification> payoutNotification = Rxn<PayoutNotification>();
  getUserPaymentMethod() async {
    try {
      isLoading.value = true;
      final userID = SessionService().user!.id;

      // isEmailVerified.value = SessionService().isEmailVerified ?? false;
      PaymentMethodData? paymentMethodData = await PaymentRepo().getUserPaymentMethod(userId: userID, showSnackbar: false);
      if (paymentMethodData != null) {
        isAccountDetailsAdded.value = true;
      }
      isLoading.value = false;
    } catch (e) {
      printLogs('getUserPaymentMethod Exception : $e');
      isLoading.value = false;
    }
  }

  Future<void> getPayoutNotifications() async {
    printLogs('================getPayoutNotifications called');
    final userId = SessionService().user?.id;

    isLoadingPayoutNotifications.value = true;

    try {
      final data = await NotificationRepo()

          ///66b3953cf4a2d4388ef05833
          .getPayoutNotifications(
        userId: userId ?? '',
      );
      printLogs('=================getPayoutNotifications data ${data}');

      if (data != null && data.payoutNotification.isNotEmpty) {
        payoutNotification.value = data.payoutNotification[0];
        isEmailVerified.value = payoutNotification.value?.isVerified ?? false;
        getUserPaymentMethod();
      } else {
        isEmailVerified.value = true;
        getUserPaymentMethod();
      }
    } catch (e) {
      printLogs('===========getPayoutNotifications exception $e');
      Get.snackbar('Error', 'Failed to get Payout notifications');
    } finally {
      isLoadingPayoutNotifications.value = false;
    }
  }

  RxBool isVerifyingPayout = false.obs;
  Future<void> verifyPayouts({required String notificationId}) async {
    try {
      isVerifyingPayout.value = true;
      final data = await NotificationRepo()

          ///66b3953cf4a2d4388ef05833
          .verifyPayoutNotification(
        notificationId: notificationId ?? '',
      );
      printLogs('=================getPayoutNotifications data ${data}');

      if (data != null && data) {
        CustomSnackbar.showSnackbar("Payout details has been verified successfully");
        isEmailVerified.value = true;
        showCongratulationsDialogNew(
          isFromProfile: true,
          // customerName: paymentMethodData?.userName ?? "-",
          // iban: paymentMethodData?.iban ?? "-",
          // amountToWithdraw: walletPaymentData.value?.readyToWithdrawAmount?.toStringAsFixed(2) ?? "0",
          requestStatus: 'Success',
        );
      } else {
        CustomSnackbar.showSnackbar("Failed to verify payout details, please try again");
      }
    } catch (e) {
      printLogs('===========getPayoutNotifications exception $e');
      CustomSnackbar.showSnackbar("Failed to verify payout details, please try again");
    } finally {
      isVerifyingPayout.value = false;
    }
  }
}
