import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:socials_app/repositories/wallet_repo.dart';
import 'package:socials_app/services/custom_snackbar.dart';
import 'package:socials_app/views/screens/profile/controller/profile_controller.dart';

import '../../../../models/payment_models/get_payment_methods_model.dart';
import '../../../../models/payment_models/request_payment_model.dart';
import '../../../../models/payment_models/wallet_balance_model.dart';
import '../../../../repositories/payment_repo.dart';
import '../../../../services/session_services.dart';
import '../../../../utils/common_code.dart';
import '../../../custom_widgets/custom_app_dialogs.dart';

class RequestPaymentController extends GetxController {
  GlobalKey<ScaffoldState> requestPaymentKey = GlobalKey<ScaffoldState>();
  Rx<RequestPaymentData?> walletData = Rx<RequestPaymentData?>(null);
  RxList<Export> exportsList = RxList();
  RxBool isLoading = false.obs;
  RxBool isShowAll = false.obs;
  RxBool canSendRequest = false.obs, canWithdrawAmount = false.obs;
  Rx<WalletBalanceModel?> walletPaymentData = Rx<WalletBalanceModel?>(null);

  RxBool isPaymentMethodFound = false.obs;
  @override
  void onInit() {
    super.onInit();
    getPaymentDetail();
  }

  /// fn to get wallet balance
  Future<void> getWalletBalance() async {
    final resp = await WalletRepo().getWalletBalance();
    if (resp != null) {
      walletPaymentData.value = resp;
      canWithdrawAmount.value = walletPaymentData.value?.readyToWithdrawAmount != null && walletPaymentData.value!.readyToWithdrawAmount! > 0;
    } else {
      canWithdrawAmount.value = false;
      CustomSnackbar.showSnackbar('Network Error: Unable to get wallet balance');
    }
  }

  /*Future<void> getPaymentDetail() async {
    isLoading.value = true;
    try {
      // get payment detail
      final resp = await InvoiceRepo().getwallet();
      if (resp != null) {
        walletData.value = resp;
      }
    } catch (e) {
      log('Error in getPaymentDetail: $e');
      CustomSnackbar.showSnackbar('Error in getPaymentDetail');
    }
    isLoading.value = false;
  }*/

  ///fn to check payment history
  PaymentMethodData? paymentMethodData;
  Future<void> getPaymentDetail() async {
    isLoading.value = true;
    try {
      // get payment detail
      final resp = await WalletRepo().geRequestPayment();
      if (resp != null) {
        walletData.value = resp;
        if (walletData.value != null &&
            walletData.value!.exportss != null &&
            walletData.value!.exportss!.isNotEmpty &&
            walletData.value!.exportss![0].exports != null &&
            walletData.value!.exportss![0].exports!.isNotEmpty) {
          exportsList.value = walletData.value!.exportss![0].exports!;
        }

        canSendRequest.value = walletData.value != null &&
                walletData.value!.exportss != null &&
                walletData.value!.exportss!.isNotEmpty &&
                walletData.value!.exportss![0].totalAmount != null &&
                walletData.value!.exportss![0].totalAmount! > 0
            ? true
            : false;

        paymentMethodData = await PaymentRepo().getUserPaymentMethod(userId: SessionService().user!.id);
        if (paymentMethodData != null) {
          isPaymentMethodFound.value = true;
        } else {
          isPaymentMethodFound.value = false;
        }
      }
    } catch (e) {
      if (kDebugMode) {
        log('Error in getPaymentDetail: $e');
      }
      CustomSnackbar.showSnackbar('Error in getting payment details');
    }
    isLoading.value = false;
  }

  ///fn to request payment to Admin
  Future<void> requestPaymentToAdmin() async {
    isLoading.value = true;
    try {
      // get payment detail
      final resp = await WalletRepo().requestPaymentToAdmin();
      if (resp) {
        Get.back();
        CustomSnackbar.showSnackbar('Withdrawal Request sent successfully');
        Get.find<ProfileScreenController>().getWalletBalance();
        showCongratulationsDialog(
          customerName: paymentMethodData?.userName ?? "-",
          iban: paymentMethodData?.iban ?? "-",
          amountToWithdraw: walletPaymentData.value?.readyToWithdrawAmount?.toStringAsFixed(2) ?? "0",
          requestStatus: 'Success',
        ); /*showPaymentStatusDialog(
          customerName: paymentMethodData?.userName ?? "-",
          iban: paymentMethodData?.iban ?? "-",
          amountToWithdraw: walletPaymentData.value?.readyToWithdrawAmount?.toStringAsFixed(2) ?? "0",
          requestStatus: 'Success',
        );*/
      } else {
        // CustomSnackbar.showSnackbar('Withdrawal Request could not be sen');
      }
    } catch (e) {
      if (kDebugMode) {
        printLogs('Error in requestPaymentToAdmin: $e');
      }
      CustomSnackbar.showSnackbar('Error occurred while sending withdrawal request, please try again');
    }
    isLoading.value = false;
  }
}
