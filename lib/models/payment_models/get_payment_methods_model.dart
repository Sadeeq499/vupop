import 'dart:convert';

GetPaymentMethodModel getPaymentMethodModelFromJson(String str) => GetPaymentMethodModel.fromJson(json.decode(str));

String getPaymentMethodModelToJson(GetPaymentMethodModel data) => json.encode(data.toJson());

class GetPaymentMethodModel {
  bool? success;
  PaymentMethodData? data;

  GetPaymentMethodModel({
    this.success,
    this.data,
  });

  GetPaymentMethodModel copyWith({
    bool? success,
    PaymentMethodData? data,
  }) =>
      GetPaymentMethodModel(
        success: success ?? this.success,
        data: data ?? this.data,
      );

  factory GetPaymentMethodModel.fromJson(Map<String, dynamic> json) => GetPaymentMethodModel(
        success: json["success"],
        data: json["data"] == null ? null : PaymentMethodData.fromJson(json["data"]),
      );

  Map<String, dynamic> toJson() => {
        "success": success,
        "data": data?.toJson(),
      };
}

class PaymentMethodData {
  String? message;
  String? addressLine1;
  String? city;
  String? postalCode;
  String? countryCode;
  String? iban;
  String? userName;

  PaymentMethodData({
    this.message,
    this.addressLine1,
    this.city,
    this.postalCode,
    this.countryCode,
    this.iban,
    this.userName,
  });

  PaymentMethodData copyWith({
    String? message,
    String? addressLine1,
    String? city,
    String? postalCode,
    String? countryCode,
    String? iban,
    String? userName,
  }) =>
      PaymentMethodData(
        message: message ?? this.message,
        addressLine1: addressLine1 ?? this.addressLine1,
        city: city ?? this.city,
        postalCode: postalCode ?? this.postalCode,
        countryCode: countryCode ?? this.countryCode,
        iban: iban ?? this.iban,
        userName: userName ?? this.userName,
      );

  factory PaymentMethodData.fromJson(Map<String, dynamic> json) => PaymentMethodData(
        message: json["message"],
        addressLine1: json["address_line1"],
        city: json["city"],
        postalCode: json["postal_code"],
        countryCode: json["countryCode"],
        iban: json["IBAN"],
        userName: json["userName"],
      );

  Map<String, dynamic> toJson() => {
        "message": message,
        "address_line1": addressLine1,
        "city": city,
        "postal_code": postalCode,
        "countryCode": countryCode,
        "IBAN": iban,
        "userName": userName,
      };
}
