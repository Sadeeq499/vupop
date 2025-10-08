import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:socials_app/models/community_chat_noification_model.dart';
import 'package:socials_app/models/notification_model.dart';
import 'package:socials_app/models/payout_notification_model.dart';
import 'package:socials_app/services/endpoints.dart';
import 'package:socials_app/services/http_client.dart';

import '../models/export_notifications_model.dart';
import '../utils/common_code.dart';

class NotificationRepo {
  late HTTPClient _httpClient;
  static final _instance = NotificationRepo._internal();

  factory NotificationRepo() {
    return _instance;
  }

  NotificationRepo._internal() {
    _httpClient = HTTPClient();
  }

  /// send notification to user
  Future<void> sendNotification({
    required String userId,
    required String title,
    required String body,
  }) async {
    try {
      if (kDebugMode) {
        printLogs('sendNotification called with userId: $userId, title: $title, body: $body');
      }
      final resp = await _httpClient.postRequestWithHeader(
        url: kSendNotificationURL,
        body: jsonEncode({
          'user': userId,
          'title': title,
          'body': body,
        }),
      );
      if (kDebugMode) {
        printLogs('sendNotification response: $resp');
      }
    } catch (e) {
      rethrow;
    }
  }

  /// get all notifications
  Future<List<NotificationModel>> getAllNotifications(String userId) async {
    try {
      // if (kDebugMode) {
      printLogs('getAllNotifications called with userId: $userId');
      // }
      final resp = await _httpClient.getRequestWithHeader(
        url: "$kGetAllNotificationsURL/$userId",
      );
      // if (kDebugMode) {
      printLogs('getAllNotifications response: $resp');
      // }
      if (resp.statusCode == 200) {
        final Map<String, dynamic> jsonData = jsonDecode(resp.data);
        final data = NotificationResponse.fromJson(jsonData);
        return data.notifications;
      }
    } catch (e) {
      printLogs('getAllNotifications response: ${e.toString()}');
      return [];
    }
    return [];
  }

  /// get all notifications
  Future<CommunityChatNotificationData?> getAllCommunityChatNotifications({required String userId, required int pageNo}) async {
    try {
      if (kDebugMode) {
        printLogs('getAllCommunityChatNotifications called with userId: $userId');
      }
      final resp = await _httpClient.getRequestWithHeader(
        url: "$kGetAllCommunityChatNotificationsURL/$userId?page=$pageNo&limit=20",
      );
      if (kDebugMode) {
        printLogs('getAllCommunityChatNotifications response: $resp');
      }
      if (resp.statusCode == 200) {
        printLogs('===============getAllCommunityChatNotifications res.data ${resp.data}');
        final Map<String, dynamic> jsonData = jsonDecode(resp.data);
        printLogs('===============getAllCommunityChatNotifications jsonData $jsonData');
        printLogs('===============getAllCommunityChatNotifications jsonData[data] ${jsonData['data']}');
        final data = communityChatNotificationModelFromJson(jsonEncode(jsonData));
        return data.data;
      } else {
        return null;
      }
    } catch (e) {
      printLogs('===========getAllCommunityChatNotifications Exception $e');
      return null;
    }
    // return null;
  }

  /// get all post export notifications
  Future<ExportNotificationsDataModel?> getAllPostExportNotifications({required String userId, required int pageNo}) async {
    try {
      if (kDebugMode) {
        printLogs('getAllPostExportNotifications called with userId: $userId');
      }
      final resp = await _httpClient.getRequestWithHeader(
        url: "$kGetAllExportNotificationsURL?userId=$userId&page=$pageNo&limit=20",
      );
      if (kDebugMode) {
        printLogs('getAllPostExportNotifications response: $resp');
      }
      if (resp.statusCode == 200) {
        printLogs('===============getAllPostExportNotifications res.data ${resp.data}');
        final Map<String, dynamic> jsonData = jsonDecode(resp.data);
        printLogs('===============getAllPostExportNotifications jsonData $jsonData');
        printLogs('===============getAllPostExportNotifications jsonData[data] ${jsonData['data']}');
        final data = exportNotificationsModelFromJson(jsonEncode(jsonData));
        return data.data;
      } else {
        return null;
      }
    } catch (e) {
      printLogs('===========getAllPostExportNotifications Exception $e');
      return null;
    }
    // return null;
  }

  /// get payout notifications
  Future<PayoutNotificationData?> getPayoutNotifications({required String userId}) async {
    try {
      if (kDebugMode) {
        printLogs('getPayoutNotifications called with userId: $userId');
      }
      final resp = await _httpClient.getRequestWithHeader(
        url: "$kGetPayoutNotificationsURL?userId=$userId&isVerified=false",
      );

      /*final resp = ResponseModel();

      resp.statusCode = 200;
      resp.statusDescription = "Success";
      resp.data = {
        "success": true,
        "message": "Notification found",
        "data": {
          "success": true,
          "message": "Notification found",
          "data": {
            "payoutNotification": [
              {
                "isVerified": false,
                "_id": "687e34d103ea6b0012db7f4d",
                "userId": "66f43359afe0c2b995a4b93f",
                "exportedBy": "686904761333a30012b10cfc",
                "exportId": "687e34beead57d0012c0bbbb",
                "amount": "21.00",
                "title": "Payout is on its way",
                "description": "Please dd your bank account details to recieve your payout securely",
                "deadline": "2025-10-19T12:38:41.944Z",
                "date": "2025-07-21T12:38:41.944Z",
                "__v": 0
              }
            ]
          }
        }
      };*/
      if (kDebugMode) {
        printLogs('getPayoutNotifications response: $resp');
      }
      if (resp.statusCode == 200) {
        printLogs('===============getPayoutNotifications res.data ${resp.data}');
        final Map<String, dynamic> jsonData = resp.data is String ? jsonDecode(resp.data) : resp.data;
        printLogs('===============getPayoutNotifications jsonData $jsonData');
        printLogs('===============getPayoutNotifications jsonData[data] ${jsonData['data']}');
        final data = payoutNotificationModelFromJson(jsonEncode(jsonData));
        return data.success ? data.data : null;
      } else {
        return null;
      }
    } catch (e) {
      printLogs('===========getPayoutNotifications Exception $e');
      return null;
    }
    // return null;
  }

  Future<bool> verifyPayoutNotification({required String notificationId}) async {
    Map<String, dynamic> data = {
      'id': notificationId,
    };
    // String jsonData = jsonEncode(data);
    final response = await _httpClient.putRequestWithHeader(url: kVerifyPayoutNotificationsURL, body: jsonEncode(data));

    //For Mock data
    /*final response = ResponseModel();
    response.statusCode = 200;
    response.statusDescription = "Success";
    response.data = {"success": true, "message": "Notification verified successfully"};*/
    // if (kDebugMode) {
    printLogs('verifyPayoutNotification Response.statuscode: ${response.statusCode}');
    // }
    if (response.statusCode == 200) {
      try {
        Map<String, dynamic> jsonData = response.data is String ? jsonDecode(response.data) : response.data;
        //if (kDebugMode) {
        printLogs('verifyPayoutNotification jsonData: $jsonData');
        // }
        if (jsonData['message'] != null && jsonData['message'] == "Notification verified successfully") {
          return true;
        } else {
          return false;
        }
      } catch (e) {
        if (kDebugMode) {
          printLogs('Error verifyPayoutNotification: $e');
        }
      }
    } else {
      if (kDebugMode) {
        printLogs('Response verifyPayoutNotification: ${response.statusCode}');
      }
    }
    return false;
  }
}
