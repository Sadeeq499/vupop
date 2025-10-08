import 'dart:convert';
import 'dart:io';
import 'dart:ui';

import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:memory_info/memory_info.dart';
import 'package:socials_app/firebase_options.dart';
import 'package:socials_app/services/notification_sevices.dart';
import 'package:socials_app/utils/common_code.dart';
import 'package:socials_app/utils/route_generator.dart';
import 'package:socials_app/views/screens/bottom/controller/bottom_bar_controller.dart';

import 'utils/app_colors.dart';
import 'utils/app_strings.dart';
import 'utils/screen_bindings.dart';

// @pragma('vm:entry-point')
// void callbackDispatcher() {
//   Workmanager().executeTask((task, inputData) async {
//     if (task == "uploadVideo") {
//       // Call the video upload function
//       String? userId = inputData?['userId'];
//       String? videoPath = inputData?['videoPath'];
//       String? thumbnailPath = inputData?['thumbnailFile'];
//       String locationAddress = inputData?['address'];
//       double? lat = inputData?['latitude'];
//       double? lng = inputData?['longitude'];
//       bool isFaceCam = inputData?['facecam'] == 'true';
//       bool isPortrait = inputData?['isPortrait'] == 'true';
//       List<String>? mentions =
//           (inputData?['mentions'] as List<dynamic>?)?.cast<String>();
//       List<String>? tags =
//           (inputData?['tags'] as List<dynamic>?)?.cast<String>();

//       if (videoPath != null && userId != null) {
//         await PostRepo()
//             .createPost(
//           userId: userId,
//           file: File(videoPath),
//           locationAdress: locationAddress,
//           lat: lat ?? 0.0,
//           lng: lng ?? 0.0,
//           mentions: mentions,
//           tags: tags,
//           thumbnailFile: File(thumbnailPath!),
//           isFaceCam: isFaceCam,
//           isPortrait: isPortrait,
//           progress: (progress) async {},
//         )
//             .then((value) {
//           printLogs('Post created');
//         }).catchError((e) {
//           printLogs('Error creating post: $e');
//         });
//       }

//       return Future.value(true);
//     }
//     return Future.value(false);
//   });
// }

String deviceToken = '';

Memory? memoryInfo;
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  await GetStorage.init();
  await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform, name: 'vupop');
  await FirebaseAnalytics.instance.setAnalyticsCollectionEnabled(true);
  FirebaseAnalytics.instance.logAppOpen();
  FlutterError.onError = (flutterErrorDetails) {
    FirebaseCrashlytics.instance.recordFlutterError(flutterErrorDetails);
  };

  PlatformDispatcher.instance.onError = (error, stack) {
    FirebaseCrashlytics.instance.recordError(error, stack);
    return true;
  };

  // Workmanager().initialize(callbackDispatcher, isInDebugMode: true);
  deviceToken = await NotificationService().initNotification() ?? '';
  await getMemoryInfo();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  ThemeData _buildTheme(brightness) {
    var baseTheme = ThemeData(brightness: brightness);

    return baseTheme.copyWith(
      textTheme: GoogleFonts.leagueSpartanTextTheme(baseTheme.textTheme),
      scaffoldBackgroundColor: kBackgroundColor,
      colorScheme: ThemeData().colorScheme.copyWith(primary: kPrimaryColor),
      cupertinoOverrideTheme: const CupertinoThemeData(
        primaryContrastingColor: Colors.white,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(428, 926),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return GetMaterialApp(
            theme: _buildTheme(Brightness.light),
            title: kAppName,
            debugShowCheckedModeBanner: false,
            defaultTransition: Transition.cupertino,
            initialBinding: ScreenBindings(),
            // initialRoute: kSignInRoute,
            initialRoute: kSplashRoute,
            // initialRoute: kFilterRoute,
            getPages: RouteGenerator.getPages(),
            builder: (context, child) {
              return GestureDetector(
                onHorizontalDragStart: Platform.isIOS
                    ? (details) async {
                        // print('===========details.localPosition.dx ${details.localPosition.dx}');
                        // print('===========current route ${Get.routing.current}');
                        // print('===========previous route ${Get.routing.previous}');

                        if ((Get.routing.previous == "/signInScreen" &&
                                Get.routing.current ==
                                    "/SingleCommunityChatScreen") ||
                            details.localPosition.dx > 100) {
                          if (Get.routing.current ==
                              "/SingleCommunityChatScreen") {
                            Get.back();
                          }
                        } else if (details.localPosition.dx < 50) {
                          // printLogs('======Get.routing.current ${Get.routing.current}');
                          // Detect edge swipe
                          if (Get.routing.route?.isFirst == false &&
                              Get.routing.current != "/bottomNavbarScreen") {
                            Get.back();
                          } else if (Get.routing.current ==
                              "/bottomNavbarScreen") {
                            if (Get.isRegistered<BottomBarController>() &&
                                Get.find<BottomBarController>()
                                        .selectedIndex
                                        .value >
                                    0) {
                              Get.find<BottomBarController>()
                                  .selectedIndex
                                  .value = Get.find<BottomBarController>()
                                      .selectedIndex
                                      .value -
                                  1;
                            }
                          }
                        }
                      }
                    : null,
                child: MediaQuery(
                    data: MediaQuery.of(context).copyWith(
                        textScaler: TextScaler.linear(MediaQuery.of(context)
                            .textScaleFactor
                            .clamp(1.0, 1.0))),
                    child: child!),
              );
            });
      },
    );
  }
}

getMemoryInfo() async {
  try {
    Memory memory = await MemoryInfoPlugin().memoryInfo;
    DiskSpace diskSpace = await MemoryInfoPlugin().diskSpace;
    JsonEncoder encoder = JsonEncoder.withIndent('  ');
    memoryInfo = memory;
    printLogs('=============memoryInfo app ${memoryInfo?.appMem}');
    printLogs('=============memoryInfo free ${memoryInfo?.freeMem}');
    printLogs('=============memoryInfo low  ${memoryInfo?.lowMemory}');
    printLogs('=============memoryInfo total ${memoryInfo?.totalMem}');
    printLogs('=============diskSpace freeSpace ${diskSpace.freeSpace}');
    printLogs('=============diskSpace total ${diskSpace.totalSpace}');
    printLogs('=============diskSpace usedSpace ${diskSpace.usedSpace}');
    String memInfo = encoder.convert(memoryInfo?.toMap());
    // printLogs('====================memInfo ${memInfo}');
  } catch (e) {
    printLogs('getMemoryInfo Exception : $e');
  }
}
