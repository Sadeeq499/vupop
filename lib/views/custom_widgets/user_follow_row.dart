import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:socials_app/utils/app_colors.dart';
import 'package:socials_app/utils/app_styles.dart';

import '../../utils/common_code.dart';

class UserFollowRow extends StatelessWidget {
  final String name;
  final String imageUrl;
  final RxBool isFollowed;
  final VoidCallback onTap;
  final RxBool isFollowLoading;
  final String? btnText;
  final VoidCallback onBlockTap;
  final bool isShwoBlock;
  final VoidCallback onProfileTap;
  const UserFollowRow({
    super.key,
    required this.name,
    required this.imageUrl,
    required this.isFollowed,
    required this.onTap,
    required this.isFollowLoading,
    this.btnText = 'Follow',
    required this.onBlockTap,
    this.isShwoBlock = true,
    required this.onProfileTap,
  });

  @override
  Widget build(BuildContext context) {
    printLogs('UserFollowRow === $isFollowed');
    return GestureDetector(
      onTap: onProfileTap,
      child: SizedBox(
        width: Get.width,
        height: Get.height * 0.05,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            GestureDetector(
              onTap: onProfileTap,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(4.r),
                child: CommonCode().isValidURL(imageUrl) && CommonCode().isValidAWSUrl(imageUrl)
                    ? Image.network(
                        imageUrl,
                        width: 50.w,
                        height: 50.h,
                        errorBuilder: (context, error, stackTrace) {
                          return Icon(
                            Icons.person,
                            size: 50.h,
                            color: kPrimaryColor,
                          );
                        },
                      )
                    : Icon(
                        Icons.person,
                        size: 50.h,
                        color: kPrimaryColor,
                      ),
              ),
            ),
            SizedBox(width: 10.w),
            GestureDetector(
              onTap: onProfileTap,
              child: Center(
                child: Text(
                  textAlign: TextAlign.center,
                  name,
                  style: AppStyles.labelTextStyle().copyWith(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w400,
                    color: kPrimaryColor,
                  ),
                ),
              ),
            ),
            const Spacer(),
            isShwoBlock
                ? GestureDetector(
                    onTap: onBlockTap,
                    child: Container(
                      width: 82.w,
                      height: 30.h,
                      decoration: BoxDecoration(
                        color: Colors.transparent,
                        borderRadius: BorderRadius.circular(4.r),
                        border: Border.all(
                          color: kYouTubeTileColor,
                          width: 1,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          'Block',
                          style: AppStyles.labelTextStyle().copyWith(fontSize: 16.sp, color: kYouTubeTileColor),
                        ),
                      ),
                    ),
                  )
                : Container(),
            SizedBox(width: 10.w),
            Obx(
              () => isFollowLoading.isTrue
                  ? const CircularProgressIndicator()
                  : GestureDetector(
                      onTap: onTap,
                      child: !isFollowed.value
                          ? Container(
                              width: 82.w,
                              height: 30.h,
                              decoration: BoxDecoration(
                                  color: isFollowed.value ? kPrimaryColor : Colors.transparent,
                                  borderRadius: BorderRadius.circular(4.r),
                                  border: Border.all(
                                    color: isFollowed.value ? Colors.transparent : kPrimaryColor,
                                    width: 1,
                                  )),
                              child: Center(
                                child: Text(
                                  isFollowed.value ? 'UnFollow' : btnText ?? 'Follow',
                                  style: AppStyles.labelTextStyle().copyWith(fontSize: 16.sp, color: isFollowed.value ? kBlackColor : kPrimaryColor),
                                ),
                              ),
                            )
                          : Container(
                              width: 82.w,
                              height: 30.h,
                              decoration: BoxDecoration(
                                  color: isFollowed.value ? kPrimaryColor : Colors.transparent,
                                  borderRadius: BorderRadius.circular(4.r),
                                  border: Border.all(
                                    color: isFollowed.value ? Colors.transparent : kPrimaryColor,
                                    width: 1,
                                  )),
                              child: Center(
                                child: Text(
                                  btnText ?? 'UnFollow',
                                  style: AppStyles.labelTextStyle().copyWith(fontSize: 16.sp, color: kBlackColor),
                                ),
                              ),
                            )),
            )
          ],
        ),
      ),
    );
  }
}
