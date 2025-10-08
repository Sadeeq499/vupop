// To parse this JSON data, do
//
//     final localUserVideoPostModel = localUserVideoPostModelFromJson(jsonString);

import 'dart:convert';
import 'dart:io';

LocalUserVideoPostModel localUserVideoPostModelFromJson(String str) => LocalUserVideoPostModel.fromJson(json.decode(str));

String localUserVideoPostModelToJson(LocalUserVideoPostModel data) => json.encode(data.toJson());

class LocalUserVideoPostModel {
  String? userId;
  String? videoPath;
  File? thumbnailFile;
  Map<String, String>? mentions;
  Map<String, String>? tags;
  String? locationCoordinates0;
  String? locationCoordinates1;
  String? facecam;
  String? isPortrait;
  String? area;
  List<String>? mentionIdsList;
  double? lat;
  double? lng;
  String? locationAdress;
  bool? recordedByVupop;
  int? videoProgress;
  String? status;

  LocalUserVideoPostModel({
    this.userId,
    this.videoPath,
    this.thumbnailFile,
    this.mentions,
    this.tags,
    this.locationCoordinates0,
    this.locationCoordinates1,
    this.facecam,
    this.isPortrait,
    this.area,
    this.mentionIdsList,
    this.lat,
    this.lng,
    this.locationAdress,
    this.recordedByVupop,
    this.videoProgress,
    this.status,
  });

  LocalUserVideoPostModel copyWith(
          {String? userId,
          String? videoPath,
          File? thumbnailFile,
          Map<String, String>? mentions,
          Map<String, String>? tags,
          String? locationCoordinates0,
          String? locationCoordinates1,
          String? facecam,
          String? isPortrait,
          String? area,
          List<String>? mentionIdsList,
          double? lat,
          double? lng,
          String? locationAdress,
          bool? recordedByVupop,
          int? videoProgress,
          String? status}) =>
      LocalUserVideoPostModel(
        userId: userId ?? this.userId,
        videoPath: videoPath ?? this.videoPath,
        thumbnailFile: thumbnailFile ?? this.thumbnailFile,
        mentions: mentions ?? this.mentions,
        tags: tags ?? this.tags,
        locationCoordinates0: locationCoordinates0 ?? this.locationCoordinates0,
        locationCoordinates1: locationCoordinates1 ?? this.locationCoordinates1,
        facecam: facecam ?? this.facecam,
        isPortrait: isPortrait ?? this.isPortrait,
        area: area ?? this.area,
        mentionIdsList: mentionIdsList ?? this.mentionIdsList,
        lat: lat ?? this.lat,
        lng: lng ?? this.lng,
        locationAdress: locationAdress ?? this.locationAdress,
        recordedByVupop: recordedByVupop ?? this.recordedByVupop,
        videoProgress: videoProgress ?? this.videoProgress,
        status: status ?? this.status,
      );

  factory LocalUserVideoPostModel.fromJson(Map<dynamic, dynamic> json) => LocalUserVideoPostModel(
        userId: json["userId"],
        videoPath: json["videoPath"],
        thumbnailFile: json["thumbnailFile"] is String ? File(json["thumbnailFile"]) : json["thumbnailFile"],
        // For mentions
        mentions: json["mentions"] == null
            ? <String, String>{}
            : json["mentions"] is List
                ? (json["mentions"].length > 0
                    ? Map<String, String>.from(
                        {for (int i = 0; i < json["mentions"].length; i++) "mentions[$i]": json["mentions"][i]?.toString() ?? ""})
                    : <String, String>{})
                : Map<String, String>.from(
                    (json["mentions"] as Map).map((key, value) => MapEntry<String, String>(key.toString(), value?.toString() ?? ""))),

        // For tags
        tags: json["tags"] == null
            ? <String, String>{}
            : json["tags"] is List
                ? (json["tags"].length > 0
                    ? Map<String, String>.from({for (int i = 0; i < json["tags"].length; i++) "tags[$i]": json["tags"][i]?.toString() ?? ""})
                    : <String, String>{})
                : Map<String, String>.from(
                    (json["tags"] as Map).map((key, value) => MapEntry<String, String>(key.toString(), value?.toString() ?? ""))),
        /*
        mentions: json["mentions"].length > 0
            ? json["mentions"].map((key, value) {
                return MapEntry(key, value?.toString());
              })
            : <String, String>{},
        tags: json["tags"].length > 0
            ? json["tags"].map((key, value) {
                return MapEntry(key, value?.toString());
              })
            : <String, String>{},*/
        locationCoordinates0: json["location[coordinates][0]"],
        locationCoordinates1: json["location[coordinates][1]"],
        facecam: json["facecam"] ?? "false",
        isPortrait: json["isPortrait"] ?? "true",
        area: json["area"] ?? "",
        mentionIdsList: json["mentionIdsList"] == null ? [] : List<String>.from(json["mentionIdsList"]!.map((x) => x)),
        lat: json["lat"]?.toDouble() ?? 0.0,
        lng: json["lng"]?.toDouble() ?? 0.0,
        locationAdress: json["locationAdress"] ?? "",
        recordedByVupop: json["recordedByVupop"] ?? true,
        videoProgress: json["videoProgress"] ?? 0,
        status: json["status"] ?? "",
      );

  Map<String, dynamic> toJson() => {
        "userId": userId,
        "videoPath": videoPath,
        "thumbnailFile": thumbnailFile,
        "mentions": mentions,
        "tags": tags,
        "location[coordinates][0]": locationCoordinates0,
        "location[coordinates][1]": locationCoordinates1,
        "facecam": facecam,
        "isPortrait": isPortrait,
        "area": area,
        "mentionIdsList": mentionIdsList == null ? [] : List<dynamic>.from(mentionIdsList!.map((x) => x)),
        "lat": lat,
        "lng": lng,
        "locationAdress": locationAdress,
        "recordedByVupop": recordedByVupop,
        "videoProgress": videoProgress,
        "status": status,
      };
}
