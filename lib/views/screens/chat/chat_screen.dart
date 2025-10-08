import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:shimmer/shimmer.dart';
import 'package:socials_app/models/user_chat_model.dart';
import 'package:socials_app/services/session_services.dart';
import 'package:socials_app/utils/app_colors.dart';
import 'package:socials_app/utils/app_strings.dart';
import 'package:socials_app/views/custom_widgets/customImage.dart';
import 'package:socials_app/views/screens/chat/controller/chat_controller.dart';

import '../../../models/community_all_chats_model.dart';
import '../../../utils/app_styles.dart';
import '../../../utils/common_code.dart';
import '../../custom_widgets/custom_scaffold.dart';

class ChatScreen extends GetView<ChatScreenController> {
  const ChatScreen({super.key});

  @override
  Widget build(BuildContext context) {
    Future.microtask(() async {
      // await controller.getAllchats(); // Await this call to ensure it's completed.
      await controller.getAllCommunityChats(); // Await this call to ensure it's completed.
      controller.initializeAllMethods();
    });
    return Obx(() => ModalProgressHUD(
          inAsyncCall: controller.isLoadingFullScreen.value,
          child: DefaultTabController(
            length: 1,
            child: CustomScaffold(
              className: runtimeType.toString(),
              screenName: "All Messages",
              isBackIcon: false,
              isFullBody: false,
              backIconColor: kPrimaryColor,
              appBarSize: 40,
              padding: EdgeInsets.only(top: 20.h),
              showAppBarBackButton: false,
              leadingWidth: 0,
              scaffoldKey: controller.scaffoldKeyChat,
              onNotificationListener: (notificationInfo) {
                if (notificationInfo.runtimeType == UserScrollNotification) {
                  CommonCode().removeTextFieldFocus();
                }
                return false;
              },
              gestureDetectorOnTap: CommonCode().removeTextFieldFocus,
              body: Column(
                children: [
                  // Search Bar
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
                              controller.filterSearchCommunity(value);
                            },
                            decoration: InputDecoration(
                              hintText: "Search Chat",
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

                  // Custom Tab Bar
                  Container(
                    margin: EdgeInsets.symmetric(horizontal: Get.width * 0.05),
                    decoration: BoxDecoration(
                      color: kGreyContainerColor,
                      borderRadius: BorderRadius.circular(4.r),
                    ),
                    child: TabBar(
                      indicatorSize: TabBarIndicatorSize.tab,
                      indicatorColor: kPrimaryColor,
                      labelColor: kPrimaryColor,
                      unselectedLabelColor: kHintGreyColor,
                      labelStyle: AppStyles.labelTextStyle().copyWith(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w500,
                      ),
                      tabs: const [
                        // Tab(text: "General"),
                        Tab(text: "Community"),
                      ],
                    ),
                  ),

                  SizedBox(height: 20.h),

                  // Tab Bar View
                  Expanded(
                    child: TabBarView(
                      children: [
                        // General Chats Tab
                        /* SingleChildScrollView(
                          child: Column(
                            children: [
                              Obx(
                                () => controller.isLoading.value
                                    ? SizedBox(height: 66.h, width: Get.width, child: _buildHorizontalUserShimmer())
                                    : _buildHorizontalUserList(controller),
                              ),
                              SizedBox(height: 20.h),
                              Obx(
                                () => controller.isLoading.value
                                    ? SizedBox(height: Get.height * 0.6, child: _buildChatListShimmer())
                                    : _buildChatList(controller),
                              ),
                            ],
                          ),
                        ),*/

                        // Community Chats Tab
                        SingleChildScrollView(
                          child: Obx(
                            () => controller.isCommunityChatsLoading.isTrue
                                ? SizedBox(height: Get.height * 0.6, child: _buildChatListShimmer())
                                : _buildCommunityList(controller),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ));
  }

  // Add new method for community list
  Widget _buildCommunityList(ChatScreenController controller) {
    printLogs('============controller.filteredCommunityChats.isEmpty ${controller.filteredCommunityChats.isEmpty}');
    return controller.isCommunityChatsLoading.isFalse && controller.filteredCommunityChats.isEmpty
        ? Center(
            child: Text(
              "No community chats found",
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
            itemCount: controller.filteredCommunityChats.length,
            itemBuilder: (context, index) {
              final community = controller.filteredCommunityChats[index];
              return _buildCommunityItem(community);
            },
          );
  }

  Widget _buildCommunityItem(CommunityAllChatsModelData community) {
    return ListTile(
      onTap: () {
        controller.onCommunityTap(notification: community);
      },
      contentPadding: EdgeInsets.symmetric(vertical: 8.h, horizontal: 16.w),
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
            url: community.image ?? '',
            isCircle: false,
          ),
        ),
      ),
      title: Row(
        children: [
          Flexible(
            child: Text(
              community.name ?? '',
              style: AppStyles.labelTextStyle().copyWith(
                color: kPrimaryColor,
                fontWeight: FontWeight.w500,
                fontSize: 18.sp,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (community.members != null && community.members!.isNotEmpty)
            Container(
                padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                margin: EdgeInsets.only(left: 8.w),
                decoration: BoxDecoration(
                  color: kPrimaryColor,
                  borderRadius: BorderRadius.circular(100.r),
                ),
                constraints: BoxConstraints(minWidth: 24.w),
                child: RichText(
                    textAlign: TextAlign.center,
                    text: TextSpan(children: [
                      WidgetSpan(
                          child: Icon(
                        size: 12,
                        Icons.person,
                        color: kBlackColor,
                      )),
                      TextSpan(
                        text: community.members!.length > 99 ? '99+' : community.members?.length.toString().padLeft(2, "0"),
                        style: AppStyles.labelTextStyle().copyWith(
                          color: kBlackColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 12.sp,
                        ),
                      )
                    ]))),
        ],
      ),
      /*Row(
        children: [
          Expanded(
            child: Text(
              community.name ?? '',
              style: AppStyles.labelTextStyle().copyWith(
                color: kPrimaryColor,
                fontWeight: FontWeight.w500,
                fontSize: 18.sp,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (community.unreadCount != null && community.unreadCount! > 0)
            Container(
              margin: EdgeInsets.only(left: 8.w),
              child: CircleAvatar(
                radius: 10.r,
                backgroundColor: kPrimaryColor,
                child: Text(
                  community.unreadCount.toString(),
                  style: AppStyles.labelTextStyle().copyWith(
                    color: kBlackColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 12.sp,
                  ),
                ),
              ),
            ),
        ],
      ),*/
      subtitle: Text(
        community.description ?? '',
        style: AppStyles.labelTextStyle().copyWith(
          color: community.members != null && community.members!.isNotEmpty ? kWhiteColor : kHintGreyColor,
          fontSize: 16.sp,
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: Text(
        CommonCode.formatDateToDayAndMonth(community.date.toString()),
        style: AppStyles.labelTextStyle().copyWith(
          color: kHintGreyColor,
          fontWeight: FontWeight.w400,
          fontSize: 14.sp,
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
            )),
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
