import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';

class ThrottledNotificationService {
  final Duration throttleDuration;
  final Map<int, Timer> _timers = {};
  final Map<int, int> _lastProgress = {};
  final Map<int, int> _lastShownProgress = {}; // Track last shown progress

  ThrottledNotificationService({this.throttleDuration = const Duration(milliseconds: 500)});

  Future<void> showDownloadNotification({
    required String title,
    required String body,
    required int progress,
    bool ongoing = false,
    bool silent = false,
    required int channelID,
    required Function(String, String, int, bool, bool, int) showNotificationFunction,
  }) async {
    if (kDebugMode) {
      print('ThrottledService received progress: $progress for channel: $channelID');
    }

    // Store the latest progress
    _lastProgress[channelID] = progress;

    // For completion notifications, show immediately
    if (progress >= 100) {
      // Cancel any pending updates for this channel
      _timers[channelID]?.cancel();
      _timers.remove(channelID);

      // Show final notification
      try {
        await showNotificationFunction(title, body, progress, ongoing, silent, channelID);
        _lastShownProgress[channelID] = progress; // Update last shown progress
      } catch (e) {
        if (kDebugMode) {
          print('Error showing completion notification: $e');
        }
      }
      return;
    }

    // For initial notification (progress = 0) or significant changes, show immediately
    if (_timers[channelID] == null || _lastShownProgress[channelID] == null || (progress - (_lastShownProgress[channelID] ?? 0) >= 10)) {
      // Cancel any existing timer
      _timers[channelID]?.cancel();

      // Show the notification immediately
      try {
        await showNotificationFunction(title, body, progress, ongoing, silent, channelID);
        _lastShownProgress[channelID] = progress; // Update last shown
      } catch (e) {
        if (kDebugMode) {
          print('Error showing initial/immediate notification: $e');
        }
      }

      // Set up throttling for subsequent updates
      _timers[channelID] = Timer(throttleDuration, () {
        _processThrottledUpdate(title, channelID, ongoing, silent, showNotificationFunction);
      });
    }
    // Otherwise, we'll let the existing timer handle the update with the latest progress
  }

  void _processThrottledUpdate(
      String title, int channelID, bool ongoing, bool silent, Function(String, String, int, bool, bool, int) showNotificationFunction) async {
    // When timer fires, show the latest progress if it's different from what was last shown
    final latestProgress = _lastProgress[channelID];
    final lastShown = _lastShownProgress[channelID] ?? 0;

    // Only update if progress has changed and is below 100
    if (latestProgress != null && latestProgress < 100 && latestProgress != lastShown) {
      try {
        final body = "Downloaded ${latestProgress}%";
        await showNotificationFunction(title, body, latestProgress, ongoing, silent, channelID);
        _lastShownProgress[channelID] = latestProgress; // Update last shown

        if (kDebugMode) {
          print('Throttled notification updated to: $latestProgress%');
        }
      } catch (e) {
        if (kDebugMode) {
          print('Error in throttled notification update: $e');
        }
      }
    }

    // Clear this timer
    _timers.remove(channelID);

    // If progress is still updating and not near completion, schedule another check
    if (latestProgress != null && latestProgress < 95) {
      _timers[channelID] = Timer(throttleDuration, () {
        _processThrottledUpdate(title, channelID, ongoing, silent, showNotificationFunction);
      });
    }
  }

  // Cancel all throttling for a specific channel or all channels
  void cancelThrottling({int? channelID}) {
    if (channelID != null) {
      _timers[channelID]?.cancel();
      _timers.remove(channelID);
    } else {
      // Cancel all timers
      _timers.forEach((_, timer) => timer.cancel());
      _timers.clear();
    }
  }
}

class CustomNotificationService {
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;
  final ThrottledNotificationService _throttledService;

  CustomNotificationService(this.flutterLocalNotificationsPlugin) : _throttledService = ThrottledNotificationService();

  Future<void> requestNotificationPermission() async {
    var status = await Permission.notification.status;
    if (!status.isGranted) {
      await Permission.notification.request();
    }
  }

  Future<void> _actuallyShowNotification(String title, String body, int? progress, bool ongoing, bool silent, int channelID) async {
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
      showProgress: progress != null && progress <= 100,
      progress: progress ?? 0,
      maxProgress: 100,
    );

    final iOSDetails = DarwinNotificationDetails(
      presentAlert: progress == 100 || progress == null, // Only alert for completion
      presentBadge: false,
      presentSound: !silent && (progress == 100 || progress == null),
      threadIdentifier: 'download_progress',
    );

    final NotificationDetails platformDetails = NotificationDetails(android: androidDetails, iOS: iOSDetails);

    await flutterLocalNotificationsPlugin.show(
      channelID,
      title,
      body,
      platformDetails,
    );

    // Only cancel if we're explicitly told it's complete (progress > 100)
    if (progress != null && progress > 100) {
      await flutterLocalNotificationsPlugin.cancel(channelID);
    }
  }

  // This is the method you'll call from your UI code
  Future<void> showDownloadNotification(
      {required String title, required String body, int? progress, bool ongoing = false, bool silent = false, int channelID = 0}) async {
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
