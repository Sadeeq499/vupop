import 'dart:convert';

import 'package:socials_app/utils/app_images.dart';

EditorsModel editorsModelFromJson(String str) => EditorsModel.fromJson(json.decode(str));

String editorsModelToJson(EditorsModel data) => json.encode(data.toJson());

class EditorsModel {
  bool? success;
  EditorsDataModel? data;

  EditorsModel({
    this.success,
    this.data,
  });

  factory EditorsModel.fromJson(Map<String, dynamic> json) => EditorsModel(
        success: json["success"],
        data: json["data"] == null ? null : EditorsDataModel.fromJson(json["data"]),
      );

  Map<String, dynamic> toJson() => {
        "success": success,
        "data": data?.toJson(),
      };
}

class EditorsDataModel {
  String? message;
  List<Editor>? editors;

  EditorsDataModel({
    this.message,
    this.editors,
  });

  factory EditorsDataModel.fromJson(Map<String, dynamic> json) => EditorsDataModel(
        message: json["message"],
        editors: json["editors"] == null ? [] : List<Editor>.from(json["editors"]!.map((x) => Editor.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "message": message,
        "editors": editors == null ? [] : List<dynamic>.from(editors!.map((x) => x.toJson())),
      };

  factory EditorsDataModel.fromJsonBroadcaster(Map<String, dynamic> json) => EditorsDataModel(
        message: json["message"],
        editors: json["manager"] == null ? [] : List<Editor>.from(json["manager"]!.map((x) => Editor.fromJson(x))),
      );

  Map<String, dynamic> toJsonBroadcaster() => {
        "message": message,
        "manager": editors == null ? [] : List<dynamic>.from(editors!.map((x) => x.toJson())),
      };

  @override
  String toString() {
    return 'EditorsDataModel{message: $message, editors: $editors}';
  }
}

class Editor {
  String? id;
  String? email;
  String? name;
  String? image;
  DateTime? expiryDate;
  DateTime? issueDate;
  int? v;

  Editor({
    this.id,
    this.email,
    this.name,
    this.expiryDate,
    this.issueDate,
    this.image,
    this.v,
  });

  factory Editor.fromJson(Map<String, dynamic> json) => Editor(
        id: json["_id"],
        email: json["email"],
        name: json["name"],
        image: json["image"] ?? kdummyPerson,
        expiryDate: json["expiryDate"] == null ? null : DateTime.parse(json["expiryDate"]),
        issueDate: json["issueDate"] == null ? null : DateTime.parse(json["issueDate"]),
        v: json["__v"],
      );

  Map<String, dynamic> toJson() => {
        "_id": id,
        "email": email,
        "name": name,
        "expiryDate": expiryDate?.toIso8601String(),
        "issueDate": issueDate?.toIso8601String(),
        "__v": v,
      };

  @override
  String toString() {
    return 'Editor{id: $id, email: $email, name: $name, expiryDate: $expiryDate, issueDate: $issueDate, v: $v}';
  }
}
