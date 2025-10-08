import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:socials_app/models/user_chat_model.dart';
import 'package:socials_app/services/session_services.dart';
import 'package:socials_app/views/custom_widgets/customImage.dart';
import 'package:socials_app/views/screens/chat/controller/chat_controller.dart';

// import 'package:voice_message_package/voice_message_package.dart';

import '../../../utils/app_colors.dart';
import '../../../utils/app_styles.dart';
import '../../../utils/common_code.dart';
import '../../custom_widgets/custom_scaffold.dart';

class SingleChatScreen extends GetView<ChatScreenController> {
  const SingleChatScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        controller.singleChatController.clear();
        return true;
      },
      child: CustomScaffold(
        className: runtimeType.toString(),
        screenName: "",
        isBackIcon: false,
        isFullBody: false,
        backIconColor: kPrimaryColor,
        appBarSize: 50,
        showAppBarBackButton: false,
        leadingWidth: 0,
        centerTitle: false,
        actions: [
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              GestureDetector(
                onTap: () {
                  controller.singleChatController.clear();
                  Get.back();
                },
                child: const Icon(
                  Icons.keyboard_arrow_left,
                  color: kPrimaryColor,
                  size: 40,
                ),
              ),
              SizedBox(width: 5.w),
              ClipRRect(
                borderRadius: BorderRadius.circular(4.r),
                child: Obx(
                  () => CachedImage(
                    url: controller.chattedUserImage.value,
                    width: 40.w,
                    height: 40.h,
                    fit: BoxFit.fill,
                    isCircle: false,
                  ),
                ),
              ),
              SizedBox(
                width: 15.h,
              ),
              SizedBox(
                width: Get.width * 0.4,
                height: 50.h,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Obx(
                      () => Text(
                        controller.chattedUserName.value,
                        style: AppStyles.labelTextStyle().copyWith(
                          color: kPrimaryColor,
                          fontFamily: 'poppins',
                          fontWeight: FontWeight.w500,
                          fontSize: 18.sp,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Row(
                      children: [
                        Text(
                          'Active now',
                          style: AppStyles.labelTextStyle().copyWith(
                            color: kWhiteColor,
                            fontFamily: 'poppins',
                            fontWeight: FontWeight.w400,
                            fontSize: 10.sp,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(
                          width: 5.w,
                        ),
                        const CircleAvatar(
                          radius: 3,
                          backgroundColor: kPrimaryColor,
                        )
                      ],
                    ),
                  ],
                ),
              ),
              SizedBox(
                width: Get.width * 0.3,
              ),
              // GestureDetector(
              //   onTap: () {},
              //   child: Image.asset(
              //     kPhoneIcon,
              //     width: 18.w,
              //   ),
              // ),
              // SizedBox(width: 15.w),
              // GestureDetector(
              //   onTap: () {},
              //   child: Image.asset(
              //     kVideoIcon,
              //     width: 25.w,
              //   ),
              // ),
            ],
          )
        ],
        scaffoldKey: controller.scaffoldKeySingleChat,
        onNotificationListener: (notificationInfo) {
          if (notificationInfo.runtimeType == UserScrollNotification) {
            CommonCode().removeTextFieldFocus();
          }
          return false;
        },
        gestureDetectorOnTap: CommonCode().removeTextFieldFocus,
        body: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.only(left: 3.w),
            child: Obx(() =>
                    // StreamBuilder<List<MessageModel>>(
                    //   stream: controller.singleChatController.stream,
                    //   builder: (context, snapshot) {
                    //     if (snapshot.connectionState == ConnectionState.waiting) {
                    //       return const Center(
                    //         child: Padding(
                    //           padding: EdgeInsets.symmetric(vertical: 50),
                    //           child: CircularProgressIndicator(),
                    //         ),
                    //       );
                    //     } else if (snapshot.hasError) {
                    //       log('Error: ${snapshot.error}');
                    //       return Center(
                    //         child: Text('Error: ${snapshot.error}'),
                    //       );
                    //     } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    //       return const Center(
                    //         child: Text('No messages yet'),
                    //       );
                    //     }
                    //     List<MessageModel> chatMessages =
                    //         snapshot.data as List<MessageModel>;
                    //     return
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: controller.singleChatController.length,
                      itemBuilder: (context, index) {
                        MessageModel message = controller.singleChatController[index];
                        bool isSender = message.sender == SessionService().user?.id;
                        // bool isAudio = message.audioMessage == '' ? false : true;
                        bool isAudio = false;
                        bool isUrl = false;
                        // bool isUrl = CommonCode().isValidURL(message.audioMessage);
                        // log('isFile: $isUrl');
                        return Align(
                          alignment: isSender ? Alignment.topRight : Alignment.topLeft,
                          child: Container(
                            width: isAudio
                                ? null
                                : isSender
                                    ? 187.w
                                    : 200.w,
                            margin: EdgeInsets.symmetric(vertical: 8.h),
                            padding: EdgeInsets.all(12.w),
                            decoration: BoxDecoration(
                              color: isSender ? kPrimaryColor : kWhiteColor,
                              borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(isSender ? 20.r : 0),
                                topRight: Radius.circular(isSender ? 0 : 20.r),
                                bottomLeft: Radius.circular(20.r),
                                bottomRight: Radius.circular(20.r),
                              ),
                            ),
                            child: /*isAudio
                                ? SizedBox(
                                    width: isUrl ? null : 280.w,
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                                      children: [
                                        Visibility(
                                            visible: !isUrl,
                                            child: const CircularProgressIndicator(
                                              color: kBlackColor,
                                            )),
                                        VoiceMessageView(
                                          backgroundColor: kPrimaryColor,
                                          activeSliderColor: kBlackColor,
                                          circlesColor: kBlackColor,
                                          playPauseButtonLoadingColor: kBlackColor,
                                          innerPadding: 8,
                                          controller: VoiceController(
                                            maxDuration: const Duration(seconds: 500),
                                            audioSrc: "", //message.audioMessage!,
                                            onComplete: () {
                                              /// do something on complete
                                            },
                                            onPause: () {
                                              /// do something on pause
                                            },
                                            onPlaying: () {
                                              /// do something on playing
                                            },
                                            onError: (err) {
                                              /// do somethin on error
                                            },
                                            isFile: !isUrl,
                                          ),
                                        ),
                                      ],
                                    ),
                                  )
                                : */
                                message.sharedPost.thumbnail.isNotEmpty
                                    ? GestureDetector(
                                        onTap: () {
                                          controller.onMessageTap(message);
                                        },
                                        child: Stack(
                                          alignment: Alignment.center,
                                          children: [
                                            // Thumbnail image
                                            Image.network(
                                              message.sharedPost.thumbnail,
                                              fit: BoxFit.cover,
                                              width: double.infinity,
                                              height: 200,
                                            ),
                                            // Play button overlay
                                            const Icon(
                                              Icons.play_circle_outline,
                                              color: Colors.white,
                                              size: 64,
                                            ),
                                          ],
                                        ),
                                      )
                                    : Text(
                                        message.sharedPost.thumbnail.isNotEmpty ? message.sharedPost.thumbnail : message.message,
                                        style: AppStyles.labelTextStyle().copyWith(
                                          color: kBlackColor,
                                          fontSize: 16.sp,
                                        ),
                                      ),
                          ),
                        );
                      },
                    )
                //   },
                // ),
                ),
          ),
        ),

        //TODO: Removed chat functionality as per Dave's Requirement
        /*bottomNavigationBar: Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: Obx(
            () => SizedBox(
              width: Get.width * 0.85,
              child: controller.isAudioMesgSending.value
                  ? SizedBox(
                      height: 60.h,
                      width: 20.w,
                      child: const Center(child: CircularProgressIndicator()))
                  : controller.path.value != '' &&
                          controller.isRecordingCompleted.value
                      ? Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 5),
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
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Container(
                              width: Get.width * 0.8,
                              height: 50.h,
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(4.r),
                                  color: kGreyContainerColor),
                              child: Padding(
                                padding: EdgeInsets.only(left: 15.w),
                                child: Obx(
                                  () => controller.isRecording.value
                                      ? AudioWaveforms(
                                          enableGesture: true,
                                          size: Size(
                                              MediaQuery.of(context)
                                                      .size
                                                      .width /
                                                  2,
                                              50),
                                          recorderController:
                                              controller.recorderController,
                                          waveStyle: const WaveStyle(
                                            waveColor: Colors.white,
                                            extendWaveform: true,
                                            showMiddleLine: false,
                                          ),
                                          decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(12.0),
                                            color: const Color(0xFF1E1B26),
                                          ),
                                          padding:
                                              const EdgeInsets.only(left: 18),
                                          margin: const EdgeInsets.symmetric(
                                              horizontal: 15),
                                        )
                                      : TextFormField(
                                          controller: controller.message,
                                          autofocus: false,
                                          style: AppStyles.labelTextStyle()
                                              .copyWith(
                                            fontSize: 16.sp,
                                            fontWeight: FontWeight.w500,
                                            color: kWhiteColor,
                                          ),
                                          decoration: InputDecoration(
                                            hintText: controller
                                                    .isRecording.value
                                                ? controller
                                                        .isRecordingCompleted
                                                        .value
                                                    ? 'Recording completed'
                                                    : 'Recording...'
                                                : 'Type a message',
                                            hintStyle:
                                                AppStyles.labelTextStyle()
                                                    .copyWith(
                                              fontSize: 16.sp,
                                              fontWeight: FontWeight.w500,
                                              color: kHintGreyColor,
                                            ),
                                            suffixIcon: IconButton(
                                              icon: const Icon(
                                                CupertinoIcons.paperplane,
                                                color: kHintGreyColor,
                                              ),
                                              onPressed: () {
                                                controller.sendMessage(
                                                  controller.message.text,
                                                  sender: SessionService()
                                                          .user
                                                          ?.id ??
                                                      '',
                                                  receiver: controller
                                                      .chattedUserId.value,
                                                  isAudioFile: false,
                                                );
                                              },
                                            ),
                                            border: InputBorder.none,
                                            contentPadding:
                                                EdgeInsets.symmetric(
                                                    vertical: 15.h),
                                          ),
                                        ),
                                ),
                              ),
                            ),
                            SizedBox(
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
                            )
                          ],
                        ),
            ),
          ),
        ),*/
      ),
    );
  }
}
