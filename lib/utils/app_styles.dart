import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_colors.dart';

class AppStyles {
  static TextStyle labelTextStyle() => GoogleFonts.leagueSpartan(fontSize: 14.sp, fontWeight: FontWeight.w400, color: kWhiteColor);
  static TextStyle appBarHeadingTextStyle() => GoogleFonts.leagueSpartan(fontSize: 24.sp, fontWeight: FontWeight.w700, color: kPrimaryColor);
  static BorderRadius get customBorderTL40 => BorderRadius.only(
        topLeft: Radius.circular(40.h),
        bottomRight: Radius.circular(35.h),
      );
  static BorderRadius get customBorderAll16 => BorderRadius.all(
        Radius.circular(16.h),
      );
  static BorderRadius get customBorderAll8 => BorderRadius.all(
        Radius.circular(8.h),
      );
  static ButtonStyle get fillPrimary => ElevatedButton.styleFrom(
        backgroundColor: kPrimaryColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8.r),
        ),
      );
}
