import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:socials_app/utils/app_colors.dart';
import 'package:socials_app/utils/app_images.dart';
import 'package:socials_app/utils/app_styles.dart';

class FavVideoThumbnail extends StatelessWidget {
  final Uint8List? thumbnail;
  const FavVideoThumbnail({
    super.key,
    this.thumbnail,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 185.w,
      height: 225,
      clipBehavior: Clip.antiAlias,
      decoration: ShapeDecoration(
        image: DecorationImage(
          image: MemoryImage(thumbnail ?? Uint8List(0)),
          fit: BoxFit.cover,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      child: Stack(
        children: [
          Positioned(
              top: 20,
              left: 10,
              child: Row(
                children: [
                  Image.asset(
                    kTimerImage,
                    scale: 4,
                  ),
                  SizedBox(
                    width: 10.w,
                  ),
                  Text(
                    '4hrs',
                    textAlign: TextAlign.center,
                    style: AppStyles.labelTextStyle().copyWith(
                      color: kWhiteColor,
                      fontWeight: FontWeight.w500,
                      height: 0.11,
                    ),
                  )
                ],
              )),
          Positioned(
              bottom: 20,
              left: 10,
              child: Row(
                children: [
                  Image.asset(
                    kVideoImage,
                    scale: 4,
                  ),
                  SizedBox(
                    width: 10.w,
                  ),
                  Text(
                    '100k',
                    textAlign: TextAlign.center,
                    style: AppStyles.labelTextStyle().copyWith(
                      color: kPrimaryColor,
                    ),
                  )
                ],
              ))
        ],
      ),
    );
  }
}
