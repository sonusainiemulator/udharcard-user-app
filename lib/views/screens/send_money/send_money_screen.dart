import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:paysecure/config/dimensions.dart';
import 'package:paysecure/controllers/send_money_controller.dart';
import 'package:paysecure/utils/app_constants.dart';
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

class SendMoneyScreen extends StatelessWidget {
  const SendMoneyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    var storedLanguage = HiveHelp.read(Keys.languageData) ?? {};
    return GetBuilder<SendMoneyController>(
      builder: (sendMoneyController) {
        return Scaffold(
          backgroundColor:
              Get.isDarkMode ? AppColors.darkBgColor : AppColors.scaffoldColor,
          appBar: CustomAppBar(
            title: storedLanguage['Send Money'] ?? "Send Money",
          ),
          body: RefreshIndicator(
            color: AppColors.mainColor,
            onRefresh: () async {
              await sendMoneyController.getsendMoney();
            },
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
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
                      controller: sendMoneyController.recipientEmailController,
                      onChanged: (v) async {
                        if (v.isNotEmpty) {
                          await Future.delayed(Duration(seconds: 2));
                          await sendMoneyController.checkRecipient(
                            recipient: v.toString(),
                          );
                        } else {
                          sendMoneyController.checkRecipientmessage = "";
                          sendMoneyController.update();
                        }
                      },
                    ),
                    if (sendMoneyController.checkRecipientmessage.isNotEmpty)
                      VSpace(12.h),
                    if (sendMoneyController.checkRecipientmessage.isNotEmpty)
                      Text(
                        sendMoneyController.checkRecipientmessage,
                        style: context.t.displayMedium?.copyWith(
                          fontSize: 15.sp,
                          color:
                              sendMoneyController.checkRecipientmessage
                                      .toLowerCase()
                                      .contains('no user found')
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
                                  sendMoneyController.customCurrencyList
                                      .map((e) => e.currency_code)
                                      .toList(),
                              selectedValue:
                                  sendMoneyController.selectedCurrency,
                              onChanged: (v) {
                                try {
                                  sendMoneyController.selectedCurrency = v;
                                  sendMoneyController.selectedCurrencyId =
                                      sendMoneyController.customCurrencyList
                                          .firstWhere(
                                            (e) => e.currency_code == v,
                                          )
                                          .id
                                          .toString();
                                  if (sendMoneyController
                                          .amountController
                                          .text
                                          .isNotEmpty &&
                                      sendMoneyController.selectedCurrency !=
                                          null) {
                                    sendMoneyController.checkRedeemAmount(
                                      fields: {
                                        "amount":
                                            sendMoneyController
                                                .amountController
                                                .text,
                                        "currency_id":
                                            sendMoneyController
                                                .selectedCurrencyId,
                                        "transaction_type_id": "1",
                                        "charge_from":
                                            sendMoneyController.isChargeFrom
                                                ? "1"
                                                : "0",
                                      },
                                    );
                                  }
                                } catch (e) {
                                  Helpers.showSnackBar(msg: e.toString());
                                }
                                sendMoneyController.update();
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
                      controller: sendMoneyController.amountController,
                      onChanged: (v) {
                        try {
                          sendMoneyController.amountVal = v.toString();
                          sendMoneyController.update();
                          if (v.toString().isNotEmpty &&
                              sendMoneyController.selectedCurrency != null) {
                            sendMoneyController.checkRedeemAmount(
                              fields: {
                                "amount":
                                    sendMoneyController.amountController.text,
                                "currency_id":
                                    sendMoneyController.selectedCurrencyId,
                                "transaction_type_id": "1",
                                "charge_from":
                                    sendMoneyController.isChargeFrom
                                        ? "1"
                                        : "0",
                              },
                            );
                          }
                        } catch (e) {
                          Helpers.showSnackBar(msg: e.toString());
                        }
                      },
                    ),
                    if (sendMoneyController.amountVal.isNotEmpty &&
                        sendMoneyController.amountCheckList.isNotEmpty)
                      VSpace(5.h),
                    if (sendMoneyController.amountVal.isNotEmpty &&
                        sendMoneyController.amountCheckList.isNotEmpty)
                      Text(
                        "${sendMoneyController.amountCheckList[0].message!.message}",
                        style: context.t.bodySmall?.copyWith(
                          color:
                              sendMoneyController
                                          .amountCheckList[0]
                                          .message!
                                          .message
                                          .toString()
                                          .contains("minimum") ||
                                      sendMoneyController
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
                    VSpace(12.h),
                    Row(
                      children: [
                        Transform.scale(
                          scale: .6,
                          child: SizedBox(
                            width: 50.w,
                            child: Switch(
                              value: sendMoneyController.isChargeFrom,
                              activeColor: AppColors.mainColor,
                              onChanged: (v) {
                                try {
                                  sendMoneyController.isChargeFrom = v;
                                  if (sendMoneyController
                                          .amountController
                                          .text
                                          .isNotEmpty &&
                                      sendMoneyController.selectedCurrency !=
                                          null) {
                                    sendMoneyController.checkRedeemAmount(
                                      fields: {
                                        "amount":
                                            sendMoneyController
                                                .amountController
                                                .text,
                                        "currency_id":
                                            sendMoneyController
                                                .selectedCurrencyId,
                                        "transaction_type_id": "1",
                                        "charge_from":
                                            sendMoneyController.isChargeFrom
                                                ? "1"
                                                : "0",
                                      },
                                    );
                                  }
                                } catch (e) {
                                  Helpers.showSnackBar(msg: e.toString());
                                }
                                sendMoneyController.update();
                              },
                            ),
                          ),
                        ),
                        HSpace(8.w),
                        Text(
                          storedLanguage['Reciever will pay the txn charge'] ??
                              "Reciever will pay the txn charge",
                          style: context.t.bodySmall,
                        ),
                        HSpace(8.w),
                        Padding(
                          padding: EdgeInsets.only(top: 5.h),
                          child: Tooltip(
                            message:
                                storedLanguage['If enable transaction charge will be deduct from receiver.'] ??
                                "If enable transaction charge will be deduct from receiver.",
                            child: Image.asset(
                              "$rootImageDir/i_button.webp",
                              height: 12.h,
                              width: 12.h,
                              fit: BoxFit.cover,
                              color: AppThemes.getIconBlackColor(),
                            ),
                          ),
                        ),
                      ],
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
                      controller: sendMoneyController.noteController,
                      hintext:
                          storedLanguage['Say something'] ?? "Say something",
                    ),
                    if (sendMoneyController.amountCheckList.isNotEmpty)
                      VSpace(32.h),
                    if (sendMoneyController.amountCheckList.isNotEmpty)
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
                                  "Available Balance",
                                  style: context.t.displayMedium?.copyWith(
                                    color: AppThemes.getParagraphColor(),
                                  ),
                                ),
                                Expanded(
                                  child: Align(
                                    alignment: Alignment.centerRight,
                                    child: Text(
                                      "${sendMoneyController.amountCheckList[0].message!.balance} ${sendMoneyController.selectedCurrency.toString().split(" ").first}",
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
                                      "${sendMoneyController.amountCheckList[0].message!.charge} ${sendMoneyController.selectedCurrency.toString().split(" ").first}",
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
                                  "Payable Amount",
                                  style: context.t.displayMedium?.copyWith(
                                    color: AppThemes.getParagraphColor(),
                                  ),
                                ),
                                Expanded(
                                  child: Align(
                                    alignment: Alignment.centerRight,
                                    child: Text(
                                      "${sendMoneyController.amountCheckList[0].message!.transferAmount} ${sendMoneyController.selectedCurrency.toString().split(" ").first}",
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
                                      "${double.parse(sendMoneyController.amountCheckList[0].message!.receivedAmount.toString()).toStringAsFixed(2)} ${sendMoneyController.selectedCurrency.toString().split(" ").first}",
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
                                      "${sendMoneyController.amountCheckList[0].message!.remainingBalance} ${sendMoneyController.selectedCurrency.toString().split(" ").first}",
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
                                      "${sendMoneyController.amountCheckList[0].message!.minLimit} ${sendMoneyController.selectedCurrency.toString().split(" ").first}",
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
                                      "${sendMoneyController.amountCheckList[0].message!.maxLimit} ${sendMoneyController.selectedCurrency.toString().split(" ").first}",
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
                      isLoading: sendMoneyController.isSubmit ? true : false,
                      onTap:
                          sendMoneyController.isLoading ||
                                  sendMoneyController.isSubmit
                              ? null
                              : () async {
                                try {
                                  if (sendMoneyController
                                      .recipientEmailController
                                      .text
                                      .isEmpty) {
                                    Helpers.showSnackBar(
                                      msg:
                                          "Recipient Email or Username is required",
                                    );
                                  } else if (sendMoneyController
                                          .selectedCurrencyId ==
                                      "0") {
                                    Helpers.showSnackBar(
                                      msg: "Please select your currency",
                                    );
                                  } else if (sendMoneyController
                                      .amountController
                                      .text
                                      .isEmpty) {
                                    Helpers.showSnackBar(
                                      msg: "Amount field is required",
                                    );
                                  } else if (int.parse(
                                            sendMoneyController.amountVal,
                                          ) <
                                          int.parse(
                                            sendMoneyController
                                                .amountCheckList[0]
                                                .message!
                                                .minLimit
                                                .toString(),
                                          ) ||
                                      int.parse(sendMoneyController.amountVal) >
                                          int.parse(
                                            sendMoneyController
                                                .amountCheckList[0]
                                                .message!
                                                .maxLimit
                                                .toString(),
                                          )) {
                                    Helpers.showSnackBar(
                                      msg:
                                          "minimum payment ${sendMoneyController.amountCheckList[0].message!.minLimit.toString()} and maximum payment limit ${sendMoneyController.amountCheckList[0].message!.maxLimit.toString()}",
                                    );
                                  } else {
                                    await sendMoneyController.submitSendMoney(
                                      fields: {
                                        "recipient":
                                            sendMoneyController
                                                .recipientEmailController
                                                .text,
                                        "amount":
                                            sendMoneyController
                                                .amountController
                                                .text,
                                        "currency":
                                            sendMoneyController
                                                .selectedCurrencyId,
                                        if (sendMoneyController.isChargeFrom ==
                                            true)
                                          "charge_from": "1",
                                        "note":
                                            sendMoneyController
                                                .noteController
                                                .text,
                                      },
                                    );
                                  }
                                } catch (e) {
                                  Helpers.showSnackBar(msg: e.toString());
                                }
                              },
                      text: storedLanguage['Send Money'] ?? "Send Money",
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
