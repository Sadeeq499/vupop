import 'dart:io';
import 'dart:ui';

import 'package:ffmpeg_kit_flutter/ffmpeg_kit.dart';
import 'package:ffmpeg_kit_flutter/return_code.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:share_plus/share_plus.dart';
import 'package:socials_app/services/custom_socket_service.dart';
import 'package:socials_app/services/session_services.dart';
import 'package:socials_app/utils/app_images.dart';
import 'package:socials_app/utils/app_styles.dart';
import 'package:socials_app/views/custom_widgets/user_follow_row.dart';
import 'package:socials_app/views/screens/chat/controller/chat_controller.dart';

import '../models/post_models.dart';
import '../services/custom_snackbar.dart';
import 'app_colors.dart';

class CommonCode {
  static String? validateEmptyText(String? fieldName, String? value) {
    if (value == null || value.isEmpty) {
      return '$fieldName is required';
    }
    return null;
  }

  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return "Email is required";
    }
    final emailRegExp = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2}$');
    if (!emailRegExp.hasMatch(value)) {
      return 'Invalid email address.';
    }
    return null;
  }

  static String? validateUsername(String? value) {
    if (value == null || value.isEmpty) {
      return "Username is required";
    }

    // Trim only leading/trailing whitespace
    value = value.trim();

    if (value.length < 3) {
      return 'Username must be at least 3 characters long.';
    }
    if (value.length > 20) {
      return 'Username must be no more than 20 characters long.';
    }
    if (!RegExp(r'^[a-zA-Z]').hasMatch(value)) {
      return 'Username must start with a letter.';
    }

    // Updated regex to include space
    if (!RegExp(r'^[a-zA-Z][a-zA-Z0-9._ ]*$').hasMatch(value)) {
      return 'Username may only contain letters, numbers, dots, underscores, and spaces.';
    }

    return null;
  }

  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return "Password is required";
    }
    if (value.length < 6) {
      return 'Password must be at least 6 characters long.';
    }
    if (!value.contains(RegExp(r'[A-Z]'))) {
      return 'Password must contain atleast one uppercase letter.';
    }
    if (!value.contains(RegExp(r'[0-9]'))) {
      return 'Password must contain atleast one number.';
    }
    if (!value.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) {
      return 'Password must contain atleast one special characters.';
    }
    return null;
  }

  static String? isValidConfirmPassword(String password, String confirmPassword) {
    if (password.isEmpty) {
      return "Password is required";
    }
    if (confirmPassword.isEmpty) {
      return "You need to confirm password before proceeding";
    }
    if (password != confirmPassword) {
      return "Passwords do not match. Please enter again!";
    }
    return null;
  }

  static String? validateContact(String? value) {
    if (value == null || value.isEmpty) {
      return "Phone number is required";
    }
    final phoneRegExp = RegExp(r'^[+]*[(]{0,1}[0-9]{1,4}[)]{0,1}[-\s\./0-9]*$');
    if (!phoneRegExp.hasMatch(value)) {
      return "Invalid phone number format";
    }
    return null;
  }

  bool removeTextFieldFocus() {
    FocusScopeNode currentFocus = FocusScope.of(Get.context!);
    if (!currentFocus.hasPrimaryFocus && currentFocus.focusedChild != null) {
      FocusManager.instance.primaryFocus!.unfocus();
      return true;
    }
    return false;
  }

  /*static bool isValidEmail(String email) {
    bool emailValid = RegExp(r"^[a-zA-Z0-9.a-zA-Z0-9!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+").hasMatch(email);
    return emailValid;
  }*/
  static bool isValidEmail(String email) {
    bool emailValid = RegExp(r"^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$").hasMatch(email);
    return emailValid;
  }

  bool isValidPhone(
    String? inputString, {
    bool isRequired = false,
  }) {
    bool isInputStringValid = false;

    if (!isRequired && (inputString == null ? true : inputString.isEmpty)) {
      isInputStringValid = true;
    }

    if (inputString != null && inputString.isNotEmpty) {
      if (inputString.length > 16 || inputString.length < 6) return false;

      const pattern = r'^[+]*[(]{0,1}[0-9]{1,4}[)]{0,1}[-\s\./0-9]*$';

      final regExp = RegExp(pattern);

      isInputStringValid = regExp.hasMatch(inputString);
    }

    return isInputStringValid;
  }

  /// fn is URL
  bool isValidURL(String? url) {
    if (url == null || url.isEmpty) {
      return false;
    }
    final urlRegExp =
        RegExp(r'^(http:\/\/www\.|https:\/\/www\.|http:\/\/|https:\/\/)?[a-z0-9]+([\-\.]{1}[a-z0-9]+)*\.[a-z]{2,5}(:[0-9]{1,5})?(\/.*)?$');
    printLogs('===========isValid Url ${urlRegExp.hasMatch(url)}');
    return urlRegExp.hasMatch(url);
  }

  bool isValidAWSUrl(String url) {
    // Check if the URL is valid using Uri.tryParse
    final uri = Uri.tryParse(url);
    if (uri == null || !uri.isAbsolute) {
      return false;
    }

    // Define valid image extensions
    final validExtensions = ['jpg', 'jpeg', 'png', 'webp'];

    // Extract the path from the URL and check the extension
    final extension = uri.pathSegments.last.split('.').last.toLowerCase();

    if (validExtensions.contains(extension)) {
      return true;
    } else {
      return false;
    }
  }

  /// fn to check of input is Uint8List or String
  bool isUint8ListOrString(dynamic input) {
    if (input is Uint8List || input is String) {
      return true;
    }
    return false;
  }

  /// fn to check special characters
  bool hasSpecialCharacters(String input) {
    final specialCharacters = RegExp(r'[!@#$%^&*(),.?":{}|<>]');
    return specialCharacters.hasMatch(input);
  }

  /// fn to genrate file from Uint8List
  Future<File> generateFile(Uint8List bytes, String fileName) async {
    /// Get the directory path for the app
    // final directory = Directory.systemTemp;
    final appDirectory = Platform.isIOS ? await getApplicationDocumentsDirectory() : await getExternalStorageDirectory();
    String videoDirectory =
        Platform.isIOS ? '${appDirectory?.path}/Download/vupop/temp/' : "${appDirectory?.path.split('Android')[0]}Download/vupop/temp/";
    if (!await Directory(videoDirectory).exists()) {
      printLogs("Directory not exist");
      Directory(videoDirectory).createSync(recursive: true);
    }

    printLogs('============generateFile directory.path ${videoDirectory}');

    /// Create the file
    final file = File('$videoDirectory$fileName');

    /// Write the file
    await file.writeAsBytes(bytes);

    return file;
  }

  static String formatDate(String date) {
    DateTime dateTime = DateTime.parse(date);
    String monthName = DateFormat('MMM').format(dateTime);
    String formattedDate = "${dateTime.day}, $monthName, ${dateTime.year}";
    String formattedTime = DateFormat('HH:mm').format(dateTime);
    return "$formattedDate $formattedTime";
  }

  static String formatDateToMonthDateYear(DateTime dateTime) {
    // DateTime dateTime = DateTime.parse(date);
    String monthName = DateFormat('MMMM').format(dateTime);
    String formattedDate = "$monthName ${dateTime.day}, ${dateTime.year}";
    // String formattedTime = DateFormat('HH:mm').format(dateTime);
    return "$formattedDate";
  }

  static String formatDateToDayAndMonth(String date) {
    DateTime dateTime = DateTime.parse(date);
    String monthName = DateFormat('MMM').format(dateTime);
    String formattedDate = "${dateTime.day} $monthName";
    String formattedTime = DateFormat('HH:mm').format(dateTime);
    return formattedDate;
  }

  static logOutConfirmation() async {
    await showDialog(
      barrierDismissible: true,
      context: Get.context!,
      builder: (context) => Theme(
        data: ThemeData.dark(),
        child: AlertDialog(
          backgroundColor: kGreyContainerColor,
          content: const Text('Are you sure, you want to exit app?'),
          actions: [
            TextButton(
                style: TextButton.styleFrom(foregroundColor: Colors.red),
                onPressed: () async {
                  exit(0);
                },
                child: const Text('YES')),
            TextButton(
                style: TextButton.styleFrom(foregroundColor: kPrimaryColor),
                onPressed: () {
                  Get.back();
                },
                child: const Text('NO'))
          ],
        ),
      ),
    );
  }

  Future withInAppShare(
    BuildContext context,
    PostModel post,
  ) async {
    showModalBottomSheet(
      context: context,
      backgroundColor: kBackgroundColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      isScrollControlled: true,
      builder: (context) {
        final users = SessionService().following;
        if (users.isEmpty) {
          return const SizedBox(
            height: 100,
            child: Center(
              child: Text(
                'No users to share with',
                style: TextStyle(color: kWhiteColor),
              ),
            ),
          );
        }
        return FractionallySizedBox(
          heightFactor: 0.7,
          child: SizedBox(
            height: Get.height,
            width: Get.width,
            child: Column(
              children: [
                const SizedBox(height: 10),
                ListTile(
                  title: Text(
                    'Share with your friends',
                    style: AppStyles.labelTextStyle().copyWith(
                      color: kWhiteColor,
                      fontSize: 16.sp,
                    ),
                  ),
                ),
                SizedBox(
                  height: Get.height * 0.6,
                  child: ListView.separated(
                    itemCount: users.length,
                    shrinkWrap: true,
                    padding: EdgeInsets.symmetric(horizontal: 15.h),
                    itemBuilder: (context, index) {
                      final name = users[index].name;
                      final imageUrl = users[index].image ?? '';
                      return UserFollowRow(
                        onProfileTap: () {},
                        name: name,
                        imageUrl: imageUrl,
                        isFollowed: false.obs,
                        btnText: 'Share',
                        onTap: () {
                          Navigator.pop(context);

                          ChatScreenController chatScreenController =
                              Get.isRegistered<ChatScreenController>() ? Get.find<ChatScreenController>() : Get.put(ChatScreenController());
                          // printLogs('===============post.maskVideo ${post.maskVideo}');
                          chatScreenController.sendMessage(post.id,
                              sender: SessionService().user?.id ?? '',
                              receiver: users[index].id,
                              receiverName: users[index].name,
                              isAudioFile: false);

                          ///fn removed to implement sockets
                          /*ChatRepo()
                              .sendMessage(
                            //post.maskVideo,
                            "Check out this video",
                            receiver: users[index].id,
                            sender: SessionService().user?.id ?? '',
                          )
                              .then((value) {
                            CustomSnackbar.showSnackbar('Shared with $name');
                          });*/
                        },
                        onBlockTap: () {},
                        isFollowLoading: false.obs,
                      );
                    },
                    separatorBuilder: (context, index) => SizedBox(height: 20.h),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // Helper function to apply watermark to the video
  static Future<bool> applyWatermark({
    required String videoPath,
    required String waterMarkVideoPath,
  }) async {
    /*try {
      // Validate video path
      if (videoPath.isEmpty) {
        printLogs('Video path is empty');
        return false;
      }

      // Get the directory for temporary files
      final tempDir = await getTemporaryDirectory();

      // Prepare watermark file path
      final watermarkPath = await _prepareWatermarkImage();

      printLogs('============waterMarkVideoPath $waterMarkVideoPath');
      printLogs('============videoPath $videoPath');

      // Prepare output file path
      final outputPath = waterMarkVideoPath;

      // Construct FFmpeg command for diagonal watermark
      final command = [
        '-i', videoPath, // Input video
        '-i', watermarkPath, // Watermark image
        '-filter_complex',
        '[1:v]format=rgba,scale=iw*0.4:-1,rotate=PI/4:ow=rotw(iw):oh=roth(ih):c=none[wm];' // Rotate watermark diagonally
            '[0:v][wm]overlay=W-w-20:H-h-20:enable=between(t,0,20)', // Overlay diagonally with transparency
        '-c:a', 'copy', // Copy audio without re-encoding
        outputPath
      ];

      // Execute FFmpeg command
      final session = await FFmpegKit.execute(command.join(' '));

      final returnCode = await session.getReturnCode();
      printLogs('=============returnCode $returnCode');

      if (ReturnCode.isSuccess(returnCode)) {
        // Replace original video with watermarked version
        await File(videoPath).delete();
        await File(outputPath).rename(videoPath);

        printLogs('Watermark applied successfully');
        return true;
      } else {
        printLogs('Failed to apply watermark ${returnCode}');
        return false;
      }
    } catch (e) {
      printLogs('Error applying watermark: $e');
      return false;
    }*/
    try {
      if (videoPath.isEmpty || waterMarkVideoPath.isEmpty) {
        printLogs('Error: Video path or watermark path is empty');
        return false;
      }

      // Log paths for debugging
      printLogs('Video Path: $videoPath');
      printLogs('Watermark Path: $waterMarkVideoPath');

      // final tempDir = await getTemporaryDirectory();
      // final outputPath = '${tempDir.path}/watermarked_video.mp4';
      final outputPath = waterMarkVideoPath;

      /*final command = [
        '-i',
        videoPath,
        '-i',
        await _prepareWatermarkImage(),
        '-filter_complex',
        '[1:v]scale=iw*0.2:-1[wm];[0:v][wm]overlay=W-w-10:H-h-10',
        '-c:a',
        'copy',
        outputPath
      ];*/
      final command = [
        '-i',
        videoPath,
        '-i',
        await _prepareWatermarkImage(),
        '-filter_complex',
        '[1:v]scale=iw*0.45:-1[wm];[wm]format=yuva444p,colorchannelmixer=aa=0.55[wm_trans];[0:v][wm_trans]overlay=10:H/3',
        '-c:a',
        'copy',
        outputPath
      ];

      printLogs('FFmpeg Command: ${command.join(' ')}');

      final session = await FFmpegKit.execute(command.join(' '));
      final returnCode = await session.getReturnCode();

      if (ReturnCode.isSuccess(returnCode)) {
        printLogs('Watermark applied successfully!');
        return true;
      } else {
        printLogs('FFmpeg execution failed: $returnCode');
        return false;
      }
    } catch (e) {
      printLogs('Error during watermark application: $e');
      return false;
    }
  }

  static Future<String> _prepareWatermarkImage() async {
    // Prepare watermark image from assets
    final tempDir = await getTemporaryDirectory();
    final watermarkPath = '${tempDir.path}/watermark.png';

    final byteData = await rootBundle.load(kWatermarkYellow); // Replace with your asset path
    final watermarkFile = File(watermarkPath);
    await watermarkFile.writeAsBytes(byteData.buffer.asUint8List());

    return watermarkPath;
  }

  ///working code with water mark in bottom right
  /* static Future<bool> applyWatermark({required String videoPath, required String waterMarkVideoPath}) async {
    try {
      // Validate video path
      if (videoPath.isEmpty) {
        printLogs('Video path is empty');
        return false;
      }

      // Get the directory for temporary files
      final tempDir = await getTemporaryDirectory();

      // Prepare watermark file path
      final watermarkPath = await _prepareWatermarkImage();

      printLogs('============waterMarkVideoPath $waterMarkVideoPath');
      printLogs('============videoPath $videoPath');
      // Prepare output file path
      final outputPath = waterMarkVideoPath; //'${tempDir.path}/watermarked_video.mp4';

      // Construct FFmpeg command
      // This command overlays the watermark in the bottom right corner
      final command = [
        '-i', videoPath, // Input video
        '-i', watermarkPath, // Watermark image
        '-filter_complex',
        '[1:v]scale=iw*0.2:-1[wm];[0:v][wm]overlay=W-w-10:H-h-10', // Position watermark
        '-c:a', 'copy', // Copy audio without re-encoding
        outputPath
      ];

      // Execute FFmpeg command
      final session = await FFmpegKit.execute(command.join(' '));

      final returnCode = await session.getReturnCode();
      printLogs('=============returnCode $returnCode');

      if (ReturnCode.isSuccess(returnCode)) {
        // Replace original video with watermarked version
        await File(videoPath).delete();
        await File(outputPath).rename(videoPath);

        printLogs('Watermark applied successfully');
        return true;
      } else {
        printLogs('Failed to apply watermark ${returnCode}');
        return false;
      }
    } catch (e) {
      printLogs('Error applying watermark: $e');
      return false;
    }
  }

  static Future<String> _prepareWatermarkImage() async {
    // This method would create or locate your watermark image
    // For this example, we'll assume you have a watermark image in assets
    final tempDir = await getTemporaryDirectory();
    // final watermarkPath = '${tempDir.path}/watermark.png';

    // Step 3: Load watermark from assets and save to temp directory
    final watermarkPath = '${tempDir.path}/watermark.png';
    final byteData = await rootBundle.load(kAppLogo);
    final watermarkFile = File(watermarkPath);
    await watermarkFile.writeAsBytes(byteData.buffer.asUint8List());

    // In a real implementation, you would:
    // 1. Copy watermark from assets to temp directory
    // 2. Or generate a watermark image dynamically

    // This is a placeholder - replace with actual watermark image preparation
    return watermarkPath;
  }*/
  ///working code with water mark in bottom right ends
  ///
  void sendMentionNotification({
    required String managerID,
    required String userID,
    required String message,
  }) async {
    final socket = CustomSocketService.instance.socket;

    printLogs('=================send notification to the manager ManagerID: $managerID, userID : $userID}');
    socket?.emit('getNotification', [managerID, userID, message]);

    /*socket?.on('allChats', (data) {
        singleChatController.add(MessageModel.fromJson(data));
        singleChatController.refresh();
      });*/
    // NotificationRepo().sendNotification(userId: receiver, title: "New Message", body: text);
    // CustomSnackbar.showSnackbar('Shared with $receiverName');
    // message.clear();
  }

//share as an image
  static Future<void> captureAndSharePng(receiptKey) async {
    try {
      RenderRepaintBoundary boundary = receiptKey.currentContext!.findRenderObject() as RenderRepaintBoundary;

      // Capture image
      var image = await boundary.toImage(pixelRatio: 8.0);
      ByteData? byteData = await image.toByteData(format: ImageByteFormat.png);
      if (byteData != null) {
        Uint8List pngBytes = byteData.buffer.asUint8List();

        // Save the image to a temporary file using path_provider
        final directory = await getApplicationDocumentsDirectory();
        final filePath = '${directory.path}/${DateTime.timestamp()}.png';
        final file = File(filePath);
        await file.writeAsBytes(pngBytes);

        // Create an XFile and share it
        final XFile xFile = XFile(filePath);
        ShareResult shareResult = await Share.shareXFiles([xFile], text: 'Payment receipt');
        /*Uint8List pngBytes = byteData.buffer.asUint8List();

      // Save the image to a temporary file
      final directory = await getApplicationDocumentsDirectory();
      final file = XFile('${directory.path}/${DateTime.timestamp()}.png');
      // await file.writeAsBytes(pngBytes);

      // Share the image using share_plus
      ShareResult shareResult = await Share.shareXFiles([file], text: 'Payment Receipt');*/
        if (shareResult.status == ShareResultStatus.success) {
          CustomSnackbar.showSnackbar('Shared successfully');
        }
      }
    } catch (e) {
      printLogs(e.toString());
    }
  }

// Method to capture the widget as an image and save it to the device

  static Future<void> captureAndSavePng(receiptKey) async {
    try {
      // Request storage permission
      if (await _requestStoragePermission()) {
        RenderRepaintBoundary boundary = receiptKey.currentContext!.findRenderObject() as RenderRepaintBoundary;

        // Capture image
        var image = await boundary.toImage();
        ByteData? byteData = await image.toByteData(format: ImageByteFormat.png);
        if (byteData != null) {
          Uint8List pngBytes = byteData.buffer.asUint8List();

          // Get the path to save the file (e.g., Downloads directory)
          final savedVideoDirectory = Platform.isIOS ? await getApplicationDocumentsDirectory() : await getExternalStorageDirectory();

          final directory = Platform.isAndroid
              ? "${savedVideoDirectory?.path.split('Android')[0]}Download/vupop/receipts"
              : "${savedVideoDirectory?.path}/Download/vupop/receipts";
          await Directory(directory).create(recursive: true);
          final filePath = '$directory/payment_receipt_${DateTime.now().millisecondsSinceEpoch}.png';
          final file = File(filePath);
          await file.writeAsBytes(pngBytes);

          // Show a snackbar or toast indicating the image has been saved
          CustomSnackbar.showSnackbar('Receipt saved successfully');
        }
      } else {
        // Permission denied
        CustomSnackbar.showSnackbar('Storage permission is required to save the receipt');
      }
    } catch (e) {
      printLogs(e.toString());
    }
  }

  static Future<bool> _requestStoragePermission() async {
    PermissionStatus status = await Permission.storage.request();
    return status.isGranted;
  }

  static void closeDialogAndSnackbar() {
    // Close any open snackbars
    printLogs('========isSnackbarOpen ${Get.isSnackbarOpen} ====dialog ${Get.isDialogOpen}');
    if (Get.isSnackbarOpen) {
      // await Get.closeCurrentSnackbar();
      Get.closeAllSnackbars();
    }
    // Close the dialog
    if (Get.isDialogOpen ?? false) {
      Get.back();
    }
  }

  /// fn to get date object by DateTime UTC
  static DateTime formatAndParseDateTime(DateTime dateTime) {
    print('================dateTime $dateTime');
    String formattedString = DateFormat("yyyy-MM-dd HH:mm:ss").format(dateTime);
    return DateFormat("yyyy-MM-dd HH:mm:ss").parseUtc(formattedString);
  }

  static String getTimeStatus(DateTime endTime) {
    DateTime dateTime = formatAndParseDateTime(endTime);
    final difference = dateTime.difference(DateTime.now().isUtc ? DateTime.now() : DateTime.now().toUtc());

    if (difference.isNegative) {
      return 'Expired';
    }

    if (difference.inHours > 0) {
      if (difference.inHours % 60 > 0) {
        int remainingMinutes = difference.inMinutes % 60;
        return difference.inHours == 1
            ? '${difference.inHours} HOUR : $remainingMinutes MINUTES'
            : '${difference.inHours} HOURS : $remainingMinutes MINUTES';
      }
      return difference.inHours == 1 ? '${difference.inHours} HOUR' : '${difference.inHours} HOURS';
    } else if (difference.inMinutes > 0) {
      return difference.inMinutes == 1 ? '${difference.inMinutes} MINUTE' : '${difference.inMinutes} MINUTES';
    } else {
      return difference.inSeconds == 1 ? '${difference.inSeconds} SECOND' : '${difference.inSeconds} SECONDS';
    }
  }

  static Future<void> clearAppCache() async {
    final cacheDir = await getTemporaryDirectory();

    if (cacheDir.existsSync()) {
      try {
        cacheDir.listSync().forEach((file) {
          try {
            if (file is File) {
              file.deleteSync();
            } else if (file is Directory) {
              file.deleteSync(recursive: true);
            }
          } catch (e) {
            print('Error deleting file: $e');
          }
        });
        print("✅ Cache cleared!");
      } catch (e) {
        print("❌ Error while clearing cache: $e");
      }
    }
  }

// Function to show the dark-themed dialog when user attempts to logout
  static void showLogoutWarningDialog({required VoidCallback? onLogoutPressed}) {
    Get.dialog(
      Builder(
        builder: (context) => CupertinoTheme(
          data: CupertinoThemeData(
            brightness: Brightness.dark,
            primaryColor: CupertinoColors.systemBlue,
            textTheme: CupertinoTextThemeData(
              textStyle: TextStyle(color: CupertinoColors.white),
              actionTextStyle: TextStyle(color: CupertinoColors.systemBlue),
            ),
          ),
          child: CupertinoAlertDialog(
            title: Text(
              'Warning',
              style: TextStyle(color: CupertinoColors.white),
            ),
            content: Text(
              'Logging out will delete all videos that are in progress or failed to upload. These videos are currently stored on your device. Complete your uploads before signing out to save your content.',
              style: TextStyle(color: CupertinoColors.white),
            ),
            actions: [
              CupertinoDialogAction(
                child: Text('Cancel'),
                onPressed: () {
                  Get.back(); // Close the dialog
                },
              ),
              CupertinoDialogAction(isDestructiveAction: true, child: Text('Logout Anyway'), onPressed: onLogoutPressed),
            ],
          ),
        ),
      ),
      barrierDismissible: false, // User must choose an option
    );
  }
}

printLogs(String msg) {
  // if (kDebugMode) {
  debugPrint("====log====$msg");

  // }
}

printToFirebase(String msg) {
  FirebaseAnalytics.instance.logEvent(name: "logs_user_${SessionService().user?.id}", parameters: {"message": msg});
}

myMethodNew(String message) {}
