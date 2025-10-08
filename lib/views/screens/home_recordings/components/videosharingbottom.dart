import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:socials_app/utils/app_colors.dart';
import 'package:socials_app/utils/app_images.dart';

class VideoSharingBottom extends StatelessWidget {
  final VoidCallback? onPressed;
  const VideoSharingBottom({
    super.key,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Container(
        width: Get.width,
        height: 55.h,
        color: Colors.transparent,
        child: SizedBox(
          width: 180.w,
          height: 40.h,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Align(
              alignment: Alignment.topRight,
              child: ElevatedButton(
                onPressed: onPressed,
                style: ElevatedButton.styleFrom(
                  foregroundColor: kWhiteColor,
                  shadowColor: Colors.transparent,
                  backgroundColor: kPrimaryColor,
                  fixedSize: Size(180.w, 40.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('Share', style: GoogleFonts.leagueSpartan(color: kBlackColor, fontSize: 14.sp, fontWeight: FontWeight.w400)),
                    SizedBox(width: 8.w),
                    Image.asset(kICsharearrow, width: 20.w, height: 20.h),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
