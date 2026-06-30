import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:paysecure/config/dimensions.dart';
import 'package:paysecure/views/widgets/custom_appbar.dart';
import 'package:paysecure/views/widgets/text_theme_extension.dart';
import '../../../config/app_colors.dart';
import '../../../controllers/qr_payment_controller.dart';
import '../../../themes/themes.dart';
import '../../../utils/app_constants.dart';
import '../../../utils/services/helpers.dart';
import '../../../utils/services/localstorage/hive.dart';
import '../../../utils/services/localstorage/keys.dart';
import '../../widgets/appDialog.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_custom_dropdown.dart';
import '../../widgets/custom_textfield.dart';
import '../../widgets/search_dialog.dart';
import '../../widgets/spacing.dart';
import '../home/home_screen.dart';

class QrPaymentScreen extends StatelessWidget {
  const QrPaymentScreen({super.key});

  @override
  Widget build(BuildContext context) {
    var storedLanguage = HiveHelp.read(Keys.languageData) ?? {};
    TextTheme t = Theme.of(context).textTheme;
    return GetBuilder<QrPaymentController>(
      builder: (qrPaymentController) {
        return Scaffold(
          appBar: buildAppbar(storedLanguage, context, qrPaymentController),
          body: RefreshIndicator(
            color: AppColors.mainColor,
            onRefresh: () async {
              qrPaymentController.selectedGateway = null;
              qrPaymentController.selectedGatewayId = "";
              qrPaymentController.emailEditingCtrlr.clear();
              qrPaymentController.dateTimeEditingCtrlr.clear();
              qrPaymentController.resetDataAfterSearching(
                isFromOnRefreshIndicator: true,
              );
              await qrPaymentController.getQrPaymentList(
                page: 1,
                gateway: "",
                email: "",
                created_at: "",
              );
            },
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              controller: qrPaymentController.scrollController,
              child: Padding(
                padding: Dimensions.kDefaultPadding,
                child: Column(
                  children: [
                    VSpace(20.h),
                    qrPaymentController.isLoading
                        ? buildTransactionLoader(
                          itemCount: 20,
                          isReverseColor: true,
                        )
                        : qrPaymentController.qrPaymentList.isEmpty
                        ? Helpers.notFound()
                        : ListView.builder(
                          physics: const NeverScrollableScrollPhysics(),
                          shrinkWrap: true,
                          itemCount: qrPaymentController.qrPaymentList.length,
                          itemBuilder: (context, i) {
                            var data = qrPaymentController.qrPaymentList[i];
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
                                      Image.asset(
                                        "$rootImageDir/done.webp",
                                        height: 48.h,
                                        width: 48.h,
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
                                      Text(
                                        storedLanguage['Amount'] ?? "Amount",
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
                                      Text(
                                        storedLanguage['Charge'] ?? "Charge",
                                        style: t.bodyMedium?.copyWith(
                                          color:
                                              Get.isDarkMode
                                                  ? AppColors.whiteColor
                                                  : AppColors.blackColor,
                                        ),
                                      ),
                                      Text(
                                        data.charge.toString() +
                                            " ${data.currency}",
                                        style: t.bodySmall?.copyWith(
                                          color: AppColors.redColor,
                                        ),
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
                                      width: 44.h,
                                      height: 44.h,
                                      padding: EdgeInsets.all(10.h),
                                      decoration: BoxDecoration(
                                        color:
                                            data.status.toString() == '0'
                                                ? AppColors.pendingColor
                                                    .withValues(alpha: .1)
                                                : AppColors.greenColor
                                                    .withValues(alpha: .1),
                                        shape: BoxShape.circle,
                                      ),
                                      child: Image.asset(
                                        data.status.toString() == '0'
                                            ? "$rootImageDir/pending.webp"
                                            : '$rootImageDir/approved.webp',
                                        color:
                                            data.status.toString() == '0'
                                                ? AppColors.pendingColor
                                                : AppColors.greenColor,
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
                                                      data.gateway.toString(),
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
                                                child: Align(
                                                  alignment:
                                                      Alignment.centerRight,
                                                  child: Text(
                                                    "${data.amount.toString()} ${data.currency.toString()}",
                                                    maxLines: 1,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    style: t.bodyMedium,
                                                  ),
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
                    if (qrPaymentController.isLoadMore == true)
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
    QrPaymentController qrPaymentController,
  ) {
    return CustomAppBar(
      title: storedLanguage['QR Payment'] ?? "QR Payment",
      actions: [
        InkResponse(
          onTap: () {
            searchDialog(
              context: context,
              children: [
                CustomTextField(
                  hintext: storedLanguage['Email'] ?? "Email",
                  controller: qrPaymentController.emailEditingCtrlr,
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
                            qrPaymentController
                                .dateTimeEditingCtrlr
                                .text = DateFormat('yyyy-MM-dd').format(value);
                          }
                        });
                      },
                      child: IgnorePointer(
                        ignoring: true,
                        child: CustomTextField(
                          hintext: storedLanguage['Date'] ?? "Date",
                          controller: qrPaymentController.dateTimeEditingCtrlr,
                          contentPadding: EdgeInsets.only(left: 20.w),
                        ),
                      ),
                    ),
                    InkResponse(
                      onTap: () {
                        qrPaymentController.dateTimeEditingCtrlr.clear();
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
                GetBuilder<QrPaymentController>(
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
                            qrPaymentController.gatewayList
                                .map((e) => e.name)
                                .toList(),
                        selectedValue: qrPaymentController.selectedGateway,
                        onChanged: (v) {
                          qrPaymentController.selectedGateway = v;
                          qrPaymentController.selectedGatewayId =
                              qrPaymentController.gatewayList
                                  .firstWhere((e) => e.name == v)
                                  .id
                                  .toString();
                          qrPaymentController.update();
                        },
                        hint:
                            storedLanguage['Select Gateway'] ??
                            "Select Gateway",
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
                  text: storedLanguage['Search Now'] ?? "Search Now",
                  onTap: () async {
                    qrPaymentController.resetDataAfterSearching(
                      isFromOnRefreshIndicator: true,
                    );
                    Get.back();

                    await qrPaymentController.getQrPaymentList(
                      page: 1,
                      gateway: qrPaymentController.selectedGatewayId,
                      email: qrPaymentController.emailEditingCtrlr.text,
                      created_at: qrPaymentController.dateTimeEditingCtrlr.text,
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
