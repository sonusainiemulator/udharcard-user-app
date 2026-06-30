import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:paysecure/config/dimensions.dart';
import 'package:paysecure/controllers/voucher_controller.dart';
import 'package:paysecure/utils/services/helpers.dart';
import 'package:paysecure/views/widgets/app_button.dart';
import 'package:paysecure/views/widgets/custom_appbar.dart';
import 'package:paysecure/views/widgets/text_theme_extension.dart';
import '../../../config/app_colors.dart';
import '../../../themes/themes.dart';
import '../../../utils/services/localstorage/hive.dart';
import '../../../utils/services/localstorage/keys.dart';
import '../../widgets/custom_textfield.dart';
import '../../widgets/spacing.dart';

class VoucherPreviewScreen extends StatelessWidget {
  final String? utr;
  final bool? isFromHistoryPag;
  final BuildContext? context;
  const VoucherPreviewScreen(
      {super.key, this.utr = "", this.isFromHistoryPag = false, this.context});

  @override
  Widget build(BuildContext context) {
    var storedLanguage = HiveHelp.read(Keys.languageData) ?? {};
    return GetBuilder<VoucherController>(builder: (voucherController) {
      return Scaffold(
        backgroundColor:
            Get.isDarkMode ? AppColors.darkBgColor : AppColors.scaffoldColor,
        appBar: CustomAppBar(
            title: storedLanguage['Voucher Preview'] ?? "Voucher Preview"),
        body: voucherController.isLoading
            ? Helpers.appLoader()
            : SingleChildScrollView(
                child: Padding(
                  padding: Dimensions.kDefaultPadding,
                  child: voucherController.voucherPreviewList.isEmpty
                      ? SizedBox()
                      : Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            VSpace(40.h),
                            voucherController.voucherPreviewList.isEmpty
                                ? SizedBox()
                                : voucherController.voucherPreviewList[0].showCharges
                                            .toString() ==
                                        "yes"
                                    ? Container(
                                        width: double.maxFinite,
                                        height: voucherController.voucherPreviewList[0].note
                                                        .toString() !=
                                                    "" &&
                                                voucherController.voucherPreviewList[0].note
                                                        .toString() !=
                                                    "null"
                                            ? 340.h
                                            : 310.h,
                                        padding: EdgeInsets.symmetric(
                                            horizontal: 16.w, vertical: 20.h),
                                        decoration: BoxDecoration(
                                          color: AppThemes.getDarkCardColor(),
                                          borderRadius:
                                              Dimensions.kBorderRadius,
                                        ),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Row(
                                              children: [
                                                Text(
                                                  "Request Amount",
                                                  style: context.t.displayMedium
                                                      ?.copyWith(
                                                          color: AppThemes
                                                              .getParagraphColor()),
                                                ),
                                                Expanded(
                                                    child: Align(
                                                  alignment:
                                                      Alignment.centerRight,
                                                  child: Text(
                                                    "${voucherController.voucherPreviewList[0].requestedAmount} ${voucherController.voucherPreviewList[0].currencyCode}",
                                                    maxLines: 1,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                  ),
                                                )),
                                              ],
                                            ),
                                            Container(
                                              width: double.maxFinite,
                                              height: .5,
                                              color: AppThemes
                                                  .getSliderInactiveColor(),
                                            ),
                                            Row(
                                              children: [
                                                Text(
                                                  "Percentage charge (${voucherController.voucherPreviewList[0].percentage}%)",
                                                  style: context.t.displayMedium
                                                      ?.copyWith(
                                                          color: AppThemes
                                                              .getParagraphColor()),
                                                ),
                                                Expanded(
                                                    child: Align(
                                                  alignment:
                                                      Alignment.centerRight,
                                                  child: Text(
                                                      "${voucherController.voucherPreviewList[0].percentageCharge} ${voucherController.voucherPreviewList[0].currencyCode}",
                                                      maxLines: 1,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                      style:
                                                          context.t.bodyMedium),
                                                )),
                                              ],
                                            ),
                                            Container(
                                              width: double.maxFinite,
                                              height: .5,
                                              color: AppThemes
                                                  .getSliderInactiveColor(),
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
                                                  alignment:
                                                      Alignment.centerRight,
                                                  child: Text(
                                                      "${voucherController.voucherPreviewList[0].fixedCharge} ${voucherController.voucherPreviewList[0].currencyCode}",
                                                      maxLines: 1,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                      style:
                                                          context.t.bodyMedium),
                                                )),
                                              ],
                                            ),
                                            Container(
                                              width: double.maxFinite,
                                              height: .5,
                                              color: AppThemes
                                                  .getSliderInactiveColor(),
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
                                                  alignment:
                                                      Alignment.centerRight,
                                                  child: Text(
                                                      "${voucherController.voucherPreviewList[0].totalCharge} ${voucherController.voucherPreviewList[0].currencyCode}",
                                                      maxLines: 1,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                      style:
                                                          context.t.bodyMedium),
                                                )),
                                              ],
                                            ),
                                            Container(
                                              width: double.maxFinite,
                                              height: .5,
                                              color: AppThemes
                                                  .getSliderInactiveColor(),
                                            ),
                                            Row(
                                              children: [
                                                Text(
                                                  "Receivable Amount",
                                                  style: context.t.displayMedium
                                                      ?.copyWith(
                                                          color: AppThemes
                                                              .getParagraphColor()),
                                                ),
                                                Expanded(
                                                    child: Align(
                                                  alignment:
                                                      Alignment.centerRight,
                                                  child: Text(
                                                      "${voucherController.voucherPreviewList[0].receivableAmount} ${voucherController.voucherPreviewList[0].currencyCode}",
                                                      maxLines: 1,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                      style:
                                                          context.t.bodyMedium),
                                                )),
                                              ],
                                            ),
                                            if (voucherController.voucherPreviewList[0].note
                                                        .toString() !=
                                                    "" &&
                                                voucherController.voucherPreviewList[0].note
                                                        .toString() !=
                                                    "null")
                                              Container(
                                                width: double.maxFinite,
                                                height: .5,
                                                color: AppThemes
                                                    .getSliderInactiveColor(),
                                              ),
                                            if (voucherController.voucherPreviewList[0].note
                                                        .toString() !=
                                                    "" &&
                                                voucherController.voucherPreviewList[0].note
                                                        .toString() !=
                                                    "null")
                                              Row(
                                                children: [
                                                  Text(
                                                    "Note",
                                                    style: context
                                                        .t.displayMedium
                                                        ?.copyWith(
                                                            color: AppThemes
                                                                .getParagraphColor()),
                                                  ),
                                                  Expanded(
                                                      child: Align(
                                                    alignment:
                                                        Alignment.centerRight,
                                                    child: Text(
                                                        " ${voucherController.voucherPreviewList[0].note.toString()}",
                                                        maxLines: 1,
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                        style: context
                                                            .t.bodyMedium),
                                                  )),
                                                ],
                                              ),
                                          ],
                                        ))
                                    : Container(
                                        width: double.maxFinite,
                                        height: 170.h,
                                        padding: EdgeInsets.symmetric(
                                            horizontal: 16.w, vertical: 20.h),
                                        decoration: BoxDecoration(
                                          color: AppThemes.getDarkCardColor(),
                                          borderRadius:
                                              Dimensions.kBorderRadius,
                                        ),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Row(
                                              children: [
                                                Text(
                                                  "Payable amount",
                                                  style: context.t.displayMedium
                                                      ?.copyWith(
                                                          color: AppThemes
                                                              .getParagraphColor()),
                                                ),
                                                Expanded(
                                                    child: Align(
                                                  alignment:
                                                      Alignment.centerRight,
                                                  child: Text(
                                                    "${voucherController.voucherPreviewList[0].requestedAmount} ${voucherController.voucherPreviewList[0].currencyCode}",
                                                    maxLines: 1,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                  ),
                                                )),
                                              ],
                                            ),
                                            Container(
                                              width: double.maxFinite,
                                              height: .5,
                                              color: AppThemes
                                                  .getSliderInactiveColor(),
                                            ),
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
                                                  alignment:
                                                      Alignment.centerRight,
                                                  child: Text(
                                                      "${voucherController.voucherPreviewList[0].note.toString().replaceAll("null", "")}",
                                                      maxLines: 1,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                      style:
                                                          context.t.bodyMedium),
                                                )),
                                              ],
                                            ),
                                            Container(
                                              width: double.maxFinite,
                                              height: .5,
                                              color: AppThemes
                                                  .getSliderInactiveColor(),
                                            ),
                                            Row(
                                              children: [
                                                Text(
                                                  "Status",
                                                  style: context.t.displayMedium
                                                      ?.copyWith(
                                                          color: AppThemes
                                                              .getParagraphColor()),
                                                ),
                                                Expanded(
                                                  child: Align(
                                                    alignment:
                                                        Alignment.centerRight,
                                                    child: Text(
                                                        " ${voucherController.voucherPreviewList[0].status}",
                                                        maxLines: 1,
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                        style: context
                                                            .t.bodyMedium
                                                            ?.copyWith(
                                                                color: voucherController.voucherPreviewList[0].status ==
                                                                        "Generated"
                                                                    ? AppColors
                                                                        .secondaryColor
                                                                    : voucherController.voucherPreviewList[0].status ==
                                                                            "Pending"
                                                                        ? AppColors
                                                                            .pendingColor
                                                                        : voucherController.voucherPreviewList[0].status ==
                                                                                "Canceled"
                                                                            ? AppColors.redColor
                                                                            : AppColors.greenColor)),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        )),
                            if (voucherController.voucherPreviewList[0].enableFor == true)
                              VSpace(48.h),
                            if (voucherController.voucherPreviewList[0].enableFor == true)
                              CustomTextField(
                                isBorderColor: false,
                                isSuffixIcon: false,
                                contentPadding: EdgeInsets.only(left: 20.w),
                                hintext: storedLanguage['Security Pin'] ??
                                    'Security Pin',
                                keyboardType: TextInputType.number,
                                inputFormatters: <TextInputFormatter>[
                                  FilteringTextInputFormatter.digitsOnly,
                                ],
                                controller: voucherController.securityPinController,
                                onChanged: (v) {},
                              ),
                            if (voucherController.voucherPreviewList[0].acceptBtn.toString() ==
                                    "yes" ||
                                voucherController.voucherPreviewList[0].cancelBtn.toString() ==
                                    "yes")
                              VSpace(40.h),
                            Row(
                              mainAxisAlignment: voucherController
                                              .voucherPreviewList[0].acceptBtn
                                              .toString() ==
                                          "yes" &&
                                      voucherController.voucherPreviewList[0].cancelBtn
                                              .toString() ==
                                          "yes"
                                  ? MainAxisAlignment.spaceBetween
                                  : MainAxisAlignment.center,
                              children: [
                                if (voucherController.voucherPreviewList[0].acceptBtn
                                        .toString() ==
                                    "yes")
                                  Expanded(
                                    child: AppButton(
                                      buttonHeight: 38.h,
                                      bgColor: Colors.transparent,
                                      border: Border.all(
                                          color: AppColors.greenColor),
                                      style: context.t.bodySmall,
                                      isIcon: true,
                                      iconWidget: Container(
                                        padding: EdgeInsets.all(2.h),
                                        margin: EdgeInsets.only(
                                            right: 5.w, top: 3.h),
                                        decoration: BoxDecoration(
                                            color: AppColors.greenColor,
                                            shape: BoxShape.circle),
                                        child: Icon(
                                          Icons.done,
                                          size: 10.h,
                                          color: AppColors.whiteColor,
                                        ),
                                      ),
                                      isLoading:
                                          voucherController.isClickedAcceptBtn && voucherController.isSubmit
                                              ? true
                                              : false,
                                      onTap: voucherController.isSubmit
                                          ? null
                                          : () async {
                                              voucherController.isClickedAcceptBtn = true;
                                              voucherController.update();
                                              if (utr != null &&
                                                  utr!.isNotEmpty) {
                                                await voucherController.voucherPaymentSubmit(
                                                    context: context,
                                                    fields: {
                                                      "utr": utr,
                                                      "status": "2",
                                                    });
                                              } else {
                                                Helpers.showSnackBar(
                                                    msg:
                                                        "Utr is null or empty");
                                              }
                                            },
                                      text:
                                          storedLanguage['Accept'] ?? "Accept",
                                    ),
                                  ),
                                if (voucherController.voucherPreviewList[0].cancelBtn
                                        .toString() ==
                                    "yes")
                                  HSpace(20.w),
                                if (voucherController.voucherPreviewList[0].cancelBtn
                                        .toString() ==
                                    "yes")
                                  Expanded(
                                    child: AppButton(
                                      buttonHeight: 38.h,
                                      bgColor: Colors.transparent,
                                      border:
                                          Border.all(color: AppColors.redColor),
                                      style: context.t.bodySmall,
                                      isIcon: true,
                                      iconWidget: Container(
                                        padding: EdgeInsets.all(2.h),
                                        margin: EdgeInsets.only(
                                            right: 5.w, top: 3.h),
                                        decoration: BoxDecoration(
                                            color: AppColors.redColor,
                                            shape: BoxShape.circle),
                                        child: Icon(
                                          Icons.close,
                                          size: 10.h,
                                          color: AppColors.whiteColor,
                                        ),
                                      ),
                                      isLoading:
                                          voucherController.isClickedCancelBtn && voucherController.isSubmit
                                              ? true
                                              : false,
                                      onTap: voucherController.isSubmit
                                          ? null
                                          : () async {
                                              voucherController.isClickedCancelBtn = true;
                                              voucherController.update();
                                              if (utr != null &&
                                                  utr!.isNotEmpty) {
                                                await voucherController.voucherPaymentSubmit(
                                                    context: context,
                                                    fields: {
                                                      "utr": utr,
                                                      "status": "5",
                                                    });
                                              } else {
                                                Helpers.showSnackBar(
                                                    msg:
                                                        "Utr is null or empty");
                                              }
                                            },
                                      text:
                                          storedLanguage['Cancel'] ?? "Cancel",
                                    ),
                                  ),
                              ],
                            ),
                            if (voucherController.voucherPreviewList[0].showCharges
                                        .toString() ==
                                    "yes" &&
                                voucherController.voucherPreviewList[0].status.toString() ==
                                    "Pending")
                              VSpace(40.h),
                            if (voucherController.voucherPreviewList[0].showCharges
                                        .toString() ==
                                    "yes" &&
                                voucherController.voucherPreviewList[0].status.toString() ==
                                    "Pending")
                              AppButton(
                                isLoading: voucherController.isSubmit ? true : false,
                                onTap: voucherController.isSubmit
                                    ? null
                                    : () async {
                                        if (utr != null && utr!.isNotEmpty) {
                                          if (voucherController.voucherPreviewList[0]
                                                  .enableFor ==
                                              true) {
                                            if (voucherController.securityPinController.text
                                                .isNotEmpty) {
                                              await voucherController.voucherPreviewSubmit(
                                                  context: context,
                                                  fields: {
                                                    "utr": utr,
                                                    "security_pin": voucherController
                                                        .securityPinController
                                                        .text,
                                                  });
                                            } else {
                                              Helpers.showSnackBar(
                                                  msg:
                                                      "Security Pin is required.");
                                            }
                                          } else {
                                            await voucherController.voucherPreviewSubmit(
                                                context: context,
                                                fields: {
                                                  "utr": utr,
                                                });
                                          }
                                        } else {
                                          Helpers.showSnackBar(
                                              msg: "Utr is null or empty");
                                        }
                                      },
                                text: storedLanguage['Confirm'] ?? "Confirm",
                              ),
                            VSpace(65.h),
                          ],
                        ),
                ),
              ),
      );
    });
  }
}
