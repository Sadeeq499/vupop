import 'dart:convert';

TrendingHashTags trendingHashTagsFromJson(String str) => TrendingHashTags.fromJson(json.decode(str));

String trendingHashTagsToJson(TrendingHashTags data) => json.encode(data.toJson());

class TrendingHashTags {
  bool? success;
  String? message;
  List<TendingHashTagsData>? data;

  TrendingHashTags({
    this.success,
    this.message,
    this.data,
  });

  TrendingHashTags copyWith({
    bool? success,
    String? message,
    List<TendingHashTagsData>? data,
  }) =>
      TrendingHashTags(
        success: success ?? this.success,
        message: message ?? this.message,
        data: data ?? this.data,
      );

  factory TrendingHashTags.fromJson(Map<String, dynamic> json) => TrendingHashTags(
        success: json["success"],
        message: json["message"],
        data: json["data"] == null ? [] : List<TendingHashTagsData>.from(json["data"]!.map((x) => TendingHashTagsData.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "success": success,
        "message": message,
        "data": data == null ? [] : List<dynamic>.from(data!.map((x) => x.toJson())),
      };
}

class TendingHashTagsData {
  String? id;
  int? count;

  TendingHashTagsData({
    this.id,
    this.count,
  });

  TendingHashTagsData copyWith({
    String? id,
    int? count,
  }) =>
      TendingHashTagsData(
        id: id ?? this.id,
        count: count ?? this.count,
      );

  factory TendingHashTagsData.fromJson(Map<String, dynamic> json) => TendingHashTagsData(
        id: json["_id"],
        count: json["count"],
      );

  Map<String, dynamic> toJson() => {
        "_id": id,
        "count": count,
      };
}
