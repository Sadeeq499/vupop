import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:shimmer/shimmer.dart';
import 'package:socials_app/models/user_chat_model.dart';
import 'package:socials_app/services/session_services.dart';
import 'package:socials_app/utils/app_colors.dart';
import 'package:socials_app/utils/app_strings.dart';
import 'package:socials_app/views/custom_widgets/customImage.dart';
import 'package:socials_app/views/screens/chat/controller/chat_controller.dart';

import '../../../utils/app_styles.dart';
import '../../../utils/common_code.dart';
import '../../custom_widgets/custom_scaffold.dart';

class ChatScreenPrevious extends GetView<ChatScreenController> {
  const ChatScreenPrevious({super.key});

  @override
  Widget build(BuildContext context) {
    Future.microtask(() async {
      await controller.getAllchats(); // Await this call to ensure it's completed.
      controller.initializeAllMethods();
    });
    return CustomScaffold(
      className: runtimeType.toString(),
      screenName: "All Messages",
      isBackIcon: false,
      isFullBody: false,
      backIconColor: kPrimaryColor,
      appBarSize: 40,
      padding: EdgeInsets.only(top: 20.h),
      showAppBarBackButton: true,
      scaffoldKey: controller.scaffoldKeyChat,
      // leadingWidth: 30,
      // leadingWidget: GestureDetector(
      //   onTap: () {
      //     Get.back();
      //   },
      //   child: Padding(
      //     padding: EdgeInsets.only(left: 20.w),
      //     child: const Icon(
      //       Icons.arrow_back_ios,
      //       color: kPrimaryColor,
      //       size: 20,
      //     ),
      //   ),
      // ),
      onNotificationListener: (notificationInfo) {
        if (notificationInfo.runtimeType == UserScrollNotification) {
          CommonCode().removeTextFieldFocus();
        }
        return false;
      },
      gestureDetectorOnTap: CommonCode().removeTextFieldFocus,
      //TODO: Removed chat functionality as per Dave's Requirement
      /*floatingActionButton: FloatingActionButton(
        onPressed: () {
          controller.followingUsers.value = SessionService().following;
          showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              backgroundColor: kBackgroundColorTrans,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20.r),
                  topRight: Radius.circular(20.r),
                ),
              ),
              builder: (context) {
                return FractionallySizedBox(
                  heightFactor: 0.8,
                  child: SizedBox(
                    height: Get.height * 0.8,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      child: Column(
                        children: [
                          SizedBox(height: 20.h),
                          Text(
                            "Select Friend to Chat",
                            style: AppStyles.labelTextStyle().copyWith(
                              color: kPrimaryColor,
                              fontSize: 18.sp,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          SizedBox(height: 20.h),
                          CustomTextField(
                            isPassword: false,
                            hint: "Search",
                            controller: controller.searchNewChat,
                            icon: Icons.search,
                            isEdit: true,
                            onChanged: (value) {
                              controller.filterBottomSheetSearch(value);
                            },
                          ),
                          SizedBox(height: 20.h),
                          */
      /*if (SessionService().following.isEmpty)
                            Center(
                              child: Text(
                                "No Friends to Chat",
                                style: AppStyles.labelTextStyle().copyWith(
                                  color: kPrimaryColor,
                                  fontSize: 18.sp,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),*/
      /*
                          Obx(
                            () => controller.followingUsers.isEmpty
                                ? Center(
                                    child: Text(
                                      "No Friends to Chat",
                                      style: AppStyles.labelTextStyle().copyWith(
                                        color: kPrimaryColor,
                                        fontSize: 18.sp,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  )
                                : SizedBox(
                                    height: Get.height * 0.6,
                                    child: ListView.separated(
                                      shrinkWrap: true,
                                      scrollDirection: Axis.vertical,
                                      itemCount: controller.followingUsers.length,
                                      padding: EdgeInsets.symmetric(vertical: 10.h),
                                      itemBuilder: (context, index) {
                                        final user = controller.followingUsers[index];
                                        return UserFollowRow(
                                          name: user.name,
                                          imageUrl: user.image ?? "",
                                          isFollowed: false,
                                          onTap: () {
                                            controller.getChatBetweenTwoUsers(SessionService().user?.id ?? '', user.id, user.name, user.image ?? '');
                                            Get.back();
                                            Get.toNamed(kSingleChatScreenRoute);
                                          },
                                          isFollowLoading: false,
                                          btnText: 'Start Chat',
                                        );
                                      },
                                      separatorBuilder: (context, index) => SizedBox(height: 20.h),
                                    ),
                                  ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              });
        },
        backgroundColor: kPrimaryColor,
        child: const Icon(
          Icons.add,
          color: kBackgroundColor,
        ),
      ),*/
      body: SingleChildScrollView(
        child: Column(
          children: [
            /* Align(
              alignment: Alignment.centerLeft,
              child: GestureDetector(
                onTap: () {
                  Get.back();
                },
                child: Padding(
                  padding: EdgeInsets.only(left: 25.w),
                  child: const Icon(
                    Icons.arrow_back_ios,
                    color: kPrimaryColor,
                    size: 20,
                  ),
                ),
              ),
            ),
            SizedBox(height: 20.h),*/
            Container(
              width: Get.width * 0.9,
              height: 50.h,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(4.r),
                color: kGreyContainerColor,
              ),
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
                      controller: controller.searchChat,
                      autofocus: false,
                      style: AppStyles.labelTextStyle().copyWith(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w500,
                        color: kWhiteColor,
                      ),
                      onChanged: (value) {
                        controller.filterSearch(value);
                      },
                      onFieldSubmitted: (value) {
                        controller.filterSearch(value);
                      },
                      decoration: InputDecoration(
                        hintText: "Search",
                        hintStyle: AppStyles.labelTextStyle().copyWith(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w500,
                          color: kHintGreyColor,
                        ),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(vertical: 15.h),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 20.h),
            Obx(
              () => controller.isLoading.value
                  ? SizedBox(height: 66.h, width: Get.width, child: _buildHorizontalUserShimmer())
                  : _buildHorizontalUserList(controller),
            ),
            // _buildHorizontalUserList(controller),
            SizedBox(height: 20.h),
            Obx(
              () => controller.isLoading.value ? SizedBox(height: Get.height, child: _buildChatListShimmer()) : _buildChatList(controller),
            ),
            // _buildChatList(controller),
          ],
        ),
      ),
    );
  }

  Widget _buildHorizontalUserList(ChatScreenController controller) {
    return SizedBox(
      height: 66.h,
      child: Obx(
        () => controller.filteredChatUsers.isEmpty
            ? Center(
                child: Text(
                  "No Recent Chats",
                  style: AppStyles.labelTextStyle().copyWith(
                    color: kPrimaryColor,
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              )
            : ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: controller.filteredChatUsers.length,
                itemBuilder: (context, index) {
                  ChatUser user = controller.filteredChatUsers[index];
                  return Center(child: _buildUserItem(user.image ?? ''));
                },
              ),
      ),
      // StreamBuilder<List<ChatUser>>(
      //   stream: controller.recentChatController.stream,
      //   builder: (context, asyncShot) {
      //     if (asyncShot.hasData) {
      //       List<ChatUser> userList = asyncShot.data as List<ChatUser>;
      //       if (userList.isEmpty) {
      //         return const Center(
      //           child: Text("No Recent Chats"),
      //         );
      //       }

      //       return ListView.builder(
      //         scrollDirection: Axis.horizontal,
      //         itemCount: userList.length,
      //         shrinkWrap: true,
      //         itemBuilder: (context, index) {
      //           ChatUser user = userList[index];
      //           return _buildUserItem(user.image ?? '');
      //         },
      //       );
      //     }
      //     if (asyncShot.hasError) {
      //       log("error");
      //       return const Text("Error Fetching");
      //     }
      //     return const Center(
      //       child: CircularProgressIndicator(),
      //     );
      //   },
      // ),
    );
  }

  Widget _buildUserItem(String imageUrl) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 10.w),
      width: 56,
      decoration: BoxDecoration(
        border: Border.all(
          color: kPrimaryColor,
          width: 1.5,
        ),
        borderRadius: BorderRadius.circular(4.r),
      ),
      child: Padding(
        padding: const EdgeInsets.all(2.0),
        child: CachedImage(
          url: imageUrl,
          isCircle: false,
        ),
        // Image.asset(
        //   imageUrl,
        //   width: 56.w,
        //   height: 56.h,
        //   fit: BoxFit.fill,
        // ),
      ),
    );
  }

  Widget _buildChatList(ChatScreenController controller) {
    return Obx(
      () => controller.filteredChatUsers.isEmpty
          ? Center(
              child: Text(
                "No Chats",
                style: AppStyles.labelTextStyle().copyWith(
                  color: kPrimaryColor,
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w500,
                ),
              ),
            )
          : ListView.builder(
              physics: const NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              itemCount: controller.filteredChatUsers.length,
              itemBuilder: (context, index) {
                ChatUser chatItem = controller.filteredChatUsers[index];
                return _buildChatItem(chatItem);
              },
            ),
    );
    // StreamBuilder<List<ChatUser>>(
    //   stream: controller.recentChatController.stream,
    //   builder: (context, snapshot) {
    //     if (snapshot.hasData) {
    //       List<ChatUser> chatList = snapshot.data as List<ChatUser>;
    //       if (chatList.isEmpty) {
    //         return const Center(
    //           child: Text("No Chats"),
    //         );
    //       }
    //       return ListView.builder(
    //         physics: const NeverScrollableScrollPhysics(),
    //         shrinkWrap: true,
    //         itemCount: chatList.length,
    //         itemBuilder: (context, index) {
    //           ChatUser chatItem = chatList[index];
    //           return _buildChatItem(chatItem);
    //         },
    //       );
    //     } else {
    //       return const Center(
    //         child: CircularProgressIndicator(
    //           color: kPrimaryColor,
    //         ),
    //       );
    //     }
    //   },
    // );
  }

  Widget _buildChatItem(ChatUser chatItem) {
    return ListTile(
      onTap: () {
        controller.chattedUserName.value = '';
        controller.chattedUserImage.value = '';
        controller.getChatBetweenTwoUsers(SessionService().user?.id ?? '', chatItem.userId, chatItem.name, chatItem.image ?? '');
        Get.toNamed(kSingleChatScreenRoute);
      },
      contentPadding: EdgeInsets.symmetric(vertical: 8.h, horizontal: 10.w),
      leading: Container(
        width: 56,
        decoration: BoxDecoration(
          border: Border.all(
            color: kPrimaryColor,
            width: 1.5,
          ),
          borderRadius: BorderRadius.circular(4.r),
        ),
        child: Padding(
            padding: const EdgeInsets.all(2.0),
            child: CachedImage(
              url: chatItem.image ?? '',
              isCircle: false,
            )
            // Image.asset(
            //   chatItem.image ?? '',
            //   width: 56.w,
            //   height: 56.h,
            //   fit: BoxFit.fill,
            // ),
            ),
      ),
      title: Row(
        children: [
          Text(
            chatItem.name,
            style: AppStyles.labelTextStyle().copyWith(
              color: kPrimaryColor,
              fontWeight: FontWeight.w500,
              fontSize: 18.sp,
            ),
            overflow: TextOverflow.ellipsis,
          ),
          SizedBox(
            width: 5.w,
          ),
          if (chatItem.unReadMessages > 0)
            CircleAvatar(
              radius: 10.r,
              backgroundColor: kPrimaryColor,
              child: Text(
                chatItem.unReadMessages.toString(),
                style: AppStyles.labelTextStyle().copyWith(
                  color: kBlackColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 12.sp,
                ),
              ),
            ),
        ],
      ),
      subtitle: Text(
        chatItem.chat,
        style: AppStyles.labelTextStyle().copyWith(
          color: chatItem.unReadMessages > 0 ? kWhiteColor : kHintGreyColor,
          fontSize: 16.sp,
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: Text(
        CommonCode.formatDate(chatItem.date.toString()),
        style: AppStyles.labelTextStyle().copyWith(
          color: kHintGreyColor,
          fontWeight: FontWeight.w400,
          fontSize: 14.sp,
        ),
      ),
    );
  }

  Widget _buildHorizontalUserShimmer() {
    return ListView.builder(
      scrollDirection: Axis.horizontal,
      itemCount: 5,
      itemBuilder: (context, index) {
        return Shimmer.fromColors(
          baseColor: kShimmerbaseColor,
          highlightColor: kShimmerhighlightColor,
          child: Container(
            margin: EdgeInsets.symmetric(horizontal: 10.w),
            width: 56,
            decoration: BoxDecoration(
              border: Border.all(
                color: kPrimaryColor,
                width: 1.5,
              ),
              borderRadius: BorderRadius.circular(4.r),
              color: Colors.grey[300],
            ),
          ),
        );
      },
    );
  }

  Widget _buildChatListShimmer() {
    return ListView.builder(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemCount: 5,
      itemBuilder: (context, index) {
        return ListTile(
          contentPadding: EdgeInsets.symmetric(vertical: 8.h, horizontal: 10.w),
          leading: Shimmer.fromColors(
            baseColor: kShimmerbaseColor,
            highlightColor: kShimmerhighlightColor,
            child: Container(
              width: 56,
              decoration: BoxDecoration(
                border: Border.all(
                  color: kPrimaryColor,
                  width: 1.5,
                ),
                borderRadius: BorderRadius.circular(4.r),
              ),
              child: Padding(
                padding: const EdgeInsets.all(2.0),
                child: CachedImage(
                  url: '',
                  isCircle: false,
                ),
              ),
            ),
          ),
          title: Shimmer.fromColors(
            baseColor: kShimmerbaseColor,
            highlightColor: kShimmerhighlightColor,
            child: Container(
              width: 100.w,
              height: 10.h,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(4.r),
              ),
            ),
          ),
          subtitle: Shimmer.fromColors(
            baseColor: kShimmerbaseColor,
            highlightColor: kShimmerhighlightColor,
            child: Container(
              width: 60.w,
              height: 08.h,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(4.r),
              ),
            ),
          ),
          trailing: Shimmer.fromColors(
            baseColor: kShimmerbaseColor,
            highlightColor: kShimmerhighlightColor,
            child: Container(
              width: 100.w,
              height: 12.h,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(4.r),
              ),
            ),
          ),
        );
      },
    );
  }
}
