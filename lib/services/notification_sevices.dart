import 'dart:convert';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:socials_app/services/throttled_service.dart';
import 'package:socials_app/utils/app_strings.dart';
import 'package:socials_app/utils/common_code.dart';

Future<void> handleBackgroundMessage(RemoteMessage message) async {
  print('===========Title ${message.notification?.title}');
  print('===========Body: ${message.notification?.body}');
  print('===========Payload: ${message.data}');
}

class NotificationService {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
  final ThrottledNotificationService _throttledService;

  NotificationService() : _throttledService = ThrottledNotificationService();

  // Constants for our notification categories
  static const String downloadProgressCategoryId = 'download_progress_category';
  static const String downloadCompleteCategoryId = 'download_complete_category';
  static const String exportNotificationsCategoryId = 'export_notifications_category';
  static const String generalNotificationsCategoryId = 'general_notifications_category';

  Future<void> initializeNotifications() async {
    final List<DarwinNotificationCategory> darwinNotificationCategories = [
      // Progress category - silent in foreground
      DarwinNotificationCategory(
        downloadProgressCategoryId,
        actions: [],
        options: <DarwinNotificationCategoryOption>{
          DarwinNotificationCategoryOption.hiddenPreviewShowTitle,
        },
      ),
      // Completion category - show normally
      DarwinNotificationCategory(
        downloadCompleteCategoryId,
        actions: [],
        options: <DarwinNotificationCategoryOption>{
          DarwinNotificationCategoryOption.hiddenPreviewShowTitle,
        },
      ),
      // Export notifications category
      DarwinNotificationCategory(
        exportNotificationsCategoryId,
        actions: [],
        options: <DarwinNotificationCategoryOption>{
          DarwinNotificationCategoryOption.hiddenPreviewShowTitle,
        },
      ),
      // General notifications category
      DarwinNotificationCategory(
        generalNotificationsCategoryId,
        actions: [],
        options: <DarwinNotificationCategoryOption>{
          DarwinNotificationCategoryOption.hiddenPreviewShowTitle,
        },
      ),
    ];

    const AndroidInitializationSettings initializationSettingsAndroid = AndroidInitializationSettings('@mipmap/ic_launcher');
    DarwinInitializationSettings initializationSettingsIOS = DarwinInitializationSettings(
      requestSoundPermission: true,
      requestBadgePermission: true,
      requestAlertPermission: true,
      defaultPresentAlert: true,
      defaultPresentBadge: true,
      defaultPresentSound: true,
      notificationCategories: darwinNotificationCategories,
    );
    InitializationSettings initializationSettings = InitializationSettings(android: initializationSettingsAndroid, iOS: initializationSettingsIOS);

    await flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  Future<void> sendNotification(String title, String body, String token) async {
    // Send notification to the user with the given token
  }

  Future<void> sendNotificationToAll(String title, String body) async {
    // Send notification to all users
  }

  Future<void> requestNotificationPermission() async {
    var status = await Permission.notification.status;
    if (!status.isGranted) {
      await Permission.notification.request();
    }
  }

  Future<String?> initNotification() async {
    await requestNotificationPermission();

    try {
      final token = await _firebaseMessaging.getToken();
      await initPushNotifications();
      // if (kDebugMode) {
      printLogs('Token initNotification: $token');
      // }
      return token;
    } catch (e) {
      // if (kDebugMode) {
      printLogs('Error initNotification: $e');
      // }
      return null;
    }
  }

  final androidChannel = const AndroidNotificationChannel(
    'high_importance_channel', // id
    'High Importance Notifications', // title
    description: 'This channel is used for important notifications.', // description
    importance: Importance.high,
  );

  void handleMessage(RemoteMessage? message) {
    print('=========handleMessage:: $message');
    if (message == null) return;

    Get.toNamed(kSplashRoute, arguments: message);
  }

  Future<void> initPushNotifications() async {
    await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );

    FirebaseMessaging.instance.getInitialMessage().then(handleMessage);
    FirebaseMessaging.onMessageOpenedApp.listen(handleMessage);
    FirebaseMessaging.onBackgroundMessage(handleBackgroundMessage);
    FirebaseMessaging.onMessage.listen((message) {
      final notification = message.notification;
      if (notification == null) return;

      flutterLocalNotificationsPlugin.show(
          notification.hashCode,
          notification.title,
          notification.body,
          NotificationDetails(
            iOS: const DarwinNotificationDetails(),
            android: AndroidNotificationDetails(
              androidChannel.id,
              androidChannel.name,
              playSound: true, importance: Importance.high,
              channelDescription: androidChannel.description,
              // TODO add a proper drawable resource to android, for now using
              //      one that already exists in example app.
              icon: '@mipmap/ic_launcher',
            ),
          ),
          payload: jsonEncode(message.toMap()));
    });
  }

  /// Common method to show in-app notifications
  /// Can be used throughout the app for different types of notifications
  Future<void> showInAppNotification({
    required String title,
    required String body,
    String channelId = 'general_notifications_channel',
    String channelName = 'General Notifications',
    String? channelDescription,
    Importance importance = Importance.high,
    Priority priority = Priority.high,
    bool playSound = true,
    bool showBadge = true,
    bool showAlert = true,
    String? payload,
    int? customNotificationId,
    String? threadIdentifier,
    String? categoryId,
  }) async {
    try {
      await requestNotificationPermission();

      // Generate a unique notification ID if not provided
      final notificationId = customNotificationId ?? DateTime.now().millisecondsSinceEpoch.remainder(100000);

      final AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
        channelId,
        channelName,
        channelDescription: channelDescription ?? 'Notifications for $channelName',
        importance: importance,
        priority: priority,
        playSound: playSound,
        showWhen: true,
        icon: '@mipmap/ic_launcher',
      );

      final DarwinNotificationDetails iOSDetails = DarwinNotificationDetails(
        presentAlert: showAlert,
        presentBadge: showBadge,
        presentBanner: false,
        presentSound: playSound,
        threadIdentifier: threadIdentifier ?? channelId,
        categoryIdentifier: categoryId,
      );

      final NotificationDetails platformDetails = NotificationDetails(
        android: androidDetails,
        iOS: iOSDetails,
      );

      await flutterLocalNotificationsPlugin.show(
        notificationId,
        title,
        body,
        platformDetails,
        payload: payload,
      );

      if (kDebugMode) {
        printLogs('In-app notification shown: $title - $body');
      }
    } catch (e) {
      if (kDebugMode) {
        printLogs('Error showing in-app notification: $e');
      }
    }
  }

  /// Specific method for export notifications
  Future<void> showExportNotification({
    required String title,
    required String body,
    String? payload,
    int? customNotificationId,
  }) async {
    await showInAppNotification(
      title: title,
      body: body,
      channelId: 'export_notifications_channel',
      channelName: 'Export Notifications',
      channelDescription: 'Notifications for export status updates',
      importance: Importance.high,
      priority: Priority.high,
      playSound: true,
      showBadge: false,
      showAlert: false,
      payload: payload,
      customNotificationId: customNotificationId,
      threadIdentifier: 'export_notifications',
      categoryId: exportNotificationsCategoryId,
    );
  }

  /// Specific method for chat notifications
  Future<void> showChatNotification({
    required String title,
    required String body,
    String? payload,
    int? customNotificationId,
  }) async {
    await showInAppNotification(
      title: title,
      body: body,
      channelId: 'chat_notifications_channel',
      channelName: 'Chat Notifications',
      channelDescription: 'Notifications for new messages',
      importance: Importance.high,
      priority: Priority.high,
      playSound: true,
      showBadge: true,
      showAlert: true,
      payload: payload,
      customNotificationId: customNotificationId,
      threadIdentifier: 'chat_notifications',
    );
  }

  /// Specific method for system notifications
  Future<void> showSystemNotification({
    required String title,
    required String body,
    String? payload,
    int? customNotificationId,
  }) async {
    await showInAppNotification(
      title: title,
      body: body,
      channelId: 'system_notifications_channel',
      channelName: 'System Notifications',
      channelDescription: 'Important system notifications',
      importance: Importance.max,
      priority: Priority.max,
      playSound: true,
      showBadge: true,
      showAlert: true,
      payload: payload,
      customNotificationId: customNotificationId,
      threadIdentifier: 'system_notifications',
    );
  }

  Future<void> showDownloadNotification(
      {required String title, required String body, int? progress, bool ongoing = false, bool silent = false, int channelID = 0}) async {
    if (kDebugMode) {
      printLogs('Showing download notification');
    }
    await requestNotificationPermission();

    // Create a new AndroidNotificationDetails with the updated progress
    final AndroidNotificationDetails androidPlatformChannelSpecifics = AndroidNotificationDetails(
      'download_channel',
      'Downloads',
      channelDescription: 'Notification channel for download progress',
      importance: Importance.max,
      priority: Priority.high,
      showWhen: false,
      onlyAlertOnce: true,
      ongoing: ongoing,
      silent: silent,
      progress: progress ?? 0,
      maxProgress: 100,
    );
    final iOSDetails = DarwinNotificationDetails(
      presentAlert: false,
      presentBadge: false,
      presentSound: !silent,
      threadIdentifier: 'download_progress',
    );

    final NotificationDetails platformChannelSpecifics = NotificationDetails(android: androidPlatformChannelSpecifics, iOS: iOSDetails);

    // int id = Random().nextInt(10000);
    await flutterLocalNotificationsPlugin.show(
      channelID,
      title,
      body,
      platformChannelSpecifics,
    );
    // print('=============Download progress $progress');
    if (progress == 100) {
      await flutterLocalNotificationsPlugin.cancel(channelID);
    }
  }

  /// show silent notification to update the progress of upload
  Future<void> showUploadNotification({
    required String title,
    required String body,
    int? progress,
    bool ongoing = false,
  }) async {
    if (kDebugMode) {
      printLogs('Showing upload notification');
    }
    await requestNotificationPermission();

    // Create a new AndroidNotificationDetails with the updated progress
    final AndroidNotificationDetails androidPlatformChannelSpecifics = AndroidNotificationDetails(
      'upload_channel',
      'Uploads',
      channelDescription: 'Notification channel for upload progress',
      importance: Importance.low,
      priority: Priority.low,
      showWhen: true,
      onlyAlertOnce: true,
      ongoing: ongoing,
      progress: progress ?? 0,
      maxProgress: 100,
      icon: '@mipmap/ic_launcher',
    );
    final iOSDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: false,
      threadIdentifier: 'upload_progress',
    );
    final NotificationDetails platformChannelSpecifics = NotificationDetails(android: androidPlatformChannelSpecifics, iOS: iOSDetails);

    await flutterLocalNotificationsPlugin.show(
      0,
      title,
      body,
      platformChannelSpecifics,
    );
    if (progress == 100) {
      await flutterLocalNotificationsPlugin.cancel(0);
    }
  }

  //Update download notification functionality

  Future<void> _actuallyShowNotification(String title, String body, int progress, bool ongoing, bool silent, int channelID) async {
    if (kDebugMode) {
      print('Actually showing notification: $progress% for channel $channelID');
    }

    await requestNotificationPermission();

    final AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'download_channel',
      'Downloads',
      channelDescription: 'Notification channel for download progress',
      importance: Importance.max,
      priority: Priority.high,
      showWhen: false,
      onlyAlertOnce: true,
      ongoing: ongoing,
      silent: silent,
      showProgress: progress <= 100,
      progress: progress.clamp(0, 100), // Ensure progress is always between 0-100 for display
      maxProgress: 100,
      icon: '@mipmap/ic_launcher',
    );

    final iOSDetails = DarwinNotificationDetails(
      presentAlert: progress >= 100, // Only alert for completion
      presentBadge: false,
      presentSound: !silent && progress >= 100,
      threadIdentifier: 'download_progress',
    );

    // Specific configurations for iOS persistent notification
    /*final DarwinNotificationDetails iOSDetails = DarwinNotificationDetails(
      presentAlert: progress >= 100, // Only alert for completion
      presentBadge: true,
      presentSound: !silent && progress >= 100,
      presentBanner: true, // Show as banner
      interruptionLevel: InterruptionLevel.active,
      threadIdentifier: 'progress_notification_thread',
      subtitle: 'Progress: $progress%',
      categoryIdentifier: 'progress_category',
    );*/
    final NotificationDetails platformDetails = NotificationDetails(android: androidDetails, iOS: iOSDetails);

    try {
      await flutterLocalNotificationsPlugin.show(
        channelID,
        title,
        body,
        platformDetails,
      );

      // Handle completion and cancellation
      if (progress == 100) {
        // Wait a bit before canceling to ensure the completion notification is seen
        await Future.delayed(const Duration(seconds: 2));
        await flutterLocalNotificationsPlugin.cancel(channelID);
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error showing notification: $e');
      }
    }
  }

  // This is the method you'll call from your UI code
  Future<void> showDownloadNotificationArchive(
      {required String title, required String body, int progress = 0, bool ongoing = false, bool silent = false, int channelID = 0}) async {
    await _throttledService.showDownloadNotification(
      title: title,
      body: body,
      progress: progress ?? 0,
      ongoing: ongoing,
      silent: silent,
      channelID: channelID,
      showNotificationFunction: _actuallyShowNotification,
    );
  }
}
