import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:socials_app/services/session_services.dart';
import 'package:socials_app/views/screens/home_recordings/recording_screen.dart';
import 'package:socials_app/views/screens/profile/screen/profile_screen.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;

import '../../../../models/export_post_notification_model.dart';
import '../../../../models/post_models.dart';
import '../../../../repositories/profile_repo.dart';
import '../../../../services/custom_snackbar.dart';
import '../../../../services/endpoints.dart';
import '../../../../services/geo_services.dart';
import '../../../../services/notification_sevices.dart';
import '../../../../utils/common_code.dart';
import '../../chat/chat_screen.dart';

class BottomBarController extends GetxController {
  final List<Widget> pages = const [
    // HomeScreen(),
    // DiscoverScreen(),
    ProfileScreen(),
    RecordingScreen(
      isFromBottomBar: true,
    ),
    // SocialWalletScreen(), \\removed long ago no need shifted to drawer
    ChatScreen(),
    // ProfileScreen()
  ];
  RxBool isPayoutVerified = false.obs;
  RxInt selectedIndex = 0.obs;
  RxInt previousSelectedIndex = 0.obs;
  bool isFirstInit = true;

  // Add notification service instance
  final NotificationService _notificationService = NotificationService();
  @override
  void onInit() {
    super.onInit();
    log("BottomBarController Init");
    Future.delayed(const Duration(seconds: 1), () async {
      try {
        // Initialize the socket connection
        ExportNotificationsSocketService.instance.initializeSocket(kSocketNotificationURL, queryParams: {});
        setupExportNotificationsSocketListeners();
        updateUserLocationData();
      } catch (error, stackTrace) {
        printLogs("Error ExportNotificationsSocketService in onInit: $error");
        printLogs("ExportNotificationsSocketService StackTrace: $stackTrace");
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
    printLogs("BottomBarController Init");
    ExportNotificationsSocketService.instance.disconnectSocket();
  }

  startListeningToExportNotificationsSocket(int pageNo) {
    final socket = ExportNotificationsSocketService.instance.socket;
    if (socket == null) {
      printLogs('BottomBarCont ExportNotifications Socket is not initialized');
      return;
    }
    printLogs("============startListeningToExportNotificationsSocket pageNo $pageNo");

    socket.on('exportVideoNotification', (data) {
      printLogs('startListeningToExportNotificationsSocket exportVideoNotification response: $data');
      ExportPostNotificationModel allNotificationData = ExportPostNotificationModel.fromJson(data);
      List<NotificationData> notificationData = allNotificationData.notification ?? [];
      // notificationData.sort((a, b) => a.date!.compareTo(b.date!));
      if (pageNo == 1) {
        SessionService().exportPostNotificationData.value = notificationData;
      } else {
        SessionService().exportPostNotificationData.value.addAll(notificationData);
      }
      SessionService().setExportNotificationsData(allNotificationData.pages ?? 1);
    });

    var arg1 = {"userId": SessionService().user?.id, "page": pageNo};
    socket.emit('getexportVideoNotification', [
      arg1,
    ]);
    socket.on('exportVideoNotification', (data) {
      printLogs('startListeningToExportNotificationsSocket exportVideoNotification after emit response: $data');
      ExportPostNotificationModel allNotificationData = ExportPostNotificationModel.fromJson(data);
      List<NotificationData> notificationData = allNotificationData.notification ?? [];

      // notificationData.sort((a, b) => a.date!.compareTo(b.date!));
      SessionService().exportPostNotificationData.value = notificationData;
      SessionService().setExportNotificationsData(allNotificationData.pages ?? 1);
      if (isFirstInit) {
        isFirstInit = false;
      } else {
        if (allNotificationData.newNoti != null && allNotificationData.newNoti!.isNotEmpty) {
          CustomSnackbar.showTimerSnackbar("${allNotificationData.newNoti}");

          /*_notificationService.showDownloadNotificationArchive(
              title: 'New Export Notification',
              body: '${allNotificationData.newNoti}',
              progress: 0,
              ongoing: false,
              silent: false,
              channelID: DateTime.timestamp().millisecond);*/
          /*_notificationService.showExportNotification(
            title: "New Export Notification",
            body: "${allNotificationData.newNoti}",
            payload: jsonEncode({
              'type': 'export_notification',
              'data': allNotificationData.toJson(),
            }),
          );*/
        }
      }
      print('=======SessionService().exportPostNotificationData ${SessionService().exportPostNotificationData.length}');
    });
    socket.on('error', (data) {
      printLogs('startListeningToExportNotificationsSocket Error: $data');
    });

    socket.on('disconnect', (_) {
      printLogs('startListeningToExportNotificationsSocket Socket disconnected');
    });

    printLogs('===========startListeningToExportNotificationsSocket emitted');
  }

  RxBool isSocketConnect = false.obs;
  void setupExportNotificationsSocketListeners() {
    final socket = ExportNotificationsSocketService.instance.socket;

    socket?.onConnect((_) {
      isSocketConnect.value = true;
      //fetchChats();

      startListeningToExportNotificationsSocket(1);
      printLogs("=======ExportNotifications socket connected");
    });

    socket?.onDisconnect((_) {
      isSocketConnect.value = false;
      printLogs("=======ExportNotifications socket disconnected");
    });

    socket?.onReconnect((_) {
      printLogs("=======ExportNotifications socket reconnected");
    });

    socket?.onError((data) {
      isSocketConnect.value = false;
      printLogs("=======ExportNotifications socket error");
    });

    socket?.onConnectError((data) {
      isSocketConnect.value = false;
      printLogs("=======ExportNotifications socket connect error");
    });
  }

  Future updateUserLocationData() async {
    if (SessionService().user?.id != null) {
      Position? position = await getLatLong();
      final value = await ProfileRepo()
          .updateUserLocationData(userId: SessionService().user!.id, lat: position?.latitude ?? 0.0, lng: position?.longitude ?? 0.0);
      if (value != null) {
        printLogs('==========Location updated');
      } else {
        printLogs('==========Location not updated');
      }
    }
  }

  Future<Position?> getLatLong() async {
    try {
      Position position = await GeoServices.determinePosition();

      String address = await GeoServices.getAddress(position.latitude, position.longitude);

      SessionService().userAddress = address;
      SessionService().userLocation = Location(
        coordinates: [position.latitude, position.longitude],
      );
      SessionService().saveUserAddress();
      return position;
    } catch (e) {
      log(e.toString());
      return null;
    }
  }
}

class ExportNotificationsSocketService {
  static final ExportNotificationsSocketService _instance = ExportNotificationsSocketService._internal();

  io.Socket? socket;

  ExportNotificationsSocketService._internal();

  static ExportNotificationsSocketService get instance => _instance;

  void initializeSocket(String uri, {required Map<dynamic, dynamic> queryParams}) {
    socket = io.io(uri, io.OptionBuilder().setTransports(['websocket']).disableAutoConnect().build());

    socket?.connect();

    /*socket?.onConnect((_) {
      printLogs('Socket connected');
    });*/
    printLogs("ExportNotifications Socket initialized and connected for posts");
  }

  void disconnectSocket() {
    socket?.disconnect();
    socket = null;
    if (kDebugMode) {
      printLogs("ExportNotifications Socket disconnected");
    }
  }
}
