import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:paysecure/config/dimensions.dart';
import 'package:paysecure/controllers/voucher_controller.dart';
import 'package:paysecure/views/widgets/app_button.dart';
import 'package:paysecure/views/widgets/custom_appbar.dart';
import 'package:paysecure/views/widgets/text_theme_extension.dart';
import '../../../config/app_colors.dart';
import '../../../controllers/send_money_controller.dart';
import '../../../themes/themes.dart';
import '../../../utils/services/helpers.dart';
import '../../../utils/services/localstorage/hive.dart';
import '../../../utils/services/localstorage/keys.dart';
import '../../widgets/app_custom_dropdown.dart';
import '../../widgets/custom_textfield.dart';
import '../../widgets/spacing.dart';

class VoucherScreen extends StatelessWidget {
  const VoucherScreen({super.key});

  @override
  Widget build(BuildContext context) {
    var storedLanguage = HiveHelp.read(Keys.languageData) ?? {};
    return GetBuilder<VoucherController>(
      builder: (voucherController) {
        return Scaffold(
          backgroundColor:
              Get.isDarkMode ? AppColors.darkBgColor : AppColors.scaffoldColor,
          appBar: CustomAppBar(title: storedLanguage['Voucher'] ?? "Voucher"),
          body: RefreshIndicator(
            color: AppColors.mainColor,
            onRefresh: () async {
              await voucherController.getVoucher();
            },
            child: SingleChildScrollView(
              child: Padding(
                padding: Dimensions.kDefaultPadding,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    VSpace(40.h),
                    CustomTextField(
                      isBorderColor: true,
                      isSuffixIcon: false,
                      contentPadding: EdgeInsets.only(left: 20.w),
                      hintext:
                          storedLanguage['Recipient Email'] ??
                          'Recipient Email',
                      controller: voucherController.recipientEmailController,
                      onChanged: (v) async {
                        if (v.isNotEmpty) {
                          await Future.delayed(Duration(seconds: 2));
                          await SendMoneyController.to.checkRecipient(
                            recipient: v.toString(),
                          );
                        } else {
                          SendMoneyController.to.checkRecipientmessage = "";
                          SendMoneyController.to.update();
                        }
                      },
                    ),
                    GetBuilder<SendMoneyController>(
                      builder: (sendMoneyCtrl) {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (sendMoneyCtrl.checkRecipientmessage.isNotEmpty)
                              VSpace(12.h),
                            if (sendMoneyCtrl.checkRecipientmessage.isNotEmpty)
                              Text(
                                sendMoneyCtrl.checkRecipientmessage,
                                style: context.t.displayMedium?.copyWith(
                                  fontSize: 15.sp,
                                  color:
                                      sendMoneyCtrl.checkRecipientmessage
                                              .toLowerCase()
                                              .contains('no user found')
                                          ? AppColors.redColor
                                          : AppColors.greenColor,
                                ),
                              ),
                          ],
                        );
                      },
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
                                  voucherController.customCurrencyList
                                      .map((e) => e.currency_code)
                                      .toList(),
                              selectedValue: voucherController.selectedCurrency,
                              onChanged: (v) {
                                try {
                                  voucherController.selectedCurrency = v;
                                  voucherController.selectedCurrencyId =
                                      voucherController.customCurrencyList
                                          .firstWhere(
                                            (e) => e.currency_code == v,
                                          )
                                          .id
                                          .toString();
                                  if (voucherController
                                          .amountController
                                          .text
                                          .isNotEmpty &&
                                      voucherController.selectedCurrency !=
                                          null) {
                                    voucherController.checkRedeemAmount(
                                      fields: {
                                        "amount":
                                            voucherController
                                                .amountController
                                                .text,
                                        "currency_id":
                                            voucherController
                                                .selectedCurrencyId,
                                        "transaction_type_id": "6",
                                        "charge_from": "1",
                                      },
                                    );
                                  }
                                } catch (e) {
                                  Helpers.showSnackBar(msg: e.toString());
                                }
                                voucherController.update();
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
                      controller: voucherController.amountController,
                      onChanged: (v) {
                        try {
                          voucherController.amountVal = v.toString();
                          voucherController.update();
                          if (v.toString().isNotEmpty &&
                              voucherController.selectedCurrency != null) {
                            voucherController.checkRedeemAmount(
                              fields: {
                                "amount":
                                    voucherController.amountController.text,
                                "currency_id":
                                    voucherController.selectedCurrencyId,
                                "transaction_type_id": "6",
                                "charge_from": "1",
                              },
                            );
                          }
                        } catch (e) {
                          Helpers.showSnackBar(msg: e.toString());
                        }
                      },
                    ),
                    if (voucherController.amountVal.isNotEmpty &&
                        voucherController.amountCheckList.isNotEmpty)
                      VSpace(5.h),
                    if (voucherController.amountVal.isNotEmpty &&
                        voucherController.amountCheckList.isNotEmpty)
                      Text(
                        "${voucherController.amountCheckList[0].message!.message}",
                        style: context.t.bodySmall?.copyWith(
                          color:
                              voucherController
                                          .amountCheckList[0]
                                          .message!
                                          .message
                                          .toString()
                                          .contains("minimum") ||
                                      voucherController
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
                    VSpace(32.h),
                    CustomTextField(
                      textfieldHieght: null,
                      contentPadding: EdgeInsets.only(
                        left: 20.w,
                        bottom: 0.h,
                        top: 10.h,
                      ),
                      alignment: Alignment.topLeft,
                      minLines: 3,
                      maxLines: 5,
                      isBorderColor: true,
                      isPrefixIcon: false,
                      controller: voucherController.noteController,
                      hintext:
                          storedLanguage['Say something'] ?? "Say something",
                    ),
                    VSpace(32.h),
                    if (voucherController.amountCheckList.isNotEmpty)
                      VSpace(32.h),
                    if (voucherController.amountCheckList.isNotEmpty)
                      Container(
                        width: double.maxFinite,
                        height: 400.h,
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
                                      "${voucherController.amountCheckList[0].message!.balance} ${voucherController.selectedCurrency.toString().split(" ").first}",
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
                                      "${voucherController.amountCheckList[0].message!.charge} ${voucherController.selectedCurrency.toString().split(" ").first}",
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: context.t.bodyMedium?.copyWith(
                                        color: AppColors.mainColor,
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
                                  "Request Amount",
                                  style: context.t.displayMedium?.copyWith(
                                    color: AppThemes.getParagraphColor(),
                                  ),
                                ),
                                Expanded(
                                  child: Align(
                                    alignment: Alignment.centerRight,
                                    child: Text(
                                      "${voucherController.amountCheckList[0].message!.transferAmount} ${voucherController.selectedCurrency.toString().split(" ").first}",
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
                                  "Receivable Amount",
                                  style: context.t.displayMedium?.copyWith(
                                    color: AppThemes.getParagraphColor(),
                                  ),
                                ),
                                Expanded(
                                  child: Align(
                                    alignment: Alignment.centerRight,
                                    child: Text(
                                      "${double.parse(voucherController.amountCheckList[0].message!.receivedAmount.toString()).toStringAsFixed(2)} ${voucherController.selectedCurrency.toString().split(" ").first}",
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
                                      "${voucherController.amountCheckList[0].message!.remainingBalance} ${voucherController.selectedCurrency.toString().split(" ").first}",
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
                                  "Min Request Limit",
                                  style: context.t.displayMedium?.copyWith(
                                    color: AppThemes.getParagraphColor(),
                                  ),
                                ),
                                Expanded(
                                  child: Align(
                                    alignment: Alignment.centerRight,
                                    child: Text(
                                      "${voucherController.amountCheckList[0].message!.minLimit} ${voucherController.selectedCurrency.toString().split(" ").first}",
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
                                  "Max Request Limit",
                                  style: context.t.displayMedium?.copyWith(
                                    color: AppThemes.getParagraphColor(),
                                  ),
                                ),
                                Expanded(
                                  child: Align(
                                    alignment: Alignment.centerRight,
                                    child: Text(
                                      "${voucherController.amountCheckList[0].message!.maxLimit} ${voucherController.selectedCurrency.toString().split(" ").first}",
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
                      isLoading: voucherController.isSubmit ? true : false,
                      onTap:
                          voucherController.isLoading ||
                                  voucherController.isSubmit
                              ? null
                              : () async {
                                try {
                                  if (voucherController
                                      .recipientEmailController
                                      .text
                                      .isEmpty) {
                                    Helpers.showSnackBar(
                                      msg:
                                          "Recipient Email or Username is required",
                                    );
                                  } else if (voucherController
                                          .selectedCurrencyId ==
                                      "0") {
                                    Helpers.showSnackBar(
                                      msg: "Please select your currency",
                                    );
                                  } else if (voucherController
                                      .amountController
                                      .text
                                      .isEmpty) {
                                    Helpers.showSnackBar(
                                      msg: "Amount field is required",
                                    );
                                  } else if (int.parse(
                                            voucherController.amountVal,
                                          ) <
                                          int.parse(
                                            voucherController
                                                .amountCheckList[0]
                                                .message!
                                                .minLimit
                                                .toString(),
                                          ) ||
                                      int.parse(voucherController.amountVal) >
                                          int.parse(
                                            voucherController
                                                .amountCheckList[0]
                                                .message!
                                                .maxLimit
                                                .toString(),
                                          )) {
                                    Helpers.showSnackBar(
                                      msg:
                                          "minimum payment ${voucherController.amountCheckList[0].message!.minLimit.toString()} and maximum payment limit ${voucherController.amountCheckList[0].message!.maxLimit.toString()}",
                                    );
                                  } else {
                                    await voucherController.voucherSubmit(
                                      fields: {
                                        "recipient":
                                            voucherController
                                                .recipientEmailController
                                                .text,
                                        "amount":
                                            voucherController
                                                .amountController
                                                .text,
                                        "currency":
                                            voucherController
                                                .selectedCurrencyId,
                                        "note":
                                            voucherController
                                                .noteController
                                                .text,
                                      },
                                    );
                                  }
                                } catch (e) {
                                  Helpers.showSnackBar(msg: e.toString());
                                }
                              },
                      text:
                          storedLanguage['Create Voucher'] ?? "Create Voucher",
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
