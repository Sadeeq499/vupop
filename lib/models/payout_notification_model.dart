import 'dart:convert';

PayoutNotificationModel payoutNotificationModelFromJson(String str) => PayoutNotificationModel.fromJson(json.decode(str));

String payoutNotificationModelToJson(PayoutNotificationModel data) => json.encode(data.toJson());

class PayoutNotificationModel {
  bool success;
  String message;
  PayoutNotificationData data;

  PayoutNotificationModel({
    required this.success,
    required this.message,
    required this.data,
  });

  factory PayoutNotificationModel.fromJson(Map<String, dynamic> json) => PayoutNotificationModel(
        success: json["success"],
        message: json["message"],
        data: PayoutNotificationData.fromJson(json["data"]),
      );

  Map<String, dynamic> toJson() => {
        "success": success,
        "message": message,
        "data": data.toJson(),
      };
}

class PayoutNotificationData {
  List<PayoutNotification> payoutNotification;

  PayoutNotificationData({
    required this.payoutNotification,
  });

  factory PayoutNotificationData.fromJson(Map<String, dynamic> json) => PayoutNotificationData(
        payoutNotification: List<PayoutNotification>.from(json["payoutNotification"].map((x) => PayoutNotification.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "payoutNotification": List<dynamic>.from(payoutNotification.map((x) => x.toJson())),
      };
}

class PayoutNotification {
  bool isVerified;
  String id;
  String userId;
  String exportedBy;
  String exportId;
  String amount;
  String title;
  String description;
  DateTime deadline;
  DateTime date;
  int v;

  PayoutNotification({
    required this.isVerified,
    required this.id,
    required this.userId,
    required this.exportedBy,
    required this.exportId,
    required this.amount,
    required this.title,
    required this.description,
    required this.deadline,
    required this.date,
    required this.v,
  });

  factory PayoutNotification.fromJson(Map<String, dynamic> json) => PayoutNotification(
        isVerified: json["isVerified"],
        id: json["_id"],
        userId: json["userId"],
        exportedBy: json["exportedBy"],
        exportId: json["exportId"],
        amount: json["amount"],
        title: json["title"],
        description: json["description"],
        deadline: DateTime.parse(json["deadline"]),
        date: DateTime.parse(json["date"]),
        v: json["__v"],
      );

  Map<String, dynamic> toJson() => {
        "isVerified": isVerified,
        "_id": id,
        "userId": userId,
        "exportedBy": exportedBy,
        "exportId": exportId,
        "amount": amount,
        "title": title,
        "description": description,
        "deadline": deadline.toIso8601String(),
        "date": date.toIso8601String(),
        "__v": v,
      };
}
