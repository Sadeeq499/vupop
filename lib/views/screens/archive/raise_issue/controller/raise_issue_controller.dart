import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:socials_app/models/issues_list_model.dart';
import 'package:socials_app/repositories/raise_issue_repo.dart';

import '../../../../../services/common_imagepicker.dart';
import '../../../../../services/custom_snackbar.dart';
import '../../../../../services/session_services.dart';
import '../../../../../utils/common_code.dart';
import '../../components/report_submitted_dialog.dart';

class RaiseIssueController extends GetxController {
  GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  RxBool isLoading = false.obs, isReasonError = false.obs, isDescriptionError = false.obs;
  RxList<String> reportingReasons = RxList();
  RxString selectedReason = 'Select Reason'.obs;
  RxString selectedReasonId = ''.obs;

  RxList<IssuesListDataModel> reasonsModelReport = RxList();
  TextEditingController descriptionController = TextEditingController();
  FocusNode fnDescription = FocusNode();

  @override
  void onInit() {
    super.onInit();
  }

  @override
  void onClose() {
    // videoController?.dispose();
    super.onClose();
  }

  onReasonDropDownChange(newValue) {
    if (newValue != null) {
      selectedReason.value = newValue;
      printLogs('=================newValue $newValue');

      selectedReasonId.value = reasonsModelReport.firstWhere((element) => element.reason == newValue).id ?? "";
      if (selectedReasonId.value.isNotEmpty) {
        isReasonError.value = false;
      }
      printLogs('=============selectedReasonId.value report ${selectedReasonId.value}');
    }
  }

  RxList<String> issueImagesList = RxList();
  RxString imagePath = ''.obs;
  RxBool isFileSelected = false.obs;

  /// pick image
  Future<void> pickImage() async {
    try {
      // Check if we've reached the maximum limit (e.g., 5 images)
      if (issueImagesList.length >= 5) {
        CustomSnackbar.showSnackbar("Maximum 5 images can be selected");
        return;
      }

      if (issueImagesList.isEmpty) {
        issueImagesList.value = [];
      }
      imagePath.value = '';
      final image = await CommonServices().imagePicker(ImageSource.gallery);
      if (image != null) {
        imagePath.value = image;
        isFileSelected.value = true;
        issueImagesList.add(imagePath.value);
        printLogs("Image added: ${imagePath.value}");
        printLogs("Total images: ${issueImagesList.length}");
      }
    } catch (e) {
      CustomSnackbar.showSnackbar("Error while picking image, try again");
      printLogs("================Catch Exception pickImage $e");
    }
  }

  /// remove image from list
  void removeImage(int index) {
    try {
      if (index >= 0 && index < issueImagesList.length) {
        String removedImage = issueImagesList[index];
        issueImagesList.removeAt(index);
        printLogs("Image removed: $removedImage");
        printLogs("Total images remaining: ${issueImagesList.length}");

        // If no images left, reset file selection status
        if (issueImagesList.isEmpty) {
          isFileSelected.value = false;
        }
      }
    } catch (e) {
      CustomSnackbar.showSnackbar("Error while removing image");
      printLogs("================Catch Exception removeImage $e");
    }
  }

  /// clear all images
  void clearAllImages() {
    try {
      issueImagesList.clear();
      isFileSelected.value = false;
      imagePath.value = '';
      printLogs("All images cleared");
    } catch (e) {
      printLogs("================Catch Exception clearAllImages $e");
    }
  }

  Future<void> getPostReportingIssuesList() async {
    try {
      final userId = SessionService().user?.id ?? '';

      final response = await RaiseIssueRepo().getAllIssueReasons(userId: userId);
      printLogs('=========response $response');
      if (response != null && response.isNotEmpty) {
        reportingReasons.clear();
        reportingReasons.add("Select Reason");

        for (IssuesListDataModel reason in response) {
          if (reason.reason.isNotEmpty && !reportingReasons.contains(reason.reason)) {
            reportingReasons.add(reason.reason ?? '');
            reasonsModelReport.add(reason);
          }
        }
      } else {
        CustomSnackbar.showSnackbar("Unable to get clip reporting issues list");
      }
    } catch (e) {
      CustomSnackbar.showSnackbar("Something went wrong");
      printLogs('Error getPostReportingIssuesList: $e');
    }
  }

  /// validate form before submission
  bool validateForm() {
    bool isValidated = validateData();
    if (selectedReason.value == 'Select Reason' || selectedReason.value.isEmpty) {
      CustomSnackbar.showSnackbar("Please select an issue reason");
      return false;
    }
    printLogs("selectedReason.value ${selectedReason.value}");
    printLogs("selectedReason.value ${descriptionController.text}");

    if (descriptionController.text.trim().isEmpty) {
      CustomSnackbar.showSnackbar("Please enter a description");
      return false;
    } else if (descriptionController.text.isNotEmpty && descriptionController.text.length < 15) {
      CustomSnackbar.showSnackbar("Description must be at least 15 characters long");
      return false;
    }

    return isValidated && true;
  }

  bool validateData() {
    if (selectedReasonId.isEmpty) {
      isReasonError.value = true;
    }
    if (descriptionController.text.isEmpty || descriptionController.text.length < 15) {
      isDescriptionError.value = true;
    }
    printLogs("======isReasonError.isTrue ${isReasonError.isTrue}");
    printLogs("======isDescriptionError.isTrue ${isDescriptionError.isTrue}");
    return isReasonError.isFalse && isDescriptionError.isFalse;
  }

  Future<void> submitClipIssue() async {
    // Validate form first
    if (!validateForm()) {
      return;
    }

    isLoading.value = true;
    try {
      final userId = SessionService().user?.id ?? '';
      final postId = Get.arguments != null ? Get.arguments['postId'] : '';

      final response = await RaiseIssueRepo().reportVideoClip(
        userId: userId,
        postId: postId,
        description: descriptionController.text,
        reasonId: selectedReasonId.value,
        images: issueImagesList.value,
      );
      printLogs('=========response $response');
      if (response != null && response) {
        isLoading.value = false;

        // Show success dialog
        ReportSubmittedDialog.show(
          onBackToArchiveScreen: () {
            // Clear form data
            clearFormData();
            // Navigate back
            print('Going back to previous screen');
            Get.close(3);
          },
        );
      } else {
        isLoading.value = false;
        CustomSnackbar.showSnackbar("Unable to report the issue, please try again");
      }
    } catch (e) {
      isLoading.value = false;
      CustomSnackbar.showSnackbar("Something went wrong");
      printLogs('Error submitClipIssue: $e');
    }
  }

  /// clear form data after successful submission
  void clearFormData() {
    selectedReason.value = 'Select Reason';
    selectedReasonId.value = '';
    descriptionController.clear();
    clearAllImages();
  }
}
