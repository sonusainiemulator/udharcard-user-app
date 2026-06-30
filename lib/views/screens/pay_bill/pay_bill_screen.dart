import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:paysecure/config/dimensions.dart';
import 'package:paysecure/controllers/pay_bill_controller.dart';
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

class PayBillScreen extends StatelessWidget {
  const PayBillScreen({super.key});

  @override
  Widget build(BuildContext context) {
    PayBillController.to.scrollController = ScrollController();
    var storedLanguage = HiveHelp.read(Keys.languageData) ?? {};
    return GetBuilder<PayBillController>(
      builder: (payBillController) {
        return Scaffold(
          backgroundColor:
              Get.isDarkMode ? AppColors.darkBgColor : AppColors.scaffoldColor,
          appBar: CustomAppBar(
            title: storedLanguage['Pay Bill'] ?? "Pay Bill",
            bgColor:
                Get.isDarkMode
                    ? AppColors.darkBgColor
                    : AppColors.scaffoldColor,
          ),
          body:
              payBillController.isLoading
                  ? Helpers.appLoader()
                  : RefreshIndicator(
                    color: AppColors.mainColor,
                    onRefresh: () async {
                      payBillController.refreshPayBillData();
                      await payBillController.getPayBill();
                    },
                    child: SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      child: Padding(
                        padding: Dimensions.kDefaultPadding,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            VSpace(40.h),
                            if (payBillController.categoryList.isNotEmpty)
                              Container(
                                height: 50.h,
                                decoration: BoxDecoration(
                                  color: AppThemes.getDarkCardColor(),
                                  borderRadius: Dimensions.kBorderRadius,
                                  border: Border.all(
                                    color: AppThemes.getSliderInactiveColor(),
                                    width: 1,
                                  ),
                                ),
                                child: AppCustomDropDown(
                                  paddingLeft: 22.w,
                                  height: 50.h,
                                  width: double.infinity,
                                  items:
                                      payBillController.countryMap.entries
                                          .map((e) => e.value)
                                          .toList(),
                                  selectedValue:
                                      payBillController.selectedCountryVal,
                                  onChanged: (v) async {
                                    payBillController.onCountryChange(v);
                                  },
                                  hint:
                                      storedLanguage['Select Country'] ??
                                      "Select Country",
                                  selectedStyle: context.t.displayMedium,
                                  bgColor: AppThemes.getFillColor(),
                                  hintStyle: context.t.bodySmall?.copyWith(
                                    color: AppColors.textFieldHintColor,
                                    fontWeight: FontWeight.w400,
                                    fontSize: 18.sp,
                                  ),
                                ),
                              ),
                            VSpace(32.h),
                            Container(
                              height: 50.h,
                              decoration: BoxDecoration(
                                color: AppThemes.getDarkCardColor(),
                                borderRadius: Dimensions.kBorderRadius,
                                border: Border.all(
                                  color: AppThemes.getSliderInactiveColor(),
                                  width: 1,
                                ),
                              ),
                              child: AppCustomDropDown(
                                paddingLeft: 22.w,
                                height: 50.h,
                                width: double.infinity,
                                items:
                                    payBillController.filteredBillServiceList
                                        .map((e) => e.type.toString())
                                        .toList(),
                                selectedValue:
                                    payBillController.selectedService,
                                onChanged: payBillController.onServiceChange,
                                hint:
                                    storedLanguage['Select Service'] ??
                                    "Select Service",
                                selectedStyle: context.t.displayMedium,
                                bgColor: AppThemes.getFillColor(),
                                hintStyle: context.t.bodySmall?.copyWith(
                                  color: AppColors.textFieldHintColor,
                                  fontWeight: FontWeight.w400,
                                  fontSize: 18.sp,
                                ),
                              ),
                            ),
                            VSpace(32.h),
                            if (payBillController.labelName.isNotEmpty) ...[
                              ListView.builder(
                                shrinkWrap: true,
                                padding: EdgeInsets.zero,
                                physics: NeverScrollableScrollPhysics(),
                                itemCount: payBillController.labelName.length,
                                itemBuilder: (context, index) {
                                  final dynamicField =
                                      payBillController.labelName[index];
                                  return CustomTextField(
                                    isBorderColor: true,
                                    isSuffixIcon: false,
                                    fillColor: AppThemes.getDarkCardColor(),
                                    contentPadding: EdgeInsets.only(left: 20.w),
                                    hintext: dynamicField,
                                    controller:
                                        payBillController
                                            .labelControllerMap[dynamicField] ??
                                        TextEditingController(),
                                    onChanged: (v) {
                                      payBillController
                                          .labelControllerMap[dynamicField]!
                                          .text = v;
                                      payBillController.update();
                                    },
                                  );
                                },
                              ),
                            ],
                            if (payBillController
                                .filteredAmountDescriptionList
                                .isNotEmpty)
                              VSpace(32.h),
                            if (payBillController
                                .filteredAmountDescriptionList
                                .isNotEmpty)
                              Container(
                                height: 50.h,
                                decoration: BoxDecoration(
                                  color: AppThemes.getDarkCardColor(),
                                  borderRadius: Dimensions.kBorderRadius,
                                  border: Border.all(
                                    color: AppThemes.getSliderInactiveColor(),
                                    width: 1,
                                  ),
                                ),
                                child: AppCustomDropDown(
                                  paddingLeft: 22.w,
                                  height: 50.h,
                                  width: double.infinity,
                                  items:
                                      payBillController
                                          .filteredAmountDescriptionList
                                          .map((e) => e.value.toString())
                                          .toList(),
                                  selectedValue:
                                      payBillController.selectedAmountVAl,
                                  onChanged: payBillController.onAmountChanged,
                                  hint: storedLanguage['Amount'] ?? "Amount",
                                  selectedStyle: context.t.displayMedium,
                                  bgColor: AppThemes.getFillColor(),
                                  hintStyle: context.t.bodySmall?.copyWith(
                                    color: AppColors.textFieldHintColor,
                                    fontWeight: FontWeight.w400,
                                    fontSize: 18.sp,
                                  ),
                                ),
                              ),
                            if (payBillController
                                .filteredAmountDescriptionList
                                .isEmpty)
                              VSpace(32.h),
                            if (payBillController
                                    .filteredAmountDescriptionList
                                    .isEmpty &&
                                payBillController.selectedService != null)
                              CustomTextField(
                                isBorderColor: true,
                                fillColor: AppThemes.getDarkCardColor(),
                                isSuffixIcon: false,
                                contentPadding: EdgeInsets.only(left: 20.w),
                                hintext: storedLanguage['Amount'] ?? 'Amount',
                                keyboardType: TextInputType.number,
                                inputFormatters: <TextInputFormatter>[
                                  FilteringTextInputFormatter.digitsOnly,
                                ],
                                controller: payBillController.amountController,
                                onChanged: (v) {},
                              ),
                            VSpace(40.h),
                            AppButton(
                              isLoading:
                                  payBillController.isSubmit ? true : false,
                              onTap:
                                  payBillController.isSubmit
                                      ? null
                                      : () async {
                                        try {
                                          if (payBillController
                                              .selectedCategoryVal
                                              .isEmpty) {
                                            Helpers.showSnackBar(
                                              msg:
                                                  "Please select your category.",
                                            );
                                          } else if (payBillController
                                              .selectedCurrencyId
                                              .isEmpty) {
                                            Helpers.showSnackBar(
                                              msg:
                                                  "Please select your currency.",
                                            );
                                          } else if (payBillController
                                                  .selectedService ==
                                              null) {
                                            Helpers.showSnackBar(
                                              msg:
                                                  "Please select your service.",
                                            );
                                          } else if (payBillController
                                                  .amountController
                                                  .text
                                                  .isEmpty &&
                                              payBillController
                                                  .selectedAmountVAl
                                                  .toString()
                                                  .isEmpty) {
                                            Helpers.showSnackBar(
                                              msg: "Please enter your amount.",
                                            );
                                          } else {
                                            Map<String, dynamic> body = {
                                              "category":
                                                  payBillController
                                                      .selectedCategoryVal,
                                              "country":
                                                  payBillController
                                                      .selectedCountryKey,
                                              "service":
                                                  payBillController.serviceId,
                                              "amount":
                                                  payBillController
                                                          .filteredAmountDescriptionList
                                                          .isEmpty
                                                      ? payBillController
                                                          .amountController
                                                          .text
                                                      : payBillController
                                                          .selectedAmountKey,
                                              "from_wallet":
                                                  payBillController
                                                      .selectedCurrencyId,
                                            };

                                            for (var i
                                                in payBillController
                                                    .labelControllerMap
                                                    .entries) {
                                              body[i.key] = i.value.text;
                                            }

                                            await payBillController
                                                .submitPayBill(fields: body);
                                          }
                                        } catch (e) {
                                          Helpers.showSnackBar(
                                            msg: e.toString(),
                                          );
                                        }
                                      },
                              text: storedLanguage['Continue'] ?? "Continue",
                            ),
                            VSpace(40.h),
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
