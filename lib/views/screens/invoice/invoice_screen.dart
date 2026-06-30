import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:paysecure/config/dimensions.dart';
import 'package:paysecure/controllers/invoice_controller.dart';
import 'package:paysecure/utils/app_constants.dart';
import 'package:paysecure/views/widgets/app_button.dart';
import 'package:paysecure/views/widgets/custom_appbar.dart';
import 'package:paysecure/views/widgets/text_theme_extension.dart';
import '../../../config/app_colors.dart';
import '../../../config/styles.dart';
import '../../../themes/themes.dart';
import '../../../utils/services/localstorage/hive.dart';
import '../../../utils/services/localstorage/keys.dart';
import '../../widgets/appDialog.dart';
import '../../widgets/app_custom_dropdown.dart';
import '../../widgets/custom_textfield.dart';
import '../../widgets/spacing.dart';

class InvoiceScreen extends StatelessWidget {
  const InvoiceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    var storedLanguage = HiveHelp.read(Keys.languageData) ?? {};
    return GetBuilder<InvoiceController>(
      builder: (invoiceController) {
        return Scaffold(
          appBar: CustomAppBar(title: storedLanguage['Invoice'] ?? "Invoice"),
          body: RefreshIndicator(
            color: AppColors.mainColor,
            onRefresh: () async {
              await invoiceController.getInvoiceCreate();
            },
            child: SingleChildScrollView(
              child: Padding(
                padding: Dimensions.kDefaultPadding,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    VSpace(40.h),
                    CustomTextField(
                      isBorderColor: true,
                      contentPadding: EdgeInsets.only(left: 20.w),
                      hintext:
                          storedLanguage['Customer Email'] ?? 'Customer Email',
                      controller: invoiceController.customerEmailCtrlr,
                      borderColor:
                          invoiceController.isCustomerEmailError
                              ? AppColors.redColor
                              : AppThemes.getSliderInactiveColor(),
                      borderWidth: 1,
                      onChanged: (v) {
                        if (v.isEmpty) {
                          invoiceController.isCustomerEmailError = true;
                          invoiceController.update();
                        } else {
                          invoiceController.isCustomerEmailError = false;
                          invoiceController.update();
                        }
                      },
                    ),
                    VSpace(32.h),
                    CustomTextField(
                      isBorderColor: true,
                      contentPadding: EdgeInsets.only(left: 20.w),
                      hintext:
                          storedLanguage['Invoice Number'] ?? 'Invoice Number',
                      keyboardType: TextInputType.number,
                      inputFormatters: <TextInputFormatter>[
                        FilteringTextInputFormatter.digitsOnly,
                      ],
                      controller: invoiceController.invoiceCtrlr,
                      borderColor:
                          invoiceController.isInvoiceNumError
                              ? AppColors.redColor
                              : AppThemes.getSliderInactiveColor(),
                      borderWidth: 1,
                      onChanged: (v) {
                        if (v.isEmpty) {
                          invoiceController.isInvoiceNumError = true;
                          invoiceController.update();
                        } else {
                          invoiceController.isInvoiceNumError = false;
                          invoiceController.update();
                        }
                      },
                    ),
                    VSpace(32.h),
                    Container(
                      height: 50.h,
                      decoration: BoxDecoration(
                        borderRadius: Dimensions.kBorderRadius,
                        border: Border.all(
                          color:
                              invoiceController.isCurrencyError
                                  ? AppColors.redColor
                                  : AppThemes.getSliderInactiveColor(),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: AppCustomDropDown(
                              paddingLeft: 20.w,
                              height: 50.h,
                              width: double.infinity,
                              items:
                                  invoiceController.customCurrencyList
                                      .map((e) => e.currency_code)
                                      .toList(),
                              selectedValue: invoiceController.selectedCurrency,
                              onChanged: (v) {
                                invoiceController.selectedCurrency = v;
                                invoiceController.selectedCurrencyId =
                                    invoiceController.customCurrencyList
                                        .firstWhere((e) => e.currency_code == v)
                                        .id
                                        .toString();
                                invoiceController.isCurrencyError = false;
                                invoiceController.update();
                              },
                              hint:
                                  storedLanguage['Select currency'] ??
                                  "Select currency",
                              hintStyle: context.t.bodySmall?.copyWith(
                                color: AppColors.textFieldHintColor,
                                fontWeight: FontWeight.w400,
                                fontSize: 18.sp,
                              ),
                              selectedStyle: context.t.displayMedium,
                              bgColor: AppThemes.getFillColor(),
                            ),
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
                      isBorderColor: true,
                      isPrefixIcon: false,
                      controller: invoiceController.noteCtrlr,
                      hintext:
                          storedLanguage['Payment request note (optional)'] ??
                          "Payment request note (optional)",
                    ),
                    VSpace(32.h),
                    Text("Payment Frequency", style: context.t.displayMedium),
                    VSpace(8.h),
                    Row(
                      children: [
                        InkWell(
                          onTap: () {
                            invoiceController.groupVal = 1;
                            invoiceController.update();
                          },
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              SizedBox(
                                width: 40.w,
                                child: Radio<int>(
                                  value: 1,
                                  groupValue: invoiceController.groupVal,
                                  fillColor: WidgetStatePropertyAll(
                                    AppColors.mainColor,
                                  ),
                                  onChanged: (int? newValue) {
                                    invoiceController.groupVal = newValue!;
                                    invoiceController.update();
                                  },
                                ),
                              ),
                              Text(
                                "One Time",
                                style: context.t.displayMedium?.copyWith(
                                  fontSize: 16.sp,
                                ),
                              ),
                            ],
                          ),
                        ),
                        HSpace(32.w),
                        InkWell(
                          onTap: () {
                            invoiceController.groupVal = 2;
                            invoiceController.update();
                          },
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              SizedBox(
                                width: 40.w,
                                child: Radio<int>(
                                  value: 2,
                                  groupValue: invoiceController.groupVal,
                                  fillColor: WidgetStatePropertyAll(
                                    AppColors.mainColor,
                                  ),
                                  onChanged: (int? newValue) {
                                    invoiceController.groupVal = newValue!;
                                    invoiceController.update();
                                  },
                                ),
                              ),
                              Text(
                                "Weekly",
                                style: context.t.displayMedium?.copyWith(
                                  fontSize: 16.sp,
                                ),
                              ),
                            ],
                          ),
                        ),
                        HSpace(32.w),
                        InkWell(
                          onTap: () {
                            invoiceController.groupVal = 3;
                            invoiceController.update();
                          },
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              SizedBox(
                                width: 40.w,
                                child: Radio<int>(
                                  value: 3,
                                  groupValue: invoiceController.groupVal,
                                  visualDensity: VisualDensity.compact,
                                  fillColor: WidgetStatePropertyAll(
                                    AppColors.mainColor,
                                  ),
                                  onChanged: (int? newValue) {
                                    invoiceController.groupVal = newValue!;
                                    invoiceController.update();
                                  },
                                ),
                              ),
                              Text(
                                "Monthly",
                                style: context.t.displayMedium?.copyWith(
                                  fontSize: 16.sp,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    VSpace(24.h),
                    if (invoiceController.groupVal == 1)
                      Stack(
                        alignment: Alignment.centerRight,
                        children: [
                          GetBuilder<InvoiceController>(
                            builder: (_) {
                              return InkWell(
                                onTap: () async {
                                  await showDatePicker(
                                    context: context,
                                    builder: (context, child) {
                                      return Theme(
                                        data: Theme.of(context).copyWith(
                                          colorScheme: ColorScheme.dark(
                                            surface:
                                                Get.isDarkMode
                                                    ? AppColors.darkCardColor
                                                    : AppColors.paragraphColor,
                                            onPrimary: AppColors.whiteColor,
                                          ),
                                          textButtonTheme: TextButtonThemeData(
                                            style: TextButton.styleFrom(
                                              foregroundColor:
                                                  AppColors
                                                      .mainColor, // button text color
                                            ),
                                          ),
                                        ),
                                        child: child!,
                                      );
                                    },
                                    initialDate: DateTime.now(),
                                    firstDate: DateTime(2000),
                                    lastDate: DateTime(
                                      DateTime.now().year.toInt() + 1,
                                    ),
                                  ).then((value) {
                                    if (value != null) {
                                      invoiceController.dueDateCtrlr.text =
                                          DateFormat('dd/MM/yyy').format(value);
                                      invoiceController.isDueDateError = false;
                                      invoiceController.update();
                                    }
                                  });
                                },
                                child: IgnorePointer(
                                  ignoring: true,
                                  child: CustomTextField(
                                    hintext: "Due Date",
                                    controller: invoiceController.dueDateCtrlr,
                                    contentPadding: EdgeInsets.only(left: 20.w),
                                    isBorderColor: true,
                                    borderColor:
                                        invoiceController.isDueDateError
                                            ? AppColors.redColor
                                            : AppThemes.getSliderInactiveColor(),
                                    borderWidth: 1,
                                  ),
                                ),
                              );
                            },
                          ),
                          Positioned(
                            right: 18.w,
                            child: Image.asset(
                              "$rootImageDir/calender.webp",
                              height: 16.h,
                              width: 16.h,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ],
                      ),
                    if (invoiceController.groupVal == 2 ||
                        invoiceController.groupVal == 3)
                      CustomTextField(
                        isBorderColor: true,
                        isSuffixIcon: false,
                        contentPadding: EdgeInsets.only(left: 20.w),
                        hintext:
                            storedLanguage['Number of payments'] ??
                            'Number of payments',
                        keyboardType: TextInputType.number,
                        inputFormatters: <TextInputFormatter>[
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                        controller: invoiceController.numOfPaymentCtrlr,
                        borderColor:
                            invoiceController.isNumOfPayError
                                ? AppColors.redColor
                                : AppThemes.getSliderInactiveColor(),
                        borderWidth: 1,
                        onChanged: (v) {
                          if (v.isEmpty) {
                            invoiceController.isNumOfPayError = true;
                            invoiceController.update();
                          } else {
                            invoiceController.isNumOfPayError = false;
                            invoiceController.update();
                          }
                        },
                      ),
                    if (invoiceController.groupVal == 2 ||
                        invoiceController.groupVal == 3)
                      VSpace(24.h),
                    if (invoiceController.groupVal == 2 ||
                        invoiceController.groupVal == 3)
                      Stack(
                        alignment: Alignment.centerRight,
                        children: [
                          InkWell(
                            onTap: () async {
                              await showDatePicker(
                                context: context,
                                builder: (context, child) {
                                  return Theme(
                                    data: Theme.of(context).copyWith(
                                      colorScheme: ColorScheme.dark(
                                        surface:
                                            Get.isDarkMode
                                                ? AppColors.darkCardColor
                                                : AppColors.paragraphColor,
                                        onPrimary: AppColors.whiteColor,
                                      ),
                                      textButtonTheme: TextButtonThemeData(
                                        style: TextButton.styleFrom(
                                          foregroundColor:
                                              AppColors
                                                  .mainColor, // button text color
                                        ),
                                      ),
                                    ),
                                    child: child!,
                                  );
                                },
                                initialDate: DateTime.now(),
                                firstDate: DateTime(2000),
                                lastDate: DateTime(
                                  DateTime.now().year.toInt() + 1,
                                ),
                              ).then((value) {
                                if (value != null) {
                                  invoiceController.firstPayDateCtrlr.text =
                                      DateFormat('dd/MM/yyy').format(value);
                                  invoiceController.isFirstPayDateError = false;
                                  invoiceController.update();
                                }
                              });
                            },
                            child: IgnorePointer(
                              ignoring: true,
                              child: CustomTextField(
                                hintext: "First Payment Date",
                                controller: invoiceController.firstPayDateCtrlr,
                                contentPadding: EdgeInsets.only(left: 20.w),
                                isBorderColor: true,
                                borderColor:
                                    invoiceController.isFirstPayDateError
                                        ? AppColors.redColor
                                        : AppThemes.getSliderInactiveColor(),
                                borderWidth: 1,
                              ),
                            ),
                          ),
                          Positioned(
                            right: 18.w,
                            child: Image.asset(
                              "$rootImageDir/calender.webp",
                              height: 16.h,
                              width: 16.h,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ],
                      ),
                    VSpace(20.h),
                    GetBuilder<InvoiceController>(
                      builder: (invoiceController) {
                        return AppButton(
                          buttonWidth: 124.w,
                          buttonHeight: 40.h,
                          onTap: () {
                            invoiceController.titleCtrlr.clear();
                            invoiceController.quantityCtrlr.clear();
                            invoiceController.priceCtrlr.clear();
                            invoiceController.descriptionCtrlr.clear();
                            invoiceController.update();
                            serviceDialog(
                              context,
                              invoiceController,
                              storedLanguage,
                            );
                          },
                          text:
                              storedLanguage['Add Services'] ?? "Add Services",
                          style: context.t.displayMedium?.copyWith(
                            color: AppColors.whiteColor,
                          ),
                        );
                      },
                    ),
                    if (invoiceController.serviceList.isEmpty &&
                        invoiceController.isEmptyServiceAndTappedOnSaveButton ==
                            true)
                      VSpace(10.h),
                    if (invoiceController.serviceList.isEmpty &&
                        invoiceController.isEmptyServiceAndTappedOnSaveButton ==
                            true)
                      Text(
                        "The service is required.",
                        style: context.t.bodySmall?.copyWith(
                          color: AppColors.redColor,
                        ),
                      ),
                    if (invoiceController.serviceList.isNotEmpty) VSpace(32.h),
                    if (invoiceController.serviceList.isNotEmpty)
                      ListView.builder(
                        physics: const NeverScrollableScrollPhysics(),
                        shrinkWrap: true,
                        itemCount: invoiceController.serviceList.length,
                        itemBuilder: (ctx, i) {
                          var data = invoiceController.serviceList[i];
                          return Container(
                            margin: EdgeInsets.only(bottom: 32.h),
                            width: double.maxFinite,
                            height: 260.h,
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
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      "Title",
                                      style: context.t.displayMedium?.copyWith(
                                        color: AppThemes.getParagraphColor(),
                                      ),
                                    ),
                                    Expanded(
                                      child: Align(
                                        alignment: Alignment.centerRight,
                                        child: Text(
                                          "${data.title}",
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
                                      "Quantity",
                                      style: context.t.displayMedium?.copyWith(
                                        color: AppThemes.getParagraphColor(),
                                      ),
                                    ),
                                    Expanded(
                                      child: Align(
                                        alignment: Alignment.centerRight,
                                        child: Text(
                                          "${data.quantity}",
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
                                      "Price",
                                      style: context.t.displayMedium?.copyWith(
                                        color: AppThemes.getParagraphColor(),
                                      ),
                                    ),
                                    Expanded(
                                      child: Align(
                                        alignment: Alignment.centerRight,
                                        child: Text(
                                          "${data.price}",
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
                                      "Description",
                                      style: context.t.displayMedium?.copyWith(
                                        color: AppThemes.getParagraphColor(),
                                      ),
                                    ),
                                    HSpace(20.w),
                                    Expanded(
                                      child: Align(
                                        alignment: Alignment.centerRight,
                                        child: Text(
                                          "${data.description}",
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
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    InkWell(
                                      onTap: () {
                                        invoiceController.onServiceDeleteTapped(
                                          i,
                                        );
                                      },
                                      child: Container(
                                        padding: EdgeInsets.symmetric(
                                          vertical: 3.h,
                                        ),
                                        color: Colors.transparent,
                                        child: Text(
                                          "Delete",
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: context.t.bodyMedium?.copyWith(
                                            color: AppColors.redColor,
                                          ),
                                        ),
                                      ),
                                    ),
                                    InkWell(
                                      onTap: () {
                                        invoiceController.titleCtrlr.text =
                                            data.title;
                                        invoiceController.quantityCtrlr.text =
                                            data.quantity;
                                        invoiceController.priceCtrlr.text =
                                            data.price;
                                        invoiceController
                                            .descriptionCtrlr
                                            .text = data.description ?? "";

                                        serviceDialog(
                                          context,
                                          invoiceController,
                                          storedLanguage,
                                          isFromEdit: true,
                                          i: i,
                                        );
                                      },
                                      child: Container(
                                        padding: EdgeInsets.symmetric(
                                          vertical: 3.h,
                                        ),
                                        color: Colors.transparent,
                                        child: Text(
                                          "Edit",
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: context.t.bodyMedium?.copyWith(
                                            color: Colors.blue,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    if (invoiceController.serviceList.isNotEmpty)
                      Container(
                        width: double.maxFinite,
                        height: 250.h,
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
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Text(
                                  "Subtotal",
                                  style: context.t.displayMedium?.copyWith(
                                    color: AppThemes.getParagraphColor(),
                                  ),
                                ),
                                Expanded(
                                  child: Align(
                                    alignment: Alignment.centerRight,
                                    child: Text(
                                      "${invoiceController.subTotal.toString()}",
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
                                  "Tax",
                                  style: context.t.displayMedium?.copyWith(
                                    color: AppThemes.getParagraphColor(),
                                  ),
                                ),
                                Spacer(),
                                Container(
                                  width: 100.w,
                                  height: 40.h,
                                  child: CustomTextField(
                                    hintext: "12",
                                    controller: invoiceController.taxCtrlr,
                                    contentPadding: EdgeInsets.only(left: 20.w),
                                    onChanged: (v) {
                                      invoiceController.getTaxRate(v);
                                    },
                                  ),
                                ),
                                HSpace(5.w),
                                Text("%", style: context.t.bodyMedium),
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
                                  "Vat",
                                  style: context.t.displayMedium?.copyWith(
                                    color: AppThemes.getParagraphColor(),
                                  ),
                                ),
                                Spacer(),
                                Container(
                                  width: 100.w,
                                  height: 40.h,
                                  child: CustomTextField(
                                    hintext: "5",
                                    controller: invoiceController.vatCtrlr,
                                    contentPadding: EdgeInsets.only(left: 20.w),
                                    onChanged: (v) {
                                      invoiceController.getVatRate(v);
                                    },
                                  ),
                                ),
                                HSpace(5.w),
                                Text("%", style: context.t.bodyMedium),
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
                                  "Grandtotal",
                                  style: context.t.displayMedium?.copyWith(
                                    color: AppThemes.getParagraphColor(),
                                  ),
                                ),
                                Expanded(
                                  child: Align(
                                    alignment: Alignment.centerRight,
                                    child: Text(
                                      "${invoiceController.grandTotal} ${invoiceController.selectedCurrency == null ? "" : invoiceController.selectedCurrency.toString().split(" ").first}",
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
                    VSpace(40.h),
                    AppButton(
                      isLoading: invoiceController.isSubmit ? true : false,
                      onTap:
                          invoiceController.isSubmit
                              ? null
                              : () async {
                                await invoiceController.onInvoiceSubmit();
                              },
                      text: storedLanguage['Save and Send'] ?? "Save and Send",
                    ),
                    VSpace(60.h),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  serviceDialog(
    BuildContext context,
    InvoiceController invoiceController,
    storedLanguage, {
    bool? isFromEdit = false,
    int? i = -1,
  }) {
    appDialog(
      context: context,
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            storedLanguage['Add Service'] ?? "Add Service",
            style: Styles.bodyMedium.copyWith(
              color:
                  Get.isDarkMode ? AppColors.whiteColor : AppColors.blackColor,
            ),
          ),
          InkResponse(
            onTap: () {
              Get.back();
            },
            child: Container(
              padding: EdgeInsets.all(7.h),
              decoration: BoxDecoration(
                color: AppThemes.getFillColor(),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.close,
                size: 14.h,
                color: AppThemes.getIconBlackColor(),
              ),
            ),
          ),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CustomTextField(
            hintext: "Title",
            controller: invoiceController.titleCtrlr,
            contentPadding: EdgeInsets.only(left: 20.w),
            onChanged: (v) {
              invoiceController.titleVal = v.toString();
            },
          ),
          VSpace(20.h),
          CustomTextField(
            hintext: "Price",
            controller: invoiceController.priceCtrlr,
            contentPadding: EdgeInsets.only(left: 20.w),
            keyboardType: TextInputType.number,
            inputFormatters: <TextInputFormatter>[
              FilteringTextInputFormatter.digitsOnly,
            ],
            onChanged: (v) {
              invoiceController.priceVal = v.toString();
            },
          ),
          VSpace(20.h),
          CustomTextField(
            hintext: "Quantity",
            controller: invoiceController.quantityCtrlr,
            contentPadding: EdgeInsets.only(left: 20.w),
            keyboardType: TextInputType.number,
            inputFormatters: <TextInputFormatter>[
              FilteringTextInputFormatter.digitsOnly,
            ],
            onChanged: (v) {
              invoiceController.quantityVal = v.toString();
            },
          ),
          VSpace(20.h),
          CustomTextField(
            textfieldHieght: null,
            contentPadding: EdgeInsets.only(left: 20.w, bottom: 0.h, top: 10.h),
            alignment: Alignment.topLeft,
            minLines: 3,
            maxLines: 5,
            isBorderColor: true,
            isPrefixIcon: false,
            controller: invoiceController.descriptionCtrlr,
            hintext: storedLanguage['Description'] ?? "Description",
            onChanged: (v) {
              invoiceController.descriptionVal = v.toString();
            },
          ),
          VSpace(28.h),
          AppButton(
            text: "Add",
            onTap: () async {
              await invoiceController.onAddService(i ?? 0, isFromEdit);
            },
          ),
        ],
      ),
    );
  }
}
