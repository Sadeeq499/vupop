import 'dart:convert';

ExportNotificationsModel exportNotificationsModelFromJson(String str) => ExportNotificationsModel.fromJson(json.decode(str));

String exportNotificationsModelToJson(ExportNotificationsModel data) => json.encode(data.toJson());

class ExportNotificationsModel {
  bool? success;
  String? message;
  ExportNotificationsDataModel? data;

  ExportNotificationsModel({
    this.success,
    this.message,
    this.data,
  });

  ExportNotificationsModel copyWith({
    bool? success,
    String? message,
    ExportNotificationsDataModel? data,
  }) =>
      ExportNotificationsModel(
        success: success ?? this.success,
        message: message ?? this.message,
        data: data ?? this.data,
      );

  factory ExportNotificationsModel.fromJson(Map<String, dynamic> json) => ExportNotificationsModel(
        success: json["success"] ?? false,
        message: json["message"] ?? "",
        data: json["data"] == null ? null : ExportNotificationsDataModel.fromJson(json["data"]),
      );

  Map<String, dynamic> toJson() => {
        "success": success,
        "message": message,
        "data": data?.toJson(),
      };
}

class ExportNotificationsDataModel {
  List<PostNotification>? notification;
  int? pages;

  ExportNotificationsDataModel({
    this.notification,
    this.pages,
  });

  ExportNotificationsDataModel copyWith({
    List<PostNotification>? notification,
    int? pages,
  }) =>
      ExportNotificationsDataModel(
        notification: notification ?? this.notification,
        pages: pages ?? this.pages,
      );

  factory ExportNotificationsDataModel.fromJson(Map<String, dynamic> json) => ExportNotificationsDataModel(
        notification: json["notification"] == null ? [] : List<PostNotification>.from(json["notification"]!.map((x) => PostNotification.fromJson(x))),
        pages: json["pages"],
      );

  Map<String, dynamic> toJson() => {
        "notification": notification == null ? [] : List<dynamic>.from(notification!.map((x) => x.toJson())),
        "pages": pages,
      };
}

class PostNotification {
  String? id;
  String? message;
  DateTime? date;
  Sender? sender;
  Post? post;

  PostNotification({
    this.id,
    this.message,
    this.date,
    this.sender,
    this.post,
  });

  PostNotification copyWith({
    String? id,
    String? message,
    DateTime? date,
    Sender? sender,
    Post? post,
  }) =>
      PostNotification(
        id: id ?? this.id,
        message: message ?? this.message,
        date: date ?? this.date,
        sender: sender ?? this.sender,
        post: post ?? this.post,
      );

  factory PostNotification.fromJson(Map<String, dynamic> json) => PostNotification(
        id: json["id"],
        message: json["message"],
        date: json["date"] == null ? null : DateTime.parse(json["date"]),
        sender: json["sender"] == null ? null : Sender.fromJson(json["sender"]),
        post: json["post"] == null ? null : Post.fromJson(json["post"]),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "message": message,
        "date": date?.toIso8601String(),
        "sender": sender?.toJson(),
        "post": post?.toJson(),
      };
}

class Post {
  Location? location;
  List<String>? mention;
  List<String>? tags;
  bool? isPortrait;
  bool? facecam;
  bool? recordedByVupop;
  List<dynamic>? reportedBy;
  List<dynamic>? likes;
  List<dynamic>? share;
  List<dynamic>? views;
  String? id;
  String? userId;
  String? area;
  String? video;
  String? thumbnail;
  String? flaggedStatus;
  String? flaggedPercentage;
  String? maskVideo;
  List<dynamic>? clips;
  DateTime? date;
  int? v;
  String? landscapeVideo;
  String? portraitVideo;
  String? thumbnail2;
  String? thumbnail3;
  String? thumbnail4;
  String? watermarkImage;
  String? landscapeVideoUhd;
  String? portraitVideoUhd;

  Post({
    this.location,
    this.mention,
    this.tags,
    this.isPortrait,
    this.facecam,
    this.recordedByVupop,
    this.reportedBy,
    this.likes,
    this.share,
    this.views,
    this.id,
    this.userId,
    this.area,
    this.video,
    this.thumbnail,
    this.flaggedStatus,
    this.flaggedPercentage,
    this.maskVideo,
    this.clips,
    this.date,
    this.v,
    this.landscapeVideo,
    this.portraitVideo,
    this.thumbnail2,
    this.thumbnail3,
    this.thumbnail4,
    this.watermarkImage,
    this.landscapeVideoUhd,
    this.portraitVideoUhd,
  });

  Post copyWith({
    Location? location,
    List<String>? mention,
    List<String>? tags,
    bool? isPortrait,
    bool? facecam,
    bool? recordedByVupop,
    List<dynamic>? reportedBy,
    List<dynamic>? likes,
    List<dynamic>? share,
    List<dynamic>? views,
    String? id,
    String? userId,
    String? area,
    String? video,
    String? thumbnail,
    String? flaggedStatus,
    String? flaggedPercentage,
    String? maskVideo,
    List<dynamic>? clips,
    DateTime? date,
    int? v,
    String? landscapeVideo,
    String? portraitVideo,
    String? thumbnail2,
    String? thumbnail3,
    String? thumbnail4,
    String? watermarkImage,
    String? landscapeVideoUhd,
    String? portraitVideoUhd,
  }) =>
      Post(
        location: location ?? this.location,
        mention: mention ?? this.mention,
        tags: tags ?? this.tags,
        isPortrait: isPortrait ?? this.isPortrait,
        facecam: facecam ?? this.facecam,
        recordedByVupop: recordedByVupop ?? this.recordedByVupop,
        reportedBy: reportedBy ?? this.reportedBy,
        likes: likes ?? this.likes,
        share: share ?? this.share,
        views: views ?? this.views,
        id: id ?? this.id,
        userId: userId ?? this.userId,
        area: area ?? this.area,
        video: video ?? this.video,
        thumbnail: thumbnail ?? this.thumbnail,
        flaggedStatus: flaggedStatus ?? this.flaggedStatus,
        flaggedPercentage: flaggedPercentage ?? this.flaggedPercentage,
        maskVideo: maskVideo ?? this.maskVideo,
        clips: clips ?? this.clips,
        date: date ?? this.date,
        v: v ?? this.v,
        landscapeVideo: landscapeVideo ?? this.landscapeVideo,
        portraitVideo: portraitVideo ?? this.portraitVideo,
        thumbnail2: thumbnail2 ?? this.thumbnail2,
        thumbnail3: thumbnail3 ?? this.thumbnail3,
        thumbnail4: thumbnail4 ?? this.thumbnail4,
        watermarkImage: watermarkImage ?? this.watermarkImage,
        landscapeVideoUhd: landscapeVideoUhd ?? this.landscapeVideoUhd,
        portraitVideoUhd: portraitVideoUhd ?? this.portraitVideoUhd,
      );

  factory Post.fromJson(Map<String, dynamic> json) => Post(
        location: json["location"] == null ? null : Location.fromJson(json["location"]),
        mention: json["mention"] == null ? [] : List<String>.from(json["mention"]!.map((x) => x)),
        tags: json["tags"] == null ? [] : List<String>.from(json["tags"]!.map((x) => x)),
        isPortrait: json["isPortrait"],
        facecam: json["facecam"],
        recordedByVupop: json["recordedByVupop"],
        reportedBy: json["ReportedBy"] == null ? [] : List<dynamic>.from(json["ReportedBy"]!.map((x) => x)),
        likes: json["likes"] == null ? [] : List<dynamic>.from(json["likes"]!.map((x) => x)),
        share: json["share"] == null ? [] : List<dynamic>.from(json["share"]!.map((x) => x)),
        views: json["views"] == null ? [] : List<dynamic>.from(json["views"]!.map((x) => x)),
        id: json["_id"],
        userId: json["userId"],
        area: json["area"],
        video: json["video"],
        thumbnail: json["thumbnail"],
        flaggedStatus: json["flagged_status"],
        flaggedPercentage: json["flagged_percentage"],
        maskVideo: json["maskVideo"],
        clips: json["clips"] == null ? [] : List<dynamic>.from(json["clips"]!.map((x) => x)),
        date: json["date"] == null ? null : DateTime.parse(json["date"]),
        v: json["__v"],
        landscapeVideo: json["landscapeVideo"],
        portraitVideo: json["portraitVideo"],
        thumbnail2: json["thumbnail2"],
        thumbnail3: json["thumbnail3"],
        thumbnail4: json["thumbnail4"],
        watermarkImage: json["watermarkImage"],
        landscapeVideoUhd: json["landscapeVideoUHD"],
        portraitVideoUhd: json["portraitVideoUHD"],
      );

  Map<String, dynamic> toJson() => {
        "location": location?.toJson(),
        "mention": mention == null ? [] : List<dynamic>.from(mention!.map((x) => x)),
        "tags": tags == null ? [] : List<dynamic>.from(tags!.map((x) => x)),
        "isPortrait": isPortrait,
        "facecam": facecam,
        "recordedByVupop": recordedByVupop,
        "ReportedBy": reportedBy == null ? [] : List<dynamic>.from(reportedBy!.map((x) => x)),
        "likes": likes == null ? [] : List<dynamic>.from(likes!.map((x) => x)),
        "share": share == null ? [] : List<dynamic>.from(share!.map((x) => x)),
        "views": views == null ? [] : List<dynamic>.from(views!.map((x) => x)),
        "_id": id,
        "userId": userId,
        "area": area,
        "video": video,
        "thumbnail": thumbnail,
        "flagged_status": flaggedStatus,
        "flagged_percentage": flaggedPercentage,
        "maskVideo": maskVideo,
        "clips": clips == null ? [] : List<dynamic>.from(clips!.map((x) => x)),
        "date": date?.toIso8601String(),
        "__v": v,
        "landscapeVideo": landscapeVideo,
        "portraitVideo": portraitVideo,
        "thumbnail2": thumbnail2,
        "thumbnail3": thumbnail3,
        "thumbnail4": thumbnail4,
        "watermarkImage": watermarkImage,
        "landscapeVideoUHD": landscapeVideoUhd,
        "portraitVideoUHD": portraitVideoUhd,
      };
}

class Location {
  List<double>? coordinates;
  String? type;

  Location({
    this.coordinates,
    this.type,
  });

  Location copyWith({
    List<double>? coordinates,
    String? type,
  }) =>
      Location(
        coordinates: coordinates ?? this.coordinates,
        type: type ?? this.type,
      );

  factory Location.fromJson(Map<String, dynamic> json) => Location(
        coordinates: json["coordinates"] == null ? [] : List<double>.from(json["coordinates"]!.map((x) => x?.toDouble())),
        type: json["type"]!,
      );

  Map<String, dynamic> toJson() => {
        "coordinates": coordinates == null ? [] : List<dynamic>.from(coordinates!.map((x) => x)),
        "type": type,
      };
}

class Sender {
  String? name;
  String? image;

  Sender({
    this.name,
    this.image,
  });

  Sender copyWith({
    String? name,
    String? image,
  }) =>
      Sender(
        name: name ?? this.name,
        image: image ?? this.image,
      );

  factory Sender.fromJson(Map<String, dynamic> json) => Sender(
        name: json["name"]!,
        image: json["image"],
      );

  Map<String, dynamic> toJson() => {
        "name": name,
        "image": image,
      };
}
