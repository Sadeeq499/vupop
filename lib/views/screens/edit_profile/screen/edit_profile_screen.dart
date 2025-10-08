import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:socials_app/utils/app_colors.dart';
import 'package:socials_app/utils/app_images.dart';
import 'package:socials_app/utils/common_code.dart';
import 'package:socials_app/views/custom_widgets/custom_button.dart';
import 'package:socials_app/views/custom_widgets/custom_scaffold.dart';
import 'package:socials_app/views/custom_widgets/drawer.dart';

import '../../../../utils/app_styles.dart';
import '../components/edit_fav_post.dart';
import '../controller/edit_profile_controller.dart';

class EditProfileScreen extends GetView<EditProfileController> {
  const EditProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    final double itemHeight = (size.height * 0.3);
    final double itemWidth = size.width / 2;

    return Obx(
      () => ModalProgressHUD(
        inAsyncCall: controller.isLoading.value,
        child: CustomScaffold(
          className: 'Edit Profile Screen',
          screenName: "Edit Profile",
          scaffoldKey: controller.editProfileKey,
          isFullBody: false,
          isBackIcon: true,
          leadingWidth: 30,
          // padding: EdgeInsets.only(top: 10.h),
          backIconColor: kPrimaryColor,
          actions: [
            Padding(
              padding: EdgeInsets.only(right: 20.w),
              child: GestureDetector(
                onTap: () {
                  controller.editProfileKey.currentState?.openDrawer();
                },
                child: const Icon(Icons.menu, color: kPrimaryColor),
              ),
            ),
          ],
          drawer: ProfileDrawer(),
          body: CustomScrollView(
            slivers: <Widget>[
              SliverToBoxAdapter(
                child: Column(
                  children: [
                    SizedBox(height: 50.h),
                    Obx(
                      () => Container(
                        width: 200.w,
                        height: 200.h,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          image: controller.addedPickedImage.value == ''
                              ? DecorationImage(
                                  image: AssetImage(kdummyPerson),
                                  fit: BoxFit.fill,
                                )
                              : DecorationImage(
                                  image: CommonCode().isValidURL(controller.addedPickedImage.value)
                                      ? CachedNetworkImageProvider(
                                          controller.addedPickedImage.value,
                                          errorListener: (exception) {
                                            // Log or handle the error
                                            printLogs('Image loading error: $exception');
                                          },
                                        ) as ImageProvider
                                      : FileImage(File(controller.addedPickedImage.value)),
                                  fit: BoxFit.cover),
                        ),
                        child: Stack(
                          children: [
                            Positioned(
                              bottom: 0,
                              child: GestureDetector(
                                onTap: () {
                                  showModalBottomSheet(
                                      context: context,
                                      builder: (BuildContext context) {
                                        return Container(
                                          height: 150.h,
                                          decoration: const BoxDecoration(
                                              color: kGreyContainerColor,
                                              borderRadius: BorderRadius.only(
                                                topLeft: Radius.circular(20),
                                                topRight: Radius.circular(20),
                                              )),
                                          child: Column(
                                            children: [
                                              ListTile(
                                                leading: const Icon(
                                                  Icons.camera_alt,
                                                  color: kWhiteColor,
                                                ),
                                                title: const Text(
                                                  'Camera',
                                                  style: TextStyle(color: kWhiteColor),
                                                ),
                                                onTap: () {
                                                  controller.changeImage(ImageSource.camera);
                                                  Get.back();
                                                },
                                              ),
                                              ListTile(
                                                leading: const Icon(
                                                  Icons.image,
                                                  color: kWhiteColor,
                                                ),
                                                title: const Text('Gallery', style: TextStyle(color: kWhiteColor)),
                                                onTap: () async {
                                                  controller.changeImage(ImageSource.gallery);

                                                  Get.back();
                                                },
                                              ),
                                            ],
                                          ),
                                        );
                                      });
                                },
                                child: Container(
                                  width: 200.w,
                                  height: 32.h,
                                  padding: EdgeInsets.symmetric(vertical: 11.h),
                                  clipBehavior: Clip.antiAlias,
                                  decoration: BoxDecoration(color: kBlackColor.withOpacity(0.5)),
                                  child: Text(
                                    'Change',
                                    textAlign: TextAlign.center,
                                    style: AppStyles.labelTextStyle().copyWith(
                                      color: kPrimaryColor,
                                      fontFamily: 'Norwester',
                                      height: 0.05,
                                    ),
                                  ),
                                ),
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 25),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Name',
                          style: AppStyles.labelTextStyle().copyWith(
                            color: kWhiteColor2,
                            fontSize: 16,
                            fontFamily: 'Norwester',
                            height: 0.08,
                          ),
                        ),
                        SizedBox(height: 25.h),
                        TextField(
                          // cursorHeight: 40.h,
                          controller: controller.nameController,

                          decoration: InputDecoration(
                            hintText: controller.nameController.text.isEmpty ? 'Enter your name' : controller.nameController.text,
                            enabledBorder: const UnderlineInputBorder(
                              borderSide: BorderSide(color: kPrimaryColor, width: 1),
                            ),
                            focusedBorder: const UnderlineInputBorder(
                              borderSide: BorderSide(color: kPrimaryColor),
                            ),
                            // counterStyle: AppStyles.labelTextStyle().copyWith(
                            //   color: kPrimaryColor,
                            //   fontSize: 24,
                            //   fontFamily: 'Norwester',
                            //   fontWeight: FontWeight.w400,
                            //   height: 0.03,
                            // ),
                            fillColor: Colors.black,
                            filled: true,
                          ),
                          style: AppStyles.labelTextStyle().copyWith(
                            color: kPrimaryColor,
                            fontSize: 24,
                            fontFamily: 'Norwester',
                            height: 1.0,
                          ),
                        ),
                        SizedBox(height: 25.h),
                        Text(
                          'About you',
                          style: AppStyles.labelTextStyle().copyWith(
                            color: Colors.white,
                            fontSize: 16,
                            fontFamily: 'Norwester',
                            // height: 0.08,
                          ),
                        ),
                        SizedBox(height: 20.h),
                        TextField(
                          controller: controller.aboutYouController,
                          decoration: InputDecoration(
                            enabledBorder: const UnderlineInputBorder(
                              borderSide: BorderSide(color: kPrimaryColor),
                            ),
                            hintText: 'Tell people about you, what you like what are your passions....etc',
                            hintStyle: AppStyles.labelTextStyle().copyWith(
                              color: Colors.white.withOpacity(0.6),
                              fontSize: 12.sp,
                            ),
                            focusedBorder: const UnderlineInputBorder(
                              borderSide: BorderSide(color: kPrimaryColor),
                            ),
                            fillColor: Colors.black,
                            filled: true,
                          ),
                          style: TextStyle(
                            color: kPrimaryColor,
                            fontSize: 16.sp,
                          ),
                        ),
                        SizedBox(height: 25.h),
                        Row(
                          children: [
                            Text(
                              'Your Passion',
                              style: AppStyles.labelTextStyle().copyWith(
                                color: kWhiteColor,
                                fontSize: 16.sp,
                                fontFamily: 'Norwester',
                                height: 0.08,
                              ),
                            ),
                            const Spacer(),
                            GestureDetector(
                              onTap: () {
                                showModalBottomSheet(
                                  context: context,
                                  isScrollControlled: true,
                                  builder: (BuildContext context) {
                                    return FractionallySizedBox(
                                      heightFactor: controller.passions.isEmpty
                                          ? 0.3
                                          : controller.passions.length < 4
                                              ? 0.5
                                              : 0.7,
                                      child: Container(
                                        width: Get.width,
                                        height: Get.height,
                                        padding: EdgeInsets.symmetric(vertical: 20.h, horizontal: 20.w),
                                        decoration: const BoxDecoration(
                                          color: kGreyContainerColor,
                                          borderRadius: BorderRadius.only(
                                            topLeft: Radius.circular(20),
                                            topRight: Radius.circular(20),
                                          ),
                                        ),
                                        child: SingleChildScrollView(
                                          child: Column(
                                            children: [
                                              Text(
                                                'Select your passion',
                                                style: AppStyles.labelTextStyle().copyWith(
                                                  color: kWhiteColor,
                                                  fontSize: 20.sp,
                                                ),
                                              ),
                                              SizedBox(height: 20.h),
                                              GetBuilder<EditProfileController>(
                                                builder: (cont) => Wrap(
                                                  spacing: 2.w,
                                                  alignment: WrapAlignment.center,
                                                  runAlignment: WrapAlignment.center,
                                                  children: List.generate(
                                                    cont.passions.length,
                                                    (index) {
                                                      final passion = cont.passions[index];

                                                      final isSelected =
                                                          controller.userPassions.any((selectedPassion) => selectedPassion.id == passion.id);

                                                      return Padding(
                                                        padding: const EdgeInsets.only(bottom: 5),
                                                        child: GestureDetector(
                                                          onTap: () {
                                                            cont.addPassion(passion);
                                                          },
                                                          child: Chip(
                                                            label: Row(
                                                              mainAxisSize: MainAxisSize.min,
                                                              children: [
                                                                Text(
                                                                  passion.title ?? '',
                                                                  style: AppStyles.labelTextStyle().copyWith(
                                                                    color: kBlackColor,
                                                                    fontSize: 16.sp,
                                                                  ),
                                                                ),
                                                                if (isSelected)
                                                                  Icon(
                                                                    Icons.check,
                                                                    color: kBlackColor,
                                                                    size: 16.sp,
                                                                  ),
                                                              ],
                                                            ),
                                                            backgroundColor: isSelected ? kPrimaryColor.withOpacity(0.7) : kPrimaryColor,
                                                          ),
                                                        ),
                                                      );
                                                    },
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                );
                              },
                              child: Container(
                                padding: EdgeInsets.symmetric(vertical: 5.h, horizontal: 10.w),
                                decoration: BoxDecoration(
                                  color: kPrimaryColor,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Obx(() => Text(
                                      controller.userPassions.isEmpty ? 'Add' : 'Edit',
                                      style: AppStyles.labelTextStyle().copyWith(
                                        color: kBlackColor,
                                        fontSize: 16.sp,
                                      ),
                                    )),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 20.h),
                        SizedBox(
                          width: Get.width,
                          child: Obx(
                            () => controller.isPassionLoading.value
                                ? Center(
                                    child: SizedBox(height: 40.h, width: 40.w, child: const CircularProgressIndicator()),
                                  )
                                : Wrap(
                                    spacing: 2.w,
                                    alignment: WrapAlignment.center,
                                    runAlignment: WrapAlignment.center,
                                    children: controller.userPassions.isEmpty
                                        ? [
                                            Text(
                                              'No passions selected',
                                              style: AppStyles.labelTextStyle().copyWith(color: kWhiteColor, fontSize: 16.sp),
                                            )
                                          ]
                                        : List.generate(
                                            controller.userPassions.length,
                                            (index) => Padding(
                                              padding: const EdgeInsets.only(
                                                bottom: 5,
                                              ),
                                              child: SizedBox(
                                                height: 50.h,
                                                child: Stack(
                                                  children: [
                                                    Chip(
                                                      label: Text(
                                                        controller.userPassions[index].title ?? '',
                                                        style: AppStyles.labelTextStyle().copyWith(
                                                          color: kBlackColor,
                                                          fontSize: 16.sp,
                                                        ),
                                                      ),
                                                      backgroundColor: kPrimaryColor,
                                                    ),
                                                    Positioned(
                                                      top: -3,
                                                      right: -3,
                                                      child: GestureDetector(
                                                        onTap: () {
                                                          controller.removePassion(index);
                                                        },
                                                        child: Container(
                                                          child: Icon(
                                                            Icons.close_sharp,
                                                            size: 18,
                                                            color: kYouTubeTileColor,
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ),
                                  ),
                          ),
                        ),
                        const Divider(color: kPrimaryColor),
                        //Removed Favourites as suggested by DAVE
                        /*SizedBox(height: 25.h),
                        Text(
                          'Your Favorite ',
                          style: AppStyles.labelTextStyle().copyWith(
                            color: kWhiteColor,
                            fontSize: 16.sp,
                            fontFamily: 'Norwester',
                            height: 0.08,
                          ),
                        ),
                        SizedBox(height: 25.h),
                        Text(
                          'pick up to 6 clips or photos that are your favorite \nand highlight a key moment in your life',
                          style: AppStyles.labelTextStyle().copyWith(
                            color: kWhiteColor.withOpacity(0.4),
                            fontSize: 15.sp,
                          ),
                        ),*/
                      ],
                    ),
                  ],
                ),
              ),
              //Removed Favourites as suggested by DAVE
              /*Obx(
                () => controller.isAddingFav.value
                    ? SliverToBoxAdapter(
                        child: SizedBox(
                          width: Get.width,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: const [
                              CustomImageShimmer(),
                              CustomImageShimmer(),
                            ],
                          ),
                        ),
                      )
                    : controller.isFavLoading.value
                        ? SliverToBoxAdapter(
                            child: SizedBox(
                              width: Get.width,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                children: const [
                                  CustomImageShimmer(),
                                  CustomImageShimmer(),
                                ],
                              ),
                            ),
                          )
                        : SliverGrid(
                            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              childAspectRatio: (itemWidth / itemHeight),
                              crossAxisSpacing: 10.0,
                              mainAxisSpacing: 10.0,
                            ),
                            delegate: SliverChildBuilderDelegate(
                              (context, index) {
                                if (index == 0) {
                                  return GestureDetector(
                                    onTap: () async {
                                      await showModalBottomSheet(
                                        context: context,
                                        isScrollControlled: true,
                                        builder: (BuildContext context) {
                                          return Container(
                                            height: 150.h,
                                            decoration: const BoxDecoration(
                                                color: kGreyContainerColor,
                                                borderRadius: BorderRadius.only(
                                                  topLeft: Radius.circular(20),
                                                  topRight: Radius.circular(20),
                                                )),
                                            child: Column(
                                              children: [
                                                ListTile(
                                                  leading: const Icon(
                                                    Icons.camera_alt,
                                                    color: kPrimaryColor,
                                                  ),
                                                  title: const Text(
                                                    'Record Video',
                                                    style: TextStyle(color: kWhiteColor),
                                                  ),
                                                  onTap: () async {
                                                    Get.back();

                                                    controller.clearUploadedData();

                                                    await controller.initializeCameras().then((c) {
                                                      isPotraitShowPopup();
                                                    });
                                                  },
                                                ),
                                                ListTile(
                                                  leading: const Icon(
                                                    Icons.image,
                                                    color: kPrimaryColor,
                                                  ),
                                                  title: const Text('Pick from Gallery', style: TextStyle(color: kWhiteColor)),
                                                  onTap: () async {
                                                    await CommonServices().videoPicker().then((value) {
                                                      if (value != null) {
                                                        controller.addFav(
                                                          Reel(
                                                              visibility: [],
                                                              id: "${DateTime.now()}",
                                                              userId: SessionService().user?.id ?? '',
                                                              caption: "Fav",
                                                              video: "",
                                                              thumbnail: "",
                                                              date: DateTime.now(),
                                                              version: 1),
                                                          videoPath: value,
                                                        );
                                                      }
                                                    });
                                                    Get.back();
                                                  },
                                                ),
                                              ],
                                            ),
                                          );

                                          // FractionallySizedBox(
                                          //   heightFactor: 0.5,
                                          //   child: EditFavoritePost(
                                          //       controller: controller),
                                          // );
                                        },
                                      );
                                    },
                                    child: DottedBorder(
                                      dashPattern: const [8, 8],
                                      borderType: BorderType.RRect,
                                      radius: const Radius.circular(30),
                                      strokeCap: StrokeCap.butt,
                                      color: kPrimaryColor,
                                      strokeWidth: 1.5,
                                      child: Container(
                                        width: double.infinity,
                                        height: 200,
                                        clipBehavior: Clip.antiAlias,
                                        decoration: ShapeDecoration(
                                          shape: RoundedRectangleBorder(
                                            side: const BorderSide(width: 1),
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                        ),
                                        child: Column(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            Center(
                                              child: Icon(
                                                Icons.add,
                                                color: kPrimaryColor,
                                                size: 40.sp,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  );
                                } else {
                                  printLogs('index: ${controller.favPosts.length}');
                                  final imagePath = controller.favPosts[index - 1].thumbnail;
                                  final id = controller.favPosts[index - 1].id;
                                  return Stack(
                                    children: [
                                      Container(
                                        width: 207.w,
                                        height: 225.h,
                                        clipBehavior: Clip.antiAlias,
                                        decoration: ShapeDecoration(
                                          image: DecorationImage(
                                            image: NetworkImage(imagePath),
                                            fit: BoxFit.fill,
                                          ),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                        ),
                                      ),
                                      Positioned(
                                        top: 8,
                                        right: 8,
                                        child: GestureDetector(
                                          onTap: () {
                                            showModalBottomSheet(
                                              context: context,
                                              builder: (BuildContext context) {
                                                return Container(
                                                  /// confirm delete tiles
                                                  height: 180.h,
                                                  decoration: const BoxDecoration(
                                                      color: kGreyContainerColor,
                                                      borderRadius: BorderRadius.only(
                                                        topLeft: Radius.circular(20),
                                                        topRight: Radius.circular(20),
                                                      )),
                                                  child: Column(
                                                    children: [
                                                      SizedBox(height: 20.h),
                                                      Text(
                                                        'Are you sure you want to delete this?',
                                                        style: AppStyles.labelTextStyle().copyWith(
                                                          color: kWhiteColor,
                                                          fontSize: 16.sp,
                                                        ),
                                                      ),
                                                      ListTile(
                                                        leading: const Icon(
                                                          Icons.delete,
                                                          color: kYouTubeTileColor,
                                                        ),
                                                        title: const Text(
                                                          'Yes Delete',
                                                          style: TextStyle(color: kWhiteColor),
                                                        ),
                                                        onTap: () {
                                                          Get.back();
                                                          controller.deleteFav(id);
                                                        },
                                                      ),
                                                      SizedBox(height: 10.h),
                                                      ListTile(
                                                        leading: const Icon(
                                                          Icons.close,
                                                          color: kPrimaryColor,
                                                        ),
                                                        title: const Text(
                                                          'Cancel',
                                                          style: TextStyle(color: kWhiteColor),
                                                        ),
                                                        onTap: () {
                                                          Get.back();
                                                        },
                                                      ),
                                                    ],
                                                  ),
                                                );
                                              },
                                            );
                                          },
                                          child: Container(
                                            width: 25.w,
                                            height: 25.h,
                                            decoration: BoxDecoration(
                                              color: Colors.black.withOpacity(0.5),
                                              shape: BoxShape.circle,
                                            ),
                                            child: Icon(
                                              Icons.delete,
                                              color: kYouTubeTileColor.withOpacity(0.8),
                                              size: 18.sp,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  );
                                }
                              },
                              childCount: controller.favPosts.isNotEmpty ? controller.favPosts.length + 1 : 1,
                            ),
                          ),
              ),*/
            ],
          ),
          bottomNavigationBar: Container(
            margin: EdgeInsets.symmetric(vertical: Platform.isIOS ? 30 : 10.h, horizontal: 24.w),
            // padding: const EdgeInsets.only(left: 16.0, right: 16.0, bottom: 10),
            child: CustomButton(
              width: Get.width,
              height: 40.h,
              title: 'Update Profile',
              onPressed: () async {
                await controller.updateProfile();
              },
            ),
          ),
        ),
      ),
    );
  }

  void isPotraitShowPopup() async {
    Get.dialog(
      barrierColor: kBlackColor.withOpacity(0.5),
      AlertDialog(
        backgroundColor: kBlackColor.withOpacity(0.8),
        content: SizedBox(
          width: 300.w,
          height: 130.h,
          child: Column(
            children: [
              Image.asset(
                kAppLogo,
                height: 100,
                width: 100,
              ),
              Text(
                'Which orientation do you want to record in?',
                style: AppStyles.labelTextStyle(),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            child: const Text('Portrait'),
            onPressed: () async {
              Get.back();
              controller.isPortrait.value = true;
              controller.isLandScape.value = false;
              await controller.cameraController.value!.unlockCaptureOrientation();
              controller.cameraController.value!.lockCaptureOrientation(DeviceOrientation.portraitUp);
              controller.isPotraitDialogShown.value = false;
              // await controller.initializeCameras();
              // Get.to(() => EditFavoritePost(controller: controller));
              await showModalBottomSheet(
                  context: Get.context!,
                  isDismissible: false,
                  isScrollControlled: true,
                  backgroundColor: kBackgroundColor,
                  builder: (context) {
                    return FractionallySizedBox(
                      heightFactor: 0.9,
                      child: EditFavoritePost(
                        controller: controller,
                      ),
                    );
                  }).then((value) {
                controller.isPortrait.value = false;
                controller.isLandScape.value = false;
                controller.cameraController.value!.unlockCaptureOrientation();
                controller.resetRecording();
                controller.clearUploadedData();
              });
            },
          ),
          TextButton(
            child: const Text('Landscape'),
            onPressed: () async {
              Get.back();
              controller.isPortrait.value = false;
              controller.isLandScape.value = true;
              await controller.cameraController.value!.unlockCaptureOrientation();
              controller.cameraController.value!.lockCaptureOrientation(DeviceOrientation.landscapeLeft);
              controller.isPotraitDialogShown.value = false;
              // Get.to(() => EditFavoritePost(controller: controller));
              // await controller.initializeCameras();
              await showModalBottomSheet(
                  context: Get.context!,
                  isDismissible: false,
                  isScrollControlled: true,
                  backgroundColor: kBackgroundColor,
                  builder: (context) {
                    return FractionallySizedBox(
                      heightFactor: 0.9,
                      child: EditFavoritePost(
                        controller: controller,
                      ),
                    );
                  }).then((value) {
                controller.isPortrait.value = false;
                controller.isLandScape.value = false;
                controller.cameraController.value!.unlockCaptureOrientation();
                controller.resetRecording();
                controller.clearUploadedData();
              });
            },
          ),
        ],
      ),
    );
  }
}
