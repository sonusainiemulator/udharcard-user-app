import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../config/app_colors.dart';
import '../../../routes/routes_name.dart';
import '../../../utils/app_constants.dart';
import '../../widgets/auth_wave_background.dart';
import '../../widgets/spacing.dart';

class GetStartedScreen extends StatefulWidget {
  const GetStartedScreen({super.key});

  @override
  State<GetStartedScreen> createState() => _GetStartedScreenState();
}

class _GetStartedScreenState extends State<GetStartedScreen> {
  // 0: Customer, 1: Merchant
  int _selectedAccountType = 0;

  @override
  Widget build(BuildContext context) {
    final bool isDark = Get.isDarkMode;

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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Back Button
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                  child: IconButton(
                    icon: Icon(
                      Icons.arrow_back_ios_new_rounded,
                      size: 22.sp,
                      color: isDark ? Colors.white : AppColors.textDarkColor,
                    ),
                    onPressed: () => Get.back(),
                  ),
                ),

                Expanded(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.symmetric(horizontal: 24.w),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        VSpace(12.h),
                        Text(
                          "Let's Get Started",
                          style: TextStyle(
                            fontSize: 26.sp,
                            fontWeight: FontWeight.w700,
                            color: isDark ? Colors.white : AppColors.textDarkColor,
                          ),
                        ),
                        VSpace(8.h),
                        Text(
                          "Choose how you want to use UdharCard",
                          style: TextStyle(
                            fontSize: 14.sp,
                            color: isDark ? Colors.white70 : AppColors.textMutedColor,
                          ),
                        ),
                        VSpace(36.h),

                        // Card 1: I am a Customer
                        _buildAccountOptionCard(
                          index: 0,
                          icon: Icons.person_rounded,
                          title: "I am a Customer",
                          subtitle: "Shop now, pay later with trusted merchants.",
                          isSelected: _selectedAccountType == 0,
                          onTap: () {
                            setState(() {
                              _selectedAccountType = 0;
                            });
                          },
                        ),

                        VSpace(18.h),

                        // Card 2: I am a Merchant
                        _buildAccountOptionCard(
                          index: 1,
                          icon: Icons.storefront_rounded,
                          title: "I am a Merchant",
                          subtitle: "Manage customers, track udhar and grow business.",
                          isSelected: _selectedAccountType == 1,
                          onTap: () {
                            setState(() {
                              _selectedAccountType = 1;
                            });
                          },
                        ),

                        VSpace(36.h),

                        // Continue Button
                        SizedBox(
                          width: double.infinity,
                          height: 52.h,
                          child: ElevatedButton(
                            onPressed: () {
                              if (_selectedAccountType == 0) {
                                Get.toNamed(RoutesName.loginScreen);
                              } else {
                                Get.toNamed(RoutesName.signUpScreen);
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.mainColor,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14.r),
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  "Continue",
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

                        VSpace(36.h),

                        // Bottom Stores Illustration
                        Center(
                          child: Image.asset(
                            "$rootImageDir/local_stores_cityscape.png",
                            height: 70.h,
                            fit: BoxFit.contain,
                          ),
                        ),
                        VSpace(12.h),

                        // Tagline badges
                        Text(
                          "Local Businesses | Trusted Payments | Digital Udhar",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w500,
                            color: isDark ? Colors.white60 : const Color(0xff64748B),
                            letterSpacing: 0.2,
                          ),
                        ),
                        VSpace(20.h),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAccountOptionCard({
    required int index,
    required IconData icon,
    required String title,
    required String subtitle,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    final bool isDark = Get.isDarkMode;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
        decoration: BoxDecoration(
          color: isDark
              ? (isSelected ? AppColors.mainColor.withValues(alpha: 0.15) : AppColors.darkCardColor)
              : (isSelected ? AppColors.lightBlueTint : Colors.white),
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(
            color: isSelected
                ? AppColors.mainColor
                : (isDark ? Colors.white24 : AppColors.cardBorderColor),
            width: isSelected ? 1.8 : 1.2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 52.h,
              height: 52.h,
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.mainColor.withValues(alpha: 0.12)
                    : (isDark ? Colors.white10 : const Color(0xffF1F5F9)),
                borderRadius: BorderRadius.circular(14.r),
              ),
              child: Center(
                child: Icon(
                  icon,
                  size: 28.sp,
                  color: isSelected
                      ? AppColors.mainColor
                      : (isDark ? Colors.white70 : const Color(0xff64748B)),
                ),
              ),
            ),
            HSpace(14.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w700,
                      color: isDark ? Colors.white : AppColors.textDarkColor,
                    ),
                  ),
                  VSpace(4.h),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 12.5.sp,
                      fontWeight: FontWeight.w400,
                      color: isDark ? Colors.white60 : AppColors.textMutedColor,
                      height: 1.3,
                    ),
                  ),
                ],
              ),
            ),
            HSpace(10.w),
            Container(
              width: 22.r,
              height: 22.r,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? AppColors.mainColor : const Color(0xffCBD5E1),
                  width: 2,
                ),
              ),
              child: isSelected
                  ? Center(
                      child: Container(
                        width: 11.r,
                        height: 11.r,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.mainColor,
                        ),
                      ),
                    )
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}
