// ignore_for_file: prefer_is_empty, unnecessary_null_comparison, unnecessary_brace_in_string_interps

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart' as d;
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
// ignore: depend_on_referenced_packages
import 'package:http_parser/http_parser.dart';
import 'package:socials_app/services/session_services.dart';
import 'package:socials_app/services/sharedprefrence_service.dart';
import 'package:socials_app/views/screens/profile/screen/profile_screen.dart';

import '../models/response_model.dart';
import '../utils/common_code.dart';

class HTTPClient extends GetConnect {
  factory HTTPClient() {
    return _instance;
  }
  static const int _requestTimeOut = 120;
  static final HTTPClient _instance = HTTPClient._constructor();

  HTTPClient._constructor();
  String kUserToken = '';

  ///fn not in use
  Future<ResponseModel> postRequest({required String url, dynamic body}) async {
    try {
      Response response = await post(
        url,
        body,
      ).timeout(const Duration(seconds: _requestTimeOut));
      ResponseModel responseModel;

      if (response.body is List) {
        responseModel = ResponseModel.named(statusCode: 200, statusDescription: "Success");
        responseModel.data = response.body;
      } else if (response.body is String) {
        responseModel = ResponseModel.named(statusCode: 200, statusDescription: "Success");
        responseModel.data = (response.bodyString!);
      } else {
        responseModel = ResponseModel.named(statusCode: 200, statusDescription: "Success");
        responseModel.data = ((response.body));
      }
      return responseModel;
    } on TimeoutException catch (_) {
      return Future.value(ResponseModel.named(statusCode: 408, statusDescription: "Request TimeOut", data: ""));
    } on SocketException catch (_) {
      return Future.value(ResponseModel.named(statusCode: 400, statusDescription: "Bad Request", data: ""));
    } catch (e) {
      return Future.value(ResponseModel.named(statusCode: 500, statusDescription: "Server Error", data: "Server Error"));
    }
  }

  ///fn not in use
  Future<ResponseModel> postMultipartRequest({required String url, Map<String, String> fields = const {}}) async {
    try {
      http.MultipartRequest request = http.MultipartRequest('POST', Uri.parse(url));
      request.fields.addAll(fields);

      http.StreamedResponse streamedResponse = await request.send();
      http.Response httpResponse = await http.Response.fromStream(streamedResponse);
      ResponseModel response = ResponseModel.fromJson(jsonDecode(httpResponse.body));
      return Future.value(response);
    } on TimeoutException catch (e) {
      if (kDebugMode) {
        printLogs('SocketException $e');
      }
      return Future.value(ResponseModel.named(statusCode: 408, statusDescription: "Request TimeOut", data: "Request TimeOut"));
    } on SocketException catch (e) {
      if (kDebugMode) {
        printLogs('SocketException $e');
      }
      return Future.value(ResponseModel.named(statusCode: 400, statusDescription: "Bad Request", data: "Bad Request"));
    } catch (e) {
      return Future.value(ResponseModel.named(statusCode: 500, statusDescription: "Server Error", data: "Server Error"));
    }
  }

  Future<ResponseModel> getRequest({required String url}) async {
    String methodName = "getRequest";
    try {
      final token = SessionService().userToken;
      Map<String, String> headers = {'Content-Type': 'application/json', 'token': token ?? ""};
      Response response = await get(url, headers: headers).timeout(const Duration(seconds: _requestTimeOut));
      ResponseModel responseModel = ResponseModel.fromJson((response.body));
      printLogs('=================url $url');
      printLogs('=================headers $headers');
      printLogs('=================response ${response.body}');

      printToFirebase('$methodName url $url');
      printToFirebase('$methodName statusCode ${response.statusCode}');
      printToFirebase('$methodName response ${response.body}');
      // debugPrint(responseModel.toString());
      return Future.value(ResponseModel.named(statusCode: 200, statusDescription: "Success", data: responseModel.data));
    } on TimeoutException catch (e) {
      if (kDebugMode) {
        printLogs('$methodName TimeOutException url $url');
        printLogs('$methodName TimeOutException $e');
      }
      printToFirebase('$methodName TimeOutException url $url');
      printToFirebase('$methodName TimeOutException $e');
      return Future.value(ResponseModel.named(statusCode: 408, statusDescription: "Request TimeOut", data: "Request TimeOut"));
    } on SocketException catch (e) {
      if (kDebugMode) {
        printLogs('$methodName SocketException url $url');
        printLogs('$methodName SocketException ${e.toString()}');
      }
      printToFirebase('$methodName SocketException url $url');
      printToFirebase('$methodName SocketException ${e.toString()}');
      return Future.value(ResponseModel.named(statusCode: 400, statusDescription: "Bad Request", data: "Bad Request"));
    } catch (e) {
      if (kDebugMode) {
        printLogs("Exception Http Error ${e.toString()}");
      }
      printToFirebase('$methodName SocketException url $url');
      printToFirebase("$methodName Http Error ${e.toString()}");
      return Future.value(ResponseModel.named(statusCode: 500, statusDescription: "Server Error", data: "Server Error"));
    }
  }

  ///fn not in use
  Future<ResponseModel> getRequestWithOutHeader({required String url}) async {
    try {
      http.Response response = await http.get(Uri.parse(url)).timeout(const Duration(seconds: _requestTimeOut));
      ResponseModel responseModel = ResponseModel();
      if (response != null && response.body != null && response.body.length > 4) {
        responseModel.statusCode = response.statusCode;
        responseModel.statusDescription = "Success";
        responseModel.data = response.body;
      }

      return responseModel;
    } on TimeoutException catch (e) {
      if (kDebugMode) {
        printLogs("getRequestWithOutHeader TimeoutException URL $url");
        printLogs("TimeoutException $e");
      }
      return Future.value(ResponseModel.named(statusCode: 408, statusDescription: "Request TimeOut", data: ""));
    } on SocketException catch (e) {
      if (kDebugMode) {
        printLogs("getRequestWithOutHeader SocketException URL $url");
        printLogs('SocketException $e');
      }
      return Future.value(ResponseModel.named(statusCode: 400, statusDescription: "Bad Request", data: ""));
    } catch (_) {
      return Future.value(ResponseModel.named(statusCode: 500, statusDescription: "Server Error", data: ""));
    }
  }

  Future<ResponseModel> postMultipartRequestFile({
    required String url,
    dynamic body,
    bool isFile = false,
    bool isListOfFiles = false,
    List<String> filePathsList = const [],
    String? filePath,
    String? filed,
    MediaType? mediaType,
    String? thumbnail,
    void Function(int sentBytes, int totalBytes)? onProgress,
  }) async {
    String methodName = "postMultipartRequestFile";
    try {
      if (kDebugMode) {
        printLogs('url : $url');
        printLogs('body : $body');
      }

      printToFirebase('$methodName url $url');
      printToFirebase('$methodName request params ${body}');
      final token = SessionService().userToken;
      /*Map<String, String> headers = {
        // 'Authorization': 'Bearer $token',
        // 'Authorization': '$token',
        'Cookie': 'connect.sid=s%3A7JM8KY564sG_iYhyTndjWeGSX8LxGC3O.Pfs19mTE2%2FXSZ1ReaQ2kFQdklqo2yGkXzg3cKThH6TI',
      };*/
      var headers = {'Content-Type': 'application/json', 'token': token ?? ""};

      http.MultipartRequest request = http.MultipartRequest('POST', Uri.parse(url));
      if (isFile) {
        if (kDebugMode) {
          printLogs('filePath $filePath');
        }
        request.files.add(await http.MultipartFile.fromPath(
          filed!, filePath!,
          // contentType: mediaType
        ));
        if (thumbnail != null) {
          request.files.add(await http.MultipartFile.fromPath(
            'thumbnail',
            thumbnail,
            // contentType: mediaType
          ));
        }
      } else if (isListOfFiles) {
        for (String file in filePathsList) {
          if (kDebugMode) {
            printLogs('filePath:::::::====> $file');
          }
          request.files.add(await http.MultipartFile.fromPath(
            filed!, file,
            // contentType: mediaType
          ));
        }
      }

      request.fields.addAll(body);
      request.headers.addAll(headers);
      http.StreamedResponse streamedResponse = await request.send();
      http.Response httpResponse = await http.Response.fromStream(streamedResponse);
      if (kDebugMode) {
        printLogs('response ${httpResponse.body}');
      }

      printToFirebase('$methodName statusCode ${httpResponse.statusCode}');
      printToFirebase('$methodName response ${httpResponse.body}');
      ResponseModel responseModel = ResponseModel();
      if (httpResponse != null && httpResponse.body != null && httpResponse.body.length > 4) {
        responseModel.statusCode = httpResponse.statusCode;
        responseModel.statusDescription = "Success";
        responseModel.data = httpResponse.body;
      }
      return responseModel;
    } on TimeoutException catch (e) {
      if (kDebugMode) {
        printLogs('$methodName TimeOutException url $url');
        printLogs('$methodName TimeOutException $e');
      }
      printToFirebase('$methodName TimeOutException url $url');
      printToFirebase('$methodName TimeOutException $e');
      return Future.value(ResponseModel.named(statusCode: 408, statusDescription: "Request TimeOut", data: "Request TimeOut"));
    } on SocketException catch (e) {
      if (kDebugMode) {
        printLogs('$methodName SocketException url $url');
        printLogs('$methodName SocketException ${e.toString()}');
      }
      printToFirebase('$methodName SocketException url $url');
      printToFirebase('$methodName SocketException ${e.toString()}');
      return Future.value(ResponseModel.named(statusCode: 400, statusDescription: "Bad Request", data: "Bad Request"));
    } catch (e) {
      if (kDebugMode) {
        printLogs("Exception Http Error ${e.toString()}");
      }
      printToFirebase('$methodName SocketException url $url');
      printToFirebase("$methodName Http Error ${e.toString()}");
      return Future.value(ResponseModel.named(statusCode: 500, statusDescription: "Server Error", data: "Server Error"));
    }
  }

  /// fn for getreuest with headers
  Future<ResponseModel> getRequestWithHeader({
    required String url,
  }) async {
    final token = SessionService().userToken;
    String methodName = "getRequestWithHeader for : $url";
    try {
      Map<String, String> headers = {'Content-Type': 'application/json', 'token': token ?? ""};

      // final bodyData = jsonEncode(body);
      // if (kDebugMode) {
      printLogs('$methodName url : $url');
      printLogs('$methodName headers : $headers');
      // printLogs('$methodName body : $body');
      // }

      printToFirebase('$methodName url : $url');
      // printToFirebase('$methodName request : $body');

      var request = http.Request('GET', Uri.parse(url));
      // if (body != null) request.body = bodyData;
      request.headers.addAll(headers);
      http.StreamedResponse response = await request.send().timeout(Duration(seconds: _requestTimeOut));
      http.Response httpResponse = await http.Response.fromStream(response);

      // Response httpResponse = await get(url, headers: headers).timeout(const Duration(seconds: _requestTimeOut));
      // if (kDebugMode) {
      printLogs('$methodName statusCode ${httpResponse.statusCode}');
      printLogs('$methodName response ${httpResponse.body}');
      // }

      printToFirebase('getRequestWithHeader status code ${httpResponse.statusCode}');
      printToFirebase('getRequestWithHeader response ${httpResponse.body}');
      ResponseModel responseModel = ResponseModel();
      if (httpResponse != null && httpResponse.body != null && httpResponse.body.length > 4) {
        responseModel.statusCode = response.statusCode;
        responseModel.statusDescription = "Success";
        responseModel.data = httpResponse.body;
      }

      return responseModel;
    } on TimeoutException catch (e) {
      if (kDebugMode) {
        printLogs('$methodName TimeOutException url $url');
        printLogs('$methodName TimeOutException $e');
      }
      printToFirebase('$methodName TimeOutException url $url');
      printToFirebase('$methodName TimeOutException $e');
      return Future.value(ResponseModel.named(statusCode: 408, statusDescription: "Request TimeOut", data: "Request TimeOut"));
    } on SocketException catch (e) {
      if (kDebugMode) {
        printLogs('$methodName SocketException url $url');
        printLogs('$methodName SocketException ${e.toString()}');
      }
      printToFirebase('$methodName SocketException url $url');
      printToFirebase('$methodName SocketException ${e.toString()}');
      return Future.value(ResponseModel.named(statusCode: 400, statusDescription: "Bad Request", data: "Bad Request"));
    } catch (e) {
      if (kDebugMode) {
        printLogs("$methodName Exception Http Error ${e.toString()}");
      }
      printToFirebase('$methodName SocketException url $url');
      printToFirebase("$methodName Http Error ${e.toString()}");
      return Future.value(ResponseModel.named(statusCode: 500, statusDescription: "Server Error", data: "Server Error"));
    }
  }

  // fn to post request with headers with patch
  Future<ResponseModel> postRequestWithHeader({required String url, dynamic body}) async {
    String methodName = "postRequestWithHeader";

    try {
      final token = SessionService().userToken;
      // if (kDebugMode) {
      printLogs('$methodName url : $url');
      printLogs('$methodName request : $body');
      // }

      printToFirebase('$methodName url : $url');
      printToFirebase('$methodName request : $body');

      Map<String, String> headers = {'Content-Type': 'application/json', 'token': token ?? ""};

      http.Response response = await http.post(Uri.parse(url), headers: headers, body: body).timeout(const Duration(seconds: _requestTimeOut));

      printToFirebase('$methodName statusCode ${response.statusCode}');
      printToFirebase('$methodName response ${response.body}');
      ResponseModel responseModel = ResponseModel();
      if (response != null && response.body != null && response.body.length > 4) {
        //
        responseModel.statusCode = response.statusCode;
        responseModel.statusDescription = "Success";
        responseModel.data = response.body;
        //
      }
      return responseModel;
    } on TimeoutException catch (e) {
      if (kDebugMode) {
        printLogs('$methodName TimeOutException url $url');
        printLogs('$methodName TimeOutException $e');
      }
      printToFirebase('$methodName TimeOutException url $url');
      printToFirebase('$methodName TimeOutException $e');
      return Future.value(ResponseModel.named(statusCode: 408, statusDescription: "Request TimeOut", data: "Request TimeOut"));
    } on SocketException catch (e) {
      if (kDebugMode) {
        printLogs('$methodName SocketException url $url');
        printLogs('$methodName SocketException ${e.toString()}');
      }
      printToFirebase('$methodName SocketException url $url');
      printToFirebase('$methodName SocketException ${e.toString()}');
      return Future.value(ResponseModel.named(statusCode: 400, statusDescription: "Bad Request", data: "Bad Request"));
    } catch (e) {
      if (kDebugMode) {
        printLogs("Exception Http Error ${e.toString()}");
      }
      printToFirebase('$methodName SocketException url $url');
      printToFirebase("$methodName Http Error ${e.toString()}");
      return Future.value(ResponseModel.named(statusCode: 500, statusDescription: "Server Error", data: "Server Error"));
    }
  }

  /// patch request with headers
  /// fn not in use
  Future<ResponseModel> patchRequestWithHeader({required String url, dynamic body}) async {
    try {
      final token = SessionService().userToken;
      Map<String, String> headers = {
        'Authorization': 'Bearer $token',
      };
      if (kDebugMode) {
        printLogs('url : $url');
        printLogs('body : $body');
      }
      http.Response response = await http.patch(Uri.parse(url), headers: headers, body: body).timeout(const Duration(seconds: _requestTimeOut));
      // Get.printLogs('response ${response.body}');
      ResponseModel responseModel = ResponseModel();
      if (response != null && response.body != null && response.body.length > 4) {
        responseModel.statusCode = response.statusCode;
        responseModel.statusDescription = "Success";
        responseModel.data = response.body;
      }
      return responseModel;
    } on TimeoutException catch (e) {
      if (kDebugMode) {
        printLogs('TimeOutException $e');
      }
      return Future.value(ResponseModel.named(statusCode: 408, statusDescription: "Request TimeOut", data: ""));
    } on SocketException catch (e) {
      return Future.value(ResponseModel.named(statusCode: 400, statusDescription: "Bad Request", data: ""));
    } catch (_) {
      return Future.value(ResponseModel.named(statusCode: 500, statusDescription: "Server Error", data: ""));
    }
  }

  /// fn to patch request MultiPart with headers
  /// fn not in use
  Future<ResponseModel> patchRequestMultiPartWithHeader({
    required String url,
    dynamic body,
    bool isFile = false,
    String? filePath,
    String? filed,
    MediaType? mediaType,
  }) async {
    try {
      final token = SessionService().userToken;
      Map<String, String> headers = {
        'Authorization': 'Bearer $token',
      };
      http.MultipartRequest request = http.MultipartRequest('PATCH', Uri.parse(url));
      request.headers.addAll(headers);
      if (kDebugMode) {
        printLogs('url : $url');
        printLogs('body : $body');
      }
      if (isFile) {
        if (kDebugMode) {
          printLogs('filePath $filePath');
        }
        request.files.add(await http.MultipartFile.fromPath(filed!, filePath!, contentType: mediaType));
      } else {
        request.fields.addAll(body);
      }
      http.StreamedResponse streamedResponse = await request.send();
      http.Response httpResponse = await http.Response.fromStream(streamedResponse);
      ResponseModel responseModel = ResponseModel();
      if (httpResponse != null && httpResponse.body != null && httpResponse.body.length > 4) {
        responseModel.statusCode = httpResponse.statusCode;
        responseModel.statusDescription = "Success";
        responseModel.data = httpResponse.body;
      }
      return responseModel;
    } on TimeoutException catch (e) {
      if (kDebugMode) {
        printLogs('TimeOutException $e');
      }
      return Future.value(ResponseModel.named(statusCode: 408, statusDescription: "Request TimeOut", data: "Request TimeOut"));
    } on SocketException catch (e) {
      if (kDebugMode) {
        printLogs('SocketException $e');
      }
      return Future.value(ResponseModel.named(statusCode: 400, statusDescription: "Bad Request", data: "Bad Request"));
    } catch (e) {
      if (kDebugMode) {
        printLogs("Exception Http Error $e");
      }
      return Future.value(ResponseModel.named(statusCode: 500, statusDescription: "Server Error", data: "Server Error"));
    }
  }

  /// fn to put request with headers
  Future<ResponseModel> putRequestWithHeader({required String url, dynamic body}) async {
    String methodName = "putRequestWithHeader for $url";
    try {
      final token = SessionService().userToken;
      Map<String, String> headers = {
        'Content-Type': 'application/json',
        'token': token ?? ''
        // 'Cookie':
        //     'connect.sid=s%3A1e3QTF1m3M3Y-AKIuRlgAv1YT4gwpNsn.LCnlD%2F0CIvyrG2coffbG5E4yNifUs0yySzC%2B%2ByRIhzA'
      };
      // if (kDebugMode) {
      printLogs('$methodName url : $url');
      printLogs('$methodName header : $headers');
      printLogs('$methodName body : $body');
      // }

      // printToFirebase('$methodName url : $url');
      // printToFirebase('$methodName request : $body');

      http.Response response = await http.put(Uri.parse(url), headers: headers, body: body).timeout(const Duration(seconds: _requestTimeOut));
      printLogs('$methodName status code ${response.statusCode}');
      printLogs('$methodName response ${response.body}');

      printToFirebase('$methodName status code ${response.statusCode}');
      printToFirebase('$methodName response ${response.body}');
      ResponseModel responseModel = ResponseModel();
      if (response != null && response.body != null && response.body.length > 4) {
        responseModel.statusCode = response.statusCode;
        responseModel.statusDescription = "Success";
        responseModel.data = response.body;
      }
      return responseModel;
    } on TimeoutException catch (e) {
      if (kDebugMode) {
        printLogs('$methodName TimeOutException url $url');
        printLogs('$methodName TimeOutException $e');
      }
      printToFirebase('$methodName TimeOutException url $url');
      printToFirebase('$methodName TimeOutException $e');
      return Future.value(ResponseModel.named(statusCode: 408, statusDescription: "Request TimeOut", data: "Request TimeOut"));
    } on SocketException catch (e) {
      if (kDebugMode) {
        printLogs('$methodName SocketException url $url');
        printLogs('$methodName SocketException ${e.toString()}');
      }
      printToFirebase('$methodName SocketException url $url');
      printToFirebase('$methodName SocketException ${e.toString()}');
      return Future.value(ResponseModel.named(statusCode: 400, statusDescription: "Bad Request", data: "Bad Request"));
    } catch (e) {
      if (kDebugMode) {
        printLogs("$methodName Exception Http Error ${e.toString()}");
      }
      printToFirebase('$methodName SocketException url $url');
      printToFirebase("$methodName Http Error ${e.toString()}");
      return Future.value(ResponseModel.named(statusCode: 500, statusDescription: "Server Error", data: "Server Error"));
    }
  }

  /// fn to put request without headers
  Future<ResponseModel> putRequestWithoutHeader({required String url, dynamic body}) async {
    String methodName = "putRequestWithoutHeader for $url";
    try {
      final token = SessionService().userToken;
      Map<String, String> headers = {'Content-Type': 'application/json', 'token': token ?? ""};

      // var headers = {'Content-Type': 'application/json', 'token': token ?? ''};
      http.Response response = await http.put(Uri.parse(url), headers: headers, body: body).timeout(const Duration(seconds: _requestTimeOut));
      if (kDebugMode) {
        printLogs('$methodName url : $url');
        printLogs('$methodName body : $body');
        printLogs('$methodName response ${response.body}');
      }
      printToFirebase('$methodName url : $url');
      printToFirebase('$methodName request : $body');
      printToFirebase('$methodName statusCode ${response.statusCode}');
      printToFirebase('$methodName response ${response.body}');

      ResponseModel responseModel = ResponseModel();
      if (response != null && response.body != null && response.body.length > 4) {
        responseModel.statusCode = response.statusCode;
        responseModel.statusDescription = "Success";
        responseModel.data = response.body;
      }
      return responseModel;
    } on TimeoutException catch (e) {
      if (kDebugMode) {
        printLogs('$methodName TimeOutException url $url');
        printLogs('$methodName TimeOutException $e');
      }
      printToFirebase('$methodName TimeOutException url $url');
      printToFirebase('$methodName TimeOutException $e');
      return Future.value(ResponseModel.named(statusCode: 408, statusDescription: "Request TimeOut", data: "Request TimeOut"));
    } on SocketException catch (e) {
      if (kDebugMode) {
        printLogs('$methodName SocketException url $url');
        printLogs('$methodName SocketException ${e.toString()}');
      }
      printToFirebase('$methodName SocketException url $url');
      printToFirebase('$methodName SocketException ${e.toString()}');
      return Future.value(ResponseModel.named(statusCode: 400, statusDescription: "Bad Request", data: "Bad Request"));
    } catch (e) {
      if (kDebugMode) {
        printLogs("Exception Http Error ${e.toString()}");
      }
      printToFirebase('$methodName SocketException url $url');
      printToFirebase("$methodName Http Error ${e.toString()}");
      return Future.value(ResponseModel.named(statusCode: 500, statusDescription: "Server Error", data: "Server Error"));
    }
  }

  /// fn for simple put request
  /// fn not in use
  Future<ResponseModel> putrequest({required String url, dynamic body}) async {
    try {
      final token = SessionService().userToken;

      /*var headers = {
        'Content-Type': 'application/json',
        'Cookie': 'connect.sid=s%3A7JM8KY564sG_iYhyTndjWeGSX8LxGC3O.Pfs19mTE2%2FXSZ1ReaQ2kFQdklqo2yGkXzg3cKThH6TI'
      };*/
      var request = http.Request('PUT', Uri.parse(url));

      request.body = jsonEncode(body);
      // request.headers.addAll(headers);

      http.StreamedResponse response = await request.send();

      http.Response httpResponse = await http.Response.fromStream(response);
      ResponseModel responseModel = ResponseModel();
      if (httpResponse != null && httpResponse.body != null && httpResponse.body.length > 4) {
        responseModel.statusCode = httpResponse.statusCode;
        responseModel.statusDescription = "Success";
        responseModel.data = httpResponse.body;
      }
      return responseModel;
    } on TimeoutException catch (e) {
      if (kDebugMode) {
        printLogs('TimeOutException $e');
      }
      return Future.value(ResponseModel.named(statusCode: 408, statusDescription: "Request TimeOut", data: "Request TimeOut"));
    } on SocketException catch (e) {
      if (kDebugMode) {
        printLogs('SocketException $e');
      }
      return Future.value(ResponseModel.named(statusCode: 400, statusDescription: "Bad Request", data: "Bad Request"));
    } catch (e) {
      if (kDebugMode) {
        printLogs("Exception Http Error $e");
      }
      return Future.value(ResponseModel.named(statusCode: 500, statusDescription: "Server Error", data: "Server Error"));
    }
  }

  /// fn for put request with MultiPart with headers
  Future<ResponseModel> putRequestMultiPartWithHeader({
    required String url,
    dynamic body,
    bool isFile = false,
    String? filePath,
    String? filed,
    MediaType? mediaType,
  }) async {
    String methodName = "putRequestMultiPartWithHeader";
    try {
      final token = SessionService().userToken;
      /*Map<String, String> headers = {
        'Authorization': 'Bearer $token',
      };*/
      var headers = {'Content-Type': 'application/json', 'token': token ?? ''};

      http.MultipartRequest request = http.MultipartRequest('PUT', Uri.parse(url));
      request.headers.addAll(headers);
      if (kDebugMode) {
        printLogs('$methodName url : $url');
        printLogs('$methodName body : $body');
      }
      printToFirebase('$methodName url : $url');
      printToFirebase('$methodName request : $body');
      if (isFile) {
        if (kDebugMode) {
          printLogs('$methodName filePath $filePath');
        }
        request.files.add(await http.MultipartFile.fromPath(filed!, filePath!, contentType: mediaType));
      }
      request.fields.addAll(body);
      http.StreamedResponse streamedResponse = await request.send();
      http.Response httpResponse = await http.Response.fromStream(streamedResponse);

      printToFirebase('$methodName statusCode ${httpResponse.statusCode}');
      printToFirebase('$methodName response ${httpResponse.body}');
      ResponseModel responseModel = ResponseModel();
      if (httpResponse != null && httpResponse.body != null && httpResponse.body.length > 4) {
        responseModel.statusCode = httpResponse.statusCode;
        responseModel.statusDescription = "Success";
        responseModel.data = httpResponse.body;
      }
      return responseModel;
    } on TimeoutException catch (e) {
      if (kDebugMode) {
        printLogs('$methodName TimeOutException url $url');
        printLogs('$methodName TimeOutException $e');
      }
      printToFirebase('$methodName TimeOutException url $url');
      printToFirebase('$methodName TimeOutException $e');
      return Future.value(ResponseModel.named(statusCode: 408, statusDescription: "Request TimeOut", data: "Request TimeOut"));
    } on SocketException catch (e) {
      if (kDebugMode) {
        printLogs('$methodName SocketException url $url');
        printLogs('$methodName SocketException ${e.toString()}');
      }
      printToFirebase('$methodName SocketException url $url');
      printToFirebase('$methodName SocketException ${e.toString()}');
      return Future.value(ResponseModel.named(statusCode: 400, statusDescription: "Bad Request", data: "Bad Request"));
    } catch (e) {
      if (kDebugMode) {
        printLogs("Exception Http Error ${e.toString()}");
      }
      printToFirebase('$methodName SocketException url $url');
      printToFirebase("$methodName Http Error ${e.toString()}");
      return Future.value(ResponseModel.named(statusCode: 500, statusDescription: "Server Error", data: "Server Error"));
    }
  }

  /// fn to delete request with headers
  Future<ResponseModel> deleteRequestWithHeader({required String url}) async {
    String methodName = "deleteRequestWithHeader";
    try {
      final token = SessionService().userToken;
      Map<String, String> headers = {
        'Content-Type': 'application/json',

        'token': token ?? ""
        // 'Cookie':
        //     'connect.sid=s%3A1e3QTF1m3M3Y-AKIuRlgAv1YT4gwpNsn.LCnlD%2F0CIvyrG2coffbG5E4yNifUs0yySzC%2B%2ByRIhzA'
      };

      http.Response response = await http.delete(Uri.parse(url), headers: headers).timeout(const Duration(seconds: _requestTimeOut));
      printLogs('response ${response.body}--length${response.body.length}');

      printToFirebase('$methodName url $url');
      printToFirebase('$methodName statusCode ${response.statusCode}');
      printToFirebase('$methodName response ${response.body}');

      ResponseModel responseModel = ResponseModel();
      if (response != null && response.body != null && response.body.length > 4) {
        responseModel.statusCode = response.statusCode;
        responseModel.statusDescription = "Success";
        responseModel.data = response.body;
      }
      return responseModel;
    } on TimeoutException catch (e) {
      if (kDebugMode) {
        printLogs('$methodName TimeOutException url $url');
        printLogs('$methodName TimeOutException $e');
      }
      printToFirebase('$methodName TimeOutException url $url');
      printToFirebase('$methodName TimeOutException $e');
      return Future.value(ResponseModel.named(statusCode: 408, statusDescription: "Request TimeOut", data: "Request TimeOut"));
    } on SocketException catch (e) {
      if (kDebugMode) {
        printLogs('$methodName SocketException url $url');
        printLogs('$methodName SocketException ${e.toString()}');
      }
      printToFirebase('$methodName SocketException url $url');
      printToFirebase('$methodName SocketException ${e.toString()}');
      return Future.value(ResponseModel.named(statusCode: 400, statusDescription: "Bad Request", data: "Bad Request"));
    } catch (e) {
      if (kDebugMode) {
        printLogs("Exception Http Error ${e.toString()}");
      }
      printToFirebase('$methodName SocketException url $url');
      printToFirebase("$methodName Http Error $url");
      return Future.value(ResponseModel.named(statusCode: 500, statusDescription: "Server Error", data: "Server Error"));
    }
  }

  Future<void> downloadFileWithProgress({
    required String url,
    required String savePath,
    required void Function(int receivedBytes, int totalBytes) onProgress,
    required void Function() onDone,
  }) async {
    final uri = Uri.parse(url);

    // Make the request
    final http.Client client = http.Client();
    final http.Request request = http.Request('GET', uri);
    final http.StreamedResponse response = await client.send(request);

    // Get the total file size from headers (if available)
    final int totalBytes = response.contentLength ?? 0;

    // Create the file at the specified path
    final file = File(savePath);

    // Open the file for writing
    final fileStream = file.openWrite();

    // Track the number of bytes downloaded
    int receivedBytes = 0;

    // Listen to the stream and write to the file
    response.stream.listen(
      (List<int> chunk) {
        // Write each chunk to the file
        fileStream.add(chunk);

        // Update the number of bytes received
        receivedBytes += chunk.length;

        // Call the progress callback with the current progress
        onProgress(receivedBytes, totalBytes);
      },
      onDone: () async {
        // Close the file stream when done
        await fileStream.close();
        client.close();
        printLogs('Download completed: $savePath');
        onDone();
      },
      onError: (e) {
        printLogs('Error downloading file: $e');
        client.close();
      },
      cancelOnError: true,
    );
  }

  /// upload file with progress

  Future<ResponseModel> postMultipartRequestFileProgress({
    required String url,
    dynamic body,
    bool isFile = false,
    String? filePath,
    String? filed,
    MediaType? mediaType,
    String? thumbnail,
    void Function(int sentBytes, int totalBytes)? onProgress,
  }) async {
    String methodName = "postMultipartRequestFileProgress";
    try {
      if (kDebugMode) {
        printLogs('url $url');
      }
      printToFirebase('$methodName url : $url');

      final token = SessionService().userToken;
      /*Map<String, String> headers = {
        'Cookie': 'connect.sid=s%3A7JM8KY564sG_iYhyTndjWeGSX8LxGC3O.Pfs19mTE2%2FXSZ1ReaQ2kFQdklqo2yGkXzg3cKThH6TI',
      };*/
      var headers = {'Content-Type': 'application/json', 'token': token};

      d.Dio dio = d.Dio();
      dio.options.headers.addAll(headers);

      d.FormData formData = d.FormData.fromMap(body);
      // if (kDebugMode) {
      printLogs('url : $url');
      printLogs('body : $body');
      // }
      if (isFile) {
        // if (kDebugMode) {
        printLogs('filePath $filePath');
        printLogs('thumbnail path $thumbnail');
        // }
        printToFirebase('$methodName filePath : $filePath');
        printToFirebase('$methodName thumbnailPath : $thumbnail');
        formData.files.add(MapEntry(
          filed!,
          await d.MultipartFile.fromFile(filePath!, contentType: mediaType),
        ));
        if (thumbnail != null) {
          formData.files.add(MapEntry(
            'thumbnail',
            await d.MultipartFile.fromFile(
              thumbnail,
            ),
          ));
        }
      }
      printLogs('=======createPost Request sent at ${DateTime.now()} ');
      printToFirebase('createPost Request sent at ${DateTime.now()}');
      d.Response response = await dio.post(
        url,
        data: formData,
        onSendProgress: (int sentBytes, int totalBytes) {
          // if (kDebugMode) {
          double progress = sentBytes / totalBytes;

          printLogs("===========onSendProgress $progress");
          printLogs('sentBytes $sentBytes totalBytes $totalBytes');
          printLogs("===========onSendProgress filePath $filePath");
          if (filePath != null) {
            printLogs("===========onSendProgress filePath null check ${filePath != null} progress: $progress");
            SharedPrefrenceService.saveUploadProgress(filePath, progress);
            SharedPrefrenceService.saveUploadStatus(filePath, progress < 1 ? UploadStatus.uploading : UploadStatus.success);
          }
          // }
          if (onProgress != null) {
            onProgress(sentBytes, totalBytes);
          }
        },
        onReceiveProgress: (int receivedBytes, int totalBytes) {
          // if (kDebugMode) {
          printLogs('receivedBytes $receivedBytes totalBytes $totalBytes');
          // }
          if (onProgress != null) {
            onProgress(receivedBytes, totalBytes);
          }
        },
      );
      printLogs('=======createPost response received at ${DateTime.now()} ');
      printToFirebase('createPost response received at ${DateTime.now()} ');
      if (kDebugMode) {
        printLogs('response ${response.data}');
      }
      printToFirebase('createPost response : ${response.data}');
      ResponseModel responseModel = ResponseModel();
      responseModel.statusCode = response.statusCode ?? 0;
      responseModel.statusDescription = "Success";
      responseModel.data = response.data;

      return responseModel;
    } on d.DioException catch (e) {
      if (kDebugMode) {
        printLogs('DioError $e');
      }
      printToFirebase('createPost Error : ${e.toString()}');
      if (e.type == d.DioExceptionType.receiveTimeout || e.type == d.DioExceptionType.sendTimeout) {
        printToFirebase('createPost TimeOut Error');
        return ResponseModel.named(statusCode: 408, statusDescription: "Request TimeOut", data: "");
      } else if (e.error is SocketException) {
        printToFirebase('createPost SocketException');
        return ResponseModel.named(statusCode: 400, statusDescription: "Bad Request", data: "");
      } else {
        printToFirebase('createPost General Error');
        return ResponseModel.named(statusCode: 500, statusDescription: "Server Error", data: "");
      }
    } catch (e) {
      if (kDebugMode) {
        printLogs("Exception Http Error $e");
      }
      printToFirebase('createPost Server Error');
      return ResponseModel.named(statusCode: 500, statusDescription: "Server Error", data: "");
    }
  }
}
