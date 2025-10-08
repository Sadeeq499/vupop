import 'dart:convert';

ReelsResponse reelsResponseFromJson(String str) =>
    ReelsResponse.fromJson(json.decode(str));

String reelsResponseToJson(ReelsResponse data) =>
    json.encode(data.toJson());


class ReelsUploadResponse {
  final String message;
  final Reel reel;

  ReelsUploadResponse({
    required this.message,
    required this.reel,
  });

  factory ReelsUploadResponse.fromJson(Map<String, dynamic> json) {
    return ReelsUploadResponse(
      message: json['message'],
      reel: Reel.fromJson(json['data']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'message': message,
      'reel': reel.toJson(),
    };
  }
}

class ReelsResponse {
  final String message;
  final List<Reel> reels;

  ReelsResponse({
    required this.message,
    required this.reels,
  });

  factory ReelsResponse.fromJson(Map<String, dynamic> json) {
    return ReelsResponse(
      message: json['message'],
      reels: List<Reel>.from(json['reels'].map((x) => Reel.fromJson(x))),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'message': message,
      'reels': List<dynamic>.from(reels.map((x) => x.toJson())),
    };
  }
}

class Reel {
  final List<String> visibility;
  final String id;
  final String userId;
  final String caption;
  final String video;
  final String thumbnail;
  final DateTime date;
  final int version;

  Reel({
    required this.visibility,
    required this.id,
    required this.userId,
    required this.caption,
    required this.video,
    required this.thumbnail,
    required this.date,
    required this.version,
  });

  factory Reel.fromJson(Map<String, dynamic> json) {
    return Reel(
      visibility: List<String>.from(json['visibility']),
      id: json['_id'],
      userId: json['userId'],
      caption: json['caption'],
      video: json['video'],
      thumbnail: json['thumbnail'],
      date: DateTime.parse(json['date']),
      version: json['__v'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'visibility': visibility,
      '_id': id,
      'userId': userId,
      'caption': caption,
      'video': video,
      'thumbnail': thumbnail,
      'date': date.toIso8601String(),
      '__v': version,
    };
  }
}