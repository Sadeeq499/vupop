import 'dart:developer';

// import 'package:the_apple_sign_in/the_apple_sign_in.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:socials_app/main.dart';
import 'package:socials_app/repositories/auth_repo.dart';
import 'package:socials_app/services/custom_snackbar.dart';
import 'package:socials_app/services/session_services.dart';
import 'package:socials_app/services/sharedprefrence_service.dart';
import 'package:socials_app/utils/app_colors.dart';
import 'package:socials_app/utils/app_strings.dart';
import 'package:socials_app/views/screens/home_recordings/controller/recording_cont.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../utils/common_code.dart';

class AuthController extends GetxController {
  GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  GlobalKey<FormState> loginFormKey = GlobalKey<FormState>();
  TextEditingController tecUserName = TextEditingController(),
      tecEmail = TextEditingController(),
      tecPassword = TextEditingController();
  FocusNode fnUsername = FocusNode(),
      fnEmail = FocusNode(),
      fnPassword = FocusNode();
  RxBool isHidePassword = true.obs;
  RxBool showOtherFields = false.obs;
  RxBool isAllFieldFilled = false.obs;
  final GoogleSignIn googleSignIn = GoogleSignIn();
  RxBool isLoading1 = false.obs;
  RxBool isLoading3 = false.obs;
  final _auth = FirebaseAuth.instance;
  RxBool isFullLoading = false.obs;
  RxBool isVaildEmail = false.obs;
  RxBool termAndConditionAccepted = false.obs;
  @override
  void onInit() {
    super.onInit();
    tecEmail.addListener(_checkAllFieldsFilled);
    tecUserName.addListener(_checkAllFieldsFilled);
    tecPassword.addListener(_checkAllFieldsFilled);
  }

  void _checkAllFieldsFilled() {
    isAllFieldFilled.value = tecEmail.text.trim().isNotEmpty &&
        tecUserName.text.isNotEmpty &&
        tecPassword.text.isNotEmpty;
  }

  @override
  void onClose() {
    tecEmail.removeListener(_checkAllFieldsFilled);
    tecUserName.removeListener(_checkAllFieldsFilled);
    tecPassword.removeListener(_checkAllFieldsFilled);
    super.onClose();
  }

  Future signInWithGoogle(BuildContext context) async {
    try {
      final GoogleSignInAccount? userAccount = await googleSignIn.signIn();
      if (userAccount == null) {
        isLoading1.value = false;
        Get.snackbar(
          backgroundColor: kWhiteColor,
          'Login unsuccessful',
          'Sign in with Google canceled.',
        );
        return;
      }
      final GoogleSignInAuthentication googleAuth =
          await userAccount.authentication;
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      UserCredential userCredential =
          await FirebaseAuth.instance.signInWithCredential(credential);
      // FirebaseAuth.instance.signInWithCredential(credential);
      termAndConditionAccepted.value = true;
      await AuthRepo()
          .signUpWithGoogle(
              deviceId: deviceToken,
              email: userAccount.email,
              name: userAccount.displayName ?? '',
              id: googleAuth.accessToken,
              termAndCondition: termAndConditionAccepted.isTrue)
          .then((value) async {
        if (value != null && value.authToken != "") {
          isLoading1.value = false;
          CustomSnackbar.showSnackbar('Login Successful');
          await videoUploadFirstTime();
          if (Get.find<RecordingController>().isVideoAvailable.value) {
            printLogs("===========going to profile signInWithGoogle");
            Get.offAllNamed(kBottomNavBar);
          } else {
            Get.offAllNamed(kBottomNavBar);
          }
          /*await videoUploadFirstTime();

          if (Get.find<RecordingController>().isVideoAvailable.value) {
            Get.toNamed(kBottomNavBar);
          } else {
            Get.toNamed(kBottomNavBar);
          }*/
        } else {
          isLoading1.value = false;
          CustomSnackbar.showSnackbar('Login Unsuccessful');
        }
      });
    } catch (e) {
      printLogs('===google sign in Error: $e');
      isLoading1.value = false;
      Get.snackbar(
          backgroundColor: kWhiteColor,
          'Data not found',
          'Please enter valid credentials. $e');
    }
  }

  Future signInWithApple(BuildContext context) async {
    try {
      final AuthorizationCredentialAppleID authorizationResult =
          await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
      );

      final AuthCredential credential = OAuthProvider('apple.com').credential(
        idToken: authorizationResult.identityToken,
        accessToken: authorizationResult.authorizationCode,
      );
      UserCredential userCredential =
          await FirebaseAuth.instance.signInWithCredential(credential);
      isLoading1.value = false;
      isLoading3.value = false;

      printLogs("======deviceToken $deviceToken");
      if (deviceToken.isEmpty) {
        deviceToken = await FirebaseMessaging.instance.getToken() ?? '';
      }
      termAndConditionAccepted.value = true;
      final resp = await AuthRepo().signInWithApple(
          deviceId: deviceToken,
          email: userCredential.user?.email ?? '',
          name: userCredential.user != null
              ? userCredential.user!.displayName != null &&
                      userCredential.user!.displayName!.isNotEmpty
                  ? userCredential.user!.displayName!
                  : userCredential.user?.email != null
                      ? userCredential.user!.email!.split("@")[0]
                      : ""
              : "",
          id: credential.accessToken ?? '',
          termAndCondition: termAndConditionAccepted.isTrue);
      if (resp != null) {
        printLogs('Data: ${resp.email}');
        CustomSnackbar.showSnackbar('Login Successful');
        await videoUploadFirstTime();
        if (Get.find<RecordingController>().isVideoAvailable.value) {
          printLogs("===========going to profile apple");
          Get.offAllNamed(kBottomNavBar);
        } else {
          Get.offAllNamed(kBottomNavBar);
        }
      } else {
        CustomSnackbar.showSnackbar('Login Unsuccessful');
      }
      // Get.toNamed(kBottomNavBar);
    } catch (e) {
      printLogs("SignInWithApple Exception $e");
      isLoading3.value = false;
      isLoading1.value = false;
      Get.snackbar(
          backgroundColor: kWhiteColor,
          'Data not found',
          'Please enter valid credentials.');
    }
  }

  /// sign in with facebook
  Future<void> signInWithFacebook() async {
    // CustomSnackbar.showSnackbar('Coming Soon');
    try {
      final LoginResult result = await FacebookAuth.instance
          .login(permissions: ['email', 'public_profile']);

      // Map<String, dynamic> userData = {};
      if (result.status == LoginStatus.success) {
        final userData = await FacebookAuth.instance.getUserData();

        // log(result.message ?? '');
        termAndConditionAccepted.value = true;
        final resp = await AuthRepo().signInWithFacebook(
            id: result.accessToken?.tokenString ?? '',
            email: userData['email'] ?? '',
            name: userData['name'] ?? '',
            termAndCondition: termAndConditionAccepted.isTrue);
        if (resp != null) {
          CustomSnackbar.showSnackbar('Login Successful');
          await videoUploadFirstTime();
          if (Get.find<RecordingController>().isVideoAvailable.value) {
            printLogs("===========going to profile signInWithFacebook");
            Get.offAllNamed(kBottomNavBar);
          } else {
            Get.offAllNamed(kBottomNavBar);
          }
          /*

          await videoUploadFirstTime();
          if (Get.find<RecordingController>().isVideoAvailable.value) {
            Get.toNamed(kBottomNavBar);
          } else {
            Get.toNamed(kBottomNavBar);
          }*/
        } else {
          CustomSnackbar.showSnackbar('Login Unsuccessful');
        }
      } else {
        CustomSnackbar.showSnackbar('Login Unsuccessful');
      }
    } catch (e) {
      log('Error Login: $e');
      CustomSnackbar.showSnackbar('Login Unsuccessful');
    }
  }

  /// This function is used to register the user
  Future<void> registerUser() async {
    try {
      isFullLoading.value = true;
      final data = await AuthRepo().registerUser(
        email: tecEmail.text.trim(),
        password: tecPassword.text,
        name: tecUserName.text,
        termAndCondition: termAndConditionAccepted.isTrue,
        deviceId: deviceToken,
      );
      // printLogs('========data $data');
      if (data != null) {
        isLoading1.value = false;
        CustomSnackbar.showSnackbar('Registration Successful');
        await videoUploadFirstTime();
        // Get.toNamed(kBottomNavBar);
        Get.toNamed(kBottomNavBar);
        isFullLoading.value = false;
        printLogs("===========going to profile registerUser");
        // Get.offAllNamed(kBottomNavBar);
      } else {
        isLoading1.value = false;
        isFullLoading.value = false;
        CustomSnackbar.showSnackbar('Registration Unsuccessful');
      }
    } catch (e) {
      isLoading1.value = false;
      isFullLoading.value = false;
      CustomSnackbar.showSnackbar('Registration Unsuccessful');
    }
  }

  /// This function is used to login the user
  Future<void> loginUser() async {
    isFullLoading.value = true;
    try {
      final data = await AuthRepo().loginUser(
        email: tecEmail.text.trim(),
        password: tecPassword.text,
        deviceId: deviceToken,
      );
      if (data != null) {
        CustomSnackbar.showSnackbar('Login Successful');
        await videoUploadFirstTime();

        printLogs("===========going to profile loginUser");
        Get.offAllNamed(kBottomNavBar);
      } else {
        // CustomSnackbar.showSnackbar('Login Unsuccessful');
      }
    } catch (e) {
      isLoading1.value = false;
      CustomSnackbar.showSnackbar('Login Unsuccessful');
    }
    isFullLoading.value = false;
  }

  /// fn to check if the user is exist or not
  RxBool isUserExist = false.obs;
  Future<void> checkUser() async {
    try {
      final data = await AuthRepo().checkUserExist(
        email: tecEmail.text.trim(),
      );

      printLogs('Data checkUser: $data');
      if (data) {
        isUserExist.value = true;
      } else {}
    } catch (e) {
      log('Error checkUser: $e');
    }
  }

  checkUserANdVideo() {
    Get.isRegistered<RecordingController>()
        ? Get.find<RecordingController>()
        : Get.put(RecordingController());
    SharedPrefrenceService.setIsFirstVideo();
    return (SessionService().isUserLoggedIn &&
        Get.find<RecordingController>().isVideoAvailable.value);
  }

  //// fn for video upload if first time
  Future<bool> videoUploadFirstTime() async {
    printLogs('=======uploading videos first time');
    Get.isRegistered<RecordingController>()
        ? Get.find<RecordingController>()
        : Get.put(RecordingController());

    bool isExist = SessionService().isUserLoggedIn &&
        Get.find<RecordingController>().isVideoAvailable.value;
    if (isExist) {
      printLogs('=======uploading videos first time available');
      await SharedPrefrenceService.setIsFirstVideo();
      bool isAdded =
          await Get.find<RecordingController>().videoUploadFirstTime();
      return isAdded;
    } else {
      return isExist;
    }
  }

  //open t&c
  Future<void> launchTermsAndPrivacyUrl() async {
    //final Uri _url = Uri.parse('https://app.termly.io/policy-viewer/policy.html?policyUUID=39e5fa85-27e2-43da-a164-b75e93ce1488');
    final Uri _url = Uri.parse(
        'https://app.termly.io/policy-viewer/policy.html?policyUUID=6911806b-c1c8-4de8-a493-a2a2714e20e8');
    if (!await launchUrl(_url)) {
      throw Exception('Could not launch $_url');
    } else {
      termAndConditionAccepted.value = true;
    }
  }
}
