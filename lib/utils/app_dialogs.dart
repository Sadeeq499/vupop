import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'app_colors.dart';

class AppDialogs {
  void showDeleteAccountDialog({VoidCallback? onPressed}) {
    Get.dialog(
        Theme(
          data: ThemeData(
              primaryColor: kBlackColor,
              primaryColorDark: kBlackColor,
              dialogTheme: DialogThemeData(backgroundColor: kPrimaryColor),
              dialogBackgroundColor: kPrimaryColor2,
              cupertinoOverrideTheme: const CupertinoThemeData(
                primaryColor: kPrimaryColor2,
                scaffoldBackgroundColor: kPrimaryColor2,
                brightness: Brightness.dark, // Makes the dialog background black
              ),
              cardTheme: CardThemeData(color: kPrimaryColor2)),
          child: CupertinoAlertDialog(
            title: const Text('Delete Account'),
            content: const Text('Are you sure you want to delete your account? This action cannot be undone.'),
            actions: <Widget>[
              CupertinoDialogAction(
                onPressed: () {
                  Get.back();
                },
                child: const Text(
                  'Cancel',
                  style: TextStyle(color: kPrimaryColor),
                ),
              ),
              CupertinoDialogAction(
                isDestructiveAction: true,
                onPressed: onPressed,
                child: const Text('Delete'),
              ),
            ],
          ),
        ),
        barrierDismissible: false);
  }

  void showBlockUserConfirmationDialog({VoidCallback? onPressed}) {
    Get.dialog(
        Theme(
          data: ThemeData(
            cupertinoOverrideTheme: CupertinoThemeData(
              brightness: Brightness.dark, // Makes the dialog background black
            ),
          ),
          child: CupertinoAlertDialog(
            title: const Text(''),
            content: const Text('Are you sure you want to block this user?'),
            actions: <Widget>[
              CupertinoDialogAction(
                onPressed: () {
                  Get.back();
                },
                child: const Text(
                  'Cancel',
                  style: TextStyle(color: kPrimaryColor),
                ),
              ),
              CupertinoDialogAction(
                isDestructiveAction: true,
                onPressed: onPressed,
                child: const Text(
                  'Block',
                ),
              ),
            ],
          ),
        ),
        barrierDismissible: false);
  }
}
