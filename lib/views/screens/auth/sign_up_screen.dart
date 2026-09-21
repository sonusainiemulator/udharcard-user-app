import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:paysecure/utils/app_constants.dart';
import '../../../../config/app_colors.dart';
import '../../../config/dimensions.dart';
import '../../../controllers/auth_controller.dart';
import '../../../routes/routes_name.dart';
import '../../../themes/themes.dart';
import '../../../utils/services/helpers.dart';
import '../../../utils/services/localstorage/hive.dart';
import '../../../utils/services/localstorage/keys.dart';
import '../../widgets/app_button.dart';
import '../../widgets/custom_textfield.dart';
import '../../widgets/spacing.dart';
import 'package:country_code_picker/country_code_picker.dart';
import 'package:pinput/pinput.dart';
import 'package:smart_auth/smart_auth.dart';
import '../../../utils/services/sms_retriever_impl.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen>
    with SingleTickerProviderStateMixin {
  SmsRetrieverImpl? _smsRetrieverImpl;
  late AnimationController _animController;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;

  @override
  void initState() {
    super.initState();
    if (Platform.isAndroid) {
      _smsRetrieverImpl = SmsRetrieverImpl(SmartAuth.instance);
    }
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeAnim = CurvedAnimation(parent: _animController, curve: Curves.easeOut);
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.08),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _animController, curve: Curves.easeOut));
    _animController.forward();
  }

  @override
  void dispose() {
    _smsRetrieverImpl?.dispose();
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    TextTheme t = Theme.of(context).textTheme;
    AuthController controller = Get.find<AuthController>();
    var storedLanguage = HiveHelp.read(Keys.languageData) ?? {};
    final bool isDark = Get.isDarkMode;

    return GetBuilder<AuthController>(
      builder: (_) {
        return Scaffold(
          backgroundColor: isDark ? const Color(0xFF0F0F1A) : const Color(0xFFF7F8FC),
          body: Stack(
            children: [
              // ── Background gradient header ──
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: Container(
                  height: 220.h,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        AppColors.mainColor,
                        AppColors.mainColor.withValues(alpha: 0.75),
                      ],
                    ),
                  ),
                  child: Stack(
                    children: [
                      // decorative circles
                      Positioned(
                        top: -30,
                        right: -30,
                        child: Container(
                          width: 130.w,
                          height: 130.w,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white.withValues(alpha: 0.08),
                          ),
                        ),
                      ),
                      Positioned(
                        top: 50,
                        left: -20,
                        child: Container(
                          width: 80.w,
                          height: 80.w,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white.withValues(alpha: 0.06),
                          ),
                        ),
                      ),
                      // App logo centered in header
                      Positioned(
                        bottom: 16.h,
                        left: 0,
                        right: 0,
                        child: Center(
                          child: Image.asset(
                            "$rootImageDir/app_logo.png",
                            height: 70.h,
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // ── Bottom wave decoration ──
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Image.asset(
                  "$rootImageDir/shape.webp",
                  height: 120.h,
                  fit: BoxFit.cover,
                  color: AppColors.mainColor.withValues(alpha: 0.07),
                ),
              ),

              // ── Main content card ──
              Positioned(
                top: 195.h,
                left: 0,
                right: 0,
                bottom: 0,
                child: FadeTransition(
                  opacity: _fadeAnim,
                  child: SlideTransition(
                    position: _slideAnim,
                    child: Container(
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF161625) : Colors.white,
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(28.r),
                          topRight: Radius.circular(28.r),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.08),
                            blurRadius: 20,
                            offset: const Offset(0, -4),
                          ),
                        ],
                      ),
                      child: SingleChildScrollView(
                        padding: EdgeInsets.symmetric(
                          horizontal: 24.w,
                          vertical: 28.h,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Title
                            Text(
                              storedLanguage['Create Account'] ?? "Create Account",
                              style: t.titleMedium?.copyWith(
                                fontSize: 24.sp,
                                fontWeight: FontWeight.w700,
                                color: isDark ? Colors.white : const Color(0xFF1A1A2E),
                              ),
                            ),
                            VSpace(6.h),
                            Text(
                              storedLanguage['Sign up with your phone number to continue!'] ??
                                  "Sign up with your phone number to continue!",
                              style: t.displayMedium?.copyWith(
                                color: AppThemes.getParagraphColor(),
                                fontSize: 14.sp,
                              ),
                            ),
                            VSpace(28.h),

                            // ── Phone / OTP section ──
                            if (!controller.isOtpSent) ...[
                              // Phone input row
                              _buildPhoneInputRow(controller, t, storedLanguage, isDark),
                              if (controller.errorMessage != null &&
                                  controller.errorMessage!.isNotEmpty)
                                _buildInlineError(controller.errorMessage!, t),
                              VSpace(24.h),
                              // Send OTP button
                              Material(
                                color: Colors.transparent,
                                child: AppButton(
                                  text: storedLanguage['Send OTP'] ?? "Send OTP",
                                  isLoading: controller.isLoading,
                                  bgColor: controller.phoneController.text.isEmpty
                                      ? AppThemes.getInactiveColor()
                                      : AppColors.mainColor,
                                  onTap: controller.phoneController.text.isEmpty
                                      ? null
                                      : controller.isLoading
                                          ? null
                                          : () async {
                                              Helpers.hideKeyboard();
                                              String fullPhone =
                                                  "${controller.phoneCode}${controller.phoneController.text.trim()}";
                                              await controller.sendOtp(fullPhone);
                                            },
                                ),
                              ),
                            ] else ...[
                              _buildOtpInfoCard(controller, storedLanguage, t),
                              VSpace(24.h),
                              // OTP pin input
                              Center(
                                child: Directionality(
                                  textDirection: TextDirection.ltr,
                                  child: Pinput(
                                    length: 6,
                                    controller: controller.otpController,
                                    smsRetriever: Platform.isAndroid
                                        ? _smsRetrieverImpl
                                        : null,
                                    keyboardType: TextInputType.number,
                                    hapticFeedbackType:
                                        HapticFeedbackType.lightImpact,
                                    autofillHints: const [
                                      AutofillHints.oneTimeCode
                                    ],
                                    defaultPinTheme: PinTheme(
                                      width: 48.w,
                                      height: 54.h,
                                      textStyle: TextStyle(
                                        fontSize: 20.sp,
                                        fontWeight: FontWeight.w700,
                                        color: isDark
                                            ? AppColors.whiteColor
                                            : AppColors.black30,
                                      ),
                                      decoration: BoxDecoration(
                                        color: AppThemes.getFillColor(),
                                        borderRadius:
                                            BorderRadius.circular(12.r),
                                        border: Border.all(
                                          color:
                                              AppThemes.getSliderInactiveColor(),
                                          width: 1.2,
                                        ),
                                      ),
                                    ),
                                    focusedPinTheme: PinTheme(
                                      width: 48.w,
                                      height: 54.h,
                                      textStyle: TextStyle(
                                        fontSize: 20.sp,
                                        fontWeight: FontWeight.w700,
                                        color: isDark
                                            ? AppColors.whiteColor
                                            : AppColors.black30,
                                      ),
                                      decoration: BoxDecoration(
                                        color: AppColors.mainColor
                                            .withValues(alpha: 0.06),
                                        borderRadius:
                                            BorderRadius.circular(12.r),
                                        border: Border.all(
                                          color: AppColors.mainColor,
                                          width: 2,
                                        ),
                                      ),
                                    ),
                                    submittedPinTheme: PinTheme(
                                      width: 48.w,
                                      height: 54.h,
                                      textStyle: TextStyle(
                                        fontSize: 20.sp,
                                        fontWeight: FontWeight.w700,
                                        color: isDark
                                            ? AppColors.whiteColor
                                            : AppColors.black30,
                                      ),
                                      decoration: BoxDecoration(
                                        color: AppThemes.getFillColor(),
                                        borderRadius:
                                            BorderRadius.circular(12.r),
                                        border: Border.all(
                                          color: AppColors.mainColor
                                              .withValues(alpha: 0.6),
                                          width: 1.5,
                                        ),
                                      ),
                                    ),
                                    errorPinTheme: PinTheme(
                                      width: 48.w,
                                      height: 54.h,
                                      textStyle: TextStyle(
                                        fontSize: 20.sp,
                                        fontWeight: FontWeight.w700,
                                        color: const Color(0xFFDC2626),
                                      ),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFFEF2F2),
                                        borderRadius:
                                            BorderRadius.circular(12.r),
                                        border: Border.all(
                                          color: const Color(0xFFDC2626),
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
                                      await controller.verifyOtpAndLogin(
                                          pin, fullPhone);
                                    },
                                  ),
                                ),
                              ),
                              if (controller.errorMessage != null &&
                                  controller.errorMessage!.isNotEmpty)
                                _buildInlineError(controller.errorMessage!, t),
                              VSpace(24.h),
                              // Verify button
                              Material(
                                color: Colors.transparent,
                                child: AppButton(
                                  text: storedLanguage['Verify & Register'] ??
                                      "Verify & Register",
                                  isLoading: controller.isLoading,
                                  bgColor:
                                      controller.otpController.text.length < 6
                                          ? AppThemes.getInactiveColor()
                                          : AppColors.mainColor,
                                  onTap: controller.otpController.text.length < 6
                                      ? null
                                      : controller.isLoading
                                          ? null
                                          : () async {
                                              Helpers.hideKeyboard();
                                              String fullPhone =
                                                  "${controller.phoneCode}${controller.phoneController.text.trim()}";
                                              await controller
                                                  .verifyOtpAndLogin(
                                                controller.otpController.text
                                                    .trim(),
                                                fullPhone,
                                              );
                                            },
                                ),
                              ),
                              VSpace(16.h),
                              // Resend row
                              _buildResendRow(controller, storedLanguage, t),
                              VSpace(4.h),
                              // Change number
                              Align(
                                alignment: Alignment.center,
                                child: TextButton.icon(
                                  onPressed: () => controller.resetOtpState(),
                                  icon: Icon(
                                    Icons.edit_outlined,
                                    size: 15.sp,
                                    color: AppThemes.getHintColor(),
                                  ),
                                  label: Text(
                                    storedLanguage['Change Phone Number'] ??
                                        "Change Phone Number",
                                    style: t.bodyMedium?.copyWith(
                                      color: AppThemes.getHintColor(),
                                      fontSize: 13.sp,
                                    ),
                                  ),
                                ),
                              ),
                            ],

                            VSpace(24.h),
                            // OR divider
                            _buildOrDivider(t),
                            VSpace(16.h),
                            // Google Sign-In
                            _buildGoogleButton(controller, t),
                            VSpace(24.h),
                            // Already have account row
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  storedLanguage['Already have an account?'] ??
                                      "Already have an account?",
                                  style: t.bodyMedium?.copyWith(
                                    fontSize: 14.sp,
                                    color: AppThemes.getHintColor(),
                                  ),
                                ),
                                TextButton(
                                  onPressed: () =>
                                      Get.toNamed(RoutesName.loginScreen),
                                  child: Text(
                                    storedLanguage['Login'] ?? "Login",
                                    style: t.bodyMedium?.copyWith(
                                      fontSize: 14.sp,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.mainColor,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            VSpace(20.h),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPhoneInputRow(
    AuthController controller,
    TextTheme t,
    Map storedLanguage,
    bool isDark,
  ) {
    return Container(
      height: Dimensions.textFieldHeight,
      decoration: BoxDecoration(
        color: AppThemes.getFillColor(),
        borderRadius: Dimensions.kBorderRadius,
        border: Border.all(
          color: AppThemes.getSliderInactiveColor(),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          // ── Compact flag + dial code ──
          IntrinsicWidth(
            child: Container(
              decoration: BoxDecoration(
                border: Border(
                  right: BorderSide(
                    color: AppThemes.getSliderInactiveColor(),
                    width: 1,
                  ),
                ),
              ),
              child: CountryCodePicker(
                enabled: true,
                padding: EdgeInsets.symmetric(horizontal: 6.w),
                dialogBackgroundColor: AppThemes.getDarkCardColor(),
                dialogTextStyle: t.bodyMedium?.copyWith(fontSize: 15.sp),
                flagWidth: 20.w, // ← smaller flag
                textStyle: t.bodyMedium?.copyWith(
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w600,
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
            ),
          ),
          // ── Phone number input ──
          Expanded(
            child: CustomTextField(
              hintext: storedLanguage['Phone Number'] ?? "Phone Number",
              isPrefixIcon: false,
              keyboardType: TextInputType.phone,
              controller: controller.phoneController,
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
    );
  }

  Widget _buildResendRow(
    AuthController controller,
    Map storedLanguage,
    TextTheme t,
  ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (!controller.canResendOtp) ...[
          Container(
            padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 7.h),
            decoration: BoxDecoration(
              color: AppColors.mainColor.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(20.r),
              border: Border.all(
                color: AppColors.mainColor.withValues(alpha: 0.2),
                width: 1,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.timer_outlined,
                    size: 15.sp, color: AppColors.mainColor),
                HSpace(6.w),
                Text(
                  "Resend OTP in 00:${controller.resendOtpCountdown.toString().padLeft(2, '0')}",
                  style: t.bodyMedium?.copyWith(
                    color: AppColors.mainColor,
                    fontWeight: FontWeight.w600,
                    fontSize: 13.sp,
                  ),
                ),
              ],
            ),
          ),
        ] else ...[
          Text(
            storedLanguage["Didn't receive the code?"] ??
                "Didn't receive the code?",
            style: t.bodyMedium?.copyWith(
              color: AppThemes.getParagraphColor(),
              fontSize: 13.sp,
            ),
          ),
          TextButton(
            onPressed: controller.isLoading
                ? null
                : () async {
                    Helpers.hideKeyboard();
                    String fullPhone =
                        "${controller.phoneCode}${controller.phoneController.text.trim()}";
                    await controller.resendOtp(fullPhone);
                  },
            child: Text(
              storedLanguage['Resend OTP'] ?? "Resend OTP",
              style: t.bodyMedium?.copyWith(
                color: AppColors.mainColor,
                fontWeight: FontWeight.w700,
                fontSize: 13.sp,
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildOrDivider(TextTheme t) {
    return Row(
      children: [
        Expanded(
          child: Divider(
            color: AppThemes.getHintColor().withValues(alpha: 0.25),
            thickness: 1,
          ),
        ),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 12.w),
          child: Text(
            "OR",
            style: t.bodyMedium?.copyWith(
              color: AppThemes.getHintColor(),
              fontWeight: FontWeight.w500,
              fontSize: 12.sp,
              letterSpacing: 1.2,
            ),
          ),
        ),
        Expanded(
          child: Divider(
            color: AppThemes.getHintColor().withValues(alpha: 0.25),
            thickness: 1,
          ),
        ),
      ],
    );
  }

  Widget _buildGoogleButton(AuthController controller, TextTheme t) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: controller.isLoading ? null : () => controller.signInWithGoogle(),
        borderRadius: BorderRadius.circular(14.r),
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(vertical: 14.h, horizontal: 20.w),
          decoration: BoxDecoration(
            color: Get.isDarkMode ? const Color(0xFF1E1E30) : Colors.white,
            borderRadius: BorderRadius.circular(14.r),
            border: Border.all(
              color: Get.isDarkMode
                  ? Colors.white.withValues(alpha: 0.1)
                  : const Color(0xFFE2E8F0),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
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
                  size: 22.sp,
                  color: const Color(0xFF4285F4),
                ),
              ),
              SizedBox(width: 10.w),
              Text(
                "Continue with Google",
                style: t.bodyMedium?.copyWith(
                  fontSize: 15.sp,
                  fontWeight: FontWeight.w600,
                  color: Get.isDarkMode
                      ? Colors.white
                      : const Color(0xFF1A1A2E),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOtpInfoCard(
    AuthController controller,
    Map storedLanguage,
    TextTheme t,
  ) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: AppColors.mainColor.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: AppColors.mainColor.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 36.w,
            height: 36.w,
            decoration: BoxDecoration(
              color: AppColors.mainColor.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.mark_email_read_outlined,
              color: AppColors.mainColor,
              size: 18.sp,
            ),
          ),
          HSpace(12.w),
          Expanded(
            child: Text.rich(
              TextSpan(
                style: t.bodyMedium?.copyWith(
                  color: AppThemes.getParagraphColor(),
                  fontSize: 13.sp,
                ),
                children: [
                  TextSpan(
                    text:
                        "${storedLanguage['Verification code sent to'] ?? 'Verification code sent to'} ",
                  ),
                  TextSpan(
                    text:
                        "${controller.phoneCode} ${controller.phoneController.text}",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: AppColors.mainColor,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInlineError(String errorText, TextTheme t) {
    return Container(
      width: double.infinity,
      margin: EdgeInsets.only(top: 14.h),
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: const Color(0xFFFEF2F2),
        borderRadius: BorderRadius.circular(10.r),
        border: Border.all(color: const Color(0xFFFCA5A5), width: 1),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.only(top: 2.h),
            child: Icon(
              Icons.error_outline_rounded,
              color: const Color(0xFFDC2626),
              size: 17.sp,
            ),
          ),
          HSpace(10.w),
          Expanded(
            child: Text(
              errorText,
              style: t.bodyMedium?.copyWith(
                color: const Color(0xFF991B1B),
                fontWeight: FontWeight.w500,
                fontSize: 13.sp,
                height: 1.3,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
