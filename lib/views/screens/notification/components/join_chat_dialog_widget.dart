import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:socials_app/utils/app_colors.dart';
import 'package:socials_app/utils/app_images.dart';
import 'package:socials_app/utils/app_styles.dart';
import 'package:socials_app/utils/common_code.dart';
import 'package:socials_app/views/custom_widgets/custom_button.dart';

import '../../../../models/community_chat_noification_model.dart';

class JoinChatDialog extends StatelessWidget {
  final ChatNotification? notification;
  final String titleText;
  final String description;
  final String btnLabel;
  final String? image;
  final VoidCallback onTap;
  final DateTime? endTime;
  final RxBool isLoading;
  const JoinChatDialog(
      {Key? key,
      this.image,
      this.notification,
      required this.titleText,
      required this.description,
      required this.btnLabel,
      required this.onTap,
      required this.isLoading,
      required this.endTime})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        width: Get.width,
        padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 8),
        decoration: BoxDecoration(
          color: Colors.black,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: Colors.yellow.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Logo
            Container(
              width: 144, // 3:1 ratio example
              height: 48,
              decoration: const BoxDecoration(
                color: Colors.transparent,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: image == null && notification != null && notification!.image != null && notification!.image!.isNotEmpty
                    ? Image.network(
                        notification!.image!, // Add your logo asset
                        width: 144, // 3:1 ratio example
                        height: 48,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Image.asset(
                            kGroupChatIcon, // Add your logo asset
                            width: 85,
                            height: 85,
                            fit: BoxFit.fill,
                          );
                        },
                      )
                    : image != null && image!.startsWith("http")
                        ? Image.network(
                            image!, // Add your logo asset
                            width: 144, // 3:1 ratio example
                            height: 48,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Image.asset(
                                kGroupChatIcon, // Add your logo asset
                                width: 85,
                                height: 85,
                                fit: BoxFit.fill,
                              );
                            },
                          )
                        : image != null
                            ? Image.asset(
                                image!, // Add your logo asset
                                width: 144, // 3:1 ratio example
                                height: 48,
                                fit: BoxFit.cover,
                              )
                            : Image.asset(
                                kGroupChatIcon, // Add your logo asset
                                width: 85,
                                height: 85,
                                fit: BoxFit.fill,
                              ),
              ),
            ),
            // CircleAvatar(
            //   backgroundImage: notification.image != null && notification.image!.isNotEmpty
            //       ? NetworkImage(notification.image!, scale: 5)
            //       : AssetImage(kGroupChatIcon) as ImageProvider,
            // ),
            SizedBox(height: 24),

            // Title
            Center(
              child: Text(
                titleText,
                style: AppStyles.labelTextStyle().copyWith(fontSize: 20, color: kPrimaryColor, fontWeight: FontWeight.w600),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 16),

            // Description
            Center(
              child: Text(
                description,
                style: AppStyles.labelTextStyle().copyWith(color: kWhiteColor, fontSize: 14),
                textAlign: TextAlign.center,
              ),
            ),
            /*RichText(
              textAlign: TextAlign.center,
              text: TextSpan(
                children: [
                  TextSpan(
                    text:
                        '🏆 The ultimate showdown is here! Join the live chat for Barcelona vs. Real Madrid and experience the action with fellow fans—debate, celebrate, and share every moment! 🔥💬',
                    style: AppStyles.labelTextStyle().copyWith(color: kWhiteColor, fontSize: 16),
                  )
                ],
              ),
            ),*/
            const SizedBox(height: 24),

            // Time remaining
            if (endTime != null && !CommonCode.formatAndParseDateTime(endTime!).difference(DateTime.now()).isNegative)
              Container(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.grey[900],
                  borderRadius: BorderRadius.circular(100),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(
                      kChatTimerIcon,
                      color: kPrimaryColor,
                      width: 24,
                      height: 24,
                    ),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        '${CommonCode.getTimeStatus(endTime!)} REMAINING',
                        style: AppStyles.labelTextStyle().copyWith(
                          color: kWhiteColor,
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 24),

            // Join button
            Obx(() => isLoading.isTrue
                ? Container(
                    decoration: ShapeDecoration(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                      color: kPrimaryColor,
                    ),
                    width: Get.width * 0.75,
                    height: 40.h,
                    child: Center(
                      child: const CircularProgressIndicator(
                        color: kBlackColor,
                        strokeWidth: 2.0,
                      ),
                    ),
                  )
                : CustomButton(width: Get.width * 0.75, height: 40.h, title: btnLabel, onPressed: onTap))
            /*GestureDetector(
              onTap: () {
                // Handle join chat action
                Get.back(); // Close dialog
              },
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 16),
                decoration: BoxDecoration(
                  color: kPrimaryColor,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  btnLabel,
                  style: AppStyles.labelTextStyle().copyWith(
                    color: kBlackColor,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),*/
          ],
        ),
      ),
    );
  }
}
