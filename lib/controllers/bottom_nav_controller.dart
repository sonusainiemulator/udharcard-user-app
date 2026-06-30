import 'package:flutter/material.dart';
import 'package:paysecure/controllers/app_controller.dart';
import '../routes/page_index.dart';

class BottomNavController extends GetxController {
  static BottomNavController get to => Get.find<BottomNavController>();
  int selectedIndex = 0;
  List<Widget> screens = [
    HomeScreen(),
       if( AppController.to.basicCtrlList.isNotEmpty &&
AppController.to.basicCtrlList[0].virtualCard.toString() == '1')
    VirtualCardScreen(),
      if( AppController.to.basicCtrlList.isNotEmpty &&
AppController.to.basicCtrlList[0].virtualCard.toString() == '0')
    TransactionScreen(),
      if( AppController.to.basicCtrlList.isNotEmpty &&
AppController.to.basicCtrlList[0].exchange.toString() == '1')
    ExchangeScreen(),
      if( AppController.to.basicCtrlList.isNotEmpty &&
AppController.to.basicCtrlList[0].virtualCard.toString() == '0')
    DisputeHistoryScreen(),
    const ProfileSettingScreen(),
  ];

  Widget get currentScreen => screens[selectedIndex];

  void changeScreen(int index) {
    selectedIndex = index;
    update();
  }
}
