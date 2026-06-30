import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:paysecure/config/dimensions.dart';
import 'package:paysecure/controllers/deposit_controller.dart';
import 'package:paysecure/views/screens/deposit/deposit_preview_screen.dart';
import 'package:paysecure/views/widgets/custom_appbar.dart';
import '../../../config/app_colors.dart';
import '../../../controllers/deposit_history_controller.dart';
import '../../../themes/themes.dart';
import '../../../utils/app_constants.dart';
import '../../../utils/services/helpers.dart';
import '../../../utils/services/localstorage/hive.dart';
import '../../../utils/services/localstorage/keys.dart';
import '../../widgets/appDialog.dart';
import '../../widgets/app_button.dart';
import '../../widgets/custom_textfield.dart';
import '../../widgets/search_dialog.dart';
import '../../widgets/spacing.dart';
import '../home/home_screen.dart';

class DepositHistoryScreen extends StatelessWidget {
  const DepositHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    var storedLanguage = HiveHelp.read(Keys.languageData) ?? {};
    TextTheme t = Theme.of(context).textTheme;
    return GetBuilder<DepositHistoryController>(
      builder: (depositHistoryController) {
        return Scaffold(
          appBar: buildAppbar(
            storedLanguage,
            context,
            depositHistoryController,
          ),
          body: RefreshIndicator(
            color: AppColors.mainColor,
            onRefresh: () async {
              depositHistoryController.utrEditingCtrlr.clear();
              depositHistoryController.resetDataAfterSearching(
                isFromOnRefreshIndicator: true,
              );
              await depositHistoryController.getDepositList(
                page: 1,
                transaction_id: "",
                currency: "",
                created_at: "",
              );
            },
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              controller: depositHistoryController.scrollController,
              child: Padding(
                padding: Dimensions.kDefaultPadding,
                child: Column(
                  children: [
                    VSpace(20.h),
                    depositHistoryController.isLoading
                        ? buildTransactionLoader(
                          itemCount: 20,
                          isReverseColor: true,
                        )
                        : depositHistoryController.depositList.isEmpty
                        ? Helpers.notFound()
                        : ListView.builder(
                          physics: const NeverScrollableScrollPhysics(),
                          shrinkWrap: true,
                          itemCount:
                              depositHistoryController.depositList.length,
                          itemBuilder: (context, i) {
                            var data = depositHistoryController.depositList[i];
                            return InkWell(
                              borderRadius: Dimensions.kBorderRadius,
                              onTap: () {
                                appDialog(
                                  context: context,
                                  title: Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
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
                                        width: 54.h,
                                        height: 54.h,
                                        padding: EdgeInsets.all(10.h),
                                        decoration: BoxDecoration(
                                          color:
                                              data.status.toString() == '0'
                                                  ? AppColors.pendingColor
                                                      .withValues(alpha: .1)
                                                  : data.status.toString() ==
                                                      '1'
                                                  ? AppColors.greenColor
                                                      .withValues(alpha: .1)
                                                  : AppColors.redColor
                                                      .withValues(alpha: .1),
                                          shape: BoxShape.circle,
                                        ),
                                        child: Image.asset(
                                          data.status.toString() == '0'
                                              ? '$rootImageDir/pending.webp'
                                              : data.status.toString() == '1'
                                              ? '$rootImageDir/approved.webp'
                                              : '$rootImageDir/rejected.webp',
                                          color:
                                              data.status.toString() == '0'
                                                  ? AppColors.pendingColor
                                                  : data.status.toString() ==
                                                      '1'
                                                  ? AppColors.greenColor
                                                  : AppColors.redColor,
                                          fit: BoxFit.contain,
                                        ),
                                      ),
                                      VSpace(12.h),
                                      Text(
                                        storedLanguage['Transaction ID'] ??
                                            "Transaction ID",
                                        style: t.bodyMedium?.copyWith(
                                          color:
                                              Get.isDarkMode
                                                  ? AppColors.whiteColor
                                                  : AppColors.blackColor,
                                        ),
                                      ),
                                      SelectableText(
                                        data.trxId.toString(),
                                        style: t.bodySmall,
                                      ),
                                      VSpace(12.h),
                                      Text(
                                        storedLanguage['Status'] ?? "Status",
                                        style: t.bodyMedium?.copyWith(
                                          color:
                                              Get.isDarkMode
                                                  ? AppColors.whiteColor
                                                  : AppColors.blackColor,
                                        ),
                                      ),
                                      Text(
                                        data.status.toString() == '0'
                                            ? 'Pending'
                                            : data.status.toString() == '1'
                                            ? 'Success'
                                            : 'Rejected',
                                        style: t.bodySmall?.copyWith(
                                          color:
                                              data.status.toString() == "1"
                                                  ? AppColors.greenColor
                                                  : data.status.toString() ==
                                                      "2"
                                                  ? AppColors.redColor
                                                  : AppColors.pendingColor,
                                        ),
                                      ),
                                      VSpace(12.h),
                                      Text(
                                        storedLanguage['Date'] ?? "Date",
                                        style: t.bodyMedium?.copyWith(
                                          color:
                                              Get.isDarkMode
                                                  ? AppColors.whiteColor
                                                  : AppColors.blackColor,
                                        ),
                                      ),
                                      Text(
                                        DateFormat('dd MMM yyyy')
                                            .format(
                                              DateTime.parse(
                                                data.createdAt.toString(),
                                              ),
                                            )
                                            .toString(),
                                        style: t.bodySmall,
                                      ),
                                      VSpace(12.h),
                                    ],
                                  ),
                                );
                              },
                              child: Ink(
                                width: double.maxFinite,
                                padding: EdgeInsets.symmetric(vertical: 10.h),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      width: 45.h,
                                      height: 45.h,
                                      padding: EdgeInsets.all(10.h),
                                      decoration: BoxDecoration(
                                        color:
                                            data.status.toString() == '0'
                                                ? AppColors.pendingColor
                                                    .withValues(alpha: .1)
                                                : data.status.toString() == '1'
                                                ? AppColors.greenColor
                                                    .withValues(alpha: .1)
                                                : AppColors.redColor.withValues(
                                                  alpha: .1,
                                                ),
                                        shape: BoxShape.circle,
                                      ),
                                      child: Image.asset(
                                        data.status.toString() == '0'
                                            ? '$rootImageDir/pending.webp'
                                            : data.status.toString() == '1'
                                            ? '$rootImageDir/approved.webp'
                                            : '$rootImageDir/rejected.webp',
                                        color:
                                            data.status.toString() == '0'
                                                ? AppColors.pendingColor
                                                : data.status.toString() == '1'
                                                ? AppColors.greenColor
                                                : AppColors.redColor,
                                        fit: BoxFit.contain,
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
                                                      CrossAxisAlignment.start,
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  children: [
                                                    Text(
                                                      data.gateway == null
                                                          ? ''
                                                          : data.gateway!.name
                                                              .toString(),
                                                      maxLines: 1,
                                                      overflow:
                                                          TextOverflow.fade,
                                                      style: t.bodyMedium,
                                                    ),
                                                    VSpace(3.h),
                                                    Text(
                                                      data.createdAt == null
                                                          ? ""
                                                          : DateFormat(
                                                            'dd MMM yyyy',
                                                          ).format(
                                                            DateTime.parse(
                                                              data.createdAt
                                                                  .toString(),
                                                            ),
                                                          ),
                                                      maxLines: 1,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                      style: t.bodySmall?.copyWith(
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
                                                  children: [
                                                    Align(
                                                      alignment:
                                                          Alignment.centerRight,
                                                      child: Text(
                                                        "${Helpers.numberFormatWithAsFixed2('', data.amount.toString())} ${data.currency!.code.toString()}",
                                                        maxLines: 1,
                                                        overflow:
                                                            TextOverflow
                                                                .ellipsis,
                                                        style: t.bodyMedium,
                                                      ),
                                                    ),
                                                    VSpace(8.h),
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
                                                          onTap: () async {
                                                            DepositController
                                                                    .to
                                                                    .gatewayName =
                                                                data
                                                                    .gateway!
                                                                    .name
                                                                    .toString();
                                                            DepositController
                                                                    .to
                                                                    .amountValue =
                                                                data.payableAmount
                                                                    .toString();
                                                            DepositController
                                                                    .to
                                                                    .selectedCurrency =
                                                                data
                                                                    .currency!
                                                                    .code
                                                                    .toString();
                                                            DepositController.to
                                                                .update();
                                                            Get.to(
                                                              () =>
                                                                  DepositPreviewScreen(
                                                                    fund: data,
                                                                  ),
                                                            );
                                                          },
                                                          child: Ink(
                                                            padding:
                                                                EdgeInsets.symmetric(
                                                                  vertical: 5.h,
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
                                                                    width: 12.h,
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                          Container(
                                            margin: EdgeInsets.only(top: 15.h),
                                            decoration: BoxDecoration(
                                              border: Border(
                                                bottom: BorderSide(
                                                  color:
                                                      Get.isDarkMode
                                                          ? AppColors.black70
                                                          : AppColors.black20,
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
                    if (depositHistoryController.isLoadMore == true)
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
  }

  CustomAppBar buildAppbar(
    storedLanguage,
    BuildContext context,
    DepositHistoryController depositHistoryController,
  ) {
    return CustomAppBar(
      title: storedLanguage['Deposit History'] ?? "Deposit History",
      actions: [
        InkResponse(
          onTap: () {
            searchDialog(
              context: context,
              children: [
                CustomTextField(
                  hintext: "Transaction ID",
                  controller: depositHistoryController.utrEditingCtrlr,
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
                            depositHistoryController
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
                              depositHistoryController.dateTimeEditingCtrlr,
                          contentPadding: EdgeInsets.only(left: 20.w),
                        ),
                      ),
                    ),
                    InkResponse(
                      onTap: () {
                        depositHistoryController.dateTimeEditingCtrlr.clear();
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
                VSpace(28.h),
                AppButton(
                  text: "Search Now",
                  onTap: () async {
                    depositHistoryController.resetDataAfterSearching(
                      isFromOnRefreshIndicator: true,
                    );
                    Get.back();

                    await depositHistoryController.getDepositList(
                      page: 1,
                      transaction_id:
                          depositHistoryController.utrEditingCtrlr.text,
                      currency: "",
                      created_at:
                          depositHistoryController.dateTimeEditingCtrlr.text,
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
