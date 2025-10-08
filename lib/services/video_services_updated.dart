// import 'dart:async';
// import 'dart:developer';
// import 'dart:io' as io;
// import 'dart:io';
//
// import 'package:camerawesome/camerawesome_plugin.dart';
// import 'package:device_info_plus/device_info_plus.dart';
// import 'package:ffmpeg_kit_flutter/ffmpeg_kit.dart';
// import 'package:ffmpeg_kit_flutter/ffmpeg_kit_config.dart';
// import 'package:ffmpeg_kit_flutter/ffprobe_kit.dart';
// import 'package:ffmpeg_kit_flutter/return_code.dart';
// import 'package:ffmpeg_kit_flutter/session.dart';
// import 'package:flutter/foundation.dart';
// import 'package:flutter/services.dart';
// import 'package:get/get.dart';
// import 'package:mime/mime.dart';
// import 'package:path_provider/path_provider.dart';
// import 'package:permission_handler/permission_handler.dart';
// import 'package:saver_gallery/saver_gallery.dart';
// import 'package:socials_app/services/http_client.dart';
// import 'package:socials_app/services/notification_sevices.dart';
// import 'package:socials_app/utils/common_code.dart';
// import 'package:socials_app/views/screens/profile/controller/profile_controller.dart';
// import 'package:video_thumbnail/video_thumbnail.dart';
//
// import 'custom_snackbar.dart';
// import 'permission_service.dart';
//
// class VideoServices {
//   Future<void> mergeVideosOld({
//     required List<String> videoPaths,
//     required String outputPath,
//     required Function(double) onProgress,
//     required Function(String) onMergeComplete,
//   }) async {
//     try {
//       // Check and add silent audio to videos without audio
//       final tempList = await checkAndAddSilentAudio(videoPaths);
//       videoPaths = tempList;
//
//       // Build input string for FFmpeg
//       final inputs = videoPaths.map((path) => '-i "$path"').join(' ');
//       final filterComplex = 'concat=n=${videoPaths.length}:v=1:a=1 [v] [a]';
//
//       // Simplified command without preset option
//       final arguments = '-y $inputs -filter_complex "$filterComplex" -map "[v]" -map "[a]" -r 30 $outputPath';
//
//       // Create a completer to properly handle async completion
//       final completer = Completer<void>();
//
//       // Execute FFmpeg command
//       final session = await FFmpegKit.executeAsync(
//         arguments,
//         (sessionComplete) async {
//           final returnCode = await sessionComplete.getReturnCode();
//           if (ReturnCode.isSuccess(returnCode)) {
//             // Verify the file exists and has size > 0
//             final outputFile = File(outputPath);
//             if (await outputFile.exists() && await outputFile.length() > 0) {
//               onMergeComplete(outputPath);
//               completer.complete();
//             } else {
//               completer.completeError('Output file is empty or does not exist');
//             }
//           } else {
//             final logs = await sessionComplete.getAllLogs();
//             final errorMessage = logs.map((log) => log.getMessage()).join('\n');
//             if (kDebugMode) {
//               printLogs('FFmpeg error logs: $errorMessage');
//             }
//             completer.completeError('FFmpeg error: $errorMessage');
//           }
//         },
//         (logCallback) {
//           // Log FFmpeg output for debugging
//           if (kDebugMode) {
//             printLogs('FFmpeg log: ${logCallback.getMessage()}');
//           }
//         },
//         (statisticsCallback) async {
//           final timeInMilliseconds = statisticsCallback.getTime();
//           final totalVideoDuration = videoPaths.length * 1000;
//           final progress = timeInMilliseconds / totalVideoDuration;
//           onProgress(progress.clamp(0.0, 1.0));
//         },
//       );
//
//       // Add timeout to prevent hanging
//       await completer.future.timeout(
//         Duration(seconds: 30 * videoPaths.length), // Adjust timeout based on number of videos
//         onTimeout: () {
//           throw Exception('Video merge operation timed out');
//         },
//       );
//     } catch (e) {
//       if (kDebugMode) {
//         printLogs('Error merging videos: $e');
//       }
//       throw Exception('Failed to merge videos: $e');
//     }
//   }
//
//   Future<void> mergeVideosAndroid({
//     required List<String> videoPaths,
//     required String outputPath,
//     required Function(double) onProgress,
//     required Function(String) onMergeComplete,
//   }) async {
//     try {
//       // Check and add silent audio to videos without audio
//       final tempList = await checkAndAddSilentAudio(videoPaths);
//       videoPaths = tempList;
//
//       // Calculate total duration for better progress tracking
//       double totalDuration = 0;
//       for (final path in videoPaths) {
//         final mediaInfo = await FFprobeKit.getMediaInformation(path);
//         final duration = double.tryParse(mediaInfo.getMediaInformation()?.getDuration() ?? '0') ?? 0;
//         totalDuration += duration;
//       }
//
//       // Build input string for FFmpeg
//       final inputs = videoPaths.map((path) => '-i "$path"').join(' ');
//       final filterComplex = 'concat=n=${videoPaths.length}:v=1:a=1 [v] [a]';
//
//       // Add specific encoding parameters for better compatibility
//       final arguments = '''
//       -y $inputs
//       -filter_complex "$filterComplex"
//       -map "[v]" -map "[a]"
//       -c:a aac
//       -r 30
//       "$outputPath"
//     '''
//           .replaceAll('\n', ' ')
//           .trim();
//
//       double lastProgress = 0;
//       final completer = Completer<void>();
//
//       final session = await FFmpegKit.executeAsync(
//         arguments,
//         (session) async {
//           final returnCode = await session.getReturnCode();
//
//           if (ReturnCode.isSuccess(returnCode)) {
//             final outputFile = File(outputPath);
//             if (await outputFile.exists() && await outputFile.length() > 0) {
//               // Ensure final progress is shown
//               if (lastProgress < 1.0) {
//                 onProgress(1.0);
//               }
//               onMergeComplete(outputPath);
//               completer.complete();
//             } else {
//               completer.completeError('Output file is empty or does not exist');
//               printLogs('===========Output file is empty or does not exist');
//             }
//           } else {
//             final logs = await session.getAllLogs();
//             completer.completeError('FFmpeg error: ${logs.map((log) => log.getMessage()).join('\n')}');
//             printLogs('======FFmpeg error: ${logs.map((log) => log.getMessage()).join('\n')}');
//           }
//         },
//         (log) {
//           // if (kDebugMode) {
//           printLogs('======FFmpeg log: ${log.getMessage()}');
//           // }
//         },
//         (statistics) {
//           if (totalDuration > 0) {
//             final timeInSeconds = statistics.getTime() / 1000;
//             final progress = (timeInSeconds / totalDuration).clamp(0.0, 1.0);
//
//             // Only update if progress has meaningfully changed
//             if (progress - lastProgress >= 0.01) {
//               lastProgress = progress;
//               onProgress(progress);
//             }
//           }
//         },
//       );
//
//       // Add timeout with some buffer time
//       final timeoutDuration = Duration(seconds: (30 * videoPaths.length).clamp(60, 300));
//       printLogs('===========timeoutDuration ${timeoutDuration}');
//       await completer.future.timeout(
//         timeoutDuration,
//         onTimeout: () {
//           session.cancel();
//           throw Exception('Video merge operation timed out after ${timeoutDuration.inSeconds} seconds');
//         },
//       );
//     } catch (e) {
//       // if (kDebugMode) {
//       printLogs('Error merging videos: $e');
//       // }
//       throw Exception('Failed to merge videos: $e');
//     }
//   }
//
//   Future<void> mergeVideos({
//     required List<String> videoPaths,
//     required String outputPath,
//     required Function(double) onProgress,
//     required Function(String) onMergeComplete,
//   }) async {
//     try {
//       // Check and add silent audio to videos without audio
//       final tempList = await checkAndAddSilentAudio(videoPaths);
//       videoPaths = tempList;
//
//       // Calculate total duration for better progress tracking
//       double totalDuration = 0;
//       for (final path in videoPaths) {
//         final mediaInfo = await FFprobeKit.getMediaInformation(path);
//         final duration = double.tryParse(mediaInfo.getMediaInformation()?.getDuration() ?? '0') ?? 0;
//         totalDuration += duration;
//       }
//
//       // Build input string for FFmpeg
//       final inputs = videoPaths.map((path) => '-i "$path"').join(' ');
//       final filterComplex = 'concat=n=${videoPaths.length}:v=1:a=1 [v] [a]';
//
//       // Simplified FFmpeg command with basic supported flags
//       final arguments = '''
//     -y $inputs
//     -filter_complex "$filterComplex"
//     -map "[v]"
//     -map "[a]"
//     -c:v mpeg4
//     -b:v 20M
//     -g 30
//     -threads 0
//     -c:a aac
//     -b:a 192k
//     "$outputPath"
//   '''
//           .replaceAll('\n', ' ')
//           .trim();
//       double lastProgress = 0;
//       final completer = Completer<void>();
//
//       final session = await FFmpegKit.executeAsync(
//         arguments,
//         (session) async {
//           final returnCode = await session.getReturnCode();
//
//           if (ReturnCode.isSuccess(returnCode)) {
//             final outputFile = File(outputPath);
//             if (await outputFile.exists() && await outputFile.length() > 0) {
//               onProgress(1.0);
//               onMergeComplete(outputPath);
//               completer.complete();
//             } else {
//               completer.completeError('Output file is empty or does not exist');
//               printLogs('=======Output file is empty or does not exist');
//             }
//           } else {
//             final logs = await session.getAllLogsAsString();
//             completer.completeError('FFmpeg error: $logs');
//             printLogs('========FFmpeg error: $logs');
//           }
//         },
//         (log) => printLogs('FFmpeg log: ${log.getMessage()}'),
//         (statistics) {
//           if (totalDuration > 0) {
//             final timeInSeconds = statistics.getTime() / 1000;
//             final progress = (timeInSeconds / totalDuration).clamp(0.0, 1.0);
//
//             if (progress - lastProgress >= 0.01) {
//               lastProgress = progress;
//               onProgress(progress);
//             }
//           }
//         },
//       );
//
//       // Increased timeout for high-quality processing
//       final timeoutDuration = Duration(seconds: (90 * videoPaths.length).clamp(180, 1200));
//       printLogs('===========timeoutDuration ${timeoutDuration}');
//       await completer.future.timeout(
//         timeoutDuration,
//         onTimeout: () {
//           session.cancel();
//           throw Exception('Video merge operation timed out after ${timeoutDuration.inSeconds} seconds');
//         },
//       );
//     } catch (e) {
//       printLogs('Error merging videos: $e');
//       throw Exception('Failed to merge videos: $e');
//     }
//   }
//
//   Future<List<String>> checkAndAddSilentAudio(List<String> videoPaths) async {
//     final tempList = <String>[];
//     final Directory appDirectory = await getApplicationDocumentsDirectory();
//     final String videoDirectory = '${appDirectory.path}/Videos';
//
//     for (var path in videoPaths) {
//       final mediaInformationSession = await FFprobeKit.getMediaInformation(path);
//       final mediaInformation = mediaInformationSession.getMediaInformation();
//       final hasAudio = mediaInformation?.getStreams().any((stream) => stream.getType() == 'audio');
//
//       if (hasAudio == false) {
//         final outputPath = '$videoDirectory/with_audio_${DateTime.now().millisecondsSinceEpoch}.mp4';
//
//         await FFmpegKit.execute(
//           '-i $path -f lavfi -i anullsrc=channel_layout=stereo:sample_rate=44100 -c:v copy -c:a aac -shortest $outputPath',
//         );
//
//         tempList.add(outputPath);
//       } else {
//         tempList.add(path);
//       }
//     }
//
//     return tempList;
//   }
//
//   /// fn to mute the audio of the video
//   Future<void> muteVideo(String videoPath) async {
//     // Temporary output path
//     final tempOutputPath = videoPath.replaceAll('.mp4', '_temp.mp4');
//
//     // Execute FFmpeg command to mute the audio and save to a temporary file
//     final command = '-i $videoPath -c copy -an $tempOutputPath';
//     final returnCode = await FFmpegKit.execute(command);
//     if (ReturnCode.isSuccess(await returnCode.getReturnCode())) {
//       // Follow up with renaming
//       final originalFile = File(videoPath);
//       final tempFile = File(tempOutputPath);
//       await originalFile.delete();
//       await tempFile.rename(videoPath);
//     } else if (ReturnCode.isCancel(await returnCode.getReturnCode())) {
//     } else {}
//   }
//
//   /// fn to genrate iutput file
//   Future<String?> getOutputPath() async {
//     final appDirectory = Platform.isIOS ? await getApplicationDocumentsDirectory() : await getExternalStorageDirectory();
//     // final Directory appDirectory = await getApplicationDocumentsDirectory();
//     printLogs('==================appDirectory ${appDirectory?.path}');
//     final String videoDirectory = '${appDirectory?.path}/Videos';
//     await Directory(videoDirectory).create(recursive: true);
//     final String currentTime = DateTime.now().millisecondsSinceEpoch.toString();
//     final String filePath = '$videoDirectory/$currentTime.mp4';
//     printLogs('==========Video will be saved to: $filePath');
//     return filePath;
//   }
//
//   void deleteFile(String filePath) {
//     final file = File(filePath);
//     if (file.existsSync()) {
//       file.deleteSync();
//       printLogs('File deleted: $filePath');
//     } else {
//       printLogs('File not found: $filePath');
//     }
//   }
//
//   /// fn to check if dual camera is available
//   static Future<bool> isDualCameraAvailable() async {
//     return await CamerawesomePlugin.isMultiCamSupported();
//   }
//
//   /// Request camera permission
//   static Future<void> requestCameraPermission() async {
//     await PermissionsService().requestCameraPermission(
//       onPermissionDenied: () {
//         CustomSnackbar.showSnackbar('Camera permission denied');
//       },
//       onPermissionGranted: () {
//         // CustomSnackbar.showSnackbar('Camera permission granted');
//       },
//     );
//   }
//
//   //// save the video to the device Downloads directory
//   Future<File?> saveFile(String outputPath) async {
//     try {
//       if (Platform.isAndroid) {
//         //// save the file to download folder
//         final dir = await getExternalStorageDirectory();
//         final downFolder = "${dir?.path.split("Android")[0]}Download";
//         final file = File(outputPath);
//         final newPath = '$downFolder/${DateTime.now().millisecondsSinceEpoch}_output.mp4';
//         await file.copy(newPath);
//
//         return File(newPath);
//       } else {
//         final dir = await getApplicationDocumentsDirectory();
//         final file = File(outputPath);
//         final newPath = '${dir.path}/${DateTime.now().millisecondsSinceEpoch}_output.mp4';
//         await file.copy(newPath);
//
//         return File(newPath);
//       }
//     } catch (e) {
//       CustomSnackbar.showSnackbar('Failed to save/Share file');
//       return null;
//     }
//   }
//
//   /// fn to get video thumbnail from video url
//
//   Future<Uint8List?> getThumbnailData(String videoUrl) async {
//     final uint8List = await VideoThumbnail.thumbnailData(
//       video: videoUrl,
//       imageFormat: ImageFormat.PNG,
//       maxWidth: 128,
//       quality: 25,
//     );
//     return uint8List;
//   }
//
//   /// compress video file
//   Future<String?> compressVideo(String videoPath) async {
//     final Directory appDirectory = await getApplicationDocumentsDirectory();
//     final String videoDirectory = '${appDirectory.path}/Videos';
//     final outputPath = '$videoDirectory/compressed_${DateTime.now().millisecondsSinceEpoch}.mp4';
//     FFmpegKit.executeAsync("-y -i $videoPath -vcodec libx264 -crf 22 $outputPath", (Session session) async {
//       final returnCode = await session.getReturnCode();
//       if (ReturnCode.isSuccess(returnCode)) {
//         // final result = await saveFile(outputPath);
//         // return result?.path;
//         //SUCCESS
//       } else if (ReturnCode.isCancel(returnCode)) {
//         // CANCEL
//       } else {
//         FFmpegKitConfig.enableLogCallback((log) {
//           final message = log.getMessage();
//           if (kDebugMode) {
//             printLogs(message);
//           }
//         });
//         // ERROR
//       }
//     });
//     return null;
//   }
//
//   Future<bool> downloadVideo({
//     required String videoUrl,
//     required NotificationService notificationService,
//   }) async {
//     try {
//       // Initialize notifications and request permission
//       ProfileScreenController profileController = Get.isRegistered() ? Get.find<ProfileScreenController>() : Get.put(ProfileScreenController());
//       await notificationService.initializeNotifications();
//       await notificationService.requestNotificationPermission();
//       final deviceInfoPlugin = DeviceInfoPlugin();
//       final deviceInfo = await deviceInfoPlugin.deviceInfo;
//       final allInfo = deviceInfo.data;
//       // log("Device Info: ${allInfo['version']['release']}");
//
//       // final httpClient = http.Client();
//       // final request = http.Request('GET', Uri.parse(videoUrl));
//       // final response = await httpClient.send(request);
//
//       // final contentLength = response.contentLength ?? 0;
//       int bytesReceived = 0;
//
//       final savedVideoDirectory = Platform.isIOS ? await getApplicationDocumentsDirectory() : await getExternalStorageDirectory();
//       final videoDirectory = "${savedVideoDirectory?.path}/Download/vupop";
//       await Directory(videoDirectory).create(recursive: true);
//
//       String fileName = "${DateTime.now().millisecondsSinceEpoch}.mp4";
//       final videoPath = '$videoDirectory/$fileName';
//       final file = File(videoPath);
//       await HTTPClient()
//           .downloadFileWithProgress(
//               url: videoUrl,
//               savePath: videoPath,
//               onProgress: (received, total) async {
//                 final progress = (received / total * 100).toInt().toStringAsFixed(2);
//                 if (kDebugMode) {
//                   printLogs('Download progress: $progress');
//                 }
//                 if (kDebugMode) {
//                   printLogs('Download (received / total * 100).toInt(): ${(received / total * 100).toInt()}');
//                 }
//                 bytesReceived = received;
//                 await notificationService.showDownloadNotification(
//                     title: 'Downloading video',
//                     body: 'Downloaded ${progress} ',
//                     progress: (received / total * 100).toInt(),
//                     ongoing: false,
//                     silent: true);
//                 if ((progress) == "100.00") {
//                   if (Platform.isAndroid) {
//                     if (int.parse(allInfo['version']['release']) < 11) {
//                       var status = await Permission.storage.request();
//                       if (status.isGranted) {
//                         await saveVideoForAndroid(videoPath: file.path, fileName: fileName);
//                       } else {
//                         CustomSnackbar.showSnackbar('Permission Not Allowed');
//                       }
//                     } else {
//                       var status1 = await Permission.manageExternalStorage.request();
//                       if (kDebugMode) {
//                         printLogs("${status1.isGranted}");
//                       }
//                       if (status1.isGranted) {
//                         await saveVideoForAndroid(videoPath: file.path, fileName: fileName);
//                       } else {
//                         await Permission.storage.request();
//                         await saveVideoForAndroid(videoPath: file.path, fileName: fileName);
//                       }
//                     }
//                   } else if (Platform.isIOS) {
//                     if (await requestIOSPermissions()) {
//                       await saveVideoForIOSWatermark(videoPath: file.path, fileName: fileName);
//                     } else {
//                       CustomSnackbar.showSnackbar('Permission Not Allowed');
//                     }
//
//                     // await saveVideoForIOS(videoPath: file.path, name: '${DateTime.now().millisecondsSinceEpoch}.mp4');
//                   }
//                   await notificationService.showDownloadNotification(
//                     title: 'Download complete',
//                     body: 'Video downloaded successfully',
//                     progress: 101,
//                     ongoing: false,
//                   );
//                 }
//               })
//           .then((value) async {
//         await notificationService.showDownloadNotification(
//           title: 'Download complete',
//           body: 'Video downloaded successfully',
//           progress: 100,
//         );
//       });
//
//       return true;
//     } catch (e) {
//       if (kDebugMode) {
//         printLogs('Failed to download video: ${e.toString()}');
//       }
//
//       // Show error notification
//       await notificationService.showDownloadNotification(
//         title: 'Download failed',
//         body: 'Failed to download video',
//       );
//
//       return false;
//     }
//   }
//
//   Future<void> saveVideoForAndroid({required String videoPath, required String fileName}) async {
//     if (videoPath.isEmpty) {
//       if (kDebugMode) {
//         printLogs('Video path is empty');
//       }
//       return;
//     }
//     try {
//       final savedVideoDirectory = await getExternalStorageDirectory();
//       String videoDirectory = "${savedVideoDirectory?.path.split('Android')[0]}Download/vupop/";
//       if (!await io.Directory(videoDirectory).exists()) {
//         log("Directory not exist");
//         io.Directory(videoDirectory).createSync(recursive: true);
//       }
//       final newVideoPath = '$videoDirectory${DateTime.now().millisecondsSinceEpoch}.mp4';
//       final waterMarkVideoPath = '${videoDirectory}vp${DateTime.now().millisecondsSinceEpoch}.mp4';
//       File newFile = await io.File(videoPath).copy(newVideoPath);
//       if (kDebugMode) {
//         printLogs('File copied successfully to: ${newFile.path}');
//       }
//       await io.File(videoPath).delete();
//       if (newFile.path.isNotEmpty) {
//         await CommonCode.applyWatermark(videoPath: newVideoPath, waterMarkVideoPath: waterMarkVideoPath);
//       }
//     } catch (e) {
//       if (kDebugMode) {
//         printLogs('Error saving video to gallery: $e');
//       }
//     }
//   }
//
//   Future<void> saveVideoForIOSWatermark({required String videoPath, required String fileName}) async {
//     if (videoPath.isEmpty) return;
//
//     try {
//       final directory = await getApplicationDocumentsDirectory();
//       String videoDirectory = "${directory.path}/Download/vupop/";
//
//       if (!await Directory(videoDirectory).exists()) {
//         Directory(videoDirectory).createSync(recursive: true);
//       }
//
//       final newVideoPath = '$videoDirectory${DateTime.now().millisecondsSinceEpoch}.mp4';
//       final waterMarkVideoPath = '${videoDirectory}vp${DateTime.now().millisecondsSinceEpoch}.mp4';
//
//       File newFile = await File(videoPath).copy(newVideoPath);
//       await File(videoPath).delete();
//
//       if (newFile.path.isNotEmpty) {
//         await CommonCode.applyWatermark(videoPath: newVideoPath, waterMarkVideoPath: waterMarkVideoPath);
//
//         // Save to Photos
//         final result = await SaverGallery.saveFile(filePath: waterMarkVideoPath, fileName: waterMarkVideoPath.split("vp")[1], skipIfExists: false);
//         if (result.isSuccess) {
//           printLogs('Video saved to gallery successfully');
//         }
//       }
//     } catch (e) {
//       if (kDebugMode) {
//         printLogs('Error saving video: $e');
//       }
//     }
//   }
//
//   Future<void> saveVideoForIOSWithWatermark({required String videoPath, required String fileName}) async {
//     if (videoPath.isEmpty) {
//       if (kDebugMode) {
//         printLogs('Video path is empty');
//       }
//       return;
//     }
//
//     try {
//       final directory = await getApplicationDocumentsDirectory();
//       String videoDirectory = "${directory.path}/Download/vupop/";
//
//       if (!await Directory(videoDirectory).exists()) {
//         Directory(videoDirectory).createSync(recursive: true);
//       }
//
//       final newVideoPath = '$videoDirectory${DateTime.now().millisecondsSinceEpoch}.mp4';
//       final waterMarkVideoPath = '${videoDirectory}vp${DateTime.now().millisecondsSinceEpoch}.mp4';
//
//       File newFile = await File(videoPath).copy(newVideoPath);
//       await File(videoPath).delete();
//
//       if (newFile.path.isNotEmpty) {
//         await CommonCode.applyWatermark(videoPath: newVideoPath, waterMarkVideoPath: waterMarkVideoPath);
//       }
//     } catch (e) {
//       if (kDebugMode) {
//         printLogs('Error saving video: $e');
//       }
//     }
//   }
//
//   Future<bool> requestIOSPermissions() async {
//     // Define the platform channel
//     const platform = MethodChannel('com.vupop.permission');
//     bool isGranted = false;
//     try {
//       final result = await platform.invokeMethod('requestPermissions');
//       if (result == "granted") {
//         if (kDebugMode) {
//           printLogs("Permissions granted!");
//         }
//         isGranted = true;
//       } else {
//         if (kDebugMode) {
//           printLogs("Permissions denied or restricted.");
//         }
//       }
//       return isGranted;
//     } on PlatformException catch (e) {
//       if (kDebugMode) {
//         printLogs("Failed to request permissions: ${e.message}");
//       }
//       return isGranted;
//     }
//   }
//
//   Future<bool> checkIOSPermissions() async {
//     // iOS requires photo library permission for saving videos
//     var status = await Permission.photos.status;
//
//     if (status.isDenied) {
//       status = await Permission.photos.request();
//     }
//
//     // Also check microphone permissions if needed
//     var micStatus = await Permission.microphone.status;
//     if (micStatus.isDenied) {
//       micStatus = await Permission.microphone.request();
//     }
//
//     return status.isGranted && micStatus.isGranted;
//   }
//
//   // Save video for iOS
//   Future<void> saveVideoForIOS({required String videoPath, required String name}) async {
//     if (videoPath.isEmpty) {
//       if (kDebugMode) {
//         printLogs('Video path is empty');
//       }
//       return;
//     }
//     try {
//       final result = await SaverGallery.saveFile(
//         filePath: videoPath,
//         fileName: name,
//         skipIfExists: false,
//       );
//       if (result.isSuccess) {
//         if (kDebugMode) {
//           printLogs('Video saved to gallery successfully');
//         }
//       } else {
//         if (kDebugMode) {
//           printLogs('Failed to save video to gallery');
//         }
//       }
//     } catch (e) {
//       if (kDebugMode) {
//         printLogs('Error saving video to gallery: $e');
//       }
//     }
//   }
//
//   // Save video temporarily for Android
//   Future<String?> saveVideoForAndroidTemp({required String videoPath}) async {
//     if (videoPath.isEmpty) {
//       return null;
//     }
//     try {
//       final savedVideoDirectory = await getExternalStorageDirectory();
//       String videoDirectory = "${savedVideoDirectory?.path.split('Android')[0]}Download/vupop/temp/";
//       if (!await io.Directory(videoDirectory).exists()) {
//         log("Directory not exist");
//         io.Directory(videoDirectory).createSync(recursive: true);
//       }
//       final newVideoPath = '$videoDirectory/${DateTime.now().millisecondsSinceEpoch}.mp4';
//       await io.File(videoPath).copy(newVideoPath);
//
//       deleteFile(videoPath);
//       return newVideoPath;
//     } catch (e) {
//       return null;
//     }
//   }
//
//   // Save video temporarily for iOS
//   Future<String?> saveVideoForIOSTemp({required String videoPath}) async {
//     if (videoPath.isEmpty) {
//       return null;
//     }
//     try {
//       final tempDir = await getTemporaryDirectory();
//       String videoDirectory = '${tempDir.path}/vupop/temp/';
//       if (!await io.Directory(videoDirectory).exists()) {
//         log("Directory not exist");
//         io.Directory(videoDirectory).createSync(recursive: true);
//       }
//       final newVideoPath = '$videoDirectory/${DateTime.now().millisecondsSinceEpoch}.mp4';
//       await io.File(videoPath).copy(newVideoPath);
//       deleteFile(videoPath);
//       return newVideoPath;
//     } catch (e) {
//       return null;
//     }
//   }
//
//   // Get list of temporary videos for Android
//   Future<List<String>> getTempVideosForAndroid() async {
//     final savedVideoDirectory = await getExternalStorageDirectory();
//     String videoDirectory = "${savedVideoDirectory?.path.split('Android')[0]}Download/vupop/temp/";
//     if (!await io.Directory(videoDirectory).exists()) {
//       return [];
//     }
//     final videos = io.Directory(videoDirectory).listSync().where((element) => element.path.endsWith('.mp4')).map((e) => e.path).toList();
//     return videos;
//   }
//
//   // Get list of temporary videos for iOS
//   Future<List<String>> getTempVideosForIOS() async {
//     final tempDir = await getTemporaryDirectory();
//     String videoDirectory = '${tempDir.path}/vupop/temp/';
//     if (!await io.Directory(videoDirectory).exists()) {
//       return [];
//     }
//     final videos = io.Directory(videoDirectory).listSync().where((element) => element.path.endsWith('.mp4')).map((e) => e.path).toList();
//     return videos;
//   }
//
//   // Remove a specific temp video for Android and iOS
//   Future<void> removeTempVideo(String videoPath) async {
//     if (await io.File(videoPath).exists()) {
//       io.File(videoPath).deleteSync();
//     }
//   }
//
//   // Clear temp directory for Android
//   Future<void> clearTempDirectoryForAndroid() async {
//     final savedVideoDirectory = await getExternalStorageDirectory();
//     String videoDirectory = "${savedVideoDirectory?.path.split('Android')[0]}Download/vupop/temp/";
//     if (await io.Directory(videoDirectory).exists()) {
//       io.Directory(videoDirectory).deleteSync(recursive: true);
//     }
//   }
//
//   // Clear temp directory for iOS
//   Future<void> clearTempDirectoryForIOS() async {
//     final tempDir = await getTemporaryDirectory();
//     String videoDirectory = '${tempDir.path}/vupop/temp/';
//     if (await io.Directory(videoDirectory).exists()) {
//       io.Directory(videoDirectory).deleteSync(recursive: true);
//     }
//   }
//
//   /// code for geting local details
//   Future<Map<String, dynamic>> getLocalVideoDetails(String videoPath) async {
//     File file = File(videoPath);
//
//     if (!await file.exists()) {
//       throw Exception("File does not exist");
//     }
//
//     int fileSize = await file.length();
//     String? mimeType = lookupMimeType(videoPath);
//     bool hasAudio = false;
//     String orientation = "Portrait";
//     int width = 0, height = 0;
//     String? latitude;
//     String? longitude;
//
//     // Get video resolution and orientation
//     await FFprobeKit.execute('-i "$videoPath" -show_streams -select_streams v -loglevel error -show_entries stream=width,height')
//         .then((session) async {
//       final logs = await session.getLogs();
//       String logsText = logs.map((log) => log.getMessage()).join("\n");
//
//       RegExp widthExp = RegExp(r'width=(\d+)');
//       RegExp heightExp = RegExp(r'height=(\d+)');
//
//       Match? widthMatch = widthExp.firstMatch(logsText);
//       Match? heightMatch = heightExp.firstMatch(logsText);
//
//       if (widthMatch != null && heightMatch != null) {
//         width = int.parse(widthMatch.group(1)!);
//         height = int.parse(heightMatch.group(1)!);
//         orientation = width > height ? "Landscape" : "Portrait";
//       }
//     });
//
//     // Check if video contains audio
//     await FFprobeKit.execute('-i "$videoPath" -show_streams -select_streams a -loglevel error').then((session) async {
//       final logs = await session.getLogs();
//       hasAudio = logs.isNotEmpty;
//     });
//
//     // Get video duration
//     final duration2 = await getVideoDuration(videoPath) ?? 0;
//
//     // Extract GPS location metadata (if available)
//     await FFprobeKit.execute('-i "$videoPath" -show_entries format_tags=com.apple.quicktime.location.ISO6709 -v quiet -of csv="p=0"')
//         .then((session) async {
//       final logs = await session.getLogs();
//       if (logs.isNotEmpty) {
//         String gpsData = logs.first.getMessage().trim();
//
//         // Example format: "+37.7749-122.4194/"
//         RegExp gpsPattern = RegExp(r'([\+\-]\d+\.\d+)([\+\-]\d+\.\d+)');
//         Match? match = gpsPattern.firstMatch(gpsData);
//
//         if (match != null) {
//           latitude = match.group(1);
//           longitude = match.group(2);
//         }
//       }
//     });
//
//     return {
//       "mimeType": mimeType,
//       "fileSize": fileSize, // in bytes
//       "duration": duration2,
//       "hasAudio": hasAudio,
//       "width": width,
//       "height": height,
//       "orientation": orientation, // "Portrait" or "Landscape"
//       "latitude": latitude,
//       "longitude": longitude,
//     };
//   }
//
//   Future<int?> getVideoDuration(String videoPath) async {
//     int? duration;
//
//     await FFprobeKit.execute('-i "$videoPath" -show_entries format=duration -v quiet -of csv="p=0"').then((session) async {
//       final logs = await session.getLogs();
//       if (logs.isNotEmpty) {
//         String logMessage = logs.first.getMessage().trim();
//         duration = double.tryParse(logMessage)?.toInt(); // Convert to seconds
//       }
//     });
//
//     return duration;
//   }
//
//   /// function for gettting first 20 seconds of video
//   Future<String?> extractFirst20Seconds(String videoPath) async {
//     // Check if the input file exists
//     File inputFile = File(videoPath);
//     if (!await inputFile.exists()) {
//       throw Exception("File does not exist");
//     }
//
//     // Get temporary directory to store output
//     Directory tempDir = await getTemporaryDirectory();
//     String outputPath = "${tempDir.path}/trimmed_video.mp4";
//
//     // FFmpeg command to trim the video
//     String command = '-i "$videoPath" -t 20 -c copy "$outputPath"';
//
//     // Execute the FFmpeg command
//     await FFmpegKit.execute(command).then((session) async {
//       final returnCode = await session.getReturnCode();
//       if (returnCode?.isValueSuccess() == true) {
//         printLogs("Video successfully trimmed: $outputPath");
//       } else {
//         printLogs("Error trimming video: ${await session.getLogs()}");
//         return null;
//       }
//     });
//
//     // Return the output file path
//     return outputPath;
//   }
//
//   Future<String> transcodeVideo(String sourceUrl) async {
//     // Get temporary directory for storing processed video
//     final directory = await getTemporaryDirectory();
//     final outputPath = '${directory.path}/transcoded_${DateTime.now().millisecondsSinceEpoch}.mp4';
//
//     try {
//       // Using flutter_ffmpeg package for transcoding
//       // final FFmpegKit _flutterFFmpeg = FlutterFFmpeg();
//
//       // Command to transcode to a more compatible format
//       // This reduces resolution and uses H.264 codec with AAC audio
//       await FFmpegKit.execute('-i $sourceUrl -c:v libx264 -preset fast -crf 23 '
//               '-vf "scale=1280:720" -c:a aac -b:a 128k $outputPath')
//           .then((session) async {
//         final returnCode = await session.getReturnCode();
//         if (returnCode?.isValueSuccess() == true) {
//           printLogs("Video successfully trimmed: $outputPath");
//         } else {
//           printLogs("Error trimming video: ${await session.getLogs()}");
//           return null;
//         }
//       });
//
//       // if (rc == 0) {
//       return outputPath;
//       /* } else {
//         throw Exception('Transcoding failed with return code $rc');
//       }*/
//     } catch (e) {
//       printLogs('Video transcoding error: $e');
//       // Fall back to original if transcoding fails
//       return sourceUrl;
//     }
//   }
// }
