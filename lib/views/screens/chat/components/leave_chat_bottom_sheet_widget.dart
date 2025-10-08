import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../utils/app_colors.dart';
import '../../../../utils/app_images.dart';
import '../../../../utils/app_styles.dart';
import '../../../../utils/common_code.dart';

class LeaveChatBottomSheet extends StatelessWidget {
  final String titleText;
  final String description;
  final String? image;
  final VoidCallback onTap;
  const LeaveChatBottomSheet({super.key, required this.titleText, required this.description, required this.image, required this.onTap});

  @override
  Widget build(BuildContext context) {
    printLogs('==============image $image');
    return Container(
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20.r),
          topRight: Radius.circular(20.r),
        ),
      ),
      child: Padding(
        padding: EdgeInsets.all(24.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Top indicator bar
            Container(
              width: 40.w,
              height: 4.h,
              margin: EdgeInsets.only(bottom: 24.h),
              decoration: BoxDecoration(
                color: Colors.grey[600],
                borderRadius: BorderRadius.circular(2.r),
              ),
            ),

            // Channel Logo
            Container(
              width: 96,
              height: 96,
              decoration: const BoxDecoration(
                color: Colors.transparent,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: image != null && image!.startsWith("https")
                    ? Image.network(
                        image!, // Add your logo asset
                        width: 85,
                        height: 85,
                        fit: BoxFit.fill,
                        errorBuilder: (context, error, stackTrace) {
                          return Image.asset(
                            kGroupChatIcon, // Add your logo asset
                            width: 85,
                            height: 85,
                            fit: BoxFit.fill,
                          );
                        },
                      )
                    : Image.asset(
                        kGroupChatIcon, // Add your logo asset
                        width: 85,
                        height: 85,
                        fit: BoxFit.fill,
                      ),
              ),
            ),

            SizedBox(height: 20.h),

            // Title
            Center(
              child: Text(
                titleText,
                style: AppStyles.labelTextStyle().copyWith(fontSize: 20, color: kPrimaryColor, fontWeight: FontWeight.w600),
                textAlign: TextAlign.center,
              ),
            ),

            SizedBox(height: 16.h),

            // Description
            Center(
              child: Text(
                description,
                style: AppStyles.labelTextStyle().copyWith(color: kWhiteColor, fontSize: 14),
                textAlign: TextAlign.center,
              ),
            ),

            SizedBox(height: 24.h),

            // Leave Chat Button
            GestureDetector(
              onTap: onTap,
              child: Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(vertical: 16.h),
                decoration: BoxDecoration(
                  border: Border.all(color: kOverdueRedColor),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Leave Chat',
                      style: AppStyles.labelTextStyle().copyWith(
                        color: kOverdueRedColor,
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(width: 8.w),
                    Icon(Icons.exit_to_app, color: kOverdueRedColor, size: 24.sp),
                  ],
                ),
              ),
            ),

            SizedBox(height: 16.h),
          ],
        ),
      ),
    );
  }
}
