import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:shimmer/shimmer.dart';
import 'package:socials_app/services/session_services.dart';
import 'package:socials_app/utils/app_colors.dart';
import 'package:socials_app/utils/app_images.dart';
import 'package:socials_app/utils/app_strings.dart';
import 'package:socials_app/views/custom_widgets/custom_scaffold.dart';
import 'package:socials_app/views/custom_widgets/custom_shimmer_image_widget.dart';
import 'package:socials_app/views/custom_widgets/drawer.dart';
import 'package:socials_app/views/screens/home_recordings/controller/recording_cont.dart';

import '../../../../utils/app_styles.dart';
import '../../../../utils/common_code.dart';
import '../../../custom_widgets/custom_app_dialogs.dart';
import '../../bottom/controller/bottom_bar_controller.dart';
import '../controller/profile_controller.dart';

class ProfileScreen extends GetView<ProfileScreenController> {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    Future.microtask(() async {
      Get.find<BottomBarController>().selectedIndex.value = 0;
      if (Get.find<BottomBarController>().previousSelectedIndex.value == 1) {
        Get.find<BottomBarController>().previousSelectedIndex.value = 0;
        Get.find<RecordingController>().stopCamera();
        Get.find<RecordingController>().resetRecording();
      }
      controller.getWalletBalance();
      controller.getUploadingVideos();
    });
    return Obx(
      () => ModalProgressHUD(
        inAsyncCall: controller.isVerifyingPayout.value,
        child: CustomScaffold(
          className: 'Profile Screen',
          screenName: "",
          scaffoldKey: controller.scaffoldKeyProfile,
          isFullBody: false,
          backIconColor: kPrimaryColor,
          leadingWidth: 0,
          // isBackIcon: true,
          /*leadingWidget: IconButton(
            icon: const Icon(Icons.arrow_back_ios),
            color: kPrimaryColor,
            onPressed: () {
              ///TODO back to home screen
              Get.find<BottomBarController>().selectedIndex.value = 0;
            },
          ),*/
          onWillPop: () {
            print('===========hey');
            // Get.find<BottomBarController>().selectedIndex.value = 0;
            CommonCode.logOutConfirmation();
          },
          actions: [
            Container(
              padding: EdgeInsets.only(left: 20),
              child: Image.asset(
                kAppLogo,
                width: 120.w,
                height: 40.h,
              ),
            ),
            const Spacer(),
            GestureDetector(
              onTap: () {
                Get.toNamed(kNotificationRoute);
              },
              child: Image.asset(
                kNotificationIcon,
                width: 50.w,
                height: 20.h,
              ),
            ),
            Obx(() => controller.isOtherUser.value
                ? const SizedBox()
                : Padding(
                    padding: const EdgeInsets.only(right: 20),
                    child: GestureDetector(
                      onTap: () {
                        controller.scaffoldKeyProfile.currentState
                            ?.openDrawer();
                      },
                      child: const Icon(Icons.menu, color: kPrimaryColor),
                    ),
                  )),
          ],
          drawer: ProfileDrawer(),
          body: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                    width: Get.width,
                    height: 265.h,
                    padding:
                        EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
                    decoration: BoxDecoration(
                        color: kGreyContainerColor,
                        borderRadius: BorderRadius.circular(8.r)),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(
                          width: Get.width * 0.30,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // const SizedBox(height: 10),
                              Obx(
                                () => controller.profileImageUrl.value.isEmpty
                                    ? CustomImageShimmer(
                                        width: 130.w,
                                        height: 150.h,
                                      )
                                    : Container(
                                        width: 130.w,
                                        height: 150.h,
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(10),
                                          image: controller
                                                      .userData.value?.image ==
                                                  ''
                                              ? DecorationImage(
                                                  image:
                                                      AssetImage(kdummyPerson),
                                                  fit: BoxFit.fill,
                                                )
                                              : DecorationImage(
                                                  image: CommonCode()
                                                          .isValidURL(controller
                                                              .userData
                                                              .value
                                                              ?.image)
                                                      ? CachedNetworkImageProvider(
                                                          controller
                                                              .profileImageUrl
                                                              .value,
                                                          // controller.userData.value?.image ?? "",
                                                          // "https://vupop-public.s3.eu-north-1.amazonaws.com/uploads/1745488332413_image_picker_66BC510C-953C-43C5-B628-CB57B5788C13-18711-000004BE3DA36923.jpg?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Content-Sha256=UNSIGNED-PAYLOAD&X-Amz-Credential=AKIA6ODU2XI34DAAZENQ%2F20250508%2Feu-north-1%2Fs3%2Faws4_request&X-Amz-Date=20250508T191450Z&X-Amz-Expires=3600&X-Amz-Signature=988097635bce9b0afdffd0617e034981abb6e81537d22a0438eac8837403c69d&X-Amz-SignedHeaders=host&x-amz-checksum-mode=ENABLED&x-id=GetObject",
                                                          errorListener:
                                                              (exception) {
                                                            // Log or handle the error
                                                            printLogs(
                                                                'Image loading error: $exception');
                                                            if (exception
                                                                .toString()
                                                                .contains(
                                                                    "Invalid statusCode:")) {
                                                              controller
                                                                  .getUserProfileImage();
                                                            }
                                                          },
                                                        ) as ImageProvider
                                                      : AssetImage(
                                                          (kdummyPerson)),
                                                  fit: BoxFit.cover),
                                        ),
                                      ),
                              ),
                              // CachedImage(
                              //   url: controller.userData.value?.image ?? "",
                              //   width: 200.w,
                              //   height: 150.h,
                              // ),
                              const SizedBox(height: 10),
                              Flexible(
                                child: Text(
                                  "${controller.userData.value?.name ?? SessionService().user?.name}" ??
                                      'N/A',
                                  textAlign: TextAlign.center,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: AppStyles.labelTextStyle().copyWith(
                                    color: kWhiteColor,
                                    fontSize: 22.sp,
                                    fontFamily: 'Norwester',
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(width: Get.width * 0.03),
                        Expanded(
                            child: SizedBox(
                          width: Get.width * 0.65,
                          height: Get.height,
                          child: Obx(
                            () => Column(
                              mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Stack(
                                  children: [
                                    Obx(
                                      () => Container(
                                        width: Get.width,
                                        height: 150.h,
                                        padding:
                                            EdgeInsets.symmetric(vertical: 20),
                                        decoration: BoxDecoration(
                                            image: DecorationImage(
                                                image: AssetImage(controller
                                                            .isAccountDetailsAdded
                                                            .value &&
                                                        (controller
                                                                .isEmailVerified
                                                                .value ||
                                                            Get.find<
                                                                    BottomBarController>()
                                                                .isPayoutVerified
                                                                .isTrue)
                                                    ? kPayoutsBgGreenCircle
                                                    : controller.isAccountDetailsAdded
                                                                .value &&
                                                            !controller
                                                                .isEmailVerified
                                                                .value
                                                        ? kPayoutsBgOrangeCircle
                                                        : kPayoutsBgWhiteCircle),
                                                fit: BoxFit.fill),
                                            borderRadius:
                                                BorderRadius.circular(4.r)),
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          children: [
                                            Text(
                                              controller.walletData.value
                                                          ?.readyToWithdrawAmount !=
                                                      null
                                                  ? "£${controller.walletData.value?.readyToWithdrawAmount?.toStringAsFixed(2)}"
                                                  : 'N/A',
                                              textAlign: TextAlign.center,
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              style: AppStyles
                                                      .appBarHeadingTextStyle()
                                                  .copyWith(
                                                color: kBlackColor,
                                                fontWeight: FontWeight.w600,
                                                fontSize: 24.sp,
                                                fontFamily: 'Norwester',
                                              ),
                                            ),
                                            SizedBox(
                                              height: 4,
                                            ),
                                            Text(
                                              "Total Payouts",
                                              textAlign: TextAlign.center,
                                              maxLines: 2,
                                              overflow: TextOverflow.ellipsis,
                                              style: AppStyles.labelTextStyle()
                                                  .copyWith(
                                                color: kBlackColor
                                                    .withOpacity(0.6),
                                                fontWeight: FontWeight.w600,
                                                fontSize: 14.sp,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    // Clickable "Add Bank" button in white circle
                                    Positioned(
                                      bottom:
                                          0, // Adjust to fit perfectly in the white circle
                                      left: Get.width *
                                          0.1, // Center it horizontally
                                      right: Get.width * 0.1,
                                      child: GestureDetector(
                                        onTap: controller.isAccountDetailsAdded
                                                    .value &&
                                                (controller.isEmailVerified
                                                        .value ||
                                                    Get.find<
                                                            BottomBarController>()
                                                        .isPayoutVerified
                                                        .isTrue)
                                            ? null
                                            : controller
                                                    .isAccountDetailsAdded.value
                                                ? () {
                                                    showWithdrawDialog(
                                                      onContinueBtnClick:
                                                          () async {
                                                        Get.back();
                                                        // Get.toNamed(kAccountDetailsRoute);
                                                        controller.verifyPayouts(
                                                            notificationId:
                                                                controller
                                                                        .payoutNotification
                                                                        .value
                                                                        ?.id ??
                                                                    '');
                                                      },
                                                    );
                                                  }
                                                : () {
                                                    Get.toNamed(
                                                        kAccountDetailsRoute);
                                                  },
                                        child: Container(
                                          padding: EdgeInsets.symmetric(
                                              vertical: 8.h, horizontal: 16.w),
                                          decoration: BoxDecoration(
                                            color: Colors
                                                .transparent, // Or add a subtle background
                                            borderRadius:
                                                BorderRadius.circular(20.r),
                                          ),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.center,
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Icon(
                                                controller.isAccountDetailsAdded
                                                            .value &&
                                                        (controller
                                                                .isEmailVerified
                                                                .value ||
                                                            Get.find<
                                                                    BottomBarController>()
                                                                .isPayoutVerified
                                                                .isTrue)
                                                    ? Icons.verified_sharp
                                                    : controller.isAccountDetailsAdded
                                                                .value &&
                                                            !controller
                                                                .isEmailVerified
                                                                .value
                                                        ? Icons.verified_sharp
                                                        : Icons.add_circle,
                                                color: controller
                                                            .isAccountDetailsAdded
                                                            .value &&
                                                        (controller
                                                                .isEmailVerified
                                                                .value ||
                                                            Get.find<
                                                                    BottomBarController>()
                                                                .isPayoutVerified
                                                                .isTrue)
                                                    ? kWhiteColor
                                                    : kBlackColor,
                                                size: 20,
                                              ),
                                              Text(
                                                controller.isAccountDetailsAdded
                                                            .value &&
                                                        (controller
                                                                .isEmailVerified
                                                                .value ||
                                                            Get.find<
                                                                    BottomBarController>()
                                                                .isPayoutVerified
                                                                .isTrue)
                                                    ? " Verified"
                                                    : controller.isAccountDetailsAdded
                                                                .value &&
                                                            !controller
                                                                .isEmailVerified
                                                                .value
                                                        ? " Confirm"
                                                        : " Add Bank",
                                                textAlign: TextAlign.center,
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                                style:
                                                    AppStyles.labelTextStyle()
                                                        .copyWith(
                                                  color: controller
                                                              .isAccountDetailsAdded
                                                              .value &&
                                                          (controller
                                                                  .isEmailVerified
                                                                  .value ||
                                                              Get.find<
                                                                      BottomBarController>()
                                                                  .isPayoutVerified
                                                                  .isTrue)
                                                      ? kWhiteColor
                                                      : kBlackColor,
                                                  fontWeight: FontWeight.w700,
                                                  fontSize: 14.sp,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(
                                  height: Get.height * 0.02,
                                ),
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.info_outline_rounded,
                                      color: kWhiteColor.withOpacity(0.7),
                                    ),
                                    SizedBox(
                                      width: 5,
                                    ),
                                    Flexible(
                                      child: Text(
                                        "Add & Verify your Bank Details to get your Royalty payouts.",
                                        textAlign: TextAlign.left,
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                        style:
                                            AppStyles.labelTextStyle().copyWith(
                                          fontFamily: 'League Spartan',
                                          color: kWhiteColor.withOpacity(0.7),
                                          fontWeight: FontWeight.w400,
                                          fontSize: 12.sp,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ))
                        // Expanded(
                        //   child: SizedBox(
                        //     width: Get.width * 0.48,
                        //     // height: 250.h,
                        //     child: Column(
                        //       mainAxisAlignment: MainAxisAlignment.center,
                        //       crossAxisAlignment: CrossAxisAlignment.center,
                        //       children: [
                        //         Container(
                        //           padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        //           clipBehavior: Clip.antiAlias,
                        //           decoration: BoxDecoration(
                        //             borderRadius: BorderRadius.circular(8),
                        //             border: Border.all(
                        //               color: kPrimaryColor,
                        //               width: 1,
                        //             ),
                        //           ),
                        //           child: GestureDetector(
                        //               onTap: () {
                        //                 /*showModalBottomSheet(
                        //                   context: context,
                        //                   backgroundColor: kBackgroundColor,
                        //                   isScrollControlled: true,
                        //                   shape: const RoundedRectangleBorder(
                        //                     borderRadius: BorderRadius.only(
                        //                       topLeft: Radius.circular(30),
                        //                       topRight: Radius.circular(30),
                        //                     ),
                        //                   ),
                        //                   builder: (context) {
                        //                     return FollowersFollowingBottomSheet(controller: controller, isFollowersSheet: true);
                        //                   }).then((ab) {
                        //                 controller.searchController.clear();
                        //               });*/
                        //               },
                        //               child: Obx(
                        //                 () => RichText(
                        //                     textAlign: TextAlign.center,
                        //                     text: TextSpan(children: [
                        //                       TextSpan(
                        //                         text: controller.walletData.value?.pendingAmount != null
                        //                             ? "£${controller.walletData.value?.pendingAmount?.toStringAsFixed(2)}"
                        //                             : 'N/A',
                        //                         style: AppStyles.labelTextStyle()
                        //                             .copyWith(color: kWhiteColor, fontSize: 20.sp, fontWeight: FontWeight.bold),
                        //                       ),
                        //                       WidgetSpan(
                        //                           alignment: PlaceholderAlignment.top,
                        //                           child: Padding(
                        //                             padding: const EdgeInsets.only(left: 5.0),
                        //                             child: GestureDetector(
                        //                               onTap: () async {
                        //                                 await controller.tooltipControllerPending.showTooltip();
                        //                               },
                        //                               child: SuperTooltip(
                        //                                 backgroundColor: kGreyContainerColor,
                        //                                 showBarrier: true,
                        //                                 controller: controller.tooltipControllerPending,
                        //                                 content: Text(
                        //                                   "These funds are being processed and will be available for withdrawal soon.",
                        //                                   softWrap: true,
                        //                                   style: AppStyles.labelTextStyle()
                        //                                       .copyWith(fontSize: 14.sp, fontWeight: FontWeight.w400, color: kPrimaryColor),
                        //                                 ),
                        //                                 child: Container(
                        //                                   width: 16.0,
                        //                                   height: 16.0,
                        //                                   decoration: const BoxDecoration(
                        //                                     shape: BoxShape.circle,
                        //                                     color: kPrimaryColor,
                        //                                   ),
                        //                                   child: const Icon(
                        //                                     size: 16,
                        //                                     Icons.info,
                        //                                     color: kBlackColor,
                        //                                   ),
                        //                                 ),
                        //                               ),
                        //                             ),
                        //                           )),
                        //                       TextSpan(text: "\n"),
                        //                       WidgetSpan(
                        //                           child: Padding(
                        //                         padding: const EdgeInsets.only(top: 3.0),
                        //                         child: Text(
                        //                           "Pending Amount",
                        //                           style: AppStyles.labelTextStyle().copyWith(
                        //                             color: kWhiteColorTrans2,
                        //                             fontSize: 16.sp,
                        //                           ),
                        //                         ),
                        //                       )),
                        //                     ])),
                        //               )),
                        //         ),
                        //         const SizedBox(height: 10),
                        //         Container(
                        //           padding: EdgeInsets.only(left: 12, right: 12, bottom: 8, top: 0),
                        //           clipBehavior: Clip.antiAlias,
                        //           decoration: BoxDecoration(
                        //             borderRadius: BorderRadius.circular(8),
                        //             border: Border.all(
                        //               color: kPrimaryColor,
                        //               width: 1,
                        //             ),
                        //           ),
                        //           child: Center(
                        //             child: GestureDetector(
                        //                 onTap: () {
                        //                   /*showModalBottomSheet(
                        //                     context: context,
                        //                     backgroundColor: kBackgroundColor,
                        //                     isScrollControlled: true,
                        //                     shape: const RoundedRectangleBorder(
                        //                       borderRadius: BorderRadius.only(
                        //                         topLeft: Radius.circular(30),
                        //                         topRight: Radius.circular(30),
                        //                       ),
                        //                     ),
                        //                     builder: (context) {
                        //                       return FollowersFollowingBottomSheet(controller: controller, isFollowersSheet: true);
                        //                     }).then((ab) {
                        //                   controller.searchController.clear();
                        //                 });*/
                        //                 },
                        //                 child: Center(
                        //                   child: RichText(
                        //                       textAlign: TextAlign.center,
                        //                       text: TextSpan(children: [
                        //                         TextSpan(
                        //                           text: controller.walletData.value?.readyToWithdrawAmount != null
                        //                               ? "£${controller.walletData.value?.readyToWithdrawAmount?.toStringAsFixed(2)}"
                        //                               : 'N/A',
                        //                           style: AppStyles.labelTextStyle()
                        //                               .copyWith(color: kWhiteColor, fontSize: 20.sp, fontWeight: FontWeight.bold),
                        //                         ),
                        //                         WidgetSpan(
                        //                             alignment: PlaceholderAlignment.middle,
                        //                             child: Padding(
                        //                               padding: const EdgeInsets.only(left: 5.0),
                        //                               child: GestureDetector(
                        //                                 onTap: () async {
                        //                                   await controller.tooltipControllerWithdrawal.showTooltip();
                        //                                 },
                        //                                 child: SuperTooltip(
                        //                                   backgroundColor: kGreyContainerColor,
                        //                                   showBarrier: true,
                        //                                   controller: controller.tooltipControllerWithdrawal,
                        //                                   content: Text(
                        //                                     "This is the amount available for you to withdraw, once you ask for a withdrawal we then check everything and approve it within 24hrs.",
                        //                                     softWrap: true,
                        //                                     style: AppStyles.labelTextStyle()
                        //                                         .copyWith(fontSize: 14.sp, fontWeight: FontWeight.w400, color: kPrimaryColor),
                        //                                   ),
                        //                                   child: Container(
                        //                                     width: 16.0,
                        //                                     height: 16.0,
                        //                                     decoration: const BoxDecoration(
                        //                                       shape: BoxShape.circle,
                        //                                       color: kPrimaryColor,
                        //                                     ),
                        //                                     child: const Icon(
                        //                                       size: 16,
                        //                                       Icons.info,
                        //                                       color: kBlackColor,
                        //                                     ),
                        //                                   ),
                        //                                 ),
                        //                               ),
                        //                             )),
                        //                         WidgetSpan(child: Text("\n")),
                        //                         WidgetSpan(
                        //                             child: Padding(
                        //                                 padding: const EdgeInsets.only(top: 3.0),
                        //                                 child: Text(
                        //                                   "Available to Withdraw Amount",
                        //                                   style: AppStyles.labelTextStyle().copyWith(
                        //                                     color: kWhiteColorTrans2,
                        //                                     fontSize: 14.sp,
                        //                                   ),
                        //                                 ))),
                        //                         WidgetSpan(child: Text("\n")),
                        //                         WidgetSpan(
                        //                             child: Padding(
                        //                           padding: const EdgeInsets.only(top: 5.0),
                        //                           child: Text(
                        //                             "Withdraw",
                        //                             style: AppStyles.labelTextStyle().copyWith(
                        //                               color: kPrimaryColor,
                        //                               fontSize: 16.sp,
                        //                             ),
                        //                           ),
                        //                         )),
                        //                         WidgetSpan(
                        //                             child: Padding(
                        //                           padding: const EdgeInsets.only(top: 5.0),
                        //                           child: GestureDetector(
                        //                             onTap: () {
                        //                               Get.toNamed(kRequestPaymentRoute);
                        //                             },
                        //                             child: Transform.rotate(
                        //                                 angle: 68.5,
                        //                                 child: const Icon(
                        //                                   Icons.arrow_forward,
                        //                                   color: kPrimaryColor,
                        //                                 )),
                        //                           ),
                        //                         )),
                        //                       ])),
                        //                 )),
                        //           ),
                        //         ),
                        //       ],
                        //     ),
                        //   ),
                        // ),
                      ],
                    )),
                SizedBox(height: 20.h),
                // Uploading videos section
                Text(
                  'UPLOADING',
                  style: AppStyles.labelTextStyle().copyWith(
                    color: kWhiteColor,
                    fontSize: 16,
                    fontFamily: 'Norwester',
                    // height: 0.08,
                  ),
                ),
                SizedBox(height: 20),
                // this part is for showing uploading videos
                Obx(
                  () => controller.isUploadingInProgress.isTrue
                      ? Container(
                          height: 200.h,
                          child: Obx(
                            () => ListView.builder(
                              shrinkWrap: true,
                              scrollDirection: Axis.horizontal,
                              itemCount: controller.listUploadingVideos.length,
                              // itemCount: 5,
                              itemBuilder: (context, index) {
                                final item =
                                    controller.listUploadingVideos[index];
                                return Obx(() {
                                  final progress = controller
                                      .getProgress(item.videoPath!)
                                      .value;
                                  printLogs(
                                      "progressPercent ${item.videoPath}==> progressPercent $progress");
                                  final status = controller
                                      .getStatus(item.videoPath!)
                                      .value;

                                  printLogs(
                                      "progressPercent ${item.videoPath}==> status $status");
                                  return UploadItem(
                                    imageFile: item.thumbnailFile!,
                                    status: status,
                                    onRetry: () =>
                                        controller.retryUpload(index),
                                    onRemove: () =>
                                        controller.removeItem(index),
                                    progressPercent: progress,
                                  );
                                });
                                // return UploadItem(
                                //   // imageFile: File(
                                //   //     '${controller.savedVideoDirectory?.path.split('Android')[0]}Download/vupop/receipts/payment_receipt_1735993090645.png'),
                                //   imageFile: item.thumbnailFile!,
                                //   status: controller.getStatus(item.videoPath!).value,
                                //   // status: index == 2 ? UploadStatus.failed : UploadStatus.uploading,
                                //   onRetry: () => controller.retryUpload(index),
                                //   onRemove: () => controller.removeItem(index),
                                //   progressPercent: controller.getProgress(item.videoPath!).value,
                                // );
                              },
                            ),
                          ),
                        )
                      : Text(
                          'All videos uploaded successfully! No videos in progress.',
                          style: AppStyles.labelTextStyle()
                              .copyWith(fontSize: 16.sp, color: kPrimaryColor),
                        ),
                ),
                /*Text(
                    controller.userData.value != null && controller.userData.value?.about != null && controller.userData.value!.about!.isNotEmpty
                        ? controller.userData.value!.about!
                        : SessionService().userDetail?.about ?? 'N/A',
                    style: AppStyles.labelTextStyle().copyWith(color: kWhiteColor, fontSize: 16.sp)),*/
                /* SizedBox(height: 20.h),
                      Center(
                        child: Text("My Passions", style: AppStyles.labelTextStyle().copyWith(color: kWhiteColor, fontSize: 20.sp)),
                      ),
                      SizedBox(height: 10.h),
                      SizedBox(
                        width: Get.width,
                        child: Obx(
                          () => Wrap(
                            spacing: 2.w,
                            alignment: WrapAlignment.center,
                            runAlignment: WrapAlignment.center,
                            children: controller.userPassions.isEmpty
                                ? [
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
                                                      Obx(
                                                        () => Wrap(
                                                          spacing: 2.w,
                                                          alignment: WrapAlignment.center,
                                                          runAlignment: WrapAlignment.center,
                                                          children: List.generate(
                                                            controller.passions.length,
                                                            (index) {
                                                              final passion = controller.passions[index];
                                                              final isSelected = controller.userPassions.contains(passion);
                                                              return Padding(
                                                                padding: const EdgeInsets.only(bottom: 5),
                                                                child: GestureDetector(
                                                                  onTap: () {
                                                                    controller.addPassion(passion);
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
                                        child: Text(
                                          'Add Passions',
                                          style: AppStyles.labelTextStyle().copyWith(
                                            color: kBlackColor,
                                            fontSize: 16.sp,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ]
                                : List.generate(
                                    controller.userPassions.length,
                                    (index) => Padding(
                                      padding: const EdgeInsets.only(bottom: 5),
                                      child: SizedBox(
                                        height: 40.h,
                                        // width: 100.w,
                                        child: Chip(
                                          label: Text(
                                            controller.userPassions[index].title ?? '',
                                            style: AppStyles.labelTextStyle().copyWith(
                                              color: kBlackColor,
                                              fontSize: 16.sp,
                                            ),
                                          ),
                                          backgroundColor: kPrimaryColor,
                                        ),
                                      ),
                                    ),
                                  ),
                          ),
                        ),
                      ),*/
                SizedBox(height: 30),

                // for showing uploaded clips
                Text(
                  'Uploaded Clips',
                  style: AppStyles.labelTextStyle().copyWith(
                    color: kWhiteColor,
                    fontSize: 16,
                    fontFamily: 'Norwester',
                    // height: 0.08,
                  ),
                ),
                SizedBox(height: 20),
                // this part is for showing uploaded videos
                SizedBox(
                  height: 280.h,
                  width: Get.width,
                  child: Obx(
                    () => controller.isGettingPosts.value == true
                        ? Shimmer.fromColors(
                            baseColor: kShimmerbaseColor,
                            highlightColor: kShimmerhighlightColor,
                            child: Container(
                              width: 180.w,
                              height: 200.h,
                              color: Colors.grey,
                            ),
                          )
                        : SizedBox(
                            height: 260.h,
                            width: Get.width * 0.9,
                            child: Obx(
                              () => controller.userPosts.isEmpty
                                  ? Text(
                                      'No posts found',
                                      style: AppStyles.labelTextStyle()
                                          .copyWith(
                                              fontSize: 16.sp,
                                              color: kPrimaryColor),
                                    )
                                  : PageView.builder(
                                      itemCount: controller.userPosts.length,
                                      controller: controller.pageController,
                                      itemBuilder:
                                          (BuildContext context, int index) {
                                        printLogs('inside the builder');
                                        if (controller.userPosts.isEmpty) {
                                          //return const Center(child: CustomImageShimmer());
                                          return Center(
                                            child: Text(
                                              'No posts found',
                                              style: AppStyles.labelTextStyle()
                                                  .copyWith(
                                                      fontSize: 16.sp,
                                                      color: kPrimaryColor),
                                            ),
                                          );
                                        }

                                        return ListenableBuilder(
                                          listenable: controller.pageController,
                                          builder: (context, child) {
                                            double scale = 1.0;
                                            if (controller
                                                .pageController
                                                .position
                                                .hasContentDimensions) {
                                              scale = 1 -
                                                  (controller.pageController
                                                                  .page! -
                                                              index)
                                                          .abs() *
                                                      0.3;
                                            }

                                            bool isPortrait = controller
                                                    .userPosts[index]
                                                    .isPortrait ??
                                                false;

                                            return Center(
                                              child: GestureDetector(
                                                onTap: () async {
                                                  /*controller.isVideoLoading.value = true;
                                                  controller.tappedPostIndex.value = index;
                                                  controller.disposeVideoPlayer();
                                                  int postLength = index == 0 && controller.userPosts.length >= 3
                                                      ? 3
                                                      : index == 0 && controller.userPosts.length < 3
                                                          ? controller.userPosts.length
                                                          : controller.userPosts.length - index;
                                                  printLogs("=====postLength ${postLength}");
                                                  printLogs("=====index ${index}");
                                                  printLogs("=====controller.userPosts.length - index ${controller.userPosts.length - index}");
                                                  printLogs("=====controller.userPosts.length ${controller.userPosts.length}");
                                                  controller
                                                      .initializeAllControllers(index, postLength > 3 ? 3 : postLength, isFromProfileScreen: true)
                                                      .then((val) {
                                                    controller.videoControllers.first.controller.play();
                                                  });*/

                                                  controller.tappedPostIndex
                                                      .value = index;
                                                  if (controller
                                                          .userPosts.length <
                                                      3) {
                                                    // printLogs("=====index ${index}");
                                                    // printLogs("=====controller.userPosts.length - index ${controller.userPosts.length - index}");
                                                    // printLogs("=====controller.userPosts.length ${controller.userPosts.length}");
                                                    controller
                                                        .initializeAllControllers(
                                                            index,
                                                            index > 0
                                                                ? controller
                                                                        .userPosts
                                                                        .length -
                                                                    index
                                                                : controller
                                                                    .userPosts
                                                                    .length)
                                                        .then((a) {
                                                      controller
                                                          .videoControllers
                                                          .first
                                                          .controller
                                                          .play();
                                                    });
                                                  } else {
                                                    controller
                                                        .initializeAllControllers(
                                                            index, 3)
                                                        .then((val) {
                                                      controller
                                                          .videoControllers
                                                          .first
                                                          .play();
                                                    });
                                                  }
                                                  // print('===============is initialiazed ${controller.videoControllers[index].value.isInitialized}');
                                                  Get.toNamed(
                                                      kProfileSwipeViewPosts);
                                                },
                                                // Modified onTap for navigating to swipe view
                                                /*onTap: () async {
                                                  controller.isVideoLoading.value = true;
                                                  controller.tappedPostIndex.value = index;
                                                  await controller.disposeVideoPlayer();

                                                  // Determine how many videos to load based on available posts
                                                  int videosToLoad = min(3, controller.userPosts.length - index);

                                                  // Play the first video
                                                  if (controller.videoControllers.isNotEmpty) {
                                                    controller.videoControllers.first.controller.play();
                                                  } else {
                                                    // Initialize controllers
                                                    await controller.initializeAllControllers(index, videosToLoad);
                                                  }

                                                  Get.toNamed(kProfileSwipeViewPosts);
                                                },*/
                                                child: Transform.scale(
                                                  scale: scale,
                                                  child: Stack(
                                                    alignment:
                                                        AlignmentDirectional
                                                            .center,
                                                    children: [
                                                      Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .all(8.0),
                                                        child: Container(
                                                          width: 180.w,
                                                          height: 240.h,
                                                          decoration:
                                                              BoxDecoration(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        8),
                                                            border: Border.all(
                                                                color:
                                                                    kGreyContainerColor,
                                                                width: 1),
                                                            boxShadow: [
                                                              BoxShadow(
                                                                color: kGreyContainerColor2
                                                                    .withOpacity(
                                                                        0.5),
                                                                spreadRadius: 1,
                                                                blurRadius: 5,
                                                                offset:
                                                                    const Offset(
                                                                        0, 3),
                                                              ),
                                                            ],
                                                          ),
                                                          child: SizedBox(
                                                            height: 50.h,
                                                            child:
                                                                Image.network(
                                                              controller
                                                                      .userPosts[
                                                                          index]
                                                                      .thumbnail ??
                                                                  '',
                                                              fit: BoxFit
                                                                  .contain,
                                                              loadingBuilder:
                                                                  (context,
                                                                      child,
                                                                      loadingProgress) {
                                                                if (loadingProgress ==
                                                                    null) {
                                                                  return SizedBox(
                                                                    width: Get
                                                                        .width,
                                                                    height: Get
                                                                        .height,
                                                                    child:
                                                                        child,
                                                                  );
                                                                } else {
                                                                  return const CustomImageShimmer();
                                                                }
                                                              },
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                      Positioned(
                                                        bottom: 10,
                                                        left: 10,
                                                        child: Visibility(
                                                          visible: controller
                                                                  .userPosts[
                                                                      index]
                                                                  .views
                                                                  ?.isNotEmpty ??
                                                              false,
                                                          child: SizedBox(
                                                            child: Row(
                                                              children: [
                                                                Image.asset(
                                                                  kVideoImage,
                                                                  color:
                                                                      kWhiteColor,
                                                                  scale: 3.0,
                                                                ),
                                                                SizedBox(
                                                                  width: 10.w,
                                                                ),
                                                                Text(
                                                                  "${controller.userPosts[index].views?.length}",
                                                                  style: const TextStyle(
                                                                      color:
                                                                          kWhiteColor),
                                                                ),
                                                              ],
                                                            ),
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
                                    ),
                            ),
                          ),
                  ),
                ),
                SizedBox(height: 10.h),
              ],
            ),
          ),
          /*bottomNavigationBar: Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.h),
            child: SwipeButton.expand(
              thumb: const Icon(
                Icons.double_arrow_rounded,
                color: kBlackColor,
              ),
              activeTrackColor: kPrimaryColor.withOpacity(0.25),
              inactiveTrackColor: kGreyContainerColor.withOpacity(0.5),
              activeThumbColor: kPrimaryColor,
              inactiveThumbColor: kGreyContainerColor.withOpacity(0.5),
              onSwipeStart: () {
                // Set isSwiping to true when swipe starts
                controller.isSwiping.value = true;
              },
              onSwipeEnd: () {
                controller.isSwiping.value = false;
                Get.toNamed(kCreateHighlightedPost);
              },
              child: SizedBox(
                width: Get.width,
                child: Center(
                  child: Text("My Highlight real \n Swipe --->",
                      textAlign: TextAlign.center, style: AppStyles.labelTextStyle().copyWith(color: kPrimaryColor, fontSize: 18.sp)),
                ),
              ),
            ),
          ),*/
        ),
      ),
    );
  }
}

class UploadItem extends StatelessWidget {
  final File imageFile;
  final UploadStatus status;
  final VoidCallback onRetry;
  final VoidCallback onRemove;
  final double progressPercent;

  const UploadItem({
    Key? key,
    required this.imageFile,
    required this.status,
    required this.onRetry,
    required this.onRemove,
    required this.progressPercent,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 200.h,
      width: 150.w,
      margin: EdgeInsets.symmetric(horizontal: 12),
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Image placeholder (in a real app, use Image.file(imageFile))
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              image: DecorationImage(
                image: FileImage((imageFile)),
                //AssetImage('assets/placeholder_image.jpg'),
                fit: BoxFit.cover,
              ),
            ),
          ),

          // Upload progress indicator at bottom
          /*if (status == UploadStatus.uploading)
            Positioned(
              bottom: 12,
              left: 0,
              right: 0,
              child: Center(
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: kPrimaryColor,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.arrow_upward,
                        color: kBlackColor,
                        size: 16,
                      ),
                      SizedBox(width: 4),
                      Text(
                        "85%",
                        style: TextStyle(
                          color: kBlackColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),*/
          if (status == UploadStatus.uploading) ...[
            // Dark overlay showing remaining progress
            Positioned.fill(
              child: Align(
                alignment: Alignment.centerRight,
                child: FractionallySizedBox(
                  widthFactor: 1.0 - progressPercent.clamp(0.0, 1.0),
                  alignment: Alignment.bottomCenter,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.6),
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
            ),

            // Upload indicator with percentage
            Positioned(
              bottom: 12,
              left: 0,
              right: 0,
              child: Center(
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: kPrimaryColor,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.arrow_upward,
                        color: kBlackColor,
                        size: 16,
                      ),
                      SizedBox(width: 4),
                      Text(
                        "${(progressPercent * 100).toInt()}%",
                        style: TextStyle(
                          color: kBlackColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],

          if (status == UploadStatus.hold) ...[
            // Dark overlay showing remaining progress
            Positioned.fill(
              child: Align(
                alignment: Alignment.centerRight,
                child: FractionallySizedBox(
                  widthFactor: 1.0 - progressPercent.clamp(0.0, 1.0),
                  alignment: Alignment.bottomCenter,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.6),
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
            ),

            // Upload indicator with percentage
            Positioned(
              bottom: 12,
              left: 0,
              right: 0,
              child: Center(
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: kPrimaryColor,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.arrow_upward,
                        color: kBlackColor,
                        size: 16,
                      ),
                      SizedBox(width: 4),
                      Text(
                        "0%",
                        style: TextStyle(
                          color: kBlackColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],

          /*Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: kBlackColor.withOpacity(0.5),
              ),
              child: const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(kPrimaryColor),
                ),
              ),
            ),*/

          if (status == UploadStatus.failed)
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: kBlackTransparentColor.withOpacity(0.7),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'Failed Uploading',
                    style: TextStyle(
                      color: kWhiteColor,
                      fontSize: 14,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 5),
                  ElevatedButton(
                    onPressed: onRetry,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: kPrimaryColor,
                      minimumSize: const Size(60, 25),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 5),
                    ),
                    child: const Text(
                      'Retry',
                      style: TextStyle(
                        color: kBlackColor,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ),

          // Close button
          Positioned(
            top: 5,
            right: 5,
            child: GestureDetector(
              onTap: onRemove,
              child: Container(
                width: 20,
                height: 20,
                decoration: const BoxDecoration(
                  color: Colors.black54,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.close,
                  size: 14,
                  color: kWhiteColor,
                ),
              ),
            ),
          ),

          // Success indicator
          if (status == UploadStatus.success)
            Positioned(
              bottom: 5,
              left: 5,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: kPrimaryColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  'OK',
                  style: TextStyle(
                    color: kBlackColor,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

enum UploadStatus { uploading, hold, success, failed }
