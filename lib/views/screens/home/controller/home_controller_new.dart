// import 'dart:developer';

// import 'package:flick_video_player/flick_video_player.dart';
// import 'package:flutter/material.dart';
// import 'package:geolocator/geolocator.dart';
// import 'package:get/get.dart';
// import 'package:socials_app/models/post_models.dart';
// import 'package:socials_app/repositories/post_repo.dart';
// import 'package:socials_app/services/custom_snackbar.dart';
// import 'package:socials_app/services/geo_services.dart';
// import 'package:socials_app/services/session_services.dart';

// class HomeScreenController extends GetxController {
//   GlobalKey<ScaffoldState> scaffoldKeyHome = GlobalKey<ScaffoldState>();
//   RxList<PostModel> posts = <PostModel>[].obs;
//   RxBool isLoading = false.obs;
//   PageController pageController = PageController();
//   FlickManager? flickManager;
//   RxInt ratingValue = 0.obs;
//   RxBool isRatingTapped = false.obs;
//   RxBool isVideoChanged = false.obs;
//   RxInt videoLimitForLoading = 6.obs;
//   @override
//   void onInit() {
//     super.onInit();
//     getAllPosts();
//     getLatLong();
//   }

//   /// fn to get all posts
//   Future<void> getAllPosts() async {
//     isLoading.value = true;
//     try {
//       final response = await PostRepo().getAllPosts();
//       if (response is List<PostModel> && response != null) {
//         printLogs('Posts: ${response.length}');
//         posts.assignAll(response);
//         await initializeAllControllers(0, videoLimitForLoading.value);
//         isLoading.value = false;
//       }
//     } catch (e) {
//       printLogs('Error: $e');
//       CustomSnackbar.showSnackbar("Unable to Load the Feed");
//     }
//     isLoading.value = false;
//   }

//   /// fn to set rating for video
//   Future<void> setRating(int rating, int index) async {
//     isRatingTapped.value = false;
//     final userId = SessionService().user?.id ?? '';
//     try {
//       final response =
//           await PostRepo().setRating(rating, posts[index].id, userId);
//       if (response != null) {
//         ratingValue.value = rating;
//       }
//     } catch (e) {
//       log('Error: $e');
//       CustomSnackbar.showSnackbar("Unable to Submit Rating");
//     }
//   }

//   getLatLong() async {
//     try {
//       Position position = await GeoServices.determinePosition();
//       log('Position lat and long: ${position.latitude}, ${position.latitude}');

//       /// Get address from lat and long
//       String address =
//           await GeoServices.getAddress(position.latitude, position.longitude);
//       log('Address: ${address}');
//       SessionService().userAddress = address;
//       SessionService().userLocation = Location(
//           lat: position.latitude.toString(),
//           lng: position.longitude.toString());
//       SessionService().saveUserAddress();
//     } catch (e) {
//       log(e.toString());
//     }
//   }

//   RxInt videoPreLoadLimit = 6.obs;
//   RxInt currentIndex = 0.obs;
//   RxList<VideoPlayerController?> videoControllers =
//       <VideoPlayerController?>[].obs;
//   RxList<bool> isPreloaded = <bool>[].obs;

//   /// fn to initiliaze all controllers
//   RxBool isMoreLoading = false.obs;
//   Future<void> initializeAllControllers(int startIndex, int limit) async {
//     isMoreLoading.value = true;
//     for (int i = startIndex; i < startIndex + limit && i < posts.length; i++) {
//       try {
//         await initializeFutureController(i);
//       } catch (e) {
//         Get.log('Error: $e');
//       }
//     }
//     isMoreLoading.value = false;
//   }

//   Future<void> initializeFutureController(int index) async {
//     // if (videoControllers.length > 6) {
//     //   /// Dispose of the oldest controller to manage memory
//     //   disposeController(0);
//     // }

//     videoControllers
//         .add(VideoPlayerController.networkUrl(Uri.parse(posts[index].video)));
//     await videoControllers[index]?.initialize().then((_) {
//       isPreloaded[index] = true;
//       videoControllers[index]?.setVolume(1.0);
//       videoControllers[index]?.setLooping(true);
//       videoControllers[index]?.play();
//     });
//   }

//   void disposeController(int index) {
//     videoControllers[index]?.dispose();
//     videoControllers.removeAt(index);
//     isPreloaded.removeAt(index);
//   }

//   void onPageChange(int index) {
//     currentIndex.value = index;
//     if (index + 1 >= videoPreLoadLimit.value) {
//       videoPreLoadLimit.value += 3;
//       initializeAllControllers(index + 1, videoLimitForLoading.value);
//     }
//     videoControllers[index]?.setLooping(true);
//     videoControllers[index]?.setVolume(1.0);
//     videoControllers[index]?.play();
//   }

//   // //dispose
//   @override
//   void onClose() {
//     super.onClose();
//     for (int i = 0; i < videoControllers.length; i++) {
//       videoControllers[i]?.dispose();
//     }
//   }
// }

import 'dart:developer';
import 'dart:io';
import 'dart:math' as math;

import 'package:cached_video_player_plus/cached_video_player_plus.dart';
import 'package:card_swiper/card_swiper.dart';
import 'package:carousel_slider/carousel_controller.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_video_info/flutter_video_info.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:socials_app/models/post_models.dart';
import 'package:socials_app/models/usermodel.dart';
import 'package:socials_app/repositories/notification_repo.dart';
import 'package:socials_app/repositories/post_repo.dart';
import 'package:socials_app/repositories/profile_repo.dart';
import 'package:socials_app/services/custom_snackbar.dart';
import 'package:socials_app/services/geo_services.dart';
import 'package:socials_app/services/session_services.dart';
import 'package:socials_app/services/sharedprefrence_service.dart';
import 'package:socials_app/services/videoservices.dart';
import 'package:socials_app/utils/app_strings.dart';
import 'package:socials_app/utils/common_code.dart';
import 'package:socials_app/views/screens/chat/controller/chat_controller.dart';
import 'package:socials_app/views/screens/discover/controller/discover_controller.dart';

import '../../../../models/reasons_report_block_model.dart';

class HomeScreenController extends GetxController {
  GlobalKey<ScaffoldState> scaffoldKeyHome = GlobalKey<ScaffoldState>();
  RxList<PostModel> posts = <PostModel>[].obs;
  RxBool isLoading = false.obs;
  PageController pageController = PageController();
  RxDouble ratingValue = 0.0.obs;
  RxBool isRatingTapped = false.obs;
  RxBool isVideoChanged = false.obs;
  RxInt videoLimitForLoading = 2.obs;
  Set<int> activeVideoIndices = {};
  ChatScreenController chatController = Get.find<ChatScreenController>();
  SwiperController swiperController = SwiperController();

  RxList<String> reportingReasons = RxList();
  RxList<String> blockingReasons = RxList();
  RxString selectedReason = 'Select Reason'.obs;
  RxString selectedReasonId = ''.obs;

  RxList<ReasonModel> reasonsModelReport = RxList();
  RxList<ReasonModel> reasonsModelBlock = RxList();
  final CarouselSliderController carouselController = CarouselSliderController();
  @override
  void onInit() {
    super.onInit();
    printLogs('============Hey I am called from home controller');
    getUserProfile();
    getAllPosts(isFirstTime: true).then((value) {
      if (posts.isNotEmpty) {
        getReasonsOfReportingBlocking();
        getReasonsOfBlocking();
      }
    });
  }

  ///fn with pagination logic
  RxInt currentPage = 1.obs;
  RxInt totalPages = 1.obs;
  RxBool hasMorePosts = true.obs;
  RxBool isVideoLoading = false.obs;

  Future<void> getAllPosts({required bool isFirstTime, bool isFromOnChange = false}) async {
    if (!hasMorePosts.value) return;

    isVideoLoading.value = true;
    try {
      Position? position = await getLatLong();
      final response = await PostRepo().getUserFeedPosts(
          userId: SessionService().user?.id ?? "", pageNum: currentPage.value, lat: position?.latitude ?? 0.0, lng: position?.longitude ?? 0.0);

      /* if (response != null && response.totalPages != currentPage.value && isFirstTime) {
        currentPage.value = response.totalPages;
        await getAllPosts(isFirstTime: false);
      } else {*/
      if (response != null && response.posts.isNotEmpty) {
        totalPages.value = response.totalPages ?? 1;
        // Filter out blocked and reported posts
        final filteredPosts = response.posts
            .where((post) =>
                !post.reportedBy.contains(SessionService().user?.id) &&
                !SessionService().isBlocked(post.userId.id) &&
                post.userId.id != SessionService().user?.id)
            .toList();

        // Append new posts
        posts.addAll(filteredPosts);
        if (isFirstTime) {
          isFirstTime = posts.isEmpty;
        }

        printLogs("=======Preload post length in getAllPostHome: ${posts.length}");
        // Update pagination
        currentPage.value++;
        hasMorePosts.value = currentPage.value <= totalPages.value; // Assuming 20 posts per page
        if (isFirstTime) {
          getAllPosts(
            isFirstTime: isFirstTime,
          );
        }
        if (isFromOnChange) {
          // await initializeAllControllers(previousValue.value, 2);
          // onPageChange(previousValue.value);
        } else {
          if (posts.isNotEmpty && posts.length < videoLimitForLoading.value) {
            await initializeAllControllers(0, posts.length);
          } else {
            await initializeAllControllers(0, 3);
          }
        }
      } else {
        hasMorePosts.value = false;
      }
      isVideoLoading.value = false;
      //}
    } catch (e) {
      CustomSnackbar.showSnackbar("Unable to Load the Feed");
      isVideoLoading.value = false;
    }
  }

  Future<Position?> getLatLong() async {
    try {
      Position position = await GeoServices.determinePosition();

      String address = await GeoServices.getAddress(position.latitude, position.longitude);

      SessionService().userAddress = address;
      SessionService().userLocation = Location(
        coordinates: [position.latitude, position.longitude],
      );
      SessionService().saveUserAddress();
      return position;
    } catch (e) {
      log(e.toString());
      return null;
    }
  }

  RxInt videoPreLoadLimit = 3.obs;
  RxInt currentIndex = 0.obs, previousValue = 0.obs;
  RxList<Rx<CachedVideoPlayerPlus>> videoControllers = <Rx<CachedVideoPlayerPlus>>[].obs;
  RxList<bool> isPreloaded = <bool>[].obs;
  RxBool isMoreLoading = false.obs;
  RxBool isPlaying = false.obs;
  RxBool moreLoading = false.obs;
  Future<void> initializeAllControllers(int startIndex, int limit) async {
    // isMoreLoading.value = true;
    moreLoading.value = true;
    List<Future> futures = [];
    printLogs('==============startIndex $startIndex');
    printLogs('==============limit $limit');

    // Make sure startIndex is within bounds
    if (startIndex >= posts.length) {
      startIndex = math.max(0, posts.length - 1);
    }

    // Calculate end index ensuring it doesn't exceed posts.length
    int endIndex = math.min(startIndex + limit, posts.length);

    for (int i = startIndex; i < endIndex; i++) {
      try {
        futures.add(initializeVideoPlayer(posts[i].video));
        isLoading.value = false;
      } catch (e) {
        if (kDebugMode) {
          printLogs("============catch Exception initializeAllControllers $e");
        }
      }
    }

    try {
      await Future.wait(futures);
    } catch (e) {
      if (kDebugMode) {
        printLogs("============catch Exception $e");
      }
    }

    videoControllers.refresh();
    moreLoading.value = false;
    isLoading.value = false;
    isMoreLoading.value = false;
  }

  void cleanupUnusedControllers(int currentIndex, int keepRange) {
    // Keep controllers within a certain range of the current index
    if (videoControllers.length > keepRange * 2 + 1) {
      int minKeepIndex = math.max(0, currentIndex - keepRange);
      int maxKeepIndex = math.min(videoControllers.length - 1, currentIndex + keepRange);

      // Dispose controllers outside the keep range
      for (int i = 0; i < videoControllers.length; i++) {
        if (i < minKeepIndex || i > maxKeepIndex) {
          try {
            videoControllers[i].value.dispose();
            // Mark as null after disposing
            // videoControllers[i] = Rx<CachedVideoPlayerPlusController?>(null);
          } catch (e) {
            printLogs("Error disposing controller at index $i: $e");
          }
        }
      }
    }
  }

  Future<void> initializeVideoPlayer(String videoUrl) async {
    videoControllers
        .add(Rx(CachedVideoPlayerPlus.networkUrl(Uri.parse(videoUrl), invalidateCacheIfOlderThan: const Duration(minutes: 30))));
    await videoControllers.last.value.initialize().then((_) {
      videoControllers.last.value.controller.setLooping(true);
      videoControllers.last.value.controller.setVolume(1.0);
      videoControllers.last.value.controller.pause();
    });
  }

  Future<void> initializeFutureController(int index) async {
    videoControllers.add(Rx<CachedVideoPlayerPlus>(
      CachedVideoPlayerPlus.networkUrl(Uri.parse(posts[index].video), invalidateCacheIfOlderThan: const Duration(minutes: 1)),
    ));
    await videoControllers[index].value.initialize().then((_) async {
      isPreloaded[index] = true;
      videoControllers[index].value.controller.setVolume(1.0);
      videoControllers[index].value.controller.setLooping(true);
      await videoControllers[index].value.controller.pause();
      videoControllers[index].refresh();
    });
    activeVideoIndices.add(index);
    videoControllers.refresh();
  }

  void disposeController(int index) {
    videoControllers[index].value.dispose();
    videoControllers.removeAt(index);
    isPreloaded.removeAt(index);
    activeVideoIndices.remove(index);
  }

  ///fn with pagination
  void onPageChange(int index) async {
    if (hasMorePosts.isFalse) {
      await videoControllers[index - 1].value.pause();
    }

    if (isIndexOutOfRange(index)) {
      CustomSnackbar.showSnackbar("Error: Post not found");
      return;
    } else {
      tappedPostIndex.value = index;
      printLogs("xxxxxxxxxxx Preload Starts xxxxxxxxxxx");
      printLogs('======Preload index $index');
      printLogs('======Preload index + 2 >= posts.length ${index + 2 >= posts.length}');
      printLogs('======Preload posts.length ${posts.length}');
      printLogs('======Preload index hasMorePosts.isFalse ${hasMorePosts.isFalse}');
      printLogs('======Preload index videoControllers.length ${videoControllers.length}');
      // Load more posts when reaching near the end
      if (index + 2 >= posts.length) {
        if (hasMorePosts.isFalse && videoControllers.length == posts.length) {
          printLogs("=========Preload inside if posts.length == videoControllers.length ${posts.length == videoControllers.length}");
          // No more posts to load
          return;
        } else {
          printLogs("=========Preload inside else getAllPosts ${posts.length == videoControllers.length}");
          // Trigger load more posts
          await getAllPosts(isFirstTime: false, isFromOnChange: true);
        }
      }

      // Video controller management
      if (videoControllers.isNotEmpty) {
        videoControllers[index].value.setLooping(true);
        videoControllers[index].value.setVolume(1.0);
        videoControllers[index].value.play();

        // Update view count for the current post
        updateViewCount(
          postId: posts[index].id,
          index: index,
        );
      }

      /* // Initialize new video controllers if needed
      if (index + 1 >= videoControllers.length) {
        await initializeAllControllers(index + 1, 3);
      }*/
      // Preload next batch of videos when approaching the end
// For example, start preloading when user is 3 videos away from the end
      printLogs("=========Preload videoControllers.length ${videoControllers.length}");
      printLogs("=========Preload posts.length ${posts.length}");
      printLogs("=========Preload videoControllers.length - index ${videoControllers.length - index}");
      //if (index + 1 >= videoControllers.length) {
      if (videoControllers.length - 3 <= posts.length) {
        await initializeAllControllers(videoControllers.length, 3);
      }

      printLogs("=========Preload videoControllers.length after init ${videoControllers.length}");
      printLogs("=========Preload posts.length after init ${posts.length}");
      //}
      /*if (videoControllers.length - index <= 3) {
        // Calculate next index to initialize
        int nextIndexToInitialize = videoControllers.length;

        // Only initialize if we have more posts that need controllers
        if (nextIndexToInitialize < posts.length) {
          await initializeAllControllers(nextIndexToInitialize, 3);
          printLogs("Preloaded videos starting at index $nextIndexToInitialize");
        }
      }*/
      // Add cleanup at the end
      // cleanupUnusedControllers(index, 3); // Keep 3 videos before and after current
    }
  }

  @override
  void onClose() {
    super.onClose();
    for (int i = 0; i < videoControllers.length; i++) {
      videoControllers[i].value.dispose();
    }
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

  bool isIndexOutOfRange(int index) {
    return (hasMorePosts.isFalse && index >= posts.length || index < 0);
  }

  ///other functions

  Future<void> initializeAllControllersBefore(int startIndex, int limit) async {
    isMoreLoading.value = true;
    moreLoading.value = true;
    List<Future> futures = [];
    printLogs('==============startIndex $startIndex');
    printLogs('==============limit $limit');
    for (int i = startIndex; i < startIndex + limit && i < posts.length; i++) {
      try {
        futures.add(initializeVideoPlayer(posts[i].video));
        // await initializeFutureController(i);
        isLoading.value = false;
      } catch (e) {
        if (kDebugMode) {
          printLogs("============catch Exception initializeAllControllers $e");
        }
      }
      try {
        await Future.wait(futures);
      } catch (e) {
        if (kDebugMode) {
          printLogs("============catch Exception $e");
        }
      }
    }
    videoControllers.refresh();
    moreLoading.value = false;
    isLoading.value = false;
    isMoreLoading.value = false;
  }

  Future initializeVideoPlayerNew(String videoUrl) async {
    try {
      // First check if video needs transcoding
      if (await isHighResolutionVideo(videoUrl)) {
        String transcodedUrl = await VideoServices().transcodeVideo(videoUrl);
        videoControllers.add(Rx(transcodedUrl.startsWith("https")
            ? CachedVideoPlayerPlus.networkUrl(Uri.parse(transcodedUrl), invalidateCacheIfOlderThan: const Duration(minutes: 30))
            : CachedVideoPlayerPlus.file(File(transcodedUrl))));
      } else {
        // Use original for compatible videos
        videoControllers
            .add(Rx(CachedVideoPlayerPlus.networkUrl(Uri.parse(videoUrl), invalidateCacheIfOlderThan: const Duration(minutes: 30))));
      }

      await videoControllers.last.value.initialize().then((_) {
        videoControllers.last.value.controller.setLooping(true);
        videoControllers.last.value.controller.setVolume(1.0);
        videoControllers.last.value.controller.pause();
      });
    } catch (e) {
      printLogs("Video initialization error: $e");
      // Handle error gracefully
    }
  }

// Helper to determine if video needs transcoding
  Future<bool> isHighResolutionVideo(String url) async {
    // Implementation depends on how you want to check resolution
    // Could use video_metadata package or a simple heuristic based on file size
    try {
      final metadata = await FlutterVideoInfo().getVideoInfo(url); //.getMetadata(url);
      return metadata!.width! > 1920 || metadata!.height! > 1080;
    } catch (e) {
      // If we can't determine, assume it might need transcoding
      return true;
    }
  }

  /// fn to update like and dislike
  Future<void> updateLikeDislike({
    required String postId,
    required int index,
  }) async {
    final userId = SessionService().user?.id ?? '';

    if (posts[index].likes.contains(userId)) {
      // posts[index].likes.remove(SessionService().user?.id);
      // posts[index].likesCount--;
      // posts.refresh();
      // try {
      //   final response =
      //       await PostRepo().updateUserActivity(postId: postId, likes: userId);
      //   if (response != null) {
      //     CustomSnackbar.showSnackbar("Like/Dislike Updated");
      //   }
      // } catch (e) {
      //   log('Error: $e');
      //   CustomSnackbar.showSnackbar("Unable to Update Like/Dislike");
      // }
    } else {
      posts[index].likes.add(SessionService().user?.id ?? '');
      posts[index].likesCount++;
      posts.refresh();
      try {
        final response = await PostRepo().updateUserActivity(
          postId: postId,
          likes: userId,
        );
        if (response) {
          // CustomSnackbar.showSnackbar("Like/Dislike Updated");
        }
      } catch (e) {
        CustomSnackbar.showSnackbar("Something went wrong");
      }
    }
  }

  /// fn to update view count
  Future<void> updateViewCount({required String postId, required int index}) async {
    final userId = SessionService().user?.id ?? '';
    try {
      final response = await PostRepo().updateUserActivity(
        postId: postId,
        views: userId,
      );
      if (response) {
        posts[index].views?.add(ViewsModel(id: userId, name: SessionService().user?.name ?? ""));
        posts.refresh();
        // CustomSnackbar.showSnackbar("View Count Updated");
      }
    } catch (e) {
      // CustomSnackbar.showSnackbar("Unable to Update View Count");
    }
  }

  Future<void> reportClip({required String postId, required String reason}) async {
    try {
      isLoading.value = true;
      final userId = SessionService().user?.id ?? '';

      if (kDebugMode) {
        printLogs('===========selectedReasonId.value ${selectedReasonId.value}');
      }
      final response = await PostRepo().reportPost(reason: selectedReasonId.value, postId: postId, userID: userId);
      if (kDebugMode) {
        printLogs('=====================response report post $response -------- ${response?.message}');
      }
      if (response != null && response.message == "Clip reported successfully") {
        videoControllers.removeWhere((element) =>
            element.value.dataSource == posts.firstWhere((element) => element.id == postId).video ||
            element.value.dataSource == posts.firstWhere((element) => element.id == postId).maskVideo);
        videoControllers.refresh();
        posts.removeWhere((element) => element.id == postId);
        posts.refresh();
        // Get.back();
        // Get.back();
        NotificationRepo().sendNotification(title: 'Reported Post', body: 'Your post has been reported', userId: userId);
        CustomSnackbar.showSnackbar("Clip reported successfully");
        selectedReason.value = 'Select Reason';

        DiscoverController discoverController = Get.isRegistered() ? Get.find<DiscoverController>() : Get.put(DiscoverController());
        if (discoverController.isLoading.isFalse) {
          discoverController.posts.removeWhere((element) => element.id == postId);
          discoverController.posts.refresh();
          discoverController.filteredPosts.removeWhere((element) => element.id == postId);
          discoverController.filteredPosts.refresh();
        }
        update();
      } else {
        CustomSnackbar.showSnackbar("Unable to report the clip");
      }
      isLoading.value = false;
    } catch (e) {
      CustomSnackbar.showSnackbar("Something went wrong");
      printLogs('Error : $e');
      isLoading.value = false;
    }
  }

  Future<void> blockUser({required String blockedUserId, required String reason}) async {
    try {
      isLoading.value = true;
      final userId = SessionService().user?.id ?? '';
      final response = await PostRepo().blockUser(reasonId: reason, blockedUserId: blockedUserId, userID: userId);
      if (response != null && response.message == "User blocked successfully") {
        videoControllers
            .removeWhere((element) => element.value.dataSource == posts.firstWhere((element) => element.userId.id == blockedUserId).video);
        posts.removeWhere((element) => element.userId.id == blockedUserId);
        posts.refresh();
        ProfileRepo().getFollowingUsers(userId: SessionService().user?.id ?? '').then((value) {
          SessionService().replaceFollowingList(value);
        });

        videoControllers.refresh();

        NotificationRepo().sendNotification(title: 'Blocked User', body: 'User has been blocked successfully', userId: userId);
        CustomSnackbar.showSnackbar("User blocked successfully");
        selectedReason.value = 'Select Reason';
      } else {
        CustomSnackbar.showSnackbar("Unable to block the user");
      }
      isLoading.value = false;
    } catch (e) {
      CustomSnackbar.showSnackbar("Something went wrong");
      printLogs('Error blockUser: $e');
      isLoading.value = false;
    }
  }

  onReasonDropDownChange(newValue) {
    if (newValue != null) {
      selectedReason.value = newValue;
      printLogs('=================newValue $newValue');

      selectedReasonId.value = reasonsModelReport.firstWhere((element) => element.reason == newValue).id ?? "";
      printLogs('=============selectedReasonId.value report ${selectedReasonId.value}');
    }
  }

  onBlockDropDownChange(newValue) {
    if (newValue != null) {
      selectedReason.value = newValue;
      selectedReasonId.value = reasonsModelBlock.firstWhere((element) => element.reason == newValue).id ?? "";
      printLogs('=============selectedReasonId.value block ${selectedReasonId.value}');
    }
  }

  Future<void> getReasonsOfReportingBlocking() async {
    try {
      final userId = SessionService().user?.id ?? '';

      final response = await PostRepo().getReasonsToBlockReport(isReport: true);
      printLogs('=========response $response');
      if (response != null) {
        reportingReasons.clear();
        reportingReasons.add("Select Reason");

        response.reasons?.forEach((reason) {
          if (reason.reason != null && reason.reason!.isNotEmpty && !reportingReasons.contains(reason.reason)) {
            reportingReasons.add(reason.reason ?? '');
            reasonsModelReport.add(reason);
          }
        });
      } else {
        CustomSnackbar.showSnackbar("Unable to get reasons");
      }
    } catch (e) {
      CustomSnackbar.showSnackbar("Something went wrong");
      printLogs('Error getReasonsOfReportingBlocking: $e');
    }
  }

  Future<void> getReasonsOfBlocking() async {
    try {
      final response = await PostRepo().getReasonsToBlockReport(isReport: false);
      if (response != null) {
        blockingReasons.clear();
        blockingReasons.add("Select Reason");
        response.reasons?.forEach((reason) {
          if (reason.reason != null && reason.reason!.isNotEmpty && !blockingReasons.contains(reason.reason)) {
            blockingReasons.add(reason.reason ?? '');
            reasonsModelBlock.add(reason);
          }
        });
      } else {
        CustomSnackbar.showSnackbar("Unable to get reasons");
      }
    } catch (e) {
      CustomSnackbar.showSnackbar("Something went wrong");
      printLogs('Error getReasonsOfBlocking: $e');
    }
  }

  /// fn to update share count
  Future<void> updateShareCount({
    required String postId,
    required int index,
    required String postedUserId,
  }) async {
    final userId = SessionService().user?.id ?? '';
    try {
      final response = await PostRepo().updateUserActivity(
        postId: postId,
        share: userId,
      );
      if (response) {
        posts[index].share.add(userId);
        posts.refresh();
        NotificationRepo().sendNotification(
          userId: postedUserId,
          title: 'Post Shared',
          body: 'Your post has been shared by ${SessionService().user?.name}',
        );
        // CustomSnackbar.showSnackbar("View Count Updated");
      }
    } catch (e) {
      // CustomSnackbar.showSnackbar("Unable to Update View Count");
    }
  }

  ///follow/unfollow
  RxBool isFollowStatusLoading = false.obs;
  RxMap<String, RxBool> followLoadingMap = <String, RxBool>{}.obs;
  Future<void> updateFollowStatus({required String followedUserId, required int index, bool isFromBottomSheet = false}) async {
    final userId = SessionService().user?.id ?? '';

    /// check if the user is already following the user
    bool isFollowing = false;

    isFollowing = SessionService().isFollowingById(followedUserId);
    isFollowStatusLoading.value = true;
    if (isFromBottomSheet) {
      followLoadingMap[followedUserId] = true.obs;
      followLoadingMap.refresh();
    }
    try {
      if (isFollowing) {
        await ProfileRepo().unFollowUser(userId: SessionService().user!.id, followedUserId: followedUserId).then((d) {
          // SessionService().userDetail?.following.remove(followedUserId);
          CustomSnackbar.showSnackbar("You have unfollowed the user");
        });
      } else {
        await ProfileRepo().followUser(userId: SessionService().user!.id, followUserId: followedUserId).then((value) {
          printLogs('==========SessionService().followingUsersIDs ${SessionService().followingUsersIDs}');

          // SessionService().userDetail?.following.add(followedUserId);
          //SessionService().replaceFollowingList(SessionService().following);
          printLogs('==========SessionService().followingUsersIDs after add ${SessionService().followingUsersIDs}');
          NotificationRepo().sendNotification(
            userId: followedUserId,
            title: 'New Follower',
            body: '${SessionService().user!.name} started following you',
          );
          CustomSnackbar.showSnackbar("You have followed the user");
        });
      }
    } catch (e) {
      CustomSnackbar.showSnackbar("Unable to Update Follow Status");
    }
    isFollowStatusLoading.value = false;
    if (isFromBottomSheet) {
      followLoadingMap[followedUserId] = false.obs;
      followLoadingMap.refresh();
      searchBottomSheetList.refresh();
    }
  }

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
        followLoadingMap[model.id] = false.obs;
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

  Future<void> onOtherUserView(String userId) async {
    isLoading.value = true;
    Get.toNamed(kFollowersProfileScreen, arguments: userId);
    isLoading.value = false;
  }

  Future<void> getUserProfile() async {
    try {
      final userID = SessionService().user!.id;
      if (kDebugMode) {
        printLogs('User ID: $userID');
      }
      final value = await ProfileRepo().getUserProfile(userId: userID);
      if (value != null) {
        // userData.value = value;
        SessionService().userDetail = value;
        SessionService().saveUserDetails();
        SessionService().followingUsersIDs.value = SessionService().userDetail?.following ?? [];
        updateUserLocationData();
        getAllFollowersProfileData();
      } else {
        CustomSnackbar.showSnackbar('Error in getting user profile');
      }
    } catch (e) {
      printLogs('============user profile home controller exception $e');
      CustomSnackbar.showSnackbar('Error in getting user profile');
    }
    isLoading.value = false;
  }

  Future updateUserLocationData() async {
    Position? position = await getLatLong();
    final value = await ProfileRepo()
        .updateUserLocationData(userId: SessionService().user!.id, lat: position?.latitude ?? 0.0, lng: position?.longitude ?? 0.0);
    if (value != null) {
      printLogs('==========Location updated');
    } else {
      printLogs('==========Location not updated');
    }
  }

  getAllFollowersProfileData() {
    ProfileRepo().getFollowingUsers(userId: SessionService().user?.id ?? '').then((value) {
      SessionService().replaceFollowingList(value);
    });
  }

  /// sorting function
  void sortPostsByRecent() {
    posts.sort((a, b) => (b.date ?? DateTime(0)).compareTo(a.date ?? DateTime(0)));

    // for (int i = 0; i < posts.length; i++) {
    //   log('Post: ${posts[i].date}');
    // }
  }

  Future<void> sortPostsByLocation() async {
    final position = await GeoServices.determinePosition();
    posts.sort((a, b) {
      final aLocation = Location(coordinates: a.location?.coordinates ?? [0.0, 0.0]);
      final bLocation = Location(coordinates: b.location?.coordinates ?? [0.0, 0.0]);
      final aDistance = GeoServices.calculateDistance(position.latitude, position.longitude, aLocation);
      final bDistance = GeoServices.calculateDistance(position.latitude, position.longitude, bLocation);
      final result = aDistance.compareTo(bDistance);
      printLogs('Distance: $aDistance, $bDistance, $result == ${a.id}');
      return result;
    });
    sortPostsByRecent();
  }

  Future<void> sortPostsByFollowing() async {
    final userId = SessionService().user?.id ?? '';
    try {
      final response = await ProfileRepo().getFollowingUsers(userId: userId);
      final followingUsers = response;
      posts.sort((a, b) {
        final aUserId = a.userId.id;
        final bUserId = b.userId.id;
        final aIndex = followingUsers.indexWhere((user) => user.id == aUserId);
        final bIndex = followingUsers.indexWhere((user) => user.id == bUserId);
        final result = aIndex.compareTo(bIndex);
        printLogs('Following: $aIndex, $bIndex, $result == ${a.id}');
        return result;
      });
      sortPostsByLocation();
    } catch (e) {
      CustomSnackbar.showSnackbar("Unable to Load the Feed");
    }
    isLoading.value = false;
  }

  Future<void> setRating(double rating, int index) async {
    isRatingTapped.value = false;
    final userId = SessionService().user?.id ?? '';
    try {
      final response = await PostRepo().setRating(rating, posts[index].id, userId);
      if (response != null) {
        ratingValue.value = rating;
        posts[index].averageRating = response.averageRating;
        posts.refresh();
        NotificationRepo().sendNotification(
          userId: posts[index].userId.id,
          title: 'Rating Updated',
          body: 'Your post has been rated $rating by ${SessionService().user?.name}',
        );
      }
    } catch (e) {
      CustomSnackbar.showSnackbar("Unable to Submit Rating");
    }
  }

  /// fn to get avilable videos in temp
  /// not in use
  RxList<String> availableVideos = <String>[].obs;
  Future<void> getAvailableVideos() async {
    try {
      final response = Platform.isIOS ? await VideoServices().getTempVideosForIOS() : await VideoServices().getTempVideosForAndroid();
      availableVideos.assignAll(response);
      final address = await GeoServices.getAddress(
        SessionService().userLocation?.coordinates?[0] ?? 0.0,
        SessionService().userLocation?.coordinates?[1] ?? 0.0,
      );
      if (availableVideos.isEmpty) {
        return;
      }

      List<Map> videoDetail = await SharedPrefrenceService.getTempVideos();
      if (availableVideos.isNotEmpty) {
        String userId = SessionService().user?.id ?? '';
        if (videoDetail.isEmpty) {
          for (int i = 0; i < availableVideos.length; i++) {
            final thumbnail = await VideoServices().getThumbnailData(availableVideos[i]);
            final thumbnailFile = await CommonCode().generateFile(thumbnail ?? Uint8List(0), 'thumbnail.jpg');

            PostRepo()
                .createPost(
              userId: userId,
              // mentions: [],
              // tags: [],
              file: File(availableVideos[i]),
              thumbnailFile: thumbnailFile,
              locationAdress: address,
              lat: SessionService().userLocation?.coordinates?[0] ?? 0.0,
              lng: SessionService().userLocation?.coordinates?[1] ?? 0.0,
              isFaceCam: false,
              isPortrait: false,
            )
                .then((value) {
              SharedPrefrenceService.removeTempVideo(availableVideos[i]);
              VideoServices().removeTempVideo(availableVideos[i]);
            });
          }
          return;
        } else {
          for (int i = 0; i < videoDetail.length; i++) {
            final thumbnail = await VideoServices().getThumbnailData(videoDetail[i]['path']);
            final thumbnailFile = await CommonCode().generateFile(thumbnail ?? Uint8List(0), 'thumbnail.jpg');

            PostRepo()
                .createPost(
              userId: userId,
              mentions: videoDetail[i].entries.where((element) => element.key.contains('mentions')).map((e) => e.value as String).toList(),
              tags: videoDetail[i].entries.where((element) => element.key.contains('tags')).map((e) => e.value as String).toList(),
              file: File(videoDetail[i]['videoPath']),
              thumbnailFile: thumbnailFile,
              locationAdress: address,
              lat: SessionService().userLocation?.coordinates?[0] ?? 0.0,
              lng: SessionService().userLocation?.coordinates?[1] ?? 0.0,
              isFaceCam: videoDetail[i]['isFaceCam'],
              isPortrait: videoDetail[i]['isPortrait'],
            )
                .then((value) {
              SharedPrefrenceService.removeTempVideo(videoDetail[i]['videoPath']);
              VideoServices().removeTempVideo(videoDetail[i]['videoPath']);
            });
          }
        }
      }
    } catch (e) {
      // CustomSnackbar.showSnackbar("Something went wrong");
      printLogs('Error getAvailableVideos: $e');
    }
  }
}
