import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:paysecure/config/dimensions.dart';
import 'package:paysecure/controllers/redeem_code_controller.dart';
import 'package:paysecure/utils/app_constants.dart';
import 'package:paysecure/utils/services/helpers.dart';
import 'package:paysecure/views/widgets/app_button.dart';
import 'package:paysecure/views/widgets/custom_appbar.dart';
import 'package:paysecure/views/widgets/text_theme_extension.dart';
import '../../../config/app_colors.dart';
import '../../../themes/themes.dart';
import '../../../utils/services/localstorage/hive.dart';
import '../../../utils/services/localstorage/keys.dart';
import '../../widgets/app_custom_dropdown.dart';
import '../../widgets/custom_textfield.dart';
import '../../widgets/spacing.dart';

class RedeemScreen extends StatelessWidget {
  const RedeemScreen({super.key});

  @override
  Widget build(BuildContext context) {
    var storedLanguage = HiveHelp.read(Keys.languageData) ?? {};
    return GetBuilder<RedeemCodeController>(
      builder: (redeemCodeController) {
        return Scaffold(
          backgroundColor:
              Get.isDarkMode ? AppColors.darkBgColor : AppColors.scaffoldColor,
          appBar: CustomAppBar(title: storedLanguage['Redeem'] ?? "Redeem"),
          body: RefreshIndicator(
            color: AppColors.mainColor,
            onRefresh: () async {
              await redeemCodeController.getGenerateCode();
            },
            child: SingleChildScrollView(
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
                                  redeemCodeController.customCurrencyList
                                      .map((e) => e.currency_code)
                                      .toList(),
                              selectedValue:
                                  redeemCodeController.selectedCurrency,
                              onChanged: (v) {
                                try {
                                  redeemCodeController.selectedCurrency = v;
                                  redeemCodeController.selectedCurrencyId =
                                      redeemCodeController.customCurrencyList
                                          .firstWhere(
                                            (e) => e.currency_code == v,
                                          )
                                          .id
                                          .toString();
                                  if (redeemCodeController
                                          .amountController
                                          .text
                                          .isNotEmpty &&
                                      redeemCodeController.selectedCurrency !=
                                          null) {
                                    redeemCodeController.checkRedeemAmount(
                                      fields: {
                                        "amount":
                                            redeemCodeController
                                                .amountController
                                                .text,
                                        "currency_id":
                                            redeemCodeController
                                                .selectedCurrencyId,
                                        "transaction_type_id": "4",
                                        if (redeemCodeController.isChargeFrom)
                                          "charge_from": "1",
                                      },
                                    );
                                  }
                                } catch (e) {
                                  Helpers.showSnackBar(msg: e.toString());
                                }
                                redeemCodeController.update();
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
                      controller: redeemCodeController.amountController,
                      onChanged: (v) {
                        try {
                          redeemCodeController.amountVal = v.toString();
                          redeemCodeController.update();
                          if (v.toString().isNotEmpty &&
                              redeemCodeController.selectedCurrency != null) {
                            redeemCodeController.checkRedeemAmount(
                              fields: {
                                "amount":
                                    redeemCodeController.amountController.text,
                                "currency_id":
                                    redeemCodeController.selectedCurrencyId,
                                "transaction_type_id": "4",
                                if (redeemCodeController.isChargeFrom)
                                  "charge_from": "1",
                              },
                            );
                          }
                        } catch (e) {
                          Helpers.showSnackBar(msg: e.toString());
                        }
                      },
                    ),
                    if (redeemCodeController.amountVal.isNotEmpty &&
                        redeemCodeController.amountCheckList.isNotEmpty)
                      VSpace(5.h),
                    if (redeemCodeController.amountVal.isNotEmpty &&
                        redeemCodeController.amountCheckList.isNotEmpty)
                      Text(
                        "${redeemCodeController.amountCheckList[0].message!.message}",
                        style: context.t.bodySmall?.copyWith(
                          color:
                              redeemCodeController
                                          .amountCheckList[0]
                                          .message!
                                          .message
                                          .toString()
                                          .contains("minimum") ||
                                      redeemCodeController
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
                              value: redeemCodeController.isChargeFrom,
                              activeColor: AppColors.mainColor,
                              onChanged: (v) {
                                try {
                                  redeemCodeController.isChargeFrom = v;
                                  if (redeemCodeController
                                          .amountController
                                          .text
                                          .isNotEmpty &&
                                      redeemCodeController.selectedCurrency !=
                                          null) {
                                    redeemCodeController.checkRedeemAmount(
                                      fields: {
                                        "amount":
                                            redeemCodeController
                                                .amountController
                                                .text,
                                        "currency_id":
                                            redeemCodeController
                                                .selectedCurrencyId,
                                        "transaction_type_id": "4",
                                        if (redeemCodeController.isChargeFrom)
                                          "charge_from": "1",
                                      },
                                    );
                                  }
                                } catch (e) {
                                  Helpers.showSnackBar(msg: e.toString());
                                }
                                redeemCodeController.update();
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
                      contentPadding: EdgeInsets.only(
                        left: 20.w,
                        bottom: 0.h,
                        top: 10.h,
                      ),
                      alignment: Alignment.topLeft,
                      minLines: 5,
                      maxLines: 8,
                      textfieldHieght: null,
                      isBorderColor: true,
                      isPrefixIcon: false,
                      controller: redeemCodeController.noteController,
                      hintext:
                          storedLanguage['Say something'] ?? "Say something",
                    ),
                    if (redeemCodeController.amountCheckList.isNotEmpty)
                      VSpace(32.h),
                    if (redeemCodeController.amountCheckList.isNotEmpty)
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
                                      "${redeemCodeController.amountCheckList[0].message!.balance} ${redeemCodeController.selectedCurrency.toString().split(" ").first}",
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
                                      "${redeemCodeController.amountCheckList[0].message!.charge} ${redeemCodeController.selectedCurrency.toString().split(" ").first}",
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
                                      "${redeemCodeController.amountCheckList[0].message!.transferAmount} ${redeemCodeController.selectedCurrency.toString().split(" ").first}",
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
                                      "${double.parse(redeemCodeController.amountCheckList[0].message!.receivedAmount.toString()).toStringAsFixed(2)} ${redeemCodeController.selectedCurrency.toString().split(" ").first}",
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
                                      "${redeemCodeController.amountCheckList[0].message!.remainingBalance} ${redeemCodeController.selectedCurrency.toString().split(" ").first}",
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
                                      "${redeemCodeController.amountCheckList[0].message!.minLimit} ${redeemCodeController.selectedCurrency.toString().split(" ").first}",
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
                                      "${redeemCodeController.amountCheckList[0].message!.maxLimit} ${redeemCodeController.selectedCurrency.toString().split(" ").first}",
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
                      isLoading: redeemCodeController.isSubmit ? true : false,
                      onTap:
                          redeemCodeController.isLoading ||
                                  redeemCodeController.isSubmit
                              ? null
                              : () async {
                                try {
                                  if (redeemCodeController.selectedCurrencyId ==
                                      "0") {
                                    Helpers.showSnackBar(
                                      msg: "Please select your currency",
                                    );
                                  } else if (redeemCodeController
                                      .amountController
                                      .text
                                      .isEmpty) {
                                    Helpers.showSnackBar(
                                      msg: "Amount field is required",
                                    );
                                  } else if (int.parse(
                                            redeemCodeController.amountVal,
                                          ) <
                                          int.parse(
                                            redeemCodeController
                                                .amountCheckList[0]
                                                .message!
                                                .minLimit
                                                .toString(),
                                          ) ||
                                      int.parse(
                                            redeemCodeController.amountVal,
                                          ) >
                                          int.parse(
                                            redeemCodeController
                                                .amountCheckList[0]
                                                .message!
                                                .maxLimit
                                                .toString(),
                                          )) {
                                    Helpers.showSnackBar(
                                      msg:
                                          "minimum payment ${redeemCodeController.amountCheckList[0].message!.minLimit.toString()} and maximum payment limit ${redeemCodeController.amountCheckList[0].message!.maxLimit.toString()}",
                                    );
                                  } else {
                                    await redeemCodeController
                                        .generateCodeSubmit(
                                          fields: {
                                            "amount":
                                                redeemCodeController
                                                    .amountController
                                                    .text,
                                            "currency":
                                                redeemCodeController
                                                    .selectedCurrencyId,
                                            if (redeemCodeController
                                                .isChargeFrom)
                                              "charge_from": "1",
                                            "note":
                                                redeemCodeController
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
                    VSpace(40.h),
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
