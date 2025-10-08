import 'dart:convert';

ExportPostNotificationModel exportPostNotificationModelFromJson(String str) => ExportPostNotificationModel.fromJson(json.decode(str));

String exportPostNotificationModelToJson(ExportPostNotificationModel data) => json.encode(data.toJson());

class ExportPostNotificationModel {
  List<NotificationData>? notification;
  int? pages;
  String? newNoti;

  ExportPostNotificationModel({
    this.notification,
    this.pages,
    this.newNoti,
  });

  ExportPostNotificationModel copyWith({
    List<NotificationData>? notification,
    int? pages,
  }) =>
      ExportPostNotificationModel(
        notification: notification ?? this.notification,
        pages: pages ?? this.pages,
        newNoti: newNoti ?? this.newNoti,
      );

  factory ExportPostNotificationModel.fromJson(Map<String, dynamic> json) => ExportPostNotificationModel(
        notification: json["notification"] == null ? [] : List<NotificationData>.from(json["notification"]!.map((x) => NotificationData.fromJson(x))),
        pages: json["pages"],
        newNoti: json["newNoti"] ?? "",
      );

  Map<String, dynamic> toJson() => {
        "notification": notification == null ? [] : List<dynamic>.from(notification!.map((x) => x.toJson())),
        "pages": pages,
        "newNoti": newNoti,
      };
}

class NotificationData {
  String? id;
  String? message;
  DateTime? date;
  NotificationPostSender? sender;
  NotificationPost? post;

  NotificationData({
    this.id,
    this.message,
    this.date,
    this.sender,
    this.post,
  });

  NotificationData copyWith({
    String? id,
    String? message,
    DateTime? date,
    NotificationPostSender? sender,
    NotificationPost? post,
  }) =>
      NotificationData(
        id: id ?? this.id,
        message: message ?? this.message,
        date: date ?? this.date,
        sender: sender ?? this.sender,
        post: post ?? this.post,
      );

  factory NotificationData.fromJson(Map<String, dynamic> json) => NotificationData(
        id: json["id"],
        message: json["message"],
        date: json["date"] == null ? null : DateTime.parse(json["date"]),
        sender: json["sender"] == null ? null : NotificationPostSender.fromJson(json["sender"]),
        post: json["post"] == null ? null : NotificationPost.fromJson(json["post"]),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "message": message,
        "date": date?.toIso8601String(),
        "sender": sender?.toJson(),
        "post": post?.toJson(),
      };
}

class NotificationPost {
  NotificationPostLocation? location;
  List<String>? mention;
  List<String>? tags;
  bool? isPortrait;
  bool? facecam;
  bool? recordedByVupop;
  List<dynamic>? reportedBy;
  List<dynamic>? likes;
  List<dynamic>? share;
  List<String>? views;
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
  String? landscapeVideoUhd;
  String? portraitVideo;
  String? portraitVideoUhd;
  String? thumbnail2;
  String? thumbnail3;
  String? thumbnail4;
  String? watermarkImage;

  NotificationPost({
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
    this.landscapeVideoUhd,
    this.portraitVideo,
    this.portraitVideoUhd,
    this.thumbnail2,
    this.thumbnail3,
    this.thumbnail4,
    this.watermarkImage,
  });

  NotificationPost copyWith({
    NotificationPostLocation? location,
    List<String>? mention,
    List<String>? tags,
    bool? isPortrait,
    bool? facecam,
    bool? recordedByVupop,
    List<dynamic>? reportedBy,
    List<dynamic>? likes,
    List<dynamic>? share,
    List<String>? views,
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
    String? landscapeVideoUhd,
    String? portraitVideo,
    String? portraitVideoUhd,
    String? thumbnail2,
    String? thumbnail3,
    String? thumbnail4,
    String? watermarkImage,
  }) =>
      NotificationPost(
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
        landscapeVideoUhd: landscapeVideoUhd ?? this.landscapeVideoUhd,
        portraitVideo: portraitVideo ?? this.portraitVideo,
        portraitVideoUhd: portraitVideoUhd ?? this.portraitVideoUhd,
        thumbnail2: thumbnail2 ?? this.thumbnail2,
        thumbnail3: thumbnail3 ?? this.thumbnail3,
        thumbnail4: thumbnail4 ?? this.thumbnail4,
        watermarkImage: watermarkImage ?? this.watermarkImage,
      );

  factory NotificationPost.fromJson(Map<String, dynamic> json) => NotificationPost(
        location: json["location"] == null ? null : NotificationPostLocation.fromJson(json["location"]),
        mention: json["mention"] == null ? [] : List<String>.from(json["mention"]!.map((x) => x)),
        tags: json["tags"] == null ? [] : List<String>.from(json["tags"]!.map((x) => x)),
        isPortrait: json["isPortrait"],
        facecam: json["facecam"],
        recordedByVupop: json["recordedByVupop"],
        reportedBy: json["ReportedBy"] == null ? [] : List<dynamic>.from(json["ReportedBy"]!.map((x) => x)),
        likes: json["likes"] == null ? [] : List<dynamic>.from(json["likes"]!.map((x) => x)),
        share: json["share"] == null ? [] : List<dynamic>.from(json["share"]!.map((x) => x)),
        views: json["views"] == null ? [] : List<String>.from(json["views"]!.map((x) => x)),
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
        landscapeVideoUhd: json["landscapeVideoUHD"],
        portraitVideo: json["portraitVideo"],
        portraitVideoUhd: json["portraitVideoUHD"],
        thumbnail2: json["thumbnail2"],
        thumbnail3: json["thumbnail3"],
        thumbnail4: json["thumbnail4"],
        watermarkImage: json["watermarkImage"],
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
        "landscapeVideoUHD": landscapeVideoUhd,
        "portraitVideo": portraitVideo,
        "portraitVideoUHD": portraitVideoUhd,
        "thumbnail2": thumbnail2,
        "thumbnail3": thumbnail3,
        "thumbnail4": thumbnail4,
        "watermarkImage": watermarkImage,
      };
}

class NotificationPostLocation {
  List<double>? coordinates;
  String? type;

  NotificationPostLocation({
    this.coordinates,
    this.type,
  });

  NotificationPostLocation copyWith({
    List<double>? coordinates,
    String? type,
  }) =>
      NotificationPostLocation(
        coordinates: coordinates ?? this.coordinates,
        type: type ?? this.type,
      );

  factory NotificationPostLocation.fromJson(Map<String, dynamic> json) => NotificationPostLocation(
        coordinates: json["coordinates"] == null ? [] : List<double>.from(json["coordinates"]!.map((x) => x?.toDouble())),
        type: json["type"],
      );

  Map<String, dynamic> toJson() => {
        "coordinates": coordinates == null ? [] : List<dynamic>.from(coordinates!.map((x) => x)),
        "type": type,
      };
}

class NotificationPostSender {
  String? name;
  String? image;

  NotificationPostSender({
    this.name,
    this.image,
  });

  NotificationPostSender copyWith({
    String? name,
    String? image,
  }) =>
      NotificationPostSender(
        name: name ?? this.name,
        image: image ?? this.image,
      );

  factory NotificationPostSender.fromJson(Map<String, dynamic> json) => NotificationPostSender(
        name: json["name"],
        image: json["image"],
      );

  Map<String, dynamic> toJson() => {
        "name": name,
        "image": image,
      };
}
