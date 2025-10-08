import 'dart:convert';
import 'dart:io';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:socials_app/models/usermodel.dart';
import 'package:socials_app/utils/common_code.dart';
import 'package:socials_app/views/screens/profile/screen/profile_screen.dart';

class SharedPrefrenceService {
  static const String tokenKey = 'token';
  static Future<void> saveToken(String token) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(tokenKey, token);
  }

  static Future<String?> getToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(tokenKey);
  }

  // fn to store user Model
  static const String userModelKey = 'userModel';

  static Future<String?> get token async {
    return getToken();
  }

  /// fn to clear all data from shared prefrence
  static Future<void> clearAllData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }

  static Future<void> saveUserModel(UserModel userModel) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(userModelKey, jsonEncode(userModel.toJson()));
  }

  static Future<UserModel?> getUserModel() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? userString = prefs.getString(userModelKey);
    if (userString != null) {
      return UserModel.fromJson(jsonDecode(userString));
    }
    return null;
  }

  /// fn for store recent search
  static const String recentFilterSearchKey = 'recentFilterSearch';

  static Future<void> saveRecentSearch(String search) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> recentSearch = prefs.getStringList(recentFilterSearchKey) ?? [];
    recentSearch.add(search);
    await prefs.setStringList(recentFilterSearchKey, recentSearch);
  }

  static Future<List<String>> getRecentSearch() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(recentFilterSearchKey) ?? [];
  }

  /// save temp videos data
  static const String tempVideosKey = 'tempVideos';
  static Future<void> saveTempVideos(List<Map> videos) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(tempVideosKey, jsonEncode(videos));
  }

  static Future<void> addToTempVideos(Map video) async {
    printLogs("=======addToTempVideos");
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<Map> videos = await getTempVideos();

    // Convert File objects to file paths
    Map<String, dynamic> videoToSave = video.map((key, value) {
      if (value is File) {
        return MapEntry(key, value.path);
      }
      return MapEntry(key, value);
    });

    printLogs("=======addToTempVideos visdotoSave");
    videos.add(videoToSave);
    printLogs("=======addToTempVideos videos ${videos.length}");

    await prefs.setString(tempVideosKey, jsonEncode(videos));

    printLogs("=======addToTempVideos videos added ${videos.length}");
  }

  static Future<List<Map>> getTempVideos() async {
    printLogs('=========getTempVideos pref');
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? videosString = prefs.getString(tempVideosKey);
    printLogs('=========getTempVideos pref videosString ${videosString}');
    if (videosString != null) {
      printLogs('=========getTempVideos pref if');
      List<dynamic> videosJson = jsonDecode(videosString);

      printLogs('=========getTempVideos pref videosString ${videosJson}');
      return videosJson.map((video) => Map<String, dynamic>.from(video)).toList();
    }
    printLogs('=========getTempVideos pref out');
    return [];
  }

  static Future<void> removeTempVideo(String videoPath) async {
    printLogs('=========removeTempVideo pref ${videoPath}');
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<Map> videos = await getTempVideos();
    videos.removeWhere((element) => element['videoPath'] == videoPath);
    await prefs.setString(tempVideosKey, jsonEncode(videos));
    await clearUploadProgress(videoPath);
    await clearUploadStatus(videoPath);
  }

  static Future<void> saveUploadProgress(String filePath, double progress) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('upload_progress_$filePath', progress);
  }

  static Future<void> setIsFirstVideo() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isFirstVideo', true);
  }

  static Future<bool> getIsFirstVideo() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('isFirstVideo') ?? false;
  }

  static Future<void> removeIsFirstVideo() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('isFirstVideo');
  }

  static Future<double> getUploadProgress(String filePath) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getDouble('upload_progress_$filePath') ?? 0.0;
  }

  static Future<void> clearUploadProgress(String filePath) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('upload_progress_$filePath');
  }

  static Future<void> saveUploadStatus(String filePath, UploadStatus progress) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('upload_status_$filePath', progress.name);
  }

  static Future<String> getUploadStatus(String filePath) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('upload_status_$filePath') ?? UploadStatus.success.name;
  }

  static Future<void> clearUploadStatus(String filePath) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('upload_status_$filePath');
  }
}
