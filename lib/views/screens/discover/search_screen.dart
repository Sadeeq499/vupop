import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:socials_app/utils/app_colors.dart';
import 'package:socials_app/utils/app_images.dart';
import 'package:socials_app/views/screens/discover/controller/discover_controller.dart';

import '../../../utils/app_strings.dart';
import '../../../utils/app_styles.dart';
import '../../../utils/common_code.dart';
import '../../custom_widgets/custom_scaffold.dart';

class SearchScreen extends GetView<DiscoverController> {
  const SearchScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomScaffold(
      className: runtimeType.toString(),
      screenName: "",
      isBackIcon: false,
      isFullBody: false,
      appBarSize: 0,
      showAppBarBackButton: false,
      scaffoldKey: controller.scaffoldKeySearch,
      onNotificationListener: (notificationInfo) {
        if (notificationInfo.runtimeType == UserScrollNotification) {
          CommonCode().removeTextFieldFocus();
        }
        return false;
      },
      padding: EdgeInsets.only(left: 15.w),
      gestureDetectorOnTap: CommonCode().removeTextFieldFocus,
      body: SingleChildScrollView(
        child: Column(
          children: [
            Row(
              children: [
                GestureDetector(
                  onTap: () {
                    Get.back();
                  },
                  child: const Icon(
                    Icons.keyboard_arrow_left,
                    color: kPrimaryColor,
                    size: 40,
                  ),
                ),
                Container(
                  width: Get.width * 0.83,
                  height: 50.h,
                  decoration: BoxDecoration(borderRadius: BorderRadius.circular(4.r), color: kGreyContainerColor),
                  child: Row(
                    children: [
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 10.w),
                        child: const Icon(
                          Icons.search,
                          color: kHintGreyColor,
                          size: 25,
                        ),
                      ),
                      Expanded(
                        child: TextFormField(
                          controller: controller.search,
                          autofocus: false,
                          style: AppStyles.labelTextStyle().copyWith(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w500,
                            color: kWhiteColor,
                          ),
                          onChanged: (value) {
                            controller.filterSearch(value);
                          },
                          decoration: InputDecoration(
                            hintText: "Search for friends, broadcasters or hashtags",
                            hintStyle: AppStyles.labelTextStyle().copyWith(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w500,
                              color: kHintGreyColor,
                            ),
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.symmetric(vertical: 15.h),
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          controller.search.clear();
                        },
                        child: Padding(
                          padding: EdgeInsets.only(right: 10.w),
                          child: const Icon(
                            Icons.close,
                            color: kPrimaryColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 55.h),
            Container(
              height: Get.height,
              width: Get.width,
              padding: EdgeInsets.only(left: 10.w, right: 15.w),
              child: Obx(() => ListView.builder(
                    itemCount: controller.filteredSearchList.length,
                    itemBuilder: (context, index) {
                      final search = controller.filteredSearchList[index];
                      return Container(
                        height: 70.h,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            GestureDetector(
                              onTap: () {
                                Get.toNamed(kFollowersProfileScreen, arguments: search.userId);
                              },
                              child: Row(
                                children: [
                                  ClipRRect(
                                      borderRadius: BorderRadius.circular(4.r),
                                      child: Image.network(
                                        search.imageUrl,
                                        width: 50.w,
                                        height: 50.h,
                                        errorBuilder: (context, error, stackTrace) {
                                          return Image.asset(
                                            kdummyPerson,
                                            width: 50.w,
                                            height: 50.h,
                                          );
                                        },
                                      )),
                                  SizedBox(
                                    width: 15.w,
                                  ),
                                  Column(
                                    mainAxisSize: MainAxisSize.min,
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        search.name,
                                        style: AppStyles.labelTextStyle().copyWith(
                                          fontSize: 16.sp,
                                          color: kGreyRecentSearch,
                                        ),
                                      ),
                                      Text(
                                        search.followers,
                                        style: AppStyles.labelTextStyle().copyWith(
                                          fontSize: 10.sp,
                                          color: kGreyRecentSearch,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            GestureDetector(
                              onTap: () {
                                controller.toggleFollowStatus(index);
                              },
                              child: Container(
                                width: search.isFollowed ? 82.w : 65.w,
                                height: 30.h,
                                decoration: BoxDecoration(
                                    color: search.isFollowed ? kPrimaryColor : Colors.transparent,
                                    borderRadius: BorderRadius.circular(4.r),
                                    border:
                                        Border.all(color: search.isFollowed ? Colors.transparent : kPrimaryColor, width: search.isFollowed ? 0 : 1)),
                                child: Center(
                                  child: Text(
                                    search.isFollowed ? 'UnFollow' : 'Follow',
                                    style:
                                        AppStyles.labelTextStyle().copyWith(fontSize: 16.sp, color: search.isFollowed ? kBlackColor : kPrimaryColor),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  )),
            ),
          ],
        ),
      ),
    );
  }
}
