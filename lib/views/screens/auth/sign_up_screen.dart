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

class SignUpScreen extends StatelessWidget {
  const SignUpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    TextTheme t = Theme.of(context).textTheme;
    AuthController controller = Get.find<AuthController>();
    var storedLanguage = HiveHelp.read(Keys.languageData) ?? {};
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
                      children: [
                        VSpace(100.h),
                        Text(
                          storedLanguage['Create Account'] ?? "Create Account",
                          style: t.titleMedium?.copyWith(fontSize: 26.sp),
                        ),
                        VSpace(12.h),
                        Text(
                          storedLanguage['Sign up with your phone number to continue!'] ??
                              "Sign up with your phone number to continue!",
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
                          if (controller.errorMessage != null &&
                              controller.errorMessage!.isNotEmpty)
                            _buildInlineError(controller.errorMessage!, t),
                          VSpace(32.h),
                          Material(
                            color: Colors.transparent,
                            child: AppButton(
                              text: storedLanguage['Send OTP'] ?? "Send OTP",
                              isLoading: controller.isLoading ? true : false,
                              bgColor: controller.phoneController.text.isEmpty
                                  ? AppThemes.getInactiveColor()
                                  : AppColors.mainColor,
                              onTap: controller.phoneController.text.isEmpty
                                  ? null
                                  : controller.isLoading
                                  ? null
                                  : () async {
                                      Helpers.hideKeyboard();
                                      String fullPhone = "${controller.phoneCode}${controller.phoneController.text.trim()}";
                                      await controller.sendOtp(fullPhone);
                                    },
                            ),
                          ),
                        ] else ...[
                          _buildOtpInfoCard(controller, storedLanguage, t),
                          VSpace(24.h),
                          CustomTextField(
                            hintext: storedLanguage['6-Digit OTP'] ?? "6-Digit OTP",
                            isPrefixIcon: true,
                            prefixIcon: 'lock',
                            keyboardType: TextInputType.number,
                            controller: controller.otpController,
                            onChanged: (v) {
                              if (controller.errorMessage != null) {
                                controller.errorMessage = null;
                              }
                              controller.update();
                            },
                          ),
                          if (controller.errorMessage != null &&
                              controller.errorMessage!.isNotEmpty)
                            _buildInlineError(controller.errorMessage!, t),
                          VSpace(32.h),
                          Material(
                            color: Colors.transparent,
                            child: AppButton(
                              text: storedLanguage['Verify & Register'] ?? "Verify & Register",
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
                                      String fullPhone = "${controller.phoneCode}${controller.phoneController.text.trim()}";
                                      await controller.verifyOtpAndLogin(
                                        controller.otpController.text.trim(),
                                        fullPhone,
                                      );
                                    },
                            ),
                          ),
                          VSpace(20.h),
                          Align(
                            alignment: Alignment.center,
                            child: TextButton(
                              onPressed: () {
                                controller.isOtpSent = false;
                                controller.otpController.clear();
                                controller.errorMessage = null;
                                controller.update();
                              },
                              child: Text(
                                storedLanguage['Change Phone Number'] ??
                                    "Change Phone Number",
                                style: t.bodyMedium?.copyWith(
                                  color: AppThemes.getHintColor(),
                                ),
                              ),
                            ),
                          ),
                        ],
                        VSpace(60.h),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              storedLanguage['Already have an account?'] ??
                                  "Already have an account?",
                              style: t.displayMedium?.copyWith(
                                fontSize: 18.sp,
                                color: AppThemes.getHintColor(),
                              ),
                            ),
                            TextButton(
                              onPressed: () {
                                Get.toNamed(RoutesName.loginScreen);
                              },
                              child: Text(
                                storedLanguage['Login'] ?? "Login",
                                style: t.displayMedium?.copyWith(
                                  fontSize: 18.sp,
                                ),
                              ),
                            ),
                          ],
                        ),
                        VSpace(60.h),
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
