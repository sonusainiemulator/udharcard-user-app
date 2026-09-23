import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:country_code_picker/country_code_picker.dart';
import 'package:get/get.dart';

import '../../../../config/app_colors.dart';
import '../../../controllers/auth_controller.dart';
import '../../../routes/routes_name.dart';
import '../../../themes/themes.dart';
import '../../../utils/app_constants.dart';
import '../../../utils/services/helpers.dart';
import '../../../utils/services/localstorage/hive.dart';
import '../../../utils/services/localstorage/keys.dart';
import '../../widgets/spacing.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  bool _obscurePassword = true;
  bool _agreeTerms = true;
  // 0: Customer, 1: Merchant
  int _selectedAccountType = 0;

  @override
  Widget build(BuildContext context) {
    AuthController controller = Get.find<AuthController>();
    var storedLanguage = HiveHelp.read(Keys.languageData) ?? {};
    final bool isDark = Get.isDarkMode;

    return GetBuilder<AuthController>(
      builder: (_) {
        return Scaffold(
          backgroundColor: isDark ? AppColors.darkBgColor : Colors.white,
          body: SafeArea(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 24.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Top Back Button
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
                      onPressed: () => Get.back(),
                    ),
                  ),

                  // Logo
                  Center(
                    child: Image.asset(
                      "$rootImageDir/app_logo.png",
                      height: 75.h,
                      fit: BoxFit.contain,
                    ),
                  ),
                  VSpace(20.h),

                  // Headings
                  Text(
                    storedLanguage['Create Account'] ?? "Create Account",
                    style: TextStyle(
                      fontSize: 26.sp,
                      fontWeight: FontWeight.w700,
                      color: isDark ? Colors.white : AppColors.textDarkColor,
                    ),
                  ),
                  VSpace(6.h),
                  Text(
                    storedLanguage['Join UdharCard and grow together'] ??
                        "Join UdharCard and grow together",
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: isDark ? Colors.white70 : AppColors.textMutedColor,
                    ),
                  ),
                  VSpace(28.h),

                  // 1. Full Name Field
                  _buildInputField(
                    controller: controller.signupFNameEditingController,
                    hintText: storedLanguage['Full Name'] ?? "Full Name",
                    prefixIcon: Icons.person_outline_rounded,
                    isDark: isDark,
                    onChanged: (v) {
                      controller.signupFNameVal = v;
                      controller.signUpUserNameVal = v.toLowerCase().replaceAll(' ', '');
                    },
                  ),
                  VSpace(14.h),

                  // 2. Mobile Number Field with 🇮🇳 +91
                  Container(
                    height: 52.h,
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
                          height: 26.h,
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
                              hintText: storedLanguage['Mobile Number'] ?? "Mobile Number",
                              hintStyle: const TextStyle(
                                color: AppColors.textFieldHintColor,
                              ),
                              contentPadding: EdgeInsets.zero,
                            ),
                            onChanged: (v) {
                              controller.phoneNumberVal = v;
                              controller.phoneNumberEditingController.text = v;
                              if (controller.errorMessage != null) {
                                controller.errorMessage = null;
                                controller.update();
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                  VSpace(14.h),

                  // 3. Email Address Field
                  _buildInputField(
                    controller: controller.emailEditingController,
                    hintText: storedLanguage['Email Address'] ?? "Email Address",
                    prefixIcon: Icons.mail_outline_rounded,
                    keyboardType: TextInputType.emailAddress,
                    isDark: isDark,
                    onChanged: (v) {
                      controller.emailVal = v;
                    },
                  ),
                  VSpace(14.h),

                  // 4. Create Password Field with eye toggle
                  Container(
                    height: 52.h,
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
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 14.w),
                          child: Icon(
                            Icons.lock_outline_rounded,
                            size: 20.sp,
                            color: AppColors.textMutedColor,
                          ),
                        ),
                        Expanded(
                          child: TextField(
                            controller: controller.signUpPassEditingController,
                            obscureText: _obscurePassword,
                            style: TextStyle(
                              fontSize: 15.sp,
                              fontWeight: FontWeight.w500,
                              color: isDark ? Colors.white : AppColors.textDarkColor,
                            ),
                            decoration: InputDecoration(
                              border: InputBorder.none,
                              enabledBorder: InputBorder.none,
                              focusedBorder: InputBorder.none,
                              hintText: storedLanguage['Create Password'] ?? "Create Password",
                              hintStyle: const TextStyle(
                                color: AppColors.textFieldHintColor,
                              ),
                              contentPadding: EdgeInsets.zero,
                            ),
                            onChanged: (v) {
                              controller.signUpPassVal = v;
                              controller.signUpConfirmPassVal = v;
                            },
                          ),
                        ),
                        IconButton(
                          icon: Icon(
                            _obscurePassword
                                ? Icons.visibility_outlined
                                : Icons.visibility_off_outlined,
                            size: 20.sp,
                            color: AppColors.textMutedColor,
                          ),
                          onPressed: () {
                            setState(() {
                              _obscurePassword = !_obscurePassword;
                            });
                          },
                        ),
                      ],
                    ),
                  ),

                  VSpace(20.h),

                  // 5. Account Type Selector
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      storedLanguage['Account Type'] ?? "Account Type",
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                        color: isDark ? Colors.white : AppColors.textDarkColor,
                      ),
                    ),
                  ),
                  VSpace(10.h),
                  Row(
                    children: [
                      // Customer Radio
                      GestureDetector(
                        onTap: () => setState(() => _selectedAccountType = 0),
                        child: Row(
                          children: [
                            Container(
                              width: 20.r,
                              height: 20.r,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: _selectedAccountType == 0
                                      ? AppColors.mainColor
                                      : const Color(0xffCBD5E1),
                                  width: 2,
                                ),
                              ),
                              child: _selectedAccountType == 0
                                  ? Center(
                                      child: Container(
                                        width: 10.r,
                                        height: 10.r,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: AppColors.mainColor,
                                        ),
                                      ),
                                    )
                                  : null,
                            ),
                            HSpace(8.w),
                            Text(
                              "Customer",
                              style: TextStyle(
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w500,
                                color: isDark ? Colors.white : AppColors.textDarkColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                      HSpace(32.w),
                      // Merchant Radio
                      GestureDetector(
                        onTap: () => setState(() => _selectedAccountType = 1),
                        child: Row(
                          children: [
                            Container(
                              width: 20.r,
                              height: 20.r,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: _selectedAccountType == 1
                                      ? AppColors.mainColor
                                      : const Color(0xffCBD5E1),
                                  width: 2,
                                ),
                              ),
                              child: _selectedAccountType == 1
                                  ? Center(
                                      child: Container(
                                        width: 10.r,
                                        height: 10.r,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: AppColors.mainColor,
                                        ),
                                      ),
                                    )
                                  : null,
                            ),
                            HSpace(8.w),
                            Text(
                              "Merchant",
                              style: TextStyle(
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w500,
                                color: isDark ? Colors.white : AppColors.textDarkColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  VSpace(18.h),

                  // 6. Terms Checkbox
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
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
                          value: _agreeTerms,
                          onChanged: (v) {
                            setState(() {
                              _agreeTerms = v ?? false;
                            });
                          },
                        ),
                      ),
                      HSpace(10.w),
                      Expanded(
                        child: Text.rich(
                          TextSpan(
                            style: TextStyle(
                              fontSize: 12.5.sp,
                              color: isDark ? Colors.white70 : const Color(0xff475569),
                            ),
                            children: [
                              TextSpan(
                                text: storedLanguage['I agree to the '] ??
                                    "I agree to the ",
                              ),
                              TextSpan(
                                text: storedLanguage['Terms & Conditions'] ??
                                    "Terms & Conditions",
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.mainColor,
                                ),
                              ),
                              TextSpan(
                                text: storedLanguage[' and '] ?? " and ",
                              ),
                              TextSpan(
                                text: storedLanguage['Privacy Policy'] ??
                                    "Privacy Policy",
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.mainColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),

                  if (controller.errorMessage != null &&
                      controller.errorMessage!.isNotEmpty) ...[
                    VSpace(12.h),
                    _buildErrorAlert(controller.errorMessage!),
                  ],

                  VSpace(28.h),

                  // 7. Sign Up Primary Button
                  SizedBox(
                    width: double.infinity,
                    height: 52.h,
                    child: ElevatedButton(
                      onPressed: (!_agreeTerms || controller.isLoading)
                          ? null
                          : () async {
                              Helpers.hideKeyboard();
                              if (controller.phoneController.text.trim().isNotEmpty) {
                                String fullPhone =
                                    "${controller.phoneCode}${controller.phoneController.text.trim()}";
                                await controller.sendOtp(fullPhone);
                              } else {
                                await controller.register();
                              }
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
                          : Text(
                              storedLanguage['Sign Up'] ?? "Sign Up",
                              style: TextStyle(
                                fontSize: 16.sp,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                    ),
                  ),

                  VSpace(22.h),

                  // 8. Footer: Already have an account? Log In
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        storedLanguage['Already have an account?'] ??
                            "Already have an account?",
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: isDark ? Colors.white70 : AppColors.textMutedColor,
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          Get.toNamed(RoutesName.loginScreen);
                        },
                        child: Text(
                          storedLanguage['Log In'] ?? "Log In",
                          style: TextStyle(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w700,
                            color: AppColors.mainColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                  VSpace(24.h),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String hintText,
    required IconData prefixIcon,
    TextInputType keyboardType = TextInputType.text,
    required bool isDark,
    required ValueChanged<String> onChanged,
  }) {
    return Container(
      height: 52.h,
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
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 14.w),
            child: Icon(
              prefixIcon,
              size: 20.sp,
              color: AppColors.textMutedColor,
            ),
          ),
          Expanded(
            child: TextField(
              controller: controller,
              keyboardType: keyboardType,
              style: TextStyle(
                fontSize: 15.sp,
                fontWeight: FontWeight.w500,
                color: isDark ? Colors.white : AppColors.textDarkColor,
              ),
              decoration: InputDecoration(
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                hintText: hintText,
                hintStyle: const TextStyle(
                  color: AppColors.textFieldHintColor,
                ),
                contentPadding: EdgeInsets.zero,
              ),
              onChanged: onChanged,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorAlert(String errorText) {
    return Container(
      width: double.infinity,
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
