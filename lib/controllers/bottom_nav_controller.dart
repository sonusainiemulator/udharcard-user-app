import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../views/screens/home/home_screen.dart';
import '../views/screens/customer_udhar/customer_udhar_merchants_screen.dart';
import '../views/screens/customer_udhar/customer_udhar_ledger_screen.dart';
import '../views/screens/profile/profile_setting_screen.dart';

class BottomNavController extends GetxController {
  static BottomNavController get to => Get.find<BottomNavController>();
  int selectedIndex = 0;
  List<Widget> get screens {
    return [
      const HomeScreen(),
      const CustomerUdharMerchantsScreen(),
      const CustomerUdharLedgerScreen(),
      const ProfileSettingScreen(),
    ];
  }

  Widget get currentScreen {
    if (selectedIndex < 0 || selectedIndex >= screens.length) {
      return const HomeScreen(); // Fallback
    }
    return screens[selectedIndex];
  }

  void changeScreen(int index) {
    if (index >= 0 && index < screens.length) {
      selectedIndex = index;
      update();
    }
  }
}
