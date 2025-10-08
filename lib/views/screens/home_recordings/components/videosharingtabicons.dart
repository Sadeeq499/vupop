import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:socials_app/utils/app_colors.dart';

class VideoSharingTabIcons extends StatelessWidget {
  final String iconPath;
  final String iconText;
  final bool isSelected;
  final double? scale;
  final double height;
  final double width;
  const VideoSharingTabIcons(
      {super.key, required this.iconPath, required this.iconText, this.height = 60, this.width = 60, this.scale, this.isSelected = false});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height.h,
      width: width.w,
      child: Align(
        alignment: Alignment.bottomCenter,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Center(
              child: Image.asset(
                iconPath,
                scale: scale ?? 3.0,
                color: isSelected ? kPrimaryColor : kWhiteColor,
              ),
            ),
            SizedBox(
              height: 2,
            ),
            Expanded(
              child: Text(
                iconText,
                textAlign: TextAlign.center,
                style: GoogleFonts.leagueSpartan(
                    color: isSelected ? kPrimaryColor : kWhiteColor, fontSize: width != 60 ? 10.sp : 13.sp, fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
