import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:socials_app/utils/app_colors.dart';
import 'package:socials_app/views/custom_widgets/custom_button.dart';
import 'package:socials_app/views/custom_widgets/custom_scaffold.dart';
import 'package:socials_app/views/custom_widgets/custom_textfield.dart';

import '../../../../utils/app_styles.dart';
import '../controller/help_and_support_controller.dart';

class HelpAndSupportScreen extends GetView<HelpAndSupportController> {
  const HelpAndSupportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => ModalProgressHUD(
        inAsyncCall: controller.isLoading.value,
        child: CustomScaffold(
          className: runtimeType.toString(),
          screenName: "Help and Support",
          isBackIcon: true,
          isFullBody: false,
          appBarSize: 40,
          leadingWidth: 30,
          backIconColor: kPrimaryColor,
          showAppBarBackButton: true,
          scaffoldKey: controller.helpAndSupportKey,
          body: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  height: 30.h,
                ),
                Text(
                  "Have a question or need assistance? Reach out to us via the form below. We're here to support and want your feedback.",
                  style: AppStyles.labelTextStyle().copyWith(
                    color: kWhiteColor,
                    fontSize: 16.sp,
                  ),
                ),
                SizedBox(
                  height: 34.h,
                ),
                Text(
                  'Name',
                  style: AppStyles.labelTextStyle().copyWith(
                    color: kWhiteColor,
                    fontWeight: FontWeight.w700,
                    height: 0,
                    letterSpacing: 0.28,
                  ),
                ),
                const SizedBox(
                  height: 24,
                ),
                CustomTextField(
                  isPassword: false,
                  hint: '',
                  controller: controller.nameController,
                ),
                SizedBox(
                  height: 34.h,
                ),
                Text(
                  'Email',
                  style: AppStyles.labelTextStyle().copyWith(
                    color: kWhiteColor,
                    fontWeight: FontWeight.w700,
                    height: 0,
                    letterSpacing: 0.28,
                  ),
                ),
                const SizedBox(
                  height: 24,
                ),
                CustomTextField(
                  isPassword: false,
                  hint: "",
                  controller: controller.emailController,
                  isEdit: false,
                ),
                SizedBox(
                  height: 34.h,
                ),
                Text(
                  'Message',
                  style: AppStyles.labelTextStyle().copyWith(
                    color: kWhiteColor,
                    fontWeight: FontWeight.w700,
                    height: 0,
                    letterSpacing: 0.28,
                  ),
                ),
                SizedBox(
                  height: 24.h,
                ),
                CustomTextField(
                  contentPadding: EdgeInsets.symmetric(vertical: 13.h, horizontal: 16.w),
                  isPassword: false,
                  hint: '',
                  controller: controller.messageController,
                  minLines: 8,
                  maxLines: 9,
                ),
                const SizedBox(
                  height: 24,
                ),
              ],
            ),
          ),
          bottomNavigationBar: Container(
            margin: EdgeInsets.symmetric(vertical: Platform.isIOS ? 30 : 10.h, horizontal: 24.w),
            // padding: const EdgeInsets.all(12.0),
            child: CustomButton(
                width: Get.width,
                height: 50,
                title: 'Submit',
                onPressed: () async {
                  await controller.sendHelpSupport();
                }),
          ),
        ),
      ),
    );
  }
}
