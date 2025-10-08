class NotificationResponse {
  final bool success;
  final String message;
  final List<NotificationModel> notifications;

  NotificationResponse({
    required this.success,
    required this.message,
    required this.notifications,
  });

  factory NotificationResponse.fromJson(Map<String, dynamic> json) {
    var notificationsJson = json['notification'] as List;
    List<NotificationModel> notificationsList = notificationsJson.map((i) => NotificationModel.fromJson(i)).toList();

    return NotificationResponse(
      success: json['success'] == null ? false : json['success'] ?? false,
      message: json['message'] ?? '',
      notifications: notificationsList,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'message': message,
      'notification': notifications.map((notification) => notification.toJson()).toList(),
    };
  }
}

class NotificationModel {
  final bool adminNoti;
  final bool isMentionedNoti;
  final bool isAppNoti;
  final bool isFeeNoti;
  final bool isExpired;
  final String id;
  final String senderBroadcaster;
  final String title;
  final String message;
  final DateTime date;
  final int version;

  NotificationModel({
    required this.adminNoti,
    required this.isMentionedNoti,
    required this.isAppNoti,
    required this.isFeeNoti,
    required this.id,
    required this.senderBroadcaster,
    required this.title,
    required this.message,
    required this.date,
    required this.version,
    required this.isExpired,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      adminNoti: json['adminNoti'] ?? false,
      isMentionedNoti: json['isMentionedNoti'] ?? false,
      isAppNoti: json['isAppNoti'] ?? false,
      isFeeNoti: json['isFeeNoti'] ?? false,
      isExpired: json['isExpired'] ?? false,
      id: json['_id'] ?? '',
      senderBroadcaster: json['senderBroadcaster'] ?? "",
      title: json['title'] ?? '',
      message: json['message'] ?? '',
      date: json['date'] == null ? DateTime.now() : DateTime.parse(json['date']),
      version: json['__v'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'adminNoti': adminNoti,
      'isMentionedNoti': isMentionedNoti,
      'isAppNoti': isAppNoti,
      'isFeeNoti': isFeeNoti,
      '_id': id,
      'senderBroadcaster': senderBroadcaster,
      'title': title,
      'message': message,
      'date': date.toIso8601String(),
      '__v': version,
    };
  }
}
