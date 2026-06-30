import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:paysecure/controllers/bindings/controller_index.dart';
import 'package:paysecure/controllers/send_money_controller.dart';
import 'package:paysecure/views/screens/send_money/send_money_preview_screen.dart';
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

class SendMoneyHistoryScreen extends StatelessWidget {
  final bool? isFromSendMoneyPage;
  const SendMoneyHistoryScreen({super.key, this.isFromSendMoneyPage = false});

  @override
  Widget build(BuildContext context) {
    TextTheme t = Theme.of(context).textTheme;
    var storedLanguage = HiveHelp.read(Keys.languageData) ?? {};
    return GetBuilder<SendMoneyHistoryController>(
      builder: (sendMoneyHistoryController) {
        return GetBuilder<SendMoneyController>(
          builder: (sendMoneyCtrl) {
            return PopScope(
              canPop: false,
              onPopInvokedWithResult: (didPop, result) {
                if (didPop) return;
                if (isFromSendMoneyPage == true) {
                  Get.toNamed(RoutesName.bottomNavBar);
                  Get.delete<SendMoneyHistoryController>();
                } else {
                  Get.back();
                }
              },
              child: Scaffold(
                appBar: buildAppbar(
                  storedLanguage,
                  context,
                  sendMoneyHistoryController,
                  isFromSendMoneyPage,
                ),
                body: RefreshIndicator(
                  color: AppColors.mainColor,
                  onRefresh: () async {
                    sendMoneyHistoryController.refreshSearchData();
                    sendMoneyHistoryController.resetDataAfterSearching(
                      isFromOnRefreshIndicator: true,
                    );
                    await sendMoneyHistoryController.getSendMoneyList(
                      page: 1,
                      email: "",
                      created_at: "",
                      utr: "",
                    );
                  },
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    controller: sendMoneyHistoryController.scrollController,
                    child: Padding(
                      padding: Dimensions.kDefaultPadding,
                      child: Column(
                        children: [
                          VSpace(20.h),
                          sendMoneyHistoryController.isLoading
                              ? buildTransactionLoader(
                                itemCount: 20,
                                isReverseColor: true,
                              )
                              : sendMoneyHistoryController.sendMoeyList.isEmpty
                              ? Helpers.notFound()
                              : ListView.builder(
                                physics: const NeverScrollableScrollPhysics(),
                                shrinkWrap: true,
                                itemCount:
                                    sendMoneyHistoryController
                                        .sendMoeyList
                                        .length,
                                itemBuilder: (context, i) {
                                  var data =
                                      sendMoneyHistoryController
                                          .sendMoeyList[i];
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
                                              data.amount.toString() +
                                                  " ${data.currencyCode}",
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
                                                          if (data.status
                                                                  .toString() ==
                                                              "Pending")
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
                                                                    sendMoneyCtrl
                                                                            .isLoading
                                                                        ? null
                                                                        : () async {
                                                                          Get.to(
                                                                            () => SendMoneyPreviewScreen(
                                                                              utr:
                                                                                  data.transactionId.toString(),
                                                                              isFromHistoryPage:
                                                                                  true,
                                                                              context:
                                                                                  context,
                                                                            ),
                                                                          );
                                                                          await sendMoneyCtrl.sendMoneyPreview(
                                                                            utr:
                                                                                data.transactionId.toString(),
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
                                                                            ? AppColors.darkCardColor
                                                                            : AppColors.sliderInActiveColor,
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
                                                                      HSpace(
                                                                        5.w,
                                                                      ),
                                                                      Padding(
                                                                        padding: EdgeInsets.only(
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
                                                              "${data.amount.toString()} ${data.currencyCode.toString()}",
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
                          if (sendMoneyHistoryController.isLoadMore == true)
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
    SendMoneyHistoryController sendMoneyHistoryController,
    isFromSendMoneyPage,
  ) {
    return CustomAppBar(
      title: storedLanguage['Transfer History'] ?? "Transfer History",
      onBackPressed: () {
        if (isFromSendMoneyPage == true) {
          Get.toNamed(RoutesName.bottomNavBar);
          Get.delete<SendMoneyHistoryController>();
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
                  controller: sendMoneyHistoryController.utrEditingCtrlr,
                  contentPadding: EdgeInsets.only(left: 20.w),
                ),
                VSpace(24.h),
                CustomTextField(
                  hintext: "Email",
                  controller: sendMoneyHistoryController.emailEditingCtrlr,
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
                            sendMoneyHistoryController
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
                              sendMoneyHistoryController.dateTimeEditingCtrlr,
                          contentPadding: EdgeInsets.only(left: 20.w),
                        ),
                      ),
                    ),
                    InkResponse(
                      onTap: () {
                        sendMoneyHistoryController.dateTimeEditingCtrlr.clear();
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
                    sendMoneyHistoryController.resetDataAfterSearching(
                      isFromOnRefreshIndicator: true,
                    );
                    Get.back();
                    await sendMoneyHistoryController.getSendMoneyList(
                      page: 1,
                      email: sendMoneyHistoryController.emailEditingCtrlr.text,
                      created_at:
                          sendMoneyHistoryController.dateTimeEditingCtrlr.text,
                      utr: sendMoneyHistoryController.utrEditingCtrlr.text,
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
    default:
      return AppColors.mainColor;
  }
}
