import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:paysecure/data/repositories/auth_repo.dart';
import 'package:paysecure/data/source/errors/check_api_status.dart';
import 'package:paysecure/utils/services/helpers.dart';
import 'package:paysecure/utils/services/localstorage/hive.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import '../routes/routes_name.dart';
import '../utils/services/localstorage/keys.dart';

class AuthController extends GetxController {
  static AuthController get to => Get.find<AuthController>();

  bool isLoading = false;

  final FirebaseAuth _auth = FirebaseAuth.instance;
  String verificationId = '';
  bool isOtpSent = false;
  int? resendToken;
  TextEditingController phoneController = TextEditingController();
  TextEditingController otpController = TextEditingController();

  Future sendOtp(String fullPhoneNumber) async {
    isLoading = true;
    update();
    
    try {
      await _auth.verifyPhoneNumber(
        phoneNumber: fullPhoneNumber,
        verificationCompleted: (PhoneAuthCredential credential) async {
          await _auth.signInWithCredential(credential);
          User? user = _auth.currentUser;
          if (user != null) {
            await loginOrRegisterWithBackend(fullPhoneNumber, user.uid);
          }
        },
        verificationFailed: (FirebaseAuthException e) {
          isLoading = false;
          update();
          Helpers.showSnackBar(msg: "Verification failed: ${e.message}");
        },
        codeSent: (String verId, int? forceResendingToken) {
          verificationId = verId;
          resendToken = forceResendingToken;
          isOtpSent = true;
          isLoading = false;
          update();
          Helpers.showSnackBar(msg: "Verification code sent to $fullPhoneNumber");
        },
        codeAutoRetrievalTimeout: (String verId) {
          verificationId = verId;
        },
        timeout: const Duration(seconds: 60),
      );
    } catch (e) {
      isLoading = false;
      update();
      Helpers.showSnackBar(msg: "Error sending OTP: $e");
    }
  }

  Future verifyOtpAndLogin(String otpCode, String fullPhoneNumber) async {
    isLoading = true;
    update();
    
    try {
      PhoneAuthCredential credential = PhoneAuthProvider.credential(
        verificationId: verificationId,
        smsCode: otpCode,
      );
      
      UserCredential userCredential = await _auth.signInWithCredential(credential);
      User? user = userCredential.user;
      if (user != null) {
        await loginOrRegisterWithBackend(fullPhoneNumber, user.uid);
      } else {
        isLoading = false;
        update();
        Helpers.showSnackBar(msg: "Failed to sign in with Firebase");
      }
    } catch (e) {
      isLoading = false;
      update();
      Helpers.showSnackBar(msg: "Invalid OTP code: $e");
    }
  }

  Future loginOrRegisterWithBackend(String fullPhoneNumber, String firebaseUid) async {
    String cleanDigits = fullPhoneNumber.replaceAll(RegExp(r'\D'), '');
    String generatedUsername = "usr_$cleanDigits";
    String generatedPassword = "Firebase_$firebaseUid";
    
    try {
      http.Response loginResponse = await AuthRepo.login(data: {
        "username": generatedUsername,
        "password": generatedPassword,
        "type": 'user',
      });
      
      var loginData = jsonDecode(loginResponse.body);
      if (loginResponse.statusCode == 200 && loginData['status'] == 'success') {
        ApiStatus.checkStatus(loginData['status'], loginData['message']);
        HiveHelp.write(Keys.token, loginData['token']);
        Get.offAllNamed(RoutesName.bottomNavBar);
        clearSignInController();
        clearSignUpController();
        isOtpSent = false;
        phoneController.clear();
        otpController.clear();
      } else {
        String cleanDialCode = phoneCode.replaceAll('+', '');
        String rawPhone = cleanDigits;
        if (cleanDigits.startsWith(cleanDialCode)) {
          rawPhone = cleanDigits.substring(cleanDialCode.length);
        }
        
        http.Response regResponse = await AuthRepo.register(data: {
          "firstname": "Phone",
          "lastname": "User",
          "username": generatedUsername,
          "email": "phone_$cleanDigits@paysecure.com",
          "phone_code": phoneCode,
          "phone": rawPhone,
          "country": countryName,
          "country_code": countryCode,
          "password": generatedPassword,
          "password_confirmation": generatedPassword
        });
        
        var regData = jsonDecode(regResponse.body);
        if (regResponse.statusCode == 200 && regData['status'] == 'success') {
          ApiStatus.checkStatus(regData['status'], regData['message']);
          HiveHelp.write(Keys.token, regData['token']);
          Get.offAllNamed(RoutesName.bottomNavBar);
          clearSignInController();
          clearSignUpController();
          isOtpSent = false;
          phoneController.clear();
          otpController.clear();
        } else {
          if (regData['message'] is List) {
            Helpers.showSnackBar(msg: (regData['message'] as List).join('\n'));
          } else {
            Helpers.showSnackBar(msg: regData['message']?.toString() ?? 'Backend registration failed');
          }
        }
      }
    } catch (e) {
      Helpers.showSnackBar(msg: "Authentication error: $e");
    } finally {
      isLoading = false;
      update();
    }
  }

  // -----------------------sign in--------------------------
  TextEditingController userNameEditingController = TextEditingController();
  TextEditingController signInPassEditingController = TextEditingController();

  String userNameVal = "";
  String singInPassVal = "";
  bool isRemember = false;

  clearSignInController() {
    userNameEditingController.clear();
    signInPassEditingController.clear();
    userNameVal = "";
    singInPassVal = "";
  }

  Future login() async {
    isLoading = true;
    update();
    http.Response response = await AuthRepo.login(data: {
      "username": userNameVal,
      "password": singInPassVal,
      "type": 'user',
    });
    isLoading = false;
    update();
    var data = jsonDecode(response.body);
    if (response.statusCode == 200) {
      if (data['status'] == 'success') {
        ApiStatus.checkStatus(data['status'], data['message']);
        if (isRemember == true) {
          HiveHelp.write(Keys.userName, userNameVal);
          HiveHelp.write(Keys.userPass, singInPassVal);
        }
        HiveHelp.write(Keys.token, data['token']);
        Get.offAllNamed(RoutesName.bottomNavBar);
        clearSignInController();
      } else {
        ApiStatus.checkStatus(data['status'], data['message']);
      }
    } else {
      Helpers.showSnackBar(msg: '${data['message']}');
    }
  }

  // -----------------------sign up--------------------------
  TextEditingController signupFNameEditingController = TextEditingController();
  TextEditingController signupLNameEditingController = TextEditingController();
  TextEditingController emailEditingController = TextEditingController();
  TextEditingController signUpUserNameEditingController =
      TextEditingController();
  TextEditingController phoneNumberEditingController = TextEditingController();
  TextEditingController signUpPassEditingController = TextEditingController();
  TextEditingController confirmPassEditingController = TextEditingController();

  String signupFNameVal = "";
  String signupLNameVal = "";
  String signUpUserNameVal = "";
  String emailVal = "";
  String phoneNumberVal = "";
  String signUpPassVal = "";
  String signUpConfirmPassVal = "";
  String countryCode = 'IN';
  String phoneCode = '+91';
  String countryName = 'India';

  clearSignUpController() {
    emailEditingController.clear();
    signUpUserNameEditingController.clear();
    signupFNameEditingController.clear();
    phoneNumberEditingController.clear();
    signUpPassEditingController.clear();
    confirmPassEditingController.clear();
    signupFNameVal = "";
    signUpUserNameVal = "";
    emailVal = "";
    phoneNumberVal = "";
    signUpPassVal = "";
    signUpConfirmPassVal = "";
  }

  Future register() async {
    isLoading = true;
    update();
    http.Response response = await AuthRepo.register(data: {
      "firstname": signupFNameVal,
      "lastname": signupLNameVal,
      "username": signUpUserNameVal,
      'email': emailEditingController.text,
      "phone_code": phoneCode,
      "phone": phoneNumberVal,
      "country": countryName,
      "country_code": countryCode,
      "password": signUpPassVal,
      "password_confirmation": signUpConfirmPassVal
    });
    isLoading = false;
    update();
    var data = jsonDecode(response.body);
    if (response.statusCode == 200) {
      ApiStatus.checkStatus(data['status'], data['message']);
      if (data['status'] == 'success') {
        HiveHelp.write(Keys.token, data['token']);
        Get.offAllNamed(RoutesName.bottomNavBar);
        clearSignUpController();
      }
    } else {
      Helpers.showSnackBar(msg: '${data['message']}');
    }
  }

  //------------------------forgot password----------------------
  TextEditingController forgotPassEmailEditingController =
      TextEditingController();
  TextEditingController forgotPassNewPassEditingController =
      TextEditingController();
  TextEditingController forgotPassConfirmPassEditingController =
      TextEditingController();
  TextEditingController otpEditingController1 = TextEditingController();
  TextEditingController otpEditingController2 = TextEditingController();
  TextEditingController otpEditingController3 = TextEditingController();
  TextEditingController otpEditingController4 = TextEditingController();
  TextEditingController otpEditingController5 = TextEditingController();

  String forgotPassEmailVal = "";
  String forgotPassNewPassVal = "";
  String forgotPassConfirmPassVal = "";
  String otpVal1 = "";
  String otpVal2 = "";
  String otpVal3 = "";
  String otpVal4 = "";
  String otpVal5 = "";

  bool isNewPassShow = true;
  bool isConfirmPassShow = true;

  clearForgotPassNewPassVal() {
    forgotPassNewPassEditingController.clear();
    forgotPassConfirmPassEditingController.clear();
    forgotPassNewPassVal = "";
    forgotPassConfirmPassVal = "";
  }

  clearForgotPassOtpVal() {
    otpEditingController1.clear();
    otpEditingController2.clear();
    otpEditingController3.clear();
    otpEditingController4.clear();
    otpEditingController5.clear();
    otpVal1 = "";
    otpVal2 = "";
    otpVal3 = "";
    otpVal4 = "";
    otpVal5 = "";
  }

  Future forgotPass({bool? isFromOtpPage = false}) async {
    if (isFromOtpPage == false) {
      isLoading = true;
      update();
    }
    http.Response response = await AuthRepo.forgotPass(data: {
      "email": forgotPassEmailEditingController.text,
    });
    if (isFromOtpPage == false) {
      isLoading = false;
      update();
    }
    var data = jsonDecode(response.body);
    if (response.statusCode == 200) {
      ApiStatus.checkStatus(data['status'], data['message']);
      if (data['status'] == 'success') {
        Get.toNamed(RoutesName.otpScreen);
      }
    } else {
      Helpers.showSnackBar(msg: '${data['message']}');
    }
  }

  //----------------------verify email-----------------
  ///COUNT DOWN TIMER
  int counter = 60;
  late Timer timer;
  bool isStartTimer = false;
  Duration duration = const Duration(seconds: 1);

  void startTimer() {
    timer = Timer.periodic(duration, (timer) {
      if (counter > 0) {
        counter -= 1;
        isStartTimer = true;
        update();
      } else {
        timer.cancel();
        counter = 60;
        isStartTimer = false;
        update();
      }
    });
  }

  Future geCode() async {
    isLoading = true;
    update();
    http.Response response = await AuthRepo.getCode(data: {
      "email": forgotPassEmailEditingController.text,
      "code": '${otpVal1 + otpVal2 + otpVal3 + otpVal4 + otpVal5}',
    });
    isLoading = false;
    update();
    var data = jsonDecode(response.body);
    if (response.statusCode == 200) {
      ApiStatus.checkStatus(data['status'], data['message']);
      if (data['status'] == 'success') {
        Get.toNamed(RoutesName.createNewPassScreen);
        clearForgotPassOtpVal();
      }
    } else {
      Helpers.showSnackBar(msg: '${data['message']}');
    }
  }

  Future updatePass() async {
    isLoading = true;
    update();
    http.Response response = await AuthRepo.updatePass(data: {
      "password": forgotPassNewPassEditingController.text,
      "password_confirmation": forgotPassConfirmPassEditingController.text,
      "email": forgotPassEmailEditingController.text,
    });
    isLoading = false;
    update();
    var data = jsonDecode(response.body);
    if (response.statusCode == 200) {
      ApiStatus.checkStatus(data['status'], data['message']);
      if (data['status'] == 'success') {
        Get.offAllNamed(RoutesName.loginScreen);
        clearForgotPassNewPassVal();
      }
    } else {
      Helpers.showSnackBar(msg: '${data['message']}');
    }
  }
}
