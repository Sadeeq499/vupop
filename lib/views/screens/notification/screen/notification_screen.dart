import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:socials_app/models/community_chat_noification_model.dart';
import 'package:socials_app/models/usermodel.dart';
import 'package:socials_app/repositories/profile_repo.dart';
import 'package:socials_app/utils/app_colors.dart';
import 'package:socials_app/utils/app_images.dart';
import 'package:socials_app/utils/app_styles.dart';
import 'package:socials_app/views/custom_widgets/customImage.dart';
import 'package:socials_app/views/custom_widgets/custom_scaffold.dart';
import 'package:socials_app/views/screens/notification/components/join_chat_dialog_widget.dart';
import 'package:socials_app/views/screens/notification/controller/notification_controller.dart';

import '../../../custom_widgets/custom_shimmer_image_widget.dart';
import '../components/custom_payout_notification_card.dart';

class NotificationScreen extends GetView<NotificationsController> {
  const NotificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    Future.microtask(() async {
      await controller.getAllNotifications();
      controller.getAllCommunityChatNotifications();
      controller.currentPostsPageNo.value = 1;
      controller.getAllExportPostNotifications();
    });
    return CustomScaffold(
      className: runtimeType.toString(),
      screenName: "Notifications",
      isBackIcon: true,
      isFullBody: false,
      appBarSize: 40,
      showAppBarBackButton: true,
      scaffoldKey: controller.notificationKey,
      body: DefaultTabController(
        length: 3,
        child: Column(
          children: [
            Container(
              color: Colors.black,
              child: TabBar(
                tabs: const [
                  Tab(text: 'General'),
                  Tab(text: 'Posts'),
                  Tab(text: 'Community'),
                ],
                indicatorColor: kPrimaryColor,
                labelColor: kPrimaryColor,
                labelPadding: EdgeInsets.symmetric(horizontal: 4),
                // padding: EdgeInsets.symmetric(horizontal: 16),
                // tabAlignment: TabAlignment.start,
                // isScrollable: true,
                unselectedLabelStyle: AppStyles.labelTextStyle().copyWith(fontSize: 18, color: kWhiteColor),
                labelStyle: AppStyles.labelTextStyle().copyWith(fontSize: 18, color: kPrimaryColor),
                unselectedLabelColor: Colors.grey,
              ),
            ),
            Expanded(
              child: TabBarView(
                children: [
                  _buildGeneralTab(),
                  Container(margin: EdgeInsets.only(top: 8), child: _buildPostTab()),
                  Container(margin: EdgeInsets.only(top: 16), child: _buildCommunityTab()),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGeneralTab() {
    return Obx(
      () => ModalProgressHUD(
          inAsyncCall: controller.isLoading.value,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),
                CustomPayoutNotificationCard(
                  controller: controller,
                ),
                Obx(
                  () => controller.notifications.isEmpty
                      ? const Center(
                          child: Text(
                            'No notifications found',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                            ),
                          ),
                        )
                      : ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: controller.notifications.length,
                          itemBuilder: (context, index) {
                            final notifi = controller.notifications[index];
                            if (notifi.isAppNoti) {
                              return Padding(
                                padding: const EdgeInsets.only(top: 30),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 43,
                                      height: 43,
                                      clipBehavior: Clip.antiAlias,
                                      decoration: ShapeDecoration(
                                        color: Colors.white,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(58),
                                        ),
                                      ),
                                      child: FutureBuilder(
                                        future: ProfileRepo().getUserProfile(userId: notifi.senderBroadcaster),
                                        builder: (context, snapshot) {
                                          if (snapshot.connectionState == ConnectionState.waiting) {
                                            return const CircularProgressIndicator();
                                          }
                                          if (snapshot != null && snapshot.data != null) {
                                            final user = snapshot.data as UserDetailModel;
                                            return CachedImage(
                                              url: user.image ?? '',
                                              width: 43,
                                              height: 43,
                                              fit: BoxFit.fill,
                                            );
                                          } else {
                                            return CachedImage(
                                              url: '',
                                              width: 43,
                                              height: 43,
                                              fit: BoxFit.fill,
                                            );
                                          }
                                        },
                                      ),
                                    ),
                                    const SizedBox(width: 30),
                                    Expanded(
                                      child: Text(
                                        "${notifi.title}\n${notifi.message}",
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                          letterSpacing: 0.64,
                                        ),
                                      ),
                                    ),
                                    Container(
                                      width: 67,
                                      height: 67,
                                      decoration: ShapeDecoration(
                                        color: Colors.white,
                                        image: DecorationImage(
                                          image: AssetImage(kDummyImage),
                                          fit: BoxFit.fill,
                                        ),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            } else {
                              return const SizedBox.shrink();
                            }
                          },
                        ),
                ),
              ],
            ),
          )),
    );
  }

  Widget _buildPostTab() {
    return Obx(
      () => ModalProgressHUD(
          inAsyncCall: controller.isLoadingPostNotifications.value,
          child: SingleChildScrollView(
            controller: controller.scrollController,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),
                CustomPayoutNotificationCard(
                  controller: controller,
                ),
                Obx(
                  () => controller.postsNotifications.isEmpty
                      ? const Center(
                          child: Text(
                            'No notifications found',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                            ),
                          ),
                        )
                      : ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: controller.postsNotifications.length,
                          itemBuilder: (context, index) {
                            final notifi = controller.postsNotifications[index];

                            return Padding(
                              padding: const EdgeInsets.only(top: 30),
                              child: Row(
                                children: [
                                  Container(
                                      width: 43,
                                      height: 43,
                                      clipBehavior: Clip.antiAlias,
                                      decoration: ShapeDecoration(
                                        color: Colors.white,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(58),
                                        ),
                                      ),
                                      child: CachedImage(
                                        url: notifi.sender?.image ?? '',
                                        width: 43,
                                        height: 43,
                                        fit: BoxFit.fill,
                                      )),
                                  const SizedBox(width: 30),
                                  Expanded(
                                    child: Text(
                                      "${notifi.message}",
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                        letterSpacing: 0.64,
                                      ),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Container(
                                      width: 100,
                                      height: 100,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(8),
                                        border: Border.all(color: kGreyContainerColor, width: 1),
                                        boxShadow: [
                                          BoxShadow(
                                            color: kGreyContainerColor2.withOpacity(0.5),
                                            spreadRadius: 1,
                                            blurRadius: 5,
                                            offset: const Offset(0, 3),
                                          ),
                                        ],
                                      ),
                                      child: SizedBox(
                                        height: 100,
                                        width: 100,
                                        child: Image.network(
                                          notifi.post?.thumbnail ?? '',
                                          fit: BoxFit.contain,
                                          loadingBuilder: (context, child, loadingProgress) {
                                            if (loadingProgress == null) {
                                              return SizedBox(
                                                width: 100,
                                                height: 100,
                                                child: child,
                                              );
                                            } else {
                                              return CustomImageShimmer(
                                                height: 100,
                                                width: 100,
                                              );
                                            }
                                          },
                                        ),
                                      ),
                                    ),
                                  ),
                                  /*Container(
                                    width: 67,
                                    height: 67,
                                    decoration: ShapeDecoration(
                                      color: Colors.white,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                    ),
                                    child: CachedImage(
                                      url: notifi.post?.thumbnail ?? '',
                                      width: 69,
                                      height: 69,
                                      isCircle: false,
                                      fit: BoxFit.fill,
                                      errorImage: kDummyImage,
                                    ),
                                  ),*/
                                ],
                              ),
                            );
                          },
                        ),
                ),
                Obx(() => controller.isLoadingMorePostNotifications.value
                    ? Center(
                        child: const Padding(
                          padding: EdgeInsets.only(top: 8.0, bottom: 24),
                          child: CircularProgressIndicator(),
                        ),
                      )
                    : const SizedBox.shrink()),
              ],
            ),
          )),
    );
  }

  Widget _buildCommunityTab() {
    return Obx(
      () => ModalProgressHUD(
        inAsyncCall: controller.isLoadingCommunityChats.value,
        child: Obx(
          () => controller.communityNotifications.isEmpty
              ? const Center(
                  child: Text(
                    'No community notifications',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                    ),
                  ),
                )
              : SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CustomPayoutNotificationCard(
                        controller: controller,
                      ),
                      // Active Notifications
                      _buildNotificationsList(
                        notifications: controller.communityNotifications
                            .where((notification) => notification.endTime == null || !notification.endTime!.difference(DateTime.now()).isNegative)
                            .toList(),
                        isExpired: false,
                      ),

                      // Expired Header
                      if (controller.communityNotifications
                          .any((notification) => notification.endTime != null && notification.endTime!.difference(DateTime.now()).isNegative))
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                          child: Text(
                            'EXPIRED',
                            style: TextStyle(
                              color: kWhiteColor,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),

                      // Expired Notifications
                      _buildNotificationsList(
                        notifications: controller.communityNotifications
                            .where((notification) => notification.endTime != null && notification.endTime!.difference(DateTime.now()).isNegative)
                            .toList(),
                        isExpired: true,
                      ),
                    ],
                  ),
                ),
        ),
      ),
    );
  }

  Widget _buildNotificationsList({
    required List<ChatNotification> notifications,
    required bool isExpired,
  }) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: notifications.length,
      itemBuilder: (context, index) {
        final notification = notifications[index];
        return Container(
          margin: const EdgeInsets.only(top: 8, bottom: 8, right: 8, left: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                decoration: BoxDecoration(
                  color: Colors.grey[900],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ListTile(
                  contentPadding: EdgeInsets.only(top: 5, bottom: 5, right: 8, left: 8),
                  leading: CircleAvatar(
                    backgroundImage: notification.image != null && notification.image!.isNotEmpty
                        ? NetworkImage(notification.image!)
                        : AssetImage(kProfileImage) as ImageProvider,
                  ),
                  title: RichText(
                    text: TextSpan(children: [
                      WidgetSpan(alignment: PlaceholderAlignment.middle, child: Image.asset(kChatIcon, color: kWhiteColor, height: 18, width: 20)),
                      TextSpan(
                        text: " ${notification.message}" ?? "",
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                        ),
                      ),
                    ]),
                  ),
                  trailing: isExpired
                      ? const Text(
                          'Expired',
                          style: TextStyle(
                            color: Colors.grey,
                            fontSize: 12,
                          ),
                        )
                      : GestureDetector(
                          onTap: () {
                            Get.dialog(
                              JoinChatDialog(
                                isLoading: controller.isJoinCommunityLoading,
                                btnLabel: 'Join Chat',
                                titleText: notification.communityName!.toUpperCase(),
                                endTime: notification.endTime,
                                onTap: () {
                                  controller.joinCommunityChat(notification: notification);
                                },
                                description: notification.communityDescription ?? "No Description Found",
                                // '🏆 The ultimate showdown is here! Join the live chat for ${notification.chatTopic} and experience the action with fellow fans—debate, celebrate, and share every moment! 🔥💬',
                                notification: notification,
                              ),
                              barrierColor: Colors.black.withOpacity(0.55),
                            );
                          },
                          child: Container(
                            padding: EdgeInsets.symmetric(vertical: 5, horizontal: 8),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              color: kPrimaryColor,
                            ),
                            child: const Icon(
                              Icons.arrow_forward_ios,
                              color: kBlackColor,
                              size: 24,
                            ),
                          ),
                        ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

// // ignore_for_file: avoid_unnecessary_containers
//
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
// import 'package:socials_app/models/usermodel.dart';
// import 'package:socials_app/repositories/profile_repo.dart';
// import 'package:socials_app/utils/app_images.dart';
// import 'package:socials_app/views/custom_widgets/customImage.dart';
// import 'package:socials_app/views/custom_widgets/custom_scaffold.dart';
// import 'package:socials_app/views/screens/notification/controller/notification_controller.dart';
//
// class NotificationScreen extends GetView<NotificationsController> {
//   const NotificationScreen({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     return Obx(
//       () => ModalProgressHUD(
//         inAsyncCall: controller.isLoading.value,
//         child: CustomScaffold(
//           className: runtimeType.toString(),
//           screenName: "Notifications",
//           isBackIcon: true,
//           isFullBody: false,
//           appBarSize: 40,
//           showAppBarBackButton: true,
//           scaffoldKey: controller.notificationKey,
//           body: SingleChildScrollView(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 const SizedBox(height: 20),
//                 Obx(
//                   () => controller.notifications.isEmpty
//                       ? const Center(
//                           child: Text(
//                             'No notifications found',
//                             style: TextStyle(
//                               color: Colors.white,
//                               fontSize: 16,
//                             ),
//                           ),
//                         )
//                       : ListView.builder(
//                           shrinkWrap: true,
//                           itemCount: controller.notifications.length,
//                           itemBuilder: (context, index) {
//                             final notifi = controller.notifications[index];
//                             if (notifi.isAppNoti) {
//                               return Padding(
//                                 padding: const EdgeInsets.only(top: 30),
//                                 child: Row(
//                                   children: [
//                                     Container(
//                                       width: 43,
//                                       height: 43,
//                                       clipBehavior: Clip.antiAlias,
//                                       decoration: ShapeDecoration(
//                                         color: Colors.white,
//                                         // image: DecorationImage(
//                                         //   image: AssetImage(kImage3),
//                                         //   fit: BoxFit.fill,
//                                         // ),
//                                         shape: RoundedRectangleBorder(
//                                           borderRadius: BorderRadius.circular(58),
//                                         ),
//                                       ),
//                                       child: FutureBuilder(
//                                         future: ProfileRepo().getUserProfile(userId: notifi.senderBroadcaster),
//                                         builder: (context, snapshot) {
//                                           if (snapshot.connectionState == ConnectionState.waiting) {
//                                             return const CircularProgressIndicator();
//                                           }
//                                           final user = snapshot.data as UserDetailModel;
//                                           return CachedImage(
//                                             url: user.image ?? '',
//                                             width: 43,
//                                             height: 43,
//                                             fit: BoxFit.fill,
//                                           );
//                                         },
//                                       ),
//                                     ),
//                                     const SizedBox(width: 30),
//                                     Expanded(
//                                       child: Text(
//                                         "${notifi.title}\n${notifi.message}",
//                                         style: const TextStyle(
//                                           color: Colors.white,
//                                           fontSize: 16,
//                                           fontWeight: FontWeight.w600,
//                                           letterSpacing: 0.64,
//                                         ),
//                                       ),
//                                     ),
//                                     Container(
//                                       width: 67,
//                                       height: 67,
//                                       decoration: ShapeDecoration(
//                                         color: Colors.white,
//                                         image: DecorationImage(
//                                           image: AssetImage(kDummyImage),
//                                           fit: BoxFit.fill,
//                                         ),
//                                         shape: RoundedRectangleBorder(
//                                           borderRadius: BorderRadius.circular(8),
//                                         ),
//                                       ),
//                                     ),
//                                   ],
//                                 ),
//                               );
//                             } else {
//                               return const Center(
//                                 child: Text(
//                                   'No notifications found',
//                                   style: TextStyle(
//                                     color: Colors.white,
//                                     fontSize: 16,
//                                   ),
//                                 ),
//                               );
//                             }
//                           }),
//                 )
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }
