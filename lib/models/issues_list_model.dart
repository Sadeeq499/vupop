import 'dart:convert';

IssuesListModel issuesListModelFromJson(String str) => IssuesListModel.fromJson(json.decode(str));

String issuesListModelToJson(IssuesListModel data) => json.encode(data.toJson());

class IssuesListModel {
  bool success;
  String message;
  List<IssuesListDataModel> data;

  IssuesListModel({
    required this.success,
    required this.message,
    required this.data,
  });

  factory IssuesListModel.fromJson(Map<String, dynamic> json) => IssuesListModel(
        success: json["success"],
        message: json["message"],
        data: List<IssuesListDataModel>.from(json["data"].map((x) => IssuesListDataModel.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "success": success,
        "message": message,
        "data": List<dynamic>.from(data.map((x) => x.toJson())),
      };
}

class IssuesListDataModel {
  String id;
  String reason;
  int v;

  IssuesListDataModel({
    required this.id,
    required this.reason,
    required this.v,
  });

  factory IssuesListDataModel.fromJson(Map<String, dynamic> json) => IssuesListDataModel(
        id: json["_id"] ?? '',
        reason: json["reason"] ?? '',
        v: json["__v"] ?? '',
      );

  Map<String, dynamic> toJson() => {
        "_id": id,
        "reason": reason,
        "__v": v,
      };
}
