import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:socials_app/utils/app_colors.dart';
import 'package:socials_app/utils/app_images.dart';

import '../../../../utils/app_styles.dart';

class SocailWalletWidget extends StatelessWidget {
  final String text;
  final String priceValue;
  final bool price;
  const SocailWalletWidget({super.key, required this.text, required this.price, required this.priceValue});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: ShapeDecoration(
            image: DecorationImage(
              image: AssetImage(kAppInitialIcon),
              fit: BoxFit.fill,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(43.16),
            ),
          ),
        ),
        SizedBox(
          width: 20.w,
        ),
        SizedBox(
          width: 231,
          child: Text(
            text,
            style: AppStyles.labelTextStyle().copyWith(
              color: kWhiteColor,
              fontSize: 16.sp,
              letterSpacing: 0.64,
            ),
          ),
        ),
        Spacer(),
        price
            ? Text(
                priceValue,
                style: AppStyles.labelTextStyle().copyWith(
                  color: Color(0xFF47AD17),
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                  height: 0.09,
                  letterSpacing: 0.64,
                ),
              )
            : SizedBox(),
      ],
    );
  }
}
