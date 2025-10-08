import 'dart:convert';

BlockReportModel blockReportModelFromJson(String str) => BlockReportModel.fromJson(json.decode(str));

String blockReportModelToJson(BlockReportModel data) => json.encode(data.toJson());

class BlockReportModel {
  String? message;
  Data? data;

  BlockReportModel({
    this.message,
    this.data,
  });

  BlockReportModel copyWith({
    String? message,
    Data? data,
  }) =>
      BlockReportModel(
        message: message ?? this.message,
        data: data ?? this.data,
      );

  factory BlockReportModel.fromJson(Map<String, dynamic> json) => BlockReportModel(
        message: json["message"],
        data: json["data"] == null ? null : Data.fromJson(json["data"]),
      );

  Map<String, dynamic> toJson() => {
        "message": message,
        "data": data?.toJson(),
      };
}

class Data {
  bool? isReport;
  String? id;
  String? reportedBy;
  String? clip;
  String? reason;
  DateTime? date;
  int? v;

  Data({
    this.isReport,
    this.id,
    this.reportedBy,
    this.clip,
    this.reason,
    this.date,
    this.v,
  });

  Data copyWith({
    bool? isReport,
    String? id,
    String? reportedBy,
    String? clip,
    String? reason,
    DateTime? date,
    int? v,
  }) =>
      Data(
        isReport: isReport ?? this.isReport,
        id: id ?? this.id,
        reportedBy: reportedBy ?? this.reportedBy,
        clip: clip ?? this.clip,
        reason: reason ?? this.reason,
        date: date ?? this.date,
        v: v ?? this.v,
      );

  factory Data.fromJson(Map<String, dynamic> json) => Data(
        isReport: json["isReport"],
        id: json["_id"],
        reportedBy: json["ReportedBy"],
        clip: json["clip"],
        reason: json["reason"],
        date: json["date"] == null ? null : DateTime.parse(json["date"]),
        v: json["__v"],
      );

  Map<String, dynamic> toJson() => {
        "isReport": isReport,
        "_id": id,
        "ReportedBy": reportedBy,
        "clip": clip,
        "reason": reason,
        "date": date?.toIso8601String(),
        "__v": v,
      };
}
