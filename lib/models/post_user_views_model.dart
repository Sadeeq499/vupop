import 'dart:convert';

import 'package:socials_app/models/usermodel.dart';

PostUserViewsModel postUserViewsModelFromJson(String str) => PostUserViewsModel.fromJson(json.decode(str));

String postUserViewsModelToJson(PostUserViewsModel data) => json.encode(data.toJson());

class PostUserViewsModel {
  PostUserViewsDataModel? data;

  PostUserViewsModel({
    this.data,
  });

  PostUserViewsModel copyWith({
    PostUserViewsDataModel? data,
  }) =>
      PostUserViewsModel(
        data: data ?? this.data,
      );

  factory PostUserViewsModel.fromJson(Map<String, dynamic> json) => PostUserViewsModel(
        data: json["data"] == null ? null : PostUserViewsDataModel.fromJson(json["data"]),
      );

  Map<String, dynamic> toJson() => {
        "data": data?.toJson(),
      };
}

class PostUserViewsDataModel {
  String? message;
  List<Post>? post;

  PostUserViewsDataModel({
    this.message,
    this.post,
  });

  PostUserViewsDataModel copyWith({
    String? message,
    List<Post>? post,
  }) =>
      PostUserViewsDataModel(
        message: message ?? this.message,
        post: post ?? this.post,
      );

  factory PostUserViewsDataModel.fromJson(Map<String, dynamic> json) => PostUserViewsDataModel(
        message: json["message"],
        post: json["post"] == null ? [] : List<Post>.from(json["post"]!.map((x) => Post.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "message": message,
        "post": post == null ? [] : List<dynamic>.from(post!.map((x) => x.toJson())),
      };
}

class Post {
  String? id;
  List<UserDetailModel>? views;
  int? totalViews;

  Post({
    this.id,
    this.views,
    this.totalViews,
  });

  Post copyWith({
    String? id,
    List<UserDetailModel>? views,
    int? totalViews,
  }) =>
      Post(
        id: id ?? this.id,
        views: views ?? this.views,
        totalViews: totalViews ?? this.totalViews,
      );

  factory Post.fromJson(Map<String, dynamic> json) => Post(
        id: json["_id"],
        views: json["views"] == null ? [] : List<UserDetailModel>.from(json["views"]!.map((x) => UserDetailModel.fromJson(x))),
        totalViews: json["totalViews"],
      );

  Map<String, dynamic> toJson() => {
        "_id": id,
        "views": views == null ? [] : List<dynamic>.from(views!.map((x) => x.toJson())),
        "totalViews": totalViews,
      };
}

class View {
  ViewerLocation? location;
  List<dynamic>? favourite;
  List<String>? followers;
  List<String>? following;
  bool? isAdmin;
  List<String>? deviceId;
  bool? isDeleted;
  bool? isBlocked;
  bool? termAndCondition;
  bool? verified;
  List<dynamic>? passion;
  String? id;
  String? email;
  String? name;
  String? appleId;
  DateTime? date;
  int? v;
  String? about;
  String? image;

  View({
    this.location,
    this.favourite,
    this.followers,
    this.following,
    this.isAdmin,
    this.deviceId,
    this.isDeleted,
    this.isBlocked,
    this.termAndCondition,
    this.verified,
    this.passion,
    this.id,
    this.email,
    this.name,
    this.appleId,
    this.date,
    this.v,
    this.about,
    this.image,
  });

  View copyWith({
    ViewerLocation? location,
    List<dynamic>? favourite,
    List<String>? followers,
    List<String>? following,
    bool? isAdmin,
    List<String>? deviceId,
    bool? isDeleted,
    bool? isBlocked,
    bool? termAndCondition,
    bool? verified,
    List<dynamic>? passion,
    String? id,
    String? email,
    String? name,
    String? appleId,
    DateTime? date,
    int? v,
    String? about,
    String? image,
  }) =>
      View(
        location: location ?? this.location,
        favourite: favourite ?? this.favourite,
        followers: followers ?? this.followers,
        following: following ?? this.following,
        isAdmin: isAdmin ?? this.isAdmin,
        deviceId: deviceId ?? this.deviceId,
        isDeleted: isDeleted ?? this.isDeleted,
        isBlocked: isBlocked ?? this.isBlocked,
        termAndCondition: termAndCondition ?? this.termAndCondition,
        verified: verified ?? this.verified,
        passion: passion ?? this.passion,
        id: id ?? this.id,
        email: email ?? this.email,
        name: name ?? this.name,
        appleId: appleId ?? this.appleId,
        date: date ?? this.date,
        v: v ?? this.v,
        about: about ?? this.about,
        image: image ?? this.image,
      );

  factory View.fromJson(Map<String, dynamic> json) => View(
        location: json["location"] == null ? null : ViewerLocation.fromJson(json["location"]),
        favourite: json["favourite"] == null ? [] : List<dynamic>.from(json["favourite"]!.map((x) => x)),
        followers: json["followers"] == null ? [] : List<String>.from(json["followers"]!.map((x) => x)),
        following: json["following"] == null ? [] : List<String>.from(json["following"]!.map((x) => x)),
        isAdmin: json["isAdmin"],
        deviceId: json["deviceId"] == null ? [] : List<String>.from(json["deviceId"]!.map((x) => x)),
        isDeleted: json["isDeleted"],
        isBlocked: json["isBlocked"],
        termAndCondition: json["termAndCondition"],
        verified: json["verified"],
        passion: json["passion"] == null ? [] : List<dynamic>.from(json["passion"]!.map((x) => x)),
        id: json["_id"],
        email: json["email"],
        name: json["name"],
        appleId: json["appleId"],
        date: json["date"] == null ? null : DateTime.parse(json["date"]),
        v: json["__v"],
        about: json["about"],
        image: json["image"],
      );

  Map<String, dynamic> toJson() => {
        "location": location?.toJson(),
        "favourite": favourite == null ? [] : List<dynamic>.from(favourite!.map((x) => x)),
        "followers": followers == null ? [] : List<dynamic>.from(followers!.map((x) => x)),
        "following": following == null ? [] : List<dynamic>.from(following!.map((x) => x)),
        "isAdmin": isAdmin,
        "deviceId": deviceId == null ? [] : List<dynamic>.from(deviceId!.map((x) => x)),
        "isDeleted": isDeleted,
        "isBlocked": isBlocked,
        "termAndCondition": termAndCondition,
        "verified": verified,
        "passion": passion == null ? [] : List<dynamic>.from(passion!.map((x) => x)),
        "_id": id,
        "email": email,
        "name": name,
        "appleId": appleId,
        "date": date?.toIso8601String(),
        "__v": v,
        "about": about,
        "image": image,
      };
}

class ViewerLocation {
  List<double>? coordinates;
  String? type;

  ViewerLocation({
    this.coordinates,
    this.type,
  });

  ViewerLocation copyWith({
    List<double>? coordinates,
    String? type,
  }) =>
      ViewerLocation(
        coordinates: coordinates ?? this.coordinates,
        type: type ?? this.type,
      );

  factory ViewerLocation.fromJson(Map<String, dynamic> json) => ViewerLocation(
        coordinates: json["coordinates"] == null ? [] : List<double>.from(json["coordinates"]!.map((x) => x?.toDouble())),
        type: json["type"],
      );

  Map<String, dynamic> toJson() => {
        "coordinates": coordinates == null ? [] : List<dynamic>.from(coordinates!.map((x) => x)),
        "type": type,
      };
}
