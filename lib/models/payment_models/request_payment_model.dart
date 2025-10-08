import 'dart:convert';

RequestPaymentModel requestPaymentModelFromJson(String str) => RequestPaymentModel.fromJson(json.decode(str));

String requestPaymentModelToJson(RequestPaymentModel data) => json.encode(data.toJson());

class RequestPaymentModel {
  bool? success;
  RequestPaymentData? data;

  RequestPaymentModel({
    this.success,
    this.data,
  });

  RequestPaymentModel copyWith({
    bool? success,
    RequestPaymentData? data,
  }) =>
      RequestPaymentModel(
        success: success ?? this.success,
        data: data ?? this.data,
      );

  factory RequestPaymentModel.fromJson(Map<String, dynamic> json) => RequestPaymentModel(
        success: json["success"],
        data: json["data"] == null ? null : RequestPaymentData.fromJson(json["data"]),
      );

  Map<String, dynamic> toJson() => {
        "success": success,
        "data": data?.toJson(),
      };
}

class RequestPaymentData {
  String? message;
  List<Exportss>? exportss;

  RequestPaymentData({
    this.message,
    this.exportss,
  });

  RequestPaymentData copyWith({
    String? message,
    List<Exportss>? exportss,
  }) =>
      RequestPaymentData(
        message: message ?? this.message,
        exportss: exportss ?? this.exportss,
      );

  factory RequestPaymentData.fromJson(Map<String, dynamic> json) => RequestPaymentData(
        message: json["message"],
        exportss: json["exportss"] == null ? [] : List<Exportss>.from(json["exportss"]!.map((x) => Exportss.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "message": message,
        "exportss": exportss == null ? [] : List<dynamic>.from(exportss!.map((x) => x.toJson())),
      };
}

class Exportss {
  double? totalAmount;
  List<Export>? exports;

  Exportss({
    this.totalAmount,
    this.exports,
  });

  Exportss copyWith({
    double? totalAmount,
    List<Export>? exports,
  }) =>
      Exportss(
        totalAmount: totalAmount ?? this.totalAmount,
        exports: exports ?? this.exports,
      );

  factory Exportss.fromJson(Map<String, dynamic> json) => Exportss(
        totalAmount: json["totalAmount"]?.toDouble(),
        exports: json["exports"] == null ? [] : List<Export>.from(json["exports"]!.map((x) => Export.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "totalAmount": totalAmount,
        "exports": exports == null ? [] : List<dynamic>.from(exports!.map((x) => x.toJson())),
      };
}

class Export {
  String? exportedBy;
  Post? post;

  Export({
    this.exportedBy,
    this.post,
  });

  Export copyWith({
    String? exportedBy,
    Post? post,
  }) =>
      Export(
        exportedBy: exportedBy ?? this.exportedBy,
        post: post ?? this.post,
      );

  factory Export.fromJson(Map<String, dynamic> json) => Export(
        exportedBy: json["exportedBy"],
        post: json["post"] == null ? null : Post.fromJson(json["post"]),
      );

  Map<String, dynamic> toJson() => {
        "exportedBy": exportedBy,
        "post": post?.toJson(),
      };
}

class Post {
  String? thumbnail;
  double? duration;

  Post({
    this.thumbnail,
    this.duration,
  });

  Post copyWith({
    String? thumbnail,
    double? duration,
  }) =>
      Post(
        thumbnail: thumbnail ?? this.thumbnail,
        duration: duration ?? this.duration,
      );

  factory Post.fromJson(Map<String, dynamic> json) => Post(
        thumbnail: json["thumbnail"],
        duration: json["duration"]?.toDouble(),
      );

  Map<String, dynamic> toJson() => {
        "thumbnail": thumbnail,
        "duration": duration,
      };
}
