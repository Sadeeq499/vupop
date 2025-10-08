import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:socials_app/services/session_services.dart';
import 'package:socials_app/utils/app_colors.dart';
import 'package:socials_app/utils/app_images.dart';
import 'package:socials_app/utils/common_code.dart';
import 'package:socials_app/views/custom_widgets/share_bottom_sheet.dart';
import 'package:socials_app/views/screens/home/components/reasons_bottom_modal.dart';
import 'package:socials_app/views/screens/home/controller/home_controller.dart';

import '../../../../services/custom_snackbar.dart';
import '../../../../utils/app_dialogs.dart';
import '../../../custom_widgets/sharing_icon.dart';

class VideoReactionsBar extends StatelessWidget {
  final HomeScreenController controller;
  final int index;

  const VideoReactionsBar({
    super.key,
    required this.controller,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 50.w,
      // height: Get.height * 0.35,
      padding: const EdgeInsets.only(left: 8, right: 8, top: 16),
      decoration: ShapeDecoration(
        color: Colors.black.withOpacity(0.3),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Obx(() => SharingIcon(
                iconPath: kLikeIcon,
                text: controller.posts[index].likesCount.toString(),
                isTapped: controller.posts[index].likes.contains(SessionService().user?.id ?? ''),
                onTap: () {
                  controller.updateLikeDislike(postId: controller.posts[index].id, index: index);
                  // CustomSnackbar.showSnackbar("Feature Coming Soon");
                },
              )),
          SizedBox(
            height: 5.h,
          ),
          Obx(() => SharingIcon(
                iconPath: kRatingStar,
                text: controller.posts[index].averageRating.toDouble().toStringAsFixed(1),
                onTap: () {
                  printLogs('Comment');
                  controller.isRatingTapped.value = !controller.isRatingTapped.value;
                },
              )),
          SizedBox(
            height: 5.h,
          ),
          Obx(() => SharingIcon(
                iconPath: kSendIcon,
                text: controller.posts[index].share.length.toString(),
                onTap: () async {
                  controller.isRatingTapped.value = false;
                  _showShareOptions(context);

                  // print(
                  //     '=======shareResult on clik ${controller.posts[index].id}');
                  // String videoLink = controller.posts[index].maskVideo;
                  // printLogs('=======shareResult videoLink $videoLink');
                  // ShareResult shareResult = await Share.share(videoLink,
                  //     subject: 'Check out this video');
                  // printLogs('=======shareResult $shareResult');
                  // if (shareResult.status == ShareResultStatus.success) {
                  //   controller.updateShareCount(
                  //       postId: controller.posts[index].id,
                  //       index: index,
                  //       postedUserId: controller.posts[index].userId.id);
                  // }
                },
              )),
          SizedBox(
            height: 5.h,
          ),
          SharingIcon(
            iconPath: kReportClip,
            text: controller.posts[index].reportCount.toString(),
            onTap: () {
              printLogs('on reasons lst === ${controller.reportingReasons}');
              controller.isRatingTapped.value = false;
              showDialog(
                context: context,
                builder: (context) => Obx(
                  () => ReasonBottomSheet(
                    titleText: 'Report Clip',
                    reasons: controller.reportingReasons.value,
                    onCloseButton: () {
                      controller.selectedReason.value = 'Select Reason';

                      Get.back();
                    },
                    onButtonTap: () {
                      if (controller.selectedReason.value != "Select Reason") {
                        controller.reportClip(postId: controller.posts[index].id, reason: controller.selectedReason.value).then((value) {
                          Navigator.pop(context);
                        });
                      } else {
                        CustomSnackbar.showSnackbar("Select reason");
                      }
                    },
                    onChange: controller.onReasonDropDownChange,
                    selectedReason: controller.selectedReason.value,
                    btnText: 'Report',
                  ),
                ),
              );
            },
          ),
          SharingIcon(
            iconPath: kBlockUser,
            text: "",
            onTap: () {
              printLogs('on reasons lst === ${controller.blockingReasons}');
              controller.isRatingTapped.value = false;
              showDialog(
                  context: context,
                  builder: (context) => Obx(
                        () => ReasonBottomSheet(
                          titleText: 'Block User',
                          reasons: controller.blockingReasons,
                          onCloseButton: () {
                            controller.selectedReason.value = 'Select Reason';
                            Get.back();
                          },
                          onButtonTap: () {
                            if (controller.selectedReason.value != "Select Reason") {
                              AppDialogs().showBlockUserConfirmationDialog(onPressed: () async {
                                Get.back();
                                await controller
                                    .blockUser(blockedUserId: controller.posts[index].userId.id, reason: controller.selectedReasonId.value)
                                    .then((value) {
                                  Navigator.pop(context);
                                });
                              });
                            } else {
                              CustomSnackbar.showSnackbar("Select reason");
                            }
                          },
                          onChange: controller.onBlockDropDownChange,
                          selectedReason: controller.selectedReason.value,
                          btnText: 'Block',
                        ),
                      ));
            },
          )
        ],
      ),
    );
  }

  void _showShareOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: kBackgroundColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      builder: (BuildContext context) {
        return ShareOptionsBottomSheet(
          onInAppShare: () async {
            CommonCode().withInAppShare(context, controller.posts[index]);
          },
          videoLink: controller.posts[index].maskVideo,
          onShareSuccess: () {
            controller.updateShareCount(
              postId: controller.posts[index].id,
              index: index,
              postedUserId: controller.posts[index].userId.id,
            );
          },
        );
      },
    );
  }
}
