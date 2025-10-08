// To parse this JSON data, do
//
//     final communityMessagesModel = communityMessagesModelFromJson(jsonString);

import 'dart:convert';

CommunityMessagesModel communityMessagesModelFromJson(String str) => CommunityMessagesModel.fromJson(json.decode(str));

String communityMessagesModelToJson(CommunityMessagesModel data) => json.encode(data.toJson());

class CommunityMessagesModel {
  bool? success;
  CommunityMessagesDataModel? data;

  CommunityMessagesModel({
    this.success,
    this.data,
  });

  CommunityMessagesModel copyWith({
    bool? success,
    CommunityMessagesDataModel? data,
  }) =>
      CommunityMessagesModel(
        success: success ?? this.success,
        data: data ?? this.data,
      );

  factory CommunityMessagesModel.fromJson(Map<String, dynamic> json) => CommunityMessagesModel(
        success: json["success"],
        data: json["data"] == null ? null : CommunityMessagesDataModel.fromJson(json["data"]),
      );

  Map<String, dynamic> toJson() => {
        "success": success,
        "data": data?.toJson(),
      };
}

class CommunityMessagesDataModel {
  List<CommunityChatMessages>? chats;
  Community? community;
  int? messageCount;
  int? totalPages;

  CommunityMessagesDataModel({
    this.chats,
    this.community,
    this.messageCount,
    this.totalPages,
  });

  CommunityMessagesDataModel copyWith({
    List<CommunityChatMessages>? chats,
    Community? community,
    int? messageCount,
    int? totalPages,
  }) =>
      CommunityMessagesDataModel(
        chats: chats ?? this.chats,
        community: community ?? this.community,
        messageCount: messageCount ?? this.messageCount,
        totalPages: totalPages ?? this.totalPages,
      );

  factory CommunityMessagesDataModel.fromJson(Map<String, dynamic> json) => CommunityMessagesDataModel(
        chats: json["chats"] == null ? [] : List<CommunityChatMessages>.from(json["chats"]!.map((x) => CommunityChatMessages.fromJson(x))),
        community: json["community"] == null ? null : Community.fromJson(json["community"]),
        messageCount: json["messageCount"] ?? 0,
        totalPages: json["totalPages"],
      );

  Map<String, dynamic> toJson() => {
        "chats": chats == null ? [] : List<dynamic>.from(chats!.map((x) => x.toJson())),
        "community": community?.toJson(),
        "messageCount": messageCount,
        "totalPages": totalPages,
      };
}

class CommunityChatMessages {
  String? senderId;
  String? senderName;
  String? senderImage;
  String? message;
  DateTime? date;
  String? community;

  CommunityChatMessages({
    this.senderId,
    this.senderName,
    this.senderImage,
    this.message,
    this.date,
    this.community,
  });

  CommunityChatMessages copyWith({
    String? senderId,
    String? senderName,
    String? senderImage,
    String? message,
    DateTime? date,
    String? community,
  }) =>
      CommunityChatMessages(
        senderId: senderId ?? this.senderId,
        senderName: senderName ?? this.senderName,
        senderImage: senderImage ?? this.senderImage,
        message: message ?? this.message,
        date: date ?? this.date,
        community: community ?? this.community,
      );

  factory CommunityChatMessages.fromJson(Map<String, dynamic> json) => CommunityChatMessages(
        senderId: json["senderId"],
        senderName: json["senderName"],
        senderImage: json["senderImage"],
        message: json["message"],
        date: json["date"] == null ? null : DateTime.parse(json["date"]),
        community: json["community"],
      );

  Map<String, dynamic> toJson() => {
        "senderId": senderId,
        "senderName": senderName,
        "senderImage": senderImage,
        "message": message,
        "date": date?.toIso8601String(),
        "community": community,
      };
}

class Community {
  String? id;
  List<dynamic>? membersLeft;
  String? name;
  String? createdBy;
  DateTime? endTime;
  List<Member>? members;
  DateTime? date;
  int? v;
  String? image;
  String? description;
  String? editor;
  String? firstMessage;

  Community({
    this.id,
    this.membersLeft,
    this.name,
    this.createdBy,
    this.endTime,
    this.members,
    this.date,
    this.v,
    this.image,
    this.description,
    this.editor,
    this.firstMessage,
  });

  Community copyWith({
    String? id,
    List<dynamic>? membersLeft,
    String? name,
    String? createdBy,
    DateTime? endTime,
    List<Member>? members,
    DateTime? date,
    int? v,
    String? image,
    String? description,
    String? editor,
    String? firstMessage,
  }) =>
      Community(
        id: id ?? this.id,
        membersLeft: membersLeft ?? this.membersLeft,
        name: name ?? this.name,
        createdBy: createdBy ?? this.createdBy,
        endTime: endTime ?? this.endTime,
        members: members ?? this.members,
        date: date ?? this.date,
        v: v ?? this.v,
        image: image ?? this.image,
        description: description ?? this.description,
        editor: editor ?? this.editor,
        firstMessage: firstMessage ?? this.firstMessage,
      );

  factory Community.fromJson(Map<String, dynamic> json) => Community(
        id: json["_id"],
        membersLeft: json["membersLeft"] == null ? [] : List<dynamic>.from(json["membersLeft"]!.map((x) => x)),
        name: json["name"],
        createdBy: json["createdBy"],
        endTime: json["endTime"] == null ? null : DateTime.parse(json["endTime"]),
        members: json["members"] == null ? [] : List<Member>.from(json["members"]!.map((x) => Member.fromJson(x))),
        date: json["date"] == null ? null : DateTime.parse(json["date"]),
        v: json["__v"],
        image: json["image"],
        description: json["description"],
        editor: json["editor"],
        firstMessage: json["firstMessage"],
      );

  Map<String, dynamic> toJson() => {
        "_id": id,
        "membersLeft": membersLeft == null ? [] : List<dynamic>.from(membersLeft!.map((x) => x)),
        "name": name,
        "createdBy": createdBy,
        "endTime": endTime?.toIso8601String(),
        "members": members == null ? [] : List<dynamic>.from(members!.map((x) => x.toJson())),
        "date": date?.toIso8601String(),
        "__v": v,
        "image": image,
        "description": description,
        "editor": editor,
        "firstMessage": firstMessage,
      };
}

class Member {
  bool? isLeft;
  String? id;
  String? memberId;
  DateTime? joinDate;
  DateTime? leftDate;

  Member({
    this.isLeft,
    this.id,
    this.memberId,
    this.joinDate,
    this.leftDate,
  });

  Member copyWith({
    bool? isLeft,
    String? id,
    String? memberId,
    DateTime? joinDate,
    DateTime? leftDate,
  }) =>
      Member(
        isLeft: isLeft ?? this.isLeft,
        id: id ?? this.id,
        memberId: memberId ?? this.memberId,
        joinDate: joinDate ?? this.joinDate,
        leftDate: leftDate ?? this.leftDate,
      );

  factory Member.fromJson(Map<String, dynamic> json) => Member(
        isLeft: json["isLeft"],
        id: json["_id"],
        memberId: json["id"],
        joinDate: json["joinDate"] == null ? null : DateTime.parse(json["joinDate"]),
        leftDate: json["leftDate"] == null ? null : DateTime.parse(json["leftDate"]),
      );

  Map<String, dynamic> toJson() => {
        "isLeft": isLeft,
        "_id": id,
        "id": memberId,
        "joinDate": joinDate?.toIso8601String(),
        "leftDate": leftDate?.toIso8601String(),
      };
}
