import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:socials_app/views/custom_widgets/custom_button.dart';

import '../../../../utils/app_colors.dart';
import '../../../../utils/app_images.dart';
import '../../../../utils/app_styles.dart';

class ReasonBottomSheet extends StatelessWidget {
  final List<String> reasons;

  ReasonBottomSheet(
      {super.key,
      required this.reasons,
      required this.onButtonTap,
      required this.onCloseButton,
      required this.onChange,
      required this.selectedReason,
      required this.btnText,
      required this.titleText});
  String selectedReason;
  String btnText;
  String titleText;
  VoidCallback onButtonTap;
  VoidCallback onCloseButton;
  ValueChanged onChange;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent, // Ensure the material is transparent
      child: BackdropFilter(
        filter: ImageFilter.blur(
            sigmaX: 10.0, sigmaY: 10.0), // Apply a stronger blur effect
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(
                0.05), // Increase opacity for a more pronounced whitish effect
            borderRadius: BorderRadius.circular(12.0),
          ),
          child: AlertDialog(
            backgroundColor:
                kBlackColor, // Lighter background color for a more pronounced blur
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24),
            elevation: 12.0, // Add shadow with elevation
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.0),
            ),
            title: Row(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  titleText,
                  style: AppStyles.appBarHeadingTextStyle()
                      .copyWith(color: kPrimaryColor),
                ),
                IconButton(
                    icon: const Icon(
                      Icons.close,
                      size: 24,
                    ),
                    color: kPrimaryColor,
                    onPressed: onCloseButton)
              ],
            ),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(height: 5),
                  Container(
                    width: Get.width * 0.7,
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1B1B1B),
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        dropdownColor: Colors.black,
                        hint: Text(
                          '',
                          style: AppStyles.labelTextStyle()
                              .copyWith(color: kHintGreyColor),
                        ),
                        value: selectedReason,
                        icon: Image.asset(
                          kDropDown,
                          scale: 5,
                        ),
                        isExpanded: true,
                        style: AppStyles.labelTextStyle().copyWith(
                          color: kHintGreyColor,
                          fontSize: 16.sp,
                        ),
                        onChanged: onChange,
                        items: reasons
                            .map<DropdownMenuItem<String>>((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      CustomButton(
                        width: Get.width * 0.30,
                        height: 40.h,
                        title: btnText,
                        onPressed: onButtonTap,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
