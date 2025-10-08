// To parse this JSON data, do
//
//     final paymentMethodresponse = paymentMethodresponseFromJson(jsonString);

import 'dart:convert';

PaymentMethodresponse paymentMethodresponseFromJson(String str) => PaymentMethodresponse.fromJson(json.decode(str));

String paymentMethodresponseToJson(PaymentMethodresponse data) => json.encode(data.toJson());

class PaymentMethodresponse {
  bool success;
  String message;
  SavedPaymentMethod savedPaymentMethod;

  PaymentMethodresponse({
    required this.success,
    required this.message,
    required this.savedPaymentMethod,
  });

  PaymentMethodresponse copyWith({
    bool? success,
    String? message,
    SavedPaymentMethod? savedPaymentMethod,
  }) =>
      PaymentMethodresponse(
        success: success ?? this.success,
        message: message ?? this.message,
        savedPaymentMethod: savedPaymentMethod ?? this.savedPaymentMethod,
      );

  factory PaymentMethodresponse.fromJson(Map<String, dynamic> json) => PaymentMethodresponse(
        success: json["success"],
        message: json["message"],
        savedPaymentMethod: SavedPaymentMethod.fromJson(json["savedPaymentMethod"]),
      );

  Map<String, dynamic> toJson() => {
        "success": success,
        "message": message,
        "savedPaymentMethod": savedPaymentMethod.toJson(),
      };
}

class SavedPaymentMethod {
  String id;
  String userId;
  String name;
  String addressLine1;
  String city;
  String postalCode;
  String countryCode;
  String iban;
  String recipient;
  DateTime date;
  int v;

  SavedPaymentMethod({
    required this.id,
    required this.userId,
    required this.name,
    required this.addressLine1,
    required this.city,
    required this.postalCode,
    required this.countryCode,
    required this.iban,
    required this.recipient,
    required this.date,
    required this.v,
  });

  SavedPaymentMethod copyWith({
    String? id,
    String? userId,
    String? name,
    String? addressLine1,
    String? city,
    String? postalCode,
    String? countryCode,
    String? iban,
    String? recipient,
    DateTime? date,
    int? v,
  }) =>
      SavedPaymentMethod(
        id: id ?? this.id,
        userId: userId ?? this.userId,
        name: name ?? this.name,
        addressLine1: addressLine1 ?? this.addressLine1,
        city: city ?? this.city,
        postalCode: postalCode ?? this.postalCode,
        countryCode: countryCode ?? this.countryCode,
        iban: iban ?? this.iban,
        recipient: recipient ?? this.recipient,
        date: date ?? this.date,
        v: v ?? this.v,
      );

  factory SavedPaymentMethod.fromJson(Map<String, dynamic> json) => SavedPaymentMethod(
        id: json["_id"],
        userId: json["userId"],
        name: json["name"],
        addressLine1: json["address_line1"],
        city: json["city"],
        postalCode: json["postal_code"],
        countryCode: json["countryCode"],
        iban: json["IBAN"],
        recipient: json["recipient"],
        date: DateTime.parse(json["date"]),
        v: json["__v"],
      );

  Map<String, dynamic> toJson() => {
        "_id": id,
        "userId": userId,
        "name": name,
        "address_line1": addressLine1,
        "city": city,
        "postal_code": postalCode,
        "countryCode": countryCode,
        "IBAN": iban,
        "recipient": recipient,
        "date": date.toIso8601String(),
        "__v": v,
      };
}
