import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:socials_app/utils/app_colors.dart';
import 'package:socials_app/utils/app_strings.dart';
import 'package:socials_app/utils/app_styles.dart';
import 'package:socials_app/views/custom_widgets/custom_app_bar_widget.dart';
import 'package:webview_flutter/webview_flutter.dart';

import 'go_cardless_controller.dart';

class GoCardlessAuthView extends GetView<GoCardlessAuthController> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(60),
        child: CustomAppBar(
            actions: [
              Padding(
                padding: const EdgeInsets.only(right: 20.0),
                child: TextButton(
                  onPressed: () {
                    Get.offAndToNamed(kBottomNavBar);
                  },
                  child: Text(
                    "Done",
                    style: AppStyles.labelTextStyle().copyWith(color: kPrimaryColor, fontSize: 16, fontWeight: FontWeight.w500),
                  ),
                ),
              )
            ],
            backIcon: true,
            backIconColor: kPrimaryColor,
            scaffoldKey: controller.scaffoldKey,
            centerTitle: false,
            screenTitleColor: kPrimaryColor,
            screenTitle: "Go Cardless Authorization",
            className: runtimeType.toString()),
      ),
      body: Stack(
        children: [
          WebViewWidget(controller: controller.webViewController),
          Obx(() => controller.isLoading.value ? Center(child: CircularProgressIndicator()) : SizedBox.shrink()),
        ],
      ),
    );
  }
}
