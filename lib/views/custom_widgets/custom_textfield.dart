import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../utils/app_colors.dart';
import '../../utils/app_styles.dart';
import '../screens/auth/controller/auth_controller.dart';

class CustomTextField extends StatelessWidget {
  final IconData? icon;
  final bool isPassword;
  final double? width;
  final String hint;
  final TextEditingController controller;
  final IconData? suffixIcon;
  final Widget? suffixWidget;
  final bool? isChangePassword;
  final String? Function(String?)? validator;
  final int? maxLines;
  final int? minLines;
  final bool? isEdit;
  final EdgeInsetsGeometry? contentPadding;
  final bool isActive; // New property to determine if the text field is active or not
  final Function(String)? onChanged;
  final TextInputAction? textInputAction;

  const CustomTextField({
    Key? key,
    this.icon,
    required this.isPassword,
    required this.hint,
    required this.controller,
    this.suffixIcon,
    this.isEdit,
    this.maxLines,
    this.width,
    this.isChangePassword,
    this.validator,
    this.minLines,
    this.contentPadding,
    this.onChanged,
    this.isActive = true, // Default value is true
    this.suffixWidget,
    this.textInputAction,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final AuthController cont = Get.put(AuthController());
    final isHidePassword = cont.isHidePassword;
    final obscureText = isPassword && (hint == 'Type your password' && isHidePassword.value);

    return Container(
      width: width ?? Get.width,
      child: TextFormField(
        autovalidateMode: AutovalidateMode.onUserInteraction,
        controller: controller,
        obscureText: obscureText,
        validator: validator,
        minLines: minLines ?? 1,
        maxLines: maxLines ?? 1,
        readOnly: isEdit != null ? isEdit! : !isActive, // Conditionally set readOnly based on isActive
        style: AppStyles.labelTextStyle().copyWith(
          fontSize: 16.sp,
          fontWeight: FontWeight.w500,
          color: kPrimaryColor,
        ),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: AppStyles.labelTextStyle().copyWith(
            fontSize: 14.sp,
            fontWeight: FontWeight.w500,
            color: kHintGreyColor,
          ),
          prefixIcon: icon != null
              ? Icon(
                  icon,
                  size: 18,
                  color: kWhiteColor,
                )
              : null,
          suffixIcon: isPassword
              ? GestureDetector(
                  onTap: () {
                    if (hint == 'Type your password') {
                      cont.isHidePassword.toggle();
                    }
                  },
                  child: Icon(
                    suffixIcon,
                    color: kPrimaryColor,
                    size: 18,
                  ),
                )
              : suffixWidget,
          filled: true,
          contentPadding: contentPadding ?? EdgeInsets.symmetric(vertical: 5, horizontal: 16),
          fillColor: kGreyContainerColor,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.r),
            borderSide: isEdit == true
                ? BorderSide.none
                : BorderSide(
                    color: kGreyContainerColor,
                    width: 2.0,
                  ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.r),
            borderSide: isEdit == true
                ? BorderSide.none
                : BorderSide(
                    color: kPrimaryColor,
                    width: 2.0,
                  ),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.r),
            borderSide: isEdit == true
                ? BorderSide.none
                : BorderSide(
                    color: kGreyContainerColor,
                    width: 2.0,
                  ),
          ),
        ),
        onChanged: onChanged,
        textInputAction: textInputAction ?? TextInputAction.next,
      ),
    );
  }
}
