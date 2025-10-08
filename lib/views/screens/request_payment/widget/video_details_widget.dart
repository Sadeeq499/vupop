import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:shimmer/shimmer.dart';
import 'package:socials_app/utils/app_colors.dart';
import 'package:socials_app/utils/app_images.dart';
import 'package:socials_app/utils/app_styles.dart';

class VideoDetailsWidget extends StatelessWidget {
  final String exporterName;
  final String duration;
  final String imageUrl;
  const VideoDetailsWidget({super.key, required this.exporterName, required this.duration, required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: Get.width * 1,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center, // Center alignment for text
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Container(
              width: 86.w,
              height: 100.h,
              clipBehavior: Clip.antiAlias,
              decoration: ShapeDecoration(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
              ),
              child: imageUrl.isNotEmpty && imageUrl.startsWith("https")
                  ? CachedNetworkImage(
                      imageUrl: imageUrl,
                      progressIndicatorBuilder: (context, url, progress) => Shimmer.fromColors(
                          baseColor: kShimmerbaseColor,
                          highlightColor: kShimmerhighlightColor,
                          child: Container(
                            color: Colors.white,
                          )),
                    )
                  : Image.asset(kDummyImage)),
          SizedBox(width: 10.w),
          // Wrap the Column with Expanded or Flexible
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(
                        text: '$duration of this video clip were exported by ',
                        style: AppStyles.labelTextStyle().copyWith(
                          color: kWhiteColor,
                          fontSize: 14.sp,
                        ),
                      ),
                      TextSpan(
                        text: '@$exporterName',
                        style: AppStyles.labelTextStyle().copyWith(
                          color: kPrimaryColor,
                        ),
                      ),
                      TextSpan(
                        text: ', funds will be in your wallet soon',
                        style: AppStyles.labelTextStyle().copyWith(
                          color: kWhiteColor,
                        ),
                      ),
                    ],
                  ),
                  overflow: TextOverflow.visible,
                  softWrap: true,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
