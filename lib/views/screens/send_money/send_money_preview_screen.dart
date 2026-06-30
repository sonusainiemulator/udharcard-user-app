import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:paysecure/config/dimensions.dart';
import 'package:paysecure/controllers/send_money_controller.dart';
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

class SendMoneyPreviewScreen extends StatelessWidget {
  final String? utr;
  final bool? isFromHistoryPage;
  final BuildContext? context;
  const SendMoneyPreviewScreen(
      {super.key, this.utr = "", this.isFromHistoryPage = false, this.context});

  @override
  Widget build(BuildContext context) {
    var storedLanguage = HiveHelp.read(Keys.languageData) ?? {};
    return GetBuilder<SendMoneyController>(builder: (sendMoneyController) {
      return Scaffold(
        backgroundColor:
            Get.isDarkMode ? AppColors.darkBgColor : AppColors.scaffoldColor,
        appBar: CustomAppBar(
            title:
                storedLanguage['Send Money Preview'] ?? "Send Money Preview"),
        body: sendMoneyController.isLoading
            ? Helpers.appLoader()
            : SingleChildScrollView(
                child: Padding(
                  padding: Dimensions.kDefaultPadding,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      VSpace(40.h),
                      sendMoneyController.sendMoneyPreviewList.isEmpty
                          ? SizedBox()
                          : Container(
                              width: double.maxFinite,
                              height:
                                  sendMoneyController.sendMoneyPreviewList[0].note.toString() !=
                                              "" &&
                                          sendMoneyController.sendMoneyPreviewList[0].note
                                                  .toString() !=
                                              "null"
                                      ? 440.h
                                      : 430.h,
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
                                        "Receiver name",
                                        style: context.t.displayMedium
                                            ?.copyWith(
                                                color: AppThemes
                                                    .getParagraphColor()),
                                      ),
                                      Expanded(
                                          child: Align(
                                        alignment: Alignment.centerRight,
                                        child: Text(
                                            "${sendMoneyController.sendMoneyPreviewList[0].receiverName}",
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
                                        "Percentage charge (${sendMoneyController.sendMoneyPreviewList[0].percentage}%)",
                                        style: context.t.displayMedium
                                            ?.copyWith(
                                                color: AppThemes
                                                    .getParagraphColor()),
                                      ),
                                      Expanded(
                                          child: Align(
                                        alignment: Alignment.centerRight,
                                        child: Text(
                                            "${sendMoneyController.sendMoneyPreviewList[0].percentageCharge} ${sendMoneyController.sendMoneyPreviewList[0].currency}",
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
                                            "${sendMoneyController.sendMoneyPreviewList[0].fixedCharge} ${sendMoneyController.sendMoneyPreviewList[0].currency}",
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
                                            "${sendMoneyController.sendMoneyPreviewList[0].totalCharge} ${sendMoneyController.sendMoneyPreviewList[0].currency}",
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
                                            "${sendMoneyController.sendMoneyPreviewList[0].payableAmount} ${sendMoneyController.sendMoneyPreviewList[0].currency}",
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
                                        "Receiver will received",
                                        style: context.t.displayMedium
                                            ?.copyWith(
                                                color: AppThemes
                                                    .getParagraphColor()),
                                      ),
                                      Expanded(
                                          child: Align(
                                        alignment: Alignment.centerRight,
                                        child: Text(
                                            "${sendMoneyController.sendMoneyPreviewList[0].receiverWillReceive} ${sendMoneyController.sendMoneyPreviewList[0].currency}",
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
                                        "Charge deduct from",
                                        style: context.t.displayMedium
                                            ?.copyWith(
                                                color: AppThemes
                                                    .getParagraphColor()),
                                      ),
                                      Expanded(
                                          child: Align(
                                        alignment: Alignment.centerRight,
                                        child: Text(
                                            "${sendMoneyController.sendMoneyPreviewList[0].chargeDeductFrom}",
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: context.t.bodyMedium),
                                      )),
                                    ],
                                  ),
                                  if (sendMoneyController.sendMoneyPreviewList[0].note
                                          .toString() !=
                                      "")
                                    Container(
                                      width: double.maxFinite,
                                      height: .5,
                                      color: AppThemes.getSliderInactiveColor(),
                                    ),
                                  if (sendMoneyController.sendMoneyPreviewList[0].note
                                          .toString() !=
                                      "")
                                    Row(
                                      children: [
                                        Text(
                                          "Note",
                                          style: context.t.displayMedium
                                              ?.copyWith(
                                                  color: AppThemes
                                                      .getParagraphColor()),
                                        ),
                                        Expanded(
                                            child: Align(
                                          alignment: Alignment.centerRight,
                                          child: Text(
                                              " ${sendMoneyController.sendMoneyPreviewList[0].note.toString().replaceAll("null", "")}",
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              style: context.t.bodyMedium),
                                        )),
                                      ],
                                    ),
                                ],
                              )),
                      if (sendMoneyController.sendMoneyPreviewList[0].enableFor == true)
                        VSpace(48.h),
                      if (sendMoneyController.sendMoneyPreviewList[0].enableFor == true)
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
                          controller: sendMoneyController.securityPinController,
                        ),
                      VSpace(40.h),
                      sendMoneyController.sendMoneyPreviewList.isEmpty
                          ? SizedBox()
                          : AppButton(
                              isLoading: sendMoneyController.isSubmit ? true : false,
                              onTap: sendMoneyController.isSubmit
                                  ? null
                                  : () async {
                                      if (utr == "") {
                                        Helpers.showSnackBar(
                                            msg: "Utr not found");
                                      } else if (sendMoneyController.sendMoneyPreviewList[0]
                                                  .enableFor ==
                                              true &&
                                          sendMoneyController.securityPinController.text
                                              .isEmpty) {
                                        Helpers.showSnackBar(
                                            msg: "Security Pin is required");
                                      } else {
                                        await sendMoneyController.sendMoneyConfirm(
                                            isFromHistoryPage:
                                                isFromHistoryPage,
                                            context: context,
                                            fields: {
                                              "utr": utr,
                                              if (sendMoneyController.sendMoneyPreviewList[0]
                                                      .enableFor ==
                                                  true)
                                                "security_pin": sendMoneyController
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
