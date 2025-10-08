import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:socials_app/models/recordings_models/mention_model.dart';
import 'package:socials_app/utils/app_colors.dart';

import '../../../../utils/common_code.dart';

class MentionWidget extends StatelessWidget {
  const MentionWidget({
    super.key,
    required this.value,
  });

  final MentionModel value;

  @override
  Widget build(BuildContext context) {
    printLogs('value.imageUrl.startsWith("https") ${value.imageUrl.startsWith("https")}');
    return SizedBox(
      width: value.name.length * 15.w,
      // width: Get.width,
      height: 50.h,
      // padding: EdgeInsets.only(bottom: 10.h),
      child: Row(
        children: [
          CircleAvatar(
            radius: 16.r,
            backgroundImage:
                value.imageUrl.startsWith("https") ? NetworkImage(value.imageUrl, scale: 2.5) : AssetImage(value.imageUrl) as ImageProvider,
          ),
          SizedBox(width: 10.w),
          Text(
            value.name,
            style: GoogleFonts.leagueSpartan(
              fontSize: 14.sp,
              fontWeight: FontWeight.w600,
              color: value.isSelected ? kPrimaryColor : kWhiteColor,
            ),
          ),
        ],
      ),
    );
  }
}
