import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:socials_app/utils/app_colors.dart';
import 'package:socials_app/views/screens/chat/controller/chat_controller.dart';

class ChatTimerWidget extends StatelessWidget {
  final String? endTimeIso;
  final ChatScreenController controller;

  const ChatTimerWidget({Key? key, this.endTimeIso, required this.controller}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Set the end time if provided
    if (endTimeIso != null) {
      // controller.setEndTime(endTimeIso!);
    }

    return Container(
      width: double.infinity,
      // margin: EdgeInsets.symmetric(horizontal: 5),
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFDDB),
        // borderRadius: BorderRadius.all(Radius.circular(4)), // Light yellow background
        border: Border(
          left: BorderSide(
            color: kPrimaryColor,
            width: 7,
          ),
        ),
      ),
      child: Obx(
        () => Text(
          controller.timeText.value,
          textAlign: TextAlign.left,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.black.withOpacity(0.75),
          ),
        ),
      ),
    );
  }
}
