import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:socials_app/utils/app_colors.dart';

class SharingIcon extends StatelessWidget {
  final String iconPath;
  final String text;
  final Function()? onTap;
  final bool isTapped;
  const SharingIcon({
    super.key,
    required this.iconPath,
    required this.text,
    this.onTap,
    this.isTapped = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        child: Column(
          children: [
            Image.asset(
              iconPath,
              width: 80.w,
              height: 30.h,
              color: isTapped ? kPrimaryColor : null,
            ),
            SizedBox(height: 8.h),
            Text(
              text,
              style: TextStyle(
                color: Colors.white,
                fontSize: 12.sp,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
