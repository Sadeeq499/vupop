// ignore_for_file: must_be_immutable

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:socials_app/utils/app_styles.dart';

import '../../utils/app_colors.dart';

class CustomButton extends StatelessWidget {
  CustomButton(
      {super.key, required this.width, required this.height, required this.title, this.backgroundColor, this.textColor, required this.onPressed});
  final double width;
  final double height;
  final String title;
  VoidCallback? onPressed;
  final Color? backgroundColor;
  final Color? textColor;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        foregroundColor: kWhiteColor,
        // disabledForegroundColor: backgroundColor,
        disabledBackgroundColor: kPrimaryColor.withOpacity(0.5),
        shadowColor: Colors.transparent,
        backgroundColor: backgroundColor ?? kPrimaryColor,
        fixedSize: Size(width, height),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8.r),
        ),
      ),
      child: Text(title,
          style: AppStyles.labelTextStyle()
              .copyWith(fontFamily: 'Norwester', fontSize: 18.sp, fontWeight: FontWeight.w400, color: textColor ?? kBlackColor)),
    );
  }
}
