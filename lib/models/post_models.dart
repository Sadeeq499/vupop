// import 'dart:convert';

// PostModel postModelFromJson(String str) => PostModel.fromJson(json.decode(str));

// String postModelToJson(PostModel data) => json.encode(data.toJson());

// class PostModel {
//   List<dynamic> mention;
//   List<dynamic> tags;
//   String id;
//   String userId;
//   String video;
//   List<dynamic> clips;
//   Location? location;
//   String? area;
//   String? thumbnail;
//   DateTime? date;
//   int? v;

//   PostModel({
//     required this.mention,
//     required this.tags,
//     required this.id,
//     required this.userId,
//     required this.video,
//     required this.clips,
//     this.location,
//     this.area,
//     this.thumbnail,
//     this.date,
//     this.v,
//   });

//   factory PostModel.fromJson(Map<String, dynamic> json) {
//     return PostModel(
//       mention: json["mention"] == null ? [] : List<dynamic>.from(json["mention"]!.map((x) => x)),
//       tags: json["tags"] == null ? [] : List<dynamic>.from(json["tags"]!.map((x) => x)),
//       id: json['_id'],
//       userId: json['userId'],
//       video: json['video'],
//       clips: json["clips"] == null ? [] : List<dynamic>.from(json["clips"]!.map((x) => x)),
//       location: json['location'] != null ? Location.fromJson(json['location']) : null,
//       area: json['area'],
//       thumbnail: json['thumbnail'],
//       date: json["date"] == null ? null : DateTime.parse(json["date"]),
//       v: json["__v"],
//     );
//   }

//   Map<String, dynamic> toJson() {
//     return {
//       "location": location?.toJson(),
//       "mention": mention == null ? [] : List<dynamic>.from(mention!.map((x) => x)),
//       "tags": tags == null ? [] : List<dynamic>.from(tags!.map((x) => x)),
//       "_id": id,
//       "userId": userId,
//       "area": area,
//       "video": video,
//       "thumbnail": thumbnail,
//       "clips": clips == null ? [] : List<dynamic>.from(clips!.map((x) => x)),
//       "date": date?.toIso8601String(),
//       "__v": v,
//     };
//   }
// }

// class PostResponse {
//   final bool success;
//   final PostModel data;

//   PostResponse({required this.success, required this.data});

//   factory PostResponse.fromJson(Map<String, dynamic> json) {
//     return PostResponse(
//       success: json['success'],
//       data: PostModel.fromJson(json['data']),
//     );
//   }

//   Map<String, dynamic> toJson() {
//     return {
//       'success': success,
//       'data': data.toJson(),
//     };
//   }
// }

// class ListPostResponse {
//   final bool success;
//   final List<PostModel> data;

//   ListPostResponse({required this.success, required this.data});

//   factory ListPostResponse.fromJson(Map<String, dynamic> json) {
//     return ListPostResponse(
//       success: json['success'],
//       data: List<PostModel>.from(json['data']['posts'].map((x) => PostModel.fromJson(x))),
//     );
//   }

//   Map<String, dynamic> toJson() {
//     return {
//       'success': success,
//       'posts': List<dynamic>.from(data.map((x) => x.toJson())),
//     };
//   }
// }

// class Location {
//   List<double>? coordinates;
//   String? lat;
//   String? lng;
//   String? type;

//   Location({
//     this.coordinates,
//     this.lat,
//     this.lng,
//     this.type,
//   });

//   factory Location.fromJson(Map<String, dynamic> json) => Location(
//         coordinates: json["coordinates"] == null ? [] : List<double>.from(json["coordinates"]!.map((x) => x?.toDouble())),
//         lat: json["lat"],
//         lng: json["lng"],
//         type: json["type"],
//       );

//   Map<String, dynamic> toJson() => {
//         "coordinates": coordinates == null ? [] : List<dynamic>.from(coordinates!.map((x) => x)),
//         "lat": lat,
//         "lng": lng,
//         "type": type,
//       };
// }

import 'dart:convert';

import 'package:socials_app/utils/common_code.dart';

PostModel postModelFromJson(String str) => PostModel.fromJson(json.decode(str));

String postModelToJson(PostModel data) => json.encode(data.toJson());

class PostModel {
  List<String> mention;
  List<String> tags;
  String id;
  UploaderData userId;
  String video;
  List<dynamic> clips;
  Location? location;
  String? area;
  String? thumbnail;
  DateTime? date;
  int? v;
  List<String> likes;
  List<String> share;
  List<ViewsModel>? views;
  bool facecam;
  int likesCount;
  int sharesCount;
  double averageRating;
  String maskVideo;
  bool? isPortrait;
  List<String> reportedBy;
  int? reportCount;
  String landscapeVideo;
  String portraitVideo;
  String thumbnail2;
  String thumbnail3;
  String thumbnail4;

  PostModel({
    required this.mention,
    required this.tags,
    required this.id,
    required this.userId,
    required this.video,
    required this.clips,
    this.location,
    this.area,
    this.thumbnail,
    this.date,
    this.v,
    required this.likes,
    required this.share,
    required this.views,
    required this.facecam,
    required this.likesCount,
    required this.sharesCount,
    required this.averageRating,
    required this.maskVideo,
    required this.isPortrait,
    required this.reportedBy,
    required this.reportCount,
    required this.landscapeVideo,
    required this.portraitVideo,
    required this.thumbnail2,
    required this.thumbnail3,
    required this.thumbnail4,
  });

  factory PostModel.fromJson(Map<String, dynamic> json) {
    return PostModel(
      mention: json["mention"] == null || json["mention"] == [] ? [] : List<String>.from(json["mention"].map((x) => x)),
      tags: json["tags"] == null || json["tags"] == [] ? [] : List<String>.from(json["tags"].map((x) => x)),
      id: json['_id'],
      userId: json['userId'] is String ? UploaderData(id: json["userId"], name: "") : UploaderData.fromJson(json['userId']),
      video: /*json["p720"] != null && json["p720"] != '' && !hasUndefinedAfterLastSlash(json["p720"])
          ? json["p720"]
          : */
          json["isPortrait"] != null &&
                  json["isPortrait"] == true &&
                  json["portraitVideo"] != null &&
                  json["portraitVideo"] != '' &&
                  !hasUndefinedAfterLastSlash(json["portraitVideo"])
              ? json["portraitVideo"]
              : json["landscapeVideo"] != null && json["landscapeVideo"] != '' && !hasUndefinedAfterLastSlash(json["landscapeVideo"])
                  ? json["landscapeVideo"]
                  : json['video'],
      // video: json['video'],
      clips: json["clips"] == null || json["clips"] == [] ? [] : List<dynamic>.from(json["clips"].map((x) => x)),
      location: json['location'] != null ? Location.fromJson(json['location']) : null,
      area: json['area'],
      thumbnail: json['thumbnail'],
      date: json["date"] == null ? null : DateTime.parse(json["date"]),
      v: json["__v"],
      likes: json["likes"] == null || json["likes"] == [] ? [] : List<String>.from(json["likes"].map((x) => x)),
      share: json["share"] == null || json["share"] == [] ? [] : List<String>.from(json["share"].map((x) => x)),
      views: json["views"] == null || json["views"] == [] ? [] : List<ViewsModel>.from(json["views"].map((x) => ViewsModel.fromJson(x))),
      facecam: json['facecam'],
      likesCount: json['likesCount'] ?? 0,
      sharesCount: json['sharesCount'] ?? 0,
      averageRating: json['averageRating']?.toDouble() ?? 0.0,
      maskVideo: json['maskVideo'] != null && json['maskVideo'] is String ? json['maskVideo'] : "",
      isPortrait: json["isPortrait"],
      reportedBy: json["ReportedBy"] == null || json["ReportedBy"] == [] ? [] : List<String>.from(json["ReportedBy"]!.map((x) => x)),
      reportCount: json["reportCount"],
      landscapeVideo: json["landscapeVideo"] ?? "",
      portraitVideo: json["portraitVideo"] ?? "",
      thumbnail2: json["thumbnail2"] ?? "",
      thumbnail3: json["thumbnail3"] ?? "",
      thumbnail4: json["thumbnail4"] ?? "",
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "mention": List<dynamic>.from(mention.map((x) => x)),
      "tags": List<dynamic>.from(tags.map((x) => x)),
      "_id": id,
      "userId": userId,
      "video": video,
      "clips": List<dynamic>.from(clips.map((x) => x)),
      "location": location?.toJson(),
      "area": area,
      "thumbnail": thumbnail,
      "date": date?.toIso8601String(),
      "__v": v,
      "likes": List<dynamic>.from(likes.map((x) => x)),
      "share": List<dynamic>.from(share.map((x) => x)),
      "views": views == null ? null : List<dynamic>.from(views!.map((x) => x.toJson())),
      "facecam": facecam,
      "likesCount": likesCount,
      "sharesCount": sharesCount,
      "averageRating": averageRating,
      "maskVideo": maskVideo,
      "isPortrait": isPortrait,
      "ReportedBy": reportedBy == null ? [] : List<String>.from(reportedBy!.map((x) => x)),
      "reportCount": reportCount,
    };
  }

  @override
  String toString() {
    return 'PostModel{id: $id}';
  }
}

class PostResponse {
  final bool success;
  final PostModel data;

  PostResponse({required this.success, required this.data});

  factory PostResponse.fromJson(Map<String, dynamic> json) {
    return PostResponse(
      success: json['success'] ?? false,
      data: PostModel.fromJson(json['data']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'data': data.toJson(),
    };
  }
}

class ListPostResponse {
  final bool success;
  // final List<PostModel> data;

  final PostData data;
  ListPostResponse({required this.success, required this.data});

  factory ListPostResponse.fromJson(Map<String, dynamic> json) {
    return ListPostResponse(
      success: json['success'] ?? false,
      // data: List<PostModel>.from(json['data']['posts'].map((x) => PostModel.fromJson(x))),
      data: json["data"] == null ? PostData(posts: [], totalPages: 0, totalPosts: 0) : PostData.fromJson(json["data"]),
    );
  }

  /*Map<String, dynamic> toJson() {
    return {
      'success': success,
      'posts': List<dynamic>.from(data.map((x) => x.toJson())),
    };
  }*/
}

class PostData {
  String? message;
  int totalPosts;
  List<PostModel> posts;
  int totalPages;

  PostData({
    this.message,
    required this.totalPosts,
    required this.posts,
    required this.totalPages,
  });

  PostData copyWith({
    String? message,
    int? totalPosts,
    List<PostModel>? posts,
    int? totalPages,
  }) =>
      PostData(
        message: message ?? this.message,
        totalPosts: totalPosts ?? this.totalPosts,
        posts: posts ?? this.posts,
        totalPages: totalPages ?? this.totalPages,
      );

  factory PostData.fromJson(Map<String, dynamic> json) => PostData(
        message: json["message"] ?? "",
        totalPosts: json["totalPosts"] ?? 0,
        posts: json["posts"] == null || json["posts"] == [] ? [] : List<PostModel>.from(json["posts"]!.map((x) => PostModel.fromJson(x))),
        totalPages: json["totalPages"] ?? 0,
      );

  Map<String, dynamic> toJson() => {
        "message": message,
        "totalPosts": totalPosts,
        "posts": posts == null ? [] : List<dynamic>.from(posts!.map((x) => x.toJson())),
        "totalPages": totalPages,
      };
}

class Location {
  List<double>? coordinates;
  String? type;

  var coordinates0;

  Location({
    this.coordinates,
    this.type,
  });

  factory Location.fromJson(Map<String, dynamic> json) => Location(
        coordinates: json["coordinates"] == null || json["coordinates"] == [] ? [] : List<double>.from(json["coordinates"].map((x) => x?.toDouble())),
        type: json["type"],
      );

  Map<String, dynamic> toJson() => {
        "coordinates": coordinates == null ? [] : List<dynamic>.from(coordinates!.map((x) => x)),
        "type": type,
      };
}

class ViewsModel {
  final String id;
  final String name;
  final String? image;

  ViewsModel({required this.id, required this.name, this.image});

  factory ViewsModel.fromJson(Map<String, dynamic> json) => ViewsModel(
        id: json['_id'],
        name: json['name'],
        image: json['image'],
      );

  Map<String, dynamic> toJson() => {
        "_id": id,
        "name": name,
        "image": image,
      };
}

class UploaderData {
  final String id;
  final String name;
  final String? image;

  UploaderData({required this.id, required this.name, this.image});

  factory UploaderData.fromJson(Map<String, dynamic> json) => UploaderData(
        id: json['_id'],
        name: json['name'],
        image: json['image'],
      );

  Map<String, dynamic> toJson() => {
        "_id": id,
        "name": name,
        "image": image,
      };
}

bool hasUndefinedAfterLastSlash(String url) {
  // Split the URL by slash
  List<String> urlParts = url.split('/');

  // Check if the last part is exactly "undefined"
  printLogs("====urlParts.last == 'undefined' ${urlParts.last.split("?")[0] == 'undefined'}");
  return urlParts.last.split("?")[0] == 'undefined';
}
