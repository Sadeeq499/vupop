import 'dart:convert';

CommunityAllChatsModel communityAllChatsModelFromJson(String str) => CommunityAllChatsModel.fromJson(json.decode(str));

String communityAllChatsModelToJson(CommunityAllChatsModel data) => json.encode(data.toJson());

class CommunityAllChatsModel {
  bool? success;
  List<CommunityAllChatsModelData>? data;
  int? totalPages;
  int? totalCommunities;

  CommunityAllChatsModel({
    this.success,
    this.data,
    this.totalPages,
    this.totalCommunities,
  });

  CommunityAllChatsModel copyWith({
    bool? success,
    List<CommunityAllChatsModelData>? data,
    int? totalPages,
    int? totalCommunities,
  }) =>
      CommunityAllChatsModel(
        success: success ?? this.success,
        data: data ?? this.data,
        totalPages: totalPages ?? this.totalPages,
        totalCommunities: totalCommunities ?? this.totalCommunities,
      );

  factory CommunityAllChatsModel.fromJson(Map<String, dynamic> json) => CommunityAllChatsModel(
        success: json["success"],
        data: json["data"] == null ? [] : List<CommunityAllChatsModelData>.from(json["data"]!.map((x) => CommunityAllChatsModelData.fromJson(x))),
        totalPages: json["totalPages"],
        totalCommunities: json["totalCommunities"],
      );

  Map<String, dynamic> toJson() => {
        "success": success,
        "data": data == null ? [] : List<dynamic>.from(data!.map((x) => x.toJson())),
        "totalPages": totalPages,
        "totalCommunities": totalCommunities,
      };
}

class CommunityAllChatsModelData {
  String? id;
  String? name;
  String? description;
  DateTime? endTime;
  String? editor;
  String? image;
  String? createdBy;
  List<Member>? members;
  DateTime? date;
  int? v;
  int? messageCount;

  CommunityAllChatsModelData({
    this.id,
    this.name,
    this.description,
    this.endTime,
    this.editor,
    this.image,
    this.createdBy,
    this.members,
    this.date,
    this.v,
    this.messageCount,
  });

  CommunityAllChatsModelData copyWith({
    String? id,
    String? name,
    String? description,
    DateTime? endTime,
    String? editor,
    String? image,
    String? createdBy,
    List<Member>? members,
    DateTime? date,
    int? v,
    int? messageCount,
  }) =>
      CommunityAllChatsModelData(
        id: id ?? this.id,
        name: name ?? this.name,
        description: description ?? this.description,
        endTime: endTime ?? this.endTime,
        editor: editor ?? this.editor,
        image: image ?? this.image,
        createdBy: createdBy ?? this.createdBy,
        members: members ?? this.members,
        date: date ?? this.date,
        v: v ?? this.v,
        messageCount: messageCount ?? this.messageCount,
      );

  factory CommunityAllChatsModelData.fromJson(Map<String, dynamic> json) => CommunityAllChatsModelData(
        id: json["_id"],
        name: json["name"]!,
        description: json["description"]!,
        endTime: json["endTime"] == null ? null : DateTime.parse(json["endTime"]),
        editor: json["editor"]!,
        image: json["image"],
        createdBy: json["createdBy"]!,
        members: json["members"] == null ? [] : List<Member>.from(json["members"]!.map((x) => Member.fromJson(x))),
        date: json["date"] == null ? null : DateTime.parse(json["date"]),
        v: json["__v"],
        messageCount: json["messageCount"],
      );

  Map<String, dynamic> toJson() => {
        "_id": id,
        "name": name,
        "description": description,
        "endTime": endTime?.toIso8601String(),
        "editor": editor,
        "image": image,
        "createdBy": createdBy,
        "members": members == null ? [] : List<dynamic>.from(members!.map((x) => x.toJson())),
        "date": date?.toIso8601String(),
        "__v": v,
        "messageCount": messageCount,
      };
}

class Member {
  bool? isLeft;
  String? id;
  String? memberId;
  DateTime? joinDate;

  Member({
    this.isLeft,
    this.id,
    this.memberId,
    this.joinDate,
  });

  Member copyWith({
    bool? isLeft,
    String? id,
    String? memberId,
    DateTime? joinDate,
  }) =>
      Member(
        isLeft: isLeft ?? this.isLeft,
        id: id ?? this.id,
        memberId: memberId ?? this.memberId,
        joinDate: joinDate ?? this.joinDate,
      );

  factory Member.fromJson(Map<String, dynamic> json) => Member(
        isLeft: json["isLeft"],
        id: json["_id"],
        memberId: json["id"],
        joinDate: json["joinDate"] == null ? null : DateTime.parse(json["joinDate"]),
      );

  Map<String, dynamic> toJson() => {
        "isLeft": isLeft,
        "_id": id,
        "id": memberId,
        "joinDate": joinDate?.toIso8601String(),
      };

  @override
  String toString() {
    return 'Member{isLeft: $isLeft, id: $id, memberId: $memberId, joinDate: $joinDate}';
  }
}
