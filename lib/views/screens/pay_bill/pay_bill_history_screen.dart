import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:paysecure/controllers/bindings/controller_index.dart';
import 'package:paysecure/views/widgets/text_theme_extension.dart';
import '../../../../config/app_colors.dart';
import '../../../config/dimensions.dart';
import '../../../themes/themes.dart';
import '../../../utils/app_constants.dart';
import '../../../utils/services/helpers.dart';
import '../../../utils/services/localstorage/hive.dart';
import '../../../utils/services/localstorage/keys.dart';
import '../../widgets/appDialog.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_custom_dropdown.dart';
import '../../widgets/custom_appbar.dart';
import '../../widgets/custom_textfield.dart';
import '../../widgets/search_dialog.dart';
import '../../widgets/spacing.dart';
import '../home/home_screen.dart';
import 'pay_bill_preview_screen.dart';

class PayBillHistoryScreen extends StatelessWidget {
  const PayBillHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    TextTheme t = Theme.of(context).textTheme;
    var storedLanguage = HiveHelp.read(Keys.languageData) ?? {};
    return GetBuilder<PayBillHistoryController>(
      builder: (payBillHistoryController) {
        return GetBuilder<PayBillController>(
          builder: (payBill) {
            return Scaffold(
              appBar: buildAppbar(
                storedLanguage,
                context,
                payBillHistoryController,
              ),
              body: RefreshIndicator(
                color: AppColors.mainColor,
                onRefresh: () async {
                  payBillHistoryController.selectedStatus = "All";
                  payBillHistoryController.categoryEditingCtrlr.clear();
                  payBillHistoryController.typeEditingCtrlr.clear();
                  payBillHistoryController.dateTimeEditingCtrlr.clear();
                  payBillHistoryController.resetDataAfterSearching(
                    isFromOnRefreshIndicator: true,
                  );
                  await payBillHistoryController.getPayBillList(
                    page: 1,
                    type: "",
                    status: "",
                    created_at: "",
                    category_name: "",
                  );
                },
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  controller: payBillHistoryController.scrollController,
                  child: Padding(
                    padding: Dimensions.kDefaultPadding,
                    child: Column(
                      children: [
                        VSpace(20.h),
                        payBillHistoryController.isLoading
                            ? buildTransactionLoader(
                              itemCount: 20,
                              isReverseColor: true,
                            )
                            : payBillHistoryController.payBillList.isEmpty
                            ? Helpers.notFound()
                            : ListView.builder(
                              physics: const NeverScrollableScrollPhysics(),
                              shrinkWrap: true,
                              itemCount:
                                  payBillHistoryController.payBillList.length,
                              itemBuilder: (context, i) {
                                var data =
                                    payBillHistoryController.payBillList[i];
                                return InkWell(
                                  borderRadius: Dimensions.kBorderRadius,
                                  onTap: () {
                                    appDialog(
                                      context: context,
                                      title: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.end,
                                        children: [
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
                                                color:
                                                    Get.isDarkMode
                                                        ? AppColors.whiteColor
                                                        : AppColors.blackColor,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      content: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Container(
                                            width: 48.h,
                                            height: 48.h,
                                            padding: EdgeInsets.all(12.h),
                                            decoration: BoxDecoration(
                                              color: checkBgColor(
                                                data.status.toString(),
                                              ),
                                              shape: BoxShape.circle,
                                            ),
                                            child: Image.asset(
                                              checkStatus(
                                                data.status.toString(),
                                              ),
                                              color: checkIconColor(
                                                data.status.toString(),
                                              ),
                                            ),
                                          ),
                                          VSpace(12.h),
                                          InkWell(
                                            onTap: () {
                                              ScaffoldMessenger.of(
                                                context,
                                              ).removeCurrentSnackBar();
                                              Clipboard.setData(
                                                new ClipboardData(
                                                  text: "${data.utr ?? ''}",
                                                ),
                                              );

                                              Helpers.showSnackBar(
                                                msg: "Copied Successfully",
                                                title: 'Success',
                                                bgColor: AppColors.greenColor,
                                              );
                                            },
                                            child: Container(
                                              color: Colors.transparent,
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Center(
                                                    child: Text(
                                                      storedLanguage['Transaction ID'] ??
                                                          "Transaction ID",
                                                      style: t.bodyMedium?.copyWith(
                                                        color:
                                                            Get.isDarkMode
                                                                ? AppColors
                                                                    .whiteColor
                                                                : AppColors
                                                                    .blackColor
                                                                    .withValues(
                                                                      alpha: .5,
                                                                    ),
                                                      ),
                                                    ),
                                                  ),
                                                  Center(
                                                    child: Text(
                                                      data.utr ?? '',
                                                      textAlign:
                                                          TextAlign.center,
                                                      style: t.bodySmall,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                          if (data.status != null) ...[
                                            VSpace(12.h),
                                            Text(
                                              storedLanguage['Status'] ??
                                                  "Status",
                                              style: t.bodyMedium?.copyWith(
                                                color:
                                                    Get.isDarkMode
                                                        ? AppColors.whiteColor
                                                        : AppColors.blackColor
                                                            .withValues(
                                                              alpha: .5,
                                                            ),
                                              ),
                                            ),
                                            Text(
                                              checkStatusText(
                                                data.status.toString(),
                                              ),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              style: t.bodySmall,
                                            ),
                                          ],
                                          VSpace(12.h),
                                          Text(
                                            storedLanguage['Amount'] ??
                                                "Amount",
                                            style: t.bodyMedium?.copyWith(
                                              color:
                                                  Get.isDarkMode
                                                      ? AppColors.whiteColor
                                                      : AppColors.blackColor
                                                          .withValues(
                                                            alpha: .5,
                                                          ),
                                            ),
                                          ),
                                          Text(
                                            data.amount.toString() +
                                                " ${data.currency}",
                                            style: t.bodySmall,
                                          ),
                                          VSpace(12.h),
                                          Text(
                                            storedLanguage['Charge'] ??
                                                "Charge",
                                            style: t.bodyMedium?.copyWith(
                                              color:
                                                  Get.isDarkMode
                                                      ? AppColors.whiteColor
                                                      : AppColors.blackColor
                                                          .withValues(
                                                            alpha: .5,
                                                          ),
                                            ),
                                          ),
                                          Text(
                                            data.charge.toString() +
                                                " ${data.currency}",
                                            style: t.bodySmall,
                                          ),
                                          VSpace(12.h),
                                        ],
                                      ),
                                    );
                                  },
                                  child: Ink(
                                    width: double.maxFinite,
                                    padding: EdgeInsets.symmetric(
                                      vertical: 10.h,
                                    ),
                                    child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Container(
                                          width: 45.h,
                                          height: 45.h,
                                          padding: EdgeInsets.all(12.h),
                                          decoration: BoxDecoration(
                                            color: checkBgColor(
                                              data.status.toString(),
                                            ),
                                            shape: BoxShape.circle,
                                          ),
                                          child: Image.asset(
                                            checkStatus(data.status.toString()),
                                            color: checkIconColor(
                                              data.status.toString(),
                                            ),
                                          ),
                                        ),
                                        HSpace(12.w),
                                        Expanded(
                                          child: Column(
                                            children: [
                                              Row(
                                                children: [
                                                  Expanded(
                                                    flex: 10,
                                                    child: Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .spaceBetween,
                                                      children: [
                                                        Text(
                                                          data.type.toString(),
                                                          maxLines: 1,
                                                          overflow:
                                                              TextOverflow.fade,
                                                          style: t.bodyMedium,
                                                        ),
                                                        VSpace(3.h),
                                                        Text(
                                                          DateFormat(
                                                            'dd MMM yyyy',
                                                          ).format(
                                                            DateTime.parse(
                                                              data.createdTime
                                                                  .toString(),
                                                            ),
                                                          ),
                                                          maxLines: 1,
                                                          overflow:
                                                              TextOverflow
                                                                  .ellipsis,
                                                          style: t.bodySmall
                                                              ?.copyWith(
                                                                color:
                                                                    AppThemes.getBlack50Color(),
                                                              ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                  HSpace(3.w),
                                                  Flexible(
                                                    flex: 7,
                                                    child: Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        if (data.status
                                                                .toString() ==
                                                            "0")
                                                          Align(
                                                            alignment:
                                                                Alignment
                                                                    .centerRight,
                                                            child: InkWell(
                                                              borderRadius:
                                                                  BorderRadius.circular(
                                                                    4.r,
                                                                  ),
                                                              onTap:
                                                                  payBill.isGettingPrev
                                                                      ? null
                                                                      : () async {
                                                                        Get.to(
                                                                          () => PayBillPreviewScreen(
                                                                            utr:
                                                                                data.utr.toString(),
                                                                          ),
                                                                        );
                                                                        await payBill.getPayBillPreview(
                                                                          utr:
                                                                              data.utr.toString(),
                                                                        );
                                                                      },
                                                              child: Ink(
                                                                padding:
                                                                    EdgeInsets.symmetric(
                                                                      vertical:
                                                                          5.h,
                                                                      horizontal:
                                                                          9.w,
                                                                    ),
                                                                decoration: BoxDecoration(
                                                                  color:
                                                                      Get.isDarkMode
                                                                          ? AppColors
                                                                              .darkCardColor
                                                                          : AppColors
                                                                              .sliderInActiveColor,
                                                                  borderRadius:
                                                                      BorderRadius.circular(
                                                                        4.r,
                                                                      ),
                                                                ),
                                                                child: Row(
                                                                  mainAxisSize:
                                                                      MainAxisSize
                                                                          .min,
                                                                  children: [
                                                                    Text(
                                                                      "Confirm",
                                                                      style: t.bodySmall?.copyWith(
                                                                        fontSize:
                                                                            14.sp,
                                                                        color:
                                                                            Get.isDarkMode
                                                                                ? AppColors.whiteColor
                                                                                : AppColors.blackColor,
                                                                      ),
                                                                    ),
                                                                    HSpace(5.w),
                                                                    Padding(
                                                                      padding:
                                                                          EdgeInsets.only(
                                                                            top:
                                                                                3.h,
                                                                          ),
                                                                      child: Image.asset(
                                                                        "$rootImageDir/confirm_arrow.webp",
                                                                        color:
                                                                            AppThemes.getIconBlackColor(),
                                                                        height:
                                                                            12.h,
                                                                        width:
                                                                            12.h,
                                                                      ),
                                                                    ),
                                                                  ],
                                                                ),
                                                              ),
                                                            ),
                                                          ),
                                                        Align(
                                                          alignment:
                                                              Alignment
                                                                  .centerRight,
                                                          child: Text(
                                                            "${data.amount.toString()} ${data.currency.toString()}",
                                                            maxLines: 1,
                                                            overflow:
                                                                TextOverflow
                                                                    .ellipsis,
                                                            style: t.bodyMedium,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              Container(
                                                margin: EdgeInsets.only(
                                                  top: 15.h,
                                                ),
                                                decoration: BoxDecoration(
                                                  border: Border(
                                                    bottom: BorderSide(
                                                      color:
                                                          Get.isDarkMode
                                                              ? AppColors
                                                                  .black70
                                                              : AppColors
                                                                  .black20,
                                                      width: .2,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                        if (payBillHistoryController.isLoadMore == true)
                          Padding(
                            padding: EdgeInsets.only(top: 10.h, bottom: 20.h),
                            child: Helpers.appLoader(),
                          ),
                        VSpace(20.h),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  CustomAppBar buildAppbar(
    storedLanguage,
    BuildContext context,
    PayBillHistoryController payBillHistoryController,
  ) {
    return CustomAppBar(
      title: storedLanguage['Pay Bill History'] ?? "Pay Bill History",
      actions: [
        InkResponse(
          onTap: () {
            searchDialog(
              context: context,
              children: [
                CustomTextField(
                  hintext: "Category Name",
                  controller: payBillHistoryController.categoryEditingCtrlr,
                  contentPadding: EdgeInsets.only(left: 20.w),
                ),
                VSpace(24.h),
                CustomTextField(
                  hintext: "Type",
                  controller: payBillHistoryController.typeEditingCtrlr,
                  contentPadding: EdgeInsets.only(left: 20.w),
                ),
                VSpace(24.h),
                Stack(
                  alignment: Alignment.centerRight,
                  children: [
                    InkWell(
                      onTap: () async {
                        /// SHOW DATE PICKER
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
                          lastDate: DateTime(DateTime.now().year.toInt() + 1),
                        ).then((value) {
                          if (value != null) {
                            payBillHistoryController
                                .dateTimeEditingCtrlr
                                .text = DateFormat('yyyy-MM-dd').format(value);
                          }
                        });
                      },
                      child: IgnorePointer(
                        ignoring: true,
                        child: CustomTextField(
                          hintext: "Date",
                          controller:
                              payBillHistoryController.dateTimeEditingCtrlr,
                          contentPadding: EdgeInsets.only(left: 20.w),
                        ),
                      ),
                    ),
                    InkResponse(
                      onTap: () {
                        payBillHistoryController.dateTimeEditingCtrlr.clear();
                      },
                      child: Container(
                        padding: EdgeInsets.all(4.h),
                        margin: EdgeInsets.only(right: 10.w),
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
                VSpace(24.h),
                GetBuilder<PayBillHistoryController>(
                  builder: (_) {
                    return Container(
                      height: 50.h,
                      decoration: BoxDecoration(
                        borderRadius: Dimensions.kBorderRadius,
                        border: Border.all(
                          color: AppThemes.getSliderInactiveColor(),
                          width: 1,
                        ),
                      ),
                      child: AppCustomDropDown(
                        paddingLeft: 20.w,
                        height: 50.h,
                        width: double.infinity,
                        items:
                            payBillHistoryController.statusList
                                .map((e) => e)
                                .toList(),
                        selectedValue: payBillHistoryController.selectedStatus,
                        onChanged: (v) {
                          payBillHistoryController.selectedStatus = v;
                          payBillHistoryController.update();
                        },
                        hint: storedLanguage['Status'] ?? "Status",
                        hintStyle: context.t.bodySmall?.copyWith(
                          color: AppColors.textFieldHintColor,
                          fontWeight: FontWeight.w400,
                          fontSize: 18.sp,
                        ),
                        selectedStyle: context.t.displayMedium,
                        bgColor: AppThemes.getFillColor(),
                      ),
                    );
                  },
                ),
                VSpace(28.h),
                AppButton(
                  text: "Search Now",
                  onTap: () async {
                    payBillHistoryController.resetDataAfterSearching(
                      isFromOnRefreshIndicator: true,
                    );
                    Get.back();
                    await payBillHistoryController.getPayBillList(
                      page: 1,
                      type: payBillHistoryController.typeEditingCtrlr.text,
                      status: checkStatusforPost(
                        payBillHistoryController.selectedStatus,
                      ),
                      created_at:
                          payBillHistoryController.dateTimeEditingCtrlr.text,
                      category_name:
                          payBillHistoryController.categoryEditingCtrlr.text,
                    );
                  },
                ),
              ],
            );
          },
          child: Container(
            width: 34.h,
            height: 34.h,
            padding: EdgeInsets.all(10.5.h),
            decoration: BoxDecoration(
              color: Get.isDarkMode ? AppColors.darkBgColor : AppColors.black5,
              borderRadius: BorderRadius.circular(6.r),
              border: Border.all(color: AppColors.mainColor, width: .2),
            ),
            child: Image.asset(
              "$rootImageDir/filter_3.webp",
              height: 32.h,
              width: 32.h,
              color:
                  Get.isDarkMode ? AppColors.whiteColor : AppColors.blackColor,
              fit: BoxFit.fitHeight,
            ),
          ),
        ),
        HSpace(20.w),
      ],
    );
  }
}

String checkStatusforPost(String data) {
  switch (data) {
    case "All":
      return "";
    case "Generate":
      return "generate";
    case "Pending":
      return "pending";
    case "Payment Completed":
      return "payment_completed";
    case "Bill Completed":
      return "bill_complete";
    case "Bill Return":
      return "bill_return";
    default:
      return "";
  }
}

String checkStatusText(String data) {
  switch (data) {
    case "0":
      return "Generated";
    case "1":
      return "Pending";
    case "2":
      return "Payment Completed";
    case "3":
      return "Bill Completed";
    case "4":
      return "Bill Return";
    default:
      return "";
  }
}

String checkStatus(String data) {
  switch (data) {
    case "0":
      return "$rootImageDir/generated.webp";
    case "1":
      return "$rootImageDir/pending.webp";
    case "2":
      return "$rootImageDir/payment_completed.webp";
    case "3":
      return "$rootImageDir/bill_completed.webp";
    case "4":
      return "$rootImageDir/bill_return.webp";
    default:
      return "$rootImageDir/unknown.webp";
  }
}

dynamic checkBgColor(String data) {
  switch (data) {
    case "0":
      return AppColors.secondaryColor.withValues(alpha: .1);
    case "1":
      return AppColors.pendingColor.withValues(alpha: .1);
    case "2":
      return AppColors.greenColor.withValues(alpha: .1);
    case "3":
      return AppColors.greenColor.withValues(alpha: .1);
    case "4":
      return AppColors.redColor.withValues(alpha: .1);
    default:
      return AppColors.mainColor.withValues(alpha: .1);
  }
}

dynamic checkIconColor(String data) {
  switch (data) {
    case "0":
      return AppColors.secondaryColor;
    case "1":
      return AppColors.pendingColor;
    case "2":
      return AppColors.greenColor;
    case "3":
      return AppColors.greenColor;
    case "4":
      return AppColors.redColor;
    default:
      return AppColors.mainColor;
  }
}
