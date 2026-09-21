import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
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
  String? errorMessage;

  final FirebaseAuth _auth = FirebaseAuth.instance;
  String verificationId = '';
  bool isOtpSent = false;
  int? resendToken;
  DateTime? _rateLimitEndTime;  // tracks when too-many-requests cooldown expires
  TextEditingController phoneController = TextEditingController();
  TextEditingController otpController = TextEditingController();

  // 60-second Resend OTP countdown timer state
  int resendOtpCountdown = 60;
  bool canResendOtp = false;
  Timer? _countdownTimer;

  void startResendTimer() {
    stopResendTimer();
    resendOtpCountdown = 60;
    canResendOtp = false;
    update();

    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (resendOtpCountdown > 1) {
        resendOtpCountdown--;
        update();
      } else {
        resendOtpCountdown = 0;
        canResendOtp = true;
        stopResendTimer();
        update();
      }
    });
  }

  void stopResendTimer() {
    _countdownTimer?.cancel();
    _countdownTimer = null;
  }

  void resetOtpState() {
    stopResendTimer();
    isOtpSent = false;
    canResendOtp = false;
    resendOtpCountdown = 60;
    otpController.clear();
    errorMessage = null;
    update();
  }

  /// Returns true if the device is currently rate-limited by Firebase
  bool get isRateLimited {
    if (_rateLimitEndTime == null) return false;
    return DateTime.now().isBefore(_rateLimitEndTime!);
  }

  /// Human-friendly remaining cooldown string e.g. "4 min 32 sec"
  String get rateLimitRemainingText {
    if (_rateLimitEndTime == null) return '';
    final remaining = _rateLimitEndTime!.difference(DateTime.now());
    if (remaining.isNegative) return '';
    final m = remaining.inMinutes;
    final s = remaining.inSeconds % 60;
    if (m > 0) return '$m min ${s.toString().padLeft(2, '0')} sec';
    return '$s sec';
  }

  /// Maps a FirebaseAuthException to a short, user-friendly message
  String _friendlyFirebaseError(FirebaseAuthException e) {
    switch (e.code) {
      case 'too-many-requests':
        // Start a 5-minute rate-limit cooldown
        _rateLimitEndTime = DateTime.now().add(const Duration(minutes: 5));
        return 'Too many OTP requests. Please wait 5 minutes before trying again.';
      case 'invalid-phone-number':
        return 'Phone number is invalid. Please enter a valid 10-digit mobile number with country code.';
      case 'network-request-failed':
        return 'No internet connection. Please check your network and try again.';
      case 'quota-exceeded':
        return 'SMS quota exceeded. Please contact support or try again after some time.';
      case 'app-not-authorized':
        return 'App verification failed. Please update the app and try again.';
      case 'missing-phone-number':
        return 'Please enter your mobile number to receive an OTP.';
      case 'captcha-check-failed':
        return 'Security check failed. Please restart the app and try again.';
      default:
        return 'Could not send OTP. Please try again in a few minutes.';
    }
  }

  Future resendOtp(String fullPhoneNumber) async {
    if (!canResendOtp || isLoading) return;
    await sendOtp(fullPhoneNumber, isResend: true);
  }

  Future sendOtp(String fullPhoneNumber, {bool isResend = false}) async {
    isLoading = true;
    errorMessage = null;
    otpController.clear();
    update();
    
    try {
      await _auth.verifyPhoneNumber(
        phoneNumber: fullPhoneNumber,
        forceResendingToken: isResend ? resendToken : null,
        verificationCompleted: (PhoneAuthCredential credential) async {
          await _auth.signInWithCredential(credential);
          User? user = _auth.currentUser;
          if (user != null) {
            await loginOrRegisterWithBackend(fullPhoneNumber, user.uid);
          }
        },
        verificationFailed: (FirebaseAuthException e) {
          isLoading = false;
          isOtpSent = false;
          final friendly = _friendlyFirebaseError(e);
          errorMessage = friendly;
          update();
          if (e.code == 'too-many-requests') {
            Get.dialog(
              AlertDialog(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                title: const Row(
                  children: [
                    Icon(Icons.block_rounded, color: Colors.red),
                    SizedBox(width: 8),
                    Text('Too Many Requests'),
                  ],
                ),
                content: Text(
                  'Firebase has temporarily blocked OTP requests from this device.\n\n'
                  'Please wait 5 minutes and try again.\n\n'
                  'Tip: Avoid tapping "Send OTP" multiple times rapidly.',
                ),
                actions: [
                  TextButton(
                    onPressed: () => Get.back(),
                    child: const Text('OK, I understand'),
                  ),
                ],
              ),
              barrierDismissible: false,
            );
          } else {
            Helpers.showSnackBar(msg: friendly, title: 'OTP Failed');
          }
        },
        codeSent: (String verId, int? forceResendingToken) {
          verificationId = verId;
          resendToken = forceResendingToken;
          isOtpSent = true;
          isLoading = false;
          errorMessage = null; // ← explicitly clear any stale errors
          otpController.clear(); // ← reset OTP input on new send
          startResendTimer();
          update();
          Helpers.showSuccessSnackBar(
            title: isResend ? "OTP Resent Successfully" : "OTP Sent Successfully",
            msg: "A 6-digit verification code was sent to $fullPhoneNumber",
          );
        },
        codeAutoRetrievalTimeout: (String verId) {
          verificationId = verId;
        },
        timeout: const Duration(seconds: 60),
      );
    } catch (e) {
      isLoading = false;
      isOtpSent = false;
      // Catch-all: show friendly message, never expose raw exception to user
      errorMessage = 'Something went wrong. Please check your network and try again.';
      update();
      Helpers.showSnackBar(
        msg: 'Could not send OTP. Please try again.',
        title: 'Error',
      );
    }
  }

  Future verifyOtpAndLogin(String otpCode, String fullPhoneNumber) async {
    isLoading = true;
    errorMessage = null;
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
        errorMessage = "Failed to sign in with Firebase";
        update();
        Helpers.showSnackBar(msg: "Failed to sign in with Firebase", title: "Error!");
      }
    } catch (e) {
      isLoading = false;
      errorMessage = "Invalid OTP code: ${e is FirebaseAuthException ? (e.message ?? e.toString()) : e.toString()}";
      update();
      Helpers.showSnackBar(msg: "Invalid OTP code", title: "Error!");
    }
  }

  // ─────────────────────────────────────────────
  // GOOGLE SIGN-IN
  // ─────────────────────────────────────────────

  static const String _googleClientId =
      '91651925903-mmutsd2fu0qrt8u35b22ou6hnrbrnc9t.apps.googleusercontent.com';

  final GoogleSignIn _googleSignIn = GoogleSignIn(
    clientId: Platform.isIOS ? _googleClientId : null,
    serverClientId: _googleClientId,
  );

  Future<void> signInWithGoogle() async {
    isLoading = true;
    errorMessage = null;
    update();

    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        // User cancelled the picker
        isLoading = false;
        update();
        return;
      }

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      final OAuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      UserCredential userCredential =
          await _auth.signInWithCredential(credential);
      User? user = userCredential.user;
      if (user != null) {
        await loginOrRegisterWithGoogleBackend(user);
      } else {
        isLoading = false;
        errorMessage = "Google Sign-In failed. Please try again.";
        update();
      }
    } on PlatformException catch (e) {
      isLoading = false;
      if (e.code == 'sign_in_canceled') {
        debugPrint("Google Sign-In cancelled by user.");
      } else {
        errorMessage = "Google Sign-In: ${e.message ?? e.code}";
      }
      update();
    } on FirebaseAuthException catch (e) {
      isLoading = false;
      errorMessage = e.message ?? "Authentication failed.";
      update();
    } catch (e) {
      isLoading = false;
      errorMessage = "Google Sign-In failed: ${e.toString().split('Exception: ').last}";
      update();
    }
  }

  Future<void> loginOrRegisterWithGoogleBackend(User firebaseUser) async {
    String email = firebaseUser.email ?? '';
    String googleUid = firebaseUser.uid;
    String displayName = firebaseUser.displayName ?? 'Google User';
    List<String> nameParts = displayName.trim().split(' ');
    String firstName = nameParts.first;
    String lastName = nameParts.length > 1 ? nameParts.last : 'User';

    // Deterministic credentials derived from Google identity
    String cleanEmail = email.replaceAll(RegExp(r'[^a-zA-Z0-9]'), '_');
    String username = 'g_$cleanEmail';
    String password = 'Google_$googleUid';

    errorMessage = null;

    try {
      // 1. Try login first
      http.Response loginResp = await AuthRepo.login(data: {
        'username': username,
        'password': password,
        'type': 'user',
      });
      if (loginResp.statusCode == 200) {
        var d = jsonDecode(loginResp.body);
        if (d['status'] == 'success' && d['token'] != null) {
          HiveHelp.write(Keys.token, d['token']);
          Get.offAllNamed(RoutesName.bottomNavBar);
          isLoading = false;
          errorMessage = null;
          return;
        }
      }

      // 2. Register new user
      http.Response regResp = await AuthRepo.register(data: {
        'firstname': firstName,
        'lastname': lastName,
        'username': username,
        'email': email,
        'phone_code': phoneCode,
        'phone': '',
        'country': countryName,
        'country_code': countryCode,
        'password': password,
        'password_confirmation': password,
      });
      var regData = jsonDecode(regResp.body);
      if (regResp.statusCode == 200 && regData['status'] == 'success') {
        // Skip ApiStatus.checkStatus to avoid email verification redirect
        HiveHelp.write(Keys.token, regData['token']);
        Get.offAllNamed(RoutesName.bottomNavBar);
        isLoading = false;
        errorMessage = null;
        return;
      }

      // 3. Account exists — retry login
      http.Response retryResp = await AuthRepo.login(data: {
        'username': username,
        'password': password,
        'type': 'user',
      });
      if (retryResp.statusCode == 200) {
        var d = jsonDecode(retryResp.body);
        if (d['status'] == 'success' && d['token'] != null) {
          HiveHelp.write(Keys.token, d['token']);
          Get.offAllNamed(RoutesName.bottomNavBar);
          isLoading = false;
          errorMessage = null;
          return;
        }
      }

      errorMessage = 'Google Sign-In failed. Please try again.';
    } catch (e) {
      errorMessage = 'Google Sign-In error: ${e.toString()}';
    } finally {
      isLoading = false;
      update();
    }
  }

  // ─────────────────────────────────────────────

  Future loginOrRegisterWithBackend(String fullPhoneNumber, String firebaseUid) async {
    String cleanDigits = fullPhoneNumber.replaceAll(RegExp(r'\D'), '');
    String cleanDialCode = phoneCode.replaceAll('+', '');
    String rawPhone = cleanDigits;
    if (cleanDigits.startsWith(cleanDialCode)) {
      rawPhone = cleanDigits.substring(cleanDialCode.length);
    }

    String generatedUsername = "usr_$cleanDigits";
    String deterministicPassword = "UdharCard_$cleanDigits";
    String legacyPassword = "PaySecure_$cleanDigits";
    String firebasePassword = "Firebase_$firebaseUid";
    String phonePassword = "Phone_$cleanDigits";

    List<String> passwordCandidates = [
      deterministicPassword,
      legacyPassword,
      firebasePassword,
      phonePassword,
    ];

    List<String> usernameCandidates = [
      generatedUsername,
      rawPhone,
      fullPhoneNumber,
      "phone_$cleanDigits@udharcard.shop",
      "phone_$cleanDigits@paysecure.com",
    ];

    errorMessage = null;

    try {
      // 1. Attempt login with candidate combinations
      for (String u in usernameCandidates) {
        for (String p in passwordCandidates) {
          http.Response loginResponse = await AuthRepo.login(data: {
            "username": u,
            "password": p,
            "type": 'user',
          });

          if (loginResponse.statusCode == 200) {
            var loginData = jsonDecode(loginResponse.body);
            if (loginData['status'] == 'success' && loginData['token'] != null) {
              ApiStatus.checkStatus(loginData['status'], loginData['message']);
              HiveHelp.write(Keys.token, loginData['token']);
              Get.offAllNamed(RoutesName.bottomNavBar);
              clearSignInController();
              clearSignUpController();
              isOtpSent = false;
              phoneController.clear();
              otpController.clear();
              errorMessage = null;
              return;
            }
          }
        }
      }

      // 2. If login attempts failed, attempt user registration with deterministic password
      http.Response regResponse = await AuthRepo.register(data: {
        "firstname": "Phone",
        "lastname": "User",
        "username": generatedUsername,
        "email": "phone_$cleanDigits@udharcard.shop",
        "phone_code": phoneCode,
        "phone": rawPhone,
        "country": countryName,
        "country_code": countryCode,
        "password": deterministicPassword,
        "password_confirmation": deterministicPassword
      });

      var regData = jsonDecode(regResponse.body);
      if (regResponse.statusCode == 200 && regData['status'] == 'success') {
        // Don't call ApiStatus.checkStatus here — backend returns "Email Verification Required"
        // for new accounts, but since we're using phone-based OTP auth, we skip email verification.
        HiveHelp.write(Keys.token, regData['token']);
        Get.offAllNamed(RoutesName.bottomNavBar);
        clearSignInController();
        clearSignUpController();
        isOtpSent = false;
        phoneController.clear();
        otpController.clear();
        errorMessage = null;
        return;
      }


      // 3. If registration failed because user/phone/email already exists
      String regMsg = regData['message'] is List
          ? (regData['message'] as List).join('\n')
          : (regData['message']?.toString() ?? '');

      if (regMsg.toLowerCase().contains('taken') || regMsg.toLowerCase().contains('exist')) {
        // Account exists on backend. Perform retry login across candidates:
        for (String u in usernameCandidates) {
          for (String p in passwordCandidates) {
            http.Response retryLogin = await AuthRepo.login(data: {
              "username": u,
              "password": p,
              "type": 'user',
            });
            if (retryLogin.statusCode == 200) {
              var retryData = jsonDecode(retryLogin.body);
              if (retryData['status'] == 'success' && retryData['token'] != null) {
                ApiStatus.checkStatus(retryData['status'], retryData['message']);
                HiveHelp.write(Keys.token, retryData['token']);
                Get.offAllNamed(RoutesName.bottomNavBar);
                clearSignInController();
                clearSignUpController();
                isOtpSent = false;
                phoneController.clear();
                otpController.clear();
                errorMessage = null;
                return;
              }
            }
          }
        }
        errorMessage = "An account with this phone number already exists. Please log in using your credentials.";
      } else {
        errorMessage = regMsg.isNotEmpty ? regMsg : 'Backend registration failed';
      }
    } catch (e) {
      errorMessage = "Authentication error: $e";
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
    errorMessage = null;
  }

  Future login() async {
    isLoading = true;
    errorMessage = null;
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
        errorMessage = null;
        ApiStatus.checkStatus(data['status'], data['message']);
        if (isRemember == true) {
          HiveHelp.write(Keys.userName, userNameVal);
          HiveHelp.write(Keys.userPass, singInPassVal);
        }
        HiveHelp.write(Keys.token, data['token']);
        Get.offAllNamed(RoutesName.bottomNavBar);
        clearSignInController();
      } else {
        errorMessage = data['message']?.toString();
        ApiStatus.checkStatus(data['status'], data['message']);
      }
    } else {
      errorMessage = data['message']?.toString() ?? 'Login failed';
      Helpers.showSnackBar(msg: '${data['message']}', title: "Error!");
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
    errorMessage = null;
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

  @override
  void onClose() {
    stopResendTimer();
    phoneController.clear();
    otpController.clear();
    super.onClose();
  }
}
