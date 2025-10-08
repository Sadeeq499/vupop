import 'dart:convert';

CommunityChatUserModel communityChatUserModelFromJson(String str) => CommunityChatUserModel.fromJson(json.decode(str));

String communityChatUserModelToJson(CommunityChatUserModel data) => json.encode(data.toJson());

class CommunityChatUserModel {
  String? senderId;
  String? name;
  String? image;
  String? lastMessage;
  DateTime? lastMessageTime;
  String? community;
  int? unreadCount;

  CommunityChatUserModel({
    this.senderId,
    this.name,
    this.image,
    this.lastMessage,
    this.lastMessageTime,
    this.community,
    this.unreadCount,
  });

  CommunityChatUserModel copyWith({
    String? senderId,
    String? name,
    String? image,
    String? lastMessage,
    DateTime? lastMessageTime,
    String? community,
    int? unreadCount,
  }) =>
      CommunityChatUserModel(
        senderId: senderId ?? this.senderId,
        name: name ?? this.name,
        image: image ?? this.image,
        lastMessage: lastMessage ?? this.lastMessage,
        lastMessageTime: lastMessageTime ?? this.lastMessageTime,
        community: community ?? this.community,
        unreadCount: unreadCount ?? this.unreadCount,
      );

  factory CommunityChatUserModel.fromJson(Map<String, dynamic> json) => CommunityChatUserModel(
        senderId: json["senderId"]!,
        name: json["name"]!,
        image: json["image"],
        lastMessage: json["lastMessage"]!,
        lastMessageTime: json["lastMessageTime"] == null ? null : DateTime.parse(json["lastMessageTime"]),
        community: json["community"]!,
        unreadCount: json["unreadCount"]!,
      );

  Map<String, dynamic> toJson() => {
        "senderId": senderId,
        "name": name,
        "image": image,
        "lastMessage": lastMessage,
        "lastMessageTime": lastMessageTime?.toIso8601String(),
        "community": community,
        "unreadCount": unreadCount,
      };
}
