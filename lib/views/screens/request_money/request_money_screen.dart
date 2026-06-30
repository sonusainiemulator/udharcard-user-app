import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:paysecure/config/dimensions.dart';
import 'package:paysecure/views/widgets/app_button.dart';
import 'package:paysecure/views/widgets/custom_appbar.dart';
import 'package:paysecure/views/widgets/text_theme_extension.dart';
import '../../../config/app_colors.dart';
import '../../../controllers/request_money_controller.dart';
import '../../../controllers/send_money_controller.dart';
import '../../../themes/themes.dart';
import '../../../utils/services/helpers.dart';
import '../../../utils/services/localstorage/hive.dart';
import '../../../utils/services/localstorage/keys.dart';
import '../../widgets/app_custom_dropdown.dart';
import '../../widgets/custom_textfield.dart';
import '../../widgets/spacing.dart';

class RequestMoneyScreen extends StatelessWidget {
  const RequestMoneyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    var storedLanguage = HiveHelp.read(Keys.languageData) ?? {};
    return GetBuilder<RequestMoneyController>(
      builder: (requestMoneyController) {
        return Scaffold(
          backgroundColor:
              Get.isDarkMode ? AppColors.darkBgColor : AppColors.scaffoldColor,
          appBar: CustomAppBar(
            title: storedLanguage['New Request'] ?? "New Request",
          ),
          body: RefreshIndicator(
            color: AppColors.mainColor,
            onRefresh: () async {
              await requestMoneyController.getRequestMoney();
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
                      controller:
                          requestMoneyController.recipientEmailController,
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
                                  requestMoneyController.customCurrencyList
                                      .map((e) => e.currency_code)
                                      .toList(),
                              selectedValue:
                                  requestMoneyController.selectedCurrency,
                              onChanged: (v) {
                                try {
                                  requestMoneyController.selectedCurrency = v;
                                  requestMoneyController.selectedCurrencyId =
                                      requestMoneyController.customCurrencyList
                                          .firstWhere(
                                            (e) => e.currency_code == v,
                                          )
                                          .id
                                          .toString();
                                  if (requestMoneyController
                                          .amountController
                                          .text
                                          .isNotEmpty &&
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
                                        "charge_from": "1",
                                      },
                                    );
                                  }
                                } catch (e) {
                                  Helpers.showSnackBar(msg: e.toString());
                                }
                                requestMoneyController.update();
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
                      controller: requestMoneyController.amountController,
                      onChanged: (v) {
                        try {
                          requestMoneyController.amountVal = v.toString();
                          requestMoneyController.update();
                          if (v.toString().isNotEmpty &&
                              requestMoneyController.selectedCurrency != null) {
                            requestMoneyController.checkRedeemAmount(
                              fields: {
                                "amount":
                                    requestMoneyController
                                        .amountController
                                        .text,
                                "currency_id":
                                    requestMoneyController.selectedCurrencyId,
                                "transaction_type_id": "2",
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
                      if (requestMoneyController
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
                              .contains("not have enough"))
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
                      controller: requestMoneyController.noteController,
                      hintext:
                          storedLanguage['Say something'] ?? "Say something",
                    ),
                    if (requestMoneyController.isActiveSecurityPin == true)
                      VSpace(32.h),
                    if (requestMoneyController.isActiveSecurityPin == true)
                      CustomTextField(
                        isBorderColor: true,
                        isSuffixIcon: false,
                        contentPadding: EdgeInsets.only(left: 20.w),
                        hintext:
                            storedLanguage['Security Pin'] ?? 'Security Pin',
                        keyboardType: TextInputType.number,
                        inputFormatters: <TextInputFormatter>[
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                        controller:
                            requestMoneyController.securityPinController,
                        onChanged: (v) {},
                      ),
                    VSpace(40.h),
                    AppButton(
                      isLoading: requestMoneyController.isSubmit ? true : false,
                      onTap:
                          requestMoneyController.isLoading ||
                                  requestMoneyController.isSubmit
                              ? null
                              : () async {
                                try {
                                  if (requestMoneyController
                                      .recipientEmailController
                                      .text
                                      .isEmpty) {
                                    Helpers.showSnackBar(
                                      msg:
                                          "Recipient Email or Username is required",
                                    );
                                  } else if (requestMoneyController
                                          .selectedCurrencyId ==
                                      "0") {
                                    Helpers.showSnackBar(
                                      msg: "Please select your currency",
                                    );
                                  } else if (requestMoneyController
                                      .amountController
                                      .text
                                      .isEmpty) {
                                    Helpers.showSnackBar(
                                      msg: "Amount field is required",
                                    );
                                  } else if (int.parse(
                                            requestMoneyController.amountVal,
                                          ) <
                                          int.parse(
                                            requestMoneyController
                                                .amountCheckList[0]
                                                .message!
                                                .minLimit
                                                .toString(),
                                          ) ||
                                      int.parse(
                                            requestMoneyController.amountVal,
                                          ) >
                                          int.parse(
                                            requestMoneyController
                                                .amountCheckList[0]
                                                .message!
                                                .maxLimit
                                                .toString(),
                                          )) {
                                    Helpers.showSnackBar(
                                      msg:
                                          "minimum payment ${requestMoneyController.amountCheckList[0].message!.minLimit.toString()} and maximum payment limit ${requestMoneyController.amountCheckList[0].message!.maxLimit.toString()}",
                                    );
                                  } else {
                                    await requestMoneyController
                                        .submitRequestMoney(
                                          fields: {
                                            "recipient":
                                                requestMoneyController
                                                    .recipientEmailController
                                                    .text,
                                            "amount":
                                                requestMoneyController
                                                    .amountController
                                                    .text,
                                            "currency":
                                                requestMoneyController
                                                    .selectedCurrencyId,
                                            "charge_from": "1",
                                            "note":
                                                requestMoneyController
                                                    .noteController
                                                    .text,
                                            if (requestMoneyController
                                                    .isActiveSecurityPin ==
                                                true)
                                              "security_pin":
                                                  requestMoneyController
                                                      .securityPinController
                                                      .text,
                                          },
                                        );
                                  }
                                } catch (e) {
                                  Helpers.showSnackBar(msg: e.toString());
                                }
                              },
                      text: storedLanguage['Request Money'] ?? "Request Money",
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
