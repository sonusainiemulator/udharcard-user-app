import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:paysecure/config/dimensions.dart';
import 'package:paysecure/controllers/app_controller.dart';
import 'package:paysecure/controllers/pay_bill_controller.dart';
import 'package:paysecure/utils/services/helpers.dart';
import 'package:paysecure/views/widgets/app_button.dart';
import 'package:paysecure/views/widgets/custom_appbar.dart';
import 'package:paysecure/views/widgets/text_theme_extension.dart';
import '../../../config/app_colors.dart';
import '../../../routes/routes_name.dart';
import '../../../themes/themes.dart';
import '../../../utils/services/localstorage/hive.dart';
import '../../../utils/services/localstorage/keys.dart';
import '../../widgets/app_custom_dropdown.dart';
import '../../widgets/spacing.dart';

class BillCategoryScreen extends StatelessWidget {
  const BillCategoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    PayBillController.to.scrollController = ScrollController();
    var storedLanguage = HiveHelp.read(Keys.languageData) ?? {};
    List<Color> colors = [
      Color(0xff7A4EFF),
      Color(0xffFFCD05),
      Color(0xff05FF68),
      Color(0xffFFCD05),
      Color(0xff05FF68),
      Color(0xff7A4EFF),
    ];
    return GetBuilder<PayBillController>(builder: (payBillController) {
      return Scaffold(
        backgroundColor:
            Get.isDarkMode ? AppColors.darkBgColor : AppColors.scaffoldColor,
        appBar: CustomAppBar(
            bgColor: Get.isDarkMode
                ? AppColors.darkBgColor
                : AppColors.scaffoldColor,
            title: storedLanguage['Bill Category'] ?? "Bill Category"),
        body: payBillController.isLoading
            ? Helpers.appLoader()
            : RefreshIndicator(
                color: AppColors.mainColor,
                onRefresh: () async {
                  payBillController.refreshPayBillData();
                  await payBillController.getPayBill();
                },
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      VSpace(30.h),
                      Padding(
                        padding: Dimensions.kDefaultPadding,
                        child: Column(
                          children: [
                            Text("Hello!", style: context.t.titleSmall),
                            Text("${HiveHelp.read(Keys.userFullName)}",
                                style: context.t.titleSmall),
                            VSpace(24.h),
                            Text("Your Available Balance",
                                style: context.t.displayMedium?.copyWith(
                                    color: AppThemes.getParagraphColor())),
                            VSpace(5.h),
                            Text(
                                "${AppController.to.walletList.isEmpty ? "\$0.00" : AppController.to.walletList[0].currency!.symbol + Helpers.numberFormatWithAsFixed2('', AppController.to.walletList[0].totalBalance.toString())}",
                                style: context.t.titleLarge?.copyWith(
                                    fontSize: 32.sp,
                                    fontWeight: FontWeight.bold)),
                            VSpace(32.h),
                            Container(
                                height: 50.h,
                                decoration: BoxDecoration(
                                  borderRadius: Dimensions.kBorderRadius,
                                  color: AppThemes.getDarkCardColor(),
                                  border: Border.all(
                                      color: AppThemes.getSliderInactiveColor(),
                                      width: 1),
                                ),
                                child: AppCustomDropDown(
                                  paddingLeft: 20.w,
                                  height: 50.h,
                                  width: double.infinity,
                                  items: payBillController.customCurrencyList
                                      .map((e) => e.currency_code)
                                      .toList(),
                                  selectedValue:
                                      payBillController.selectedCurrency,
                                  onChanged: (v) {
                                    payBillController.selectedCurrency = v;
                                    payBillController.selectedCurrencyId =
                                        payBillController.customCurrencyList
                                            .firstWhere(
                                                (e) => e.currency_code == v)
                                            .id
                                            .toString();
                                    payBillController.update();
                                  },
                                  hint: storedLanguage['From Wallet'] ??
                                      "From Wallet",
                                  hintStyle: context.t.bodySmall?.copyWith(
                                    color: AppColors.textFieldHintColor,
                                    fontWeight: FontWeight.w400,
                                    fontSize: 18.sp,
                                  ),
                                  selectedStyle: context.t.displayMedium,
                                  bgColor: AppThemes.getFillColor(),
                                )),
                            VSpace(32.h),
                            Align(
                              alignment: Alignment.centerLeft,
                              child: Padding(
                                padding: Dimensions.kDefaultPadding / 2,
                                child: Text("Services",
                                    style: context.t.titleSmall),
                              ),
                            ),
                          ],
                        ),
                      ),
                      VSpace(20.h),
                      if (payBillController.categoryList.isNotEmpty)
                        Padding(
                          padding: EdgeInsets.zero,
                          child: GridView.builder(
                              padding: EdgeInsets.zero,
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: payBillController.categoryList.length,
                              gridDelegate:
                                  SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 3,
                              ),
                              itemBuilder: (c, index) {
                                return Column(
                                  children: [
                                    InkWell(
                                      borderRadius: BorderRadius.circular(12.r),
                                      onTap: () {
                                        payBillController.onCategoryTapped(
                                            index, context);
                                      },
                                      child: Ink(
                                        width: 70.h,
                                        height: 70.h,
                                        padding: EdgeInsets.all(20.h),
                                        decoration: BoxDecoration(
                                          color: AppThemes.getDarkCardColor(),
                                          border: Border.all(
                                              color: payBillController
                                                          .selectedIndex ==
                                                      index
                                                  ? colors[index % 6]
                                                  : AppThemes
                                                      .getDarkCardColor()),
                                          borderRadius:
                                              BorderRadius.circular(12.r),
                                        ),
                                        child: CachedNetworkImage(
                                          imageUrl: payBillController
                                              .categoryList[index].img,
                                          height: 25.h,
                                          width: 25.h,
                                          color: colors[index % 6],
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                    ),
                                    VSpace(12.h),
                                    Text(
                                        "${payBillController.categoryList[index].name}",
                                        style: context.t.displayMedium
                                            ?.copyWith(
                                                color: AppThemes
                                                    .getIconBlackColor())),
                                  ],
                                );
                              }),
                        ),
                      VSpace(40.h),
                      Padding(
                        padding: Dimensions.kDefaultPadding,
                        child: AppButton(
                          isLoading: payBillController.isSubmit ? true : false,
                          onTap: payBillController.isSubmit
                              ? null
                              : () async {
                                  try {
                                    if (payBillController
                                        .selectedCategoryVal.isEmpty) {
                                      Helpers.showSnackBar(
                                          msg: "Please select your category.");
                                    } else if (payBillController
                                        .selectedCurrencyId.isEmpty) {
                                      Helpers.showSnackBar(
                                          msg: "Please select your currency.");
                                    } else {
                                      Get.toNamed(RoutesName.payBillScreen);
                                    }
                                  } catch (e) {
                                    Helpers.showSnackBar(msg: e.toString());
                                  }
                                },
                          text: storedLanguage['Continue'] ?? "Continue",
                        ),
                      ),
                      VSpace(40.h),
                    ],
                  ),
                ),
              ),
      );
    });
  }
}
