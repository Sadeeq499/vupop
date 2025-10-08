// ignore_for_file: public_member_api_docs, sort_constructors_first
/*@Author Sadaf Khowaja
  */

import 'dart:convert';

class ResponseModel {
  int statusCode = -1;
  String statusDescription = "";
  dynamic data;

  ResponseModel();

  ResponseModel.named({required this.statusCode, required this.statusDescription, this.data});

  ResponseModel.fromJson(Map<String, dynamic> json) {
    this.statusCode = json["success"] ?? -1;
    this.statusDescription = json["message"] ?? "";

    data = json;
  }

  ResponseModel.fromJsonString(String json) {
    data = json;
  }

  Map<String, dynamic> toJson() {
    return {
      'statusCode': this.statusCode,
      'statusDescription': this.statusDescription,
      'data': this.data,
    };
  }

  @override
  String toString() {
    return 'ResponseModel{statusCode: $statusCode, statusDescription: $statusDescription, data: $data}';
  }
}

SuccessResponse successResponseFromJson(String str) => SuccessResponse.fromJson(json.decode(str));

class SuccessResponse {
  bool success;
  String message;

  SuccessResponse({
    required this.success,
    required this.message,
  });

  factory SuccessResponse.fromJson(Map<String, dynamic> json) {
    return SuccessResponse(
      success: json['success'],
      message: json['data']['message'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'data': {
        'message': message,
      },
    };
  }
}

SuccessResponseWithoutData successResponseWithoutDataFromJson(String str) => SuccessResponseWithoutData.fromJson(json.decode(str));

class SuccessResponseWithoutData {
  bool success;
  String message;

  SuccessResponseWithoutData({
    required this.success,
    required this.message,
  });

  factory SuccessResponseWithoutData.fromJson(Map<String, dynamic> json) {
    return SuccessResponseWithoutData(
      success: json['success'],
      message: json['message'] ?? json["data"]["message"],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'data': {
        'message': message,
      },
    };
  }
}
