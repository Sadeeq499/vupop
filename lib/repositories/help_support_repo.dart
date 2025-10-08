import 'dart:convert';
import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:socials_app/models/support_model.dart';
import 'package:socials_app/services/endpoints.dart';

import '../services/http_client.dart';
import '../utils/common_code.dart';

class HelpSupportRepo {
  late HTTPClient _httpClient;
  static final _instance = HelpSupportRepo._constructor();
  factory HelpSupportRepo() {
    return _instance;
  }
  HelpSupportRepo._constructor() {
    _httpClient = HTTPClient();
  }

  Future<SupportData?> sendHelpSupport({required String email, required String message, required String name, required String userId}) async {
    Map<String, dynamic> data = {
      "userId": userId,
      "email": email,
      "name": name,
      "message": message,
    };
    String jsonData = jsonEncode(data);
    final response = await _httpClient.postRequestWithHeader(url: kSupportURL, body: jsonData);
    if (response.statusCode == 200) {
      try {
        Map<String, dynamic> jsonData = jsonDecode(response.data);

        return supportModelFromJson(jsonEncode(jsonData)).data;
      } catch (e) {
        if (kDebugMode) {
          log('Error sendHelpSupport: $e');
        }
      }
    } else {
      if (kDebugMode) {
        printLogs('Response sendHelpSupport: ${response.statusCode}');
      }
    }
    return null;
  }
}
