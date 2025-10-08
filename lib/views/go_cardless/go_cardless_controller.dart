import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../../utils/app_strings.dart';
import '../../utils/common_code.dart';

class GoCardlessAuthController extends GetxController {
  GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  // final String authUrl;
  final isLoading = true.obs;
  late WebViewController webViewController;

  // GoCardlessAuthController({required this.authUrl});

  @override
  void onInit() {
    super.onInit();
    webViewController = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageFinished: (String url) {
            isLoading.value = false;
            /*webViewController.runJavaScript('''
                (function() {
                  let contentWrapper = document.createElement('div');
                  contentWrapper.style.height = '100%';
                  contentWrapper.style.overflowY = 'scroll';
                  contentWrapper.style.display = 'block';

                  let bodyChildren = document.body.children;
                  while (bodyChildren.length > 0) {
                    contentWrapper.appendChild(bodyChildren[0]);
                  }

                  document.body.appendChild(contentWrapper);
                  document.body.style.height = '100%';
                  document.body.style.margin = '0';
                })();
              ''');*/

            webViewController.runJavaScriptReturningResult("document.body.innerText").then((dynamic result) {
              if (result != null) {
                // Convert the result to a string and trim any whitespace
                String pageContent = result.toString().trim();

                // Check if the string starts and ends with quotes, indicating it’s a stringified JSON
                if (pageContent.startsWith('"') && pageContent.endsWith('"')) {
                  // Remove the starting and ending quotes and unescape any internal quotes
                  pageContent = pageContent.substring(1, pageContent.length - 1).replaceAll(r'\"', '"');

                  // Now check if the content is valid JSON
                  if (pageContent.startsWith("{") && pageContent.endsWith("}")) {
                    try {
                      // Parse the JSON string into a map
                      Map<String, dynamic> response = jsonDecode(pageContent) as Map<String, dynamic>;

                      // Check if the 'success' field is true
                      if (response['success'] == true) {
                        // Authorization successful, close WebView or perform navigation
                        Get.offAndToNamed(kBottomNavBar);

                        printLogs("Authorization successful");
                        printLogs("Access Token: ${response['savedPaymentMethod']['accessToken']}");
                      } else {
                        Get.offAndToNamed(kBottomNavBar);
                      }
                    } catch (e) {
                      printLogs("Error parsing JSON: $e");
                    }
                  } else {
                    printLogs("The content is not valid JSON: $pageContent");
                  }
                } else {
                  printLogs("The result is not a stringified JSON object: $pageContent");
                }
              }
            }).catchError((error) {
              printLogs("Error executing JavaScript: $error");
            });

            /* webViewController.runJavaScript('''
                document.body.style.overflow = 'scroll';
                document.documentElement.style.overflow = 'scroll';
                document.body.style.height = 'auto';
                document.documentElement.style.height = 'auto';
              ''');*/
          },
        ),
      )
      ..loadRequest(Uri.parse("https://flutter.dev"));
    // ..loadRequest(Uri.parse(kGoCardlessAuthURL));
  }
}
