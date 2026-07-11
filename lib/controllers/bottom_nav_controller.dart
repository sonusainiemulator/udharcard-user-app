import 'package:flutter/material.dart';
import 'package:paysecure/controllers/app_controller.dart';
import '../routes/page_index.dart';

class BottomNavController extends GetxController {
  static BottomNavController get to => Get.find<BottomNavController>();
  int selectedIndex = 0;
  List<Widget> get screens {
    final basicCtrlList = AppController.to.basicCtrlList;
    final hasVirtualCard = basicCtrlList.isNotEmpty && basicCtrlList[0].virtualCard.toString() == '1';
    final hasExchange = basicCtrlList.isNotEmpty && basicCtrlList[0].exchange.toString() == '1';

    return [
      HomeScreen(),
      hasVirtualCard ? VirtualCardScreen() : TransactionScreen(),
      hasExchange ? ExchangeScreen() : DisputeHistoryScreen(),
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
    selectedIndex = index;
    update();
  }
}
