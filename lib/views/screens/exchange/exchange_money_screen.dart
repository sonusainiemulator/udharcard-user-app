import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:paysecure/config/dimensions.dart';
import 'package:paysecure/controllers/bindings/controller_index.dart';
import 'package:paysecure/controllers/exchange_controller.dart';
import 'package:paysecure/views/widgets/app_button.dart';
import 'package:paysecure/views/widgets/custom_appbar.dart';
import 'package:paysecure/views/widgets/text_theme_extension.dart';
import '../../../config/app_colors.dart';
import '../../../themes/themes.dart';
import '../../../utils/services/helpers.dart';
import '../../../utils/services/localstorage/hive.dart';
import '../../../utils/services/localstorage/keys.dart';
import '../../widgets/app_custom_dropdown.dart';
import '../../widgets/custom_textfield.dart';
import '../../widgets/spacing.dart';

class ExchangeScreen extends StatelessWidget {
  const ExchangeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    var storedLanguage = HiveHelp.read(Keys.languageData) ?? {};
    return GetBuilder<ExchangeController>(builder: (exchangeController) {
      return GetBuilder<BottomNavController>(builder: (b) {
        return Scaffold(
          backgroundColor:
              Get.isDarkMode ? AppColors.darkBgColor : AppColors.scaffoldColor,
          appBar: CustomAppBar(
            title: storedLanguage['Exchange'] ?? "Exchange",
            leading:
                BottomNavController.to.selectedIndex == 2 ? SizedBox() : null,
          ),
          body: RefreshIndicator(
            color: AppColors.mainColor,
            onRefresh: () async {
              await exchangeController.getexchangeMoney();
            },
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Padding(
                padding: Dimensions.kDefaultPadding,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    VSpace(40.h),
                    Container(
                        height: 50.h,
                        decoration: BoxDecoration(
                          borderRadius: Dimensions.kBorderRadius,
                          border: Border.all(
                              color: AppThemes.getSliderInactiveColor(),
                              width: 1),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: AppCustomDropDown(
                                paddingLeft: 20.w,
                                height: 50.h,
                                width: double.infinity,
                                items: exchangeController.customFromWalletCurrencyList
                                    .map((e) => e.currency_code)
                                    .toList(),
                                selectedValue: exchangeController.selectedFromWalletCurrency,
                                onChanged: (v) {
                                  try {
                                    exchangeController.selectedFromWalletCurrency = v;
                                    exchangeController.selectedFromWalletCurrencyId = exchangeController
                                        .customFromWalletCurrencyList
                                        .firstWhere((e) => e.currency_code == v)
                                        .id
                                        .toString();
                                    exchangeController.filterToWalletData(v);
                                    if (exchangeController.amountController.text.isNotEmpty &&
                                        exchangeController.selectedFromWalletCurrency != null) {
                                      exchangeController.checkRedeemAmount(fields: {
                                        "amount": exchangeController.amountController.text,
                                        "currency_id":
                                            exchangeController.selectedFromWalletCurrencyId,
                                        "transaction_type_id": "3",
                                        "charge_from": "0",
                                      });
                                    }
                                  } catch (e) {
                                    Helpers.showSnackBar(msg: e.toString());
                                  }
                                  exchangeController.update();
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
                              ),
                            ),
                          ],
                        )),
                    VSpace(32.h),
                    Container(
                        height: 50.h,
                        decoration: BoxDecoration(
                          borderRadius: Dimensions.kBorderRadius,
                          border: Border.all(
                              color: AppThemes.getSliderInactiveColor(),
                              width: 1),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: AppCustomDropDown(
                                paddingLeft: 20.w,
                                height: 50.h,
                                width: double.infinity,
                                items: exchangeController.selectedFromWalletCurrency == null
                                    ? []
                                    : exchangeController.toWalletList
                                        .map((e) => e.currency_code)
                                        .toList(),
                                selectedValue: exchangeController.selectedToWalletCurrency,
                                onChanged: (v) {
                                  try {
                                    exchangeController.selectedToWalletCurrency = v;
                                    exchangeController.selectedToWalletCurrencyId = exchangeController
                                        .toWalletList
                                        .firstWhere((e) => e.currency_code == v)
                                        .id
                                        .toString();
                                 
                                  } catch (e) {
                                    Helpers.showSnackBar(msg: e.toString());
                                  }
                                  exchangeController.update();
                                },
                                isCustomHintShow: true,
                                hint:
                                    storedLanguage['To Wallet'] ?? "To Wallet",
                                hintStyle: context.t.bodySmall?.copyWith(
                                  color: AppColors.textFieldHintColor,
                                  fontWeight: FontWeight.w400,
                                  fontSize: 18.sp,
                                ),
                                selectedStyle: context.t.displayMedium,
                                bgColor: AppThemes.getFillColor(),
                              ),
                            ),
                          ],
                        )),
                    VSpace(32.h),
                    CustomTextField(
                      isBorderColor: true,
                      isSuffixIcon: false,
                      contentPadding: EdgeInsets.only(left: 20.w),
                      hintext: storedLanguage['Enter Amount'] ?? 'Enter Amount',
                      keyboardType: TextInputType.number,
                      focusNode: exchangeController.amountFocusNode,
                      inputFormatters: <TextInputFormatter>[
                        FilteringTextInputFormatter.digitsOnly,
                      ],
                      controller: exchangeController.amountController,
                      onChanged: (v) {
                        try {
                          exchangeController.amountVal = v.toString();
                          exchangeController.update();
                          if (v.toString().isNotEmpty &&
                              exchangeController.selectedFromWalletCurrency != null) {
                            exchangeController.checkRedeemAmount(fields: {
                              "amount": exchangeController.amountController.text,
                              "currency_id": exchangeController.selectedFromWalletCurrencyId,
                              "transaction_type_id": "3",
                              "charge_from": "0",
                            });
                          }
                        } catch (e) {
                          Helpers.showSnackBar(msg: e.toString());
                        }
                      },
                    ),
                    if (exchangeController.amountVal.isNotEmpty && exchangeController.amountCheckList.isNotEmpty)
                      VSpace(5.h),
                    if (exchangeController.amountVal.isNotEmpty && exchangeController.amountCheckList.isNotEmpty)
                      Text(
                        "${exchangeController.amountCheckList[0].message!.message}",
                        style: context.t.bodySmall?.copyWith(
                          color: exchangeController.amountCheckList[0].message!.message
                                      .toString()
                                      .contains("minimum") ||
                                  exchangeController.amountCheckList[0].message!.message
                                      .toString()
                                      .contains("not have enough")
                              ? AppColors.redColor
                              : AppColors.greenColor,
                          fontSize: 14.sp,
                        ),
                      ),
                    VSpace(32.h),
                    if (exchangeController.amountCheckList.isNotEmpty)
                      Container(
                          width: double.maxFinite,
                          height: 329.h,
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
                                    "Available Balance",
                                    style: context.t.displayMedium?.copyWith(
                                        color: AppThemes.getParagraphColor()),
                                  ),
                                  Expanded(
                                      child: Align(
                                    alignment: Alignment.centerRight,
                                    child: Text(
                                        "${exchangeController.amountCheckList[0].message!.balance} ${exchangeController.selectedFromWalletCurrency.toString().split(" ").first}",
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
                                    "Transfer Charge",
                                    style: context.t.displayMedium?.copyWith(
                                        color: AppThemes.getParagraphColor()),
                                  ),
                                  Expanded(
                                      child: Align(
                                    alignment: Alignment.centerRight,
                                    child: Text(
                                        "${exchangeController.amountCheckList[0].message!.charge} ${exchangeController.selectedFromWalletCurrency.toString().split(" ").first}",
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: context.t.bodyMedium?.copyWith(
                                            color: AppColors.mainColor)),
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
                                    "Payable Amount",
                                    style: context.t.displayMedium?.copyWith(
                                        color: AppThemes.getParagraphColor()),
                                  ),
                                  Expanded(
                                      child: Align(
                                    alignment: Alignment.centerRight,
                                    child: Text(
                                        "${exchangeController.amountCheckList[0].message!.transferAmount} ${exchangeController.selectedFromWalletCurrency.toString().split(" ").first}",
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
                                    "You will Get",
                                    style: context.t.displayMedium?.copyWith(
                                        color: AppThemes.getParagraphColor()),
                                  ),
                                  Expanded(
                                      child: Align(
                                    alignment: Alignment.centerRight,
                                    child: Text(
                                        "${exchangeController.amountCheckList[0].message!.receivedAmount} ${exchangeController.selectedFromWalletCurrency.toString().split(" ").first}",
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
                                    "Exchange Rate",
                                    style: context.t.displayMedium?.copyWith(
                                        color: AppThemes.getParagraphColor()),
                                  ),
                                  Expanded(
                                      child: Align(
                                    alignment: Alignment.centerRight,
                                    // child: Text("1 USD = 0.92 EUR",
                                    child: Text(
                                        "${exchangeController.amountCheckList[0].message!.balance} ${exchangeController.selectedFromWalletCurrency.toString().split(" ").first}",
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: context.t.bodyMedium),
                                  )),
                                ],
                              ),
                            ],
                          )),
                    VSpace(40.h),
                    AppButton(
                      isLoading: exchangeController.isSubmit ? true : false,
                      onTap: exchangeController.isLoading || exchangeController.isSubmit
                          ? null
                          : () async {
                              try {
                                if (exchangeController.selectedFromWalletCurrencyId == "0") {
                                  Helpers.showSnackBar(
                                      msg:
                                          "Please select From Wallet currency");
                                }
                                if (exchangeController.selectedToWalletCurrencyId == "0") {
                                  Helpers.showSnackBar(
                                      msg: "Please select To Wallet currency");
                                } else if (exchangeController.amountController.text.isEmpty) {
                                  Helpers.showSnackBar(
                                      msg: "Amount field is required");
                                } else {
                                  await exchangeController.submitExchangeMoney(fields: {
                                    "from_wallet":
                                        exchangeController.selectedFromWalletCurrencyId,
                                    "to_wallet": exchangeController.selectedToWalletCurrencyId,
                                    "amount": exchangeController.amountController.text,
                                  });
                                }
                              } catch (e) {
                                Helpers.showSnackBar(msg: e.toString());
                              }
                            },
                      text:
                          storedLanguage['Exchange Money'] ?? "Exchange Money",
                    ),
                    VSpace(65.h),
                  ],
                ),
              ),
            ),
          ),
        );
      });
    });
  }
}
