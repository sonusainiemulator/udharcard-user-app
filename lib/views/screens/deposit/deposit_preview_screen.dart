import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:paysecure/controllers/deposit_history_controller.dart';
import 'package:paysecure/views/widgets/text_theme_extension.dart';
import '../../../config/app_colors.dart';
import '../../../config/dimensions.dart';
import '../../../controllers/deposit_controller.dart';
import '../../../data/models/deposit_history_model.dart';
import '../../../utils/services/helpers.dart';
import '../../../utils/services/localstorage/hive.dart';
import '../../../utils/services/localstorage/keys.dart';
import '../../widgets/app_button.dart';
import '../../widgets/custom_appbar.dart';
import '../../widgets/spacing.dart';

class DepositPreviewScreen extends StatelessWidget {
  final Fund? fund;
  const DepositPreviewScreen({super.key, this.fund});

  @override
  Widget build(BuildContext context) {
    var storedLanguage = HiveHelp.read(Keys.languageData) ?? {};

    return GetBuilder<DepositController>(builder: (depositCtrl) {
      return GetBuilder<DepositHistoryController>(
          builder: (depositHistoryCtrl) {
        return Scaffold(
          appBar: CustomAppBar(
            title: storedLanguage['Deposit Preview'] ?? "Deposit Preview",
          ),
          body: Padding(
            padding: Dimensions.kDefaultPadding,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                VSpace(50.h),
                Container(
                  height: 250.h,
                  width: double.maxFinite,
                  decoration: BoxDecoration(
                    borderRadius: Dimensions.kBorderRadius,
                    border: Border.all(
                        color: Get.isDarkMode
                            ? AppColors.black60
                            : AppColors.black30,
                        width: Dimensions.appThinBorder),
                  ),
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 12.h),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 16.w),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text("Gateway",
                                  style: context.t.displayMedium?.copyWith(
                                      color: Get.isDarkMode
                                          ? AppColors.textFieldHintColor
                                          : AppColors.paragraphColor)),
                              Expanded(
                                  child: Container(
                                alignment: Alignment.centerRight,
                                child: Text("${fund?.gateway?.name}",
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: context.t.displayMedium),
                              )),
                            ],
                          ),
                        ),
                        Container(
                          height: .2,
                          color: Get.isDarkMode
                              ? AppColors.black60
                              : AppColors.black30,
                        ),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 16.w),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(storedLanguage['Name'] ?? "Name",
                                  style: context.t.displayMedium?.copyWith(
                                      color: Get.isDarkMode
                                          ? AppColors.textFieldHintColor
                                          : AppColors.paragraphColor)),
                              Expanded(
                                  child: Container(
                                alignment: Alignment.centerRight,
                                child: Text("${fund?.user?.name}",
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: context.t.displayMedium?.copyWith(
                                      color: AppColors.redColor,
                                    )),
                              )),
                            ],
                          ),
                        ),
                        Container(
                          height: .2,
                          color: Get.isDarkMode
                              ? AppColors.black60
                              : AppColors.black30,
                        ),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 16.w),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(storedLanguage['Amount'] ?? "Amount",
                                  style: context.t.displayMedium?.copyWith(
                                      color: Get.isDarkMode
                                          ? AppColors.textFieldHintColor
                                          : AppColors.paragraphColor)),
                              Expanded(
                                  child: Container(
                                alignment: Alignment.centerRight,
                                child: Text(
                                    "${Helpers.numberFormatWithAsFixed2("", fund!.amount.toString())} ${fund!.currency!.code}",
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: context.t.displayMedium?.copyWith(
                                      color: AppColors.greenColor,
                                    )),
                              )),
                            ],
                          ),
                        ),
                        Container(
                          height: .2,
                          color: Get.isDarkMode
                              ? AppColors.black60
                              : AppColors.black30,
                        ),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 16.w),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(storedLanguage['Charge'] ?? "Charge",
                                  style: context.t.displayMedium?.copyWith(
                                      color: Get.isDarkMode
                                          ? AppColors.textFieldHintColor
                                          : AppColors.paragraphColor)),
                              Expanded(
                                  child: Container(
                                alignment: Alignment.centerRight,
                                child: Text(
                                    "${Helpers.numberFormatWithAsFixed2('', fund!.charge.toString())}  ${fund!.currency!.code}",
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: context.t.displayMedium?.copyWith(
                                      color: AppColors.redColor,
                                    )),
                              )),
                            ],
                          ),
                        ),
                        Container(
                          height: .2,
                          color: Get.isDarkMode
                              ? AppColors.black60
                              : AppColors.black30,
                        ),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 16.w),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                  storedLanguage['Payable Amount'] ??
                                      "Payable Amount",
                                  style: context.t.displayMedium?.copyWith(
                                      color: Get.isDarkMode
                                          ? AppColors.textFieldHintColor
                                          : AppColors.paragraphColor)),
                              Expanded(
                                  child: Container(
                                alignment: Alignment.centerRight,
                                child: Text(
                                    "${Helpers.numberFormatWithAsFixed2('', fund!.payableAmount.toString())}  ${fund!.currency!.code}",
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: context.t.displayMedium?.copyWith(
                                      color: AppColors.greenColor,
                                    )),
                              )),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                VSpace(45.h),
                Material(
                  color: Colors.transparent,
                  child: AppButton(
                    isLoading: depositCtrl.isLoadingPaymentSheet ? true : false,
                    onTap: depositCtrl.isLoadingPaymentSheet
                        ? null
                        : () async {
                            await depositCtrl.onPaymentDone(
                                fields: {'utr': fund!.trxId.toString()});
                          },
                    text: storedLanguage['Confirm & Next'] ?? "Confirm & Next",
                  ),
                ),
              ],
            ),
          ),
        );
      });
    });
  }
}
