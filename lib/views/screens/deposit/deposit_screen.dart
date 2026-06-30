import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:paysecure/views/widgets/text_theme_extension.dart';
import '../../../config/app_colors.dart';
import '../../../config/dimensions.dart';
import '../../../controllers/deposit_controller.dart';
import '../../../themes/themes.dart';
import '../../../utils/services/helpers.dart';
import '../../../utils/services/localstorage/hive.dart';
import '../../../utils/services/localstorage/keys.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_custom_dropdown.dart';
import '../../widgets/custom_appbar.dart';
import '../../widgets/custom_textfield.dart';
import '../../widgets/spacing.dart';

class DepositScreen extends StatefulWidget {
  final bool? isFromBottomNav;
  const DepositScreen({super.key, this.isFromBottomNav = true});

  @override
  State<DepositScreen> createState() => _DepositScreenState();
}

class _DepositScreenState extends State<DepositScreen> {
  FocusNode node = FocusNode();
  @override
  void initState() {
    node.addListener(() {
      setState(() {});
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    TextTheme t = Theme.of(context).textTheme;
    Get.put(DepositController());
    var storedLanguage = HiveHelp.read(Keys.languageData) ?? {};

    return GetBuilder<DepositController>(builder: (depositController) {
      return Scaffold(
        appBar: CustomAppBar(
          title: storedLanguage['Deposit'] ?? "Deposit",
        ),
        body: depositController.isLoading
            ? Helpers.appLoader()
            : depositController.paymentGatewayList.isEmpty
                ? Helpers.notFound()
                : Padding(
                    padding: Dimensions.kDefaultPadding,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        VSpace(32.h),
                        CustomTextField(
                          isBorderColor: true,
                          hintext: storedLanguage['Search Gateway'] ??
                              "Search Gateway",
                          controller: depositController.gatewayEditingController,
                          onChanged: depositController.queryPaymentGateway,
                          isSuffixIcon: true,
                          isSuffixBgColor: true,
                          suffixIcon: "search",
                          suffixIconColor: Get.isDarkMode
                              ? AppColors.whiteColor
                              : AppColors.blackColor,
                        ),
                        VSpace(32.h),
                        Expanded(
                            child: Container(
                          padding: EdgeInsets.symmetric(vertical: 10.h),
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12.r),
                              border: Border.all(
                                  color: Get.isDarkMode
                                      ? AppColors.darkCardColorDeep
                                      : AppColors.black20,
                                  width: Get.isDarkMode ? .6 : .2)),
                          child: ListView.builder(
                              itemCount: depositController.isGatewaySearching
                                  ? depositController.searchedGatewayItem.length
                                  : depositController.paymentGatewayList.length,
                              itemBuilder: (context, i) {
                                var data = depositController.isGatewaySearching
                                    ? depositController.searchedGatewayItem[i]
                                    : depositController.paymentGatewayList[i];
                                return Padding(
                                  padding: EdgeInsets.only(bottom: 10.h),
                                  child: InkWell(
                                    borderRadius: Dimensions.kBorderRadius / 2,
                                    onTap: () async {
                                      Helpers.hideKeyboard();
                                      depositController.selectedGatewayIndex = i;
                                      depositController.getGatewayData(i);
                                      depositController.getSelectedGatewayData(i);
                                      depositController.update();
                                      buildDialog(context, depositController, storedLanguage);
                                    },
                                    child: Container(
                                      padding: EdgeInsets.symmetric(
                                          vertical: 12.h, horizontal: 16.w),
                                      decoration: BoxDecoration(
                                        border: Border(
                                            bottom: BorderSide(
                                                color: Get.isDarkMode
                                                    ? AppColors
                                                        .darkCardColorDeep
                                                    : AppColors.black20,
                                                width:
                                                    Get.isDarkMode ? .6 : .2)),
                                      ),
                                      child: Row(
                                        children: [
                                          Container(
                                            height: 42.h,
                                            width: 64.w,
                                            decoration: BoxDecoration(
                                                color: Get.isDarkMode
                                                    ? AppColors.darkBgColor
                                                    : AppColors.fillColorColor,
                                                borderRadius:
                                                    Dimensions.kBorderRadius /
                                                        2,
                                                image: DecorationImage(
                                                  image:
                                                      CachedNetworkImageProvider(
                                                          data.imagePath),
                                                  fit: BoxFit.cover,
                                                )),
                                          ),
                                          HSpace(16.w),
                                          Expanded(
                                              child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(data.name.toString(),
                                                  style: t.bodyMedium),
                                              VSpace(1.h),
                                              Text(data.description.toString(),
                                                  maxLines: 3,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  style: t.bodySmall?.copyWith(
                                                      color: AppThemes
                                                          .getParagraphColor())),
                                            ],
                                          )),
                                          Container(
                                            width: 20.h,
                                            height: 20.h,
                                            decoration: BoxDecoration(
                                              color: depositController.selectedGatewayIndex == i
                                                  ? AppColors.mainColor
                                                  : Colors.transparent,
                                              border: Border.all(
                                                  color: depositController.selectedGatewayIndex !=
                                                          i
                                                      ? Get.isDarkMode
                                                          ? AppColors
                                                              .darkCardColorDeep
                                                          : AppColors.black20
                                                      : Colors.transparent),
                                              shape: BoxShape.circle,
                                            ),
                                            child: Center(
                                              child: Icon(
                                                Icons.done_rounded,
                                                size: 14.h,
                                                color:
                                                    depositController.selectedGatewayIndex == i
                                                        ? AppColors.whiteColor
                                                        : Colors.transparent,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                              }),
                        )),
                      ],
                    ),
                  ),
      );
    });
  }

  Future<dynamic> buildDialog(
      BuildContext context, DepositController depositController, storedLanguage) {
    return showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return GetBuilder<DepositController>(builder: (_) {
          return Container(
              padding: Dimensions.kDefaultPadding,
              height: MediaQuery.of(context).size.height * 0.8,
              width: MediaQuery.of(context).size.width,
              decoration: BoxDecoration(
                color: AppThemes.getDarkCardColor(),
                borderRadius: Dimensions.kBorderRadius * 2,
              ),
              child: ListView(
                children: [
                  VSpace(32.h),
                  if (depositController.gatewayName != "")
                    Padding(
                      padding: Dimensions.kDefaultPadding,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Align(
                            alignment: Alignment.center,
                            child: Row(
                              children: [
                                depositController.minAmount == '0.00' && depositController.maxAmount == '0.00'
                                    ? const SizedBox()
                                    : Text(
                                        "${storedLanguage['Transaction Limit:'] ?? "Transaction Limit:"} ${Helpers.numberFormatWithAsFixed2('', depositController.minAmount)}-${Helpers.numberFormatWithAsFixed2('', depositController.maxAmount)} ${depositController.selectedCurrency}",
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: context.t.bodySmall?.copyWith(
                                            color: AppColors.redColor),
                                      ),
                                Spacer(),
                                Material(
                                  color: Colors.transparent,
                                  borderRadius: BorderRadius.circular(50),
                                  child: InkWell(
                                    borderRadius: BorderRadius.circular(50),
                                    onTap: () {
                                      Get.back();
                                    },
                                    child: Ink(
                                      height: 26.h,
                                      width: 26.h,
                                      padding: EdgeInsets.all(3.h),
                                      decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: Get.isDarkMode
                                              ? AppColors.darkBgColor
                                              : AppColors.sliderInActiveColor),
                                      child: Icon(
                                        Icons.close,
                                        size: 15.h,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          VSpace(20.h),
                          depositController.selectedCurrency == null
                              ? const SizedBox()
                              : VSpace(12.h),
                          Text(
                            storedLanguage['Select Gateway Currency'] ??
                                "Select Gateway Currency",
                            style: context.t.displayMedium,
                          ),
                          VSpace(12.h),
                          Container(
                            height: 50.h,
                            decoration: BoxDecoration(
                              border: Border.all(
                                  color: AppThemes.getSliderInactiveColor()),
                              borderRadius: Dimensions.kBorderRadius,
                            ),
                            child: AppCustomDropDown(
                              height: 50.h,
                              width: double.infinity,
                              items: depositController.supportedCurrencyList
                                  .map((e) => e)
                                  .toList(),
                              selectedValue: depositController.selectedCurrency,
                              onChanged: (value) async {
                                depositController.selectedCurrency = value;
                                if (depositController.is_crypto == false) {
                                  depositController.getSelectedCurrencyData(value);
                                }
                                depositController.update();
                              },
                              hint: storedLanguage['Select currency'] ??
                                  "Select currency",
                              selectedStyle: context.t.displayMedium,
                              bgColor: Get.isDarkMode
                                  ? AppColors.darkBgColor
                                  : AppColors.fillColorColor,
                            ),
                          ),
                          VSpace(20.h),
                          depositController.selectedCurrency == null ||
                                  depositController.isCurrencySupportedFromAdmin == false
                              ? const SizedBox()
                              : Text(storedLanguage['Amount'] ?? 'Amount',
                                  style: context.t.displayMedium),
                          depositController.selectedCurrency == null ||
                                  depositController.isCurrencySupportedFromAdmin == false
                              ? const SizedBox()
                              : VSpace(12.h),
                          depositController.selectedCurrency == null ||
                                  depositController.isCurrencySupportedFromAdmin == false
                              ? const SizedBox()
                              : CustomTextField(
                                  focusNode: node,
                                  suffixIcon: depositController.amountValue.isEmpty
                                      ? null
                                      : depositController.isFollowedTransactionLimit
                                          ? "check"
                                          : "warning",
                                  suffixIconSize: depositController.isFollowedTransactionLimit
                                      ? 20.h
                                      : 15.h,
                                  suffixIconColor: depositController.isFollowedTransactionLimit
                                      ? AppColors.greenColor
                                      : AppColors.redColor,
                                  contentPadding: EdgeInsets.only(left: 20.w),
                                  hintext: storedLanguage['Enter Amount'] ??
                                      'Enter Amount',
                                  keyboardType: TextInputType.number,
                                  inputFormatters: <TextInputFormatter>[
                                    FilteringTextInputFormatter.digitsOnly,
                                    LengthLimitingTextInputFormatter(
                                        depositController.maxAmount.length),
                                  ],
                                  controller: depositController.amountCtrl,
                                  onChanged: depositController.onChangedAmount,
                                ),
                          VSpace(16.h),
                          if (depositController.amountValue.isNotEmpty &&
                              depositController.selectedCurrency != null)
                            Container(
                              height: 180.h,
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
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Padding(
                                      padding: EdgeInsets.symmetric(
                                          horizontal: 16.w),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                              "Amount In ${depositController.is_crypto ? "USD" : depositController.selectedCurrency}",
                                              style: context
                                                  .t.displayMedium
                                                  ?.copyWith(
                                                      color: Get.isDarkMode
                                                          ? AppColors
                                                              .textFieldHintColor
                                                          : AppColors
                                                              .paragraphColor)),
                                          Expanded(
                                              child: Container(
                                            alignment: Alignment.centerRight,
                                            child: Text(
                                                "${depositController.amountValue} ${depositController.is_crypto ? "USD" : depositController.selectedCurrency}",
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
                                      padding: EdgeInsets.symmetric(
                                          horizontal: 16.w),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                              storedLanguage['Charge'] ??
                                                  "Charge",
                                              style: context.t.displayMedium
                                                  ?.copyWith(
                                                      color: Get.isDarkMode
                                                          ? AppColors
                                                              .textFieldHintColor
                                                          : AppColors
                                                              .paragraphColor)),
                                          Expanded(
                                              child: Container(
                                            alignment: Alignment.centerRight,
                                            child: Text(
                                                "${Helpers.numberFormatWithAsFixed2("", depositController.percentageCharge)} ${depositController.is_crypto ? "USD" : depositController.selectedCurrency}",
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                                style: context.t.displayMedium
                                                    ?.copyWith(
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
                                      padding: EdgeInsets.symmetric(
                                          horizontal: 16.w),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                              storedLanguage[
                                                      'Payable Amount'] ??
                                                  "Payable Amount",
                                              style: context.t.displayMedium
                                                  ?.copyWith(
                                                      color: Get.isDarkMode
                                                          ? AppColors
                                                              .textFieldHintColor
                                                          : AppColors
                                                              .paragraphColor)),
                                          Expanded(
                                              child: Container(
                                            alignment: Alignment.centerRight,
                                            child: Text(
                                                "${Helpers.numberFormatWithAsFixed2("", depositController.totalChargedAmount)} ${depositController.is_crypto ? "USD" : depositController.selectedCurrency}",
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                                style: context.t.displayMedium
                                                    ?.copyWith(
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
                                      padding: EdgeInsets.symmetric(
                                          horizontal: 16.w),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                              storedLanguage[
                                                      'In Base Currency'] ??
                                                  "In Base Currency",
                                              style: context.t.displayMedium
                                                  ?.copyWith(
                                                      color: Get.isDarkMode
                                                          ? AppColors
                                                              .textFieldHintColor
                                                          : AppColors
                                                              .paragraphColor)),
                                          Expanded(
                                              child: Container(
                                            alignment: Alignment.centerRight,
                                            child: Text(
                                                "${depositController.totalPayableAmountInBaseCurrency}  ${HiveHelp.read(Keys.baseCurrency)}",
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                                style: context.t.displayMedium
                                                    ?.copyWith(
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
                          VSpace(32.h),
                          Material(
                            color: Colors.transparent,
                            child: AppButton(
                              isLoading: depositController.isLoadingPaymentSheet ? true : false,
                              onTap: depositController.isLoadingPaymentSheet
                                  ? null
                                  : () async {
                                      Helpers.hideKeyboard();
                                      if (depositController.amountCtrl.text.isEmpty) {
                                        Helpers.showSnackBar(
                                            msg: "Amount field is required");
                                      } else if (depositController
                                              .isCurrencySupportedFromAdmin ==
                                          false) {
                                        Helpers.showSnackBar(
                                            msg:
                                                "This currency is unavailable for deposits");
                                      } else {
                                        if (double.parse(depositController.amountCtrl.text) <
                                            double.parse(depositController.minAmount)) {
                                          Helpers.showSnackBar(
                                              msg:
                                                  "minimum payment ${Helpers.numberFormatWithAsFixed2('', depositController.minAmount)} and maximum payment limit ${Helpers.numberFormatWithAsFixed2('', depositController.maxAmount)}");
                                        } else if (depositController
                                                .isFollowedTransactionLimit ==
                                            false) {
                                          Helpers.showSnackBar(
                                              msg:
                                                  "minimum payment ${Helpers.numberFormatWithAsFixed2('', depositController.minAmount)} and maximum payment limit ${Helpers.numberFormatWithAsFixed2('', depositController.maxAmount)}");
                                        } else {
                                          var body = {
                                            "amount": depositController.amountCtrl.text,
                                            "methodId": depositController.gatewayId.toString(),
                                            "currency":
                                                int.parse(depositController.selectedCurrencyId),
                                          };
                                          await depositController.paymentRequest(
                                            context: context,
                                            fields: body,
                                          );
                                        }
                                      }
                                    },
                              text: storedLanguage['Confirm & Next'] ??
                                  "Confirm & Next",
                            ),
                          ),
                          VSpace(node.hasFocus ? 150.h : 50.h),
                        ],
                      ),
                    ),
                  VSpace(32.h),
                ],
              ));
        });
      },
    );
  }
}
