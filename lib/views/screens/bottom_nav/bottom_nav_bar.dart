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
  State<BottomNavBar> createState() => appCtrlBottomNavBarState();
}

class appCtrlBottomNavBarState extends State<BottomNavBar> {
  final Connectivity appCtrlconnectivity = Connectivity();
  @override
  void initState() {
    super.initState();
    // Listen for connectivity changes (lightweight, safe on main thread)
    appCtrlconnectivity.onConnectivityChanged.listen(
      Get.find<AppController>().updateConnectionStatus,
    );
    // Defer ALL heavy async work to after the first frame renders.
    // This prevents the ANR "app not responding" freeze after login.
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      // Step 1: Render the UI first, then start Pusher init
      await Future.microtask(
        () => Get.put(PushNotificationController()).getPushNotificationConfig(),
      );
      // Step 2: Small delay so Pusher connection doesn't race with API calls
      await Future.delayed(const Duration(milliseconds: 300));
      // Step 3: Load profile and dashboard in parallel (both are network calls)
      await Future.wait([
        Get.put(ProfileController()).getProfile(),
        Get.put(AppController()).getDashboard(),
      ]);
      // Step 4: Package info is very lightweight, fetch last
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
                return PopScope(
                  canPop: false,
                  onPopInvokedWithResult: (didPop, result) {
                    if (didPop) return;
                    return PopApp.onWillPop();
                  },
                  child: SafeArea(
                    child: Scaffold(
                      body: controller.currentScreen,
                      bottomNavigationBar: Container(
                        decoration: BoxDecoration(
                          color: appCtrl.isDarkMode() == true
                              ? AppColors.darkCardColor
                              : Colors.white,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.06),
                              blurRadius: 16,
                              offset: const Offset(0, -4),
                            ),
                          ],
                        ),
                        child: SafeArea(
                          top: false,
                          child: Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: 16.w,
                              vertical: 8.h,
                            ),
                            child: Row(
                              mainAxisAlignment:
                                  MainAxisAlignment.spaceAround,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                _buildNavItem(
                                  icon: Icons.home_rounded,
                                  label: "Home",
                                  isSelected: controller.selectedIndex == 0,
                                  isDark: appCtrl.isDarkMode() == true,
                                  onTap: () => controller.changeScreen(0),
                                ),
                                _buildNavItem(
                                  icon: Icons.history_rounded,
                                  label: "History",
                                  isSelected: controller.selectedIndex == 1,
                                  isDark: appCtrl.isDarkMode() == true,
                                  onTap: () => controller.changeScreen(1),
                                ),
                                _buildScanAndPayItem(
                                  appCtrl.isDarkMode() == true,
                                ),
                                _buildNavItem(
                                  icon: Icons.person_rounded,
                                  label: "Profile",
                                  isSelected: controller.selectedIndex == 2,
                                  isDark: appCtrl.isDarkMode() == true,
                                  onTap: () => controller.changeScreen(2),
                                ),
                              ],
                            ),
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

  Widget _buildScanAndPayItem(bool isDark) {
    return GestureDetector(
      onTap: () {
        Get.to(() => const MobileScannerScreen(isFromMakePaymentPage: true));
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 46.h,
            height: 46.h,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [
                  AppColors.mainColor,
                  const Color(0xff1E4E8C),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.mainColor.withValues(alpha: 0.35),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Center(
              child: Icon(
                Icons.qr_code_scanner_rounded,
                color: Colors.white,
                size: 24.sp,
              ),
            ),
          ),
          SizedBox(height: 3.h),
          Text(
            "Scan & Pay",
            style: TextStyle(
              fontSize: 10.sp,
              fontWeight: FontWeight.w700,
              color: AppColors.mainColor,
            ),
          ),
        ],
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
    final color = isSelected
        ? AppColors.mainColor
        : (isDark ? Colors.grey.shade400 : Colors.grey.shade600);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12.r),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 24.sp),
            SizedBox(height: 3.h),
            Text(
              label,
              style: TextStyle(
                fontSize: 11.sp,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
