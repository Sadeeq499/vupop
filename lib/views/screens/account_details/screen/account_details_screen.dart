import 'dart:io';

import 'package:country_code_picker/country_code_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:socials_app/services/custom_snackbar.dart';
import 'package:socials_app/utils/app_colors.dart';
import 'package:socials_app/utils/app_styles.dart';
import 'package:socials_app/views/custom_widgets/custom_button.dart';
import 'package:socials_app/views/custom_widgets/custom_scaffold.dart';

import '../../../../utils/common_code.dart';
import '../../../custom_widgets/custom_textfield.dart';
import '../controller/account_details_controller.dart';

class AccountDetailsScreen extends GetView<AccountDetailsController> {
  const AccountDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    Future.microtask(() {
      controller.getUserPaymentMethod();
    });
    // String _selectedValue = 'Bank Transfer';
    return Obx(
      () => ModalProgressHUD(
        inAsyncCall: controller.isLoading.value,
        child: CustomScaffold(
          className: runtimeType.toString(),
          screenName: "Account Details",
          isBackIcon: true,
          isFullBody: false,
          leadingWidth: 30,
          appBarSize: 40,
          backIconColor: kPrimaryColor,
          showAppBarBackButton: true,
          scaffoldKey: controller.accountDetailsKey,
          body: Padding(
            padding: EdgeInsets.only(
              top: 55.h,
            ),
            child: SingleChildScrollView(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Align(
                  alignment: Alignment.bottomLeft,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Email',
                        style: AppStyles.labelTextStyle().copyWith(fontWeight: FontWeight.w700),
                      ),
                      SizedBox(
                        height: 11.h,
                      ),
                      CustomTextField(
                        isPassword: false,
                        hint: "Type your email",
                        controller: controller.tecEmail,
                        onChanged: (value) {
                          printLogs("check: $value");
                          final result = CommonCode.isValidEmail(value);
                          controller.isValidEmail.value = result;
                          controller.isEmailVerified.value = false;
                          return null;
                        },
                        suffixWidget: TextButton(
                          onPressed: () async {
                            controller.sendOtpOnEmail(context);
                          },
                          child: Obx(
                            () => Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  controller.isEmailVerified.value ? 'Verified' : 'Verify',
                                  style:
                                      TextStyle(color: controller.isEmailVerified.value ? kgreenColor : kPrimaryColor, fontWeight: FontWeight.w600),
                                ),
                                if (controller.isEmailVerified.value) ...{
                                  const SizedBox(width: 3),
                                  const CircleAvatar(
                                    backgroundColor: kgreenColor,
                                    radius: 8,
                                    child: Icon(
                                      Icons.check,
                                      color: kWhiteColor,
                                      size: 12,
                                    ),
                                  )
                                }
                              ],
                            ),
                          ),
                        ),
                        validator: (value) {
                          if (value == null) {
                            return 'Email is required';
                          } else if (!CommonCode.isValidEmail(value)) {
                            return 'Please enter valid email';
                          }
                          return null;
                        },
                      ),
                      SizedBox(
                        height: 20.h,
                      ),
                      Text(
                        'We send payouts via bank transfer, add your bank account details below',
                        style: AppStyles.labelTextStyle().copyWith(
                          color: kWhiteColor,
                          fontWeight: FontWeight.w700,
                          // height: 0,
                          letterSpacing: 0.28,
                        ),
                      ),

                      ///Removed as suggested by Dave
                      /*SizedBox(
                        height: 10.h,
                      ),
                      Obx(
                        () => Container(
                          width: 289.w,
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
                                style: AppStyles.labelTextStyle().copyWith(color: kHintGreyColor),
                              ),
                              value: controller.selectedValue.value,
                              icon: Image.asset(
                                kDropDown,
                                scale: 5,
                              ),
                              isExpanded: true,
                              style: AppStyles.labelTextStyle().copyWith(
                                color: kHintGreyColor,
                                fontSize: 16.sp,
                              ),
                              onChanged: (String? newValue) {
                                if (newValue != null) {
                                  if (newValue == 'Bank Transfer') {
                                    controller.isPaymentMethodSelected.value = true;
                                    controller.selectedValue.value = newValue;
                                  } else {
                                    // ignore: avoid_print
                                    printLogs('else');
                                    CustomSnackbar.showSnackbar("Feature Coming Soon");
                                  }
                                }
                              },
                              items: controller.dropdownItems.map<DropdownMenuItem<String>>((String value) {
                                return DropdownMenuItem<String>(
                                  value: value,
                                  child: Text(value),
                                );
                              }).toList(),
                            ),
                          ),
                        ),
                      ),*/
                    ],
                  ),
                ),
                // SizedBox(
                //   height: 25.h,
                // ),
                Obx(() => Visibility(
                      visible: controller.isPaymentMethodSelected.value || controller.selectedValue.value == 'Bank Transfer',
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          /*Text(
                                'Select your account Location',
                                style: AppStyles.labelTextStyle().copyWith(
                                  color: kWhiteColor,
                                  fontWeight: FontWeight.w700,
                                  height: 0,
                                  letterSpacing: 0.28,
                                ),
                              ),
                              SizedBox(
                                height: 11.h,
                              ),

                              ////..... account location

                              Obx(
                                () => Container(
                                  width: 289.w,
                                  padding:
                                      const EdgeInsets.symmetric(horizontal: 16.0),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF1B1B1B),
                                    borderRadius: BorderRadius.circular(12.0),
                                  ),
                                  child: DropdownButtonHideUnderline(
                                    child: DropdownButton<String>(
                                      dropdownColor: Colors.black,
                                      hint: Text(
                                        'Islambad',
                                        style: AppStyles.labelTextStyle()
                                            .copyWith(color: kHintGreyColor),
                                      ),
                                      value: controller.selectedLocation.value,
                                      icon: Image.asset(
                                        kDropDown,
                                        scale: 5,
                                      ),
                                      isExpanded: true,
                                      style:
                                          AppStyles.labelTextStyle().copyWith(
                                        color: kHintGreyColor,
                                        fontSize: 16.sp,
                                      ),
                                      onChanged: (String? newValue) {
                                        if (newValue != null) {
                                          controller.selectedLocation.value =
                                              newValue;
                                        }
                                      },
                                      items: controller.items
                                          .map<DropdownMenuItem<String>>(
                                              (String value) {
                                        return DropdownMenuItem<String>(
                                          value: value,
                                          child: Text(value),
                                        );
                                      }).toList(),
                                    ),
                                  ),
                                ),
                              ),

                          SizedBox(
                            height: 25.h,
                          ),*/
                          SizedBox(
                            height: 20.h,
                          ),
                          Text(
                            'First Name',
                            style: AppStyles.labelTextStyle().copyWith(
                              color: kWhiteColor,
                              fontWeight: FontWeight.w700,
                              height: 0,
                              letterSpacing: 0.28,
                            ),
                          ),
                          SizedBox(
                            height: 10.h,
                          ),
                          Container(
                            width: 289.w,
                            height: 48.h,
                            decoration: ShapeDecoration(
                              color: kGreyContainerColor,
                              shape: RoundedRectangleBorder(
                                side: const BorderSide(width: 1, color: Colors.transparent),
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: TextField(
                              controller: controller.firstNameController,
                              textInputAction: TextInputAction.next,
                              decoration: InputDecoration(
                                border: InputBorder.none,
                                contentPadding: EdgeInsets.symmetric(horizontal: 16.0.w, vertical: 10.h),
                              ),
                              style: const TextStyle(color: kPrimaryColor),
                            ),
                          ),
                          SizedBox(
                            height: 25.h,
                          ),
                          Text(
                            'Last Name',
                            style: AppStyles.labelTextStyle().copyWith(
                              color: kWhiteColor,
                              fontWeight: FontWeight.w700,
                              height: 0,
                              letterSpacing: 0.28,
                            ),
                          ),
                          SizedBox(
                            height: 10.h,
                          ),
                          Container(
                            width: 289.w,
                            height: 48.h,
                            decoration: ShapeDecoration(
                              color: kGreyContainerColor,
                              shape: RoundedRectangleBorder(
                                side: const BorderSide(width: 1, color: Colors.transparent),
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: TextField(
                              controller: controller.lastNameController,
                              textInputAction: TextInputAction.next,
                              decoration: InputDecoration(
                                border: InputBorder.none,
                                contentPadding: EdgeInsets.symmetric(horizontal: 16.0.w, vertical: 10.h),
                              ),
                              style: const TextStyle(color: kPrimaryColor),
                            ),
                          ),
                          SizedBox(
                            height: 25.h,
                          ),
                          /*Text(
                            'Family Name',
                            style: AppStyles.labelTextStyle().copyWith(
                              color: kWhiteColor,
                              fontWeight: FontWeight.w700,
                              height: 0,
                              letterSpacing: 0.28,
                            ),
                          ),
                          SizedBox(
                            height: 10.h,
                          ),
                          Container(
                            width: 289.w,
                            height: 48.h,
                            decoration: ShapeDecoration(
                              color: kGreyContainerColor,
                              shape: RoundedRectangleBorder(
                                side: const BorderSide(width: 1, color: Colors.transparent),
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: TextField(
                              controller: controller.familyNameController,
                              decoration: InputDecoration(
                                border: InputBorder.none,
                                contentPadding: EdgeInsets.symmetric(horizontal: 16.0.w, vertical: 10.h),
                              ),
                              style: const TextStyle(color: kPrimaryColor),
                            ),
                          ),
                          SizedBox(
                            height: 25.h,
                          ),*/
                          ////....Account Type
                          /*Text(
                            'Account Type',
                            style: AppStyles.labelTextStyle().copyWith(
                              color: kWhiteColor,
                              fontWeight: FontWeight.w700,
                              height: 0,
                              letterSpacing: 0.28,
                            ),
                          ),
                          SizedBox(
                            height: 10.h,
                          ),
                          Obx(
                            () => Container(
                              width: 289.w,
                              padding: const EdgeInsets.symmetric(horizontal: 16.0),
                              decoration: BoxDecoration(
                                color: kGreyContainerColor,
                                borderRadius: BorderRadius.circular(12.0),
                              ),
                              child: DropdownButtonHideUnderline(
                                child: DropdownButton<String>(
                                  dropdownColor: Colors.black,
                                  hint: Text(
                                    'Farhan',
                                    style: AppStyles.labelTextStyle().copyWith(color: kHintGreyColor),
                                  ),
                                  value: controller.selectedAccountType.value,
                                  icon: Image.asset(
                                    kDropDown,
                                    scale: 5,
                                  ),
                                  isExpanded: true,
                                  style: AppStyles.labelTextStyle().copyWith(
                                    color: kHintGreyColor,
                                    fontSize: 16.sp,
                                  ),
                                  onChanged: (String? newValue) {
                                    if (newValue != null) {
                                      controller.selectedAccountType.value = newValue;
                                    }
                                  },
                                  items: controller.accountName.map<DropdownMenuItem<String>>((String value) {
                                    return DropdownMenuItem<String>(
                                      value: value,
                                      child: Text(value),
                                    );
                                  }).toList(),
                                ),
                              ),
                            ),
                          ),

                          ////...Routing

                          SizedBox(
                            height: 30.h,
                          ),
                          Text(
                            'Routing Number',
                            style: AppStyles.labelTextStyle().copyWith(
                              color: kWhiteColor,
                              fontWeight: FontWeight.w700,
                              height: 0,
                              letterSpacing: 0.28,
                            ),
                          ),
                          SizedBox(
                            height: 10.h,
                          ),
                          Container(
                            width: 390,
                            height: 48,
                            decoration: ShapeDecoration(
                              color: kGreyContainerColor,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            ),
                            child: TextField(
                              controller: controller.routingNumberController,
                              decoration: const InputDecoration(
                                border: InputBorder.none,
                                contentPadding: EdgeInsets.symmetric(horizontal: 16.0),
                              ),
                              style: const TextStyle(color: kPrimaryColor),
                            ),
                          ),
                          SizedBox(
                            height: 30.h,
                          ),*/
                          Text(
                            'IBAN',
                            style: AppStyles.labelTextStyle().copyWith(
                              color: kWhiteColor,
                              fontWeight: FontWeight.w700,
                              height: 0,
                              letterSpacing: 0.28,
                            ),
                          ),
                          SizedBox(
                            height: 12.h,
                          ),
                          Container(
                            width: 390.w,
                            height: 48.h,
                            decoration: ShapeDecoration(
                              color: kGreyContainerColor,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            ),
                            child: TextField(
                              controller: controller.accountNumberController,
                              keyboardType: TextInputType.text,
                              textInputAction: TextInputAction.next,
                              onChanged: (value) {
                                if (value.length > 34) {
                                  CustomSnackbar.showSnackbar("IBAN should be 34 digits");
                                  controller.accountNumberController.text = value.substring(0, 8);
                                }
                              },
                              decoration: const InputDecoration(
                                border: InputBorder.none,
                                contentPadding: EdgeInsets.symmetric(horizontal: 16.0),
                              ),
                              style: const TextStyle(color: kPrimaryColor),
                            ),
                          ),
                          SizedBox(
                            height: 30.h,
                          ),
                          Text(
                            'Country',
                            style: AppStyles.labelTextStyle().copyWith(
                              color: kWhiteColor,
                              fontWeight: FontWeight.w700,
                              height: 0,
                              letterSpacing: 0.28,
                            ),
                          ),
                          SizedBox(
                            height: 12.h,
                          ),
                          Container(
                            width: Get.width,
                            decoration: ShapeDecoration(
                              color: kGreyContainerColor,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            ),
                            child: CountryCodePicker(
                              alignLeft: true,
                              showDropDownButton: true,
                              backgroundColor: kGreyContainerColor,
                              textStyle: const TextStyle(color: kWhiteColor),
                              showOnlyCountryWhenClosed: true,
                              searchStyle: const TextStyle(color: kWhiteColor),
                              searchDecoration: const InputDecoration(
                                hintStyle: TextStyle(color: kWhiteColor),
                                hintText: 'Search',
                                suffixIconColor: kGreyContainerColor,
                                border: OutlineInputBorder(),
                                contentPadding: EdgeInsets.symmetric(horizontal: 16.0),
                              ),
                              boxDecoration: const BoxDecoration(shape: BoxShape.rectangle, color: kBlackColor),
                              onChanged: controller.onCountryDropDownChange,
                              initialSelection: 'GB',
                              showFlagDialog: true,
                              comparator: (a, b) => a.name!.compareTo(b.name!),
                              dialogTextStyle: const TextStyle(color: kWhiteColor),
                              showCountryOnly: true,
                              // dropdownIcon: Icon(Lucide.chevron_down, color: kWhiteColor),
                            ),
                          ),
                          /*SizedBox(
                            height: 30.h,
                          ),
                          Text(
                            'Payment Reference',
                            style: AppStyles.labelTextStyle().copyWith(
                              color: kWhiteColor,
                              fontWeight: FontWeight.w700,
                              height: 0,
                              letterSpacing: 0.28,
                            ),
                          ),
                          SizedBox(
                            height: 12.h,
                          ),
                          Container(
                            width: 390.w,
                            height: 48.h,
                            decoration: ShapeDecoration(
                              color: kGreyContainerColor,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            ),
                            child: TextFormField(
                              controller: controller.paymentRefrenceController,
                              onChanged: (value) {
                                if (CommonCode().hasSpecialCharacters(value)) {
                                  CustomSnackbar.showSnackbar("Special characters are not allowed");
                                }
                              },
                              decoration: const InputDecoration(
                                border: InputBorder.none,
                                contentPadding: EdgeInsets.symmetric(horizontal: 16.0),
                              ),
                              style: const TextStyle(color: kPrimaryColor),
                            ),
                          ),*/
                          /*SizedBox(
                            height: 30.h,
                          ),
                          Text(
                            'Sort Code',
                            style: AppStyles.labelTextStyle().copyWith(
                              color: kWhiteColor,
                              fontWeight: FontWeight.w700,
                              height: 0,
                              letterSpacing: 0.28,
                            ),
                          ),
                          SizedBox(
                            height: 12.h,
                          ),
                          Container(
                            width: 390.w,
                            height: 48.h,
                            decoration: ShapeDecoration(
                              color: kGreyContainerColor,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            ),
                            child: TextFormField(
                              keyboardType: const TextInputType.numberWithOptions(signed: true, decimal: false),
                              controller: controller.sortCodeController,
                              inputFormatters: [
                                FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
                              ],
                              // controller: controller.paymentRefrenceController,
                              onChanged: (value) {},
                              decoration: const InputDecoration(
                                border: InputBorder.none,
                                contentPadding: EdgeInsets.symmetric(horizontal: 16.0),
                              ),
                              style: const TextStyle(color: kPrimaryColor),
                            ),
                          ),
                          SizedBox(
                            height: 30.h,
                          ),
                          Text(
                            'Bacs Code',
                            style: AppStyles.labelTextStyle().copyWith(
                              color: kWhiteColor,
                              fontWeight: FontWeight.w700,
                              height: 0,
                              letterSpacing: 0.28,
                            ),
                          ),
                          SizedBox(
                            height: 12.h,
                          ),
                          Container(
                            width: 390.w,
                            height: 48.h,
                            decoration: ShapeDecoration(
                              color: kGreyContainerColor,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            ),
                            child: TextFormField(
                              keyboardType: const TextInputType.numberWithOptions(signed: true, decimal: false),
                              controller: controller.bacsCodeController,
                              decoration: const InputDecoration(
                                border: InputBorder.none,
                                contentPadding: EdgeInsets.symmetric(horizontal: 16.0),
                              ),
                              style: const TextStyle(color: kPrimaryColor),
                            ),
                          ),*/

                          SizedBox(
                            height: 30.h,
                          ),
                          Text(
                            'Postal Code',
                            style: AppStyles.labelTextStyle().copyWith(
                              color: kWhiteColor,
                              fontWeight: FontWeight.w700,
                              height: 0,
                              letterSpacing: 0.28,
                            ),
                          ),
                          SizedBox(
                            height: 12.h,
                          ),
                          Container(
                            width: 390.w,
                            height: 48.h,
                            decoration: ShapeDecoration(
                              color: kGreyContainerColor,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            ),
                            child: TextFormField(
                              keyboardType: TextInputType.text,
                              controller: controller.postalCodeController,
                              // controller: controller.paymentRefrenceController,
                              onChanged: (value) {},
                              textInputAction: TextInputAction.next,
                              decoration: const InputDecoration(
                                border: InputBorder.none,
                                contentPadding: EdgeInsets.symmetric(horizontal: 16.0),
                              ),
                              style: const TextStyle(color: kPrimaryColor),
                            ),
                          ),
                          SizedBox(
                            height: 30.h,
                          ),
                          Text(
                            'City',
                            style: AppStyles.labelTextStyle().copyWith(
                              color: kWhiteColor,
                              fontWeight: FontWeight.w700,
                              height: 0,
                              letterSpacing: 0.28,
                            ),
                          ),
                          SizedBox(
                            height: 12.h,
                          ),
                          Container(
                            width: 390.w,
                            height: 48.h,
                            decoration: ShapeDecoration(
                              color: kGreyContainerColor,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            ),
                            child: TextFormField(
                              keyboardType: TextInputType.text,
                              controller: controller.cityController,
                              textInputAction: TextInputAction.next,
                              decoration: const InputDecoration(
                                border: InputBorder.none,
                                contentPadding: EdgeInsets.symmetric(horizontal: 16.0),
                              ),
                              style: const TextStyle(color: kPrimaryColor),
                            ),
                          ),
                          SizedBox(
                            height: 30.h,
                          ),
                          Text(
                            'Address',
                            style: AppStyles.labelTextStyle().copyWith(
                              color: kWhiteColor,
                              fontWeight: FontWeight.w700,
                              height: 0,
                              letterSpacing: 0.28,
                            ),
                          ),
                          SizedBox(
                            height: 12.h,
                          ),
                          Container(
                            width: 390.w,
                            height: 48.h,
                            decoration: ShapeDecoration(
                              color: kGreyContainerColor,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            ),
                            child: TextFormField(
                              keyboardType: TextInputType.text,
                              controller: controller.addressController,
                              decoration: const InputDecoration(
                                border: InputBorder.none,
                                contentPadding: EdgeInsets.symmetric(horizontal: 16.0),
                              ),
                              style: const TextStyle(color: kPrimaryColor),
                            ),
                          ),
                          SizedBox(
                            height: 20.h,
                          ),
                        ],
                      ),
                    )),
              ]),
            ),
          ),
          bottomNavigationBar: Container(
            margin: EdgeInsets.symmetric(vertical: Platform.isIOS ? 30 : 10.h, horizontal: 24.w),
            // padding: const EdgeInsets.all(18.0),
            child: CustomButton(
                width: Get.width,
                height: 40.h,
                title: controller.isPaymentMethodFound.isTrue ? 'Update Account' : 'Add Account',
                onPressed: () {
                  controller.addPaymentMethod();
                },
                backgroundColor:
                    // controller.isPaymentMethodSelected.value == true
                    //     ?
                    kPrimaryColor
                // : kPrimaryColor.withOpacity(0.5),
                ),
          ),
        ),
      ),
    );
  }
}
