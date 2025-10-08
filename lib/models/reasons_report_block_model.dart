import 'dart:convert';

ReasonsBlockReportModel reasonsBlockReportModelFromJson(String str) => ReasonsBlockReportModel.fromJson(json.decode(str));

String reasonsBlockReportModelToJson(ReasonsBlockReportModel data) => json.encode(data.toJson());

class ReasonsBlockReportModel {
  bool? success;
  List<ReasonModel>? reasons;

  ReasonsBlockReportModel({
    this.success,
    this.reasons,
  });

  ReasonsBlockReportModel copyWith({
    bool? success,
    List<ReasonModel>? reasons,
  }) =>
      ReasonsBlockReportModel(
        success: success ?? this.success,
        reasons: reasons ?? this.reasons,
      );

  factory ReasonsBlockReportModel.fromJson(Map<String, dynamic> json) => ReasonsBlockReportModel(
        success: json["success"] ?? false,
        reasons: json["reasons"] == null ? [] : List<ReasonModel>.from(json["reasons"].map((x) => ReasonModel.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "success": success,
        "reasons": List<dynamic>.from(reasons!.map((x) => x.toJson())),
      };
}

class ReasonModel {
  String? id;
  String? reason;

  ReasonModel({
    this.id,
    this.reason,
  });

  factory ReasonModel.fromJson(Map<String, dynamic> json) => ReasonModel(
        id: json["id"],
        reason: json["reason"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "reason": reason,
      };

  ReasonModel copyWith({
    String? id,
    String? reason,
  }) =>
      ReasonModel(
        id: id ?? this.id,
        reason: reason ?? this.reason,
      );

  @override
  String toString() {
    return 'ReasonModel{id: $id, reason: $reason}';
  }
}
