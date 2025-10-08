import 'dart:convert';

import 'package:socials_app/models/payment_models/request_payment_model.dart';
import 'package:socials_app/services/endpoints.dart';
import 'package:socials_app/services/http_client.dart';

import '../models/payment_models/wallet_balance_model.dart';
import '../models/response_model.dart';
import '../services/session_services.dart';
import '../utils/common_code.dart';

class WalletRepo {
  late HTTPClient _httpClient;
  static final _instance = WalletRepo._internal();

  factory WalletRepo() {
    return _instance;
  }

  WalletRepo._internal() {
    _httpClient = HTTPClient();
  }

  ///fn to get current balance and amount available for withdrawal
  Future<WalletBalanceModel?> getWalletBalance() async {
    // const userId = '66f43359afe0c2b995a4b93f';
    final userId = SessionService().user?.id ?? '';
    try {
      final response = await _httpClient.getRequestWithHeader(url: "$kGetWalletBalanceURL/$userId");

      if (response.statusCode == 200) {
        Map<String, dynamic> data = jsonDecode(response.data);
        printLogs('Wallet data: $data');
        final con = walletBalanceModelFromJson(response.data);
        printLogs('Wallet data: $con');
        return con;
      } else {
        // return response;
        return null;
      }
    } catch (e) {
      printLogs('Wallet data: $e');
    }
    return null;
  }

  ///fn to get payment details for request
  Future<RequestPaymentData?> geRequestPayment() async {
    // final userId = '66f43359afe0c2b995a4b93f';
    final userId = SessionService().user?.id ?? '';
    try {
      final response = await _httpClient.getRequestWithHeader(url: "$kRequestPaymentURL/$userId");
      if (response.statusCode == 200) {
        Map<String, dynamic> data = jsonDecode(response.data);
        printLogs('Wallet data: $data');
        final con = requestPaymentModelFromJson(response.data);
        printLogs('Wallet data: $con');
        return con.data;
      } else {
        // return response;
        return null;
      }
    } catch (e) {
      printLogs('Wallet data: $e');
    }
    return null;
  }

  /// fn to request payment to admin
  Future<bool> requestPaymentToAdmin() async {
    // final userId = '66f43359afe0c2b995a4b93f';
    final userId = SessionService().user?.id ?? '';
    final response = await _httpClient.putRequestWithHeader(url: '$kRequestPaymentToAdminURL/$userId', body: jsonEncode({}));

    /*ResponseModel response =
        ResponseModel.named(statusCode: 200, statusDescription: "Success", data: {"success": true, "message": "Request sent successfully"});*/
    /*ResponseModel response = ResponseModel.named(statusCode: 200, statusDescription: "Success", data: {
      "success": true,
      "message": "Request sent successfully",
      "data": {"amount": 2535.1326}
    });*/
    ResponseModel responseMock =
        ResponseModel.named(statusCode: 200, statusDescription: "Success", data: {"success": true, "message": "Request sent successfully"});

    /*ResponseModel response = ResponseModel();
    response.statusCode = 200;
    response.statusDescription = "Success";
    response.data = {"success": true, "message": "Request sent successfully"};*/

    // ResponseModel{statusCode: 200, statusDescription: Success, data: {"success":true,"message":"Request sent successfully","data":{"amount":845.0442}}}
    printLogs('Response requestPaymentToAdmin: $response');
    printLogs('Response.statuscode: ${response.statusCode}');
    printLogs('Response.data: ${response.data}');
    if (response.statusCode == 200) {
      try {
        // Map<String, dynamic> data = jsonDecode(jsonEncode(response.data)) ;
        Map<String, dynamic> data = jsonDecode(response.data);
        // Map<String, dynamic> data = getDataMap(response.data);
        if (data["success"] == true) {
          return true;
        } else {
          return false;
        }
      } catch (e) {
        printLogs('Error on requestPaymentToAdmin : $e');
        // return null;
        return false;
      }
    } else {
      printLogs('Response requestPaymentToAdmin: ${response.statusCode}');
    }
    return false;
  }

  Map<String, dynamic> getDataMap(dynamic response) {
    // If response.data is already a string (likely a JSON string)
    if (response.data is String) {
      try {
        return jsonDecode(response['data']);
      } catch (e) {
        print("Error decoding string: $e");
        return {};
      }
    }
    // If response.data is already a Map
    else if (response.data is Map) {
      return Map<String, dynamic>.from(response.data);
    }
    // Otherwise, try the encode-decode approach for other objects
    else {
      try {
        return jsonDecode(jsonEncode(response.data));
      } catch (e) {
        print("Error with encode-decode: $e");
        return {};
      }
    }
  }
}
