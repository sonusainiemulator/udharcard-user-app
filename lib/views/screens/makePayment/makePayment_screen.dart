import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:paysecure/config/dimensions.dart';
import 'package:paysecure/controllers/makePayment_controller.dart';
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

class MakePaymentScreen extends StatelessWidget {
  final bool? isFromScannerPage;
  const MakePaymentScreen({super.key, this.isFromScannerPage = false});

  @override
  Widget build(BuildContext context) {
    var storedLanguage = HiveHelp.read(Keys.languageData) ?? {};
    return GetBuilder<MakePaymentController>(
      builder: (makePaymentController) {
        return Scaffold(
          appBar: CustomAppBar(
            title: storedLanguage['Make Payment'] ?? "Make Payment",
            onBackPressed: () {
              if (isFromScannerPage == true) {
                Navigator.pop(context);
                Navigator.pop(context);
              } else {
                Get.back();
              }
            },
          ),
          body: RefreshIndicator(
            color: AppColors.mainColor,
            onRefresh: () async {
              await makePaymentController.getCurrency();
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
                              storedLanguage['Merchant Username/E-mail'] ??
                              'Merchant Username/E-mail',
                          controller:
                              makePaymentController.merchantEmailController,
                          onChanged: (v) async {
                            if (v.isNotEmpty) {
                              await Future.delayed(Duration(seconds: 2));
                              await makePaymentController.checkMerchant(
                                merchant: v.toString(),
                              );
                            } else {
                              makePaymentController.checkRecipientmessage = "";
                              makePaymentController.update();
                            }
                          },
                        ),
                        IconButton(
                          onPressed: () {
                            Get.to(
                              () => MobileScannerScreen(
                                isFromMakePaymentPage: true,
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
                    if (makePaymentController.checkRecipientmessage.isNotEmpty)
                      VSpace(12.h),
                    if (makePaymentController.checkRecipientmessage.isNotEmpty)
                      Text(
                        makePaymentController.checkRecipientmessage,
                        style: context.t.displayMedium?.copyWith(
                          fontSize: 15.sp,
                          color:
                              makePaymentController.checkRecipientmessage
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
                                  makePaymentController.customCurrencyList
                                      .map((e) => e.currency_code)
                                      .toList(),
                              selectedValue:
                                  makePaymentController.selectedCurrency,
                              onChanged: (v) {
                                try {
                                  makePaymentController.selectedCurrency = v;
                                  makePaymentController.selectedCurrencyId =
                                      makePaymentController.customCurrencyList
                                          .firstWhere(
                                            (e) => e.currency_code == v,
                                          )
                                          .id
                                          .toString();
                                  if (makePaymentController
                                          .amountController
                                          .text
                                          .isNotEmpty &&
                                      makePaymentController.selectedCurrency !=
                                          null) {
                                    makePaymentController
                                        .makePaymentCheckAmount(
                                          fields: {
                                            "amount":
                                                makePaymentController
                                                    .amountController
                                                    .text,
                                            "currency_id":
                                                makePaymentController
                                                    .selectedCurrencyId,
                                            "merchant": "merchant",
                                          },
                                        );
                                  }
                                } catch (e) {
                                  Helpers.showSnackBar(msg: e.toString());
                                }
                                makePaymentController.update();
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
                      controller: makePaymentController.amountController,
                      onChanged: (v) async {
                        try {
                          makePaymentController.amountVal = v.toString();
                          makePaymentController.update();
                          if (v.toString().isNotEmpty &&
                              makePaymentController.selectedCurrency != null) {
                            await Future.delayed(Duration(milliseconds: 600));
                            makePaymentController.makePaymentCheckAmount(
                              fields: {
                                "amount":
                                    makePaymentController.amountController.text,
                                "currency_id":
                                    makePaymentController.selectedCurrencyId,
                                "merchant": "merchant",
                              },
                            );
                          }
                        } catch (e) {
                          Helpers.showSnackBar(msg: e.toString());
                        }
                      },
                    ),
                    if (makePaymentController.amountVal.isNotEmpty &&
                        makePaymentController.amountCheckList.isNotEmpty)
                      VSpace(5.h),
                    if (makePaymentController.amountVal.isNotEmpty &&
                        makePaymentController.amountCheckList.isNotEmpty)
                      Text(
                        "${makePaymentController.amountCheckList[0].message!.message}",
                        style: context.t.bodySmall?.copyWith(
                          color:
                              makePaymentController
                                          .amountCheckList[0]
                                          .message!
                                          .message
                                          .toString()
                                          .contains("minimum") ||
                                      makePaymentController
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

                    if (makePaymentController.amountCheckList.isNotEmpty)
                      VSpace(32.h),
                    if (makePaymentController.amountCheckList.isNotEmpty)
                      Container(
                        width: double.maxFinite,
                        height: 380.h,
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
                                      "${makePaymentController.amountCheckList[0].message!.balance} ${makePaymentController.selectedCurrency.toString().split(" ").first}",
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
                                      "${makePaymentController.amountCheckList[0].message!.charge} ${makePaymentController.selectedCurrency.toString().split(" ").first}",
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
                                      "${makePaymentController.amountCheckList[0].message!.payable_amount} ${makePaymentController.selectedCurrency.toString().split(" ").first}",
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
                                      "${double.parse(makePaymentController.amountCheckList[0].message!.receivedAmount.toString()).toStringAsFixed(2)} ${makePaymentController.selectedCurrency.toString().split(" ").first}",
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
                                  "Charge applied to",
                                  style: context.t.displayMedium?.copyWith(
                                    color: AppThemes.getParagraphColor(),
                                  ),
                                ),
                                Expanded(
                                  child: Align(
                                    alignment: Alignment.centerRight,
                                    child: Text(
                                      "${makePaymentController.amountCheckList[0].message!.charge_applied_to.toString().toCapital()}",
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
                                      "${makePaymentController.amountCheckList[0].message!.remainingBalance} ${makePaymentController.selectedCurrency.toString().split(" ").first}",
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
                      isLoading: makePaymentController.isSubmit ? true : false,
                      onTap:
                          makePaymentController.isLoading ||
                                  makePaymentController.isSubmit
                              ? null
                              : () async {
                                try {
                                  if (makePaymentController
                                      .merchantEmailController
                                      .text
                                      .isEmpty) {
                                    Helpers.showSnackBar(
                                      msg:
                                          "Merchant Username/E-mail is required",
                                    );
                                  } else if (makePaymentController
                                          .selectedCurrencyId ==
                                      "0") {
                                    Helpers.showSnackBar(
                                      msg: "Please select your currency",
                                    );
                                  } else if (makePaymentController
                                      .amountController
                                      .text
                                      .isEmpty) {
                                    Helpers.showSnackBar(
                                      msg: "Amount field is required",
                                    );
                                  } else {
                                    await makePaymentController.initMakePayment(
                                      fields: {
                                        "recipient":
                                            makePaymentController
                                                .merchantEmailController
                                                .text,
                                        "amount":
                                            makePaymentController
                                                .amountController
                                                .text,
                                        "currency_id":
                                            makePaymentController
                                                .selectedCurrencyId,
                                      },
                                    );
                                  }
                                } catch (e) {
                                  Helpers.showSnackBar(msg: e.toString());
                                }
                              },
                      text: storedLanguage['Make Payment'] ?? "Make Payment",
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
