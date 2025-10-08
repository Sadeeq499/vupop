import 'dart:developer';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:socials_app/repositories/auth_repo.dart';
import 'package:socials_app/views/custom_widgets/custom_button.dart';
import 'package:socials_app/views/custom_widgets/custom_textfield.dart';

import '../../../services/custom_snackbar.dart';
import '../../../utils/app_colors.dart';
import '../../../utils/app_images.dart';
import '../../../utils/app_styles.dart';
import '../../../utils/common_code.dart';
import '../../custom_widgets/custom_scaffold.dart';
import 'controller/auth_controller.dart';

class SignInScreen extends GetView<AuthController> {
  const SignInScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => ModalProgressHUD(
        inAsyncCall: controller.isFullLoading.value,
        child: CustomScaffold(
          className: runtimeType.toString(),
          screenName: "",
          isBackIcon: false,
          isFullBody: false,
          appBarSize: 0,
          showAppBarBackButton: false,
          scaffoldKey: controller.scaffoldKey,
          onNotificationListener: (notificationInfo) {
            if (notificationInfo.runtimeType == UserScrollNotification) {
              CommonCode().removeTextFieldFocus();
            }
            return false;
          },
          gestureDetectorOnTap: CommonCode().removeTextFieldFocus,
          body: SingleChildScrollView(
            child: Form(
              key: controller.loginFormKey,
              child: Padding(
                padding: EdgeInsets.only(left: 5.w),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      height: 60.h,
                    ),
                    Center(
                      child: Image.asset(
                        kLogoSignup,
                        width: 276.w,
                        height: 115.h,
                      ),
                    ),
                    SizedBox(
                      height: 60.h,
                    ),
                    Text(
                      'Email',
                      style: AppStyles.labelTextStyle().copyWith(fontWeight: FontWeight.w700),
                    ),
                    SizedBox(
                      height: 11.h,
                    ),
                    CustomTextField(
                      isPassword: false,
                      hint: "Type your email",
                      controller: controller.tecEmail,
                      textInputAction: TextInputAction.done,
                      onChanged: (value) {
                        log("check: $value");
                        final result = CommonCode.isValidEmail(value);
                        controller.isVaildEmail.value = result;
                        controller.showOtherFields.value = false;
                        controller.isUserExist.value = false;
                        return null;
                      },
                    ),
                    Obx(() => controller.showOtherFields.isTrue
                        ? Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(
                                height: 20.h,
                              ),
                              Text(
                                'Username',
                                style: AppStyles.labelTextStyle().copyWith(fontWeight: FontWeight.w700),
                              ),
                              SizedBox(
                                height: 11.h,
                              ),
                              CustomTextField(
                                isPassword: false,
                                hint: "abc",
                                controller: controller.tecUserName,
                              ),
                              SizedBox(
                                height: 20.h,
                              ),
                              Text(
                                'Password',
                                style: AppStyles.labelTextStyle().copyWith(fontWeight: FontWeight.w700),
                              ),
                              SizedBox(
                                height: 11.h,
                              ),
                              Obx(
                                () => CustomTextField(
                                  hint: 'Type your password',
                                  width: 390.w,
                                  suffixIcon: controller.isHidePassword.isTrue ? Icons.visibility_off_outlined : Icons.visibility,
                                  controller: controller.tecPassword,
                                  isPassword: true,
                                  textInputAction: TextInputAction.done,
                                ),
                              ),
                            ],
                          )
                        : Container()),
                    SizedBox(height: 11.h),
                    Obx(() => Visibility(
                        visible: controller.isUserExist.value && controller.showOtherFields.isFalse,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Password',
                              style: AppStyles.labelTextStyle().copyWith(fontWeight: FontWeight.w700),
                            ),
                            SizedBox(
                              height: 11.h,
                            ),
                            Obx(
                              () => CustomTextField(
                                hint: 'Type your password',
                                width: 390.w,
                                suffixIcon: controller.isHidePassword.isTrue ? Icons.visibility_off_outlined : Icons.visibility,
                                controller: controller.tecPassword,
                                isPassword: true,
                                textInputAction: TextInputAction.done,
                              ),
                            ),
                          ],
                        ))),
                    SizedBox(
                      height: 30.h,
                    ),
                    Center(
                      child: RichText(
                        textAlign: TextAlign.center,
                        text: TextSpan(
                          //text: 'By using our services you are agreeing to our\n',
                          style: AppStyles.labelTextStyle().copyWith(color: kWhiteColor, fontSize: 13.sp),
                          children: [
                            WidgetSpan(
                              alignment: PlaceholderAlignment.middle,
                              child: Obx(
                                () => Checkbox(
                                  side: BorderSide(width: 2, color: kPrimaryColor),
                                  checkColor: Colors.black,
                                  activeColor: kPrimaryColor,
                                  value: controller.termAndConditionAccepted.isTrue,
                                  onChanged: (value) {
                                    controller.termAndConditionAccepted.value = value ?? false;
                                  },
                                ),
                              ),
                            ),
                            TextSpan(
                              text: 'By using our services you are agreeing to our\n',
                              style: AppStyles.labelTextStyle().copyWith(color: kWhiteColor, fontSize: 13.sp),
                            ),
                            TextSpan(
                                text: 'Terms',
                                style: AppStyles.labelTextStyle().copyWith(fontSize: 13.sp, fontWeight: FontWeight.w600, color: kPrimaryColor),
                                recognizer: TapGestureRecognizer()
                                  ..onTap = () {
                                    controller.launchTermsAndPrivacyUrl();
                                  }),
                            TextSpan(
                              text: ' and ',
                              style: AppStyles.labelTextStyle().copyWith(color: kWhiteColor, fontSize: 13.sp),
                            ),
                            TextSpan(
                              recognizer: TapGestureRecognizer()
                                ..onTap = () {
                                  controller.launchTermsAndPrivacyUrl();
                                },
                              text: 'Privacy Policy ',
                              style: AppStyles.labelTextStyle().copyWith(fontSize: 13.sp, fontWeight: FontWeight.w600, color: kPrimaryColor),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 20.h,
                    ),
                    Obx(
                      () => CustomButton(
                        width: 385.w,
                        height: 55.h,
                        backgroundColor: controller.isVaildEmail.value ? kPrimaryColor : kPrimaryColor.withOpacity(0.3),
                        title: controller.isUserExist.isTrue
                            ? "Sign In"
                            : controller.showOtherFields.isTrue
                                ? "Sign Up"
                                : "Continue",
                        onPressed: controller.isVaildEmail.isFalse
                            ? null
                            : () async {
                                // closee keyboard
                                CommonCode().removeTextFieldFocus();

                                if ((controller.showOtherFields.isTrue)) {
                                  String passwordError = CommonCode.validatePassword(controller.tecPassword.text) ?? '';
                                  String usernameError = CommonCode.validateUsername(controller.tecUserName.text) ?? '';
                                  controller.isFullLoading.value = false;

                                  if (usernameError.isNotEmpty) {
                                    CustomSnackbar.showSnackbar(usernameError);
                                  }
                                  if (passwordError.isNotEmpty) {
                                    CustomSnackbar.showSnackbar(passwordError);
                                  }
                                  if (usernameError.isNotEmpty || passwordError.isNotEmpty) {
                                    return;
                                  }
                                }
                                controller.isFullLoading.value = true;
                                final userExist = await AuthRepo().checkUserExist(email: controller.tecEmail.text.trim());

                                if (userExist) {
                                  controller.isUserExist.value = true;
                                  if (controller.tecPassword.text.isNotEmpty) {
                                    controller.loginUser();
                                  } else {
                                    controller.isFullLoading.value = false;
                                  }
                                } else {
                                  if (controller.showOtherFields.isFalse) {
                                    if (CommonCode.isValidEmail(controller.tecEmail.text.trim())) {
                                      controller.showOtherFields.value = true;
                                    }
                                    controller.isFullLoading.value = false;
                                  } else {
                                    String passwordError = CommonCode.validatePassword(controller.tecPassword.text) ?? '';
                                    String usernameError = CommonCode.validateUsername(controller.tecUserName.text) ?? '';
                                    if (passwordError.isEmpty && usernameError.isEmpty) {
                                      if (controller.isAllFieldFilled.isTrue) {
                                        if (controller.termAndConditionAccepted.isTrue) {
                                          controller.registerUser();
                                        } else {
                                          controller.isFullLoading.value = false;
                                          CustomSnackbar.showSnackbar('Please accept terms and conditions.');
                                        }
                                      }
                                    } else {
                                      controller.isFullLoading.value = false;
                                      if (passwordError.isNotEmpty) {
                                        CustomSnackbar.showSnackbar(passwordError);
                                      }
                                      if (usernameError.isNotEmpty) {
                                        CustomSnackbar.showSnackbar(usernameError);
                                      }
                                    }
                                  }
                                }
                              },
                      ),
                    ),
                    SizedBox(
                      height: 45.h,
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: Get.width * 0.05),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Expanded(
                            child: Divider(
                              thickness: 1,
                              color: kWhiteColor,
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: Get.width * 0.05),
                            child: Text(
                              'Or use',
                              style: AppStyles.labelTextStyle().copyWith(fontWeight: FontWeight.w400, color: kWhiteColor, fontSize: 14.sp),
                            ),
                          ),
                          const Expanded(
                            child: Divider(
                              thickness: 1,
                              color: kWhiteColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      height: Get.height * 0.02,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        GestureDetector(
                          onTap: () async {
                            controller.isLoading3.value = true;
                            await controller.signInWithApple(context);
                          },
                          child: Material(
                            elevation: 4,
                            color: kWhiteColor,
                            borderRadius: BorderRadius.circular(8.r),
                            child: Container(
                              width: 86.w,
                              height: 48.h,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8.r),
                                border: Border.all(
                                  color: kWhiteColor,
                                  width: 2,
                                ),
                              ),
                              child: Obx(
                                () => Center(
                                  child: controller.isLoading3.isTrue
                                      ? SizedBox(
                                          width: 24.w,
                                          height: 24.h,
                                          child: const CircularProgressIndicator(
                                            color: kBlackColor,
                                            strokeWidth: 2.0,
                                          ),
                                        )
                                      : Image.asset(
                                          kAppleIcon,
                                          width: 30.w,
                                          height: 30.h,
                                        ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        GestureDetector(
                          onTap: () async {
                            controller.isLoading1.value = true;
                            controller.signInWithGoogle(context);
                            // showModalBottomSheet(
                            //     context: context,
                            //     builder: (context) {
                            //       return InAppWebView(
                            //         initialUrlRequest: URLRequest(
                            //             url: WebUri(kAuthenticateGoogle)),
                            //         initialOptions: InAppWebViewGroupOptions(
                            //           crossPlatform: InAppWebViewOptions(
                            //             // debuggingEnabled: true,
                            //             javaScriptEnabled: true,
                            //           ),
                            //         ),
                            //         onWebViewCreated: (controller) {
                            //           controller.clearCache();
                            //         },
                            //         onLoadStart: (controller, url) {
                            //           log('URL: $url');
                            //         },
                            //         onLoadStop: (controller, url) {
                            //           log('URL: $url');
                            //           // if (url.toString().contains('google')) {
                            //           //   controller.stopLoading();
                            //           //   Navigator.pop(context);
                            //           // }
                            //         },
                            //       );
                            //     });
                          },
                          child: Material(
                            elevation: 4,
                            color: kWhiteColor,
                            borderRadius: BorderRadius.circular(8.r),
                            child: Container(
                              width: 86.w,
                              height: 48.h,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8.r),
                                border: Border.all(
                                  color: kWhiteColor,
                                  width: 2,
                                ),
                              ),
                              child: Obx(
                                () => Center(
                                  child: controller.isLoading1.isTrue
                                      ? SizedBox(
                                          width: 24.w,
                                          height: 24.h,
                                          child: const CircularProgressIndicator(
                                            color: kBlackColor,
                                            strokeWidth: 2.0,
                                          ),
                                        )
                                      : Image.asset(
                                          kGoogleIcon,
                                          width: 20.w,
                                          height: 20.h,
                                        ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            controller.signInWithFacebook();
                          },
                          child: Material(
                            elevation: 4,
                            color: kWhiteColor,
                            borderRadius: BorderRadius.circular(8.r),
                            child: Container(
                              width: 86.w,
                              height: 48.h,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8.r),
                                border: Border.all(
                                  color: kWhiteColor,
                                  width: 2,
                                ),
                              ),
                              child: Center(
                                child: Image.asset(
                                  kMetaIcon,
                                  width: 30.w,
                                  height: 30.h,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 20,
                    )
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
