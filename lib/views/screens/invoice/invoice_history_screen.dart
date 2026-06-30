import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:paysecure/controllers/bindings/controller_index.dart';
import 'package:paysecure/controllers/redeem_code_controller.dart';
import 'package:paysecure/views/widgets/text_theme_extension.dart';
import '../../../../config/app_colors.dart';
import '../../../config/dimensions.dart';
import '../../../routes/routes_name.dart';
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

class InvoiceHistoryScreen extends StatelessWidget {
  final bool? isFromInvoicePage;
  const InvoiceHistoryScreen({super.key, this.isFromInvoicePage = false});

  @override
  Widget build(BuildContext context) {
    TextTheme t = Theme.of(context).textTheme;
    var storedLanguage = HiveHelp.read(Keys.languageData) ?? {};
    return GetBuilder<InvoiceHistoryController>(
      builder: (invoiceHistoryController) {
        return GetBuilder<RedeemCodeController>(
          builder: (redeemCodeCtrl) {
            return PopScope(
              canPop: false,
              onPopInvokedWithResult: (didPop, result) {
                if (didPop) return;
                if (isFromInvoicePage == true) {
                  Get.toNamed(RoutesName.bottomNavBar);
                  Get.delete<InvoiceHistoryController>();
                } else {
                  Get.back();
                }
              },
              child: Scaffold(
                appBar: buildAppbar(
                  storedLanguage,
                  context,
                  invoiceHistoryController,
                  isFromInvoicePage,
                ),
                body: RefreshIndicator(
                  color: AppColors.mainColor,
                  onRefresh: () async {
                    invoiceHistoryController.refreshSearchData();
                    invoiceHistoryController.resetDataAfterSearching(
                      isFromOnRefreshIndicator: true,
                    );
                    await invoiceHistoryController.getInvoiceList(
                      page: 1,
                      email: "",
                      status: "",
                      created_at: "",
                      currency_id: "",
                    );
                  },
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    controller: invoiceHistoryController.scrollController,
                    child: Padding(
                      padding: Dimensions.kDefaultPadding,
                      child: Column(
                        children: [
                          VSpace(20.h),
                          invoiceHistoryController.isLoading
                              ? buildTransactionLoader(
                                itemCount: 20,
                                isReverseColor: true,
                              )
                              : invoiceHistoryController.invoiceList.isEmpty
                              ? Helpers.notFound()
                              : ListView.builder(
                                physics: const NeverScrollableScrollPhysics(),
                                shrinkWrap: true,
                                itemCount:
                                    invoiceHistoryController.invoiceList.length,
                                itemBuilder: (context, i) {
                                  var data =
                                      invoiceHistoryController.invoiceList[i];
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
                                                  color:
                                                      AppThemes.getFillColor(),
                                                  shape: BoxShape.circle,
                                                ),
                                                child: Icon(
                                                  Icons.close,
                                                  size: 14.h,
                                                  color:
                                                      Get.isDarkMode
                                                          ? AppColors.whiteColor
                                                          : AppColors
                                                              .blackColor,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        content: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Container(
                                              width: 65.h,
                                              height: 65.h,
                                              padding: EdgeInsets.all(15.h),
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
                                                    text:
                                                        "${data.transactionId ?? ''}",
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
                                                                      .blackColor,
                                                        ),
                                                      ),
                                                    ),
                                                    Center(
                                                      child: Text(
                                                        data.transactionId ??
                                                            '',
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
                                                          : AppColors
                                                              .blackColor,
                                                ),
                                              ),
                                              Text(
                                                data.status.toString(),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                                style: t.bodySmall,
                                              ),
                                            ],
                                            VSpace(12.h),
                                            Text(
                                              storedLanguage['Type'] ?? "Type",
                                              style: t.bodyMedium?.copyWith(
                                                color:
                                                    Get.isDarkMode
                                                        ? AppColors.whiteColor
                                                        : AppColors.blackColor,
                                              ),
                                            ),
                                            Text(
                                              data.type.toString(),
                                              style: t.bodySmall,
                                            ),
                                            VSpace(12.h),
                                            Text(
                                              storedLanguage['Sender'] ??
                                                  "Sender",
                                              style: t.bodyMedium?.copyWith(
                                                color:
                                                    Get.isDarkMode
                                                        ? AppColors.whiteColor
                                                        : AppColors.blackColor,
                                              ),
                                            ),
                                            Text(
                                              data.sender.toString(),
                                              style: t.bodySmall,
                                            ),
                                            VSpace(12.h),
                                            Text(
                                              storedLanguage['Receiver'] ??
                                                  "Receiver",
                                              style: t.bodyMedium?.copyWith(
                                                color:
                                                    Get.isDarkMode
                                                        ? AppColors.whiteColor
                                                        : AppColors.blackColor,
                                              ),
                                            ),
                                            Text(
                                              data.receiver.toString(),
                                              style: t.bodySmall,
                                            ),
                                            VSpace(12.h),
                                            Text(
                                              storedLanguage['Receiver Email'] ??
                                                  "Receiver Email",
                                              style: t.bodyMedium?.copyWith(
                                                color:
                                                    Get.isDarkMode
                                                        ? AppColors.whiteColor
                                                        : AppColors.blackColor,
                                              ),
                                            ),
                                            Text(
                                              data.receiverEmail.toString(),
                                              style: t.bodySmall,
                                            ),
                                            VSpace(12.h),
                                            Text(
                                              storedLanguage['Amount'] ??
                                                  "Amount",
                                              style: t.bodyMedium?.copyWith(
                                                color:
                                                    Get.isDarkMode
                                                        ? AppColors.whiteColor
                                                        : AppColors.blackColor,
                                              ),
                                            ),
                                            Text(
                                              data.requestedAmount.toString() +
                                                  " ${data.currencyCode.toString().replaceAll("null", "")}",
                                              style: t.bodySmall,
                                            ),
                                            VSpace(20.h),
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                if (data.status == "Unpaid")
                                                  GetBuilder<
                                                    InvoiceHistoryController
                                                  >(
                                                    builder: (_) {
                                                      return Tooltip(
                                                        message:
                                                            "Send a Reminder",
                                                        child: InkWell(
                                                          onTap: () async {
                                                            await invoiceHistoryController
                                                                .invoiceReminder(
                                                                  fields: {
                                                                    "invoiceId":
                                                                        data.id
                                                                            .toString(),
                                                                  },
                                                                  context:
                                                                      context,
                                                                );
                                                          },
                                                          borderRadius:
                                                              Dimensions
                                                                  .kBorderRadius /
                                                              2,
                                                          child: Container(
                                                            padding:
                                                                EdgeInsets.all(
                                                                  8.h,
                                                                ),
                                                            decoration: BoxDecoration(
                                                              border: Border.all(
                                                                color:
                                                                    AppColors
                                                                        .pendingColor,
                                                              ),
                                                              borderRadius:
                                                                  Dimensions
                                                                      .kBorderRadius /
                                                                  2,
                                                            ),
                                                            child:
                                                                invoiceHistoryController
                                                                        .isRemindering
                                                                    ? SizedBox(
                                                                      height:
                                                                          26.h,
                                                                      width:
                                                                          26.h,
                                                                      child:
                                                                          Helpers.appLoader(),
                                                                    )
                                                                    : Image.asset(
                                                                      "$rootImageDir/reminder.webp",
                                                                      height:
                                                                          26.h,
                                                                      width:
                                                                          26.h,
                                                                      fit:
                                                                          BoxFit
                                                                              .cover,
                                                                      color:
                                                                          AppColors
                                                                              .pendingColor,
                                                                    ),
                                                          ),
                                                        ),
                                                      );
                                                    },
                                                  ),
                                                if (data.status == "Unpaid")
                                                  HSpace(12.w),
                                                Tooltip(
                                                  message: "View Invoice",
                                                  child: InkWell(
                                                    onTap: () {
                                                      invoiceHistoryController
                                                          .getInvoiceView(
                                                            id:
                                                                data.id
                                                                    .toString(),
                                                          );
                                                      Get.toNamed(
                                                        RoutesName
                                                            .invoiceViewScreen,
                                                      );
                                                    },
                                                    borderRadius:
                                                        Dimensions
                                                            .kBorderRadius /
                                                        2,
                                                    child: Container(
                                                      padding: EdgeInsets.all(
                                                        8.h,
                                                      ),
                                                      decoration: BoxDecoration(
                                                        border: Border.all(
                                                          color:
                                                              AppColors
                                                                  .secondaryColor,
                                                        ),
                                                        borderRadius:
                                                            Dimensions
                                                                .kBorderRadius /
                                                            2,
                                                      ),
                                                      child: Image.asset(
                                                        "$rootImageDir/view.webp",
                                                        height: 26.h,
                                                        width: 26.h,
                                                        fit: BoxFit.cover,
                                                        color:
                                                            AppColors
                                                                .secondaryColor,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                // HSpace(12.w),
                                                // Tooltip(
                                                //   message: "Download Invoice",
                                                //   child: InkWell(
                                                //     onTap: () {},
                                                //     borderRadius: Dimensions
                                                //             .kBorderRadius /
                                                //         2,
                                                //     child: Container(
                                                //       padding:
                                                //           EdgeInsets.all(8.h),
                                                //       decoration:
                                                //           BoxDecoration(
                                                //         border: Border.all(
                                                //           color: AppColors
                                                //               .greenColor,
                                                //         ),
                                                //         borderRadius: Dimensions
                                                //                 .kBorderRadius /
                                                //             2,
                                                //       ),
                                                //       child: Image.asset(
                                                //         "$rootImageDir/download.webp",
                                                //         height: 26.h,
                                                //         width: 26.h,
                                                //         fit: BoxFit.cover,
                                                //         color: AppColors
                                                //             .greenColor,
                                                //       ),
                                                //     ),
                                                //   ),
                                                // ),
                                              ],
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
                                            width: 46.h,
                                            height: 46.h,
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
                                                            data.sender
                                                                    .toString() +
                                                                " send to " +
                                                                data.receiver
                                                                    .toString(),
                                                            maxLines: 1,
                                                            overflow:
                                                                TextOverflow
                                                                    .fade,
                                                            style: t.bodyMedium
                                                                ?.copyWith(
                                                                  fontSize:
                                                                      17.sp,
                                                                ),
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
                                                          Align(
                                                            alignment:
                                                                Alignment
                                                                    .centerRight,
                                                            child: Text(
                                                              "${data.requestedAmount.toString()} ${data.currencyCode.toString().replaceAll("null", "")}",
                                                              maxLines: 1,
                                                              overflow:
                                                                  TextOverflow
                                                                      .ellipsis,
                                                              style:
                                                                  t.bodyMedium,
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
                          if (invoiceHistoryController.isLoadMore == true)
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
    InvoiceHistoryController invoiceHistoryController,
    isFromInvoicePage,
  ) {
    return CustomAppBar(
      title: storedLanguage['Invoice History'] ?? "Invoice History",
      onBackPressed: () {
        if (isFromInvoicePage == true) {
          Get.toNamed(RoutesName.bottomNavBar);
          Get.delete<InvoiceHistoryController>();
        } else {
          Get.back();
        }
      },
      actions: [
        InkResponse(
          onTap: () {
            searchDialog(
              context: context,
              children: [
                VSpace(24.h),
                CustomTextField(
                  hintext: "Email",
                  controller: invoiceHistoryController.emailEditingCtrlr,
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
                            invoiceHistoryController
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
                              invoiceHistoryController.dateTimeEditingCtrlr,
                          contentPadding: EdgeInsets.only(left: 20.w),
                        ),
                      ),
                    ),
                    InkResponse(
                      onTap: () {
                        invoiceHistoryController.dateTimeEditingCtrlr.clear();
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
                GetBuilder<InvoiceHistoryController>(
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
                            invoiceHistoryController.customCurrencyList
                                .map((e) => e.currency_code)
                                .toList(),
                        selectedValue:
                            invoiceHistoryController.selectedCurrency,
                        onChanged: (v) {
                          invoiceHistoryController.selectedCurrency = v;
                          invoiceHistoryController.selectedCurrencyId =
                              invoiceHistoryController.customCurrencyList
                                  .firstWhere((e) => e.currency_code == v)
                                  .id
                                  .toString();
                          invoiceHistoryController.update();
                        },
                        hint:
                            storedLanguage['Select Currency'] ??
                            "Select Currency",
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
                VSpace(24.h),
                GetBuilder<InvoiceHistoryController>(
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
                            invoiceHistoryController.statusList
                                .map((e) => e)
                                .toList(),
                        selectedValue: invoiceHistoryController.selectedStatus,
                        onChanged: (v) {
                          invoiceHistoryController.selectedStatus = v;
                          invoiceHistoryController.update();
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
                    invoiceHistoryController.resetDataAfterSearching(
                      isFromOnRefreshIndicator: true,
                    );
                    Get.back();
                    await invoiceHistoryController.getInvoiceList(
                      page: 1,
                      email: invoiceHistoryController.emailEditingCtrlr.text,
                      status:
                          invoiceHistoryController.selectedStatus ==
                                  "All Status"
                              ? ""
                              : invoiceHistoryController.selectedStatus ==
                                  "Paid"
                              ? "paid"
                              : invoiceHistoryController.selectedStatus ==
                                  "UnPaid"
                              ? "unpaid"
                              : invoiceHistoryController.selectedStatus ==
                                  "Rejected"
                              ? "rejected"
                              : invoiceHistoryController.selectedStatus,
                      created_at:
                          invoiceHistoryController.dateTimeEditingCtrlr.text,
                      currency_id: invoiceHistoryController.selectedCurrencyId,
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

String checkStatus(String data) {
  switch (data) {
    case "paid":
      return "$rootImageDir/paid.webp";
    case "Unpaid":
      return "$rootImageDir/unpaid.webp";
    default:
      return "$rootImageDir/unknown.webp";
  }
}

dynamic checkBgColor(String data) {
  switch (data) {
    case "paid":
      return AppColors.greenColor.withValues(alpha: .1);
    case "Unpaid":
      return AppColors.pendingColor.withValues(alpha: .1);
    default:
      return AppColors.mainColor.withValues(alpha: .1);
  }
}

dynamic checkIconColor(String data) {
  switch (data) {
    case "paid":
      return AppColors.greenColor;
    case "Unpaid":
      return AppColors.pendingColor;
    default:
      return AppColors.mainColor;
  }
}
