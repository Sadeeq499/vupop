import 'dart:convert';

import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:socials_app/models/post_models.dart';
import 'package:socials_app/models/usermodel.dart';
import 'package:socials_app/services/sharedprefrence_service.dart';

import '../models/export_post_notification_model.dart';
import '../repositories/auth_repo.dart';
import '../repositories/profile_repo.dart';
import '../utils/common_code.dart';

class SessionService {
  static final SessionService _singleton = SessionService._internal();

  factory SessionService() {
    return _singleton;
  }

  SessionService._internal();

  String? userToken;
  UserModel? user;
  UserDetailModel? userDetail;
  Location? userLocation;
  String? userAddress;
  bool isUserLoggedIn = false;
  RxList<UserDetailModel> following = <UserDetailModel>[].obs;
  RxList<String> followingUsersIDs = <String>[].obs;
  String? verifiedEmail;
  bool? isEmailVerified;
  RxList<String> blockedUsers = <String>[].obs;
  RxList<NotificationData> exportPostNotificationData = RxList();
  RxInt totalPages = 1.obs;

  setUserData() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString("userToken", userToken ?? "");
    prefs.setString("user", json.encode(user?.toJson()) ?? "");
    prefs.setString("userDetail", json.encode(userDetail?.toJson()) ?? "");
    prefs.setString("userAddress", userAddress ?? "");
    prefs.setBool("isUserLoggedIn", isUserLoggedIn ?? false);
    prefs.setString("verifiedEmail", (verifiedEmail) ?? "");
    prefs.setBool("isEmailVerified", isEmailVerified ?? false);
    prefs.setString("exportPostNotificationData", json.encode(exportPostNotificationData.toJson()) ?? "");
  }

  saveUserAddress() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString("userAddress", (userAddress) ?? "");
    prefs.setString("userLocation", json.encode(userLocation) ?? "");
  }

  saveUserDetails() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    userDetail?.following = userDetail?.following.toSet().toList() ?? [];
    userDetail?.followers = userDetail?.followers.toSet().toList() ?? [];
    prefs.setString("userDetail", json.encode(userDetail?.toJson()) ?? "");
  }

  saveEmailVerificationDetails() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString("verifiedEmail", (verifiedEmail) ?? "");
    prefs.setBool("isEmailVerified", isEmailVerified ?? false);
  }

  saveBlockedUsersList(List<String> blockedList) async {
    blockedUsers.clear();
    blockedUsers.addAll(blockedList);
    blockedUsers.refresh();
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setStringList("blockedList", (blockedList));
  }

  getEmailVerificationDetails() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    verifiedEmail = prefs.getString("verifiedEmail");
    isEmailVerified = prefs.getBool("isEmailVerified");
  }

  getUserData() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String error = "";
    try {
      error = "userToken";
      userToken = prefs.getString("userToken");
      error = "user";
      user = prefs.getString("user") != null && prefs.getString("user")!.isNotEmpty && json.decode(prefs.getString("user") ?? "") != null
          ? UserModel.fromJson(json.decode(prefs.getString("user")!))
          : null;
      error = "userDetail";
      userDetail = prefs.getString("userDetail") != null &&
              prefs.getString("userDetail")!.isNotEmpty &&
              json.decode(prefs.getString("userDetail") ?? "") != null
          ? UserDetailModel.fromJson(json.decode(prefs.getString("userDetail")!))
          : null;
      error = "userLocation";
      userLocation = prefs.getString("userLocation") != null &&
              prefs.getString("userLocation")!.isNotEmpty &&
              json.decode(prefs.getString("userLocation") ?? "") != null
          ? Location.fromJson(json.decode(prefs.getString("userLocation")!))
          : null;

      error = "userAddress";
      userAddress = prefs.getString("userAddress");
      error = "isUserLoggedIn";
      isUserLoggedIn = prefs.getBool("isUserLoggedIn") ?? false;
    } catch (e) {
      //CustomSnackbar.showSnackbar("=======catch error $error");
    }
  }

  Future<bool> checkUserSession() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    isUserLoggedIn = prefs.getBool("isUserLoggedIn") ?? false;
    exportPostNotificationData = RxList();
    user = prefs.getString("user") != null && prefs.getString("user")!.isNotEmpty && json.decode(prefs.getString("user") ?? "") != null
        ? UserModel.fromJson(json.decode(prefs.getString("user")!))
        : null;
    bool isUserExist = false;
    if (isUserLoggedIn && user != null) {
      isUserExist = await AuthRepo().checkUserExist(
        email: user!.email,
      );

      if (!isUserExist) {
        clearAllData();
        SharedPrefrenceService.clearAllData();
      } else {
        final value = await ProfileRepo().getUserProfile(userId: SessionService().user?.id ?? '');
        if (value != null) {
          SessionService().userDetail = value;
          SessionService().saveUserDetails();
        }
      }
      return isUserExist;
    }
    return isUserLoggedIn;
  }

  Future<void> initialize() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    userToken = prefs.getString('userToken');
  }

  clearAllData() {
    userToken = '';
    SessionService().user = null;
    SessionService().userDetail = null;
    SessionService().isUserLoggedIn = false;
    isUserLoggedIn = false;
    userToken = "";
    isEmailVerified = false;
    verifiedEmail = "";
    exportPostNotificationData = RxList();
    SessionService().setUserData();
  }

  void replaceFollowingList(List<UserDetailModel> newList) {
    following.clear();
    followingUsersIDs.clear();
    following.addAll(newList);
    for (UserDetailModel data in newList) {
      followingUsersIDs.add(data.id);
    }
    followingUsersIDs.refresh();
    following.refresh();
  }

  /// check if user if following the user
  bool isFollowing(String userId) {
    return following.any((element) => element.id == userId);
  }

  /// check if user if following the user
  bool isFollowingById(String userId) {
    // printLogs('==============followingUsersIDs ${SessionService().userDetail?.following}');
    return SessionService().userDetail?.following.contains(userId) ?? false;
  }

  /// check if user is blocked by the user
  bool isBlocked(String userId) {
    printLogs('=======blockedUsers $blockedUsers');
    return blockedUsers.any((element) => element == userId);
  }

  setExportNotificationsData(int pages) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    totalPages.value = pages;
    prefs.setString("exportPostNotificationData", json.encode(exportPostNotificationData.toJson()) ?? "");
  }
}
