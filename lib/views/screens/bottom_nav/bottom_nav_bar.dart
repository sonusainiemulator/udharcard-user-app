import 'package:avatar_glow/avatar_glow.dart';
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
import '../../../utils/app_constants.dart';
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
                        height: 84.h,
                        padding: EdgeInsets.only(
                          top: 33.h,
                          left: 24.w,
                          right: 24.w,
                        ),
                        decoration: BoxDecoration(
                          boxShadow: [
                            BoxShadow(
                              color:
                                  appCtrl.isDarkMode() == true
                                      ? AppColors.darkBgColor
                                      : Colors.grey.shade100,
                              blurRadius: 10,
                              spreadRadius: 5,
                            ),
                          ],
                          image: DecorationImage(
                            colorFilter: ColorFilter.mode(
                              appCtrl.isDarkMode() == true
                                  ? AppColors.darkCardColor
                                  : AppColors
                                      .whiteColor, // Apply a red tint with 50% opacity
                              BlendMode.srcATop, // Use 'srcATop' blend mode
                            ),
                            image: AssetImage(
                              "$rootImageDir/bottom_nav_shape.webp",
                            ),
                            fit: BoxFit.cover,
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            InkResponse(
                              onTap: () {
                                controller.changeScreen(0);
                              },
                              child: Container(
                                padding: EdgeInsets.only(
                                  left: 10.w,
                                  right: 10.w,
                                  top: 10.h,
                                  bottom: 10.h,
                                ),
                                child: Image.asset(
                                  controller.selectedIndex == 0
                                      ? "$rootImageDir/home1.webp"
                                      : "$rootImageDir/home.webp",
                                  height: 24.h,
                                  color: controller.selectedIndex == 0
                                      ? AppColors.mainColor
                                      : appCtrl.isDarkMode() == true
                                          ? AppColors.whiteColor
                                          : AppColors.blackColor,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                            InkResponse(
                              onTap: () {
                                controller.changeScreen(1);
                              },
                              child: Container(
                                padding: EdgeInsets.only(
                                  left: 10.w,
                                  right: 60.w, // Space for center FAB
                                  top: 10.h,
                                  bottom: 10.h,
                                ),
                                child: Image.asset(
                                  controller.selectedIndex == 1
                                      ? "$rootImageDir/wallet1.webp"
                                      : "$rootImageDir/wallet.webp",
                                  height: controller.selectedIndex == 1 ? 28.h : 26.h,
                                  color: controller.selectedIndex == 1
                                      ? AppColors.mainColor
                                      : appCtrl.isDarkMode() == true
                                          ? AppColors.whiteColor
                                          : AppColors.blackColor,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                            InkResponse(
                              onTap: () {
                                controller.changeScreen(2);
                              },
                              child: Container(
                                padding: EdgeInsets.only(
                                  right: 10.w,
                                  left: 60.w, // Space for center FAB
                                  top: 10.h,
                                  bottom: 10.h,
                                ),
                                child: Image.asset(
                                  "$rootImageDir/transaction.webp",
                                  height: 26.h,
                                  color: controller.selectedIndex == 2
                                      ? AppColors.mainColor
                                      : appCtrl.isDarkMode() == true
                                          ? AppColors.whiteColor
                                          : AppColors.blackColor,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                            InkResponse(
                              onTap: () {
                                controller.changeScreen(3);
                              },
                              child: Container(
                                padding: EdgeInsets.only(
                                  left: 10.w,
                                  right: 10.w,
                                  top: 10.h,
                                  bottom: 10.h,
                                ),
                                child: Image.asset(
                                  controller.selectedIndex == 3
                                      ? "$rootImageDir/person2.webp"
                                      : "$rootImageDir/person.webp",
                                  height: controller.selectedIndex == 3 ? 20.h : 23.h,
                                  color: controller.selectedIndex == 3
                                      ? AppColors.mainColor
                                      : appCtrl.isDarkMode() == true
                                          ? AppColors.whiteColor
                                          : AppColors.blackColor,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    floatingActionButton:
                        exchangeCtrl.amountFocusNode.hasFocus
                            ? SizedBox(height: 0, width: 0)
                            : Padding(
                              padding: EdgeInsets.only(top: 50.h),
                              child: AvatarGlow(
                                animate: true,
                                startDelay: const Duration(milliseconds: 1000),
                                glowColor:
                                    appCtrl.isDarkMode() == true
                                        ? AppColors.black80
                                        : AppColors.black30,
                                glowShape: BoxShape.circle,
                                curve: Curves.fastOutSlowIn,
                                glowRadiusFactor: .5,
                                child: Container(
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    boxShadow: [
                                      BoxShadow(
                                        color:
                                            appCtrl.isDarkMode() == true
                                                ? AppColors.darkBgColor
                                                : Color(0xffD6CCF9),
                                        blurRadius: 10,
                                        spreadRadius: 3,
                                        offset: Offset(0, 5),
                                      ),
                                    ],
                                  ),
                                  child: ClipOval(child: MoneyTransferButton()),
                                ),
                              ),
                            ),
                    floatingActionButtonLocation:
                        FloatingActionButtonLocation.centerDocked,
                  ),
                ));
              },
            );
          },
        );
      },
    );
  }
}

class MoneyTransferButton extends StatefulWidget {
  @override
  appCtrlMoneyTransferButtonState createState() =>
      appCtrlMoneyTransferButtonState();
}

class appCtrlMoneyTransferButtonState extends State<MoneyTransferButton>
    with SingleTickerProviderStateMixin {
  late AnimationController appCtrlcontroller;
  late Animation<double> appCtrlsizeAnimation;
  late Animation<double> appCtrlbounceAnimation;

  @override
  void initState() {
    super.initState();

    // Initialize the animation controller
    appCtrlcontroller = AnimationController(
      duration: Duration(seconds: 2), // Total duration of the animation
      vsync: this,
    )..repeat(reverse: true); // Repeats the animation

    // Size animation (small to large)
    appCtrlsizeAnimation = Tween<double>(begin: 0.7, end: 1).animate(
      CurvedAnimation(parent: appCtrlcontroller, curve: Curves.easeInOut),
    );

    // Bounce animation (up and down movement)
    appCtrlbounceAnimation = Tween<double>(begin: 0, end: 3).animate(
      CurvedAnimation(parent: appCtrlcontroller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    appCtrlcontroller
        .dispose(); // Dispose the controller when the widget is removed
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      onPressed: () {
        Get.to(() => const MobileScannerScreen(isFromMakePaymentPage: true));
      },
      backgroundColor: AppColors.mainColor,
      child: AnimatedBuilder(
        animation: appCtrlcontroller,
        builder: (context, child) {
          return Transform.translate(
            offset: Offset(0, -appCtrlbounceAnimation.value), // Bounce effect
            child: Transform.scale(
              scale: appCtrlsizeAnimation.value, // Shrink and grow effect
              child: Icon(
                Icons.qr_code_scanner_rounded,
                color: Colors.white,
                size: 26.sp,
              ),
            ),
          );
        },
      ),
    );
  }
}
