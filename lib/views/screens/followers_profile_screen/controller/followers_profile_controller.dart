import 'package:cached_video_player_plus/cached_video_player_plus.dart';
import 'package:card_swiper/card_swiper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:socials_app/models/passion_model.dart';
import 'package:socials_app/models/post_models.dart';
import 'package:socials_app/models/reasons_report_block_model.dart';
import 'package:socials_app/models/usermodel.dart';
import 'package:socials_app/repositories/notification_repo.dart';
import 'package:socials_app/repositories/post_repo.dart';
import 'package:socials_app/repositories/profile_repo.dart';
import 'package:socials_app/services/custom_snackbar.dart';
import 'package:socials_app/services/session_services.dart';
import 'package:socials_app/views/screens/discover/controller/discover_controller.dart';
import 'package:socials_app/views/screens/home/controller/home_controller.dart';
import 'package:socials_app/views/screens/profile/controller/profile_controller.dart';

import '../../../../utils/common_code.dart';

class FollowersProfileController extends GetxController {
  GlobalKey<ScaffoldState> scaffoldKeyProfile = GlobalKey<ScaffoldState>();
  GlobalKey<ScaffoldState> scaffoldKeySwipe = GlobalKey<ScaffoldState>();
  GlobalKey<ScaffoldState> scaffoldKeyDetailPost = GlobalKey<ScaffoldState>();
  Rx<UserDetailModel?> followerDetail = Rx<UserDetailModel?>(null);
  RxList<PostModel> followerPosts = <PostModel>[].obs;
  RxBool isLoading = false.obs;
  RxBool isGettingPosts = false.obs;
  ScrollController scrollController = ScrollController();
  PageController pageController = PageController(viewportFraction: 0.4);
  RxInt leftmostVisibleIndex = 0.obs;
  RxString followerId = ''.obs;
  Rx<CachedVideoPlayerPlus> videoControllerDetail = CachedVideoPlayerPlus.networkUrl(Uri.parse('')).obs;
  // Rx<VideoPlayerController> videoControllerDetail = VideoPlayerController.networkUrl(Uri.parse('')).obs;
  Rxn<PostModel> postDetail = Rxn<PostModel>();
  RxBool isPlaying = true.obs;
  @override
  void onInit() {
    getData();
    scrollController.addListener(_onScroll);
    super.onInit();
  }

  void _onScroll() {
    double offset = scrollController.offset;
    int newIndex = (offset / 180.w).floor();
    if (newIndex != leftmostVisibleIndex.value) {
      leftmostVisibleIndex.value = newIndex;
    }
  }

  RxString userId = ''.obs;
  Future<void> getData() async {
    try {
      isLoading.value = true;
      userId.value = Get.arguments;
      followerId.value = userId.value;
      followerPosts.clear();
      followerDetail.value = null;
      await ProfileRepo().getUserProfile(userId: userId.value).then((value) async {
        if (value != null) {
          followerDetail.value = null;
          followerDetail.value = value;

          followerDetail.refresh();
          List<Future> futureResponses = [];
          // futureResponses.add(getFollowingUsers()); ///TODO uncomint if we need to show following users
          // futureResponses.add(getFollowersUsers());
          futureResponses.add(getUserPosts(userId.value));
          futureResponses.add(getReasonsOfBlocking());
          futureResponses.add(getUserPassions());
          await Future.wait(futureResponses);
          isLoading.value = false;
        } else {
          CustomSnackbar.showSnackbar('Error Fetching User Profile');
          isLoading.value = false;
        }
      });
      isLoading.value = false;
    } catch (e) {
      CustomSnackbar.showSnackbar('Error in getting user profile');
    }
    isLoading.value = false;
  }

  RxList<UserDetailModel> followersUsers = <UserDetailModel>[].obs;
  RxBool isFollowersUsersLoading = false.obs;
  RxList<UserDetailModel> followingUsers = <UserDetailModel>[].obs;
  RxBool isFollowingUsersLoading = false.obs;
  Future<void> getFollowingUsers() async {
    followingUsers.clear();
    isFollowingUsersLoading.value = true;
    try {
      List<Future<UserDetailModel?>> futureResponses = [];
      for (var id in followerDetail.value?.following ?? []) {
        futureResponses.add(ProfileRepo().getUserProfile(userId: id));
      }
      final responses = await Future.wait(futureResponses);
      followingUsers.assignAll(responses.whereType<UserDetailModel>());
    } catch (e) {
      CustomSnackbar.showSnackbar("Something went wrong");
      printLogs('Error getFollowingUsers: $e');
    }
    isFollowingUsersLoading.value = false;
  }

  Future<void> getFollowersUsers() async {
    followersUsers.clear();
    isFollowersUsersLoading.value = true;
    try {
      List<Future<UserDetailModel?>> futureResponses = [];
      for (var id in followerDetail.value?.followers ?? []) {
        futureResponses.add(ProfileRepo().getUserProfile(userId: id));
      }
      final responses = await Future.wait(futureResponses);
      followersUsers.assignAll(responses.whereType<UserDetailModel>());
    } catch (e) {
      CustomSnackbar.showSnackbar("Something went wrong");
      printLogs('Error getFollowersUsers: $e');
    }
    isFollowersUsersLoading.value = false;
  }

  RxBool isFollowersLoading = false.obs;
  RxList<UserDetailModel> viewedUsers = <UserDetailModel>[].obs;
  Future<void> updateFollowStatusOld({
    required String followedUserId,
  }) async {
    final currentUserId = SessionService().user?.id;
    if (currentUserId == null) {
      CustomSnackbar.showSnackbar('Error: User not found');
      return;
    }

    isLoading.value = true;

    try {
      if (SessionService().userDetail?.following.contains(followedUserId) ?? false) {
        printLogs('Unfollowing User: $followedUserId');
        final response = await ProfileRepo().unFollowUser(userId: currentUserId, followedUserId: followedUserId);

        if (response != null) {
          followerDetail.value?.followers.remove(followedUserId);
          // searchBottomSheetList[index].followers.remove(followedUserId);
          getUserProfile(userId.value);
          // ProfileRepo()
          //     .getFollowingUsers(userId: SessionService().user!.id)
          //     .then((data) {
          //   SessionService().replaceFollowingList(data);
          // });
        }
      } else {
        printLogs('Following User: $followedUserId');
        final response = await ProfileRepo().followUser(userId: currentUserId, followUserId: followedUserId);
        if (response != null) {
          SessionService().userDetail?.followers.add(followedUserId);
          NotificationRepo()
              .sendNotification(title: 'New Follower', body: 'You have a new follower: ${followerDetail.value?.name}', userId: followedUserId);
          getUserProfile(userId.value);
          // ProfileRepo().getFollowingUsers(userId: currentUserId).then((value) {
          //   SessionService().replaceFollowingList(value);
          // });
        }
      }
      followerDetail.refresh();
      viewedUsers.refresh();
    } catch (e) {}

    isLoading.value = false;
  }

  Future<List<PostModel>?> getUserPosts(String? userId) async {
    try {
      isGettingPosts.value = true;
      final userID = userId;
      Map<String, dynamic> body = {
        "userId": userID,
      };
      final value = await PostRepo().getUserPosts(
        userId: userID ?? '',
        body: body,
      );
      if (value != null) {
        followerPosts.clear();
        followerPosts.value = value.posts;

        followerPosts.sort((a, b) => (b.date ?? DateTime(0)).compareTo(a.date ?? DateTime(0)));
        followerPosts.sort((a, b) => b.views?.length ?? 0.compareTo(a.views?.length ?? 0));
        isGettingPosts.value = false;
        // isPostDownloading.assignAll(List.generate(followerPosts.length, (index) {
        //   return false.obs;
        // }));
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
      printLogs('Error getReasonsOfBlocking: $e');
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
        if (followerDetail.value?.followers.contains(blockedUserId) ?? false) {
          followerDetail.value?.followers.remove(blockedUserId);
          if (followersUsers.any((element) => element.id == blockedUserId)) {
            followersUsers.remove(followersUsers.firstWhere((element) => element.id == blockedUserId));
          }
        }
        if (followerDetail.value?.following.contains(blockedUserId) ?? false) {
          followerDetail.value?.following.remove(blockedUserId);
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
      printLogs('Error blockUser: $e');
      isLoading.value = false;
    }
  }

  onReasonDropDownChange(newValue) {
    if (newValue != null) {
      selectedReason.value = newValue;
      selectedReasonId.value = reportingReasons.firstWhere((element) => element.reason == newValue).id.toString();
    }
  }

  ///// Swipe code /////......
  SwiperController swiperController = SwiperController();
  RxBool isRatingTapped = false.obs;
  RxBool isVideoLoading = false.obs;
  RxDouble userRating = 0.0.obs;
  RxList<CachedVideoPlayerPlus> videoControllers = <CachedVideoPlayerPlus>[].obs;
  // RxList<VideoPlayerController> videoControllers = <VideoPlayerController>[].obs;

  Future<void> initializeAllControllers(int startIndex, int limit) async {
    isVideoLoading.value = true;
    if (startIndex < 0 || limit > followerPosts.length) {
      CustomSnackbar.showSnackbar("Error: Index out of range");
      return;
    }
    for (int i = startIndex; i < startIndex + limit && i < followerPosts.length; i++) {
      try {
        await initializeVideoPlayer(followerPosts[i].video);
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
    return index >= followerPosts.length;
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
    await videoControllers[index - 1].controller.pause();
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
        videoControllers[index].controller.setLooping(true);
        videoControllers[index].controller.setVolume(1.0);
        videoControllers[index].controller.play();
      }
    }
  }

  RxBool isVideoLoadingDetail = false.obs;
  void selectPost(PostModel post) async {
    isVideoLoadingDetail.value = true;
    postDetail.value = post;
    videoControllerDetail.value =
        CachedVideoPlayerPlus.networkUrl(Uri.parse(post.video), invalidateCacheIfOlderThan: const Duration(minutes: 30));
    /*videoControllerDetail.value = VideoPlayerController.networkUrl(
      Uri.parse(post.video),
    );*/
    await videoControllerDetail.value.initialize().then((_) {
      videoControllerDetail.value.controller.play();
      videoControllerDetail.value.controller.setLooping(true);
    });
    videoControllerDetail.refresh();
    isVideoLoadingDetail.value = false;
  }

  void disposeVideoControllerDetail() {
    videoControllerDetail.value.dispose();
    isLoading.value = false;
    isVideoLoadingDetail.value = false;
    isVideoLoading.value = false;
    postDetail.value = null;
  }

  Future<void> updateLikeDislike({required String postId}) async {
    try {
      final userId = SessionService().user?.id ?? '';
      int postIndex = followerPosts.indexWhere((element) => element.id == postId);
      HomeScreenController homeController = Get.find<HomeScreenController>();
      if (postIndex != -1) {
        if (followerPosts[postIndex].likes.contains(userId)) {
          // followerPosts[postIndex].likes.remove(userId);
          // followerPosts[postIndex].likesCount -= 1;
          // followerPosts.refresh();
          // Get.log("refresed ");
        } else {
          followerPosts[postIndex].likes.add(userId);
          followerPosts[postIndex].likesCount += 1;
          followerPosts.refresh();
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
      int postIndex = followerPosts.indexWhere((element) => element.id == postId);
      HomeScreenController homeController = Get.find<HomeScreenController>();
      if (postIndex != -1) {
        followerPosts[postIndex].share.add(SessionService().user?.id ?? '');
        followerPosts[postIndex].sharesCount += 1;
        followerPosts.refresh();
        await PostRepo().updateUserActivity(postId: postId, share: SessionService().user?.id ?? '');
        int index = homeController.posts.indexWhere((element) => element.id == postId);
        homeController.posts[index].share.add(SessionService().user?.id ?? '');
        homeController.posts[index].sharesCount += 1;
        homeController.posts.refresh();
        NotificationRepo().sendNotification(
            title: 'Post Shared', body: 'Your post has been shared by ${followerDetail.value?.name}', userId: homeController.posts[index].userId.id);
      }
    } catch (e) {}
  }

  Future<void> getUserProfile(String? userId) async {
    try {
      final userID = userId;

      SessionService().saveUserDetails();
      ProfileScreenController profileController = Get.find<ProfileScreenController>();
      profileController.getUserProfile(userId);
      final value = await ProfileRepo().getUserProfile(userId: userID ?? '');
      if (value != null) {
        followerDetail.value = null;
        followerDetail.value = value;

        followerDetail.refresh();
      }
    } catch (e) {
      CustomSnackbar.showSnackbar('Error in getting user profile');
    }
    isLoading.value = false;
  }

  RxList<Passion> userPassions = <Passion>[].obs;
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

  RxBool isFollowStatusLoading = false.obs;
  Future<void> updateFollowStatus({required String followedUserId}) async {
    final userId = SessionService().user?.id ?? '';

    /// check if the user is already following the user
    bool isFollowing = false;

    isFollowing = SessionService().isFollowingById(followedUserId);
    isFollowStatusLoading.value = true;
    try {
      if (isFollowing) {
        await ProfileRepo().unFollowUser(userId: SessionService().user!.id, followedUserId: followedUserId).then((d) {
          // SessionService().userDetail?.following.remove(followedUserId);
          CustomSnackbar.showSnackbar("You have unfollowed the user");
          followerDetail.value?.followers.remove(SessionService().user!.id);
        });
      } else {
        await ProfileRepo().followUser(userId: SessionService().user!.id, followUserId: followedUserId).then((value) {
          printLogs('==========SessionService().followingUsersIDs ${SessionService().followingUsersIDs}');
          followerDetail.value?.followers.add(SessionService().user!.id);
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
  }
}
