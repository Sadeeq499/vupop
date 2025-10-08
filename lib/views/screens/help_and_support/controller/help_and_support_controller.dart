import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:socials_app/repositories/help_support_repo.dart';
import 'package:socials_app/services/custom_snackbar.dart';
import 'package:socials_app/services/session_services.dart';

class HelpAndSupportController extends GetxController {
  GlobalKey<ScaffoldState> helpAndSupportKey = GlobalKey<ScaffoldState>();
  TextEditingController nameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController messageController = TextEditingController();
  RxString selectedValue = ''.obs;
  RxBool isLoading = false.obs;
  @override
  void onInit() {
    super.onInit();
    emailController.text = SessionService().user?.email ?? '';
    nameController.text = SessionService().user?.name ?? '';
  }

  Future<void> sendHelpSupport() async {
    if (!validate()) {
      return;
    }
    isLoading.value = true;
    final userID = SessionService().user?.id ?? '';
    final resp = await HelpSupportRepo().sendHelpSupport(
      email: emailController.text,
      message: messageController.text,
      name: nameController.text,
      userId: userID,
    );
    if (resp != null) {
      isLoading.value = false;
      Get.back();
      CustomSnackbar.showSnackbar('Your message has been sent successfully');
    } else {
      Get.snackbar('Error', 'Failed to send message');
    }
    isLoading.value = false;
  }

  /// validation
  bool validate() {
    if (nameController.text.isEmpty) {
      CustomSnackbar.showSnackbar('Name is required');
      return false;
    } else if (emailController.text.isEmpty) {
      CustomSnackbar.showSnackbar('Email is required');
      return false;
    } else if (messageController.text.isEmpty) {
      CustomSnackbar.showSnackbar('Message is required');
      return false;
    } else if (emailController.text.isEmail == false) {
      CustomSnackbar.showSnackbar('Please enter a valid email');
      return false;
    } else if (emailController.text != SessionService().user?.email) {
      CustomSnackbar.showSnackbar('Please enter your registered email');
      return false;
    }
    return true;
  }
}
