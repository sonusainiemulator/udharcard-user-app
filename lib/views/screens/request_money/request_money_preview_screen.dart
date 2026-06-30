import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:paysecure/config/dimensions.dart';
import 'package:paysecure/controllers/request_money_controller.dart';
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

class RequestMoneyPreviewScreen extends StatelessWidget {
  final String? utr;
  const RequestMoneyPreviewScreen({super.key, this.utr = ""});

  @override
  Widget build(BuildContext context) {
    var storedLanguage = HiveHelp.read(Keys.languageData) ?? {};
    return GetBuilder<RequestMoneyController>(
      builder: (requestMoneyController) {
        return Scaffold(
          backgroundColor:
              Get.isDarkMode ? AppColors.darkBgColor : AppColors.scaffoldColor,
          appBar: CustomAppBar(
            title:
                storedLanguage['Request Money Preview'] ??
                "Request Money Preview",
          ),
          body:
              requestMoneyController.isLoading
                  ? Center(child: Helpers.appLoader())
                  : requestMoneyController.requestMoneyPreviewList.isEmpty
                  ? Center(child: Helpers.notFound())
                  : SingleChildScrollView(
                    child: Padding(
                      padding: Dimensions.kDefaultPadding,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          VSpace(40.h),
                          IgnorePointer(
                            ignoring: true,
                            child: CustomTextField(
                              isBorderColor: true,
                              isSuffixIcon: false,
                              contentPadding: EdgeInsets.only(left: 20.w),
                              hintext:
                                  storedLanguage['Recipient Email or Username'] ??
                                  'Recipient Email or Username',
                              controller:
                                  requestMoneyController
                                      .recipientEmailController,
                              onChanged: (v) {},
                            ),
                          ),
                          VSpace(32.h),
                          IgnorePointer(
                            ignoring: true,
                            child: Container(
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
                                      items: [
                                        "${requestMoneyController.selectedCurrency}",
                                      ],
                                      selectedValue:
                                          requestMoneyController
                                              .selectedCurrency,
                                      onChanged: (v) {},
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
                          ),
                          VSpace(32.h),
                          CustomTextField(
                            isBorderColor: true,
                            isSuffixIcon: false,
                            contentPadding: EdgeInsets.only(left: 20.w),
                            hintext:
                                storedLanguage['Enter Amount'] ??
                                'Enter Amount',
                            keyboardType: TextInputType.number,
                            inputFormatters: <TextInputFormatter>[
                              FilteringTextInputFormatter.digitsOnly,
                            ],
                            controller: requestMoneyController.amountController,
                            onChanged: (v) {
                              try {
                                requestMoneyController.amountVal = v.toString();
                                requestMoneyController.update();
                                if (v.toString().isNotEmpty &&
                                    requestMoneyController.selectedCurrency !=
                                        null) {
                                  requestMoneyController.checkRedeemAmount(
                                    fields: {
                                      "amount":
                                          requestMoneyController
                                              .amountController
                                              .text,
                                      "currency_id":
                                          requestMoneyController
                                              .selectedCurrencyId,
                                      "transaction_type_id": "2",
                                      if (requestMoneyController.isChargeFrom)
                                        "charge_from": "1",
                                    },
                                  );
                                }
                              } catch (e) {
                                Helpers.showSnackBar(msg: e.toString());
                              }
                            },
                          ),
                          if (requestMoneyController.amountVal.isNotEmpty &&
                              requestMoneyController.amountCheckList.isNotEmpty)
                            VSpace(5.h),
                          if (requestMoneyController.amountVal.isNotEmpty &&
                              requestMoneyController.amountCheckList.isNotEmpty)
                            Text(
                              "${requestMoneyController.amountCheckList[0].message!.message}",
                              style: context.t.bodySmall?.copyWith(
                                color:
                                    requestMoneyController
                                                .amountCheckList[0]
                                                .message!
                                                .message
                                                .toString()
                                                .contains("minimum") ||
                                            requestMoneyController
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
                                    value: requestMoneyController.isChargeFrom,
                                    activeColor: AppColors.mainColor,
                                    onChanged: (v) {
                                      try {
                                        requestMoneyController.isChargeFrom = v;
                                        if (requestMoneyController
                                                .amountController
                                                .text
                                                .isNotEmpty &&
                                            requestMoneyController
                                                    .selectedCurrency !=
                                                null) {
                                          requestMoneyController
                                              .checkRedeemAmount(
                                                fields: {
                                                  "amount":
                                                      requestMoneyController
                                                          .amountController
                                                          .text,
                                                  "currency_id": "1",
                                                  "transaction_type_id": "4",
                                                  if (requestMoneyController
                                                      .isChargeFrom)
                                                    "charge_from": "1",
                                                },
                                              );
                                        }
                                      } catch (e) {
                                        Helpers.showSnackBar(msg: e.toString());
                                      }
                                      requestMoneyController.update();
                                    },
                                  ),
                                ),
                              ),
                              HSpace(8.w),
                              Text(
                                storedLanguage['Receiver will pay the txn charge'] ??
                                    "Receiver will pay the txn charge",
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
                          IgnorePointer(
                            ignoring: true,
                            child: CustomTextField(
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
                              controller: requestMoneyController.noteController,
                              hintext:
                                  storedLanguage['Say something'] ??
                                  "Say something",
                            ),
                          ),
                          if (requestMoneyController.receivedAmount.isNotEmpty)
                            VSpace(32.h),
                          if (requestMoneyController.receivedAmount.isNotEmpty)
                            Container(
                              width: double.maxFinite,
                              height: 200.h,
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
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      Text(
                                        "Transfer Charge",
                                        style: context.t.displayMedium
                                            ?.copyWith(
                                              color:
                                                  AppThemes.getParagraphColor(),
                                            ),
                                      ),
                                      Expanded(
                                        child: Align(
                                          alignment: Alignment.centerRight,
                                          child: Text(
                                            "${requestMoneyController.charge} ${requestMoneyController.selectedCurrency.toString().split(" ").first}",
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: context.t.bodyMedium
                                                ?.copyWith(
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
                                        style: context.t.displayMedium
                                            ?.copyWith(
                                              color:
                                                  AppThemes.getParagraphColor(),
                                            ),
                                      ),
                                      Expanded(
                                        child: Align(
                                          alignment: Alignment.centerRight,
                                          child: Text(
                                            "${requestMoneyController.payableAmount} ${requestMoneyController.selectedCurrency.toString().split(" ").first}",
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
                                        style: context.t.displayMedium
                                            ?.copyWith(
                                              color:
                                                  AppThemes.getParagraphColor(),
                                            ),
                                      ),
                                      Expanded(
                                        child: Align(
                                          alignment: Alignment.centerRight,
                                          child: Text(
                                            "${double.parse(requestMoneyController.receivedAmount.toString()).toStringAsFixed(2)} ${requestMoneyController.selectedCurrency.toString().split(" ").first}",
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
                            isLoading:
                                requestMoneyController.isSubmit ? true : false,
                            onTap:
                                requestMoneyController.isLoading ||
                                        requestMoneyController.isSubmit
                                    ? null
                                    : () async {
                                      try {
                                        if (requestMoneyController
                                            .amountController
                                            .text
                                            .isEmpty) {
                                          Helpers.showSnackBar(
                                            msg: "Amount field is required",
                                          );
                                        } else {
                                          await requestMoneyController
                                              .requestMoneyCheckSubmit(
                                                context: context,
                                                fields: {
                                                  "utr": utr,
                                                  "amount":
                                                      requestMoneyController
                                                          .amountController
                                                          .text,
                                                  if (requestMoneyController
                                                      .isChargeFrom)
                                                    "charge_from": "1",
                                                },
                                              );
                                        }
                                      } catch (e) {
                                        Helpers.showSnackBar(msg: e.toString());
                                      }
                                    },
                            text:
                                storedLanguage['Confirm Request'] ??
                                "Confirm Request",
                          ),
                          VSpace(40.h),
                        ],
                      ),
                    ),
                  ),
        );
      },
    );
  }
}
