import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:country_code_picker/country_code_picker.dart';
import 'package:pinput/pinput.dart';
import 'package:smart_auth/smart_auth.dart';
import 'package:get/get.dart';

import '../../../../config/app_colors.dart';
import '../../../controllers/auth_controller.dart';
import '../../../routes/routes_name.dart';
import '../../../themes/themes.dart';
import '../../../utils/app_constants.dart';
import '../../../utils/services/helpers.dart';
import '../../../utils/services/localstorage/hive.dart';
import '../../../utils/services/localstorage/keys.dart';
import '../../../utils/services/sms_retriever_impl.dart';
import '../../widgets/auth_wave_background.dart';
import '../../widgets/spacing.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  FocusNode node = FocusNode();
  SmsRetrieverImpl? _smsRetrieverImpl;

  @override
  void initState() {
    if (Platform.isAndroid) {
      _smsRetrieverImpl = SmsRetrieverImpl(SmartAuth.instance);
    }
    node.addListener(() {
      setState(() {});
    });
    super.initState();
  }

  @override
  void dispose() {
    _smsRetrieverImpl?.dispose();
    node.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var storedLanguage = HiveHelp.read(Keys.languageData) ?? {};
    AuthController controller = Get.find<AuthController>();
    final bool isDark = Get.isDarkMode;

    // Remember me check
    if (HiveHelp.read(Keys.userName) != null &&
        HiveHelp.read(Keys.isRemember) != null) {
      if (HiveHelp.read(Keys.isRemember) == true) {
        if (controller.phoneController.text.isEmpty) {
          controller.phoneController.text = HiveHelp.read(Keys.userName);
        }
      }
    }
    if (HiveHelp.read(Keys.isRemember) != null) {
      controller.isRemember = HiveHelp.read(Keys.isRemember);
    }

    return GetBuilder<AuthController>(
      builder: (_) {
        return Scaffold(
          backgroundColor: isDark ? AppColors.darkBgColor : Colors.white,
          body: Stack(
            children: [
              // Bottom Wavy Background
              const Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: AuthWaveBackground(height: 120),
              ),
              SafeArea(
                child: SingleChildScrollView(
                  padding: EdgeInsets.symmetric(horizontal: 24.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Top spacing or Back Button for OTP state
                      if (controller.isOtpSent)
                        Align(
                          alignment: Alignment.centerLeft,
                          child: IconButton(
                            padding: EdgeInsets.zero,
                            alignment: Alignment.centerLeft,
                            icon: Icon(
                              Icons.arrow_back_ios_new_rounded,
                              size: 22.sp,
                              color: isDark ? Colors.white : AppColors.textDarkColor,
                            ),
                            onPressed: () {
                              controller.resetOtpState();
                            },
                          ),
                        )
                      else
                        VSpace(30.h),

                      if (!controller.isOtpSent) ...[
                        // ─── Screen 1: Login Screen ───────────────────────
                        VSpace(10.h),
                        Center(
                          child: Image.asset(
                            "$rootImageDir/app_logo.png",
                            height: 85.h,
                            fit: BoxFit.contain,
                          ),
                        ),
                        VSpace(28.h),
                        Text(
                          storedLanguage['Welcome Back!'] ?? "Welcome Back!",
                          style: TextStyle(
                            fontSize: 26.sp,
                            fontWeight: FontWeight.w700,
                            color: isDark ? Colors.white : AppColors.textDarkColor,
                          ),
                        ),
                        VSpace(8.h),
                        Text(
                          storedLanguage['Log in to continue to UdharCard'] ??
                              "Log in to continue to UdharCard",
                          style: TextStyle(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w400,
                            color: isDark ? Colors.white70 : AppColors.textMutedColor,
                          ),
                        ),
                        VSpace(32.h),

                        // Phone input card with flag and code
                        Container(
                          height: 54.h,
                          decoration: BoxDecoration(
                            color: isDark ? AppColors.darkCardColor : Colors.white,
                            borderRadius: BorderRadius.circular(12.r),
                            border: Border.all(
                              color: isDark ? Colors.white24 : AppColors.cardBorderColor,
                              width: 1.2,
                            ),
                          ),
                          child: Row(
                            children: [
                              CountryCodePicker(
                                enabled: true,
                                padding: EdgeInsets.symmetric(horizontal: 8.w),
                                dialogBackgroundColor: AppThemes.getDarkCardColor(),
                                dialogTextStyle: TextStyle(
                                  fontSize: 15.sp,
                                  color: isDark ? Colors.white : Colors.black,
                                ),
                                flagWidth: 26.w,
                                textStyle: TextStyle(
                                  fontSize: 15.sp,
                                  fontWeight: FontWeight.w600,
                                  color: isDark ? Colors.white : AppColors.textDarkColor,
                                ),
                                onChanged: (CountryCode countryCode) {
                                  controller.countryCode = countryCode.code!;
                                  controller.phoneCode = countryCode.dialCode!;
                                  controller.countryName = countryCode.name!;
                                  controller.errorMessage = null;
                                  controller.update();
                                },
                                initialSelection: controller.countryCode,
                                showCountryOnly: false,
                                showOnlyCountryWhenClosed: false,
                                alignLeft: false,
                              ),
                              Container(
                                width: 1,
                                height: 28.h,
                                color: isDark ? Colors.white24 : AppColors.cardBorderColor,
                              ),
                              HSpace(12.w),
                              Expanded(
                                child: TextField(
                                  controller: controller.phoneController,
                                  keyboardType: TextInputType.phone,
                                  style: TextStyle(
                                    fontSize: 15.sp,
                                    fontWeight: FontWeight.w500,
                                    color: isDark ? Colors.white : AppColors.textDarkColor,
                                  ),
                                  decoration: InputDecoration(
                                    border: InputBorder.none,
                                    enabledBorder: InputBorder.none,
                                    focusedBorder: InputBorder.none,
                                    hintText: storedLanguage['Mobile Number'] ?? "8221825824",
                                    hintStyle: TextStyle(
                                      color: AppColors.textFieldHintColor,
                                      fontSize: 15.sp,
                                    ),
                                    contentPadding: EdgeInsets.zero,
                                  ),
                                  onChanged: (v) {
                                    if (controller.errorMessage != null) {
                                      controller.errorMessage = null;
                                    }
                                    controller.update();
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),

                        VSpace(16.h),
                        // Remember Me Checkbox
                        Row(
                          children: [
                            SizedBox(
                              width: 22.w,
                              height: 22.w,
                              child: Checkbox(
                                activeColor: AppColors.mainColor,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(4.r),
                                ),
                                side: BorderSide(
                                  color: isDark ? Colors.white38 : AppColors.cardBorderColor,
                                  width: 1.5,
                                ),
                                value: controller.isRemember,
                                onChanged: (v) {
                                  controller.isRemember = v ?? false;
                                  HiveHelp.write(Keys.isRemember, controller.isRemember);
                                  if (controller.isRemember) {
                                    HiveHelp.write(Keys.userName, controller.phoneController.text);
                                  } else {
                                    HiveHelp.remove(Keys.userName);
                                  }
                                  controller.update();
                                },
                              ),
                            ),
                            HSpace(8.w),
                            Text(
                              storedLanguage['Remember me'] ?? "Remember me",
                              style: TextStyle(
                                fontSize: 13.sp,
                                fontWeight: FontWeight.w400,
                                color: isDark ? Colors.white70 : const Color(0xff475569),
                              ),
                            ),
                          ],
                        ),

                        // Error Banner (matching screenshot error box)
                        if (controller.errorMessage != null &&
                            controller.errorMessage!.isNotEmpty)
                          _buildErrorAlert(controller.errorMessage!),

                        VSpace(24.h),

                        // Send OTP Button
                        SizedBox(
                          width: double.infinity,
                          height: 52.h,
                          child: ElevatedButton(
                            onPressed: (controller.phoneController.text.isEmpty ||
                                    controller.isRateLimited ||
                                    controller.isLoading)
                                ? null
                                : () async {
                                    Helpers.hideKeyboard();
                                    if (controller.isRemember) {
                                      HiveHelp.write(Keys.userName, controller.phoneController.text);
                                    }
                                    String fullPhone =
                                        "${controller.phoneCode}${controller.phoneController.text.trim()}";
                                    await controller.sendOtp(fullPhone);
                                  },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.mainColor,
                              disabledBackgroundColor: AppColors.mainColor.withValues(alpha: 0.5),
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14.r),
                              ),
                            ),
                            child: controller.isLoading
                                ? SizedBox(
                                    height: 22.h,
                                    width: 22.h,
                                    child: const CircularProgressIndicator(
                                      strokeWidth: 2.2,
                                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                    ),
                                  )
                                : Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        controller.isRateLimited
                                            ? 'Try again in ${controller.rateLimitRemainingText}'
                                            : (storedLanguage['Send OTP'] ?? "Send OTP"),
                                        style: TextStyle(
                                          fontSize: 16.sp,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.white,
                                        ),
                                      ),
                                      HSpace(8.w),
                                      Icon(
                                        Icons.arrow_forward_rounded,
                                        size: 18.sp,
                                        color: Colors.white,
                                      ),
                                    ],
                                  ),
                          ),
                        ),

                        VSpace(20.h),
                        // OR Divider
                        Row(
                          children: [
                            Expanded(
                              child: Divider(
                                color: isDark ? Colors.white24 : AppColors.cardBorderColor,
                                thickness: 1,
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 14.w),
                              child: Text(
                                "OR",
                                style: TextStyle(
                                  color: AppColors.textMutedColor,
                                  fontSize: 13.sp,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                            Expanded(
                              child: Divider(
                                color: isDark ? Colors.white24 : AppColors.cardBorderColor,
                                thickness: 1,
                              ),
                            ),
                          ],
                        ),

                        VSpace(18.h),
                        // Continue with Google Button
                        InkWell(
                          onTap: controller.isLoading
                              ? null
                              : () => controller.signInWithGoogle(),
                          borderRadius: BorderRadius.circular(14.r),
                          child: Container(
                            height: 52.h,
                            decoration: BoxDecoration(
                              color: isDark ? AppColors.darkCardColor : Colors.white,
                              borderRadius: BorderRadius.circular(14.r),
                              border: Border.all(
                                color: isDark ? Colors.white24 : AppColors.cardBorderColor,
                                width: 1.2,
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Image.network(
                                  'https://www.google.com/favicon.ico',
                                  height: 20.h,
                                  width: 20.h,
                                  errorBuilder: (_, __, ___) => Icon(
                                    Icons.g_mobiledata_rounded,
                                    size: 26.sp,
                                    color: const Color(0xFF4285F4),
                                  ),
                                ),
                                HSpace(10.w),
                                Text(
                                  storedLanguage['Continue with Google'] ?? "Continue with Google",
                                  style: TextStyle(
                                    fontSize: 15.sp,
                                    fontWeight: FontWeight.w600,
                                    color: isDark ? Colors.white : AppColors.textDarkColor,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        VSpace(20.h),
                        // Don't have an account? Sign Up
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              storedLanguage["Don't have an account?"] ??
                                  "Don't have an account?",
                              style: TextStyle(
                                fontSize: 14.sp,
                                color: isDark ? Colors.white70 : AppColors.textMutedColor,
                              ),
                            ),
                            TextButton(
                              onPressed: () {
                                Get.toNamed(RoutesName.signUpScreen);
                              },
                              child: Text(
                                storedLanguage['Sign Up'] ?? "Sign Up",
                                style: TextStyle(
                                  fontSize: 14.sp,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.mainColor,
                                ),
                              ),
                            ),
                          ],
                        ),

                        VSpace(16.h),
                        // Trusted by 10,000+ Users Badge
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                          decoration: BoxDecoration(
                            color: AppColors.lightBlueTint,
                            borderRadius: BorderRadius.circular(20.r),
                            border: Border.all(
                              color: AppColors.mainColor.withValues(alpha: 0.15),
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.verified_user_rounded,
                                size: 16.sp,
                                color: AppColors.mainColor,
                              ),
                              HSpace(6.w),
                              Text(
                                "Trusted by 10,000+ Users",
                                style: TextStyle(
                                  fontSize: 12.sp,
                                  fontWeight: FontWeight.w600,
                                  color: const Color(0xff1E40AF),
                                ),
                              ),
                            ],
                          ),
                        ),
                        VSpace(30.h),
                      ] else ...[
                        // ─── Screen 2: OTP Verification ───────────────────
                        VSpace(12.h),
                        // 3D OTP Letter Envelope Graphic
                        Center(
                          child: Image.asset(
                            "$rootImageDir/otp_verify_badge.png",
                            height: 110.h,
                            fit: BoxFit.contain,
                          ),
                        ),
                        VSpace(24.h),
                        Text(
                          storedLanguage['Verify OTP'] ?? "Verify OTP",
                          style: TextStyle(
                            fontSize: 26.sp,
                            fontWeight: FontWeight.w700,
                            color: isDark ? Colors.white : AppColors.textDarkColor,
                          ),
                        ),
                        VSpace(8.h),
                        Text.rich(
                          TextSpan(
                            style: TextStyle(
                              fontSize: 14.sp,
                              color: isDark ? Colors.white70 : AppColors.textMutedColor,
                              height: 1.4,
                            ),
                            children: [
                              TextSpan(
                                text: "${storedLanguage['We have sent a 6-digit OTP to'] ?? 'We have sent a 6-digit OTP to'}\n",
                              ),
                              TextSpan(
                                text: "${controller.phoneCode} ${controller.phoneController.text}",
                                style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  color: isDark ? Colors.white : AppColors.textDarkColor,
                                ),
                              ),
                            ],
                          ),
                          textAlign: TextAlign.center,
                        ),
                        VSpace(30.h),

                        // Pinput 6-digit boxes
                        Directionality(
                          textDirection: TextDirection.ltr,
                          child: Pinput(
                            length: 6,
                            controller: controller.otpController,
                            smsRetriever: Platform.isAndroid ? _smsRetrieverImpl : null,
                            keyboardType: TextInputType.number,
                            autofillHints: const [AutofillHints.oneTimeCode],
                            defaultPinTheme: PinTheme(
                              width: 50.w,
                              height: 54.h,
                              textStyle: TextStyle(
                                fontSize: 22.sp,
                                fontWeight: FontWeight.w700,
                                color: isDark ? Colors.white : AppColors.textDarkColor,
                              ),
                              decoration: BoxDecoration(
                                color: isDark ? AppColors.darkCardColor : Colors.white,
                                borderRadius: BorderRadius.circular(12.r),
                                border: Border.all(
                                  color: isDark ? Colors.white24 : AppColors.cardBorderColor,
                                  width: 1.3,
                                ),
                              ),
                            ),
                            focusedPinTheme: PinTheme(
                              width: 50.w,
                              height: 54.h,
                              textStyle: TextStyle(
                                fontSize: 22.sp,
                                fontWeight: FontWeight.w700,
                                color: isDark ? Colors.white : AppColors.textDarkColor,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.lightBlueTint,
                                borderRadius: BorderRadius.circular(12.r),
                                border: Border.all(
                                  color: AppColors.mainColor,
                                  width: 2,
                                ),
                              ),
                            ),
                            submittedPinTheme: PinTheme(
                              width: 50.w,
                              height: 54.h,
                              textStyle: TextStyle(
                                fontSize: 22.sp,
                                fontWeight: FontWeight.w700,
                                color: isDark ? Colors.white : AppColors.textDarkColor,
                              ),
                              decoration: BoxDecoration(
                                color: isDark ? AppColors.darkCardColor : Colors.white,
                                borderRadius: BorderRadius.circular(12.r),
                                border: Border.all(
                                  color: AppColors.mainColor.withValues(alpha: 0.6),
                                  width: 1.5,
                                ),
                              ),
                            ),
                            onChanged: (v) {
                              if (controller.errorMessage != null) {
                                controller.errorMessage = null;
                              }
                              controller.update();
                            },
                            onCompleted: (pin) async {
                              Helpers.hideKeyboard();
                              String fullPhone =
                                  "${controller.phoneCode}${controller.phoneController.text.trim()}";
                              await controller.verifyOtpAndLogin(pin, fullPhone);
                            },
                          ),
                        ),

                        if (controller.errorMessage != null &&
                            controller.errorMessage!.isNotEmpty)
                          _buildErrorAlert(controller.errorMessage!),

                        VSpace(22.h),

                        // Countdown / Resend OTP
                        if (!controller.canResendOtp)
                          Text(
                            "Didn't receive OTP? Resend in 00:${controller.resendOtpCountdown.toString().padLeft(2, '0')}",
                            style: TextStyle(
                              fontSize: 13.sp,
                              fontWeight: FontWeight.w500,
                              color: isDark ? Colors.white70 : AppColors.textMutedColor,
                            ),
                          )
                        else
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                "Didn't receive OTP? ",
                                style: TextStyle(
                                  fontSize: 13.sp,
                                  color: isDark ? Colors.white70 : AppColors.textMutedColor,
                                ),
                              ),
                              GestureDetector(
                                onTap: controller.isLoading
                                    ? null
                                    : () async {
                                        Helpers.hideKeyboard();
                                        String fullPhone =
                                            "${controller.phoneCode}${controller.phoneController.text.trim()}";
                                        await controller.resendOtp(fullPhone);
                                      },
                                child: Text(
                                  "Resend OTP",
                                  style: TextStyle(
                                    fontSize: 13.sp,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.mainColor,
                                  ),
                                ),
                              ),
                            ],
                          ),

                        VSpace(26.h),

                        // Verify OTP Button
                        SizedBox(
                          width: double.infinity,
                          height: 52.h,
                          child: ElevatedButton(
                            onPressed: (controller.otpController.text.length < 6 ||
                                    controller.isLoading)
                                ? null
                                : () async {
                                    Helpers.hideKeyboard();
                                    String fullPhone =
                                        "${controller.phoneCode}${controller.phoneController.text.trim()}";
                                    await controller.verifyOtpAndLogin(
                                      controller.otpController.text.trim(),
                                      fullPhone,
                                    );
                                  },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.mainColor,
                              disabledBackgroundColor: AppColors.mainColor.withValues(alpha: 0.5),
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14.r),
                              ),
                            ),
                            child: controller.isLoading
                                ? SizedBox(
                                    height: 22.h,
                                    width: 22.h,
                                    child: const CircularProgressIndicator(
                                      strokeWidth: 2.2,
                                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                    ),
                                  )
                                : Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        storedLanguage['Verify OTP'] ?? "Verify OTP",
                                        style: TextStyle(
                                          fontSize: 16.sp,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.white,
                                        ),
                                      ),
                                      HSpace(8.w),
                                      Icon(
                                        Icons.arrow_forward_rounded,
                                        size: 18.sp,
                                        color: Colors.white,
                                      ),
                                    ],
                                  ),
                          ),
                        ),

                        VSpace(16.h),
                        // Change Mobile Number Text Button
                        TextButton(
                          onPressed: () {
                            controller.resetOtpState();
                          },
                          child: Text(
                            storedLanguage['Change Mobile Number'] ?? "Change Mobile Number",
                            style: TextStyle(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w600,
                              color: AppColors.mainColor,
                            ),
                          ),
                        ),
                        VSpace(30.h),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildErrorAlert(String errorText) {
    return Container(
      width: double.infinity,
      margin: EdgeInsets.only(top: 14.h),
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
      decoration: BoxDecoration(
        color: const Color(0xFFFEF2F2),
        borderRadius: BorderRadius.circular(10.r),
        border: Border.all(
          color: const Color(0xFFFCA5A5),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.error_outline_rounded,
            color: const Color(0xFFDC2626),
            size: 18.sp,
          ),
          HSpace(10.w),
          Expanded(
            child: Text(
              errorText,
              style: TextStyle(
                color: const Color(0xFF991B1B),
                fontWeight: FontWeight.w500,
                fontSize: 13.sp,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
