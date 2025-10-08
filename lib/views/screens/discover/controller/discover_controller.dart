import 'dart:developer';

import 'package:cached_video_player_plus/cached_video_player_plus.dart';
import 'package:card_swiper/card_swiper.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:pull_to_refresh_flutter3/pull_to_refresh_flutter3.dart';
import 'package:socials_app/models/discover_models/search_model.dart';
import 'package:socials_app/models/editors_model.dart';
import 'package:socials_app/models/post_models.dart';
import 'package:socials_app/models/reasons_report_block_model.dart';
import 'package:socials_app/repositories/notification_repo.dart';
import 'package:socials_app/repositories/post_repo.dart';
import 'package:socials_app/repositories/profile_repo.dart';
import 'package:socials_app/services/custom_snackbar.dart';
import 'package:socials_app/services/geo_services.dart';
import 'package:socials_app/services/notification_sevices.dart';
import 'package:socials_app/services/sharedprefrence_service.dart';
import 'package:socials_app/services/videoservices.dart';
import 'package:socials_app/utils/app_images.dart';
import 'package:socials_app/utils/app_strings.dart';
import 'package:socials_app/views/screens/home/controller/home_controller.dart';
import 'package:socials_app/views/screens/profile/controller/profile_controller.dart';
import 'package:super_tooltip/super_tooltip.dart';

import '../../../../models/usermodel.dart';
import '../../../../services/session_services.dart';
import '../../../../utils/app_colors.dart';
import '../../../../utils/common_code.dart';

class DiscoverController extends GetxController {
  GlobalKey<ScaffoldState> scaffoldKeyDiscover = GlobalKey<ScaffoldState>();
  GlobalKey<ScaffoldState> scaffoldKeyFilter = GlobalKey<ScaffoldState>();
  GlobalKey<ScaffoldState> scaffoldKeySearch = GlobalKey<ScaffoldState>();
  GlobalKey<ScaffoldState> scaffoldKeySwipe = GlobalKey<ScaffoldState>();

  ScrollController scrollController = ScrollController();
  SuperTooltipController tooltipControllerFilters = SuperTooltipController();
  RxBool isScrolled = false.obs;
  RxList gridList = [
    kImage1,
    kImage2,
    kImage3,
    kImage4,
    kImage5,
    kImage6,
    kImage7,
    kImage8,
  ].obs;
  TextEditingController search = TextEditingController();
  TextEditingController locationSearch = TextEditingController();
  RxString selectedLocation = 'Select Location'.obs;
  RxBool isExpanded = false.obs;
  RxList hashtagList = ['#BarcelonaVSRealMadrid', '#penalties', '#FreeKick', '#Goal', '#SUUUUIIIIII'].obs;
  RxBool isLoading = false.obs;
  RxBool isLoadMore = false.obs;
  RxBool isLoadingEditors = false.obs;
  RefreshController refreshController = RefreshController(initialRefresh: false);
  RxList<String> locationList = [
    'Aberdeen',
    'Amsterdam',
    'Athens',
    'Austin',
    'Barcelona',
    'Berlin',
    'Birmingham',
    'Boston',
    'Chicago',
    'Copenhagen',
    'Dallas',
    'Denver',
    'Edinburgh',
    'Florence',
    'Frankfurt',
    'Glasgow',
    'Hamburg',
    'Helsinki',
    'Houston',
    'Las Vegas',
    'Leeds',
    'Liverpool',
    'London',
    'Los Angeles',
    'Madrid',
    'Manchester',
    'Miami',
    'Milan',
    'Munich',
    'New York',
    'Newcastle',
    'Nice',
    'Orlando',
    'Oslo',
    'Oxford',
    'Paris',
    'Philadelphia',
    'Portland',
    'Prague',
    'Rome',
    'San Francisco',
    'Seattle',
    'Sheffield',
    'Stockholm',
    'Toronto',
    'Truro',
    'Vancouver',
    'Venice',
    'Vienna',
    'Washington',
    'Winchester',
    'Zurich'
  ].obs;
  // VideoPlayerController? videoController;
  RxList<String> recentSearchList = [
    'UK',
    'America',
    'South Asia',
  ].obs;
  RxBool isVideoLoading = false.obs;
  RxBool isLoadingUsers = false.obs;
  RxList<SearchModel> searchList = RxList();
  SwiperController swiperController = SwiperController();

  RxList<String> filteredList = <String>[].obs;
  // RxList<Map<String, dynamic>> filteredSearchList =
  //     <Map<String, dynamic>>[].obs;
  RxList<SearchModel> filteredSearchList = <SearchModel>[].obs;
  RxDouble lat = 0.0.obs;
  RxDouble long = 0.0.obs;
  RxString address = ''.obs;
  RxList<String> selectedHashtags = <String>[].obs;
  RxList<String> selectedMentions = <String>[].obs;
  RxString selectedLocationName = ''.obs;
  RxDouble selectedLat = 0.0.obs;
  RxDouble selectedLong = 0.0.obs;
  RxBool isRatingTapped = false.obs;
  RxBool isPlaying = true.obs;
  RxList<String> reportingReasons = RxList();
  RxList<String> blockingReasons = RxList();
  RxList<ReasonModel> reasonsModelReport = RxList();
  RxList<ReasonModel> reasonsModelBlock = RxList();
  RxString selectedReason = 'Select Reason'.obs;

  @override
  void onInit() {
    super.onInit();
    // initializeController();
  }

  void initializeController() {
    locationSearch.addListener(() {
      filterLocations(locationSearch.text);
    });
    search.addListener(() {
      filterSearch(search.text);
    });

    scrollController.addListener(() {
      if (currentPage.value > 0 && scrollController.position.pixels >= scrollController.position.maxScrollExtent * 0.85 && isLoadMore.isFalse) {
        if (currentPage.value > 0 && scrollController.position.pixels == scrollController.position.maxScrollExtent) {
          loadMorePosts();
        }
      } /*else if (currentPage.value == 0 && (totalPixels.value == 0 || totalPixels.value <= scrollController.position.pixels)) {
        printLogs('=======inside else if of pixels');
        if (totalPixels.value == 0 || totalPixels < scrollController.position.pixels) {
          totalPixels.value = scrollController.position.pixels;
          CustomSnackbar.showSnackbar("No more posts to load");
        }

        return;
      }*/
      if (scrollController.offset > 100 && !isScrolled.value) {
        isScrolled.value = true;
        update();
      } else if (scrollController.offset <= 100 && isScrolled.value) {
        isScrolled.value = false;
        update();
      }
    });
    getUserProfile();
    getRecentSearch();
    getLatLong();
    getAllPosts(isFirstTime: true);
    getReasonsOfReportingBlocking();
    getReasonsOfBlocking();

    // getAllUsersSearch();
    //getActiveEditors();
  }

  @override
  void onReady() {
    // TODO: implement onReady
    super.onReady();
    Fluttertoast.showToast(
      msg: "Choose a location on the map to see videos from in and around that area",
      toastLength: Toast.LENGTH_LONG,
      gravity: ToastGravity.CENTER,
      timeInSecForIosWeb: 1,
      // backgroundColor: kGreyContainerColor,
      textColor: kPrimaryColor,
      fontSize: 16.0,
    );
    // CustomSnackbar.showSnackbar("Choose a location on the map to see videos from in and around that area");
  }

  Future<void> loadMorePosts() async {
    if (currentPage.value <= totalPostPages.value) {
      await getAllPosts(isFirstTime: false);
    }
  }

  void filterLocations(String query) async {
    if (query.isEmpty) {
      filteredList.clear();
    } else {
      await GeoServices.fetchSuggestions(query).then((value) {
        filteredList.assignAll(value);
        filteredList.refresh();
      });

      // filteredList.value = locationList
      //     .where((location) =>
      //         location.toLowerCase().contains(query.toLowerCase()))
      //     .toList();
    }
  }

  void filterSearch(String query) {
    if (query.isEmpty) {
      filteredSearchList.assignAll(searchList);
    } else {
      filteredSearchList.assignAll(searchList.where((item) {
        final name = item.name.toLowerCase();
        final tags = item.hashtags.map((tag) => tag.toLowerCase()).toList();

        bool locationMatches = true;
        bool hashtagMatches = true;

        // Check if the location matches
        if (selectedLocationName.value.isNotEmpty) {
          locationMatches = item.location == selectedLocationName.value;
        }

        // Check if any of the item's tags match the query
        if (query.isNotEmpty) {
          hashtagMatches = tags.any((tag) => tag.contains(query.toLowerCase()));
        }

        // Return true if both name, location, and tags match
        return name.contains(query.toLowerCase()) && locationMatches || hashtagMatches;
      }).toList());
    }
  }

  // void filterSearch(String query) {
  //   if (query.isEmpty) {
  //     filteredSearchList.clear();
  //   } else {
  //     log('Query: $query');
  //     log('Selected Location: ${selectedLocationName.value}');
  //     filteredSearchList.assignAll(searchList.where((item) {
  //       final name = item.name.toLowerCase();
  //       final tags = item.hashtags.map((tag) => tag.toLowerCase()).toList();
  //       bool locationMatches = true;
  //       bool hashtagMatches = true;
  //       if (selectedLocationName.value.isNotEmpty) {
  //         locationMatches = item.location == selectedLocationName.value;
  //       }

  //       /// filter on tags
  //       if (tags.isNotEmpty) {
  //         hashtagMatches = tags
  //             .any((tag) => query.toLowerCase().contains(tag.toLowerCase()));
  //       }
  //       return name.contains(query.toLowerCase()) &&
  //           locationMatches &&
  //           hashtagMatches;
  //     }).toList());
  //   }
  // }

  void toggleFollowStatus(int index) {
    SearchModel updatedItem = filteredSearchList[index];
    updatedItem.isFollowed = !updatedItem.isFollowed;
    filteredSearchList[index] = updatedItem;
    ProfileScreenController profileCont = Get.isRegistered() ? Get.find<ProfileScreenController>() : Get.put(ProfileScreenController());
    if (updatedItem.isFollowed) {
      ProfileRepo().followUser(userId: SessionService().user!.id, followUserId: updatedItem.userId).then((value) {
        NotificationRepo().sendNotification(
          userId: updatedItem.userId,
          title: 'New Follower',
          body: '${SessionService().user!.name} started following you',
        );
        profileCont.getUserProfile(SessionService().user?.id);
      });
      int userIndex = searchList.indexWhere((element) => element.userId == updatedItem.userId);

      int followers = int.parse(searchList[userIndex].followers.split(" ")[0]) + 1;
      searchList[userIndex].followers = '${followers >= 1000 ? NumberFormat.compactCurrency(
          decimalDigits: 2,
          symbol: '',
        ).format(followers) : followers} followers';
    } else {
      ProfileRepo().unFollowUser(userId: SessionService().user!.id, followedUserId: updatedItem.userId).then((d) {});
      int userIndex = searchList.indexWhere((element) => element.userId == updatedItem.userId);

      int followers = int.parse(searchList[userIndex].followers.split(" ")[0]) - 1;
      searchList[userIndex].followers = '${followers >= 1000 ? NumberFormat.compactCurrency(
          decimalDigits: 2,
          symbol: '',
        ).format(followers) : followers} followers';
    }
    search.clear();
  }

  ////....old fn commented out just in case we need it later....//////
  // void filterSearch(String query) {
  //   if (query.isEmpty) {
  //     filteredSearchList.clear();
  //   } else {
  //     filteredSearchList.assignAll(searchList.where((item) {
  //       final name = item['name'].toString().toLowerCase();
  //       return name.contains(query.toLowerCase());
  //     }).toList());
  //   }
  // }

  void removeRecentSearch(String search) {
    recentSearchList.remove(search);
  }

  getLatLong() async {
    try {
      Position position = await GeoServices.determinePosition();

      lat.value = position.latitude;
      long.value = position.longitude;

      /// Get address from lat and long
      address.value = await GeoServices.getAddress(lat.value, long.value);
    } catch (e) {
      log(e.toString());
    }
  }

  /// fn to clear filter
  void clearFilter() {
    selectedLocationName.value = '';
    search.clear();
    locationSearch.clear();
    filterSearch('');
    selectedLocation.value = 'Select Location';
    filteredPosts.assignAll(posts);
    radius.value = 0.0;
    selectedHashtags.clear();
  }

  RxInt currentPage = 1.obs;
  RxDouble totalPixels = 0.0.obs;

  /// fn to get location from lat and long and adress

  RxDouble latitude = 0.0.obs;
  RxDouble longitude = 0.0.obs;
  Future<Position?> getLocation() async {
    // TODO get location
    try {
      // isLoading.value = true;
      return await GeoServices.determinePosition();
    } catch (e) {
      printLogs(e.toString());
      return null;
    }
  }

  /// fn to get all post
  RxList<PostModel> posts = <PostModel>[].obs;
  RxInt totalPostPages = 1.obs;
  Future<void> getAllPosts({required bool isFirstTime}) async {
    if (isFirstTime) {
      isLoading.value = true;
      printLogs("=======getAllPost loading is true");
    } else {
      isLoadMore.value = true;
    }
    try {
      Position? position = await getLocation();

      latitude.value = position?.latitude ?? 0.0;
      longitude.value = position?.longitude ?? 0.0;
      final response = await PostRepo().getAllPosts(pageNum: isFirstTime ? 1 : currentPage.value, lat: latitude.value, lng: longitude.value);
      /* if (response != null && response.totalPages != currentPage.value && isFirstTime) {
        currentPage.value = response.totalPages;
        await getAllPosts(isFirstTime: false);
      } else*/
      if (response != null) {
        totalPostPages.value = response.totalPages;

        posts.addAll(response.posts);
        filteredPosts.addAll(response.posts);
        posts.removeWhere(
          (element) =>
              element.reportedBy.contains(SessionService().user?.id) ||
              SessionService().isBlocked(element.userId.id) ||
              element.userId.id == SessionService().user?.id,
        );
        filteredPosts.removeWhere(
          (element) =>
              element.reportedBy.contains(SessionService().user?.id) ||
              SessionService().isBlocked(element.userId.id) ||
              element.userId.id == SessionService().user?.id,
        );

        ///Removed as already sorted from backend
        // posts.sort((a, b) => b.date!.compareTo(a.date!));
        // filteredPosts.sort((a, b) => b.date!.compareTo(a.date!));
        final areas = posts.map((e) => e.area).where((area) => area != null).cast<String>().toSet().toList();
        locationList.clear();
        locationList.addAll(areas);
        isLoading.value = false;
        printLogs("=======getAllPost loading is false if 1");
        getThumbnailData();
        await getAllUsersSearch();
        currentPage.value++;
        printLogs('=======discovery posts length ======== ${posts.length}');
        printLogs('=======discovery posts currentPage.value ======== ${currentPage.value}');
        if (posts.length < 15) {
          initializeAllControllers(isFirstTime ? 0 : videoControllers.length, filteredPosts.length - 1);
          loadMorePosts();
        } else {
          initializeAllControllers(isFirstTime ? 0 : videoControllers.length, filteredPosts.length - 1);
          isLoadMore.value = false;
          isLoading.value = false;
          printLogs("=======getAllPost loading is false else 1");
        }
      } else {
        isLoadMore.value = false;
        isLoading.value = false;
        printLogs("=======getAllPost loading is false else 2");
      }
    } catch (e) {
      printLogs("============discovery controller get all posts exception $e");
      // CustomSnackbar.showSnackbar("Unable to Load the Feed");
      isLoadMore.value = false;

      isLoading.value = false;
      printLogs("=======getAllPost loading is false in catch");
    }
  }

  /// filter thorugh post based on location
  RxList<PostModel> filteredPosts = <PostModel>[].obs;
  RxBool isFilterSLiderTapped = false.obs;
  RxDouble radius = 1.0.obs;
  RxDouble radiusMinLimit = 0.0.obs;
  RxDouble radiusMaxLimit = 10000.0.obs;
  // 100 meter to 10km
  // 100 1, 2 ,4, 8, 10
  Future<List<PostModel>> filterPostByLocation(String location) async {
    final data = await GeoServices.getLatLngFromPlace(location);
    final lat = data.latitude;
    final lng = data.longitude;

    filteredPosts.value = posts.where((post) {
      if (post.location == null || post.location!.coordinates == null) {
        return false;
      }

      // Calculate the distance between the post location and the given location
      final distance = GeoServices.calculateDistance(
        lat,
        lng,
        post.location!,
      );

      return distance <= radius.value;
    }).toList();

    return filteredPosts;
  }

  void sliderSwitch() {
    isFilterSLiderTapped.value = !isFilterSLiderTapped.value;
  }

  void onRadiusChange(double value) {
    radius.value = value;
  }

  // filter by location and tag
  // void filterPostByLocationAndTag(String location, List<String> tags, ) {
  //   filteredPosts.clear();
  //   filteredPosts.value = posts;
  //   if (location.isNotEmpty || (tags.isNotEmpty)) {
  //     log("in-IF location: $location, tags: $tags");
  //     filteredPosts.value = posts.where((post) {
  //       // Determine if location and tags are provided
  //       final bool locationProvided = location.isNotEmpty;
  //       final bool tagsProvided = tags.isNotEmpty;

  //       // Check for location match
  //       final bool locationMatch = locationProvided
  //           ? post.area?.toLowerCase() == location.toLowerCase()
  //           : false;
  //       log('Location Match: $locationMatch');

  //       // Check for tags match
  //       final bool tagsMatch = tagsProvided
  //           ? post.tags.any((tag) =>
  //               tags.map((t) => t.toLowerCase()).contains(tag.toLowerCase()))
  //           : true;

  //       // If location is provided, both must match; otherwise, only tags must match
  //       return locationMatch && tagsMatch;
  //     }).toList();
  //   }

  //   Get.back();
  // }

  Future<void> filterPostByLocationAndTag(List<String> tags, String? location) async {
    if ((tags.isEmpty && (location == null || location == 'Select Location' || location == ''))) {
      filteredPosts.assignAll(posts);
      Get.back();
      return;
    }
    filteredPosts.clear();
    filteredPosts.value = posts;
    isLoading.value = true;
    printLogs("=======filterPostByLocationAndTag loading is true");
    await Future.delayed(Duration(seconds: 1));
    if (location != null && location.isNotEmpty) {
      await filterPostByLocation(location);
    }
    if ((tags.isNotEmpty)) {
      while (currentPage.value <= totalPostPages.value) {
        await loadMorePosts();
        // Break if we've loaded all pages or hit an error
        if (currentPage.value >= totalPostPages.value) break;
      }

      filteredPosts.value = posts.where((post) {
        final bool tagsProvided = tags.isNotEmpty;
        final bool tagsMatch = tagsProvided ? post.tags.any((tag) => tags.map((t) => t.toLowerCase()).contains(tag.toLowerCase())) : true;
        return tagsMatch;
      }).toList();
    }

    Get.back();
    isLoading.value = false;
    printLogs("=======filterPostByLocationAndTag loading is false");
  }

  RxList<Editor> filteredPeople = <Editor>[].obs;
  RxList<Editor> activeEditors = <Editor>[].obs;
  void filterPeople(String? mentions) {
    filteredPeople.clear();
    filteredPeople.value = activeEditors.where((post) {
      final bool mentionsProvided = mentions != null && mentions.isNotEmpty;

      final bool mentionsMatch = mentionsProvided ? post.name!.toLowerCase().contains(mentions.toLowerCase()) : true;

      return mentionsMatch;
    }).toList();

    // Get.back();
    // if (filteredPosts.isEmpty) {
    //   CustomSnackbar.showSnackbar('No Posts Found');
    // }
  }

  //fn to get list of active editors to follow and unfollow
  getActiveEditors() async {
    isLoadingEditors.value = true;
    activeEditors.clear();
    try {
      List<Editor> editorList = await PostRepo().getActiveEditors();

      for (Editor editor in editorList) {
        activeEditors.add(editor);
      }
      isLoadingEditors.value = false;
    } catch (e) {
      printLogs('getActiveEditors Exception $e');
      isLoadingEditors.value = false;
    }
  }

  // void filterPostByLocationAndTag(String location, List<String> tags) {
  //   filteredPosts.value = posts
  //       .where((post) =>
  //           post.area == location || post.tags.any((tag) => tags.contains(tag)))
  //       .toList();
  //   log('Filtered Posts: ${filteredPosts.length}');
  //   if (filteredPosts.isEmpty) {
  //     CustomSnackbar.showSnackbar('No Posts Found');
  //   }
  // }

  /// get list of all video thumbnail
  RxList videoThumbnailList = [].obs;
  Future<void> getThumbnailData() async {
    try {
      for (var post in posts) {
        final thumbnail = await VideoServices().getThumbnailData(post.video);
        if (thumbnail != null) {
          videoThumbnailList.add(thumbnail);
        }
      }
    } catch (e) {}
  }

  /// fn to get recent search history from shared prefrence
  void getRecentSearch() {
    SharedPrefrenceService.getRecentSearch().then((value) {
      if (value.isNotEmpty) {
        recentSearchList.assignAll(value);
      }
    });
  }

  /// fn to add recent search to shared prefrence
  void addRecentSearch(String search) {
    SharedPrefrenceService.saveRecentSearch(search);
    recentSearchList.add(search);
  }

  RxList<UserDetailModel> allUsersList = RxList();

  /// fn to get all users from backend
  Future<void> getAllUsersSearch() async {
    isLoadingUsers.value = true;
    allUsersList.clear();
    searchList.clear();
    try {
      List<UserDetailModel> users = await ProfileRepo().getAllUsers();

      for (UserDetailModel user in users) {
        allUsersList.add(user);
        final tagsList = posts
            .where((p) => p.userId.id == user.id) // Filter posts by the user's ID
            .map((p) => p.tags) // Get the tags list for each post
            .expand((tags) => tags) // Flatten the list of lists
            .toList();
        log("saved tags ${tagsList.length}");
        searchList.add(SearchModel(
            imageUrl: user.image ?? kdummyPerson,
            name: user.name,
            followers: '${user.followers.length >= 1000 ? NumberFormat.compactCurrency(
                decimalDigits: 2,
                symbol: '',
              ).format(user.followers.length) : user.followers.length} followers',
            isFollowed: user.followers.any((element) => element.toLowerCase() == SessionService().user!.id.toLowerCase()),
            hashtags: tagsList,
            location: 'London',
            email: user.email,
            userId: user.id));
      }
      isLoadingUsers.value = false;
    } catch (e) {
      printLogs('getAllUsersSearch Exception; $e');
      isLoadingUsers.value = false;
    }
  }

  Future<void> updateLikeDislike({required String postId}) async {
    printLogs('Liked Post ID: $postId');
    try {
      final userId = SessionService().user?.id ?? '';
      int postIndex = posts.indexWhere((element) => element.id == postId);
      HomeScreenController homeController = Get.find<HomeScreenController>();
      if (postIndex != -1) {
        if (posts[postIndex].likes.contains(userId)) {
          // posts[postIndex].likes.remove(userId);
          // posts[postIndex].likesCount -= 1;
          filteredPosts[postIndex].likes.remove(userId);
          filteredPosts[postIndex].likesCount -= 1;
        } else {
          // posts[postIndex].likes.add(userId);
          // posts[postIndex].likesCount += 1;
          filteredPosts[postIndex].likes.add(userId);
          filteredPosts[postIndex].likesCount += 1;
          await PostRepo().updateUserActivity(postId: postId, likes: userId);
          int index = homeController.posts.indexWhere((element) => element.id == postId);

          homeController.posts[index].likes.add(userId);
          homeController.posts[index].likesCount += 1;
        }
        posts.refresh();
        filteredPosts.refresh();
        homeController.posts.refresh();
      }
    } catch (e) {}
  }

  Future<void> updateShareCount({required String postId}) async {
    try {
      int postIndex = posts.indexWhere((element) => element.id == postId);
      HomeScreenController homeController = Get.find<HomeScreenController>();
      if (postIndex != -1) {
        posts[postIndex].share.add(SessionService().user?.id ?? '');
        posts[postIndex].sharesCount += 1;
        posts.refresh();
        await PostRepo().updateUserActivity(postId: postId, share: SessionService().user?.id ?? '');
        NotificationRepo().sendNotification(
          userId: posts[postIndex].userId.id,
          title: 'New Share',
          body: '${SessionService().user?.name} shared your post',
        );
        int index = homeController.posts.indexWhere((element) => element.id == postId);
        homeController.posts[index].share.add(SessionService().user?.id ?? '');
        homeController.posts[index].sharesCount += 1;
        homeController.posts.refresh();
      }
    } catch (e) {
      printLogs('Error updateShareCount Discover: $e');
    }
  }

  RxDouble userRating = 0.0.obs;
  Future<void> updateRating({required String postId, required double rating}) async {
    try {
      int postIndex = posts.indexWhere((element) => element.id == postId);
      final userId = SessionService().user?.id ?? '';
      if (postIndex != -1) {
        ///TODO
        final response = await PostRepo().setRating(rating, posts[postIndex].id, userId);
        if (response != null) {
          posts[postIndex].averageRating = response.averageRating;
          posts.refresh();
        }
        userRating.value = rating;
        isRatingTapped.value = false;
      }
    } catch (e) {}
  }

  onReasonDropDownChange(newValue) {
    if (newValue != null) {
      selectedReason.value = newValue;
    }
  }

  Future<void> getReasonsOfReportingBlocking() async {
    try {
      final userId = SessionService().user?.id ?? '';

      final response = await PostRepo().getReasonsToBlockReport(isReport: true);
      if (response != null) {
        reportingReasons.clear();
        reasonsModelReport.clear();
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
      printLogs('Error getReasonsOfReportingBlocking Discover: $e');
    }
  }

  Future<void> getReasonsOfBlocking() async {
    try {
      final userId = SessionService().user?.id ?? '';

      final response = await PostRepo().getReasonsToBlockReport(isReport: false);
      if (response != null) {
        blockingReasons.clear();
        reasonsModelBlock.clear();
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
      printLogs('Error getReasonsOfBlocking Discover: $e');
    }
  }

  Future<void> reportClip({required String postId, required String reason}) async {
    try {
      int indexFilteredPosts = filteredPosts.indexWhere((element) => element.id == postId);
      final userId = SessionService().user?.id ?? '';
      if (indexFilteredPosts != -1) {
        ///TODO
        final response = await PostRepo().reportPost(
            reason: reasonsModelReport.firstWhere((element) => element.reason == reason).id ?? "",
            postId: filteredPosts[indexFilteredPosts].id,
            userID: userId);
        printLogs('==============response.message  ${response?.message}');
        if (response != null && response.message == "Clip reported successfully") {
          filteredPosts.removeAt(indexFilteredPosts);
          filteredPosts.refresh();
          int postsIndex = posts.indexWhere((element) => element.id == postId);
          posts.removeAt(postsIndex);
          posts.refresh();

          HomeScreenController homeController = Get.find<HomeScreenController>();
          int homeIndex = homeController.posts.indexWhere((element) => element.id == postId);
          homeController.videoControllers
              .removeWhere((element) => element.value.dataSource == homeController.posts.firstWhere((element) => element.id == postId).video);
          homeController.posts.removeAt(homeIndex);
          homeController.posts.refresh();
          homeController.videoControllers.refresh();
          Get.back();
          Get.back();
          NotificationRepo()
              .sendNotification(title: 'Reported Post', body: 'Your post has been reported', userId: filteredPosts[indexFilteredPosts].userId.id);
          CustomSnackbar.showSnackbar("Clip reported successfully");
          selectedReason.value = 'Select Reason';
          update();
        } else {
          CustomSnackbar.showSnackbar("Unable to report the clip");
        }
      }
    } catch (e) {
      CustomSnackbar.showSnackbar("Something went wrong");
      printLogs('Error reportClip Discover: $e');
    }
  }

  Future<void> updateViewCount({required String postId}) async {
    final userId = SessionService().user?.id ?? '';
    try {
      final response = await PostRepo().updateUserActivity(
        postId: postId,
        views: userId,
      );
      if (response) {
        int index = posts.indexWhere((element) => element.id == postId);
        HomeScreenController homeController = Get.find<HomeScreenController>();
        posts[index].views?.add(ViewsModel(id: userId, name: SessionService().user?.name ?? ""));
        posts.refresh();
        int indexFilteredPosts = filteredPosts.indexWhere((element) => element.id == postId);
        filteredPosts[indexFilteredPosts].views?.add(ViewsModel(id: userId, name: SessionService().user?.name ?? ""));
        filteredPosts.refresh();
        int homeIndex = homeController.posts.indexWhere((element) => element.id == postId);
        homeController.posts[homeIndex].views?.add(ViewsModel(id: userId, name: SessionService().user?.name ?? ""));
        homeController.posts.refresh();
        // CustomSnackbar.showSnackbar("View Count Updated");
      }
    } catch (e) {
      // CustomSnackbar.showSnackbar("Unable to Update View Count");
    }
  }

  @override
  void onClose() {
    super.onClose();
    // videoController?.dispose();
    disposeVideoPlayer();
  }

  /// code for Tapping post
  /// obs int to store index of tapped post
  RxInt tappedPostIndex = 0.obs;
  void onTapPost(int index) {
    if (isIndexOutOfRange(index)) {
      CustomSnackbar.showSnackbar("Error: Post not found");
      return;
    } else {
      tappedPostIndex.value = index;
    }
  }

  /// fn to check if index is out of range
  bool isIndexOutOfRange(int index) {
    return index >= filteredPosts.length;
  }

  RxList<CachedVideoPlayerPlus> videoControllers = <CachedVideoPlayerPlus>[].obs;
  // RxList<VideoPlayerController> videoControllers = <VideoPlayerController>[].obs;

  Future<void> initializeAllControllers(int startIndex, int limit) async {
    isVideoLoading.value = true;
    printLogs('==========initializeAllControllers startIndex $startIndex limit : $limit');
    printLogs('==========initializeAllControllers filteredPosts.length ${filteredPosts.length}');
    if (startIndex < 0 || limit >= filteredPosts.length) {
      CustomSnackbar.showSnackbar("Error: Index out of range");
      return;
    }
    List<Future> futures = [];
    /*for (int i = startIndex; i < startIndex + limit && i < filteredPosts.length; i++) {
      futures.add(initializeVideoPlayer(filteredPosts[i].video));
      // isVideoLoading.value = false;
    }*/

    for (int i = startIndex; i < filteredPosts.length; i++) {
      printLogs("============initializeAllControllers inside for loop $i");
      futures.add(initializeVideoPlayer(filteredPosts[i].video, filteredPosts[i].id));
      // isVideoLoading.value = false;
    }
    printLogs("============initializeAllControllers futures.length ${futures.length}");
    try {
      // await Future.wait(futures);
      await Future.wait(futures, eagerError: false);
    } catch (e) {
      printLogs('==========initializeAllControllers exception $e');
      // CustomSnackbar.showSnackbar("Error: Index out of range");
    }
    isVideoLoading.value = false;
  }

  Future<void> initializeVideoPlayer(String videoUrl, String videoId) async {
    try {
      // Add null and empty string check
      if (videoUrl == null || videoUrl.isEmpty) {
        printLogs("Video URL is null or empty");
        return;
      }

      // Validate URL
      Uri? parsedUri = Uri.tryParse(videoUrl);
      if (parsedUri == null) {
        printLogs("Invalid video URL: $videoUrl");
        return;
      }

      // Add timeout to prevent indefinite waiting
      /*final controller = VideoPlayerController.networkUrl(
        parsedUri,
      );*/
      final controller = CachedVideoPlayerPlus.networkUrl(parsedUri, invalidateCacheIfOlderThan: const Duration(minutes: 30));

      await controller.initialize().timeout(const Duration(seconds: 30), onTimeout: () {
        printLogs("Video initialization timed out for URL: $videoUrl");
        controller.dispose();
        return Future.error('Initialization timeout');
      });

      controller.setLooping(true);
      controller.setVolume(1.0);
      controller.pause();

      videoControllers.add(controller);
    } catch (e) {
      printLogs("Error initializing video player videoID: $videoId for URL $videoUrl: $e");
      // Optionally, you could skip this video instead of throwing an error
      // This prevents one bad video from breaking the entire initialization process
    }
  }

  Future<void> initializeVideoPlayerOld(String videoUrl) async {
    try {
      /*videoControllers.add(VideoPlayerController.networkUrl(
        Uri.parse(videoUrl),
      ));*/
      videoControllers.add(CachedVideoPlayerPlus.networkUrl(Uri.parse(videoUrl), invalidateCacheIfOlderThan: const Duration(minutes: 30)));
      await videoControllers.last.initialize().then((_) {
        videoControllers.last.controller.setLooping(true);
        videoControllers.last.controller.setVolume(1.0);
        videoControllers.last.controller.pause();
      });
    } catch (e) {
      printLogs("initializeVideoPlayer $e");
    }
  }

  Future<void> disposeVideoPlayer() async {
    for (var controller in videoControllers) {
      await controller.dispose();
    }
    videoControllers.clear();
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
        initializeAllControllers(index + 1, filteredPosts.length > 3 ? 3 : filteredPosts.length - 1);
      }
      if (videoControllers.isNotEmpty) {
        videoControllers[index].controller.setLooping(true);
        videoControllers[index].controller.setVolume(1.0);
        videoControllers[index].controller.play();
        userRating.value = 0.0;
        updateViewCount(
          postId: filteredPosts[index].id,
        );
      }
    }
  }

  Future<void> downloadVideo(String videoUrl) async {
    try {
      VideoServices().downloadVideo(videoUrl: videoUrl, notificationService: NotificationService());
    } catch (e) {}
  }

  Future<void> blockUser({required String blockedUserId, required String reason}) async {
    try {
      isLoading.value = true;
      printLogs("=======blockUser loading is true");
      final userId = SessionService().user?.id ?? '';
      final response = await PostRepo().blockUser(
          reasonId: reasonsModelBlock.firstWhere((element) => element.reason == reason).id ?? "", blockedUserId: blockedUserId, userID: userId);
      if (response != null && response.message == "User blocked successfully") {
        filteredPosts.removeWhere((element) => element.userId.id == blockedUserId);
        filteredPosts.refresh();
        posts.removeWhere((element) => element.userId.id == blockedUserId);
        posts.refresh();
        ProfileRepo().getFollowingUsers(userId: SessionService().user?.id ?? '').then((value) {
          SessionService().replaceFollowingList(value);
        });
        videoControllers.refresh();

        HomeScreenController homeController = Get.find<HomeScreenController>();
        // int homeIndex = homeController.posts.indexWhere((element) => element.id == postId);
        homeController.videoControllers.removeWhere(
            (element) => element.value.dataSource == homeController.posts.firstWhere((element) => element.userId.id == blockedUserId).video);
        homeController.posts.removeWhere((element) => element.userId.id == blockedUserId);
        homeController.posts.refresh();
        homeController.videoControllers.refresh();
        // Get.back();
        // Get.back();
        NotificationRepo().sendNotification(title: 'Reported Post', body: 'User has been blocked successfully', userId: userId);
        CustomSnackbar.showSnackbar("User blocked successfully");
        selectedReason.value = 'Select Reason';
      } else {
        CustomSnackbar.showSnackbar("Unable to block the user");
      }
      isLoading.value = false;
      printLogs("=======blockUser loading is false try block");
    } catch (e) {
      CustomSnackbar.showSnackbar("Something went wrong");
      printLogs('Error blockUser Discover: $e');
      isLoading.value = false;
      printLogs("=======blockUser loading is false catch block");
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

  Future<void> updateFollowStatusold({
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
      if (SessionService().userDetail?.following.contains(followedUserId) ?? false) {
        final response = await ProfileRepo().unFollowUser(userId: currentUserId, followedUserId: followedUserId);

        if (response != null) {
          SessionService().userDetail?.followers.remove(followedUserId);
          viewedUsers[index].followers.remove(currentUserId);
          searchBottomSheetList[index].followers.remove(followedUserId);
          // getUserProfile(SessionService().user?.id);
          // ProfileRepo()
          //     .getFollowingUsers(userId: SessionService().user!.id)
          //     .then((data) {
          //   SessionService().replaceFollowingList(data);
          // });
        }
      } else {
        final response = await ProfileRepo().followUser(userId: currentUserId, followUserId: followedUserId);
        if (response != null) {
          SessionService().userDetail?.followers.add(followedUserId);
          viewedUsers[index].followers.add(currentUserId);
          NotificationRepo()
              .sendNotification(title: 'New Follower', body: 'You have a new follower: ${SessionService().userDetail?.name}', userId: followedUserId);
          // getUserProfile(SessionService().user?.id);
          // ProfileRepo().getFollowingUsers(userId: currentUserId).then((value) {
          //   SessionService().replaceFollowingList(value);
          // });
        }
      }
      viewedUsers.refresh();
      searchBottomSheetList.refresh();
    } catch (e) {}

    isFollowersLoading.value = false;
  }

  Future<void> onOtherUserView(String userId) async {
    isLoading.value = true;
    printLogs("=======onOtherUserView loading is true");
    Get.toNamed(kFollowersProfileScreen, arguments: userId);
    isLoading.value = false;
    printLogs("=======onOtherUserView loading is false");
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
      } else {
        CustomSnackbar.showSnackbar('Error in getting user profile');
      }
    } catch (e) {
      CustomSnackbar.showSnackbar('Error in getting user profile');
    }
    // isLoading.value = false;
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
  }
}
