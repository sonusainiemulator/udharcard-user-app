import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:paysecure/config/dimensions.dart';
import 'package:paysecure/controllers/escrow_controller.dart';
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

class EscrowPreviewScreen extends StatelessWidget {
  final String? utr;
  final bool? isFromHistoryPage;
  final BuildContext? context;
  const EscrowPreviewScreen({
    super.key,
    this.utr = "",
    this.isFromHistoryPage = false,
    this.context,
  });

  @override
  Widget build(BuildContext context) {
    var storedLanguage = HiveHelp.read(Keys.languageData) ?? {};
    return GetBuilder<EscrowController>(
      builder: (escrowController) {
        return Scaffold(
          backgroundColor:
              Get.isDarkMode ? AppColors.darkBgColor : AppColors.scaffoldColor,
          appBar: CustomAppBar(
            title: storedLanguage['Escrow Preview'] ?? "Escrow Preview",
          ),
          body:
              escrowController.isLoading
                  ? Helpers.appLoader()
                  : SingleChildScrollView(
                    child: Padding(
                      padding: Dimensions.kDefaultPadding,
                      child:
                          escrowController.escrowPreviewList.isEmpty
                              ? SizedBox()
                              : Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  VSpace(40.h),
                                  escrowController.escrowPreviewList.isEmpty
                                      ? SizedBox()
                                      : Container(
                                        width: double.maxFinite,
                                        height:
                                            escrowController
                                                        .escrowPreviewList[0]
                                                        .note
                                                        .toString() !=
                                                    ""
                                                ? 340.h
                                                : 310.h,
                                        padding: EdgeInsets.symmetric(
                                          horizontal: 16.w,
                                          vertical: 20.h,
                                        ),
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
                                                  storedLanguage['Payable amount'] ??
                                                      "Payable amount",
                                                  style: context.t.displayMedium
                                                      ?.copyWith(
                                                        color:
                                                            AppThemes.getParagraphColor(),
                                                      ),
                                                ),
                                                Expanded(
                                                  child: Align(
                                                    alignment:
                                                        Alignment.centerRight,
                                                    child: Text(
                                                      "${escrowController.escrowPreviewList[0].requestAmount} ${escrowController.escrowPreviewList[0].currency}",
                                                      maxLines: 1,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                            Container(
                                              width: double.maxFinite,
                                              height: .5,
                                              color:
                                                  AppThemes.getSliderInactiveColor(),
                                            ),
                                            Row(
                                              children: [
                                                Text(
                                                  "${storedLanguage['Percentage charge'] ?? "Percentage charge"}  (${escrowController.escrowPreviewList[0].percentage}%)",
                                                  style: context.t.displayMedium
                                                      ?.copyWith(
                                                        color:
                                                            AppThemes.getParagraphColor(),
                                                      ),
                                                ),
                                                Expanded(
                                                  child: Align(
                                                    alignment:
                                                        Alignment.centerRight,
                                                    child: Text(
                                                      "${escrowController.escrowPreviewList[0].percentageCharge} ${escrowController.escrowPreviewList[0].currency}",
                                                      maxLines: 1,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                      style:
                                                          context.t.bodyMedium,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                            Container(
                                              width: double.maxFinite,
                                              height: .5,
                                              color:
                                                  AppThemes.getSliderInactiveColor(),
                                            ),
                                            Row(
                                              children: [
                                                Text(
                                                  storedLanguage['Fixed charge'] ??
                                                      "Fixed charge",
                                                  style: context.t.displayMedium
                                                      ?.copyWith(
                                                        color:
                                                            AppThemes.getParagraphColor(),
                                                      ),
                                                ),
                                                Expanded(
                                                  child: Align(
                                                    alignment:
                                                        Alignment.centerRight,
                                                    child: Text(
                                                      "${escrowController.escrowPreviewList[0].fixedCharge} ${escrowController.escrowPreviewList[0].currency}",
                                                      maxLines: 1,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                      style:
                                                          context.t.bodyMedium,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                            Container(
                                              width: double.maxFinite,
                                              height: .5,
                                              color:
                                                  AppThemes.getSliderInactiveColor(),
                                            ),
                                            Row(
                                              children: [
                                                Text(
                                                  storedLanguage['Total charge'] ??
                                                      "Total charge",
                                                  style: context.t.displayMedium
                                                      ?.copyWith(
                                                        color:
                                                            AppThemes.getParagraphColor(),
                                                      ),
                                                ),
                                                Expanded(
                                                  child: Align(
                                                    alignment:
                                                        Alignment.centerRight,
                                                    child: Text(
                                                      "${escrowController.escrowPreviewList[0].totalCharge} ${escrowController.escrowPreviewList[0].currency}",
                                                      maxLines: 1,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                      style:
                                                          context.t.bodyMedium,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                            Container(
                                              width: double.maxFinite,
                                              height: .5,
                                              color:
                                                  AppThemes.getSliderInactiveColor(),
                                            ),
                                            Row(
                                              children: [
                                                Text(
                                                  storedLanguage['Receivable Amount'] ??
                                                      "Receivable Amount",
                                                  style: context.t.displayMedium
                                                      ?.copyWith(
                                                        color:
                                                            AppThemes.getParagraphColor(),
                                                      ),
                                                ),
                                                Expanded(
                                                  child: Align(
                                                    alignment:
                                                        Alignment.centerRight,
                                                    child: Text(
                                                      "${escrowController.escrowPreviewList[0].receiveAmount} ${escrowController.escrowPreviewList[0].currency}",
                                                      maxLines: 1,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                      style:
                                                          context.t.bodyMedium,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                            if (escrowController
                                                    .escrowPreviewList[0]
                                                    .note
                                                    .toString() !=
                                                "")
                                              Container(
                                                width: double.maxFinite,
                                                height: .5,
                                                color:
                                                    AppThemes.getSliderInactiveColor(),
                                              ),
                                            if (escrowController
                                                    .escrowPreviewList[0]
                                                    .note
                                                    .toString() !=
                                                "")
                                              Row(
                                                children: [
                                                  Text(
                                                    storedLanguage['Note'] ??
                                                        "Note",
                                                    style: context
                                                        .t
                                                        .displayMedium
                                                        ?.copyWith(
                                                          color:
                                                              AppThemes.getParagraphColor(),
                                                        ),
                                                  ),
                                                  Expanded(
                                                    child: Align(
                                                      alignment:
                                                          Alignment.centerRight,
                                                      child: Text(
                                                        " ${escrowController.escrowPreviewList[0].note}",
                                                        maxLines: 1,
                                                        overflow:
                                                            TextOverflow
                                                                .ellipsis,
                                                        style:
                                                            context
                                                                .t
                                                                .bodyMedium,
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            if (escrowController
                                                    .escrowPreviewList[0]
                                                    .status !=
                                                "Pending")
                                              Container(
                                                width: double.maxFinite,
                                                height: .5,
                                                color:
                                                    AppThemes.getSliderInactiveColor(),
                                              ),
                                            if (escrowController
                                                    .escrowPreviewList[0]
                                                    .status !=
                                                "Pending")
                                              Row(
                                                children: [
                                                  Text(
                                                    storedLanguage['Status'] ??
                                                        "Status",
                                                    style: context
                                                        .t
                                                        .displayMedium
                                                        ?.copyWith(
                                                          color:
                                                              AppThemes.getParagraphColor(),
                                                        ),
                                                  ),
                                                  Expanded(
                                                    child: Align(
                                                      alignment:
                                                          Alignment.centerRight,
                                                      child: Text(
                                                        " ${escrowController.escrowPreviewList[0].status}",
                                                        maxLines: 1,
                                                        overflow:
                                                            TextOverflow
                                                                .ellipsis,
                                                        style: context.t.bodyMedium?.copyWith(
                                                          color:
                                                              escrowController
                                                                          .escrowPreviewList[0]
                                                                          .status ==
                                                                      "Generated"
                                                                  ? AppColors
                                                                      .secondaryColor
                                                                  : escrowController
                                                                          .escrowPreviewList[0]
                                                                          .status ==
                                                                      "Pending"
                                                                  ? AppColors
                                                                      .pendingColor
                                                                  : escrowController
                                                                          .escrowPreviewList[0]
                                                                          .status ==
                                                                      "Canceled"
                                                                  ? AppColors
                                                                      .redColor
                                                                  : AppColors
                                                                      .greenColor,
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                          ],
                                        ),
                                      ),
                                  if (escrowController
                                              .escrowPreviewList[0]
                                              .enableFor ==
                                          true &&
                                      escrowController
                                              .escrowPreviewList[0]
                                              .status
                                              .toString() ==
                                          'Pending')
                                    VSpace(48.h),
                                  if (escrowController
                                              .escrowPreviewList[0]
                                              .enableFor ==
                                          true &&
                                      escrowController
                                              .escrowPreviewList[0]
                                              .status
                                              .toString() ==
                                          'Pending')
                                    CustomTextField(
                                      isBorderColor: false,
                                      isSuffixIcon: false,
                                      contentPadding: EdgeInsets.only(
                                        left: 20.w,
                                      ),
                                      hintext:
                                          storedLanguage['Security Pin'] ??
                                          'Security Pin',
                                      keyboardType: TextInputType.number,
                                      inputFormatters: <TextInputFormatter>[
                                        FilteringTextInputFormatter.digitsOnly,
                                      ],
                                      controller:
                                          escrowController
                                              .securityPinController,
                                      onChanged: (v) {},
                                    ),
                                  if (escrowController
                                          .escrowPreviewList[0]
                                          .status
                                          .toString() ==
                                      "Pending")
                                    VSpace(40.h),
                                  if (escrowController
                                          .escrowPreviewList[0]
                                          .status
                                          .toString() ==
                                      "Pending")
                                    AppButton(
                                      isLoading:
                                          escrowController.isSubmit
                                              ? true
                                              : false,
                                      onTap:
                                          escrowController.isSubmit
                                              ? null
                                              : () async {
                                                if (utr != null &&
                                                    utr!.isNotEmpty) {
                                                  // IF THE USER IS FROM ESCROW LIST PAGE
                                                  // if (isFromHistoryPage == true) {
                                                  //   await escrowController.escrowPaymentSubmit(
                                                  //       context: context,
                                                  //       fields: {
                                                  //         "utr": utr,
                                                  //         "status": "4",
                                                  //       });
                                                  // }
                                                  // IF THE USER IS FROM ESCROW CREATE PAGE
                                                  // else {
                                                  if (escrowController
                                                          .escrowPreviewList[0]
                                                          .enableFor ==
                                                      true) {
                                                    if (escrowController
                                                        .securityPinController
                                                        .text
                                                        .isNotEmpty) {
                                                      await escrowController
                                                          .escrowConfirm(
                                                            context: context,
                                                            fields: {
                                                              "utr": utr,
                                                              "security_pin":
                                                                  escrowController
                                                                      .securityPinController
                                                                      .text,
                                                            },
                                                          );
                                                    } else {
                                                      Helpers.showSnackBar(
                                                        msg:
                                                            "Security Pin is required.",
                                                      );
                                                    }
                                                  } else {
                                                    await escrowController
                                                        .escrowConfirm(
                                                          context: context,
                                                          fields: {"utr": utr},
                                                        );
                                                  }
                                                  // }
                                                } else {
                                                  Helpers.showSnackBar(
                                                    msg: "Utr is null or empty",
                                                  );
                                                }
                                              },
                                      text:
                                          storedLanguage['Confirm'] ??
                                          "Confirm",
                                    ),
                                  if (escrowController
                                          .escrowPreviewList[0]
                                          .acceptCancelBtn
                                          .toString() ==
                                      "yes")
                                    VSpace(40.h),
                                  if (escrowController
                                          .escrowPreviewList[0]
                                          .acceptCancelBtn
                                          .toString() ==
                                      "yes")
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Expanded(
                                          child: AppButton(
                                            buttonHeight: 38.h,
                                            bgColor: Colors.transparent,
                                            border: Border.all(
                                              color: AppColors.greenColor,
                                            ),
                                            style: context.t.bodySmall,
                                            isIcon: true,
                                            iconWidget: Container(
                                              padding: EdgeInsets.all(2.h),
                                              margin: EdgeInsets.only(
                                                right: 5.w,
                                                top: 3.h,
                                              ),
                                              decoration: BoxDecoration(
                                                color: AppColors.greenColor,
                                                shape: BoxShape.circle,
                                              ),
                                              child: Icon(
                                                Icons.done,
                                                size: 10.h,
                                                color: AppColors.whiteColor,
                                              ),
                                            ),
                                            isLoading:
                                                escrowController
                                                            .isClickedAcceptBtn &&
                                                        escrowController
                                                            .isSubmit
                                                    ? true
                                                    : false,
                                            onTap:
                                                escrowController.isSubmit
                                                    ? null
                                                    : () async {
                                                      escrowController
                                                              .isClickedCancelBtn =
                                                          false;
                                                      escrowController
                                                              .isClickedAcceptBtn =
                                                          true;
                                                      escrowController.update();
                                                      if (utr != null &&
                                                          utr!.isNotEmpty) {
                                                        await escrowController
                                                            .escrowPaymentSubmit(
                                                              context: context,
                                                              fields: {
                                                                "utr": utr,
                                                                "status": "2",
                                                              },
                                                            );
                                                      } else {
                                                        Helpers.showSnackBar(
                                                          msg:
                                                              "Utr is null or empty",
                                                        );
                                                      }
                                                    },
                                            text:
                                                storedLanguage['Accept'] ??
                                                "Accept",
                                          ),
                                        ),
                                        HSpace(20.w),
                                        Expanded(
                                          child: AppButton(
                                            buttonHeight: 38.h,
                                            bgColor: Colors.transparent,
                                            border: Border.all(
                                              color: AppColors.redColor,
                                            ),
                                            style: context.t.bodySmall,
                                            isIcon: true,
                                            iconWidget: Container(
                                              padding: EdgeInsets.all(2.h),
                                              margin: EdgeInsets.only(
                                                right: 5.w,
                                                top: 3.h,
                                              ),
                                              decoration: BoxDecoration(
                                                color: AppColors.redColor,
                                                shape: BoxShape.circle,
                                              ),
                                              child: Icon(
                                                Icons.close,
                                                size: 10.h,
                                                color: AppColors.whiteColor,
                                              ),
                                            ),
                                            isLoading:
                                                escrowController
                                                            .isClickedCancelBtn &&
                                                        escrowController
                                                            .isSubmit
                                                    ? true
                                                    : false,
                                            onTap:
                                                escrowController.isSubmit
                                                    ? null
                                                    : () async {
                                                      escrowController
                                                              .isClickedAcceptBtn =
                                                          false;
                                                      escrowController
                                                              .isClickedCancelBtn =
                                                          true;
                                                      escrowController.update();
                                                      if (utr != null &&
                                                          utr!.isNotEmpty) {
                                                        await escrowController
                                                            .escrowPaymentSubmit(
                                                              context: context,
                                                              fields: {
                                                                "utr": utr,
                                                                "status": "5",
                                                              },
                                                            );
                                                      } else {
                                                        Helpers.showSnackBar(
                                                          msg:
                                                              "Utr is null or empty",
                                                        );
                                                      }
                                                    },
                                            text:
                                                storedLanguage['Cancel'] ??
                                                "Cancel",
                                          ),
                                        ),
                                      ],
                                    ),
                                  if (escrowController
                                          .escrowPreviewList[0]
                                          .paymentDisbursedBtn
                                          .toString() ==
                                      "yes")
                                    VSpace(40.h),
                                  if (escrowController
                                          .escrowPreviewList[0]
                                          .paymentDisbursedBtn
                                          .toString() ==
                                      "yes")
                                    AppButton(
                                      isLoading:
                                          escrowController.isSubmit
                                              ? true
                                              : false,
                                      onTap:
                                          escrowController.isSubmit
                                              ? null
                                              : () async {
                                                if (utr != null &&
                                                    utr!.isNotEmpty) {
                                                  await escrowController
                                                      .escrowPaymentSubmit(
                                                        context: context,
                                                        fields: {
                                                          "utr": utr,
                                                          "status": "4",
                                                        },
                                                      );
                                                } else {
                                                  Helpers.showSnackBar(
                                                    msg: "Utr is null or empty",
                                                  );
                                                }
                                              },
                                      text:
                                          storedLanguage['Disbursed'] ??
                                          "Disbursed",
                                    ),
                                  VSpace(60.h),
                                ],
                              ),
                    ),
                  ),
        );
      },
    );
  }
}
