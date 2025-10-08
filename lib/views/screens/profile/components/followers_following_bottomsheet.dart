import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:socials_app/models/usermodel.dart';
import 'package:socials_app/services/custom_snackbar.dart';
import 'package:socials_app/services/session_services.dart';
import 'package:socials_app/utils/app_dialogs.dart';
import 'package:socials_app/utils/app_styles.dart';
import 'package:socials_app/views/custom_widgets/custom_textfield.dart';
import 'package:socials_app/views/custom_widgets/user_follow_row.dart';
import 'package:socials_app/views/screens/home/components/reasons_bottom_modal.dart';
import 'package:socials_app/views/screens/profile/controller/profile_controller.dart';

import '../../../../utils/common_code.dart';

class FollowersFollowingBottomSheet extends StatelessWidget {
  const FollowersFollowingBottomSheet({
    super.key,
    required this.controller,
    required this.isFollowersSheet,
  });

  final ProfileScreenController controller;
  final bool isFollowersSheet;

  @override
  Widget build(BuildContext context) {
    return FractionallySizedBox(
      heightFactor: 0.7,
      child: SizedBox(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 15.w, vertical: 15.h),
          child: Obx(
            () => controller.isFollowersUsersLoading.value
                ? const Center(child: CircularProgressIndicator())
                : Column(
                    children: [
                      Center(
                        child: Text(
                          isFollowersSheet ? 'Followers' : 'Followings',
                          style: AppStyles.labelTextStyle().copyWith(
                            color: Colors.white,
                            fontSize: 18.sp,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      SizedBox(height: 20.h),
                      CustomTextField(
                        isPassword: false,
                        hint: "Search",
                        controller: controller.searchController,
                        icon: Icons.search,
                        onChanged: (value) {
                          // controller
                          //     .filterBottomSheetSearch(
                          //         value);
                        },
                      ),
                      SizedBox(height: 20.h),
                      Expanded(
                        child: Obx(
                          () => isFollowersSheet && controller.followersUsers.isEmpty
                              ? Center(
                                  child: Text(
                                    'No followers found',
                                    style: AppStyles.labelTextStyle().copyWith(
                                      color: Colors.white,
                                      fontSize: 18.sp,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                )
                              : isFollowersSheet && controller.followingUsers.isEmpty
                                  ? Center(
                                      child: Text(
                                        'No followings found',
                                        style: AppStyles.labelTextStyle().copyWith(
                                          color: Colors.white,
                                          fontSize: 18.sp,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    )
                                  : ListView.builder(
                                      itemCount: isFollowersSheet ? controller.followersUsers.length : controller.followingUsers.length,
                                      itemBuilder: (context, index) {
                                        UserDetailModel user;
                                        bool isFollowed = false;
                                        if (isFollowersSheet) {
                                          user = controller.followersUsers[index];
                                          isFollowed = controller.followersUsers[index].followers.contains(SessionService().user?.id);
                                        } else {
                                          user = controller.followingUsers[index];
                                          isFollowed = SessionService().isFollowingById(user.id);
                                          // isFollowed = controller.followingUsers[index].followers.contains(SessionService().user?.id);
                                        }
                                        // Get the loading state for this specific user from the map
                                        // bool isLoading = controller.followLoadingMap[user.id] ?? false;
                                        return Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: UserFollowRow(
                                            name: user.name,
                                            imageUrl: user.image ?? '',
                                            isFollowed: isFollowed.obs,
                                            isFollowLoading: controller.followLoadingMap[user.id] ?? false.obs, // Pass user-specific loading state
                                            isShwoBlock: true,
                                            btnText: isFollowed ? 'UnFollow' : 'Follow',
                                            onTap: () {
                                              controller.updateFollowStatus(followedUserId: user.id, index: index);
                                            },
                                            onProfileTap: () {
                                              Get.back();
                                              controller.onOtherUserView(user.id).then((value) {});
                                            },
                                            onBlockTap: () {
                                              printLogs('on reasons lst === ${controller.blockingReasons}');
                                              showDialog(
                                                  context: context,
                                                  builder: (context) => Obx(
                                                        () => ReasonBottomSheet(
                                                          titleText: 'Block User',
                                                          reasons: controller.blockingReasons.value,
                                                          onCloseButton: () {
                                                            controller.selectedReason.value = 'Select Reason';
                                                            Get.back();
                                                          },
                                                          onButtonTap: () {
                                                            if (controller.selectedReason.value != "Select Reason") {
                                                              AppDialogs().showBlockUserConfirmationDialog(onPressed: () async {
                                                                Get.back();
                                                                Navigator.pop(context);
                                                                await controller
                                                                    .blockUser(blockedUserId: user.id, reason: controller.selectedReason.value)
                                                                    .then((value) {
                                                                  Navigator.pop(context);
                                                                });
                                                              });
                                                            } else {
                                                              CustomSnackbar.showSnackbar("Select reason");
                                                            }
                                                          },
                                                          onChange: controller.onReasonDropDownChange,
                                                          selectedReason: controller.selectedReason.value,
                                                          btnText: 'Block',
                                                        ),
                                                      ));
                                            },
                                          ),
                                        );
                                      },
                                    ),
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}
