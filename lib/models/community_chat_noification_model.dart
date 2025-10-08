import 'dart:convert';

CommunityChatNotificationModel communityChatNotificationModelFromJson(String str) => CommunityChatNotificationModel.fromJson(json.decode(str));

String communityChatNotificationModelToJson(CommunityChatNotificationModel data) => json.encode(data.toJson());

class CommunityChatNotificationModel {
  bool? success;
  String? message;
  CommunityChatNotificationData? data;

  CommunityChatNotificationModel({
    this.success,
    this.message,
    this.data,
  });

  CommunityChatNotificationModel copyWith({
    bool? success,
    String? message,
    CommunityChatNotificationData? data,
  }) =>
      CommunityChatNotificationModel(
        success: success ?? this.success,
        message: message ?? this.message,
        data: data ?? this.data,
      );

  factory CommunityChatNotificationModel.fromJson(Map<String, dynamic> json) => CommunityChatNotificationModel(
        success: json["success"],
        message: json["message"],
        data: json["data"] == null ? null : CommunityChatNotificationData.fromJson(json["data"]),
      );

  Map<String, dynamic> toJson() => {
        "success": success,
        "message": message,
        "data": data?.toJson(),
      };
}

class CommunityChatNotificationData {
  int? totalPages;
  List<ChatNotification>? chatNotification;

  CommunityChatNotificationData({
    this.totalPages,
    this.chatNotification,
  });

  CommunityChatNotificationData copyWith({
    int? totalPages,
    List<ChatNotification>? chatNotification,
  }) =>
      CommunityChatNotificationData(
        totalPages: totalPages ?? this.totalPages,
        chatNotification: chatNotification ?? this.chatNotification,
      );

  factory CommunityChatNotificationData.fromJson(Map<String, dynamic> json) => CommunityChatNotificationData(
        totalPages: json["totalPages"],
        chatNotification:
            json["chatNotification"] == null ? [] : List<ChatNotification>.from(json["chatNotification"]!.map((x) => ChatNotification.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "totalPages": totalPages,
        "chatNotification": chatNotification == null ? [] : List<dynamic>.from(chatNotification!.map((x) => x.toJson())),
      };
}

class ChatNotification {
  String? id;
  String? sender;
  String? reciever;
  String? community;
  String? message;
  String? image;
  DateTime? endTime;
  String? communityName;
  String? communityDescription;
  DateTime? date;
  int? v;

  ChatNotification({
    this.id,
    this.sender,
    this.reciever,
    this.community,
    this.message,
    this.image,
    this.endTime,
    this.communityName,
    this.communityDescription,
    this.date,
    this.v,
  });

  ChatNotification copyWith({
    String? id,
    String? sender,
    String? reciever,
    String? community,
    String? message,
    String? image,
    DateTime? endTime,
    String? communityName,
    String? communityDescription,
    DateTime? date,
    int? v,
  }) =>
      ChatNotification(
        id: id ?? this.id,
        sender: sender ?? this.sender,
        reciever: reciever ?? this.reciever,
        community: community ?? this.community,
        message: message ?? this.message,
        image: image ?? this.image,
        endTime: endTime ?? this.endTime,
        communityName: communityName ?? this.communityName,
        communityDescription: communityDescription ?? this.communityDescription,
        date: date ?? this.date,
        v: v ?? this.v,
      );

  factory ChatNotification.fromJson(Map<String, dynamic> json) => ChatNotification(
        id: json["_id"],
        sender: json["sender"],
        reciever: json["reciever"],
        community: json["community"],
        message: json["message"],
        image: json["image"],
        endTime: json["endTime"] == null ? null : DateTime.parse(json["endTime"]),
        communityName: json["communityName"],
        communityDescription: json["communityDescription"],
        date: json["date"] == null ? null : DateTime.parse(json["date"]),
        v: json["__v"],
      );

  Map<String, dynamic> toJson() => {
        "_id": id,
        "sender": sender,
        "reciever": reciever,
        "community": community,
        "message": message,
        "image": image,
        "endTime": endTime?.toIso8601String(),
        "communityName": communityName,
        "communityDescription": communityDescription,
        "date": date?.toIso8601String(),
        "__v": v,
      };
}
