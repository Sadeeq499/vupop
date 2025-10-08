import 'dart:convert';

RatingResponse ratingResponseModelFromJson(String str) => RatingResponse.fromJson(json.decode(str));
RatingData ratingsModelFromJson(String str) => RatingData.fromJson(json.decode(str));

class RatingResponse {
  final String message;
  final RatingData data;
  final double averageRating;

  RatingResponse({
    required this.message,
    required this.data,
    required this.averageRating,
  });

  factory RatingResponse.fromJson(Map<String, dynamic> json) {
    return RatingResponse(
      message: json['message'],
      data: RatingData.fromJson(json['data']),
      averageRating: (json['averageRating'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'message': message,
      'data': data.toJson(),
      'averageRating': averageRating,
    };
  }
}

class RatingData {
  final String? id;
  final String? userId;
  final String? videoId;
  final int? stars;

  RatingData({
    this.id,
    this.userId,
    this.videoId,
    this.stars,
  });

  factory RatingData.fromJson(Map<String, dynamic> json) {
    return RatingData(
      id: json['_id'],
      userId: json['userId'],
      videoId: json['videoId'],
      stars: json['stars'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'userId': userId,
      'videoId': videoId,
      'stars': stars,
    };
  }
}
