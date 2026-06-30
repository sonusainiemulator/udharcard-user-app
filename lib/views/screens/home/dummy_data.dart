import 'package:paysecure/utils/app_constants.dart';
import '../../../controllers/app_controller.dart';

class DummyData {
  List<Category> categoryBigList = [
    Category(
      text: "Transaction",
      img: "$rootImageDir/transaction.webp",
      subCategory: SubCategory(subText: ['']),
    ),
    if (AppController.to.basicCtrlList.isNotEmpty &&
        AppController.to.basicCtrlList[0].invoice.toString() == '1')
      Category(
        text: "Invoice",
        img: "$rootImageDir/invoice.webp",
        subCategory: SubCategory(subText: ['Create Invoice', 'Invoice List']),
      ),
    Category(
      text: "Support Ticket",
      img: "$rootImageDir/support.webp",
      subCategory: SubCategory(subText: ['']),
    ),
  ];
}

class Category {
  final String text;
  final String img;
  final SubCategory subCategory;
  Category({required this.text, required this.img, required this.subCategory});
}

class SubCategory {
  final List<String> subText;
  SubCategory({required this.subText});
}
