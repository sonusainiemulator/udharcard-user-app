import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:paysecure/config/dimensions.dart';
import 'package:paysecure/controllers/cashout_controller.dart';
import 'package:paysecure/utils/services/helpers.dart';
import 'package:paysecure/views/widgets/app_button.dart';
import 'package:paysecure/views/widgets/custom_appbar.dart';
import 'package:paysecure/views/widgets/text_theme_extension.dart';
import '../../../../config/app_colors.dart';
import '../../../../themes/themes.dart';
import '../../../../utils/services/localstorage/hive.dart';
import '../../../../utils/services/localstorage/keys.dart';
import '../../widgets/app_custom_dropdown.dart';
import '../../widgets/custom_textfield.dart';
import '../../widgets/spacing.dart';
import '../mobile_scanner/mobile_scanner_screen.dart';

class CashoutScreen extends StatelessWidget {
  final bool? isFromScannerPage;
  const CashoutScreen({super.key,this.isFromScannerPage = false});

  @override
  Widget build(BuildContext context) {
    var storedLanguage = HiveHelp.read(Keys.languageData) ?? {};
    return GetBuilder<CashoutController>(
      builder: (cashoutCtrl) {
        return Scaffold(
          appBar: CustomAppBar(title: storedLanguage['Cash Out'] ?? "Cash Out",onBackPressed: () {
              if (isFromScannerPage == true) {
                Navigator.pop(context);
                Navigator.pop(context);
              } else {
                Get.back();
              }
            },),
          body: RefreshIndicator(
            color: AppColors.mainColor,
            onRefresh: () async {
              await cashoutCtrl.getCurrency();
            },
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Padding(
                padding: Dimensions.kDefaultPadding,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    VSpace(40.h),
                    Stack(
                      alignment: Alignment.centerRight,
                      children: [
                        CustomTextField(
                          isBorderColor: true,
                          isSuffixIcon: false,
                          contentPadding: EdgeInsets.only(left: 20.w),
                          hintext:
                              storedLanguage['Agent Username/E-mail'] ??
                              'Agent Username/E-mail',
                          controller: cashoutCtrl.agentEmailController,
                          onChanged: (v) async {
                            if (v.isNotEmpty) {
                              await Future.delayed(Duration(seconds: 2));
                              await cashoutCtrl.checkAgent(agent: v.toString());
                            } else {
                              cashoutCtrl.checkRecipientmessage = "";
                              cashoutCtrl.update();
                            }
                          },
                        ),
                        IconButton(
                          onPressed: () {
                            Get.to(
                              () => MobileScannerScreen(
                                isFromCashoutPage: true,
                                context: context,
                              ),
                            );
                          },
                          icon: Icon(
                            Icons.camera_alt_outlined,
                            size: 20.h,
                            color: AppThemes.getParagraphColor(),
                          ),
                        ),
                      ],
                    ),
                    if (cashoutCtrl.checkRecipientmessage.isNotEmpty)
                      VSpace(12.h),
                    if (cashoutCtrl.checkRecipientmessage.isNotEmpty)
                      Text(
                        cashoutCtrl.checkRecipientmessage,
                        style: context.t.displayMedium?.copyWith(
                          fontSize: 15.sp,
                          color:
                              cashoutCtrl.checkRecipientmessage
                                      .toLowerCase()
                                      .contains('merchant not found')
                                  ? AppColors.redColor
                                  : AppColors.greenColor,
                        ),
                      ),
                    VSpace(32.h),
                    Container(
                      height: 50.h,
                      decoration: BoxDecoration(
                        borderRadius: Dimensions.kBorderRadius,
                        border: Border.all(
                          color: AppThemes.getSliderInactiveColor(),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: AppCustomDropDown(
                              paddingLeft: 20.w,
                              height: 50.h,
                              width: double.infinity,
                              items:
                                  cashoutCtrl.customCurrencyList
                                      .map((e) => e.currency_code)
                                      .toList(),
                              selectedValue: cashoutCtrl.selectedCurrency,
                              onChanged: (v) {
                                try {
                                  cashoutCtrl.selectedCurrency = v;
                                  cashoutCtrl.selectedCurrencyId =
                                      cashoutCtrl.customCurrencyList
                                          .firstWhere(
                                            (e) => e.currency_code == v,
                                          )
                                          .id
                                          .toString();
                                  if (cashoutCtrl
                                          .amountController
                                          .text
                                          .isNotEmpty &&
                                      cashoutCtrl.selectedCurrency != null) {
                                    cashoutCtrl.cashoutCheckAmount(
                                      fields: {
                                        "amount":
                                            cashoutCtrl.amountController.text,
                                        "currency_id":
                                            cashoutCtrl.selectedCurrencyId,
                                        "type": "cash_out",
                                      },
                                    );
                                  }
                                } catch (e) {
                                  Helpers.showSnackBar(msg: e.toString());
                                }
                                cashoutCtrl.update();
                              },
                              hint:
                                  storedLanguage['Select currency'] ??
                                  "Select currency",
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
                      ),
                    ),
                    VSpace(32.h),
                    CustomTextField(
                      isBorderColor: true,
                      isSuffixIcon: false,
                      contentPadding: EdgeInsets.only(left: 20.w),
                      hintext: storedLanguage['Enter Amount'] ?? 'Enter Amount',
                      keyboardType: TextInputType.number,
                      inputFormatters: <TextInputFormatter>[
                        FilteringTextInputFormatter.digitsOnly,
                      ],
                      controller: cashoutCtrl.amountController,
                      onChanged: (v) async {
                        try {
                          cashoutCtrl.amountVal = v.toString();
                          cashoutCtrl.update();
                          if (v.toString().isNotEmpty &&
                              cashoutCtrl.selectedCurrency != null) {
                            await Future.delayed(Duration(milliseconds: 600));
                            cashoutCtrl.cashoutCheckAmount(
                              fields: {
                                "amount": cashoutCtrl.amountController.text,
                                "currency_id": cashoutCtrl.selectedCurrencyId,
                                "type": "cash_out",
                              },
                            );
                          }
                        } catch (e) {
                          Helpers.showSnackBar(msg: e.toString());
                        }
                      },
                    ),
                    if (cashoutCtrl.amountVal.isNotEmpty &&
                        cashoutCtrl.amountCheckList.isNotEmpty)
                      VSpace(5.h),
                    if (cashoutCtrl.amountVal.isNotEmpty &&
                        cashoutCtrl.amountCheckList.isNotEmpty)
                      Text(
                        "${cashoutCtrl.amountCheckList[0].message!.message}",
                        style: context.t.bodySmall?.copyWith(
                          color:
                              cashoutCtrl.amountCheckList[0].message!.message
                                          .toString()
                                          .contains("minimum") ||
                                      cashoutCtrl
                                          .amountCheckList[0]
                                          .message!
                                          .message
                                          .toString()
                                          .contains("not have enough")
                                  ? AppColors.redColor
                                  : AppColors.greenColor,
                          fontSize: 14.sp,
                        ),
                      ),

                    if (cashoutCtrl.amountCheckList.isNotEmpty) VSpace(32.h),
                    if (cashoutCtrl.amountCheckList.isNotEmpty)
                      Container(
                        width: double.maxFinite,
                        height: 320.h,
                        padding: EdgeInsets.symmetric(
                          horizontal: 16.w,
                          vertical: 20.h,
                        ),
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
                                    color: AppThemes.getParagraphColor(),
                                  ),
                                ),
                                Expanded(
                                  child: Align(
                                    alignment: Alignment.centerRight,
                                    child: Text(
                                      "${cashoutCtrl.amountCheckList[0].message!.balance} ${cashoutCtrl.selectedCurrency.toString().split(" ").first}",
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: context.t.bodyMedium?.copyWith(
                                        color: AppColors.greenColor,
                                      ),
                                    ),
                                  ),
                                ),
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
                                    color: AppThemes.getParagraphColor(),
                                  ),
                                ),
                                Expanded(
                                  child: Align(
                                    alignment: Alignment.centerRight,
                                    child: Text(
                                      "${cashoutCtrl.amountCheckList[0].message!.charge} ${cashoutCtrl.selectedCurrency.toString().split(" ").first}",
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: context.t.bodyMedium?.copyWith(
                                        color: AppColors.redColor,
                                      ),
                                    ),
                                  ),
                                ),
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
                                    color: AppThemes.getParagraphColor(),
                                  ),
                                ),
                                Expanded(
                                  child: Align(
                                    alignment: Alignment.centerRight,
                                    child: Text(
                                      "${cashoutCtrl.amountCheckList[0].message!.transferAmount} ${cashoutCtrl.selectedCurrency.toString().split(" ").first}",
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: context.t.bodyMedium,
                                    ),
                                  ),
                                ),
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
                                  "Receiver will received",
                                  style: context.t.displayMedium?.copyWith(
                                    color: AppThemes.getParagraphColor(),
                                  ),
                                ),
                                Expanded(
                                  child: Align(
                                    alignment: Alignment.centerRight,
                                    child: Text(
                                      "${double.parse(cashoutCtrl.amountCheckList[0].message!.receivedAmount.toString()).toStringAsFixed(2)} ${cashoutCtrl.selectedCurrency.toString().split(" ").first}",
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: context.t.bodyMedium,
                                    ),
                                  ),
                                ),
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
                                  "Remaining Balance",
                                  style: context.t.displayMedium?.copyWith(
                                    color: AppThemes.getParagraphColor(),
                                  ),
                                ),
                                Expanded(
                                  child: Align(
                                    alignment: Alignment.centerRight,
                                    child: Text(
                                      "${cashoutCtrl.amountCheckList[0].message!.remainingBalance} ${cashoutCtrl.selectedCurrency.toString().split(" ").first}",
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: context.t.bodyMedium,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    VSpace(40.h),
                    AppButton(
                      isLoading: cashoutCtrl.isSubmit ? true : false,
                      onTap:
                          cashoutCtrl.isLoading || cashoutCtrl.isSubmit
                              ? null
                              : () async {
                                try {
                                  if (cashoutCtrl
                                      .agentEmailController
                                      .text
                                      .isEmpty) {
                                    Helpers.showSnackBar(
                                      msg:
                                          "Merchant Username/E-mail is required",
                                    );
                                  } else if (cashoutCtrl.selectedCurrencyId ==
                                      "0") {
                                    Helpers.showSnackBar(
                                      msg: "Please select your currency",
                                    );
                                  } else if (cashoutCtrl
                                      .amountController
                                      .text
                                      .isEmpty) {
                                    Helpers.showSnackBar(
                                      msg: "Amount field is required",
                                    );
                                  } else {
                                    await cashoutCtrl.initCashout(
                                      fields: {
                                        "recipient":
                                            cashoutCtrl
                                                .agentEmailController
                                                .text,
                                        "amount":
                                            cashoutCtrl.amountController.text,
                                        "currency_id":
                                            cashoutCtrl.selectedCurrencyId,
                                      },
                                    );
                                  }
                                } catch (e) {
                                  Helpers.showSnackBar(msg: e.toString());
                                }
                              },
                      text: storedLanguage['Cash Out'] ?? "Cash Out",
                    ),
                    VSpace(65.h),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
