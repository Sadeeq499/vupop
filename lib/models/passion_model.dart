// To parse this JSON data, do
//
//     final passionResponse = passionResponseFromJson(jsonString);

import 'dart:convert';

PassionResponse passionResponseFromJson(String str) => PassionResponse.fromJson(json.decode(str));

String passionResponseToJson(PassionResponse data) => json.encode(data.toJson());

class PassionResponse {
  Data? data;

  PassionResponse({
    this.data,
  });

  PassionResponse copyWith({
    Data? data,
  }) =>
      PassionResponse(
        data: data ?? this.data,
      );

  factory PassionResponse.fromJson(Map<String, dynamic> json) => PassionResponse(
        data: json["data"] == null ? null : Data.fromJson(json["data"]),
      );

  Map<String, dynamic> toJson() => {
        "data": data?.toJson(),
      };
}

class Data {
  List<Passion>? passions;

  Data({
    this.passions,
  });

  Data copyWith({
    List<Passion>? passions,
  }) =>
      Data(
        passions: passions ?? this.passions,
      );

  factory Data.fromJson(Map<String, dynamic> json) => Data(
        passions: json["reasons"] == null ? [] : List<Passion>.from(json["reasons"]!.map((x) => Passion.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "reasons": passions == null ? [] : List<dynamic>.from(passions!.map((x) => x.toJson())),
      };
}

class Passion {
  String? id;
  String? title;
  int? v;

  Passion({
    this.id,
    this.title,
    this.v,
  });

  Passion copyWith({
    String? id,
    String? title,
    int? v,
  }) =>
      Passion(
        id: id ?? this.id,
        title: title ?? this.title,
        v: v ?? this.v,
      );

  factory Passion.fromJson(Map<String, dynamic> json) => Passion(
        id: json["_id"],
        title: json["title"],
        v: json["__v"],
      );

  Map<String, dynamic> toJson() => {
        "_id": id,
        "title": title,
        "__v": v,
      };
}
