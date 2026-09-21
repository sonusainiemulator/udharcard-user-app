import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:paysecure/utils/app_constants.dart';
import 'package:paysecure/utils/services/localstorage/hive.dart';
import 'package:paysecure/views/widgets/custom_textfield.dart';
import 'package:get/get.dart';
import '../../../../config/app_colors.dart';
import '../../../config/dimensions.dart';
import '../../../controllers/auth_controller.dart';
import '../../../routes/routes_name.dart';
import '../../../themes/themes.dart';
import '../../../utils/services/helpers.dart';
import '../../../utils/services/localstorage/keys.dart';
import '../../widgets/app_button.dart';
import '../../widgets/spacing.dart';
import 'package:country_code_picker/country_code_picker.dart';
import 'package:pinput/pinput.dart';
import 'package:smart_auth/smart_auth.dart';
import '../../../utils/services/sms_retriever_impl.dart';

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
    TextTheme t = Theme.of(context).textTheme;
    //--------------REMEMBER ME----------------
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
          body: Container(
            height: Dimensions.screenHeight,
            width: Dimensions.screenWidth,
            child: Stack(
              children: [
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Image.asset(
                    "$rootImageDir/shape.webp",
                    height: 153.h,
                    fit: BoxFit.cover,
                    color: AppColors.mainColor.withValues(alpha: .1),
                  ),
                ),
                Padding(
                  padding: Dimensions.kDefaultPadding,
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        VSpace(60.h),
                        Center(
                          child: Image.asset(
                            "$rootImageDir/app_logo.png",
                            height: 120.h,
                            fit: BoxFit.contain,
                          ),
                        ),
                        VSpace(30.h),
                        Text(
                          storedLanguage['Log In'] ?? "Log In",
                          style: t.titleLarge?.copyWith(
                            fontWeight: FontWeight.w500,
                            fontSize: 30.sp,
                          ),
                        ),
                        VSpace(12.h),
                        Text(
                          storedLanguage['Hello there, log in to continue!'] ??
                              "Hello there, log in to continue!",
                          style: t.displayMedium?.copyWith(
                            color: AppThemes.getParagraphColor(),
                          ),
                        ),
                        VSpace(40.h),
                        if (!controller.isOtpSent) ...[
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                height: Dimensions.textFieldHeight,
                                decoration: BoxDecoration(
                                  borderRadius: Dimensions.kBorderRadius,
                                  border: Border.all(
                                    color: AppThemes.getSliderInactiveColor(),
                                    width: 1,
                                  ),
                                ),
                                child: CountryCodePicker(
                                  enabled: true,
                                  padding: EdgeInsets.zero,
                                  dialogBackgroundColor:
                                      AppThemes.getDarkCardColor(),
                                  dialogTextStyle: t.bodyMedium?.copyWith(
                                    fontSize: 16.sp,
                                  ),
                                  flagWidth: 29.w,
                                  textStyle: t.displayMedium,
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
                              HSpace(16.w),
                              Expanded(
                                child: CustomTextField(
                                  hintext:
                                      storedLanguage['Phone Number'] ??
                                      "Phone Number",
                                  isPrefixIcon: true,
                                  prefixIcon: 'call',
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
                          VSpace(24.h),
                          Row(
                            children: [
                              Transform.scale(
                                scale: .82,
                                child: Checkbox(
                                  checkColor: AppColors.whiteColor,
                                  activeColor: AppColors.mainColor,
                                  visualDensity: const VisualDensity(
                                    horizontal: -4.0,
                                    vertical: -4.0,
                                  ),
                                  side: BorderSide(
                                    color: AppThemes.getHintColor(),
                                  ),
                                  value: controller.isRemember,
                                  onChanged: (v) {
                                    controller.isRemember = v!;
                                    HiveHelp.write(Keys.isRemember, v);
                                    if (v) {
                                      HiveHelp.write(Keys.userName, controller.phoneController.text);
                                    } else {
                                      HiveHelp.remove(Keys.userName);
                                    }
                                    controller.update();
                                  },
                                ),
                              ),
                              HSpace(5.w),
                              Text(
                                storedLanguage['Remember me'] ?? "Remember me",
                                style: t.bodySmall?.copyWith(
                                  fontSize: 16.sp,
                                  color: Get.isDarkMode
                                      ? AppColors.whiteColor
                                      : AppColors.black30,
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                            ],
                          ),
                          if (controller.errorMessage != null &&
                              controller.errorMessage!.isNotEmpty)
                            _buildInlineError(controller.errorMessage!, t),
                          VSpace(32.h),
                          Material(
                            color: Colors.transparent,
                            child: AppButton(
                              text: controller.isRateLimited
                                  ? 'Try again in ${controller.rateLimitRemainingText}'
                                  : (storedLanguage['Send OTP'] ?? "Send OTP"),
                              isLoading: controller.isLoading ? true : false,
                              bgColor: (controller.phoneController.text.isEmpty || controller.isRateLimited)
                                  ? AppThemes.getInactiveColor()
                                  : AppColors.mainColor,
                              onTap: (controller.phoneController.text.isEmpty || controller.isRateLimited)
                                  ? null
                                  : controller.isLoading
                                  ? null
                                  : () async {
                                      Helpers.hideKeyboard();
                                      if (controller.isRemember) {
                                        HiveHelp.write(Keys.userName, controller.phoneController.text);
                                      }
                                      String fullPhone = "${controller.phoneCode}${controller.phoneController.text.trim()}";
                                      await controller.sendOtp(fullPhone);
                                    },
                            ),
                          ),
                        ] else ...[
                          _buildOtpInfoCard(controller, storedLanguage, t),
                          VSpace(28.h),
                          Center(
                            child: Directionality(
                              textDirection: TextDirection.ltr,
                              child: Pinput(
                                length: 6,
                                controller: controller.otpController,
                                smsRetriever: Platform.isAndroid ? _smsRetrieverImpl : null,
                                keyboardType: TextInputType.number,
                                hapticFeedbackType: HapticFeedbackType.lightImpact,
                                autofillHints: const [AutofillHints.oneTimeCode],
                                defaultPinTheme: PinTheme(
                                  width: 48.w,
                                  height: 54.h,
                                  textStyle: TextStyle(
                                    fontSize: 20.sp,
                                    fontWeight: FontWeight.w700,
                                    color: Get.isDarkMode
                                        ? AppColors.whiteColor
                                        : AppColors.black30,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppThemes.getFillColor(),
                                    borderRadius: BorderRadius.circular(12.r),
                                    border: Border.all(
                                      color: AppThemes.getSliderInactiveColor(),
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
                                    color: Get.isDarkMode
                                        ? AppColors.whiteColor
                                        : AppColors.black30,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppColors.mainColor
                                        .withValues(alpha: 0.05),
                                    borderRadius: BorderRadius.circular(12.r),
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
                                    color: Get.isDarkMode
                                        ? AppColors.whiteColor
                                        : AppColors.black30,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppThemes.getFillColor(),
                                    borderRadius: BorderRadius.circular(12.r),
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
                                    borderRadius: BorderRadius.circular(12.r),
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
                                    pin,
                                    fullPhone,
                                  );
                                },
                              ),
                            ),
                          ),
                          if (controller.errorMessage != null &&
                              controller.errorMessage!.isNotEmpty)
                            _buildInlineError(controller.errorMessage!, t),
                          VSpace(28.h),
                          Material(
                            color: Colors.transparent,
                            child: AppButton(
                              text: storedLanguage['Verify & Login'] ??
                                  "Verify & Login",
                              isLoading: controller.isLoading ? true : false,
                              bgColor: controller.otpController.text.length < 6
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
                                          await controller.verifyOtpAndLogin(
                                            controller.otpController.text.trim(),
                                            fullPhone,
                                          );
                                        },
                            ),
                          ),
                          VSpace(20.h),
                          // ───── Resend OTP Countdown & Action ─────
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              if (!controller.canResendOtp) ...[
                                Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 14.w,
                                    vertical: 7.h,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppColors.mainColor
                                        .withValues(alpha: 0.08),
                                    borderRadius: BorderRadius.circular(20.r),
                                    border: Border.all(
                                      color: AppColors.mainColor
                                          .withValues(alpha: 0.2),
                                      width: 1,
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.timer_outlined,
                                        size: 16.sp,
                                        color: AppColors.mainColor,
                                      ),
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
                                      fontSize: 14.sp,
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                          VSpace(8.h),
                          Align(
                            alignment: Alignment.center,
                            child: TextButton.icon(
                              onPressed: () {
                                controller.resetOtpState();
                              },
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
                        VSpace(32.h),
                        // ───── OR Divider ─────
                        Row(
                          children: [
                            Expanded(
                              child: Divider(
                                color: AppThemes.getHintColor().withValues(alpha: 0.3),
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
                                  fontSize: 13.sp,
                                ),
                              ),
                            ),
                            Expanded(
                              child: Divider(
                                color: AppThemes.getHintColor().withValues(alpha: 0.3),
                                thickness: 1,
                              ),
                            ),
                          ],
                        ),
                        VSpace(16.h),
                        // ───── Google Sign-In Button ─────
                        Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: controller.isLoading
                                ? null
                                : () => controller.signInWithGoogle(),
                            borderRadius: BorderRadius.circular(12.r),
                            child: Container(
                              width: double.infinity,
                              padding: EdgeInsets.symmetric(
                                vertical: 14.h,
                                horizontal: 20.w,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12.r),
                                border: Border.all(
                                  color: const Color(0xFFE2E8F0),
                                  width: 1.5,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.05),
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Image.network(
                                    'https://www.google.com/favicon.ico',
                                    height: 22.h,
                                    width: 22.h,
                                    errorBuilder: (_, __, ___) => Icon(
                                      Icons.g_mobiledata_rounded,
                                      size: 24.sp,
                                      color: const Color(0xFF4285F4),
                                    ),
                                  ),
                                  SizedBox(width: 12.w),
                                  Text(
                                    "Continue with Google",
                                    style: t.bodyMedium?.copyWith(
                                      fontSize: 15.sp,
                                      fontWeight: FontWeight.w600,
                                      color: const Color(0xFF1A1A2E),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        VSpace(28.h),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              storedLanguage["Don't have an account?"] ??
                                  "Don't have an account?",
                              style: t.displayMedium?.copyWith(
                                fontSize: 18.sp,
                                color: AppThemes.getHintColor(),
                              ),
                            ),
                            TextButton(
                              onPressed: () {
                                Get.toNamed(RoutesName.signUpScreen);
                              },
                              child: Text(
                                storedLanguage['Sign Up'] ?? "Sign Up",
                                style: t.displayMedium?.copyWith(
                                  fontSize: 18.sp,
                                ),
                              ),
                            ),
                          ],
                        ),
                        VSpace(40.h),

                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildOtpInfoCard(AuthController controller, Map storedLanguage, TextTheme t) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: AppColors.mainColor.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(10.r),
        border: Border.all(
          color: AppColors.mainColor.withValues(alpha: 0.25),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.mark_email_read_outlined,
            color: AppColors.mainColor,
            size: 20.sp,
          ),
          HSpace(10.w),
          Expanded(
            child: Text.rich(
              TextSpan(
                style: t.bodyMedium?.copyWith(
                  color: AppThemes.getParagraphColor(),
                  fontSize: 13.sp,
                ),
                children: [
                  TextSpan(
                    text: "${storedLanguage['Verification code sent to'] ?? 'Verification code sent to'} ",
                  ),
                  TextSpan(
                    text: "${controller.phoneCode} ${controller.phoneController.text}",
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
      margin: EdgeInsets.only(top: 16.h),
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: const Color(0xFFFEF2F2),
        borderRadius: BorderRadius.circular(10.r),
        border: Border.all(
          color: const Color(0xFFFCA5A5),
          width: 1,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.only(top: 2.h),
            child: Icon(
              Icons.error_outline_rounded,
              color: const Color(0xFFDC2626),
              size: 18.sp,
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
