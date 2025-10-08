import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:socials_app/services/session_services.dart';
import 'package:socials_app/utils/app_colors.dart';
import 'package:socials_app/views/custom_widgets/custom_scaffold.dart';

import '../../../../services/custom_snackbar.dart';
import '../../../../utils/app_styles.dart';
import '../../../custom_widgets/custom_app_dialogs.dart';
import '../../../custom_widgets/custom_button.dart';
import '../controller/social_wallet_controller.dart';
import '../widget/socail_wallet_widget.dart';

class SocialWalletScreen extends GetView<SocialWalletController> {
  const SocialWalletScreen({super.key});

  @override
  Widget build(BuildContext context) {
    controller.isPaymentSuccessful.value = true;
    Future.microtask(() {
      controller.getWalletBalance();
    });
    return Obx(
      () => ModalProgressHUD(
        inAsyncCall: controller.isLoading.value,
        child: CustomScaffold(
          className: runtimeType.toString(),
          screenName: "Payout Tracker",
          isBackIcon: true,
          isFullBody: false,
          appBarSize: 60,
          // leadingWidth: 40,
          backIconColor: kPrimaryColor,
          showAppBarBackButton: true,
          scaffoldKey: controller.socialWalletKey,
          leadingWidget: Row(
            children: [
              IconButton(
                icon: const Icon(
                  Icons.arrow_back_ios,
                ),
                color: kPrimaryColor,
                onPressed: () {
                  ///TODO back to home screen
                  // Get.find<BottomBarController>().selectedIndex.value = 0;
                  Get.back();
                },
              ),
              // SizedBox(width: 20.w),
              // Image.asset(kAppLogo, width: 50.w, height: 20.h),
            ],
          ),
          onWillPop: () {
            Get.back();
            // Get.find<BottomBarController>().selectedIndex.value = 0;
          },
          body: Column(mainAxisSize: MainAxisSize.min, children: [
            SizedBox(
              height: 30.h,
            ),
            Row(
              children: [
                Container(
                    width: 180.w,
                    height: 226,
                    padding: const EdgeInsets.all(16),
                    clipBehavior: Clip.antiAlias,
                    decoration: ShapeDecoration(
                      color: kPrimaryColor,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Pending balance',
                          style: AppStyles.labelTextStyle().copyWith(
                            color: kBlackColor,
                            height: 0.10,
                            letterSpacing: 0.20,
                          ),
                        ),
                        SizedBox(
                          height: 20.h,
                        ),
                        Obx(() => Text(
                              controller.walletData.value?.pendingAmount != null
                                  ? "£${controller.walletData.value?.pendingAmount?.toStringAsFixed(2)}"
                                  : 'N/A',
                              textAlign: TextAlign.center,
                              style: AppStyles.labelTextStyle().copyWith(
                                color: kBlackColor,
                                fontSize: 24.sp,
                                fontFamily: 'Norwester',
                                height: 0.03,
                              ),
                            )),
                        const Spacer(),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Text(
                              'VUPOP',
                              textAlign: TextAlign.center,
                              style: AppStyles.labelTextStyle().copyWith(
                                color: kBlackColor,
                                fontSize: 16.sp,
                                fontFamily: 'Norwester',
                                height: 0.08,
                              ),
                            ),
                            /*const Spacer(),
                            GestureDetector(
                              onTap: () {
                                Get.toNamed(kRequestPaymentRoute);
                              },
                              child: Transform.rotate(
                                  angle: 68.5,
                                  child: const Icon(
                                    Icons.arrow_forward,
                                    color: kBlackColor,
                                  )),
                            )*/
                          ],
                        )
                      ],
                    )),
                SizedBox(
                  width: 10.w,
                ),
                Container(
                    width: 180.w,
                    height: 226,
                    padding: const EdgeInsets.all(16),
                    clipBehavior: Clip.antiAlias,
                    decoration: BoxDecoration(
                      color: kBlackColor,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: kPrimaryColor,
                        width: 1.0,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Available to Withdraw',
                          style: AppStyles.labelTextStyle().copyWith(
                            color: kPrimaryColor,
                            height: 0.10,
                            letterSpacing: 0.20,
                          ),
                        ),
                        SizedBox(
                          height: 20.h,
                        ),
                        Obx(() => Text(
                              controller.walletData.value?.readyToWithdrawAmount != null
                                  ? "£${controller.walletData.value?.readyToWithdrawAmount?.toStringAsFixed(2)}"
                                  : 'N/A',
                              textAlign: TextAlign.center,
                              style: AppStyles.labelTextStyle().copyWith(
                                color: kPrimaryColor,
                                fontSize: 24.sp,
                                fontFamily: 'Norwester',
                                height: 0.03,
                              ),
                            )),
                        const Spacer(),
                        Row(
                          children: [
                            Text(
                              'VUPOP',
                              textAlign: TextAlign.center,
                              style: AppStyles.labelTextStyle().copyWith(
                                color: kPrimaryColor,
                                fontSize: 16.sp,
                                fontFamily: 'Norwester',
                                height: 0.08,
                              ),
                            ),
                            const Spacer(),
                            GestureDetector(
                              onTap: () {
                                /*if (controller.walletData.value != null &&
                                    controller.walletData.value?.readyToWithdrawAmount != null &&
                                    controller.walletData.value!.readyToWithdrawAmount! > 0 &&
                                    controller.isPaymentSuccessful.isTrue) {*/
                                if (controller.isPaymentMethodFound.isTrue &&
                                    SessionService().isEmailVerified != null &&
                                    SessionService().isEmailVerified!) {
                                  showWithdrawDialog(
                                    onContinueBtnClick: () async {
                                      Get.back();
                                      // Get.toNamed(kAccountDetailsRoute);
                                      if (controller.walletData.value != null &&
                                          controller.walletData.value?.readyToWithdrawAmount != null &&
                                          controller.walletData.value!.readyToWithdrawAmount! > 0) {
                                        controller.requestPaymentToAdmin();
                                      } else {
                                        CustomSnackbar.showSnackbar('Withdrawal amount must be greater than zero.');
                                      }
                                    },
                                  );
                                } else {
                                  bankAccountMissingDialog();
                                }

                                // }
                              },
                              child: Transform.rotate(
                                  angle: 68.5,
                                  child: const Icon(
                                    Icons.arrow_forward,
                                    color: kPrimaryColor,
                                  )),
                            )
                          ],
                        )
                      ],
                    )),
              ],
            ),

            ///TODO Coment for now

            Obx(
              () => Visibility(
                visible: controller.walletData.value != null &&
                    controller.walletData.value?.readyToWithdrawAmount != null &&
                    controller.walletData.value!.readyToWithdrawAmount! > 0 &&
                    controller.isPaymentSuccessful.isTrue,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      height: 30.h,
                    ),
                    CustomButton(
                        width: Get.width,
                        height: 40.h,
                        title: 'WithDraw Payment',
                        // onPressed: controller.onWithdrawPaymentPressed,
                        onPressed: () {
                          // Get.toNamed(kAccountDetailsRoute);
                          if (controller.isPaymentMethodFound.isTrue &&
                              SessionService().isEmailVerified != null &&
                              SessionService().isEmailVerified!) {
                            /*showPremiumDialog(
                              premiumPrice: 299,
                              onSubscriptionBtnClick: () {
                                // Handle subscription logic here
                                Get.snackbar(
                                  'Success',
                                  'Premium subscription activated!',
                                  snackPosition: SnackPosition.BOTTOM,
                                  backgroundColor: Colors.green,
                                  colorText: Colors.white,
                                );
                                Get.back();
                              });*/
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
                        }),
                  ],
                ),
              ),
            ),
            // SizedBox(
            //   height: 30.h,
            // ),
            // Row(
            //   children: [
            //     Text(
            //       'May 3',
            //       textAlign: TextAlign.center,
            //       style: AppStyles.labelTextStyle().copyWith(
            //         color: kWhiteColor,
            //         fontSize: 24.sp,
            //         fontFamily: 'Norwester',
            //         height: 0.03,
            //       ),
            //     ),
            //     const Spacer(),
            //     Text(
            //       '-\$400',
            //       style: AppStyles.labelTextStyle().copyWith(
            //         color: const Color(0xFF47AD17),
            //         fontSize: 21.sp,
            //         fontWeight: FontWeight.w600,
            //         height: 0.06,
            //         letterSpacing: 0.80,
            //       ),
            //     )
            //   ],
            // ),
            // SizedBox(
            //   height: 30.h,
            // ),
            // const SocailWalletWidget(
            //   text: 'Cash credited successfully ! ',
            //   price: true,
            // ),
            // SizedBox(
            //   height: 30.h,
            // ),
            // const SocailWalletWidget(
            //   text: 'Payment request sent, awaiting approval.',
            //   price: false,
            // ),
            // SizedBox(
            //   height: 40.h,
            // ),
            // Align(
            //   alignment: Alignment.centerLeft,
            //   child: Text(
            //     'May 2',
            //     textAlign: TextAlign.center,
            //     style: AppStyles.labelTextStyle().copyWith(
            //       color: kWhiteColor,
            //       fontFamily: 'Norwester',
            //       height: 0.10,
            //     ),
            //   ),
            // ),
            SizedBox(
              height: 30.h,
            ),
            Flexible(
              child: Obx(
                () => Visibility(
                  visible: controller.walletData.value != null &&
                      controller.walletData.value?.payment != null &&
                      controller.walletData.value!.payment!.isNotEmpty,
                  child: controller.walletData.value == null
                      ? SizedBox.shrink()
                      : ListView.separated(
                          physics: ClampingScrollPhysics(),
                          shrinkWrap: true,
                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                          itemCount: controller.walletData.value!.payment!.length,
                          separatorBuilder: (context, index) => const SizedBox(height: 18.0),
                          itemBuilder: (context, index) {
                            return Column(
                              children: [
                                SocailWalletWidget(
                                    text: controller.walletData.value!.payment![index].message ?? "",
                                    price: controller.walletData.value!.payment![index].amount != null,
                                    priceValue: "£${controller.walletData.value!.payment![index].amount?.toStringAsFixed(2)}" ?? ""),
                                if (index == controller.walletData.value!.payment!.length - 1) const SizedBox(height: 18.0),
                              ],
                            );
                          },
                        ),
                ),
              ),
            ),
          ]),
        ),
      ),
    );
  }
}
