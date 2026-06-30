import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:paysecure/controllers/bindings/controller_index.dart';
import 'package:paysecure/controllers/redeem_code_controller.dart';
import 'package:paysecure/views/screens/redeem/redeem_preview_screen.dart';
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

class RedeemHistoryScreen extends StatelessWidget {
  final bool? isFromRedeemPage;
  const RedeemHistoryScreen({super.key, this.isFromRedeemPage = false});

  @override
  Widget build(BuildContext context) {
    TextTheme t = Theme.of(context).textTheme;
    var storedLanguage = HiveHelp.read(Keys.languageData) ?? {};
    return GetBuilder<RedeemHistoryController>(
      builder: (redeemHistoryController) {
        return GetBuilder<RedeemCodeController>(
          builder: (redeemCodeCtrl) {
            return PopScope(
              canPop: false,
              onPopInvokedWithResult: (didPop, result) {
                if (didPop) return;
                if (isFromRedeemPage == true) {
                  Get.toNamed(RoutesName.bottomNavBar);
                  Get.delete<RedeemHistoryController>();
                } else {
                  Get.back();
                }
              },
              child: Scaffold(
                appBar: buildAppbar(
                  storedLanguage,
                  context,
                  redeemHistoryController,
                ),
                body: RefreshIndicator(
                  color: AppColors.mainColor,
                  onRefresh: () async {
                    redeemHistoryController.refreshSearchData();
                    redeemHistoryController.resetDataAfterSearching(
                      isFromOnRefreshIndicator: true,
                    );
                    await redeemHistoryController.getRedeemList(
                      page: 1,
                      email: "",
                      status: "",
                      created_at: "",
                      utr: "",
                    );
                  },
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    controller: redeemHistoryController.scrollController,
                    child: Padding(
                      padding: Dimensions.kDefaultPadding,
                      child: Column(
                        children: [
                          VSpace(20.h),
                          redeemHistoryController.isLoading
                              ? buildTransactionLoader(
                                itemCount: 20,
                                isReverseColor: true,
                              )
                              : redeemHistoryController.redeemList.isEmpty
                              ? Helpers.notFound()
                              : ListView.builder(
                                physics: const NeverScrollableScrollPhysics(),
                                shrinkWrap: true,
                                itemCount:
                                    redeemHistoryController.redeemList.length,
                                itemBuilder: (context, i) {
                                  var data =
                                      redeemHistoryController.redeemList[i];
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
                                              data.receiverEMail.toString(),
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
                                                                    redeemCodeCtrl
                                                                            .isLoading
                                                                        ? null
                                                                        : () async {
                                                                          Get.to(
                                                                            () => RedeemPreviewScreen(
                                                                              utr:
                                                                                  data.transactionId.toString(),
                                                                              isFromHistoryPag:
                                                                                  true,
                                                                              context:
                                                                                  context,
                                                                            ),
                                                                          );
                                                                          await redeemCodeCtrl.generateCodePreview(
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
                                                                        "Generate",
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
                          if (redeemHistoryController.isLoadMore == true)
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
    RedeemHistoryController redeemHistoryController,
  ) {
    return CustomAppBar(
      title: storedLanguage['Redeem History'] ?? "Redeem History",
      onBackPressed: () {
        if (isFromRedeemPage == true) {
          Get.toNamed(RoutesName.bottomNavBar);
          Get.delete<RedeemHistoryController>();
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
                  controller: redeemHistoryController.utrEditingCtrlr,
                  contentPadding: EdgeInsets.only(left: 20.w),
                ),
                VSpace(24.h),
                CustomTextField(
                  hintext: "Email",
                  controller: redeemHistoryController.emailEditingCtrlr,
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
                            redeemHistoryController
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
                              redeemHistoryController.dateTimeEditingCtrlr,
                          contentPadding: EdgeInsets.only(left: 20.w),
                        ),
                      ),
                    ),
                    InkResponse(
                      onTap: () {
                        redeemHistoryController.dateTimeEditingCtrlr.clear();
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
                GetBuilder<RedeemHistoryController>(
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
                            redeemHistoryController.statusList
                                .map((e) => e)
                                .toList(),
                        selectedValue: redeemHistoryController.selectedStatus,
                        onChanged: (v) {
                          redeemHistoryController.selectedStatus = v;
                          redeemHistoryController.update();
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
                    redeemHistoryController.resetDataAfterSearching(
                      isFromOnRefreshIndicator: true,
                    );
                    Get.back();
                    await redeemHistoryController.getRedeemList(
                      page: 1,
                      email: redeemHistoryController.emailEditingCtrlr.text,
                      status:
                          redeemHistoryController.selectedStatus == "All"
                              ? ""
                              : redeemHistoryController.selectedStatus ==
                                  'Pending'
                              ? "0"
                              : redeemHistoryController.selectedStatus ==
                                  'Unused'
                              ? "1"
                              : "2",
                      created_at:
                          redeemHistoryController.dateTimeEditingCtrlr.text,
                      utr: redeemHistoryController.utrEditingCtrlr.text,
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
    case "Unused":
      return "$rootImageDir/bill_return.webp";
    case "Used":
      return "$rootImageDir/bill_completed.webp";
    default:
      return "$rootImageDir/unknown.webp";
  }
}

dynamic checkBgColor(String data) {
  switch (data) {
    case "Pending":
      return AppColors.pendingColor.withValues(alpha: .1);
    case "Unused":
      return AppColors.secondaryColor.withValues(alpha: .1);
    case "Used":
      return AppColors.greenColor.withValues(alpha: .1);
    default:
      return AppColors.mainColor.withValues(alpha: .1);
  }
}

dynamic checkIconColor(String data) {
  switch (data) {
    case "Pending":
      return AppColors.pendingColor;
    case "Unused":
      return AppColors.secondaryColor;
    case "Used":
      return AppColors.greenColor;
    default:
      return AppColors.mainColor;
  }
}
