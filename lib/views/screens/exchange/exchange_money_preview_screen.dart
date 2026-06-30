import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:paysecure/config/dimensions.dart';
import 'package:paysecure/controllers/exchange_controller.dart';
import 'package:paysecure/utils/services/helpers.dart';
import 'package:paysecure/views/widgets/app_button.dart';
import 'package:paysecure/views/widgets/custom_appbar.dart';
import 'package:paysecure/views/widgets/text_theme_extension.dart';
import '../../../../config/app_colors.dart';
import '../../../../themes/themes.dart';
import '../../../../utils/services/localstorage/hive.dart';
import '../../../../utils/services/localstorage/keys.dart';
import '../../widgets/custom_textfield.dart';
import '../../widgets/spacing.dart';

class ExchangeMoneyPreviewScreen extends StatelessWidget {
  final String? utr;
  final bool? isFromHistoryPage;
  final BuildContext? context;
  const ExchangeMoneyPreviewScreen(
      {super.key, this.utr = "", this.isFromHistoryPage = false, this.context});

  @override
  Widget build(BuildContext context) {
    var storedLanguage = HiveHelp.read(Keys.languageData) ?? {};
    return GetBuilder<ExchangeController>(builder: (exchangeController) {
      return Scaffold(
        backgroundColor:
            Get.isDarkMode ? AppColors.darkBgColor : AppColors.scaffoldColor,
        appBar: CustomAppBar(
            title:
                storedLanguage['Send Money Preview'] ?? "Send Money Preview"),
        body: exchangeController.isLoading
            ? Helpers.appLoader()
            : SingleChildScrollView(
                child: Padding(
                  padding: Dimensions.kDefaultPadding,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      VSpace(40.h),
                      exchangeController.exchangePreviewList.isEmpty
                          ? SizedBox()
                          : Container(
                              width: double.maxFinite,
                              height: 410.h,
                              padding: EdgeInsets.symmetric(
                                  horizontal: 16.w, vertical: 20.h),
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
                                        storedLanguage['Exchange'] ??
                                            "Exchange",
                                        style: context.t.displayMedium
                                            ?.copyWith(
                                                color: AppThemes
                                                    .getParagraphColor()),
                                      ),
                                      Expanded(
                                          child: Align(
                                        alignment: Alignment.centerRight,
                                        child: Text(
                                            "${exchangeController.exchangePreviewList[0].exchangeFrom} to ${exchangeController.exchangePreviewList[0].exchangeTo}",
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
                                        style: context.t.displayMedium
                                            ?.copyWith(
                                                color: AppThemes
                                                    .getParagraphColor()),
                                      ),
                                      Expanded(
                                          child: Align(
                                        alignment: Alignment.centerRight,
                                        child: Text(
                                            "1 ${exchangeController.exchangePreviewList[0].exchangeFrom} = ${exchangeController.exchangePreviewList[0].exchangeRate} ${exchangeController.exchangePreviewList[0].exchangeTo}",
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
                                        "Percentage charge (${exchangeController.exchangePreviewList[0].percentage}%)",
                                        style: context.t.displayMedium
                                            ?.copyWith(
                                                color: AppThemes
                                                    .getParagraphColor()),
                                      ),
                                      Expanded(
                                          child: Align(
                                        alignment: Alignment.centerRight,
                                        child: Text(
                                            "${exchangeController.exchangePreviewList[0].percentageCharge} ${exchangeController.exchangePreviewList[0].exchangeFrom}",
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: context.t.bodyMedium
                                                ?.copyWith(
                                                    color:
                                                        AppColors.mainColor)),
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
                                        storedLanguage['Fixed charge'] ??
                                            "Fixed charge",
                                        style: context.t.displayMedium
                                            ?.copyWith(
                                                color: AppThemes
                                                    .getParagraphColor()),
                                      ),
                                      Expanded(
                                          child: Align(
                                        alignment: Alignment.centerRight,
                                        child: Text(
                                            "${exchangeController.exchangePreviewList[0].fixedCharge} ${exchangeController.exchangePreviewList[0].exchangeFrom}",
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
                                        storedLanguage['Total charge'] ??
                                            "Total charge",
                                        style: context.t.displayMedium
                                            ?.copyWith(
                                                color: AppThemes
                                                    .getParagraphColor()),
                                      ),
                                      Expanded(
                                          child: Align(
                                        alignment: Alignment.centerRight,
                                        child: Text(
                                            "${exchangeController.exchangePreviewList[0].totalCharge} ${exchangeController.exchangePreviewList[0].exchangeFrom}",
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
                                        storedLanguage['Payable Amount'] ??
                                            "Payable Amount",
                                        style: context.t.displayMedium
                                            ?.copyWith(
                                                color: AppThemes
                                                    .getParagraphColor()),
                                      ),
                                      Expanded(
                                          child: Align(
                                        alignment: Alignment.centerRight,
                                        child: Text(
                                            "${exchangeController.exchangePreviewList[0].payableAmount} ${exchangeController.exchangePreviewList[0].exchangeFrom}",
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
                                        storedLanguage['You will get'] ??
                                            "You will get",
                                        style: context.t.displayMedium
                                            ?.copyWith(
                                                color: AppThemes
                                                    .getParagraphColor()),
                                      ),
                                      Expanded(
                                          child: Align(
                                        alignment: Alignment.centerRight,
                                        child: Text(
                                            "${exchangeController.exchangePreviewList[0].youWillGet} ${exchangeController.exchangePreviewList[0].exchangeTo}",
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: context.t.bodyMedium),
                                      )),
                                    ],
                                  ),
                                ],
                              )),
                      if (exchangeController.exchangePreviewList.isNotEmpty &&
                          exchangeController.exchangePreviewList[0].enableFor == true)
                        VSpace(48.h),
                      if (exchangeController.exchangePreviewList.isNotEmpty &&
                          exchangeController.exchangePreviewList[0].enableFor == true)
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
                          controller: exchangeController.securityPinController,
                        ),
                      VSpace(40.h),
                      exchangeController.exchangePreviewList.isEmpty
                          ? SizedBox()
                          : AppButton(
                              isLoading: exchangeController.isSubmit ? true : false,
                              onTap: exchangeController.isSubmit
                                  ? null
                                  : () async {
                                      if (utr == "") {
                                        Helpers.showSnackBar(
                                            msg: "Utr not found");
                                      } else if (exchangeController.exchangePreviewList[0]
                                                  .enableFor ==
                                              true &&
                                          exchangeController.securityPinController.text
                                              .isEmpty) {
                                        Helpers.showSnackBar(
                                            msg: "Security Pin is required");
                                      } else {
                                        await exchangeController.exchangeMoneyConfirm(
                                            isFromHistoryPage:
                                                isFromHistoryPage,
                                            context: context,
                                            fields: {
                                              "utr": utr,
                                              if (exchangeController.exchangePreviewList[0]
                                                      .enableFor ==
                                                  true)
                                                "security_pin": exchangeController
                                                    .securityPinController.text,
                                            });
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
