import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:socials_app/services/endpoints.dart';
import 'package:socials_app/services/session_services.dart';
import 'package:socials_app/services/sharedprefrence_service.dart';
import 'package:socials_app/utils/app_colors.dart';
import 'package:socials_app/utils/app_images.dart';
import 'package:socials_app/utils/app_strings.dart';
import 'package:socials_app/utils/common_code.dart';
import 'package:socials_app/views/screens/profile/screen/profile_screen.dart';

import 'models/recordings_models/local_video_post_model.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    SessionService().getUserData();
    splashTimer(context);
    getUploadingVideos();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackgroundColor,
      resizeToAvoidBottomInset: false,
      body: SafeArea(
        child: Container(
          margin: EdgeInsets.only(left: 20.w, right: 20.w),
          width: Get.width,
          height: Get.height,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Center(child: Image.asset(kBaseURL.contains("staging") ? kAppLogoBeta : kAppLogo)),
              // Center(child: Image.asset(kAppLogo)),
            ],
          ),
        ),
      ),
    );
  }

  void splashTimer(BuildContext context) async {
    bool isExist = await SessionService().checkUserSession();

    if (isExist) {
      // HomeScreenController homeScreenController =
      //     Get.isRegistered<HomeScreenController>() ? Get.find<HomeScreenController>() : Get.put(HomeScreenController());
      // homeScreenController.onInit();
      Future.delayed(const Duration(seconds: 5)).then((value) {
        Get.offAndToNamed(kBottomNavBar);
        // Get.offAndToNamed(kChatScreenRoute);
      });
    } else {
      await Future.delayed(const Duration(seconds: 3));
      Get.offAndToNamed(kRecordingRoute);
    }
  }

  // RxList<LocalUserVideoPostModel> listUploadingVideos = RxList();
  getUploadingVideos() async {
    printLogs("===========getUploadingVideos ");
    List<Map> videos = await SharedPrefrenceService.getTempVideos();
    printLogs("===========getUploadingVideos videos ${videos.length}");
    for (int i = 0; i < videos.length; i++) {
      printLogs("===========getUploadingVideos inside for ${videos.length} $i");
      LocalUserVideoPostModel listUploadingVideos = (LocalUserVideoPostModel.fromJson(videos[i]));

      printLogs("Calling From Splash UploadStatus.failed");
      SharedPrefrenceService.saveUploadStatus(listUploadingVideos.videoPath ?? "", UploadStatus.failed);
      SharedPrefrenceService.saveUploadProgress(listUploadingVideos.videoPath ?? "", 0.0);
      printLogs("===========getUploadingVideos inside for listUploadingVideos ${listUploadingVideos.videoPath} $i");
    }
  }
}
