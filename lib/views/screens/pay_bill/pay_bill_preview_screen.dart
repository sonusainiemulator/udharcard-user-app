import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:paysecure/config/dimensions.dart';
import 'package:paysecure/controllers/pay_bill_controller.dart';
import 'package:paysecure/utils/services/helpers.dart';
import 'package:paysecure/views/widgets/app_button.dart';
import 'package:paysecure/views/widgets/custom_appbar.dart';
import 'package:paysecure/views/widgets/text_theme_extension.dart';
import '../../../config/app_colors.dart';
import '../../../themes/themes.dart';
import '../../../utils/services/localstorage/hive.dart';
import '../../../utils/services/localstorage/keys.dart';
import '../../widgets/custom_textfield.dart';
import '../../widgets/spacing.dart';

class PayBillPreviewScreen extends StatelessWidget {
  final String? utr;
  const PayBillPreviewScreen({super.key, this.utr = ""});

  @override
  Widget build(BuildContext context) {
    var storedLanguage = HiveHelp.read(Keys.languageData) ?? {};
    return GetBuilder<PayBillController>(builder: (payBillController) {
      return Scaffold(
        backgroundColor:
            Get.isDarkMode ? AppColors.darkBgColor : AppColors.scaffoldColor,
        appBar: CustomAppBar(title: storedLanguage['Pay Bill'] ?? "Pay Bill"),
        body: payBillController.isGettingPrev
            ? Helpers.appLoader()
            : SingleChildScrollView(
                child: Padding(
                  padding: Dimensions.kDefaultPadding,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      VSpace(40.h),
                      if (payBillController.payBillPrevList.isNotEmpty)
                        Container(
                            width: double.maxFinite,
                            height: 482.h,
                            padding: EdgeInsets.symmetric(
                                horizontal: 16.w, vertical: 20.h),
                            decoration: BoxDecoration(
                              color: AppThemes.getDarkCardColor(),
                              borderRadius: Dimensions.kBorderRadius,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      storedLanguage['Category'] ?? "Category",
                                      style: context.t.displayMedium?.copyWith(
                                          color: AppThemes.getParagraphColor()),
                                    ),
                                    Expanded(
                                        child: Align(
                                      alignment: Alignment.centerRight,
                                      child: Text(
                                          "${payBillController.payBillPrevList[0].message!.category}",
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: context.t.bodyMedium),
                                    )),
                                  ],
                                ),
                                Container(
                                  width: double.maxFinite,
                                  height: .5,
                                  color: AppThemes.getSliderInactiveColor(),
                                ),
                                Row(
                                  children: [
                                    Text(
                                      storedLanguage['Service'] ?? "Service",
                                      style: context.t.displayMedium?.copyWith(
                                          color: AppThemes.getParagraphColor()),
                                    ),
                                    Expanded(
                                        child: Align(
                                      alignment: Alignment.centerRight,
                                      child: Text(
                                          "${payBillController.payBillPrevList[0].message!.service}",
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: context.t.bodyMedium),
                                    )),
                                  ],
                                ),
                                Container(
                                  width: double.maxFinite,
                                  height: .5,
                                  color: AppThemes.getSliderInactiveColor(),
                                ),
                                Row(
                                  children: [
                                    Text(
                                      storedLanguage['Country Code'] ??
                                          "Country Code",
                                      style: context.t.displayMedium?.copyWith(
                                          color: AppThemes.getParagraphColor()),
                                    ),
                                    Expanded(
                                        child: Align(
                                      alignment: Alignment.centerRight,
                                      child: Text(
                                          "${payBillController.payBillPrevList[0].message!.countryCode}",
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: context.t.bodyMedium),
                                    )),
                                  ],
                                ),
                                Container(
                                  width: double.maxFinite,
                                  height: .5,
                                  color: AppThemes.getSliderInactiveColor(),
                                ),
                                Row(
                                  children: [
                                    Text(
                                      storedLanguage['From Wallet'] ??
                                          "From Wallet",
                                      style: context.t.displayMedium?.copyWith(
                                          color: AppThemes.getParagraphColor()),
                                    ),
                                    Expanded(
                                        child: Align(
                                      alignment: Alignment.centerRight,
                                      child: Text(
                                          "${payBillController.payBillPrevList[0].message!.fromWalletCode} - ${payBillController.payBillPrevList[0].message!.fromWalletName}",
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: context.t.bodyMedium),
                                    )),
                                  ],
                                ),
                                Container(
                                  width: double.maxFinite,
                                  height: .5,
                                  color: AppThemes.getSliderInactiveColor(),
                                ),
                                Row(
                                  children: [
                                    Text(
                                      storedLanguage['Exchange Rate'] ??
                                          "Exchange Rate",
                                      style: context.t.displayMedium?.copyWith(
                                          color: AppThemes.getParagraphColor()),
                                    ),
                                    Expanded(
                                        child: Align(
                                      alignment: Alignment.centerRight,
                                      child: Text(
                                          "1 ${payBillController.payBillPrevList[0].message!.fromWalletCode} = ${Helpers.numberFormatWithAsFixed2('', payBillController.payBillPrevList[0].message!.exchangeRate)} ${payBillController.payBillPrevList[0].message!.currencyCode}",
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: context.t.bodyMedium),
                                    )),
                                  ],
                                ),
                                Container(
                                  width: double.maxFinite,
                                  height: .5,
                                  color: AppThemes.getSliderInactiveColor(),
                                ),
                                Row(
                                  children: [
                                    Text(
                                      storedLanguage['Amount'] ?? "Amount",
                                      style: context.t.displayMedium?.copyWith(
                                          color: AppThemes.getParagraphColor()),
                                    ),
                                    Expanded(
                                        child: Align(
                                      alignment: Alignment.centerRight,
                                      child: Text(
                                          "${Helpers.numberFormatWithAsFixed2('', (double.parse(payBillController.payBillPrevList[0].message!.exchangeRate.toString()) * double.parse(payBillController.payBillPrevList[0].message!.amount.toString())).toString())} ${payBillController.payBillPrevList[0].message!.currencyCode}",
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: context.t.bodyMedium),
                                    )),
                                  ],
                                ),
                                Container(
                                  width: double.maxFinite,
                                  height: .5,
                                  color: AppThemes.getSliderInactiveColor(),
                                ),
                                Row(
                                  children: [
                                    Text(
                                      storedLanguage['Charge'] ?? "Charge",
                                      style: context.t.displayMedium?.copyWith(
                                          color: AppThemes.getParagraphColor()),
                                    ),
                                    Expanded(
                                        child: Align(
                                      alignment: Alignment.centerRight,
                                      child: Text(
                                          "${payBillController.payBillPrevList[0].message!.charge} ${payBillController.payBillPrevList[0].message!.currencyCode}",
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: context.t.bodyMedium?.copyWith(
                                              color: AppColors.redColor)),
                                    )),
                                  ],
                                ),
                                Container(
                                  width: double.maxFinite,
                                  height: .5,
                                  color: AppThemes.getSliderInactiveColor(),
                                ),
                                Row(
                                  children: [
                                    Text(
                                      storedLanguage['Payable Amount'] ??
                                          "Payable Amount",
                                      style: context.t.displayMedium?.copyWith(
                                          color: AppThemes.getParagraphColor()),
                                    ),
                                    Expanded(
                                        child: Align(
                                      alignment: Alignment.centerRight,
                                      child: Text(
                                          "${payBillController.payBillPrevList[0].message!.amount.toString()} ${payBillController.payBillPrevList[0].message!.fromWalletCode}",
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: context.t.bodyMedium),
                                    )),
                                  ],
                                ),
                              ],
                            )),
                      if (payBillController.payBillPrevList[0].message!.enableFor == true)
                        VSpace(48.h),
                      if (payBillController.payBillPrevList[0].message!.enableFor == true)
                        CustomTextField(
                          isBorderColor: false,
                          isSuffixIcon: false,
                          contentPadding: EdgeInsets.only(left: 20.w),
                          hintext:
                              storedLanguage['Security Pin'] ?? 'Security Pin',
                          keyboardType: TextInputType.number,
                          inputFormatters: <TextInputFormatter>[
                            FilteringTextInputFormatter.digitsOnly,
                          ],
                          controller: payBillController.securityPinController,
                          onChanged: (v) {},
                        ),
                      VSpace(40.h),
                      AppButton(
                        isLoading: payBillController.isSubmit ? true : false,
                        onTap: payBillController.isSubmit
                            ? null
                            : () async {
                                if (utr != null && utr!.isNotEmpty) {
                                  if (payBillController.payBillPrevList[0].message!.enableFor ==
                                      true) {
                                    if (payBillController.securityPinController.text
                                        .isNotEmpty) {
                                      await payBillController.payBillPreviewSubmit(fields: {
                                        "utr": utr,
                                        "security_pin":
                                            payBillController.securityPinController.text,
                                      });
                                    } else {
                                      Helpers.showSnackBar(
                                          msg: "Security Pin is required.");
                                    }
                                  } else {
                                    await payBillController.payBillPreviewSubmit(fields: {
                                      "utr": utr,
                                    });
                                  }
                                } else {
                                  Helpers.showSnackBar(
                                      msg: "Utr is null or empty");
                                }
                              },
                        text: storedLanguage['Confirm'] ?? "Confirm",
                      ),
                    ],
                  ),
                ),
              ),
      );
    });
  }
}
