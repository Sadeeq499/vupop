import 'dart:convert';

SupportModel supportModelFromJson(String str) =>
    SupportModel.fromJson(json.decode(str));

class SupportModel {
  final String message;
  final SupportData data;

  SupportModel({
    required this.message,
    required this.data,
  });

  factory SupportModel.fromJson(Map<String, dynamic> json) {
    return SupportModel(
      message: json['message'],
      data: SupportData.fromJson(json['data']),
    );
  }
}

class SupportData {
  final String id;
  final String userId;
  final String email;
  final String name;
  final String message;
  final int v;

  SupportData({
    required this.id,
    required this.userId,
    required this.email,
    required this.name,
    required this.message,
    required this.v,
  });

  factory SupportData.fromJson(Map<String, dynamic> json) {
    return SupportData(
      id: json['_id'],
      userId: json['userId'],
      email: json['email'],
      name: json['name'],
      message: json['message'],
      v: json['__v'],
    );
  }
}
