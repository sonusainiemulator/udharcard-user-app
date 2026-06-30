import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:paysecure/controllers/bindings/controller_index.dart';
import 'package:paysecure/controllers/request_money_controller.dart';
import 'package:paysecure/views/screens/request_money/request_money_preview_screen.dart';
import 'package:paysecure/views/widgets/text_theme_extension.dart';
import '../../../../../config/app_colors.dart';
import '../../../../config/dimensions.dart';
import '../../../../themes/themes.dart';
import '../../../../utils/app_constants.dart';
import '../../../../utils/services/helpers.dart';
import '../../../../utils/services/localstorage/hive.dart';
import '../../../../utils/services/localstorage/keys.dart';
import '../../../routes/routes_name.dart';
import '../home/home_screen.dart';
import '../../widgets/appDialog.dart';
import '../../widgets/app_button.dart';
import '../../widgets/custom_appbar.dart';
import '../../widgets/custom_textfield.dart';
import '../../widgets/search_dialog.dart';
import '../../widgets/spacing.dart';

class RequestMoneyHistoryScreen extends StatelessWidget {
  final bool? isFromRequestMoneyPage;
  const RequestMoneyHistoryScreen({
    super.key,
    this.isFromRequestMoneyPage = false,
  });

  @override
  Widget build(BuildContext context) {
    TextTheme t = Theme.of(context).textTheme;
    var storedLanguage = HiveHelp.read(Keys.languageData) ?? {};
    return GetBuilder<RequestHistoryController>(
      builder: (requestHistoryController) {
        return GetBuilder<RequestMoneyController>(
          builder: (requestCtrl) {
            return PopScope(
              canPop: false,
              onPopInvokedWithResult: (didPop, result) {
                if (didPop) return;
                if (isFromRequestMoneyPage == true) {
                  Get.toNamed(RoutesName.bottomNavBar);
                  Get.delete<RequestHistoryController>();
                } else {
                  Get.back();
                }
              },
              child: Scaffold(
                appBar: buildAppbar(
                  storedLanguage,
                  context,
                  requestHistoryController,
                  isFromRequestMoneyPage,
                ),
                body: RefreshIndicator(
                  color: AppColors.mainColor,
                  onRefresh: () async {
                    requestHistoryController.refreshSearchData();
                    requestHistoryController.resetDataAfterSearching(
                      isFromOnRefreshIndicator: true,
                    );
                    await requestHistoryController.getRequestList(
                      page: 1,
                      email: "",
                      created_at: "",
                      utr: "",
                    );
                  },
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    controller: requestHistoryController.scrollController,
                    child: Padding(
                      padding: Dimensions.kDefaultPadding,
                      child: Column(
                        children: [
                          VSpace(20.h),
                          requestHistoryController.isLoading
                              ? buildTransactionLoader(
                                itemCount: 20,
                                isReverseColor: true,
                              )
                              : requestHistoryController.requestMoeyList.isEmpty
                              ? Helpers.notFound()
                              : ListView.builder(
                                physics: const NeverScrollableScrollPhysics(),
                                shrinkWrap: true,
                                itemCount:
                                    requestHistoryController
                                        .requestMoeyList
                                        .length,
                                itemBuilder: (context, i) {
                                  var data =
                                      requestHistoryController
                                          .requestMoeyList[i];
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
                                                                      .blackColor
                                                                      .withValues(
                                                                        alpha:
                                                                            .5,
                                                                      ),
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
                                            VSpace(12.h),
                                            Text(
                                              storedLanguage['Status'] ??
                                                  "Status",
                                              style: t.bodyMedium?.copyWith(
                                                color:
                                                    Get.isDarkMode
                                                        ? AppColors.whiteColor
                                                        : AppColors.blackColor,
                                              ),
                                            ),
                                            Text(
                                              data.status.toString(),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
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
                                              data.amount.toString() +
                                                  " " +
                                                  data.currency.toString(),
                                              style: t.bodySmall,
                                            ),
                                            VSpace(12.h),
                                            Text(
                                              storedLanguage['Request To'] ??
                                                  "Request To",
                                              style: t.bodyMedium?.copyWith(
                                                color:
                                                    Get.isDarkMode
                                                        ? AppColors.whiteColor
                                                        : AppColors.blackColor,
                                              ),
                                            ),
                                            Text(
                                              data.requestTo.toString(),
                                              style: t.bodySmall,
                                            ),
                                            VSpace(12.h),
                                            Text(
                                              storedLanguage['Sender Email'] ??
                                                  "Sender Email",
                                              style: t.bodyMedium?.copyWith(
                                                color:
                                                    Get.isDarkMode
                                                        ? AppColors.whiteColor
                                                        : AppColors.blackColor,
                                              ),
                                            ),
                                            Text(
                                              data.senderEmail.toString(),
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
                                                      flex: 8,
                                                      child: Column(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .spaceBetween,
                                                        children: [
                                                          Text(
                                                            "Request to " +
                                                                data.requestTo
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
                                                          Row(
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .end,
                                                            children: [
                                                              if (data.status
                                                                      .toString() ==
                                                                  "Pending")
                                                                buildBtn(
                                                                  requestCtrl,
                                                                  t,
                                                                  onTap: () {
                                                                    buildDialog(
                                                                      context,
                                                                      requestCtrl,
                                                                      onTap:
                                                                          requestCtrl.isSubmit
                                                                              ? null
                                                                              : () async {
                                                                                requestCtrl.tappedIndex = i;
                                                                                requestCtrl.update();
                                                                                await requestCtrl
                                                                                    .requestCancel(
                                                                                      utr:
                                                                                          data.transactionId.toString(),
                                                                                    )
                                                                                    .then(
                                                                                      (
                                                                                        value,
                                                                                      ) => Navigator.pop(
                                                                                        context,
                                                                                      ),
                                                                                    );
                                                                              },
                                                                    );
                                                                  },
                                                                  isCancelColor:
                                                                      true,
                                                                  text:
                                                                      "Cancel",
                                                                ),
                                                              if (data.status
                                                                          .toString() ==
                                                                      "Pending" &&
                                                                  data.requestTo
                                                                          .toString() ==
                                                                      HiveHelp.read(
                                                                        Keys.userFullName,
                                                                      ))
                                                                Padding(
                                                                  padding:
                                                                      EdgeInsets.only(
                                                                        left:
                                                                            5.w,
                                                                      ),
                                                                  child: buildBtn(
                                                                    requestCtrl,
                                                                    t,
                                                                    onTap: () {
                                                                      RequestMoneyController
                                                                          .to
                                                                          .requestMoneyPreview(
                                                                            utr:
                                                                                data.transactionId.toString(),
                                                                          );
                                                                      Get.to(
                                                                        () => RequestMoneyPreviewScreen(
                                                                          utr:
                                                                              data.transactionId.toString(),
                                                                        ),
                                                                      );
                                                                      RequestMoneyController
                                                                          .to
                                                                          .utr = data
                                                                              .transactionId
                                                                              .toString();
                                                                    },
                                                                    text: "Yes",
                                                                  ),
                                                                ),
                                                            ],
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
                          if (requestHistoryController.isLoadMore == true)
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

  buildDialog(
    BuildContext context,
    RequestMoneyController requestCtrl, {
    required void Function()? onTap,
  }) {
    appDialog(
      context: context,
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text("Confirmation", style: context.t.bodyLarge),
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
          Text(
            "Do you want to cancel this request?",
            style: context.t.bodyMedium,
          ),
          VSpace(40.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              AppButton(
                buttonWidth: 90.w,
                buttonHeight: 35.h,
                bgColor: Colors.transparent,
                border: Border.all(color: AppColors.mainColor),
                style: context.t.bodyMedium,
                onTap: () {
                  Get.back();
                },
                text: "Close",
              ),
              HSpace(10.w),
              GetBuilder<RequestMoneyController>(
                builder: (_) {
                  return AppButton(
                    loaderSize: 20.h,
                    isLoading: requestCtrl.isSubmit ? true : false,
                    buttonWidth: requestCtrl.isLoading ? 60.w : 110.w,
                    buttonHeight: 35.h,
                    onTap: requestCtrl.isSubmit ? null : onTap,
                    text: "Confirm",
                    style: context.t.bodyMedium?.copyWith(
                      color: AppColors.whiteColor,
                    ),
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget buildBtn(
    RequestMoneyController requestCtrl,
    TextTheme t, {
    required String text,
    required void Function()? onTap,
    bool? isCancelColor = false,
  }) {
    return Align(
      alignment: Alignment.centerRight,
      child: InkWell(
        borderRadius: BorderRadius.circular(4.r),
        onTap: onTap,
        child: Ink(
          padding: EdgeInsets.symmetric(vertical: 5.h, horizontal: 9.w),
          decoration: BoxDecoration(
            color:
                Get.isDarkMode
                    ? isCancelColor == true
                        ? AppColors.redColor.withValues(alpha: .1)
                        : AppColors.darkCardColor
                    : isCancelColor == true
                    ? AppColors.redColor.withValues(alpha: .1)
                    : AppColors.sliderInActiveColor,
            borderRadius: BorderRadius.circular(4.r),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "$text",
                style: t.bodySmall?.copyWith(
                  fontSize: 14.sp,
                  color:
                      Get.isDarkMode
                          ? AppColors.whiteColor
                          : AppColors.blackColor,
                ),
              ),
              HSpace(5.w),
              Padding(
                padding: EdgeInsets.only(top: 3.h),
                child: Image.asset(
                  "$rootImageDir/confirm_arrow.webp",
                  color: AppThemes.getIconBlackColor(),
                  height: 12.h,
                  width: 12.h,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  CustomAppBar buildAppbar(
    storedLanguage,
    BuildContext context,
    RequestHistoryController requestHistoryController,
    isFromRequestMoneyPage,
  ) {
    return CustomAppBar(
      title: storedLanguage['Request History'] ?? "Request History",
      onBackPressed: () {
        if (isFromRequestMoneyPage == true) {
          Get.toNamed(RoutesName.bottomNavBar);
          Get.delete<RequestHistoryController>();
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
                CustomTextField(
                  hintext: "Transaction ID",
                  controller: requestHistoryController.utrEditingCtrlr,
                  contentPadding: EdgeInsets.only(left: 20.w),
                ),
                VSpace(24.h),
                CustomTextField(
                  hintext: "Email",
                  controller: requestHistoryController.emailEditingCtrlr,
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
                            requestHistoryController
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
                              requestHistoryController.dateTimeEditingCtrlr,
                          contentPadding: EdgeInsets.only(left: 20.w),
                        ),
                      ),
                    ),
                    InkResponse(
                      onTap: () {
                        requestHistoryController.dateTimeEditingCtrlr.clear();
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
                    requestHistoryController.resetDataAfterSearching(
                      isFromOnRefreshIndicator: true,
                    );
                    Get.back();
                    await requestHistoryController.getRequestList(
                      page: 1,
                      email: requestHistoryController.emailEditingCtrlr.text,
                      created_at:
                          requestHistoryController.dateTimeEditingCtrlr.text,
                      utr: requestHistoryController.utrEditingCtrlr.text,
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
    case "Pending":
      return "$rootImageDir/pending.webp";
    case "Success":
      return "$rootImageDir/approved.webp";
    case "Canceled":
      return "$rootImageDir/close.webp";
    default:
      return "$rootImageDir/unknown.webp";
  }
}

dynamic checkBgColor(String data) {
  switch (data) {
    case "Pending":
      return AppColors.pendingColor.withValues(alpha: .1);
    case "Success":
      return AppColors.greenColor.withValues(alpha: .1);
    case "Canceled":
      return AppColors.redColor.withValues(alpha: .1);
    default:
      return AppColors.mainColor.withValues(alpha: .1);
  }
}

dynamic checkIconColor(String data) {
  switch (data) {
    case "Pending":
      return AppColors.pendingColor;
    case "Success":
      return AppColors.greenColor;
    case "Canceled":
      return AppColors.redColor;
    default:
      return AppColors.mainColor;
  }
}
