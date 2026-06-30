import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:paysecure/config/dimensions.dart';
import 'package:paysecure/utils/services/helpers.dart';
import 'package:paysecure/views/widgets/app_button.dart';
import 'package:paysecure/views/widgets/custom_appbar.dart';
import 'package:paysecure/views/widgets/text_theme_extension.dart';
import '../../../../config/app_colors.dart';
import '../../../../themes/themes.dart';
import '../../../../utils/services/localstorage/hive.dart';
import '../../../../utils/services/localstorage/keys.dart';
import '../../../controllers/makePayment_controller.dart';
import '../../widgets/custom_textfield.dart';
import '../../widgets/spacing.dart';

class MakePaymentPreviewScreen extends StatelessWidget {
  final String? utr;
  final bool? isFromHistoryPage;
  final BuildContext? context;
  const MakePaymentPreviewScreen({
    super.key,
    this.utr = "",
    this.isFromHistoryPage = false,
    this.context,
  });

  @override
  Widget build(BuildContext context) {
    var storedLanguage = HiveHelp.read(Keys.languageData) ?? {};
    return GetBuilder<MakePaymentController>(
      builder: (paymentCtrl) {
        return Scaffold(
          backgroundColor:
              Get.isDarkMode ? AppColors.darkBgColor : AppColors.scaffoldColor,
          appBar: CustomAppBar(
            title:
                storedLanguage['Make Payment Preview'] ??
                "Make Payment Preview",
          ),
          body:
              paymentCtrl.isLoading
                  ? Helpers.appLoader()
                  : SingleChildScrollView(
                    child: Padding(
                      padding: Dimensions.kDefaultPadding,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          VSpace(40.h),
                          paymentCtrl.makePaymentPreviewList.isEmpty
                              ? SizedBox()
                              : Container(
                                width: double.maxFinite,
                                height: 230.h,
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
                                          "Receiver name",
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
                                              paymentCtrl
                                                              .makePaymentPreviewList[0]
                                                              .transaction ==
                                                          null ||
                                                      paymentCtrl
                                                              .makePaymentPreviewList[0]
                                                              .transaction
                                                              ?.merchant ==
                                                          null
                                                  ? ""
                                                  : "${paymentCtrl.makePaymentPreviewList[0].transaction?.merchant?.firstname} ${paymentCtrl.makePaymentPreviewList[0].transaction?.merchant?.lastname} ",
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
                                              "${Helpers.numberFormatWithAsFixed2('', paymentCtrl.makePaymentPreviewList[0].transaction?.amount.toString())} ${paymentCtrl.makePaymentPreviewList[0].transaction?.currency?.code}",
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
                                              "${Helpers.numberFormatWithAsFixed2('', paymentCtrl.makePaymentPreviewList[0].transaction?.charge.toString())} ${paymentCtrl.makePaymentPreviewList[0].transaction?.currency?.code}",
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
                                          "Receiver will get",
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
                                              "${Helpers.numberFormatWithAsFixed2('', paymentCtrl.makePaymentPreviewList[0].transaction?.received_amount.toString())} ${paymentCtrl.makePaymentPreviewList[0].transaction?.currency?.code}",
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              style: context.t.bodyMedium,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),

                                    if (paymentCtrl
                                            .makePaymentPreviewList[0]
                                            .transaction
                                            ?.note
                                            .toString() !=
                                        "null")
                                      Container(
                                        width: double.maxFinite,
                                        height: .5,
                                        color:
                                            AppThemes.getSliderInactiveColor(),
                                      ),
                                    if (paymentCtrl
                                            .makePaymentPreviewList[0]
                                            .transaction
                                            ?.note
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
                                                " ${paymentCtrl.makePaymentPreviewList[0].transaction?.note.toString()}",
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
                            isBorderColor: false,
                            isPrefixIcon: false,
                            controller: paymentCtrl.noteController,
                            hintext:
                                storedLanguage['Say something'] ??
                                "Say something",
                          ),

                          if (paymentCtrl.makePaymentPreviewList.isNotEmpty &&
                              paymentCtrl.makePaymentPreviewList[0].enable ==
                                  true)
                            VSpace(20.h),
                          if (paymentCtrl.makePaymentPreviewList.isNotEmpty &&
                              paymentCtrl.makePaymentPreviewList[0].enable ==
                                  true)
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
                              controller: paymentCtrl.securityPinController,
                            ),
                          VSpace(40.h),
                          paymentCtrl.makePaymentPreviewList.isEmpty
                              ? SizedBox()
                              : AppButton(
                                isLoading: paymentCtrl.isSubmit ? true : false,
                                onTap:
                                    paymentCtrl.isSubmit
                                        ? null
                                        : () async {
                                          if (utr == "") {
                                            Helpers.showSnackBar(
                                              msg: "Utr not found",
                                            );
                                          } else if (paymentCtrl
                                                      .makePaymentPreviewList[0]
                                                      .enable ==
                                                  true &&
                                              paymentCtrl
                                                  .securityPinController
                                                  .text
                                                  .isEmpty) {
                                            Helpers.showSnackBar(
                                              msg: "Security Pin is required",
                                            );
                                          } else {
                                            await paymentCtrl.makePaymentConfirm(
                                              utr: utr.toString(),
                                              isFromHistoryPage:
                                                  isFromHistoryPage,
                                              context: context,
                                              fields: {
                                                if (paymentCtrl
                                                        .makePaymentPreviewList[0]
                                                        .enable ==
                                                    true)
                                                  "security_pin":
                                                      paymentCtrl
                                                          .securityPinController
                                                          .text,
                                                'note':
                                                    paymentCtrl
                                                        .noteController
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
