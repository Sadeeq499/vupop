import 'dart:io';

import 'package:audio_waveforms/audio_waveforms.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:socials_app/services/custom_snackbar.dart';
import 'package:socials_app/services/session_services.dart';
import 'package:socials_app/utils/app_strings.dart';
import 'package:socials_app/views/custom_widgets/blinking_effect_widget.dart';
import 'package:socials_app/views/screens/chat/components/leave_chat_bottom_sheet_widget.dart';

import '../../../utils/app_colors.dart';
import '../../../utils/app_images.dart';
import '../../../utils/app_styles.dart';
import '../../../utils/common_code.dart';
import '../../custom_widgets/CustomImage.dart';
import '../../custom_widgets/custom_scaffold.dart';
import 'controller/chat_controller.dart';

class SingleCommunityChatScreen extends GetView<ChatScreenController> {
  const SingleCommunityChatScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // final scrollController = ScrollController();

    if (controller.isFirstTimeLoad.isTrue) {
      controller.isFirstTimeLoad.value = false;
      Future.microtask(() {
        if (Get.arguments != null && Get.arguments["joinedCommunity"] != null) {
          controller.communityModel.value = Get.arguments["joinedCommunity"];
          printLogs('=========controller.communityModel.value?.name ${controller.communityModel.value?.name}');
          printLogs('=========controller.communityModel.value?.firstmessage ${controller.communityModel.value?.firstMessage}');
          if (controller.communityModel.value?.firstMessage != null) {
            controller.showIntroMessage(controller.communityModel.value!.firstMessage!);
          }
        }
        controller.initScrollController();
        controller.isLoading.value = false;
        // Initial update
        // controller.startTimer();

        // controller.updateTimeText();
        controller.currentPage.value = 1;
        controller.getCommunityMessages(controller.communityModel.value?.id ?? "");
        controller.initializeAllMethods();
        controller.setEndTime((controller.communityModel.value!.endTime!));
      });
    }

    return ModalProgressHUD(
      inAsyncCall: controller.isLoading.value,
      child: CustomScaffold(
        screenName: '',
        className: runtimeType.toString(),
        isBackIcon: false,
        isFullBody: false,
        backIconColor: kPrimaryColor,
        appBarSize: 56,
        showAppBarBackButton: false,
        leadingWidth: 30,
        leadingWidget: GestureDetector(
          onTap: () {
            print('=========on back button ${Get.previousRoute}');
            print('=========on back button current ${Get.currentRoute}');
            print('=========Full route history: ${Get.routing.route}');
            print('=========Route history: ${Get.routing.route?.currentResult}');
            if (Get.previousRoute == "/signInScreen") {
              controller.isFirstTimeLoad.value = true;
              controller.singleCommunityChatMessagesController.clear();
              Get.toNamed(kBottomBarRoute);
            } else {
              controller.isFirstTimeLoad.value = true;
              controller.singleCommunityChatMessagesController.clear();
              Get.back();
            }
          },
          child: Container(
            margin: const EdgeInsets.only(left: 8),
            child: Icon(
              Icons.keyboard_arrow_left,
              color: kPrimaryColor,
              size: 40,
            ),
          ),
        ),
        title: Obx(
          () => Row(
            children: [
              Container(
                width: 54,
                height: 54,
                child: BlinkWidget(interval: 750, children: [
                  Obx(
                    () => Container(
                      width: 45,
                      height: 45,
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: kPrimaryColor,
                          width: 1.5,
                        ),
                        borderRadius: BorderRadius.circular(100.r),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(2.0),
                        child: CachedImage(url: controller.communityModel.value?.image ?? "", isCircle: true, errorImage: kGroupChatIcon),
                      ),
                    ),
                  ),
                  Obx(
                    () => Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: kPrimaryColor,
                          width: 3.5,
                        ),
                        borderRadius: BorderRadius.circular(100.r),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(2.0),
                        child: CachedImage(url: controller.communityModel.value?.image ?? "", isCircle: true, errorImage: kGroupChatIcon),
                      ),
                    ),
                  ),
                  /*CachedNetworkImage(
                            imageUrl: controller.communityModel.value?.image ?? "", // Add your logo asset
                            width: 45,
                            height: 45,
                            fit: BoxFit.fill,
                            progressIndicatorBuilder: (context, url, progress) => Shimmer.fromColors(
                                baseColor: kShimmerbaseColor,
                                highlightColor: kShimmerhighlightColor,
                                child: Container(
                                  color: Colors.white,
                                )),
                            errorWidget: (context, error, stackTrace) {
                              return Image.asset(
                                kGroupChatIcon, // Add your logo asset
                                width: 45,
                                height: 45,
                                fit: BoxFit.fill,
                              );
                            },
                          ),
                          Image.network(
                            color: Colors.transparent,
                            controller.communityModel.value?.image ?? "", // Add your logo asset
                            width: 45,
                            height: 45,
                            fit: BoxFit.fill,
                            errorBuilder: (context, error, stackTrace) {
                              return Image.asset(
                                kGroupChatIcon, // Add your logo asset
                                width: 45,
                                height: 45,
                                fit: BoxFit.fill,
                              );
                            },
                          ),*/
                ]),
              ),
              SizedBox(
                width: 10,
              ),
              Text(
                controller.communityModel.value?.name ?? "",
                style: AppStyles.labelTextStyle().copyWith(
                  color: kPrimaryColor,
                  fontFamily: 'poppins',
                  fontWeight: FontWeight.w500,
                  fontSize: 18.sp,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
        actions: [
          GestureDetector(
            onTap: () {
              Get.bottomSheet(
                LeaveChatBottomSheet(
                    titleText: controller.communityModel.value?.name ?? "",
                    description: controller.communityModel.value?.description ?? "No Description Found",
                    //"🏆 The ultimate showdown is here! Join the live chat for ${controller.communityModel.value?.name} and experience the action with fellow fans—debate, celebrate, and share every moment! ⚽🔥",
                    image: controller.communityModel.value?.image,
                    onTap: () {
                      Get.back();
                      controller.leaveCommunityChat(communityId: controller.communityModel.value?.id ?? "");
                    }),
                isScrollControlled: true,
                enableDrag: true,
                barrierColor: Colors.white.withOpacity(0.40),
                backgroundColor: Colors.transparent,
              );
            },
            child: Container(margin: const EdgeInsets.only(right: 16), child: const Icon(Icons.menu, color: kPrimaryColor)),
          ),
        ],
        scaffoldKey: controller.scaffoldKeySingleCommunityChat,
        onNotificationListener: (notificationInfo) {
          if (notificationInfo.runtimeType == UserScrollNotification) {
            CommonCode().removeTextFieldFocus();
          }
          return false;
        },
        gestureDetectorOnTap: CommonCode().removeTextFieldFocus,
        body: Container(
          decoration: BoxDecoration(
              image: DecorationImage(
            scale: 5,
            opacity: 0.4,
            image: AssetImage(
              kAppLogo,
            ),
            repeat: ImageRepeat.repeat,
            filterQuality: FilterQuality.high,
            isAntiAlias: true,
            alignment: Alignment.center,
          )),
          child: Stack(
            children: [
              Obx(() {
                final groupedMessages = controller.groupMessagesByDate(controller.singleCommunityChatMessagesController.toList());
                return ListView.builder(
                  controller: controller.scrollController,
                  reverse: true, // Reverse the list to show latest at bottom
                  itemCount: groupedMessages.length,

                  itemBuilder: (context, index) {
                    // Loading indicator at the top (which appears at the beginning when reversed)
                    /*if (index == groupedMessages.length) {
                              return Obx(() => controller.isLoadingMoreData.value
                                  ? Container(
                                      padding: EdgeInsets.symmetric(vertical: 16.h),
                                      alignment: Alignment.center,
                                      child: CircularProgressIndicator(),
                                    )
                                  : SizedBox.shrink());
                            }*/
                    final dates = groupedMessages.keys.toList()..sort((a, b) => b.compareTo(a));
                    final date = dates[index];
                    final messages = groupedMessages[date]!;

                    return Column(
                      children: [
                        if (index == groupedMessages.length)
                          Container(
                            padding: EdgeInsets.symmetric(vertical: 16.h),
                            alignment: Alignment.center,
                            child: CircularProgressIndicator(),
                          ),
                        // Date header
                        Container(
                          decoration: BoxDecoration(color: kGreyContainerColor, borderRadius: BorderRadius.circular(16)),
                          padding: EdgeInsets.symmetric(vertical: 8.h, horizontal: 16),
                          child: Text(
                            date,
                            style: AppStyles.labelTextStyle().copyWith(
                              color: Colors.grey,
                              fontSize: 12.sp,
                            ),
                          ),
                        ),
                        // Messages for this date
                        ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: messages.length,
                          itemBuilder: (context, messageIndex) {
                            final message = messages[messageIndex];
                            final isSender = message.senderId == SessionService().user?.id;

                            return Container(
                              width: Get.width * 0.80,
                              margin: EdgeInsets.only(right: isSender ? 0 : Get.width * 0.20, left: !isSender ? 0 : Get.width * 0.20),
                              child: Align(
                                alignment: isSender ? Alignment.centerRight : Alignment.centerLeft,
                                child: isSender
                                    ? Container(
                                        // width: Get.width * 0.7,
                                        margin: EdgeInsets.symmetric(vertical: 4.h, horizontal: 8.w),
                                        padding: EdgeInsets.all(12.w),
                                        decoration: BoxDecoration(
                                          color: isSender ? kPrimaryColor : kWhiteColor,
                                          borderRadius: BorderRadius.only(
                                            topLeft: Radius.circular(20.r),
                                            topRight: Radius.circular(20.r),
                                            bottomLeft: Radius.circular(isSender ? 20.r : 0.r),
                                            bottomRight: Radius.circular(isSender ? 0 : 20.r),
                                          ),
                                        ),
                                        child: Text(
                                          message.message ?? "",
                                          style: AppStyles.labelTextStyle().copyWith(
                                            color: isSender ? kBlackColor : kBlackColor,
                                            fontSize: 16.sp,
                                          ),
                                        ),
                                      )
                                    : Container(
                                        margin: EdgeInsets.only(top: 5),
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.start,
                                          crossAxisAlignment: CrossAxisAlignment.end,
                                          children: [
                                            message.senderImage != null
                                                ? CachedImage(
                                                    url: message.senderImage!,
                                                    width: 48,
                                                    height: 48,
                                                    isCircle: false,
                                                  )
                                                : Image.asset(kProfileImage, width: 48, height: 48),
                                            Flexible(
                                              child: Container(
                                                // width: Get.width * 0.7,
                                                margin: EdgeInsets.symmetric(vertical: 4.h, horizontal: 8.w),
                                                padding: EdgeInsets.all(12.w),
                                                decoration: BoxDecoration(
                                                  color: isSender ? kPrimaryColor : kWhiteColor,
                                                  borderRadius: BorderRadius.only(
                                                    topLeft: Radius.circular(20.r),
                                                    topRight: Radius.circular(20.r),
                                                    bottomLeft: Radius.circular(isSender ? 20.r : 0.r),
                                                    bottomRight: Radius.circular(isSender ? 0 : 20.r),
                                                  ),
                                                ),
                                                child: Text(
                                                  message.message ?? "",
                                                  style: AppStyles.labelTextStyle().copyWith(
                                                    color: isSender ? kBlackColor : kBlackColor,
                                                    fontSize: 16.sp,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                              ),
                            );
                          },
                        ),

                        if (index == 0)
                          SizedBox(
                            height: 16,
                          )
                      ],
                    );
                  },
                );
              }),

              // Scroll to bottom button
              Obx(
                () => Visibility(
                  visible: controller.showScrollButton.value,
                  child: Positioned(
                    right: 16,
                    bottom: 10,
                    child: FloatingActionButton(
                      mini: true,
                      backgroundColor: kWhiteColor,
                      onPressed: controller.scrollToBottom,
                      child: const Icon(Icons.keyboard_arrow_down, color: kBlackColor),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        bottomNavigationBar: controller.communityModel.value != null &&
                controller.communityModel.value!.endTime != null &&
                (controller.communityModel.value!.endTime!).difference((DateTime.now().isUtc ? DateTime.now() : DateTime.now().toUtc())).isNegative
            ? Padding(
                padding: EdgeInsets.only(
                  bottom: Platform.isIOS ? 30 : MediaQuery.of(context).viewInsets.bottom,
                ),
                child: Text(
                  'The chat has ended',
                  textAlign: TextAlign.center,
                  style: AppStyles.labelTextStyle().copyWith(
                    color: kWhiteColor,
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              )
            : Padding(
                padding: EdgeInsets.only(
                  bottom: MediaQuery.of(context).viewInsets.bottom,
                ),
                child: Obx(
                  () => SizedBox(
                    width: Get.width * 0.85,
                    child: controller.isAudioMesgSending.value
                        ? SizedBox(height: 60.h, width: 20.w, child: const Center(child: CircularProgressIndicator()))
                        : /*controller.path.value != '' && controller.isRecordingCompleted.value
                          ? Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceAround,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  SizedBox(
                                    width: Get.width * 0.8,
                                    height: 63.h,
                                    child: VoiceMessageView(
                                      backgroundColor: kPrimaryColor,
                                      activeSliderColor: kBlackColor,
                                      circlesColor: kBlackColor,
                                      playPauseButtonLoadingColor: kBlackColor,
                                      innerPadding: 8,
                                      size: 50,
                                      controller: VoiceController(
                                        maxDuration: const Duration(seconds: 300),
                                        audioSrc: controller.path.value,
                                        onComplete: () {},
                                        onPause: () {
                                          // controller.isRecordingCompleted.value = true;
                                        },
                                        onPlaying: () {
                                          // controller.isRecordingCompleted.value = false;
                                        },
                                        onError: (err) {
                                          // log('Error: $err');
                                        },
                                        isFile: true,
                                      ),
                                    ),
                                  ),
                                  GestureDetector(
                                    onTap: () {
                                      controller.sendMessage(
                                        controller.path.value,
                                        sender: SessionService().user?.id ?? '',
                                        receiver: controller.chattedUserId.value,
                                        isAudioFile: true,
                                      );
                                    },
                                    child: Container(
                                      width: 55.w,
                                      height: 55.h,
                                      decoration: BoxDecoration(
                                        color: kPrimaryColor,
                                        borderRadius: BorderRadius.circular(20.r),
                                      ),
                                      child: Center(
                                        child: Image.asset(
                                          kSendIcon,
                                          width: 20.w,
                                          color: kBlackColor,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            )
                          :*/
                        Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Container(
                                width: Get.width * 0.90,
                                // height: 60.h,
                                margin: EdgeInsets.only(bottom: Platform.isIOS ? 16 : 0),
                                decoration: BoxDecoration(borderRadius: BorderRadius.circular(12.r), color: kGreyContainerColor),
                                child: Padding(
                                  padding: EdgeInsets.only(left: 15.w),
                                  child: Obx(
                                    () => controller.isRecording.value
                                        ? AudioWaveforms(
                                            enableGesture: true,
                                            size: Size(MediaQuery.of(context).size.width / 2, 50),
                                            recorderController: controller.recorderController,
                                            waveStyle: const WaveStyle(
                                              waveColor: Colors.white,
                                              extendWaveform: true,
                                              showMiddleLine: false,
                                            ),
                                            decoration: BoxDecoration(
                                              borderRadius: BorderRadius.circular(12.0),
                                              color: const Color(0xFF1E1B26),
                                            ),
                                            padding: const EdgeInsets.only(left: 18),
                                            margin: const EdgeInsets.symmetric(horizontal: 15),
                                          )
                                        : TextFormField(
                                            controller: controller.message,
                                            autofocus: false,
                                            minLines: 1,
                                            maxLines: 3,
                                            style: AppStyles.labelTextStyle().copyWith(
                                              fontSize: 16.sp,
                                              fontWeight: FontWeight.w500,
                                              color: kWhiteColor,
                                            ),
                                            decoration: InputDecoration(
                                              hintText: controller.isRecording.value
                                                  ? controller.isRecordingCompleted.value
                                                      ? 'Recording completed'
                                                      : 'Recording...'
                                                  : 'Type message',
                                              hintStyle: AppStyles.labelTextStyle().copyWith(
                                                fontSize: 16.sp,
                                                fontWeight: FontWeight.w500,
                                                color: kHintGreyColor,
                                              ),
                                              suffixIcon: IconButton(
                                                icon: Obx(
                                                  () => Icon(
                                                    CupertinoIcons.paperplane,
                                                    color: controller.messageText.value.isNotEmpty ? kPrimaryColor : kHintGreyColor,
                                                  ),
                                                ),
                                                onPressed: () {
                                                  if (controller.message.text.isNotEmpty) {
                                                    controller.sendCommunityMessage(
                                                        text: controller.message.text, communityID: controller.communityModel.value?.id ?? "");
                                                  } else {
                                                    CustomSnackbar.showSnackbar("Type something to send");
                                                  }
                                                },
                                              ),
                                              border: InputBorder.none,
                                              contentPadding: EdgeInsets.symmetric(vertical: 15.h),
                                            ),
                                          ),
                                  ),
                                ),
                              ),
                              /*SizedBox(
                              width: 10.w,
                            ),
                            GestureDetector(
                              onTap: controller.startOrStopRecording,
                              child: Container(
                                width: 44.w,
                                height: 44.h,
                                decoration: BoxDecoration(
                                  color: kPrimaryColor,
                                  borderRadius: BorderRadius.circular(4.r),
                                ),
                                child: Center(
                                  child: Image.asset(
                                    kMicrophoneIcon,
                                    width: 18.w,
                                  ),
                                ),
                              ),
                            )*/
                            ],
                          ),
                  ),
                ),
              ),
      ),
    );
  }
}
