import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:socials_app/utils/app_colors.dart';
import 'package:socials_app/views/custom_widgets/custom_button.dart';
import 'package:socials_app/views/custom_widgets/custom_scaffold.dart';
import 'package:socials_app/views/screens/request_payment/widget/video_details_widget.dart';

import '../../../../services/session_services.dart';
import '../../../../utils/app_styles.dart';
import '../../../custom_widgets/custom_app_dialogs.dart';
import '../controller/request_payment_controller.dart';

class RequestPaymentScreen extends GetView<RequestPaymentController> {
  const RequestPaymentScreen({super.key});

  @override
  Widget build(BuildContext context) {
    Future.microtask(() {
      controller.getWalletBalance();
    });
    return Obx(
      () => ModalProgressHUD(
        inAsyncCall: controller.isLoading.value,
        child: CustomScaffold(
          className: 'Request Withdrawal',
          screenName: "Request Withdrawal",
          scaffoldKey: controller.requestPaymentKey,
          isFullBody: false,
          leadingWidth: 30,
          isBackIcon: true,
          backIconColor: kPrimaryColor,
          body: Padding(
            padding: EdgeInsets.only(top: 55.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Text(
                    '£${controller.walletPaymentData.value?.readyToWithdrawAmount != null ? controller.walletPaymentData.value!.readyToWithdrawAmount?.toStringAsFixed(2) : "0"}',
                    // '£${controller.canSendRequest.isTrue ? controller.walletData.value!.exportss![0].totalAmount?.toStringAsFixed(2) : "0"}',
                    style: AppStyles.labelTextStyle().copyWith(
                      color: kPrimaryColor,
                      fontSize: 48.sp,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.20,
                    ),
                  ),
                ),
                SizedBox(
                  height: 20.h,
                ),
                Center(
                  child: Text.rich(
                    TextSpan(
                      children: [
                        /*TextSpan(
                          text: 'estimated ',
                          style: AppStyles.labelTextStyle().copyWith(
                            color: kWhiteColor,
                            fontSize: 16.sp,
                            height: 0.08,
                            letterSpacing: 0.20,
                          ),
                        ),*/
                        TextSpan(
                          text:
                              '£${controller.walletPaymentData.value?.readyToWithdrawAmount != null ? controller.walletPaymentData.value!.readyToWithdrawAmount?.toStringAsFixed(2) : "0"}',

                          // "£${controller.canSendRequest.isTrue ? controller.walletData.value?.exportss![0].totalAmount?.toStringAsFixed(2) : '0'}",
                          // '50\$',
                          style: AppStyles.labelTextStyle().copyWith(
                            color: kWhiteColor,
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.20,
                          ),
                        ),
                        /*TextSpan(
                          text: ' are due for payment,\nyou can request withdrawal once funds will be available in your wallet ',
                          style: AppStyles.labelTextStyle().copyWith(
                            color: kWhiteColor,
                            fontSize: 16.sp,
                            letterSpacing: 0.20,
                          ),
                        ),*/
                        TextSpan(
                          text: ' is available for withdrawal. Complete your request below.',
                          style: AppStyles.labelTextStyle().copyWith(
                            color: kWhiteColor,
                            fontSize: 16.sp,
                            letterSpacing: 0.20,
                          ),
                        ),
                      ],
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                SizedBox(
                  height: 50.h,
                ),
                Text(
                  'Details',
                  style: AppStyles.labelTextStyle().copyWith(
                    color: kPrimaryColor,
                    fontSize: 24.sp,
                    fontFamily: 'Norwester',
                    height: 0.03,
                  ),
                ),
                SizedBox(
                  height: 35.h,
                ),
                Obx(() {
                  return controller.isLoading.isTrue
                      ? const SizedBox.shrink()
                      : controller.exportsList.isNotEmpty
                          ? Expanded(
                              child: ListView.builder(
                                  shrinkWrap: true,
                                  itemCount: controller.isShowAll.isTrue
                                      ? controller.exportsList.length
                                      : (controller.exportsList.length > 2 ? 2 : controller.exportsList.length),
                                  itemBuilder: (context, index) {
                                    return Column(
                                      children: [
                                        Container(
                                          margin: EdgeInsets.only(top: 12),
                                          child: VideoDetailsWidget(
                                            imageUrl: controller.exportsList[index].post?.thumbnail ?? "",
                                            exporterName: controller.exportsList[index].exportedBy ?? 'N/A',
                                            duration: '${controller.exportsList[index].post?.duration?.toStringAsFixed(2)}s' ?? '0s',
                                          ),
                                        ),
                                        if ((controller.isShowAll.isTrue ? index == controller.exportsList.length - 1 : index == 1) &&
                                            controller.exportsList.length > 2)
                                          GestureDetector(
                                            onTap: () {
                                              controller.isShowAll.value = !controller.isShowAll.value;
                                            },
                                            child: Center(
                                              child: Container(
                                                width: 187.w,
                                                height: 40.h,
                                                margin: EdgeInsets.only(
                                                  top: 25.h,
                                                ),
                                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                                                decoration: ShapeDecoration(
                                                  shape: RoundedRectangleBorder(
                                                    side: const BorderSide(width: 1, color: kPrimaryColor),
                                                    borderRadius: BorderRadius.circular(4),
                                                  ),
                                                ),
                                                child: Center(
                                                  child: Text(
                                                    controller.isShowAll.isTrue ? 'Show less' : 'Show all',
                                                    style: AppStyles.labelTextStyle().copyWith(
                                                      color: kPrimaryColor,
                                                      fontSize: 16.sp,
                                                      fontWeight: FontWeight.w500,
                                                      height: 0.08,
                                                      letterSpacing: 0.20,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                      ],
                                    );
                                  }),
                            )
                          : Center(
                              child: Text(
                                "Data not Found",
                                style: AppStyles.labelTextStyle().copyWith(
                                  color: kPrimaryColor,
                                  fontSize: 18.sp,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            );
                }),
              ],
            ),
          ),
          bottomNavigationBar: Container(
            decoration: ShapeDecoration(
              color: controller.canWithdrawAmount.isTrue && controller.canSendRequest.isTrue ? kPrimaryColor : kWhiteColorTrans,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.r),
              ),
            ),
            margin: EdgeInsets.symmetric(vertical: Platform.isIOS ? 30 : 10.h, horizontal: 24.w),
            child: CustomButton(
                backgroundColor: controller.canWithdrawAmount.isTrue && controller.canSendRequest.isTrue ? kPrimaryColor : kWhiteColorTrans,
                textColor: controller.canWithdrawAmount.isFalse && controller.canSendRequest.isFalse ? kPrimaryColor : kBlackColor,
                width: Get.width,
                height: 50.h,
                title: 'Request Withdrawal',
                onPressed: controller.canWithdrawAmount.isTrue && controller.canSendRequest.isTrue
                    ? () {
                        // controller.requestPaymentToAdmin();
                        if (controller.isPaymentMethodFound.isTrue && SessionService().isEmailVerified != null && SessionService().isEmailVerified!) {
                          showWithdrawDialog(
                            onContinueBtnClick: () async {
                              Get.back();
                              // Get.toNamed(kAccountDetailsRoute);
                              controller.requestPaymentToAdmin();
                            },
                          );
                        } else {
                          bankAccountMissingDialog();
                        }
                      }
                    : null),
          ),
        ),
      ),
    );
  }
}
