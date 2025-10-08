import 'package:country_code_picker/country_code_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:socials_app/repositories/auth_repo.dart';
import 'package:socials_app/repositories/payment_repo.dart';
import 'package:socials_app/services/custom_snackbar.dart';
import 'package:socials_app/services/session_services.dart';
import 'package:socials_app/views/screens/account_details/components/custom_verification_widget.dart';

import '../../../../models/payment_models/get_payment_methods_model.dart';
import '../../../../utils/common_code.dart';
import '../../social_wallet/controller/social_wallet_controller.dart';

class AccountDetailsController extends GetxController with GetSingleTickerProviderStateMixin {
  GlobalKey<ScaffoldState> accountDetailsKey = GlobalKey<ScaffoldState>();
  RxBool isLoading = false.obs;
  RxString selectedValue = 'Bank Transfer'.obs;
  RxBool isPaymentMethodSelected = false.obs, isPaymentMethodFound = false.obs;
  RxString selectedLocation = 'Islamabad'.obs;
  RxString selectedAccountType = 'Farhan'.obs;
  RxString selectedCountryCode = 'GB'.obs;
  // final List<String> dropdownItems = ['Bank Transfer', 'Credit Card', 'Paypal', 'Cash'];
  final List<String> dropdownItems = ['Bank Transfer'];
  final List<String> items = ['Islamabad', 'RawalPindi', 'Karachi'];
  final List<String> accountName = ['Farhan', 'Faiz', 'Saad'];
// void showdropdown(BuildContext context) {
//   final List<String> items = ['Islamabad', 'RawalPindi', 'Karachi'];

//   showMenu(
//     context: context,
//     position: RelativeRect.fromLTRB(0, 0, 0, 0),
//     items: items.map((String item) {
//       return PopupMenuItem<String>(
//         value: item,
//         child: Text(item),
//       );
//     }).toList(),
//   ).then<void>((String? newValue) {
//     if (newValue != null) {
//       selctedlocation.value = newValue;
//     }

//   });
// }

  void showAccountDropdown(BuildContext context) {
    final List<String> items = ['Islamabad', 'RawalPindi', 'Karachi'];

    showMenu(
      context: context,
      position: RelativeRect.fromLTRB(0, 0, 0, 0),
      items: items.map((String item) {
        return PopupMenuItem<String>(
          value: item,
          child: Text(item),
        );
      }).toList(),
    ).then<void>((String? newValue) {
      if (newValue != null) {
        selectedAccountType.value = newValue;
      }
    });
  }

  /// Add payment method
  TextEditingController accountNumberController = TextEditingController();
  TextEditingController routingNumberController = TextEditingController();
  TextEditingController firstNameController = TextEditingController();
  TextEditingController lastNameController = TextEditingController();
  TextEditingController paymentRefrenceController = TextEditingController();
  TextEditingController bacsCodeController = TextEditingController();
  TextEditingController sortCodeController = TextEditingController();
  TextEditingController postalCodeController = TextEditingController();
  TextEditingController cityController = TextEditingController();
  TextEditingController addressController = TextEditingController();
  TextEditingController familyNameController = TextEditingController();
  TextEditingController tecEmail = TextEditingController();
  RxBool isValidEmail = false.obs;
  void addPaymentMethod() async {
    isLoading.value = true;
    if (selectedValue.value == 'Bank Transfer' && validate()) {
      final userID = SessionService().user!.id;

      final result = await PaymentRepo().addPaymentMethod(
        userId: userID,
        accName: "${firstNameController.text} ${lastNameController.text}",
        iban: accountNumberController.text,
        address: addressController.text,
        city: cityController.text,
        postalCode: postalCodeController.text,
        countryCode: selectedCountryCode.value,
      );
      printLogs('Result: $result');
      if (result) {
        printLogs('Payment Method Added Successfully');
        isLoading.value = false;
        SocialWalletController socialWalletController =
            Get.isRegistered<SocialWalletController>() ? Get.find<SocialWalletController>() : Get.put(SocialWalletController());
        socialWalletController.isPaymentMethodFound.value = true;
        Get.back();
        CustomSnackbar.showSnackbar(isPaymentMethodFound.isTrue ? "Payment Method Updated Successfully" : "Payment Method Added Successfully");
      } else {
        CustomSnackbar.showSnackbar("Failed to add payment method");
      }
    } else if (selectedValue.value == 'Credit Card') {
      // TODO : Add credit card payment method
    } else if (selectedValue.value == 'Paypal') {
      // TODO : Add paypal payment method
    } else if (selectedValue.value == 'Cash') {
      // TODO : Add cash payment method
    }
    isLoading.value = false;
  }

  /// fn for validation
  bool validate() {
    if (selectedValue.value == 'Bank Transfer') {
      if (isEmailVerified.isFalse) {
        CustomSnackbar.showSnackbar("Please verify your email");
        return false;
      }
      if (firstNameController.text.isEmpty) {
        CustomSnackbar.showSnackbar("Please enter first name");
        return false;
      } else if (lastNameController.text.isEmpty) {
        CustomSnackbar.showSnackbar("Please enter last name");
        return false;
      } else if (accountNumberController.text.isEmpty) {
        CustomSnackbar.showSnackbar("Please enter IBAN");
        return false;
      } else if (postalCodeController.text.isEmpty) {
        CustomSnackbar.showSnackbar("Please enter postal code");
        return false;
      } else if (cityController.text.isEmpty) {
        CustomSnackbar.showSnackbar("Please enter city");
        return false;
      } else if (addressController.text.isEmpty) {
        CustomSnackbar.showSnackbar("Please enter address");
        return false;
      }
    } else if (selectedValue.value == 'Credit Card') {
      // TODO : Add credit card payment method
    } else if (selectedValue.value == 'Paypal') {
      // TODO : Add paypal payment method
    } else if (selectedValue.value == 'Cash') {
      // TODO : Add cash payment method
    }
    return true;
  }

  onCountryDropDownChange(CountryCode countryCode) {
    selectedCountryCode.value = countryCode.code ?? "GB";
  }

  //Timer
  AnimationController? timerController;
  RxInt otpTimer = 60.obs;
  RxBool isEmailVerified = false.obs;
  RxBool isTimerComplete = false.obs;
  TextEditingController tecOtp = TextEditingController();

  @override
  void onClose() {
    // TODO: implement dispose

    if (timerController != null) {
      timerController?.stop();
      timerController?.dispose();
    }
    super.onClose();
  }

  @override
  void dispose() {
    if (timerController != null) {
      timerController?.stop();
      timerController?.dispose();
    }
    // TODO: implement dispose
    super.dispose();
  }

  @override
  void onInit() {
    // TODO: implement onInit
    super.onInit();
    initOtpTimer();
  }

  initOtpTimer() {
    timerController = AnimationController(vsync: this, duration: Duration(seconds: otpTimer.value));

    timerController!.forward();
    timerController!.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        isTimerComplete.value = true;
      }
    });
  }

  sendOtpOnEmail(context) async {
    if (isEmailVerified.value) {
      return;
    }
    if (isValidEmail.isTrue) {
      isLoading.value = true;
      bool? isSentSuccessfully = await AuthRepo().sendOtpToEmail(email: tecEmail.text);
      // bool? isSentSuccessfully = true;
      if (isSentSuccessfully != null && isSentSuccessfully) {
        if (timerController != null) {
          tecOtp.text = "";
          timerController?.duration = Duration(seconds: otpTimer.value);
          timerController?.reset();
        } else {
          timerController = AnimationController(vsync: this, duration: Duration(seconds: otpTimer.value));
        }

        timerController!.forward();
        await showModalBottomSheet(
            context: context,
            builder: (context) => Padding(
                  padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
                  child: VerifyEmailWidget(
                    controller: this,
                    codeSentTo: tecEmail.text,
                  ),
                ));
      } else {
        // CustomSnackbar.showSnackbar('Failed to send OTP, please check phone number and try again');
      }
    } else {
      CustomSnackbar.showSnackbar('Please enter a valid email.');
    }
    isLoading.value = false;
  }

  reSendOtp() async {
    isLoading.value = true;

    try {
      // Stop the current timer if it's running
      timerController?.stop();

      bool? isSentSuccessfully = await AuthRepo().sendOtpToEmail(email: tecEmail.text);
      // bool? isSentSuccessfully = true;
      if (isSentSuccessfully != null && isSentSuccessfully) {
        CustomSnackbar.showSnackbar('Otp sent successfully');
        isTimerComplete.value = false;
        // Reset the duration of the timer
        timerController?.duration = Duration(seconds: otpTimer.value);

        // Restart the countdown from the beginning
        timerController?.reset();
        timerController?.forward();
      }

      isLoading.value = false;
    } catch (e) {
      printLogs('reSendOTP Exception : $e');
      isLoading.value = false;
    }
  }

  verifyOtp({
    required String otp,
  }) async {
    isLoading.value = true;
    bool? isNumberVerified = await AuthRepo().verifyOtp(
      otp: otp,
      email: tecEmail.text,
    );
    try {
      if (isNumberVerified != null && isNumberVerified) {
        isLoading.value = false;
        isEmailVerified.value = true;
        isEmailVerified.refresh();
        // Get.back();
        CustomSnackbar.showSnackbar('Email verified successfully');
      } else {
        isLoading.value = false;
        isEmailVerified.value = false;
        CustomSnackbar.showSnackbar('Email could not be verified, please try again');
      }
      // Handle successful sign-in
    } catch (e) {
      isLoading.value = false;
      isEmailVerified.value = false;
      CustomSnackbar.showSnackbar('Something went wrong, please try again');
    }
    isLoading.value = false;
  }

  getUserPaymentMethod() async {
    try {
      isLoading.value = true;
      final userID = SessionService().user!.id;

      isEmailVerified.value = SessionService().isEmailVerified ?? false;
      tecEmail.text = SessionService().verifiedEmail ?? "";
      PaymentMethodData? paymentMethodData = await PaymentRepo().getUserPaymentMethod(userId: userID);

      if (paymentMethodData != null) {
        isPaymentMethodFound.value = true;
        firstNameController.text = paymentMethodData.userName?.split(" ")[0] ?? "";
        lastNameController.text = paymentMethodData.userName?.split(" ")[1] ?? "";
        postalCodeController.text = paymentMethodData.postalCode ?? "";
        cityController.text = paymentMethodData.city ?? "";
        addressController.text = paymentMethodData.addressLine1 ?? "";
        selectedCountryCode.value = paymentMethodData.countryCode ?? "";
        accountNumberController.text = paymentMethodData.iban ?? "";
      }
      isLoading.value = false;
    } catch (e) {
      printLogs('getUserPaymentMethod Exception : $e');
      isLoading.value = false;
    }
  }
}
