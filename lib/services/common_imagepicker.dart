import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:image_picker/image_picker.dart';
import 'package:socials_app/services/custom_snackbar.dart';

import '../utils/app_colors.dart';
import '../utils/common_code.dart';

class CommonServices {
  Future<String?> imagePicker(ImageSource img) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: img);

    if (pickedFile != null) {
      return pickedFile.path;
    } else {
      printLogs('No image selected.');
      return null;
    }
  }

  // fn to check if string is url or not
  static bool isURL(String? string) {
    if (string == null) {
      return false;
    }
    return string.startsWith('http') || string.startsWith('https');
  }

  /// fn to pick video from gallery
  Future<String?> videoPicker() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickVideo(source: ImageSource.gallery);

    if (pickedFile != null) {
      final fileSize = await pickedFile.length();
      const maxSize = 500 * 1024 * 1024;

      if (fileSize > maxSize) {
        await showDialog(
          barrierDismissible: true,
          context: Get.context!,
          builder: (context) => Theme(
            data: ThemeData.dark(),
            child: AlertDialog(
              contentPadding: EdgeInsets.all(20),
              backgroundColor: kGreyContainerColor,
              content: const Text('Video is too large! Must be under 500MB.'),
              actions: [
                TextButton(
                    style: TextButton.styleFrom(foregroundColor: kPrimaryColor),
                    onPressed: () {
                      Get.back();
                    },
                    child: const Text('OK'))
              ],
            ),
          ),
        );
        return null;
      }

      return pickedFile.path;

    } else {
      printLogs('No video selected.');
      return null;
    }
  }

  /// fn to pick video from camera
  Future<String?> videoCamera() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickVideo(source: ImageSource.camera);

    if (pickedFile != null) {
      return pickedFile.path;
    } else {
      printLogs('No video selected.');
      return null;
    }
  }
}
