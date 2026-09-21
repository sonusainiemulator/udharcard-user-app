import 'package:flutter/material.dart';
import '../routes/page_index.dart';

class BottomNavController extends GetxController {
  static BottomNavController get to => Get.find<BottomNavController>();
  int selectedIndex = 0;
  List<Widget> get screens {
    return [
      HomeScreen(),
      TransactionScreen(),
      const ProfileSettingScreen(),
    ];
  }

  Widget get currentScreen {
    if (selectedIndex < 0 || selectedIndex >= screens.length) {
      return HomeScreen(); // Fallback
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
