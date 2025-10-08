import 'dart:convert';

PostResponseModel postResponseModelFromJson(String str) => PostResponseModel.fromJson(json.decode(str));

String postResponseModelToJson(PostResponseModel data) => json.encode(data.toJson());

class PostResponseModel {
  String? message;
  PostResponseModelData? data;

  PostResponseModel({
    this.message,
    this.data,
  });

  factory PostResponseModel.fromJson(Map<String, dynamic> json) => PostResponseModel(
        message: json["message"],
        data: json["data"] == null ? null : PostResponseModelData.fromJson(json["data"]),
      );

  Map<String, dynamic> toJson() => {
        "message": message,
        "data": data?.toJson(),
      };

  @override
  String toString() {
    return 'PostResponseModel{message: $message, data: $data}';
  }
}

class PostResponseModelData {
  Location? location;
  List<String>? mention;
  List<String>? tags;
  bool? facecam;
  List<dynamic>? likes;
  List<dynamic>? share;
  List<dynamic>? views;
  String? id;
  String? userId;
  String? area;
  String? video;
  String? thumbnail;
  String? maskVideo;
  List<dynamic>? clips;
  DateTime? date;
  int? v;

  PostResponseModelData({
    this.location,
    this.mention,
    this.tags,
    this.facecam,
    this.likes,
    this.share,
    this.views,
    this.id,
    this.userId,
    this.area,
    this.video,
    this.thumbnail,
    this.maskVideo,
    this.clips,
    this.date,
    this.v,
  });

  factory PostResponseModelData.fromJson(Map<String, dynamic> json) => PostResponseModelData(
        location: json["location"] == null ? null : Location.fromJson(json["location"]),
        mention: json["mention"] == null ? [] : List<String>.from(json["mention"]!.map((x) => x)),
        tags: json["tags"] == null ? [] : List<String>.from(json["tags"]!.map((x) => x)),
        facecam: json["facecam"],
        likes: json["likes"] == null ? [] : List<dynamic>.from(json["likes"]!.map((x) => x)),
        share: json["share"] == null ? [] : List<dynamic>.from(json["share"]!.map((x) => x)),
        views: json["views"] == null ? [] : List<dynamic>.from(json["views"]!.map((x) => x)),
        id: json["_id"],
        userId: json["userId"],
        area: json["area"],
        video: json["video"],
        thumbnail: json["thumbnail"],
        maskVideo: json["maskVideo"],
        clips: json["clips"] == null ? [] : List<dynamic>.from(json["clips"]!.map((x) => x)),
        date: json["date"] == null ? null : DateTime.parse(json["date"]),
        v: json["__v"],
      );

  Map<String, dynamic> toJson() => {
        "location": location?.toJson(),
        "mention": mention == null ? [] : List<dynamic>.from(mention!.map((x) => x)),
        "tags": tags == null ? [] : List<dynamic>.from(tags!.map((x) => x)),
        "facecam": facecam,
        "likes": likes == null ? [] : List<dynamic>.from(likes!.map((x) => x)),
        "share": share == null ? [] : List<dynamic>.from(share!.map((x) => x)),
        "views": views == null ? [] : List<dynamic>.from(views!.map((x) => x)),
        "_id": id,
        "userId": userId,
        "area": area,
        "video": video,
        "thumbnail": thumbnail,
        "maskVideo": maskVideo,
        "clips": clips == null ? [] : List<dynamic>.from(clips!.map((x) => x)),
        "date": date?.toIso8601String(),
        "__v": v,
      };

  @override
  String toString() {
    return 'Data{location: $location, mention: $mention, tags: $tags, facecam: $facecam, likes: $likes, share: $share, views: $views, id: $id, userId: $userId, area: $area, video: $video, thumbnail: $thumbnail, maskVideo: $maskVideo, clips: $clips, date: $date, v: $v}';
  }
}

class Location {
  List<double>? coordinates;
  String? type;

  Location({
    this.coordinates,
    this.type,
  });

  factory Location.fromJson(Map<String, dynamic> json) => Location(
        coordinates: json["coordinates"] == null ? [] : List<double>.from(json["coordinates"]!.map((x) => x?.toDouble())),
        type: json["type"],
      );

  Map<String, dynamic> toJson() => {
        "coordinates": coordinates == null ? [] : List<dynamic>.from(coordinates!.map((x) => x)),
        "type": type,
      };

  @override
  String toString() {
    return 'Location{coordinates: $coordinates, type: $type}';
  }
}
