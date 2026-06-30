import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:paysecure/config/dimensions.dart';
import 'package:paysecure/controllers/redeem_code_controller.dart';
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

class RedeemPreviewScreen extends StatelessWidget {
  final String? utr;
  final bool? isFromHistoryPag;
  final BuildContext? context;
  const RedeemPreviewScreen({
    super.key,
    this.utr = "",
    this.isFromHistoryPag = false,
    this.context,
  });

  @override
  Widget build(BuildContext context) {
    var storedLanguage = HiveHelp.read(Keys.languageData) ?? {};
    return GetBuilder<RedeemCodeController>(
      builder: (redeemCodeController) {
        return Scaffold(
          backgroundColor:
              Get.isDarkMode ? AppColors.darkBgColor : AppColors.scaffoldColor,
          appBar: CustomAppBar(
            title: storedLanguage['Redeem Preview'] ?? "Redeem Preview",
          ),
          body:
              redeemCodeController.isLoading
                  ? Helpers.appLoader()
                  : SingleChildScrollView(
                    child: Padding(
                      padding: Dimensions.kDefaultPadding,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          VSpace(40.h),
                          redeemCodeController.generatedCodePreviewList.isEmpty
                              ? SizedBox()
                              : Container(
                                width: double.maxFinite,
                                height: 350.h,
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
                                          "Percentage charge (${redeemCodeController.generatedCodePreviewList[0].percentage}%)",
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
                                              "${redeemCodeController.generatedCodePreviewList[0].percentageCharge} ${redeemCodeController.generatedCodePreviewList[0].currency}",
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
                                          "Fixed charge",
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
                                              "${redeemCodeController.generatedCodePreviewList[0].fixedCharge} ${redeemCodeController.generatedCodePreviewList[0].currency}",
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
                                          "Total charge",
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
                                              "${redeemCodeController.generatedCodePreviewList[0].totalCharge} ${redeemCodeController.generatedCodePreviewList[0].currency}",
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
                                              "${redeemCodeController.generatedCodePreviewList[0].payableAmount} ${redeemCodeController.generatedCodePreviewList[0].currency}",
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
                                              "${redeemCodeController.generatedCodePreviewList[0].receiverWillReceive} ${redeemCodeController.generatedCodePreviewList[0].currency}",
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
                                          "Charge deduct from",
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
                                              "${redeemCodeController.generatedCodePreviewList[0].chargeDeductFrom}",
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              style: context.t.bodyMedium,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    if (redeemCodeController
                                            .generatedCodePreviewList[0]
                                            .note
                                            .toString() !=
                                        "null")
                                      Container(
                                        width: double.maxFinite,
                                        height: .5,
                                        color:
                                            AppThemes.getSliderInactiveColor(),
                                      ),
                                    if (redeemCodeController
                                            .generatedCodePreviewList[0]
                                            .note
                                            .toString() !=
                                        "null")
                                      Row(
                                        children: [
                                          Text(
                                            "Note",
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
                                                " ${redeemCodeController.generatedCodePreviewList[0].note}",
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
                          VSpace(48.h),

                          CustomTextField(
                            isBorderColor: false,
                            isSuffixIcon: false,
                            contentPadding: EdgeInsets.only(left: 20.w),
                            hintext:
                                storedLanguage['Security Pin'] ??
                                'Security Pin',
                            keyboardType: TextInputType.number,
                            inputFormatters: <TextInputFormatter>[
                              FilteringTextInputFormatter.digitsOnly,
                            ],
                            controller:
                                redeemCodeController.securityPinController,
                          ),
                          VSpace(40.h),
                          redeemCodeController.generatedCodePreviewList.isEmpty
                              ? SizedBox()
                              : AppButton(
                                isLoading:
                                    redeemCodeController.isSubmit
                                        ? true
                                        : false,
                                onTap:
                                    redeemCodeController.isSubmit
                                        ? null
                                        : () async {
                                          if (utr == "") {
                                            Helpers.showSnackBar(
                                              msg: "Utr not found",
                                            );
                                          } else {
                                            await redeemCodeController
                                                .generateCodeConfirm(
                                                  isFromHistoryPage:
                                                      isFromHistoryPag,
                                                  context:
                                                      isFromHistoryPag == true
                                                          ? context
                                                          : null,
                                                  fields: {
                                                    "utr": utr,
                                                    "security_pin":
                                                        redeemCodeController
                                                            .securityPinController
                                                            .text,
                                                  },
                                                );
                                          }
                                        },
                                text: storedLanguage['Confirm'] ?? "Confirm",
                              ),
                        ],
                      ),
                    ),
                  ),
        );
      },
    );
  }
}
