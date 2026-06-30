import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:paysecure/controllers/bindings/controller_index.dart';
import 'package:paysecure/controllers/escrow_controller.dart';
import 'package:paysecure/views/screens/escrow/escrow_preview_screen.dart';
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

class EscrowHistoryScreen extends StatelessWidget {
  final bool? isFromEscrowPage;
  const EscrowHistoryScreen({super.key, this.isFromEscrowPage = false});

  @override
  Widget build(BuildContext context) {
    TextTheme t = Theme.of(context).textTheme;
    var storedLanguage = HiveHelp.read(Keys.languageData) ?? {};
    return GetBuilder<EscrowHistoryController>(
      builder: (escrowHistoryController) {
        return GetBuilder<EscrowController>(
          builder: (escrowCtrl) {
            return PopScope(
              canPop: false,
              onPopInvokedWithResult: (didPop, result) {
                if (didPop) return;
                if (isFromEscrowPage == true) {
                  Get.toNamed(RoutesName.bottomNavBar);
                  Get.delete<EscrowHistoryController>();
                } else {
                  Get.back();
                }
              },
              child: Scaffold(
                appBar: buildAppbar(
                  storedLanguage,
                  context,
                  escrowHistoryController,
                ),
                body: RefreshIndicator(
                  color: AppColors.mainColor,
                  onRefresh: () async {
                    escrowHistoryController.refreshSearchData();
                    escrowHistoryController.resetDataAfterSearching(
                      isFromOnRefreshIndicator: true,
                    );
                    await escrowHistoryController.getEscrowList(
                      page: 1,
                      email: "",
                      status: "",
                      created_at: "",
                      utr: "",
                    );
                  },
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    controller: escrowHistoryController.scrollController,
                    child: Padding(
                      padding: Dimensions.kDefaultPadding,
                      child: Column(
                        children: [
                          VSpace(20.h),
                          escrowHistoryController.isLoading
                              ? buildTransactionLoader(
                                itemCount: 20,
                                isReverseColor: true,
                              )
                              : escrowHistoryController.escrowList.isEmpty
                              ? Helpers.notFound()
                              : ListView.builder(
                                physics: const NeverScrollableScrollPhysics(),
                                shrinkWrap: true,
                                itemCount:
                                    escrowHistoryController.escrowList.length,
                                itemBuilder: (context, i) {
                                  var data =
                                      escrowHistoryController.escrowList[i];
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
                                              width: 40.h,
                                              height: 40.h,
                                              child: Image.asset(
                                                data.type.toString() ==
                                                        "Received"
                                                    ? "$rootImageDir/increment.webp"
                                                    : "$rootImageDir/decrement.webp",
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
                                            width: 40.h,
                                            height: 40.h,
                                            child: Image.asset(
                                              data.type.toString() == "Received"
                                                  ? "$rootImageDir/increment.webp"
                                                  : "$rootImageDir/decrement.webp",
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
                                                          Row(
                                                            children: [
                                                              Flexible(
                                                                child: Text(
                                                                  data.receiver
                                                                      .toString(),
                                                                  maxLines: 1,
                                                                  overflow:
                                                                      TextOverflow
                                                                          .fade,
                                                                  style: t
                                                                      .bodyMedium
                                                                      ?.copyWith(
                                                                        fontSize:
                                                                            17.sp,
                                                                      ),
                                                                ),
                                                              ),
                                                              Container(
                                                                margin:
                                                                    EdgeInsets.only(
                                                                      left: 4.w,
                                                                    ),
                                                                padding:
                                                                    EdgeInsets.symmetric(
                                                                      horizontal:
                                                                          4.w,
                                                                    ),
                                                                decoration: BoxDecoration(
                                                                  borderRadius:
                                                                      Dimensions
                                                                          .kBorderRadius /
                                                                      4,
                                                                  color:
                                                                      data.status
                                                                                  .toString() ==
                                                                              "Canceled"
                                                                          ? AppColors.redColor.withValues(
                                                                            alpha:
                                                                                .1,
                                                                          )
                                                                          : data.status.toString() ==
                                                                              "Generated"
                                                                          ? AppColors.secondaryColor.withValues(
                                                                            alpha:
                                                                                .1,
                                                                          )
                                                                          : data.status.toString() ==
                                                                              "Request for payment"
                                                                          ? AppColors.random3.withValues(
                                                                            alpha:
                                                                                .1,
                                                                          )
                                                                          : data.status.toString() ==
                                                                              "Deposited"
                                                                          ? AppColors.greenColor.withValues(
                                                                            alpha:
                                                                                .1,
                                                                          )
                                                                          : data.status.toString() ==
                                                                              "Hold"
                                                                          ? const Color.fromARGB(
                                                                            255,
                                                                            147,
                                                                            60,
                                                                            187,
                                                                          ).withValues(
                                                                            alpha:
                                                                                .1,
                                                                          )
                                                                          : AppColors.pendingColor.withValues(
                                                                            alpha:
                                                                                .1,
                                                                          ),
                                                                ),
                                                                child: Text(
                                                                  data.status
                                                                              .toString() ==
                                                                          'Deposited'
                                                                      ? 'Payment done'
                                                                      : data
                                                                          .status
                                                                          .toString(),
                                                                  maxLines: 1,
                                                                  overflow:
                                                                      TextOverflow
                                                                          .fade,
                                                                  style: t.bodyMedium?.copyWith(
                                                                    fontSize:
                                                                        12.sp,
                                                                    color:
                                                                        data.status.toString() ==
                                                                                "Canceled"
                                                                            ? AppColors.redColor
                                                                            : data.status.toString() ==
                                                                                "Generated"
                                                                            ? AppColors.secondaryColor
                                                                            : data.status.toString() ==
                                                                                "Request for payment"
                                                                            ? AppColors.random3
                                                                            : data.status.toString() ==
                                                                                "Deposited"
                                                                            ? AppColors.greenColor
                                                                            : data.status.toString() ==
                                                                                "Hold"
                                                                            ? const Color.fromARGB(
                                                                              255,
                                                                              147,
                                                                              60,
                                                                              187,
                                                                            )
                                                                            : AppColors.pendingColor,
                                                                  ),
                                                                ),
                                                              ),
                                                            ],
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
                                                            customButton(
                                                              t: t,
                                                              text: "Generate",
                                                              onTap: () async {
                                                                Get.to(
                                                                  () => EscrowPreviewScreen(
                                                                    utr:
                                                                        data.transactionId
                                                                            .toString(),
                                                                    isFromHistoryPage:
                                                                        true,
                                                                    context:
                                                                        context,
                                                                  ),
                                                                );
                                                                await escrowCtrl
                                                                    .escrowPreview(
                                                                      utr:
                                                                          data.transactionId
                                                                              .toString(),
                                                                    );
                                                              },
                                                            ),
                                                          if (data.status
                                                                  .toString() !=
                                                              "Pending")
                                                            customButton(
                                                              t: t,
                                                              text: "View",
                                                              onTap: () async {
                                                                Get.to(
                                                                  () => EscrowPreviewScreen(
                                                                    utr:
                                                                        data.transactionId
                                                                            .toString(),
                                                                    isFromHistoryPage:
                                                                        true,
                                                                    context:
                                                                        context,
                                                                  ),
                                                                );
                                                                await escrowCtrl.escrowPreview(
                                                                  utr:
                                                                      data.transactionId
                                                                          .toString() +
                                                                      "?view=1",
                                                                );
                                                              },
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
                          if (escrowHistoryController.isLoadMore == true)
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

  Widget customButton({
    required TextTheme t,
    void Function()? onTap,
    required String text,
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
                    ? AppColors.darkCardColor
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
    EscrowHistoryController escrowHistoryController,
  ) {
    return CustomAppBar(
      title: storedLanguage['Escrow History'] ?? "Escrow History",
      onBackPressed: () {
        if (isFromEscrowPage == true) {
          Get.toNamed(RoutesName.bottomNavBar);
          Get.delete<EscrowHistoryController>();
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
                  controller: escrowHistoryController.utrEditingCtrlr,
                  contentPadding: EdgeInsets.only(left: 20.w),
                ),
                VSpace(24.h),
                CustomTextField(
                  hintext: "Email",
                  controller: escrowHistoryController.emailEditingCtrlr,
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
                            escrowHistoryController
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
                              escrowHistoryController.dateTimeEditingCtrlr,
                          contentPadding: EdgeInsets.only(left: 20.w),
                        ),
                      ),
                    ),
                    InkResponse(
                      onTap: () {
                        escrowHistoryController.dateTimeEditingCtrlr.clear();
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
                GetBuilder<EscrowHistoryController>(
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
                            escrowHistoryController.statusList
                                .map((e) => e)
                                .toList(),
                        selectedValue: escrowHistoryController.selectedStatus,
                        onChanged: (v) {
                          escrowHistoryController.selectedStatus = v;
                          escrowHistoryController.update();
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
                    escrowHistoryController.resetDataAfterSearching(
                      isFromOnRefreshIndicator: true,
                    );
                    Get.back();
                    await escrowHistoryController.getEscrowList(
                      page: 1,
                      email: escrowHistoryController.emailEditingCtrlr.text,
                      status:
                          escrowHistoryController.selectedStatus == "All Status"
                              ? ""
                              : escrowHistoryController.selectedStatus ==
                                  "Pending"
                              ? "0"
                              : escrowHistoryController.selectedStatus ==
                                  "Generated"
                              ? "1"
                              : escrowHistoryController.selectedStatus ==
                                  "Payment done"
                              ? "2"
                              : escrowHistoryController.selectedStatus ==
                                  "Request for payment"
                              ? "3"
                              : escrowHistoryController.selectedStatus ==
                                  "Payment disbursed"
                              ? "4"
                              : "5",
                      created_at:
                          escrowHistoryController.dateTimeEditingCtrlr.text,
                      utr: escrowHistoryController.utrEditingCtrlr.text,
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
