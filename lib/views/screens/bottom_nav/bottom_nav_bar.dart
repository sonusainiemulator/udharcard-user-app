import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../config/app_colors.dart';
import '../../../controllers/app_controller.dart';
import '../../../controllers/bottom_nav_controller.dart';
import '../../../controllers/exchange_controller.dart';
import '../../../controllers/profile_controller.dart';
import '../../../notification_service/notification_controller.dart';
import '../../../utils/services/pop_app.dart';
import '../mobile_scanner/mobile_scanner_screen.dart';

class BottomNavBar extends StatefulWidget {
  const BottomNavBar({super.key});

  @override
  State<BottomNavBar> createState() => _BottomNavBarState();
}

class _BottomNavBarState extends State<BottomNavBar> {
  final Connectivity appCtrlconnectivity = Connectivity();

  @override
  void initState() {
    super.initState();
    appCtrlconnectivity.onConnectivityChanged.listen(
      Get.find<AppController>().updateConnectionStatus,
    );

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await Future.microtask(
        () => Get.put(PushNotificationController()).getPushNotificationConfig(),
      );
      await Future.delayed(const Duration(milliseconds: 300));
      await Future.wait([
        Get.put(ProfileController()).getProfile(),
        Get.put(AppController()).getDashboard(),
      ]);
      Get.put(AppController()).getPackageInfo();
    });
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<AppController>(
      builder: (appCtrl) {
        return GetBuilder<BottomNavController>(
          builder: (controller) {
            return GetBuilder<ExchangeController>(
              builder: (exchangeCtrl) {
                final bool isDark = appCtrl.isDarkMode() == true;
                return PopScope(
                  canPop: false,
                  onPopInvokedWithResult: (didPop, result) {
                    if (didPop) return;
                    return PopApp.onWillPop();
                  },
                  child: Scaffold(
                    body: controller.currentScreen,
                    bottomNavigationBar: Container(
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.darkCardColor : Colors.white,
                        border: Border(
                          top: BorderSide(
                            color: isDark ? Colors.white12 : const Color(0xFFF1F5F9),
                            width: 1,
                          ),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.04),
                            blurRadius: 12,
                            offset: const Offset(0, -3),
                          ),
                        ],
                      ),
                      child: SafeArea(
                        top: false,
                        child: Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: 10.w,
                            vertical: 6.h,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              // 1. Home
                              _buildNavItem(
                                icon: Icons.home_rounded,
                                label: "Home",
                                isSelected: controller.selectedIndex == 0,
                                isDark: isDark,
                                onTap: () => controller.changeScreen(0),
                              ),
                              // 2. Merchants
                              _buildNavItem(
                                icon: Icons.storefront_rounded,
                                label: "Merchants",
                                isSelected: controller.selectedIndex == 1,
                                isDark: isDark,
                                onTap: () => controller.changeScreen(1),
                              ),
                              // 3. Center Elevated Scan & Pay
                              _buildCenterScanButton(),
                              // 4. Udhari
                              _buildNavItem(
                                icon: Icons.credit_card_rounded,
                                label: "Udhari",
                                isSelected: controller.selectedIndex == 2,
                                isDark: isDark,
                                onTap: () => controller.changeScreen(2),
                              ),
                              // 5. Profile
                              _buildNavItem(
                                icon: Icons.person_outline_rounded,
                                label: "Profile",
                                isSelected: controller.selectedIndex == 3,
                                isDark: isDark,
                                onTap: () => controller.changeScreen(3),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  Widget _buildCenterScanButton() {
    return GestureDetector(
      onTap: () {
        Get.to(() => const MobileScannerScreen(isFromMakePaymentPage: true));
      },
      child: Transform.translate(
        offset: Offset(0, -6.h),
        child: Container(
          width: 52.r,
          height: 52.r,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.mainColor,
            boxShadow: [
              BoxShadow(
                color: AppColors.mainColor.withValues(alpha: 0.4),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Center(
            child: Icon(
              Icons.qr_code_scanner_rounded,
              color: Colors.white,
              size: 26.sp,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required IconData icon,
    required String label,
    required bool isSelected,
    required bool isDark,
    required VoidCallback onTap,
  }) {
    final Color selectedColor = AppColors.mainColor;
    final Color unselectedColor = isDark ? Colors.white60 : const Color(0xFF64748B);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12.r),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isSelected ? selectedColor : unselectedColor,
              size: 23.sp,
            ),
            SizedBox(height: 3.h),
            Text(
              label,
              style: TextStyle(
                fontSize: 10.5.sp,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: isSelected ? selectedColor : unselectedColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
