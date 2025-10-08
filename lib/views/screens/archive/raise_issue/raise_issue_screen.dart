import 'dart:io';

import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:socials_app/utils/app_colors.dart';
import 'package:socials_app/utils/app_styles.dart';
import 'package:socials_app/views/custom_widgets/custom_button.dart';
import 'package:socials_app/views/custom_widgets/custom_scaffold.dart';
import 'package:socials_app/views/screens/archive/raise_issue/controller/raise_issue_controller.dart';

import '../../../../utils/app_images.dart';
import '../../../../utils/common_code.dart';

class RaiseIssueScreen extends GetView<RaiseIssueController> {
  const RaiseIssueScreen({super.key});

  @override
  Widget build(BuildContext context) {
    Future.microtask(() {
      controller.getPostReportingIssuesList();
    });
    return Obx(
      () => ModalProgressHUD(
        inAsyncCall: controller.isLoading.value,
        child: CustomScaffold(
          className: runtimeType.toString(),
          screenName: "Raise An Issue",
          isBackIcon: true,
          isFullBody: false,
          leadingWidth: 30,
          appBarSize: 40,
          backIconColor: kPrimaryColor,
          showAppBarBackButton: true,
          scaffoldKey: controller.scaffoldKey,
          onNotificationListener: (notificationInfo) {
            if (notificationInfo.runtimeType == UserScrollNotification) {
              CommonCode().removeTextFieldFocus();
            }
            return false;
          },
          gestureDetectorOnTap: CommonCode().removeTextFieldFocus,
          body: Padding(
            padding: EdgeInsets.only(
              top: 55.h,
            ),
            child: SingleChildScrollView(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                /* SizedBox(
                  height: 10.h,
                ),
                Obx(
                  () => Container(
                    width: 289.w,
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1B1B1B),
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        dropdownColor: Colors.black,
                        hint: Text(
                          '',
                          style: AppStyles.labelTextStyle().copyWith(color: kHintGreyColor),
                        ),
                        value: controller.selectedValue.value,
                        icon: Image.asset(
                          kDropDown,
                          scale: 5,
                        ),
                        isExpanded: true,
                        style: AppStyles.labelTextStyle().copyWith(
                          color: kHintGreyColor,
                          fontSize: 16.sp,
                        ),
                        onChanged: (String? newValue) {
                          if (newValue != null) {
                            if (newValue == 'Bank Transfer') {
                              controller.isPaymentMethodSelected.value = true;
                              controller.selectedValue.value = newValue;
                            } else {
                              // ignore: avoid_print
                              printLogs('else');
                              CustomSnackbar.showSnackbar("Feature Coming Soon");
                            }
                          }
                        },
                        items: controller.dropdownItems.map<DropdownMenuItem<String>>((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                ),*/
                Text(
                  'Issue Reason',
                  style: AppStyles.labelTextStyle().copyWith(
                    color: kWhiteColor,
                    fontWeight: FontWeight.w700,
                    height: 0,
                    letterSpacing: 0.28,
                  ),
                ),
                SizedBox(
                  height: 12.h,
                ),
                Obx(
                  () => Container(
                    width: Get.width,
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1B1B1B),
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        dropdownColor: Colors.black,
                        hint: Text(
                          '',
                          style: AppStyles.labelTextStyle().copyWith(color: kHintGreyColor),
                        ),
                        value: controller.selectedReason.value,
                        icon: Image.asset(
                          kDropDown,
                          scale: 5,
                        ),
                        isExpanded: true,
                        style: AppStyles.labelTextStyle().copyWith(
                          color: kPrimaryColor,
                          fontSize: 16.sp,
                        ),
                        onChanged: controller.onReasonDropDownChange,
                        items: controller.reportingReasons.value.map<DropdownMenuItem<String>>((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                ),

                Obx(() => controller.isReasonError.isTrue
                    ? Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SizedBox(
                            height: 12.h,
                          ),
                          Text(
                            'Please select a reason',
                            style: AppStyles.labelTextStyle().copyWith(color: kYouTubeTileColor, fontWeight: FontWeight.w400, fontSize: 12),
                          ),
                        ],
                      )
                    : SizedBox.shrink()),
                SizedBox(
                  height: 25.h,
                ),
                Text(
                  'Description',
                  style: AppStyles.labelTextStyle().copyWith(
                    color: kWhiteColor,
                    fontWeight: FontWeight.w700,
                    height: 0,
                    letterSpacing: 0.28,
                  ),
                ),
                SizedBox(
                  height: 12.h,
                ),
                Container(
                  width: Get.width,
                  decoration: ShapeDecoration(
                    color: kGreyContainerColor,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  child: TextField(
                    focusNode: controller.fnDescription,
                    textAlign: TextAlign.start,
                    maxLength: 500,
                    minLines: 6,
                    maxLines: 10,
                    textCapitalization: TextCapitalization.sentences,
                    enableSuggestions: true,
                    controller: controller.descriptionController,
                    keyboardType: TextInputType.multiline,
                    textInputAction: TextInputAction.newline,
                    decoration: InputDecoration(
                      hintText: 'Description here',
                      counterText: "",
                      focusColor: kPrimaryColor,
                      border: InputBorder.none,
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.0),
                        borderSide: const BorderSide(
                          color: kPrimaryColor,
                          width: 1.5,
                        ),
                      ),
                      contentPadding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
                    ),
                    onChanged: (text) {
                      if (text.isNotEmpty && text.length >= 15) {
                        controller.isDescriptionError.value = false;
                      }
                    },
                    style: const TextStyle(color: kPrimaryColor),
                  ),
                ),
                Obx(() => controller.isDescriptionError.isTrue
                    ? Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SizedBox(
                            height: 12.h,
                          ),
                          Text(
                            controller.descriptionController.text.isNotEmpty && controller.descriptionController.text.length < 15
                                ? 'Description must be at least 15 characters long'
                                : 'Please enter a description',
                            style: AppStyles.labelTextStyle().copyWith(color: kYouTubeTileColor, fontWeight: FontWeight.w400, fontSize: 12),
                          ),
                        ],
                      )
                    : SizedBox.shrink()),
                SizedBox(
                  height: 24.h,
                ),
                // Screenshot Section
                Obx(
                  () => controller.issueImagesList.isEmpty ? _buildEmptyScreenshotSection() : _buildImagesSection(),
                ),
                SizedBox(
                  height: 30.h,
                ),
              ]),
            ),
          ),
          bottomNavigationBar: Container(
            margin: EdgeInsets.symmetric(vertical: Platform.isIOS ? 30 : 10.h, horizontal: 24.w),
            // padding: const EdgeInsets.all(18.0),
            child: CustomButton(
                width: Get.width,
                height: 40.h,
                title: 'Submit',
                onPressed: () {
                  controller.submitClipIssue();
                },
                backgroundColor:
                    // controller.isPaymentMethodSelected.value == true
                    //     ?
                    kPrimaryColor
                // : kPrimaryColor.withOpacity(0.5),
                ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyScreenshotSection() {
    return GestureDetector(
      onTap: () => controller.pickImage(),
      child: Container(
        width: Get.width,
        height: 200.h,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
        ),
        child: DottedBorder(
          options: RoundedRectDottedBorderOptions(
            color: kPrimaryColor,
            dashPattern: const <double>[9, 6],
            radius: const Radius.circular(12),
            padding: const EdgeInsets.all(6),
          ),
          child: Container(
            width: double.infinity,
            height: double.infinity,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.add,
                  color: kPrimaryColor,
                  size: 48,
                ),
                SizedBox(height: 8.h),
                Text(
                  'Optional Screenshot/Proof upload',
                  style: AppStyles.labelTextStyle().copyWith(
                    color: kPrimaryColor,
                    fontSize: 14,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildImagesSection() {
    // Create a list that includes the "add more" button at index 0 and then images
    List<Widget> gridItems = [];

    // Add "add more" button at index 0 if haven't reached max limit
    if (controller.issueImagesList.length < 10) {
      gridItems.add(_buildAddMoreButton());
    }

    // Add all images after the add more button
    for (int i = 0; i < controller.issueImagesList.length; i++) {
      gridItems.add(_buildImageItem(i));
    }

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 8.w,
        mainAxisSpacing: 8.h,
        childAspectRatio: 1,
      ),
      itemCount: gridItems.length,
      itemBuilder: (context, index) {
        return gridItems[index];
      },
    );
  }

  Widget _buildImageItem(int imageIndex) {
    return Stack(
      children: [
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            image: DecorationImage(
              image: FileImage(File(controller.issueImagesList[imageIndex])),
              fit: BoxFit.cover,
            ),
          ),
        ),
        Positioned(
          top: 4,
          right: 4,
          child: GestureDetector(
            onTap: () => controller.removeImage(imageIndex),
            child: Container(
              width: 20.w,
              height: 20.h,
              decoration: const BoxDecoration(
                color: kPrimaryColor,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.close,
                color: Colors.black,
                size: 14.sp,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAddMoreButton() {
    return GestureDetector(
      onTap: () => controller.pickImage(),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
        ),
        child: DottedBorder(
          options: RoundedRectDottedBorderOptions(
            dashPattern: const <double>[9, 6],
            color: kPrimaryColor,
            radius: const Radius.circular(8),
            padding: const EdgeInsets.all(6),
          ),
          child: Container(
            width: double.infinity,
            height: double.infinity,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.add,
                  color: kPrimaryColor,
                  size: 36,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Widget _buildImagesSection() {
  //   return Column(
  //     children: [
  //       // Images Grid
  //       GridView.builder(
  //         shrinkWrap: true,
  //         physics: const NeverScrollableScrollPhysics(),
  //         gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
  //           crossAxisCount: 3,
  //           crossAxisSpacing: 8.w,
  //           mainAxisSpacing: 8.h,
  //           childAspectRatio: 1,
  //         ),
  //         itemCount: controller.issueImagesList.length,
  //         itemBuilder: (context, index) {
  //           return Stack(
  //             children: [
  //               Container(
  //                 decoration: BoxDecoration(
  //                   borderRadius: BorderRadius.circular(8),
  //                   image: DecorationImage(
  //                     image: FileImage(File(controller.issueImagesList[index])),
  //                     fit: BoxFit.cover,
  //                   ),
  //                 ),
  //               ),
  //               Positioned(
  //                 top: 4,
  //                 right: 4,
  //                 child: GestureDetector(
  //                   onTap: () => controller.removeImage(index),
  //                   child: Container(
  //                     width: 20.w,
  //                     height: 20.h,
  //                     decoration: const BoxDecoration(
  //                       color: kPrimaryColor,
  //                       shape: BoxShape.circle,
  //                     ),
  //                     child: Icon(
  //                       Icons.close,
  //                       color: Colors.black,
  //                       size: 14.sp,
  //                     ),
  //                   ),
  //                 ),
  //               ),
  //             ],
  //           );
  //         },
  //       ),
  //
  //       SizedBox(height: 16.h),
  //
  //       // Add more images section (if less than max limit)
  //       // if (controller.issueImagesList.length < 5) // Assuming max 5 images
  //       GestureDetector(
  //         onTap: () => controller.pickImage(),
  //         child: Container(
  //           width: Get.width,
  //           height: 80.h,
  //           decoration: BoxDecoration(
  //             borderRadius: BorderRadius.circular(8),
  //           ),
  //           child: DottedBorder(
  //             options: RoundedRectDottedBorderOptions(
  //               dashPattern: const <double>[9, 6],
  //               color: kPrimaryColor,
  //               radius: const Radius.circular(12),
  //               padding: const EdgeInsets.all(6),
  //             ),
  //             child: Container(
  //               width: double.infinity,
  //               height: double.infinity,
  //               child: Row(
  //                 mainAxisAlignment: MainAxisAlignment.center,
  //                 children: [
  //                   Icon(
  //                     Icons.add,
  //                     color: kPrimaryColor,
  //                     size: 24.sp,
  //                   ),
  //                 ],
  //               ),
  //             ),
  //           ),
  //         ),
  //       ),
  //     ],
  //   );
  // }
}
