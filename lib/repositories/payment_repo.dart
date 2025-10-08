import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:socials_app/services/http_client.dart';

import '../models/payment_method_model.dart';
import '../models/payment_models/get_payment_methods_model.dart';
import '../models/response_model.dart';
import '../services/custom_snackbar.dart';
import '../services/endpoints.dart';
import '../utils/common_code.dart';

class PaymentRepo {
  late HTTPClient _httpClient;
  static final _instance = PaymentRepo._constructor();
  factory PaymentRepo() {
    return _instance;
  }
  PaymentRepo._constructor() {
    _httpClient = HTTPClient();
  }

  /// fn for adding payment method
  Future<bool> addPaymentMethod({
    required String userId,
    // required String familyName,
    required String address,
    required String city,
    required String postalCode,
    required String countryCode,
    // required String sortCode,
    required String accName,
    required String iban,
    // required String bacsCode,
  }) async {
    Map<String, String> fields = {
      'userId': userId,
      'name': accName,
      "address_line1": address,
      "city": city,
      "postal_code": postalCode,
      "countryCode": countryCode,
      'IBAN': iban,
    };
    final body = jsonEncode(fields);
    final response = await _httpClient.postRequestWithHeader(
      url: kAddPaymentMethodURL,
      body: body,
    );

    //For mock response
    // ResponseModel response = ResponseModel();
    //
    // /* Response addPaymentMethod: ResponseModel{statusCode: 200, statusDescription: Success, data: {"success":true,"message":"paymet method created successfully","savedPaymentMethod":{"_id":"6792ac94834814001384cef2","userId":"675f1eba7e06130012309206","recipient":"700673715","date":"2025-01-23T20:54:44.627Z","__v":0}}}*/
    // response.statusCode = 200;
    // response.statusDescription = "Success";
    // response.data = {
    //   "success": true,
    //   "message": "paymet method created successfully",
    //   "savedPaymentMethod": {
    //     "_id": "67373d8578fa1df47b05f0a2",
    //     "userId": "66f43359afe0c2b995a4b93f",
    //     "name": "sadaf sadaf",
    //     "address_line1": "27 Street London ",
    //     "city": "London ",
    //     "postal_code": "DH5675",
    //     "countryCode": "GB",
    //     "IBAN": "*****33",
    //     "recipient": "700443160",
    //     "date": "2024-11-15T12:24:37.689Z",
    //     "__v": 0
    //   }
    // };
    ResponseModel responseMock = ResponseModel();
    // ResponseModel{statusCode: 200, statusDescription: Success, data: {"success":true,"message":"paymet method created successfully","savedPaymentMethod":{"_id":"67d877dec29b6b0012d66db2","userId":"66f43359afe0c2b995a4b93f","recipient":"700673715","date":"2025-03-17T19:28:30.881Z","__v":0}}}
    responseMock.statusCode = 200;
    responseMock.statusDescription = "Success";
    responseMock.data = {
      "success": true,
      "message": "paymet method created successfully",
      "savedPaymentMethod": {
        "_id": "67d877dec29b6b0012d66db2",
        "userId": "66f43359afe0c2b995a4b93f",
        "recipient": "700673715",
        "date": "2025-03-17T19:28:30.881Z",
        "__v": 0
      }
    };

    bool isSuccess = false;
    printLogs('Response addPaymentMethod: $response');
    printLogs('Response.statuscode: ${response.statusCode}');
    printLogs('Response.data: ${response.data}');
    if (response.statusCode == 200) {
      try {
        // return paymentMethodresponseFromJson(jsonEncode(response.data)).savedPaymentMethod;

        PaymentMethodresponse paymentMethodresponse = paymentMethodresponseFromJson(jsonEncode(response.data));
        isSuccess = paymentMethodresponse.success;
      } catch (e) {
        try {
          if (response.statusCode == 200) {
            isSuccess = jsonDecode(response.data)["success"] == true;
            // isSuccess = true;
          }
        } catch (e) {
          printLogs('addPaymentMethod Exception : $e');
        }
        printLogs('Error addPaymentMethod paymentRepo: $e');
      }

      return isSuccess;
    } else {
      printLogs('Response addPaymentMethod paymentRepo: ${response.statusCode}');
    }
    return false;
  }

  /// fn for getting added payment method of user
  Future<PaymentMethodData?> getUserPaymentMethod({
    required String userId,
    bool showSnackbar = true,
  }) async {
    // Map<String, String> body = {"email": email};
    Map<String, String> body = {};
    final response = await _httpClient.getRequestWithHeader(
      url: "$kGetPaymentMethodURL?userId=$userId",
    );
    if (response.statusCode == 200) {
      try {
        Map<String, dynamic> jsonData = jsonDecode(response.data);
        printLogs('userprofile: ${jsonData}');
        final data = getPaymentMethodModelFromJson(jsonEncode(jsonData));
        return data.data;
        // return UserDetailModel.fromJson(data);
      } catch (e) {
        printLogs("error from repo getUserPaymentMethod ${e.toString()}");
      }
    } else {
      printLogs('unable to get user getUserPaymentMethod');
      showSnackbar? CustomSnackbar.showSnackbar("No Payment Methods Added") : SizedBox.shrink();
      return null;
    }
    return null;
  }
}
