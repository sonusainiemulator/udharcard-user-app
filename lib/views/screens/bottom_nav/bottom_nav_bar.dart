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
import '../../../controllers/send_money_controller.dart';
import '../../../notification_service/notification_controller.dart';
import '../../../routes/routes_name.dart';
import '../../../utils/app_constants.dart';
import '../../../utils/services/pop_app.dart';

class BottomNavBar extends StatefulWidget {
  const BottomNavBar({super.key});

  @override
  State<BottomNavBar> createState() => appCtrlBottomNavBarState();
}

class appCtrlBottomNavBarState extends State<BottomNavBar> {
  final Connectivity appCtrlconnectivity = Connectivity();
  @override
  void initState() {
    appCtrlconnectivity.onConnectivityChanged.listen(
      Get.find<AppController>().updateConnectionStatus,
    );
    Get.put(PushNotificationController()).getPushNotificationConfig();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      Get.put(ProfileController()).getProfile();
      Get.put(AppController()).getDashboard();
       Get.put(AppController()).getPackageInfo();
    });
    super.initState();
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
                  child: Scaffold(
                    body: controller.currentScreen,
                    bottomNavigationBar: SafeArea(
                      child: Container(
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
                                  appCtrl.basicCtrlList.isNotEmpty &&
                                              appCtrl.basicCtrlList[0].exchange
                                                      .toString() ==
                                                  '0' ||
                                          appCtrl.basicCtrlList.isNotEmpty &&
                                              appCtrl
                                                      .basicCtrlList[0]
                                                      .virtualCard
                                                      .toString() ==
                                                  '0'
                                      ? "$rootImageDir/home.webp"
                                      : controller.selectedIndex == 0
                                      ? "$rootImageDir/home1.webp"
                                      : "$rootImageDir/home.webp",
                                  height: 24.h,
                                  color:
                                      (appCtrl.basicCtrlList.isNotEmpty &&
                                                      appCtrl
                                                              .basicCtrlList[0]
                                                              .exchange
                                                              .toString() ==
                                                          '0' ||
                                                  appCtrl
                                                          .basicCtrlList
                                                          .isNotEmpty &&
                                                      appCtrl
                                                              .basicCtrlList[0]
                                                              .virtualCard
                                                              .toString() ==
                                                          '0') &&
                                              controller.selectedIndex == 0
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
                                padding:
                                    appCtrl.basicCtrlList.isNotEmpty &&
                                            appCtrl.basicCtrlList[0].transfer
                                                    .toString() ==
                                                '1'
                                        ? EdgeInsets.only(
                                          left: 10.w,
                                          right: 60.w,
                                          top: 10.h,
                                          bottom: 10.h,
                                        )
                                        : EdgeInsets.zero,
                                child: Image.asset(
                                  appCtrl.basicCtrlList.isNotEmpty &&
                                          appCtrl.basicCtrlList[0].virtualCard
                                                  .toString() ==
                                              '1'
                                      ? controller.selectedIndex == 1
                                          ? "$rootImageDir/wallet1.webp"
                                          : "$rootImageDir/wallet.webp"
                                      : "$rootImageDir/transaction.webp",
                                  height:
                                      controller.selectedIndex == 1
                                          ? 28.h
                                          : 26.h,
                                  color:
                                      appCtrl.basicCtrlList.isNotEmpty &&
                                              appCtrl
                                                      .basicCtrlList[0]
                                                      .virtualCard
                                                      .toString() ==
                                                  '0' &&
                                              controller.selectedIndex == 1
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
                                padding:
                                    appCtrl.basicCtrlList.isNotEmpty &&
                                            appCtrl.basicCtrlList[0].transfer
                                                    .toString() ==
                                                '1'
                                        ? EdgeInsets.only(
                                          right: 10.w,
                                          left: 60.w,
                                          top: 10.h,
                                          bottom: 10.h,
                                        )
                                        : EdgeInsets.zero,
                                child: Image.asset(
                                  appCtrl.basicCtrlList.isNotEmpty &&
                                          appCtrl.basicCtrlList[0].exchange
                                                  .toString() ==
                                              '1'
                                      ? controller.selectedIndex == 2
                                          ? "$rootImageDir/exchange1.webp"
                                          : "$rootImageDir/exchange.webp"
                                      : "$rootImageDir/dispute.webp",
                                  height:
                                      controller.selectedIndex == 2
                                          ? 26.h
                                          : 26.h,
                                  color:
                                      appCtrl.basicCtrlList.isNotEmpty &&
                                              appCtrl.basicCtrlList[0].exchange
                                                      .toString() ==
                                                  '0' &&
                                              controller.selectedIndex == 2
                                          ? AppColors.mainColor
                                          : appCtrl.isDarkMode() == true
                                          ? AppColors.whiteColor
                                          : AppColors.blackColor,
                                  fit:
                                      controller.selectedIndex == 2
                                          ? BoxFit.fitWidth
                                          : BoxFit.cover,
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
                                  appCtrl.basicCtrlList.isNotEmpty &&
                                              appCtrl.basicCtrlList[0].exchange
                                                      .toString() ==
                                                  '0' ||
                                          appCtrl.basicCtrlList.isNotEmpty &&
                                              appCtrl
                                                      .basicCtrlList[0]
                                                      .virtualCard
                                                      .toString() ==
                                                  '0'
                                      ? "$rootImageDir/person.webp"
                                      : controller.selectedIndex == 3
                                      ? "$rootImageDir/person2.webp"
                                      : "$rootImageDir/person.webp",
                                  height:
                                      controller.selectedIndex == 3
                                          ? 20.h
                                          : 23.h,
                                  color:
                                      (appCtrl.basicCtrlList.isNotEmpty &&
                                                      appCtrl
                                                              .basicCtrlList[0]
                                                              .exchange
                                                              .toString() ==
                                                          '0' ||
                                                  appCtrl
                                                          .basicCtrlList
                                                          .isNotEmpty &&
                                                      appCtrl
                                                              .basicCtrlList[0]
                                                              .virtualCard
                                                              .toString() ==
                                                          '0') &&
                                              controller.selectedIndex == 3
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
                    ),
                    floatingActionButton:
                        exchangeCtrl.amountFocusNode.hasFocus ||
                                appCtrl.basicCtrlList.isNotEmpty &&
                                    appCtrl.basicCtrlList[0].transfer
                                            .toString() ==
                                        '0'
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
                );
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
        Get.delete<SendMoneyController>();
        Get.toNamed(RoutesName.sendMoneyScreen);
      },
      backgroundColor: AppColors.blackColor,
      child: AnimatedBuilder(
        animation: appCtrlcontroller,
        builder: (context, child) {
          return Transform.translate(
            offset: Offset(0, -appCtrlbounceAnimation.value), // Bounce effect
            child: Transform.scale(
              scale: appCtrlsizeAnimation.value, // Shrink and grow effect
              child: Image.asset(
                "$rootImageDir/money_transfer.webp",
                fit: BoxFit.cover,
                height: 26.h,
                width: 26.h,
              ),
            ),
          );
        },
      ),
    );
  }
}
