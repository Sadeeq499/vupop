import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:socials_app/utils/common_code.dart';

import '../../../../utils/app_colors.dart';
import '../../../../utils/app_strings.dart';
import '../../../../utils/app_styles.dart';
import '../../../custom_widgets/custom_app_dialogs.dart';
import '../../../custom_widgets/custom_button.dart';
import '../controller/notification_controller.dart';

class CustomPayoutNotificationCard extends StatelessWidget {
  final NotificationsController controller;
  const CustomPayoutNotificationCard({
    super.key,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => controller.isLoadingPayoutNotifications.isTrue
          ? SizedBox.shrink()
          : controller.isEmailVerified.value
              ? SizedBox.shrink()
              : Container(
                  width: Get.width,
                  padding: EdgeInsets.symmetric(vertical: 15.h, horizontal: 15.w),
                  decoration: BoxDecoration(color: kPrimaryColor, borderRadius: BorderRadius.circular(4.r)),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'A payout is on its way',
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppStyles.appBarHeadingTextStyle().copyWith(
                          color: kBlackColor,
                          fontSize: 22.sp,
                          fontFamily: 'Norwester',
                        ),
                      ),
                      SizedBox(
                        height: 6.h,
                      ),
                      Text(
                        controller.isAccountDetailsAdded.value && controller.isEmailVerified.isFalse
                            ? 'Please verify your bank details to ensure your payment is sent to the correct account'
                            : "${controller.payoutNotification.value?.description}",
                        style: AppStyles.labelTextStyle().copyWith(
                          color: kBlackColor,
                          fontWeight: FontWeight.w600,
                          fontSize: 16.sp,
                        ),
                      ),
                      SizedBox(
                        height: 6.h,
                      ),
                      Text(
                        // "Deadline: November 23, 2025",
                        "Deadline: ${controller.payoutNotification.value != null ? CommonCode.formatDateToMonthDateYear(controller.payoutNotification.value!.date) : ''}",
                        style: AppStyles.labelTextStyle().copyWith(
                          color: kBlackColor,
                          fontWeight: FontWeight.w600,
                          fontSize: 16.sp,
                        ),
                      ),
                      SizedBox(
                        height: 6.h,
                      ),
                      Obx(
                        () => controller.isVerifyingPayout.isTrue
                            ? Container(
                                width: Get.width,
                                height: 40.h,
                                decoration: ShapeDecoration(
                                    color: kBlackColor,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8.r),
                                    )),
                                child: Center(child: Container(height: 20, width: 20, child: CircularProgressIndicator(color: kWhiteColor))),
                              )
                            // decoration : BoxDecoration(shape: BoxShape.circle,),color: kBlackColor,child: CircularProgressIndicator(color: kWhiteColor))
                            : CustomButton(
                                width: Get.width,
                                height: 40.h,
                                title:
                                    controller.isAccountDetailsAdded.value && controller.isEmailVerified.isFalse ? 'Verify Now' : 'Add Bank Details',
                                onPressed: () {
                                  if (controller.isAccountDetailsAdded.value && controller.isEmailVerified.isFalse) {
                                    showWithdrawDialog(
                                      onContinueBtnClick: () async {
                                        Get.back();
                                        // Get.toNamed(kAccountDetailsRoute);
                                        controller.verifyPayouts(notificationId: controller.payoutNotification.value?.id ?? '');
                                      },
                                    );
                                  } else {
                                    Get.toNamed(kAccountDetailsRoute);
                                  }
                                },
                                backgroundColor: kBlackColor,
                                textColor: kWhiteColor,
                              ),
                      )
                    ],
                  ),
                ),
    );
  }
}
