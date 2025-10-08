import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:socials_app/models/usermodel.dart';
import 'package:socials_app/services/custom_snackbar.dart';
import 'package:socials_app/services/http_client.dart';
import 'package:socials_app/services/session_services.dart';
import 'package:socials_app/services/sharedprefrence_service.dart';
import 'package:socials_app/utils/app_strings.dart';

import '../models/response_model.dart';
import '../services/endpoints.dart';
import '../utils/common_code.dart';

class AuthRepo extends GetConnect {
  late HTTPClient _httpClient;
  static final _instance = AuthRepo._constructor();

  factory AuthRepo() {
    return _instance;
  }

  AuthRepo._constructor() {
    _httpClient = HTTPClient();
  }

  Future<UserModel?> registerUser(
      {required String email, String? password, required String name, required bool termAndCondition, required String deviceId}) async {
    Map<String, dynamic> data = {
      'email': email,
      'password': password,
      'name': name,
      'termAndCondition': termAndCondition,
      "deviceId": [deviceId],
    };
    // printLogs('===request data $data');
    String jsonData = jsonEncode(data);
    final response = await _httpClient.postRequestWithHeader(url: kRegisterUserURL, body: jsonData);
    // if (kDebugMode) {
    printLogs('Response registerUser: $response');
    printLogs('Response.statuscode: ${response.statusCode}');
    // }
    if (response.statusCode == 200) {
      try {
        Map<String, dynamic> jsonData = jsonDecode(response.data);
        if (kDebugMode) {
          printLogs('jsonData: $jsonData');
        }
        UserModel user = UserModel.fromJson(jsonData['data']);
        if (kDebugMode) {
          printLogs('UserResponseModel: ${user.email}');
        }
        SharedPrefrenceService.saveToken(user.authToken);
        SessionService().userToken = user.authToken;
        SessionService().user = user;
        SessionService().isUserLoggedIn = true;
        SessionService().setUserData();
        return user;
      } catch (e) {
        if (kDebugMode) {
          printLogs('Error registerUser: $e');
        }
      }
    } else {
      if (kDebugMode) {
        printLogs('Response registerUser: ${response.statusCode}');
      }
    }
    return null;
  }

  Future<UserModel?> loginUser({required String email, required String password, required String deviceId}) async {
    Map<String, dynamic> data = {'email': email, 'password': password, 'deviceId': deviceId};
    String jsonData = jsonEncode(data);
    final response = await _httpClient.putRequestWithHeader(url: kLoginUserURL, body: jsonData);
    if (response.statusCode == 200) {
      printLogs('------inIF: ${response.data}');
      try {
        Map<String, dynamic> jsonData = jsonDecode(response.data);
        UserResponseModel userResponseModel = UserResponseModel.fromJson(jsonData);
        SharedPrefrenceService.saveToken(userResponseModel.user.authToken);
        SharedPrefrenceService.saveUserModel(userResponseModel.user);
        SessionService().userToken = userResponseModel.user.authToken;
        SessionService().user = userResponseModel.user;
        SessionService().isUserLoggedIn = true;
        SessionService().setUserData();
        return userResponseModel.user;
      } catch (e) {
        if (kDebugMode) {
          printLogs('Error loginUser: $e');
        }
        CustomSnackbar.showSnackbar('Login Unsuccessful');
      }
    } else {
      if (kDebugMode) {
        printLogs('Response loginUser: ${response.statusCode}');
      }
      try {
        Map<String, dynamic> jsonData = jsonDecode(response.data);
        if (jsonData['success'] != null && jsonData['success'] == false) {
          CustomSnackbar.showSnackbar(jsonData['error'] ?? (jsonData['message'] ?? 'Login Unsuccessful'));
        }
      } catch (e) {
        print(e);
        CustomSnackbar.showSnackbar('Login Unsuccessful');
      }
    }
    return null;
  }

  Future<UserModel?> signUpWithGoogle(
      {required String deviceId, required String email, required String name, required id, required bool termAndCondition}) async {
    Map<String, dynamic> data = {
      "deviceId": [deviceId],
      'email': email,
      'name': name,
      "googleId": id,
      "termAndCondition": termAndCondition,
    };
    String jsonData = jsonEncode(data);
    // final response = await _httpClient.getRequestWithHeader(
    //   url: kAuthenticateGoogle,
    // );
    final response = await _httpClient.postRequestWithHeader(url: kRegisterUserURL, body: jsonData);
    if (kDebugMode) {
      printLogs('google: $response');
    }
    if (kDebugMode) {
      printLogs('Response.statuscode: ${response.statusCode}');
    }
    if (response.statusCode == 200) {
      if (kDebugMode) {
        printLogs('in sign google: ${response.data}');
      }
      try {
        Map<String, dynamic> jsonData = jsonDecode(response.data);
        if (kDebugMode) {
          printLogs('jsonData: $jsonData');
        }
        UserModel user;
        if (jsonData['data']['data'] != null) {
          user = UserModel.fromJson(jsonData['data']['data']);
        } else {
          user = UserModel.fromJson(jsonData['data']);
        }
        if (kDebugMode) {
          printLogs('UserResponseModel: ${user.email}');
        }
        SharedPrefrenceService.saveToken(user.authToken);
        SessionService().userToken = user.authToken;
        SessionService().user = user;
        SessionService().isUserLoggedIn = true;
        SessionService().setUserData();
        if (kDebugMode) {
          printLogs('User: ${user.email}');
        }
        return user;
      } catch (e) {
        if (kDebugMode) {
          printLogs('Error signUpWithGoogle: $e');
        }
      }
    } else {
      if (kDebugMode) {
        printLogs('Response signUpWithGoogle: ${response.statusCode}');
      }
    }
    return null;
  }

  // sing in with google

  Future<UserModel?> signInWithApple(
      {required String deviceId, required String email, required String name, required id, required bool termAndCondition}) async {
    Map<String, dynamic> data = {
      'email': email,
      'name': name,
      "appleId": id,
      "termAndCondition": termAndCondition,
      "deviceId": [deviceId]
      // 'deviceId': deviceToken
    };
    // CustomSnackbar.showSnackbar("for testing purpose param ${data}");
    String jsonData = jsonEncode(data);
    final response = await _httpClient.postRequestWithHeader(url: kRegisterUserURL, body: jsonData);
    /*final response = ResponseModel.named(statusCode: 200, statusDescription: "Success", data: {
      "success": true,
      "message": "User registered successfully",
      "data": {
        "authToken":
            "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJfaWQiOiI2NzVmMWViYTdlMDYxMzAwMTIzMDkyMDYiLCJpYXQiOjE3MzQyODcwMzR9.uZinJU-i6ctI7VsVpoP6u0b2H6ub6Gqk_4egqgY1YkM",
        "name": "webrangesolution",
        "email": "webrangesolution@gmail.com",
        "_id": "675f1eba7e06130012309206"
      }
    });*/
    printLogs('Response apple: $response');
    printLogs('apples id: $id');
    printLogs('Response.statuscode: ${response.statusCode}');
    // CustomSnackbar.showSnackbar("for testing purpose ${response}");
    if (response.statusCode == 200) {
      try {
        Map<String, dynamic> jsonData = response.data is String ? jsonDecode(response.data) : response.data;
        printLogs('jsonData check apple : ${jsonData["data"]}');
        UserModel user = jsonData["message"].toString().toLowerCase() == "user registered successfully"
            ? UserModel.fromJson(jsonData['data'])
            : UserModel.fromJson(jsonData['data']['data']);
        // printLogs('UserResponseModel: ${user.email}');
        SharedPrefrenceService.saveToken(user.authToken);
        SessionService().userToken = user.authToken;
        SessionService().user = user;
        SessionService().isUserLoggedIn = true;
        SessionService().setUserData();
        return user;
      } catch (e) {
        printLogs('Error signInWithApple: $e');
      }
    } else {
      printLogs('Response signInWithApple: ${response.statusCode}');
    }
    return null;
  }

  // fn for facebook
  Future<UserModel?> signInWithFacebook({required String email, required String name, required id, required bool termAndCondition}) async {
    Map<String, dynamic> data = {'email': email, 'name': name, "facebookId": id, "termAndCondition": termAndCondition};
    if (kDebugMode) {
      printLogs('Data: $data');
    }
    String jsonData = jsonEncode(data);
    final response = await _httpClient.postRequestWithHeader(url: kRegisterUserURL, body: jsonData);
    if (kDebugMode) {
      printLogs('Response signInWithFacebook: $response');
    }
    if (kDebugMode) {
      printLogs('Response.statuscode: ${response.statusCode}');
    }
    if (response.statusCode == 200) {
      try {
        Map<String, dynamic> jsonData = jsonDecode(response.data);
        if (kDebugMode) {
          printLogs('jsonData: $jsonData');
        }
        UserModel user = UserModel.fromJson(jsonData['data']['data']);
        if (kDebugMode) {
          printLogs('UserResponseModel: ${user.email}');
        }
        SharedPrefrenceService.saveToken(user.authToken);
        SessionService().userToken = user.authToken;
        SessionService().user = user;
        SessionService().isUserLoggedIn = true;
        SessionService().setUserData();
        return user;
      } catch (e) {
        if (kDebugMode) {
          printLogs('Error signInWithFacebook: $e');
        }
      }
    } else {
      if (kDebugMode) {
        printLogs('Response signInWithFacebook: ${response.statusCode}');
      }
    }
    return null;
  }

  Future<bool> checkUserExist({required String email}) async {
    Map<String, dynamic> data = {
      'email': email,
    };
    // String jsonData = jsonEncode(data);
    final response = await _httpClient.putRequestWithHeader(url: kCheckUser, body: jsonEncode(data));
    // if (kDebugMode) {
    printLogs('checkUserExist Response.statuscode: ${response.statusCode}');
    // }
    if (response.statusCode == 200) {
      try {
        Map<String, dynamic> jsonData = jsonDecode(response.data);
        //if (kDebugMode) {
        printLogs('jsonData: $jsonData');
        // }
        if (jsonData['message'] == "User Found" && jsonData['userid'] != null) {
          return true;
        } else {
          return false;
        }
      } catch (e) {
        if (kDebugMode) {
          printLogs('Error checkUserExist: $e');
        }
      }
    } else {
      if (kDebugMode) {
        printLogs('Response checkUserExist: ${response.statusCode}');
      }
    }
    return false;
  }

  // fn for logout
  Future<bool> logout() async {
    try {
      // HomeScreenController homeScreenController =
      //     Get.isRegistered<HomeScreenController>() ? Get.find<HomeScreenController>() : Get.put(HomeScreenController());
      // homeScreenController.videoControllers = <Rx<CachedVideoPlayerPlusController>>[].obs;
      final GoogleSignIn googleSignIn = GoogleSignIn();
      printLogs('================signout with goolge googleSignIn ${googleSignIn.currentUser}');
      if (googleSignIn.currentUser != null && googleSignIn.currentUser?.email == SessionService().user?.email) {
        printLogs('================signout with goolge');
        googleSignIn.signOut();
      }
      User? firebaseAuth = FirebaseAuth.instance.currentUser;
      printLogs('================signout with firebaseAuth $firebaseAuth');
      if (firebaseAuth != null) {
        await FirebaseAuth.instance.signOut();
      }
      SharedPrefrenceService.clearAllData();
      SessionService().clearAllData();
      Get.offAllNamed(kSignInRoute);
      return true;
    } catch (e) {
      if (kDebugMode) {
        printLogs('Error logout: $e');
      }
      Get.offAllNamed(kSignInRoute);
      return true;
    }
  }

  Future<bool> deleteUserAccount({required String userId}) async {
    // String jsonData = jsonEncode(data);
    final response = await _httpClient.deleteRequestWithHeader(
      url: "$kDeleteUser/$userId",
    );
    if (kDebugMode) {
      printLogs('Response.statuscode: ${response.statusCode}');
    }
    if (response.statusCode == 200) {
      try {
        Map<String, dynamic> jsonData = jsonDecode(response.data);
        printLogs('response.data: ${response.data}');
        if (jsonData['message'] == "User and related data deleted successfully" && jsonData['success'] == true) {
          return true;
        } else {
          return false;
        }
      } catch (e) {
        printLogs('Error deleteUserAccount: $e');
      }
    } else {
      printLogs('Response deleteUserAccount: ${response.statusCode}');
    }
    return false;
  }

  ///fn Send otp to email
  Future<bool?> sendOtpToEmail({required String email}) async {
    Map<String, dynamic> fields = {"userId": SessionService().user?.id, "email": email.trim()};
    try {
      final body = jsonEncode(fields);
      final response = await _httpClient.postRequestWithHeader(
        url: kSendOtpToEmail,
        body: body,
      );

      if (kDebugMode) {
        printLogs('Response sendOtpToEmail: $response');
      }
      if (kDebugMode) {
        printLogs('Response.statuscode: ${response.statusCode}');
      }
      if (response.statusCode == 200 || response.statusCode == 400) {
        //CustomSnackbar.showSnackbar('Otp sent successfully');
        Map<String, dynamic> jsonData = jsonDecode(response.data);

        if (kDebugMode) {
          printLogs('Data: ${jsonData["success"]}');
        }

        bool isSuccess = jsonData["success"];
        if (isSuccess) {
          if (kDebugMode) {
            printLogs('Data: ${jsonData["message"]}');
          }
        } else {
          CustomSnackbar.showSnackbar(jsonData["data"]["error"] != null
              ? '${jsonData["data"]["error"]}'
              : jsonData["error"] == null
                  ? "Something went wrong, please try again"
                  : '${jsonData["error"]}');
        }
        return isSuccess;
      } else {
        CustomSnackbar.showSnackbar('Error occurred while sending OTP, try again');
        if (kDebugMode) {
          printLogs('Response sendOtpToEmail: ${response.statusCode}');
        }
        return false;
      }
    } catch (e) {
      CustomSnackbar.showSnackbar('Something went wrong, please try again');
      if (kDebugMode) {
        printLogs('Error sendOtpToEmail: $e');
      }
    }
    return null;
  }

  /// fn to verify otp

  Future<bool?> verifyOtp({String email = "", required String otp, bool isForForgotPassword = false}) async {
    Map<String, dynamic> body = {"userId": SessionService().user?.id, "email": email.trim(), "otp": otp};

    ResponseModel response = await _httpClient.putRequestWithoutHeader(
      url: kVerifyOtp,
      body: jsonEncode(body),
    );
    try {
      if (kDebugMode) {
        printLogs('Response verifyOtp: $response');

        printLogs('Response verifyOtp: ${response.data}');

        printLogs('Response.statuscode: ${response.statusCode}');
      }
      if (response.statusCode == 200 || response.statusCode == 400) {
        Map<String, dynamic> jsonData = jsonDecode(response.data);

        if (kDebugMode) {
          printLogs('Response verifyOtp: ${jsonData["success"]}');

          // printLogs('Response verifyOtp: ${jsonData["data"]}');
        }

        bool isSuccess = jsonData["success"];
        if (isSuccess) {
          if (kDebugMode) {
            printLogs('Data: ${jsonData["message"]}');
          }
          SessionService().verifiedEmail = email;
          SessionService().isEmailVerified = true;
          SessionService().saveEmailVerificationDetails();
          CustomSnackbar.showSnackbar('Email verified successfully');
        } else {
          CustomSnackbar.showSnackbar(jsonData["data"]["error"] != null
              ? '${jsonData["data"]["error"]}'
              : jsonData["error"] == null
                  ? "Something went wrong, please try again"
                  : '${jsonData["error"]}');
        }
        return isSuccess;
      } else {
        if (!isForForgotPassword) {
          CustomSnackbar.showSnackbar('${response.data['data']['error']}');
          if (kDebugMode) {
            printLogs('error: ${response.data['data']['error']}');
          }
        }
        return false;
      }
    } catch (e) {
      if (kDebugMode) {
        printLogs('Error on verifyOtp : $e');
      }
      CustomSnackbar.showSnackbar('Something went wrong, please try again');
    }
    return null;
  }
}
