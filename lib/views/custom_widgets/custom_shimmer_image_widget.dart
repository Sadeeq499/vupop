import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shimmer/shimmer.dart';
import 'package:socials_app/utils/app_colors.dart';

class CustomImageShimmer extends StatelessWidget {
  final double? width;
  final double? height;
  const CustomImageShimmer({
    super.key,
    this.width,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: kShimmerbaseColor,
      highlightColor: kShimmerhighlightColor,
      child: Container(
        width: width ?? 180.w,
        height: height ?? 200.h,
        color: Colors.grey,
      ),
    );
  }
}
