import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:socials_app/services/permission_service.dart';
import 'package:socials_app/utils/app_colors.dart';
import 'package:socials_app/utils/app_images.dart';
import 'package:socials_app/views/screens/home_recordings/controller/recording_cont.dart';
import 'package:socials_app/views/screens/profile/controller/profile_controller.dart';

import '../../../services/custom_snackbar.dart';
import '../../../services/session_services.dart';
import '../../../utils/common_code.dart';
import '../home_recordings/components/countdown_widget.dart';
import 'controller/bottom_bar_controller.dart';

class BottomNavigationScreen extends GetView<BottomBarController> {
  const BottomNavigationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    Get.log("Build Method");
    /*Future.microtask((){
      Get.isRegistered<RecordingController>() ? Get.find<RecordingController>() : Get.put(RecordingController());

      if (SessionService().isUserLoggedIn && Get.find<RecordingController>().isVideoAvailable.value) {
        printLogs('=======uploading videos first time available');
        Get.find<RecordingController>().videoUploadFirstTime();
      }
    });*/
    return Scaffold(
      body: Obx(
        () => controller.pages[controller.selectedIndex.value],
      ),
      // floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      // floatingActionButton: FloatingActionButton(
      //   shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100.r)),
      //     onPressed: (){
      //
      //     },
      //     child: GestureDetector(
      //         onTap: (){
      //           Get.toNamed(kRecordingRoute);
      //         },
      //         child: CircleAvatar(backgroundColor: kPrimaryColor,radius: 50.r,)),),
      bottomNavigationBar: Obx(
        () => (SessionService().isUserLoggedIn &&
                Get.find<RecordingController>().isRecording.value)
            ? SizedBox.shrink()
            : BottomNavigationBar(
                type: BottomNavigationBarType.fixed,
                selectedFontSize: 16.sp,
                unselectedFontSize: 16.sp,
                showUnselectedLabels: true,
                fixedColor: kBlackColor,
                backgroundColor: kBlackColor,
                currentIndex: controller.selectedIndex.value,
                onTap: (index) async {
                  controller.selectedIndex.value = index;
                  if (index != 1) {
                    printLogs('========resetRecording');
                    Get.find<RecordingController>().stopCamera();
                    Get.find<RecordingController>().resetRecording();
                  }
                  /*if (index != 0) {
              HomeScreenController homeScreenController =
                  Get.isRegistered<HomeScreenController>() ? Get.find<HomeScreenController>() : Get.put(HomeScreenController());
              Get.find<HomeScreenController>().isVideoChanged.value = false;
              Get.find<VideoPlayerControllerX>().videoPlayerController?.pause();
              Get.find<VideoPlayerControllerX>().videoPlayerController?.dispose();
              Get.find<VideoPlayerControllerX>().videoPlayerController = null;
              // homeScreenController.videoControllers[homeScreenController.previousValue.bitLength].value.pause();
              for (int i = 0; i < homeScreenController.videoControllers.length; i++) {
                if (homeScreenController.videoControllers[i].value.value.isPlaying) {
                  homeScreenController.videoControllers[i].value.controller.pause();
                  homeScreenController.isPlaying.value = false;
                }
                homeScreenController.videoControllers[i].refresh();
              }
              // homeScreenController.videoControllers.map((controller) => controller.value.pause());
            } else {
              HomeScreenController homeScreenController =
                  Get.isRegistered<HomeScreenController>() ? Get.find<HomeScreenController>() : Get.put(HomeScreenController());

              // homeScreenController.videoControllers[homeScreenController.previousValue.bitLength]?.play();
            }*/
                  if (index == 1 &&
                      Get.find<RecordingController>().isRecording.value) {
                    Get.find<RecordingController>().stopRecordingForNonDual();
                    Get.find<RecordingController>().isRecording.value = false;
                    // Get.find<RecordingController>().checkAndReinitializeCamera();

                    // showModalBottomSheet(
                    //   context: Get.context!,
                    //   backgroundColor: kGreyContainerColor,
                    //   builder: (context) {
                    //     return SizedBox(
                    //       // height: 150.h,
                    //       child: Column(
                    //         mainAxisSize: MainAxisSize.min,
                    //         children: [
                    //           ListTile(
                    //             title: const Text('Record Video', style: TextStyle(color: Colors.white, fontSize: 16)),
                    //             leading: Icon(Icons.videocam_rounded, color: kPrimaryColor.withOpacity(0.8)),
                    //             onTap: () async {
                    //               Get.back();
                    //               Get.find<RecordingController>().resetRecording();
                    //               Get.find<RecordingController>().onInit();
                    //             },
                    //           ),
                    //           ListTile(
                    //             title: Text(
                    //               'Select Video',
                    //               style: AppStyles.labelTextStyle().copyWith(
                    //                 color: Colors.white,
                    //                 fontSize: 16,
                    //               ),
                    //             ),
                    //             leading: Icon(
                    //               Icons.video_collection,
                    //               color: kPrimaryColor.withOpacity(0.8),
                    //             ),
                    //             onTap: () {
                    //               Get.back();
                    //               Get.find<RecordingController>().resetRecording();
                    //               Get.find<RecordingController>().isFileSelected.value = true;
                    //               Get.find<RecordingController>().onInit();
                    //               // controller.pickVideo();
                    //               // Get.back();
                    //             },
                    //           ),
                    //         ],
                    //       ),
                    //     );
                    //   },
                    // );
                    /*Get.find<RecordingController>().resetRecording();
              Get.find<RecordingController>().onInit();*/
                  } else if (controller.previousSelectedIndex.value == 1 &&
                      index == 1 &&
                      !Get.find<RecordingController>().isRecording.value) {
                    if (Get.find<RecordingController>()
                        .isFinishedRecording
                        .isTrue) {
                      Get.find<RecordingController>().resetRecording();
                    }
                    printLogs('============inside second if');
                    // Get.find<RecordingController>().resetRecording();
                    if (await PermissionsService().hasCameraPermission()) {
                      Get.find<RecordingController>().initalization();
                    } else {
                      await PermissionsService().requestCameraPermission(
                        onPermissionGranted: () {
                          printLogs("Camera permission granted");
                        },
                        onPermissionDenied: () {
                          printLogs("Camera permission denied");
                          CustomSnackbar.showSnackbar(
                              "Camera permission is required for recording, please enable it from settings");
                        },
                      );
                    }
                    // Get.find<RecordingController>().showQualityRulesSheet();
                  } else if (index == 1) {
                    // Get.find<RecordingController>().onInit();
                    Get.find<RecordingController>().resetRecording();
                    Get.find<RecordingController>().firstInit();
                  } else if (index == 2) {
                    // SocialWalletController socialWalletController =
                    //     Get.isRegistered<SocialWalletController>() ? Get.find<SocialWalletController>() : Get.put(SocialWalletController());
                    // socialWalletController.getWalletBalance();
                  } else if (index == 0) {
                    ProfileScreenController profileScreenController =
                        Get.isRegistered<ProfileScreenController>()
                            ? Get.find<ProfileScreenController>()
                            : Get.put(ProfileScreenController());
                    profileScreenController.getData();
                  }
                  controller.previousSelectedIndex.value = index;
                },
                items: [
                  /*BottomNavigationBarItem(
              icon: _buildNavItem(kHomeInactive, kHomeActive, controller.selectedIndex.value == 0),
              label: ' ',
            ),
            BottomNavigationBarItem(
              icon: _buildNavItem(kSearchInactive, kSearchActive, controller.selectedIndex.value == 1),
              label: ' ',
            ),*/

                  BottomNavigationBarItem(
                    icon: _buildNavItem(kProfileInactive, kUserActive,
                        controller.selectedIndex.value == 0),
                    label: ' ',
                  ),
                  BottomNavigationBarItem(
                    backgroundColor: Colors.black,
                    icon: Obx(
                      () => GestureDetector(
                          onLongPress: controller.selectedIndex.value == 1 &&
                                  Get.find<RecordingController>()
                                      .isRecording
                                      .value
                              ? () async {
                                  if (Get.find<RecordingController>()
                                      .isFinishedRecording
                                      .isTrue) {
                                    Get.find<RecordingController>()
                                        .resetRecording();
                                  }
                                  // Get.find<RecordingController>().resetRecording();
                                  if (await PermissionsService()
                                      .hasCameraPermission()) {
                                    Get.find<RecordingController>()
                                        .initalization();
                                  } else {
                                    await PermissionsService()
                                        .requestCameraPermission(
                                      onPermissionGranted: () {
                                        printLogs("Camera permission granted");
                                      },
                                      onPermissionDenied: () {
                                        printLogs("Camera permission denied");
                                        CustomSnackbar.showSnackbar(
                                            "Camera permission is required for recording, please enable it from settings");
                                      },
                                    );
                                  }
                                  // Get.find<RecordingController>().showQualityRulesSheet();
                                }
                              : null,
                          child: controller.selectedIndex.value == 1 &&
                                  Get.find<RecordingController>()
                                      .isRecording
                                      .value
                              ? RotatedBox(
                                  quarterTurns: Get.find<RecordingController>()
                                      .rotateValue
                                      .value
                                      .toInt(),
                                  child: CountDownWidget(
                                      controller:
                                          Get.find<RecordingController>()))
                              : Image.asset(
                                  kRecording,
                                  width: 65.w,
                                  height: 65.w,
                                )),
                    ),
                    label: ' ',
                  ),
                  BottomNavigationBarItem(
                    icon: _buildNavItem(kMessageInactive, kMessageActive,
                        controller.selectedIndex.value == 2),
                    label: ' ',
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildNavItem(
      String inactiveIcon, String activeIcon, bool isSelected) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Image.asset(
          isSelected ? activeIcon : inactiveIcon,
          width: 24.w,
          height: 24.h,
        ),
        SizedBox(height: 4.h),
        Container(
          width: 24.w,
          height: 4.h,
          decoration: BoxDecoration(
            color: isSelected ? kPrimaryColor : Colors.transparent,
            borderRadius: BorderRadius.circular(2.h),
          ),
        ),
      ],
    );
  }
}
