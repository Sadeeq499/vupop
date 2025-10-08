import 'package:flutter/material.dart';

import '../../../../utils/app_colors.dart';

class CustomCountdown extends AnimatedWidget {
  final Animation<int>? animation;

  CustomCountdown({
    Key? key,
    this.animation,
  }) : super(key: key, listenable: animation!);

  @override
  build(BuildContext context) {
    Duration clockTimer = Duration(seconds: animation!.value);

    String timerText = '${clockTimer.inMinutes.remainder(60).toString()}:${clockTimer.inSeconds.remainder(60).toString().padLeft(2, '0')}';
    // printLogs('=====timerText $timerText');
    return Text(
      'Resend code in $timerText',
      textAlign: TextAlign.right,
      style: TextStyle(
        color: kHintGreyColor,
        fontSize: 12,
        fontFamily: 'Inter',
        fontWeight: FontWeight.w400,
        height: 0,
      ),
    );
  }
}

class CustomCountdownMessages extends AnimatedWidget {
  final Animation<int>? animation;

  CustomCountdownMessages({
    Key? key,
    this.animation,
  }) : super(key: key, listenable: animation!);

  @override
  build(BuildContext context) {
    Duration clockTimer = Duration(seconds: animation!.value);

    String timerText =
        '${clockTimer.inHours.toString()}:clockTimer.inMinutes.remainder(60).toString()}:${clockTimer.inSeconds.remainder(60).toString().padLeft(2, '0')}';
    // printLogs('=====timerText $timerText');
    return Text(
      'This chat will end in $timerText',
      textAlign: TextAlign.right,
      style: TextStyle(
        color: kHintGreyColor,
        fontSize: 12,
        fontFamily: 'Inter',
        fontWeight: FontWeight.w400,
        height: 0,
      ),
    );
  }
}
