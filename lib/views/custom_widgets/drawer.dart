import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:socials_app/repositories/auth_repo.dart';
import 'package:socials_app/services/custom_snackbar.dart';
import 'package:socials_app/services/session_services.dart';
import 'package:socials_app/utils/app_colors.dart';
import 'package:socials_app/utils/app_dialogs.dart';
import 'package:socials_app/utils/app_strings.dart';
import 'package:socials_app/utils/app_styles.dart';

import '../../utils/app_images.dart';
import '../../utils/common_code.dart';

class ProfileDrawer extends StatelessWidget {
  ProfileDrawer({super.key});
  RxBool isLoading = false.obs;
  @override
  Widget build(BuildContext context) {
    return Obx(
      () => ModalProgressHUD(
        inAsyncCall: isLoading.value,
        child: Drawer(
            backgroundColor: kBlackColor,
            child: Padding(
              padding: EdgeInsets.only(left: 30, top: 50.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
                    },
                    child: const Icon(
                      Icons.close,
                      color: kPrimaryColor,
                    ),
                  ),
                  SizedBox(
                    height: 80.h,
                  ),
                  GestureDetector(
                    onTap: () {
                      printLogs('Edit Profile');
                      Get.toNamed(kEditProfileRoute);
                    },
                    child: Row(
                      children: [
                        Image.asset(
                          kUserProfileIcon,
                          scale: 5,
                        ),
                        SizedBox(
                          width: 20.w,
                        ),
                        Text(
                          'Edit Profile ',
                          style: AppStyles.labelTextStyle().copyWith(
                            color: kPrimaryColor,
                            fontSize: 16,
                            height: 0,
                          ),
                        )
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 40.h,
                  ),
                  GestureDetector(
                    onTap: () {
                      Get.toNamed(kArchivePostsScreen);
                    },
                    child: Row(
                      children: [
                        /*Image.asset(
                          kWalletIcon,
                          scale: 5,
                        ),*/
                        Icon(
                          Icons.archive_outlined,
                          size: 24,
                          color: kPrimaryColor,
                        ),
                        SizedBox(
                          width: 20.w,
                        ),
                        Text(
                          'Archived Post ',
                          style: AppStyles.labelTextStyle().copyWith(
                            color: kPrimaryColor,
                            fontSize: 16,
                            height: 0,
                          ),
                        )
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 40.h,
                  ),
                  GestureDetector(
                    onTap: () {
                      CustomSnackbar.showSnackbar("Coming Soon");
                      // Get.toNamed(kSocialWalletRoute);
                      // Get.find<BottomBarController>().selectedIndex.value = 3;
                    },
                    child: Row(
                      children: [
                        Image.asset(
                          kManageSubscriptionIcon,
                          scale: 5,
                        ),
                        SizedBox(
                          width: 20.w,
                        ),
                        Text(
                          'Manage Subscription',
                          style: AppStyles.labelTextStyle().copyWith(
                            color: kPrimaryColor,
                            fontSize: 16,
                            height: 0,
                          ),
                        )
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 40.h,
                  ),
                  /*GestureDetector(
                    onTap: () {
                      Get.toNamed(kRequestPaymentRoute);
                    },
                    child: Row(
                      children: [
                        Image.asset(
                          kRequestPaymentIcon,
                          scale: 5,
                        ),
                        SizedBox(
                          width: 20.w,
                        ),
                        Text(
                          'Request Withdrawal ',
                          style: AppStyles.labelTextStyle().copyWith(
                            color: kPrimaryColor,
                            fontSize: 16,
                            height: 0,
                          ),
                        )
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 40,
                  ),*/
                  GestureDetector(
                    onTap: () {
                      Get.toNamed(kAccountDetailsRoute);
                    },
                    child: Row(
                      children: [
                        Image.asset(
                          kBankIcon,
                          scale: 1,
                        ),
                        SizedBox(
                          width: 20.w,
                        ),
                        Text(
                          'Bank Details',
                          style: AppStyles.labelTextStyle().copyWith(
                            color: kPrimaryColor,
                            fontSize: 16,
                            height: 0,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 40.h,
                  ),
                  GestureDetector(
                    onTap: () {
                      Get.toNamed(kHelpAndSupportRoute);
                    },
                    child: Row(
                      children: [
                        Image.asset(
                          kSupportIcon,
                          scale: 5,
                        ),
                        SizedBox(
                          width: 20.w,
                        ),
                        Text(
                          'Help and Support',
                          style: AppStyles.labelTextStyle().copyWith(
                            color: kPrimaryColor,
                            fontSize: 16,
                            height: 0,
                          ),
                        )
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 90.h,
                  ),
                  GestureDetector(
                    onTap: () {
                      CommonCode.showLogoutWarningDialog(onLogoutPressed: () {
                        AuthRepo().logout();
                      });
                    },
                    child: Row(children: [
                      Image.asset(
                        kLogoutIcon,
                        scale: 5,
                      ),
                      SizedBox(
                        width: 20.w,
                      ),
                      Text(
                        'Log Out',
                        style: AppStyles.labelTextStyle().copyWith(
                          color: kPrimaryColor,
                          fontSize: 16,
                          height: 0,
                        ),
                      )
                    ]),
                  ),
                  SizedBox(
                    height: 90.h,
                  ),
                  GestureDetector(
                    onTap: () {
                      AppDialogs().showDeleteAccountDialog(onPressed: () async {
                        Get.back();
                        isLoading.value = true;
                        if (await AuthRepo().deleteUserAccount(userId: SessionService().user!.id)) {
                          AuthRepo().logout();
                          isLoading.value = false;
                          CustomSnackbar.showSnackbar("Account deleted successfully");
                        } else {
                          isLoading.value = false;
                          CustomSnackbar.showSnackbar("Error occurred while deleting the account, please try again");
                        }
                      });
                    },
                    child: Padding(
                      padding: EdgeInsets.only(right: 24),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Container(
                          width: Get.width,
                          padding: EdgeInsets.symmetric(horizontal: 8, vertical: 16),
                          margin: EdgeInsets.only(right: 0),
                          color: kOverdueRedColor.withOpacity(0.80),
                          child: Text(
                            'Delete Account',
                            textAlign: TextAlign.center,
                            style: AppStyles.labelTextStyle().copyWith(
                              color: kWhiteColor,
                              fontSize: 16,
                              height: 0,
                            ),
                          ),
                        ),
                      ),
                    ),
                  )
                ],
              ),
            )),
      ),
    );
  }
}
