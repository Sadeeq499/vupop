import 'dart:convert';

import 'package:socials_app/models/highlight_reel_model.dart';
import 'package:socials_app/models/passion_model.dart';
import 'package:socials_app/models/profile_image_model.dart';
import 'package:socials_app/models/response_model.dart';
import 'package:socials_app/services/custom_snackbar.dart';
import 'package:socials_app/services/endpoints.dart';
import 'package:socials_app/services/http_client.dart';
import 'package:socials_app/services/session_services.dart';

import '../models/usermodel.dart';
import '../utils/common_code.dart';

class ProfileRepo {
  late HTTPClient _httpClient;
  static final _instance = ProfileRepo._constructor();
  factory ProfileRepo() {
    return _instance;
  }
  ProfileRepo._constructor() {
    _httpClient = HTTPClient();
  }

  /// fn for getting user profile
  Future<UserDetailModel?> getUserProfile({
    required String userId,
  }) async {
    // Map<String, String> body = {"email": email};
    Map<String, String> body = {};
    final response = await _httpClient.getRequestWithHeader(url: "$kGetUser/$userId");
    if (response.statusCode == 200) {
      try {
        Map<String, dynamic> jsonData = jsonDecode(response.data);
        printLogs('userprofile all data: ${jsonData['data']}');
        printLogs('userprofile: ${jsonData['data']['user'][0]}');
        printLogs('userprofile blocked list: ${jsonData['data']['blockedUsers']}');
        final data = userListResponseFromJson(jsonEncode(jsonData)).users[0];

        if (SessionService().user != null && userId == SessionService().user?.id) {
          printLogs('==============inside if profile user matched with logged in user');
          SessionService().verifiedEmail = jsonData['data']['verifiedEmail'];
          SessionService().isEmailVerified = jsonData['data']['isVerified'];
          SessionService().saveEmailVerificationDetails();
          List blockedUsers = jsonData['data']['blockedUsers'] ?? [];
          SessionService().saveBlockedUsersList(blockedUsers.cast<String>());
        }
        return data;
        // return UserDetailModel.fromJson(data);
      } catch (e) {
        printLogs("error from repo getUserProfile ${e.toString()}");
      }
    } else {
      printLogs('getUserProfile unable to get user profile');
      CustomSnackbar.showSnackbar("Unable to get User Profile");
      return null;
    }
    return null;
  }

  /// fn for getting user profile
  Future<List<UserDetailModel>> getAllUsers() async {
    // Map<String, String> body = {"email": email};
    Map<String, String> body = {};
    final response = await _httpClient.getRequestWithHeader(
      url: "$kGetUser?page=1&limit=100",
    );
    if (response.statusCode == 200) {
      try {
        Map<String, dynamic> jsonData = jsonDecode(response.data);
        // printLogs('userprofile: ${jsonData['data']['user'][0]}');
        return userListResponseFromJson(jsonEncode(jsonData))
            .users
            .where((user) => user.isDeleted == false && user.id != SessionService().user?.id)
            .toList();
        // return UserDetailModel.fromJson(data);
      } catch (e) {
        printLogs("error from repo getAllUsers ${e.toString()}");
      }
    } else {
      printLogs('getAllUsers unable to get user profile');
      CustomSnackbar.showSnackbar("Unable to get User Profile");
      return [];
    }
    return [];
  }

  /// fn for follow user
  Future followUser({required String userId, required String followUserId}) async {
    Map<String, String> data = {"userId": userId, "followId": followUserId};
    String body = jsonEncode(data);
    final response = await _httpClient.putRequestWithHeader(url: kFollowUserURL, body: body);
    if (response.statusCode == 200) {
      try {
        Map<String, dynamic> jsonData = jsonDecode(response.data);
        printLogs('jsonData: $jsonData');
        ProfileRepo().getFollowingUsers(userId: userId).then((value) {
          SessionService().replaceFollowingList(value);
        });
        SessionService().userDetail?.following.add(followUserId);
        return SuccessResponse.fromJson(jsonData);
      } catch (e) {
        printLogs("error from repo followUser ${e.toString()}");
      }
    } else {
      printLogs('unable to follow');
      CustomSnackbar.showSnackbar("Unable to Follow");
      return null;
    }
  }

  /// fn for unfollow user
  Future unFollowUser({required String userId, required String followedUserId}) async {
    Map<String, String> data = {"userId": userId, "followId": followedUserId};
    String body = jsonEncode(data);
    final response = await _httpClient.putRequestWithHeader(url: kUnFollowURL, body: body);
    if (response.statusCode == 200) {
      try {
        Map<String, dynamic> jsonData = jsonDecode(response.data);
        ProfileRepo().getFollowingUsers(userId: userId).then((value) {
          SessionService().replaceFollowingList(value);
        });
        printLogs('jsonData: $jsonData');
        SessionService().userDetail?.following.remove(followedUserId);
        return SuccessResponse.fromJson(jsonData);
      } catch (e) {
        printLogs("error from repo unFollowUser ${e.toString()}");
      }
    } else {
      printLogs('unable to unfollow');
      CustomSnackbar.showSnackbar("Unable to Unfollow");
      return null;
    }
  }

  /// fn for changing profile image
  Future<SuccessResponse?> changeProfileImage({required String userId, required String imagePath}) async {
    Map<String, String> data = {};

    // String body = jsonEncode(data);
    final response = await _httpClient.putRequestMultiPartWithHeader(
        url: "$kChangeProfileImgURL/$userId", body: data, isFile: true, filePath: imagePath, filed: 'file');
    if (response.statusCode == 200) {
      try {
        ///TODO
        Map<String, dynamic> jsonData = jsonDecode(response.data);
        printLogs('jsonData: $jsonData');
        return SuccessResponse.fromJson(jsonData);
      } catch (e) {
        printLogs("error from repo changeProfileImage ${e.toString()}");
      }
    } else {
      printLogs('unable to follow');
      CustomSnackbar.showSnackbar("Unable to Change Profile Image");
      return null;
    }
    return null;
  }

  /// fn for getting user profile image
  Future<String?> getUserProfileImage({required String userId}) async {
    final response = await _httpClient.getRequestWithHeader(url: "$kGetUserPorilfeImguURL/$userId");
    if (response.statusCode == 200) {
      try {
        ///TODO
        Map<String, dynamic> jsonData = jsonDecode(response.data);
        printLogs('jsonData: $jsonData');
        final image = ProfileImageModel.fromJson(jsonData).data;
        printLogs('image: $image');
        return image;
      } catch (e) {
        printLogs("error from repo getUserProfileImage ${e.toString()}");
        return null;
      }
    } else {
      printLogs('getUserProfileImage unable to get');
      CustomSnackbar.showSnackbar("Unable to get Profile Image");
      return null;
    }
  }

  /// fn for update user about info and favorite
  Future<SuccessResponseWithoutData?> updateUserInfoFav(
      {required String userId, required String about, required String name, required List favorite, required List<String> passion}) async {
    Map<String, dynamic> data = {"about": about, "favourite": favorite, "name": name, "passion": passion};
    printLogs('data: $data');
    String body = jsonEncode(data);
    final response = await _httpClient.putRequestWithHeader(url: "$kUpdateUser/$userId", body: body);
    if (response.statusCode == 200) {
      try {
        Map<String, dynamic> jsonData = jsonDecode(response.data);
        printLogs('jsonData updateUserInfoFav: $jsonData');
        return SuccessResponseWithoutData.fromJson(jsonData);
      } catch (e) {
        printLogs("error from repo updateUserInfoFav ${e.toString()}");
        return null;
      }
    } else {
      printLogs('unable to update');
      CustomSnackbar.showSnackbar("Unable to Update User");
      return null;
    }
  }

  /// fn to get users profile that i follow
  Future<List<UserDetailModel>> getFollowingUsers({required String userId}) async {
    final data = await getAllUsers();
    return data.where((element) => element.followers.contains(userId)).toList();
  }

  //// fn to get all passions
  Future<List<Passion>> getAllPassions() async {
    final response = await _httpClient.getRequestWithHeader(url: kGetPassionURL);
    if (response.statusCode == 200) {
      try {
        Map<String, dynamic> jsonData = jsonDecode(response.data);
        printLogs('jsonData: $jsonData');
        return PassionResponse.fromJson(jsonData).data?.passions ?? [];
      } catch (e) {
        printLogs("error from repo getAllPassions ${e.toString()}");
      }
    } else {
      printLogs('unable to get passions');
      CustomSnackbar.showSnackbar("Unable to get Passions");
      return [];
    }
    return [];
  }

  /// get user passions
  Future<List<Passion>> getUserPassions({required String userId}) async {
    final response = await _httpClient.getRequestWithHeader(url: "$kGetUserPassionURL/$userId");
    if (response.statusCode == 200) {
      try {
        Map<String, dynamic> jsonData = jsonDecode(response.data);
        printLogs('jsonData: $jsonData');
        final passions = jsonData['data']['Passion'];
        printLogs('User passions: $passions');
        List<Passion> data = (passions as List).map((e) => Passion.fromJson(e as Map<String, dynamic>)).toList();
        return data;
      } catch (e) {
        printLogs("error from user passion repo ${e.toString()}");
      }
    } else {
      printLogs('unable to get passions');
      CustomSnackbar.showSnackbar("Unable to get Passions");
      return [];
    }
    return [];
  }

  /// get user highlithed reels
  Future<List<Reel>> getHighlithedReels({required String userId}) async {
    final response = await _httpClient.getRequestWithHeader(url: "$kGetUserHighlithedReelsURL/$userId");
    if (response.statusCode == 200) {
      try {
        Map<String, dynamic> jsonData = jsonDecode(response.data);
        printLogs('jsonData: $jsonData');
        final reelsResponse = ReelsResponse.fromJson(jsonData);
        printLogs('User reels: ${reelsResponse.reels}');
        return reelsResponse.reels;
      } catch (e) {
        printLogs("error from user reels repo ${e.toString()}");
      }
    } else {
      printLogs('unable to get reels');
      CustomSnackbar.showSnackbar("Unable to get Reels");
      return [];
    }
    return [];
  }

  /// create highlithed reel
  Future<Reel?> createHighlithedReel(
      {required String userId,
      required String caption,
      required String file,
      required String thumbnail,
      required List<String> visibilityList}) async {
    Map<String, String> visibility = {"visibility[0]": ""};
    printLogs('visibilityList: $visibilityList');
    if (visibilityList.isNotEmpty) {
      for (int i = 0; i < visibilityList.length; i++) {
        visibility['visibility[$i]'] = visibilityList[i];
      }
    } else {
      visibility = {};
    }
    Map<String, String> data = {"userId": userId, "caption": caption, ...visibility};
    printLogs('data: $data');
    final body = data;
    printLogs('body: $body');
    final response = await _httpClient.postMultipartRequestFile(
      url: kCreateHighlightReelURL,
      body: body,
      isFile: true,
      filePath: file,
      filed: 'file',
      thumbnail: thumbnail,
    );
    printLogs('response createHighlithedReel: ${response.data}');
    if (response.statusCode == 200) {
      try {
        Map<String, dynamic> jsonData = jsonDecode(response.data);
        printLogs('jsonData: $jsonData');
        return ReelsUploadResponse.fromJson(jsonData).reel;
      } catch (e) {
        printLogs("error from repo createHighlithedReel ${e.toString()}");
        return null;
      }
    } else {
      printLogs('unable to create reel');
      CustomSnackbar.showSnackbar("Unable to Create Reel");
      return null;
    }
  }

  Future<bool> updateHighlithedReel({
    required String reelId,
    required String caption,
  }) async {
    Map<String, String> data = {
      "caption": caption,
    };
    printLogs('data: $data');
    final body = data;
    final response = await _httpClient.putRequestMultiPartWithHeader(
      url: "$kUpdateHighlightReelURL/$reelId",
      body: body,
    );
    if (response.statusCode == 200) {
      try {
        Map<String, dynamic> jsonData = jsonDecode(response.data);
        printLogs('jsonData: $jsonData');
        return true;
      } catch (e) {
        printLogs("error from repo updateHighlithedReel${e.toString()}");
        return false;
      }
    } else {
      printLogs('unable to update reel');
      CustomSnackbar.showSnackbar("Unable to Update Reel");
      return false;
    }
  }

  Future<bool> deleteHighlight(String id) async {
    try {
      final resp = await _httpClient.deleteRequestWithHeader(url: "$kDeleteHighlightReelURL/$id");
      if (resp.statusCode == 200) {
        Map<String, dynamic> jsonData = jsonDecode(resp.data);
        printLogs('jsonData: $jsonData');
        return true;
      }
    } catch (e) {
      printLogs("error del: $e");
    }
    return false;
  }

  /// get fav clips
  Future<List<Reel>> getFavClips({required String userId}) async {
    final response = await _httpClient.getRequestWithHeader(url: "$kGetUserFavClipsURL/$userId");
    if (response.statusCode == 200) {
      try {
        Map<String, dynamic> jsonData = jsonDecode(response.data);
        printLogs('jsonData: $jsonData');
        final reelsResponse = ReelsResponse.fromJson(jsonData);
        printLogs('User reels: ${reelsResponse.reels}');
        return reelsResponse.reels;
      } catch (e) {
        printLogs("error from user reels repo ${e.toString()}");
      }
    } else {
      printLogs('unable to get reels');
      CustomSnackbar.showSnackbar("Unable to get Fav Clips");
      return [];
    }
    return [];
  }

  /// fn to add fav clips
  Future<Reel?> addFavClip({
    required String userId,
    required String filePath,
    List<String> visibilityList = const [],
    required String caption,
    required String thumbnail,
    void Function(int sent, int total)? onProgress,
  }) async {
    printLogs('filePath: $filePath thumbnail: $thumbnail caption: $caption userId: $userId');
    Map<String, String> visibility = {"visibility[0]": ""};
    printLogs('visibilityList: $visibilityList');
    if (visibilityList.isNotEmpty) {
      for (int i = 0; i < visibilityList.length; i++) {
        visibility['visibility[$i]'] = visibilityList[i];
      }
    } else {
      visibility = {};
    }
    Map<String, String> data = {"userId": userId, "caption": caption, ...visibility};

    try {
      final response = await _httpClient.postMultipartRequestFile(
        url: kAddFavClipURL,
        body: data,
        isFile: true,
        filePath: filePath,
        filed: 'file',
        thumbnail: thumbnail,
        onProgress: onProgress,
      );
      printLogs('response addFavClip: ${response.data}');
      if (response.statusCode == 200) {
        try {
          Map<String, dynamic> jsonData = jsonDecode(response.data);
          printLogs('jsonData: $jsonData');
          return ReelsUploadResponse.fromJson(jsonData).reel;
        } catch (e) {
          printLogs("error from repo addFavClip ${e.toString()}");
        }
      } else {
        printLogs('unable to add fav clip');
        CustomSnackbar.showSnackbar("Unable to Add Fav Clip");
      }
    } catch (e) {
      printLogs('error in add fav clip: $e');
    }
    return null;
  }

  /// fn to delete fav clip
  Future<bool> deleteFavClip({required String reelId}) async {
    final response = await _httpClient.delete(
      "$kDeleteFavClipURL/$reelId",
    );
    if (response.statusCode == 200) {
      return true;
    } else {
      printLogs('unable to delete fav clip');
      CustomSnackbar.showSnackbar("Unable to Delete Fav Clip");
      return false;
    }
  }

  /// fn to update fav clip
  Future<bool> updateFavClip({required String reelId, required String caption}) async {
    Map<String, String> data = {
      "caption": caption,
    };
    String body = jsonEncode(data);
    final response = await _httpClient.putRequestWithHeader(url: "$kUpdateFavClipURL/$reelId", body: body);
    if (response.statusCode == 200) {
      try {
        Map<String, dynamic> jsonData = jsonDecode(response.data);
        printLogs('jsonData: $jsonData');
        return true;
      } catch (e) {
        printLogs("error from repo updateFavClip ${e.toString()}");
      }
    } else {
      printLogs('unable to update fav clip');
      CustomSnackbar.showSnackbar("Unable to Update Fav Clip");
      return false;
    }
    return false;
  }

  /// fn for update user location
  Future<SuccessResponseWithoutData?> updateUserLocationData({required String userId, required double lng, required double lat}) async {
    Map<String, dynamic> data = {
      "location": {
        "type": "Point",
        "coordinates": [lng, lat] //[lng, lat]
      }
    };
    printLogs('data: $data');
    String body = jsonEncode(data);
    final response = await _httpClient.putRequestWithHeader(url: "$kUpdateUser/$userId", body: body);
    if (response.statusCode == 200) {
      try {
        Map<String, dynamic> jsonData = jsonDecode(response.data);
        printLogs('jsonData updateUserLocationData: $jsonData');
        return SuccessResponseWithoutData.fromJson(jsonData);
      } catch (e) {
        printLogs("error from repo updateUserLocationData ${e.toString()}");
        return null;
      }
    } else {
      printLogs('updateUserLocationData unable to update');
      // CustomSnackbar.showSnackbar("Unable to Update User");
      return null;
    }
  }
}
