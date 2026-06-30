import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:paysecure/config/dimensions.dart';
import 'package:paysecure/controllers/request_money_controller.dart';
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

class RequestMoneyPreviewConfirmScreen extends StatelessWidget {
  final String? utr;
  const RequestMoneyPreviewConfirmScreen({super.key, this.utr = ""});

  @override
  Widget build(BuildContext context) {
    var storedLanguage = HiveHelp.read(Keys.languageData) ?? {};
    return GetBuilder<RequestMoneyController>(builder: (requestMoneyController) {
      return Scaffold(
        backgroundColor:
            Get.isDarkMode ? AppColors.darkBgColor : AppColors.scaffoldColor,
        appBar: CustomAppBar(
            title: storedLanguage['Request Confirm'] ?? "Request Confirm"),
        body: requestMoneyController.isLoading
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
                          if (requestMoneyController.receivedAmount.isNotEmpty)
                            Container(
                                width: double.maxFinite,
                                height: 180.h,
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
                                          "Transfer Charge",
                                          style: context.t.displayMedium
                                              ?.copyWith(
                                                  color: AppThemes
                                                      .getParagraphColor()),
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
                                              "${requestMoneyController.payableAmount} ${requestMoneyController.selectedCurrency.toString().split(" ").first}",
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
                                              "${double.parse(requestMoneyController.receivedAmount.toString()).toStringAsFixed(2)} ${requestMoneyController.selectedCurrency.toString().split(" ").first}",
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              style: context.t.bodyMedium),
                                        )),
                                      ],
                                    ),
                                  ],
                                )),
                          if (requestMoneyController.requestMoneyPreviewList[0].enableFor == true)
                            VSpace(48.h),
                          if (requestMoneyController.requestMoneyPreviewList[0].enableFor == true)
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
                              controller: requestMoneyController.securityPinController,
                              onChanged: (v) {},
                            ),
                          VSpace(40.h),
                          AppButton(
                            isLoading: requestMoneyController.isSubmit ? true : false,
                            onTap: requestMoneyController.isLoading || requestMoneyController.isSubmit
                                ? null
                                : () async {
                                    try {
                                      if (requestMoneyController.selectedCurrencyId == "0") {
                                        Helpers.showSnackBar(
                                            msg: "Please select your currency");
                                      } else if (requestMoneyController
                                          .amountController.text.isEmpty) {
                                        Helpers.showSnackBar(
                                            msg: "Amount field is required");
                                      } else {
                                        await requestMoneyController.requestMoneyConfirm(
                                            context: context,
                                            fields: {
                                              "utr": requestMoneyController.utr,
                                              if (requestMoneyController.requestMoneyPreviewList[0]
                                                      .enableFor ==
                                                  true)
                                                "security_pin": requestMoneyController
                                                    .securityPinController.text,
                                            });
                                      }
                                    } catch (e, s) {
                                      print(s);
                                      Helpers.showSnackBar(msg: e.toString());
                                    }
                                  },
                            text: storedLanguage['Confirm'] ?? "Confirm",
                          ),
                          VSpace(40.h),
                        ],
                      ),
                    ),
                  ),
      );
    });
  }
}
