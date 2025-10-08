import 'dart:convert';

UserCommunitiesModel userCommunitiesModelFromJson(String str) => UserCommunitiesModel.fromJson(json.decode(str));

String userCommunitiesModelToJson(UserCommunitiesModel data) => json.encode(data.toJson());

class UserCommunitiesModel {
  bool? success;
  UserCommunitiesModelData? data;

  UserCommunitiesModel({
    this.success,
    this.data,
  });

  UserCommunitiesModel copyWith({
    bool? success,
    UserCommunitiesModelData? data,
  }) =>
      UserCommunitiesModel(
        success: success ?? this.success,
        data: data ?? this.data,
      );

  factory UserCommunitiesModel.fromJson(Map<String, dynamic> json) => UserCommunitiesModel(
        success: json["success"],
        data: json["data"] == null ? null : UserCommunitiesModelData.fromJson(json["data"]),
      );

  Map<String, dynamic> toJson() => {
        "success": success,
        "data": data?.toJson(),
      };
}

class UserCommunitiesModelData {
  bool? success;
  List<UserCommunity>? communities;

  UserCommunitiesModelData({
    this.success,
    this.communities,
  });

  UserCommunitiesModelData copyWith({
    bool? success,
    List<UserCommunity>? communities,
  }) =>
      UserCommunitiesModelData(
        success: success ?? this.success,
        communities: communities ?? this.communities,
      );

  factory UserCommunitiesModelData.fromJson(Map<String, dynamic> json) => UserCommunitiesModelData(
        success: json["success"],
        communities: json["communities"] == null ? [] : List<UserCommunity>.from(json["communities"]!.map((x) => UserCommunity.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "success": success,
        "communities": communities == null ? [] : List<dynamic>.from(communities!.map((x) => x.toJson())),
      };
}

class UserCommunity {
  String? id;
  String? name;
  String? image;
  DateTime? endTime;
  String? latestMessage;
  DateTime? messageDate;

  UserCommunity({
    this.id,
    this.name,
    this.image,
    this.endTime,
    this.latestMessage,
    this.messageDate,
  });

  UserCommunity copyWith({
    String? id,
    String? name,
    String? image,
    DateTime? endTime,
    String? latestMessage,
    DateTime? messageDate,
  }) =>
      UserCommunity(
        id: id ?? this.id,
        name: name ?? this.name,
        image: image ?? this.image,
        endTime: endTime ?? this.endTime,
        latestMessage: latestMessage ?? this.latestMessage,
        messageDate: messageDate ?? this.messageDate,
      );

  factory UserCommunity.fromJson(Map<String, dynamic> json) => UserCommunity(
        id: json["_id"],
        name: json["name"],
        image: json["image"],
        endTime: json["endTime"] == null ? null : DateTime.parse(json["endTime"]),
        latestMessage: json["latestMessage"],
        messageDate: json["messageDate"] == null ? null : DateTime.parse(json["messageDate"]),
      );

  Map<String, dynamic> toJson() => {
        "_id": id,
        "name": name,
        "image": image,
        "endTime": endTime?.toIso8601String(),
        "latestMessage": latestMessage,
        "messageDate": messageDate?.toIso8601String(),
      };
}
