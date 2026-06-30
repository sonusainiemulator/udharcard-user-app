import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:paysecure/config/dimensions.dart';
import 'package:paysecure/controllers/escrow_controller.dart';
import 'package:paysecure/controllers/send_money_controller.dart';
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

class EscrowScreen extends StatelessWidget {
  const EscrowScreen({super.key});

  @override
  Widget build(BuildContext context) {
    var storedLanguage = HiveHelp.read(Keys.languageData) ?? {};
    return GetBuilder<EscrowController>(
      builder: (escrowController) {
        return Scaffold(
          backgroundColor:
              Get.isDarkMode ? AppColors.darkBgColor : AppColors.scaffoldColor,
          appBar: CustomAppBar(title: storedLanguage['Escrow'] ?? "Escrow"),
          body: RefreshIndicator(
            color: AppColors.mainColor,
            onRefresh: () async {
              await escrowController.getEscrow();
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
                          storedLanguage['Recipient Email or Username'] ??
                          'Recipient Email or Username',
                      controller: escrowController.recipientEmailController,
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
                                  escrowController.customCurrencyList
                                      .map((e) => e.currency_code)
                                      .toList(),
                              selectedValue: escrowController.selectedCurrency,
                              onChanged: (v) {
                                try {
                                  escrowController.selectedCurrency = v;
                                  escrowController.selectedCurrencyId =
                                      escrowController.customCurrencyList
                                          .firstWhere(
                                            (e) => e.currency_code == v,
                                          )
                                          .id
                                          .toString();
                                  if (escrowController
                                          .amountController
                                          .text
                                          .isNotEmpty &&
                                      escrowController.selectedCurrency !=
                                          null) {
                                    escrowController.checkRedeemAmount(
                                      fields: {
                                        "amount":
                                            escrowController
                                                .amountController
                                                .text,
                                        "currency_id":
                                            escrowController.selectedCurrencyId,
                                        "transaction_type_id": "5",
                                        "charge_from": "1",
                                      },
                                    );
                                  }
                                } catch (e) {
                                  Helpers.showSnackBar(msg: e.toString());
                                }
                                escrowController.update();
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
                      controller: escrowController.amountController,
                      onChanged: (v) {
                        try {
                          escrowController.amountVal = v.toString();
                          escrowController.update();
                          if (v.toString().isNotEmpty &&
                              escrowController.selectedCurrency != null) {
                            escrowController.checkRedeemAmount(
                              fields: {
                                "amount":
                                    escrowController.amountController.text,
                                "currency_id":
                                    escrowController.selectedCurrencyId,
                                "transaction_type_id": "5",
                                "charge_from": "1",
                              },
                            );
                          }
                        } catch (e) {
                          Helpers.showSnackBar(msg: e.toString());
                        }
                      },
                    ),
                    if (escrowController.amountVal.isNotEmpty &&
                        escrowController.amountCheckList.isNotEmpty)
                      VSpace(5.h),
                    if (escrowController.amountVal.isNotEmpty &&
                        escrowController.amountCheckList.isNotEmpty)
                      Text(
                        "${escrowController.amountCheckList[0].message!.message}",
                        style: context.t.bodySmall?.copyWith(
                          color:
                              escrowController
                                          .amountCheckList[0]
                                          .message!
                                          .message
                                          .toString()
                                          .contains("minimum") ||
                                      escrowController
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
                      controller: escrowController.noteController,
                      hintext:
                          storedLanguage['Say something'] ?? "Say something",
                    ),
                    VSpace(32.h),
                    if (escrowController.amountCheckList.isNotEmpty)
                      VSpace(32.h),
                    if (escrowController.amountCheckList.isNotEmpty)
                      Container(
                        width: double.maxFinite,
                        height: 385.h,
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
                                  storedLanguage['Available Balance'] ??
                                      "Available Balance",
                                  style: context.t.displayMedium?.copyWith(
                                    color: AppThemes.getParagraphColor(),
                                  ),
                                ),
                                Expanded(
                                  child: Align(
                                    alignment: Alignment.centerRight,
                                    child: Text(
                                      "${escrowController.amountCheckList[0].message!.balance} ${escrowController.selectedCurrency.toString().split(" ").first}",
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
                                  storedLanguage['Transfer Charge'] ??
                                      "Transfer Charge",
                                  style: context.t.displayMedium?.copyWith(
                                    color: AppThemes.getParagraphColor(),
                                  ),
                                ),
                                Expanded(
                                  child: Align(
                                    alignment: Alignment.centerRight,
                                    child: Text(
                                      "${escrowController.amountCheckList[0].message!.charge} ${escrowController.selectedCurrency.toString().split(" ").first}",
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
                                  storedLanguage['Payable Amount'] ??
                                      "Payable Amount",
                                  style: context.t.displayMedium?.copyWith(
                                    color: AppThemes.getParagraphColor(),
                                  ),
                                ),
                                Expanded(
                                  child: Align(
                                    alignment: Alignment.centerRight,
                                    child: Text(
                                      "${escrowController.amountCheckList[0].message!.transferAmount} ${escrowController.selectedCurrency.toString().split(" ").first}",
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
                                  storedLanguage['Receiver will receiver'] ??
                                      "Receiver will received",
                                  style: context.t.displayMedium?.copyWith(
                                    color: AppThemes.getParagraphColor(),
                                  ),
                                ),
                                Expanded(
                                  child: Align(
                                    alignment: Alignment.centerRight,
                                    child: Text(
                                      "${double.parse(escrowController.amountCheckList[0].message!.receivedAmount.toString()).toStringAsFixed(2)} ${escrowController.selectedCurrency.toString().split(" ").first}",
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
                                  storedLanguage['Remaining Balance'] ??
                                      "Remaining Balance",
                                  style: context.t.displayMedium?.copyWith(
                                    color: AppThemes.getParagraphColor(),
                                  ),
                                ),
                                Expanded(
                                  child: Align(
                                    alignment: Alignment.centerRight,
                                    child: Text(
                                      "${escrowController.amountCheckList[0].message!.remainingBalance} ${escrowController.selectedCurrency.toString().split(" ").first}",
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
                                  storedLanguage['Min Request Limit'] ??
                                      "Min Request Limit",
                                  style: context.t.displayMedium?.copyWith(
                                    color: AppThemes.getParagraphColor(),
                                  ),
                                ),
                                Expanded(
                                  child: Align(
                                    alignment: Alignment.centerRight,
                                    child: Text(
                                      "${escrowController.amountCheckList[0].message!.minLimit} ${escrowController.selectedCurrency.toString().split(" ").first}",
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
                                  storedLanguage['Max Request Limit'] ??
                                      "Max Request Limit",
                                  style: context.t.displayMedium?.copyWith(
                                    color: AppThemes.getParagraphColor(),
                                  ),
                                ),
                                Expanded(
                                  child: Align(
                                    alignment: Alignment.centerRight,
                                    child: Text(
                                      "${escrowController.amountCheckList[0].message!.maxLimit} ${escrowController.selectedCurrency.toString().split(" ").first}",
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
                      isLoading: escrowController.isSubmit ? true : false,
                      onTap:
                          escrowController.isLoading ||
                                  escrowController.isSubmit
                              ? null
                              : () async {
                                try {
                                  if (escrowController
                                      .recipientEmailController
                                      .text
                                      .isEmpty) {
                                    Helpers.showSnackBar(
                                      msg:
                                          "Recipient Email or Username is required",
                                    );
                                  } else if (escrowController
                                          .selectedCurrencyId ==
                                      "0") {
                                    Helpers.showSnackBar(
                                      msg: "Please select your currency",
                                    );
                                  } else if (escrowController
                                      .amountController
                                      .text
                                      .isEmpty) {
                                    Helpers.showSnackBar(
                                      msg: "Amount field is required",
                                    );
                                  } else if (int.parse(
                                            escrowController.amountVal,
                                          ) <
                                          int.parse(
                                            escrowController
                                                .amountCheckList[0]
                                                .message!
                                                .minLimit
                                                .toString(),
                                          ) ||
                                      int.parse(escrowController.amountVal) >
                                          int.parse(
                                            escrowController
                                                .amountCheckList[0]
                                                .message!
                                                .maxLimit
                                                .toString(),
                                          )) {
                                    Helpers.showSnackBar(
                                      msg:
                                          "minimum payment ${escrowController.amountCheckList[0].message!.minLimit.toString()} and maximum payment limit ${escrowController.amountCheckList[0].message!.maxLimit.toString()}",
                                    );
                                  } else {
                                    await escrowController.submitEscrow(
                                      fields: {
                                        "recipient":
                                            escrowController
                                                .recipientEmailController
                                                .text,
                                        "amount":
                                            escrowController
                                                .amountController
                                                .text,
                                        "currency":
                                            escrowController.selectedCurrencyId,
                                        "note":
                                            escrowController
                                                .noteController
                                                .text,
                                      },
                                    );
                                  }
                                } catch (e) {
                                  Helpers.showSnackBar(msg: e.toString());
                                }
                              },
                      text: storedLanguage['Generate'] ?? "Generate",
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
