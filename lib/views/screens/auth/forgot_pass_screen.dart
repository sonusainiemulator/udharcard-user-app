import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:country_code_picker/country_code_picker.dart';
import 'package:get/get.dart';

import '../../../../config/app_colors.dart';
import '../../../controllers/auth_controller.dart';
import '../../../themes/themes.dart';
import '../../../utils/services/helpers.dart';
import '../../../utils/services/localstorage/hive.dart';
import '../../../utils/services/localstorage/keys.dart';
import '../../widgets/auth_wave_background.dart';
import '../../widgets/spacing.dart';

class ForgotPassScreen extends StatelessWidget {
  const ForgotPassScreen({super.key});

  @override
  Widget build(BuildContext context) {
    AuthController controller = Get.find<AuthController>();
    var storedLanguage = HiveHelp.read(Keys.languageData) ?? {};
    final bool isDark = Get.isDarkMode;

    return GetBuilder<AuthController>(
      builder: (_) {
        return Scaffold(
          backgroundColor: isDark ? AppColors.darkBgColor : Colors.white,
          body: Stack(
            children: [
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
                      // Back Button
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
                      VSpace(30.h),

                      // Circular Blue Lock Icon
                      Container(
                        width: 90.h,
                        height: 90.h,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.lightBlueTint,
                          border: Border.all(
                            color: AppColors.mainColor.withValues(alpha: 0.15),
                            width: 1.5,
                          ),
                        ),
                        child: Center(
                          child: Icon(
                            Icons.lock_rounded,
                            size: 42.sp,
                            color: AppColors.mainColor,
                          ),
                        ),
                      ),
                      VSpace(28.h),

                      // Headings
                      Text(
                        storedLanguage['Forgot Password?'] ?? "Forgot Password?",
                        style: TextStyle(
                          fontSize: 26.sp,
                          fontWeight: FontWeight.w700,
                          color: isDark ? Colors.white : AppColors.textDarkColor,
                        ),
                      ),
                      VSpace(8.h),
                      Text(
                        storedLanguage['Enter your mobile number to reset your password.'] ??
                            "Enter your mobile number to reset your password.",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: isDark ? Colors.white70 : AppColors.textMutedColor,
                        ),
                      ),
                      VSpace(36.h),

                      // Mobile Number Input with 🇮🇳 +91
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
                              ),
                            ),
                          ],
                        ),
                      ),

                      VSpace(28.h),

                      // Send Reset Link Button
                      SizedBox(
                        width: double.infinity,
                        height: 52.h,
                        child: ElevatedButton(
                          onPressed: controller.isLoading
                              ? null
                              : () async {
                                  if (controller.phoneController.text.trim().isEmpty) {
                                    Helpers.showSnackBar(
                                      msg: "Mobile number is required",
                                    );
                                  } else {
                                    Helpers.hideKeyboard();
                                    String fullPhone =
                                        "${controller.phoneCode}${controller.phoneController.text.trim()}";
                                    await controller.sendOtp(fullPhone);
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
                                  storedLanguage['Send Reset Link'] ?? "Send Reset Link",
                                  style: TextStyle(
                                    fontSize: 16.sp,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                  ),
                                ),
                        ),
                      ),

                      VSpace(18.h),
                      Text(
                        "We will send a secure link to your mobile.",
                        style: TextStyle(
                          fontSize: 13.sp,
                          color: isDark ? Colors.white60 : AppColors.textMutedColor,
                        ),
                      ),
                      VSpace(40.h),
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
}
