import 'dart:convert';

WalletBalanceModel walletBalanceModelFromJson(String str) => WalletBalanceModel.fromJson(json.decode(str));

String walletBalanceModelToJson(WalletBalanceModel data) => json.encode(data.toJson());

class WalletBalanceModel {
  bool? success;
  String? message;
  List<Payment>? payment;
  double? pendingAmount;
  double? successAmount;
  double? readyToWithdrawAmount;

  WalletBalanceModel({
    this.success,
    this.message,
    this.payment,
    this.pendingAmount,
    this.successAmount,
    this.readyToWithdrawAmount,
  });

  WalletBalanceModel copyWith({
    bool? success,
    String? message,
    List<Payment>? payment,
    double? pendingAmount,
    double? successAmount,
    double? readyToWithdrawAmount,
  }) =>
      WalletBalanceModel(
        success: success ?? this.success,
        message: message ?? this.message,
        payment: payment ?? this.payment,
        pendingAmount: pendingAmount ?? this.pendingAmount,
        successAmount: successAmount ?? this.successAmount,
        readyToWithdrawAmount: readyToWithdrawAmount ?? this.readyToWithdrawAmount,
      );

  factory WalletBalanceModel.fromJson(Map<String, dynamic> json) => WalletBalanceModel(
        success: json["success"],
        message: json["message"],
        payment: json["payment"] == null ? [] : List<Payment>.from(json["payment"]!.map((x) => Payment.fromJson(x))),
        pendingAmount: json["pendingAmount"]?.toDouble(),
        successAmount: json["successAmount"]?.toDouble(),
        readyToWithdrawAmount: json["readyToWithdrawAmount"]?.toDouble(),
      );

  Map<String, dynamic> toJson() => {
        "success": success,
        "message": message,
        "payment": payment == null ? [] : List<dynamic>.from(payment!.map((x) => x.toJson())),
        "pendingAmount": pendingAmount,
        "successAmount": successAmount,
        "readyToWithdrawAmount": readyToWithdrawAmount,
      };
}

class Payment {
  String? message;
  double? amount;

  Payment({
    this.message,
    this.amount,
  });

  Payment copyWith({
    String? message,
    double? amount,
  }) =>
      Payment(
        message: message ?? this.message,
        amount: amount ?? this.amount,
      );

  factory Payment.fromJson(Map<String, dynamic> json) => Payment(
        message: json["message"],
        amount: json["amount"]?.toDouble(),
      );

  Map<String, dynamic> toJson() => {
        "message": message,
        "amount": amount,
      };
}
