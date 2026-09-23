import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../config/app_colors.dart';
import '../../../controllers/auth_controller.dart';
import '../../../utils/app_constants.dart';
import '../../../utils/services/helpers.dart';
import '../../../utils/services/localstorage/hive.dart';
import '../../../utils/services/localstorage/keys.dart';
import '../../widgets/auth_wave_background.dart';
import '../../widgets/spacing.dart';

class OtpScreen extends StatelessWidget {
  const OtpScreen({super.key});

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
                      VSpace(10.h),
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
                      Text(
                        'Enter the 5-digit verification code\nsent to your registered details',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: isDark ? Colors.white70 : AppColors.textMutedColor,
                          height: 1.4,
                        ),
                      ),
                      VSpace(32.h),

                      // 5 digit boxes matching existing auth controller structure
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _buildOtpDigitBox(
                            context: context,
                            controller: controller.otpEditingController1,
                            onChanged: (v) {
                              controller.otpVal1 = v;
                              if (v.length == 1) {
                                FocusManager.instance.primaryFocus?.nextFocus();
                              }
                              controller.update();
                            },
                          ),
                          _buildOtpDigitBox(
                            context: context,
                            controller: controller.otpEditingController2,
                            onChanged: (v) {
                              controller.otpVal2 = v;
                              if (v.length == 1) {
                                FocusManager.instance.primaryFocus?.nextFocus();
                              }
                              controller.update();
                            },
                          ),
                          _buildOtpDigitBox(
                            context: context,
                            controller: controller.otpEditingController3,
                            onChanged: (v) {
                              controller.otpVal3 = v;
                              if (v.length == 1) {
                                FocusManager.instance.primaryFocus?.nextFocus();
                              }
                              controller.update();
                            },
                          ),
                          _buildOtpDigitBox(
                            context: context,
                            controller: controller.otpEditingController4,
                            onChanged: (v) {
                              controller.otpVal4 = v;
                              if (v.length == 1) {
                                FocusManager.instance.primaryFocus?.nextFocus();
                              }
                              controller.update();
                            },
                          ),
                          _buildOtpDigitBox(
                            context: context,
                            controller: controller.otpEditingController5,
                            onChanged: (v) {
                              controller.otpVal5 = v;
                              if (v.length == 1) {
                                Helpers.hideKeyboard();
                              }
                              controller.update();
                            },
                          ),
                        ],
                      ),

                      VSpace(28.h),

                      // Countdown / Resend
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            storedLanguage['Didn\'t receive OTP? '] ??
                                "Didn't receive OTP? ",
                            style: TextStyle(
                              fontSize: 13.sp,
                              color: isDark ? Colors.white70 : AppColors.textMutedColor,
                            ),
                          ),
                          if (controller.isStartTimer)
                            Text(
                              "Resend in 00:${controller.counter.toString().padLeft(2, '0')}",
                              style: TextStyle(
                                fontSize: 13.sp,
                                fontWeight: FontWeight.w600,
                                color: AppColors.mainColor,
                              ),
                            )
                          else
                            GestureDetector(
                              onTap: () async {
                                controller.startTimer();
                                await controller.forgotPass(isFromOtpPage: true);
                              },
                              child: Text(
                                storedLanguage['Resend OTP'] ?? "Resend OTP",
                                style: TextStyle(
                                  fontSize: 13.sp,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.mainColor,
                                ),
                              ),
                            ),
                        ],
                      ),

                      VSpace(32.h),

                      // Verify OTP Button
                      SizedBox(
                        width: double.infinity,
                        height: 52.h,
                        child: ElevatedButton(
                          onPressed: (controller.otpVal1.isEmpty ||
                                  controller.otpVal2.isEmpty ||
                                  controller.otpVal3.isEmpty ||
                                  controller.otpVal4.isEmpty ||
                                  controller.otpVal5.isEmpty ||
                                  controller.isLoading)
                              ? null
                              : () async {
                                  Helpers.hideKeyboard();
                                  await controller.geCode();
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
                      TextButton(
                        onPressed: () => Get.back(),
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
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildOtpDigitBox({
    required BuildContext context,
    required TextEditingController controller,
    required ValueChanged<String> onChanged,
  }) {
    final bool isDark = Get.isDarkMode;
    return Container(
      width: 52.w,
      height: 56.h,
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCardColor : Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: controller.text.isNotEmpty
              ? AppColors.mainColor
              : (isDark ? Colors.white24 : AppColors.cardBorderColor),
          width: 1.3,
        ),
      ),
      child: Center(
        child: TextField(
          controller: controller,
          onChanged: onChanged,
          keyboardType: TextInputType.number,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 22.sp,
            fontWeight: FontWeight.w700,
            color: isDark ? Colors.white : AppColors.textDarkColor,
          ),
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
            LengthLimitingTextInputFormatter(1),
          ],
          decoration: const InputDecoration(
            border: InputBorder.none,
            enabledBorder: InputBorder.none,
            focusedBorder: InputBorder.none,
            contentPadding: EdgeInsets.zero,
          ),
        ),
      ),
    );
  }
}
