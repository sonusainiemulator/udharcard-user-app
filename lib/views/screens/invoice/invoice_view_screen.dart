import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:paysecure/config/dimensions.dart';
import 'package:paysecure/controllers/invoice_history_controller.dart';
import 'package:paysecure/utils/services/helpers.dart';
import 'package:paysecure/views/widgets/custom_appbar.dart';
import 'package:paysecure/views/widgets/text_theme_extension.dart';
import '../../../config/app_colors.dart';
import '../../../themes/themes.dart';
import '../../../utils/services/localstorage/hive.dart';
import '../../../utils/services/localstorage/keys.dart';
import '../../widgets/spacing.dart';

class InvoiceViewScreen extends StatelessWidget {
  const InvoiceViewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    var storedLanguage = HiveHelp.read(Keys.languageData) ?? {};
    return GetBuilder<InvoiceHistoryController>(builder: (invoiceHistoryController) {
      return Scaffold(
        backgroundColor:
            Get.isDarkMode ? AppColors.darkBgColor : AppColors.scaffoldColor,
        appBar: CustomAppBar(
            title: storedLanguage['Invoice View'] ?? "Invoice View"),
        body: invoiceHistoryController.isViewingInvoice
            ? Helpers.appLoader()
            : SingleChildScrollView(
                child: Padding(
                  padding: Dimensions.kDefaultPadding,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      VSpace(40.h),
                      invoiceHistoryController.invoiceViewList.isEmpty
                          ? SizedBox()
                          : invoiceHistoryController.invoiceViewList[0].message!.invoice == null
                              ? SizedBox()
                              : Container(
                                  width: double.maxFinite,
                                  height: 430.h,
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 16.w, vertical: 20.h),
                                  decoration: BoxDecoration(
                                    color: AppThemes.getDarkCardColor(),
                                    borderRadius: Dimensions.kBorderRadius,
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Row(
                                        children: [
                                          Text(
                                            "Status",
                                            style: context.t.displayMedium
                                                ?.copyWith(
                                                    color: AppThemes
                                                        .getParagraphColor()),
                                          ),
                                          if (invoiceHistoryController.invoiceViewList[0].message!
                                                  .invoice!.status
                                                  .toString() !=
                                              "null")
                                            Expanded(
                                                child: Align(
                                              alignment: Alignment.centerRight,
                                              child: Container(
                                                padding: EdgeInsets.symmetric(
                                                    vertical: 1.h,
                                                    horizontal: 10.w),
                                                decoration: BoxDecoration(
                                                    color: invoiceHistoryController
                                                                .invoiceViewList[
                                                                    0]
                                                                .message!
                                                                .invoice!
                                                                .status
                                                                .toString()
                                                                .toLowerCase() ==
                                                            "paid"
                                                        ? Color.fromARGB(
                                                            255, 4, 136, 92)
                                                        : invoiceHistoryController
                                                                    .invoiceViewList[
                                                                        0]
                                                                    .message!
                                                                    .invoice!
                                                                    .status
                                                                    .toString()
                                                                    .toLowerCase() ==
                                                                "unpaid"
                                                            ? AppColors
                                                                .pendingColor
                                                            : AppColors
                                                                .redColor,
                                                    borderRadius: Dimensions
                                                            .kBorderRadius *
                                                        2),
                                                child: Text(
                                                    "${invoiceHistoryController.invoiceViewList[0].message!.invoice!.status.toString()}",
                                                    maxLines: 1,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    style: context.t.bodyMedium
                                                        ?.copyWith(
                                                            color: AppColors
                                                                .whiteColor)),
                                              ),
                                            )),
                                        ],
                                      ),
                                      Container(
                                        width: double.maxFinite,
                                        height: .5,
                                        color:
                                            AppThemes.getSliderInactiveColor(),
                                      ),
                                      Row(
                                        children: [
                                          Text(
                                            "Invoice Number",
                                            style: context.t.displayMedium
                                                ?.copyWith(
                                                    color: AppThemes
                                                        .getParagraphColor()),
                                          ),
                                          Expanded(
                                              child: Align(
                                            alignment: Alignment.centerRight,
                                            child: Text(
                                                "${invoiceHistoryController.invoiceViewList[0].message!.invoice!.invoiceNumber.toString()}",
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                                style: context.t.bodyMedium),
                                          )),
                                        ],
                                      ),
                                      Container(
                                        width: double.maxFinite,
                                        height: .5,
                                        color:
                                            AppThemes.getSliderInactiveColor(),
                                      ),
                                      Row(
                                        children: [
                                          Text(
                                            "Invoice Issue Date",
                                            style: context.t.displayMedium
                                                ?.copyWith(
                                                    color: AppThemes
                                                        .getParagraphColor()),
                                          ),
                                          Expanded(
                                              child: Align(
                                            alignment: Alignment.centerRight,
                                            child: Text(
                                                "${DateFormat('dd-MM-yyyy').format(DateTime.parse(invoiceHistoryController.invoiceViewList[0].message!.invoice!.createdAt.toString()))}",
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                                style: context.t.bodyMedium),
                                          )),
                                        ],
                                      ),
                                      Container(
                                        width: double.maxFinite,
                                        height: .5,
                                        color:
                                            AppThemes.getSliderInactiveColor(),
                                      ),
                                      Row(
                                        children: [
                                          Text(
                                            "Percent Charge (${double.parse(invoiceHistoryController.invoiceViewList[0].message!.invoice!.percentage.toString()).toStringAsFixed(1)}%)",
                                            style: context.t.displayMedium
                                                ?.copyWith(
                                                    color: AppThemes
                                                        .getParagraphColor()),
                                          ),
                                          Expanded(
                                              child: Align(
                                            alignment: Alignment.centerRight,
                                            child: Text(
                                                "${double.parse(invoiceHistoryController.invoiceViewList[0].message!.invoice!.chargePercentage.toString()).toStringAsFixed(2)} ${invoiceHistoryController.currency}",
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                                style: context.t.bodyMedium
                                                    ?.copyWith(
                                                        color: AppColors
                                                            .redColor)),
                                          )),
                                        ],
                                      ),
                                      Container(
                                        width: double.maxFinite,
                                        height: .5,
                                        color:
                                            AppThemes.getSliderInactiveColor(),
                                      ),
                                      Row(
                                        children: [
                                          Text(
                                            "Fixed Charge",
                                            style: context.t.displayMedium
                                                ?.copyWith(
                                                    color: AppThemes
                                                        .getParagraphColor()),
                                          ),
                                          Expanded(
                                              child: Align(
                                            alignment: Alignment.centerRight,
                                            child: Text(
                                                "${double.parse(invoiceHistoryController.invoiceViewList[0].message!.invoice!.chargeFixed.toString()).toStringAsFixed(2)} ${invoiceHistoryController.currency}",
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                                style: context.t.bodyMedium
                                                    ?.copyWith(
                                                        color: AppColors
                                                            .redColor)),
                                          )),
                                        ],
                                      ),
                                      Container(
                                        width: double.maxFinite,
                                        height: .5,
                                        color:
                                            AppThemes.getSliderInactiveColor(),
                                      ),
                                      Row(
                                        children: [
                                          Text(
                                            "Overall Charge",
                                            style: context.t.displayMedium
                                                ?.copyWith(
                                                    color: AppThemes
                                                        .getParagraphColor()),
                                          ),
                                          Expanded(
                                              child: Align(
                                            alignment: Alignment.centerRight,
                                            child: Text(
                                                "${double.parse(invoiceHistoryController.invoiceViewList[0].message!.invoice!.charge.toString()).toStringAsFixed(2)} ${invoiceHistoryController.currency}",
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                                style: context.t.bodyMedium
                                                    ?.copyWith(
                                                        color: AppColors
                                                            .redColor)),
                                          )),
                                        ],
                                      ),
                                    ],
                                  )),
                      VSpace(48.h),
                      if (invoiceHistoryController.invoiceViewList.isNotEmpty)
                        if (invoiceHistoryController.invoiceViewList[0].message!.invoice != null)
                          Stack(
                            alignment: Alignment.bottomCenter,
                            children: [
                              Center(
                                child: CustomPaint(
                                  size: Size(220.h, 70.h),
                                  painter: TrianglePainter(),
                                ),
                              ),
                              Text(
                                "Invoice Payment",
                                style: context.t.bodyMedium,
                              ),
                            ],
                          ),
                      if (invoiceHistoryController.invoiceViewList.isNotEmpty)
                        Container(
                            width: double.maxFinite,
                            height: 260.h,
                            padding: EdgeInsets.symmetric(
                                horizontal: 16.w, vertical: 20.h),
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
                                      "Requester Name",
                                      style: context.t.displayMedium?.copyWith(
                                          color: AppThemes.getParagraphColor()),
                                    ),
                                    Expanded(
                                        child: Align(
                                      alignment: Alignment.centerRight,
                                      child: Text(
                                          "${HiveHelp.read(Keys.userFullName)}",
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: context.t.bodyMedium),
                                    )),
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
                                      "Amount",
                                      style: context.t.displayMedium?.copyWith(
                                          color: AppThemes.getParagraphColor()),
                                    ),
                                    Expanded(
                                        child: Align(
                                      alignment: Alignment.centerRight,
                                      child: Text(
                                          "${invoiceHistoryController.invoiceViewList[0].message!.invoice!.grandTotal.toString()} ${invoiceHistoryController.currency}",
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: context.t.bodyMedium),
                                    )),
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
                                      "Note",
                                      style: context.t.displayMedium?.copyWith(
                                          color: AppThemes.getParagraphColor()),
                                    ),
                                    HSpace(20.w),
                                    Expanded(
                                        child: Align(
                                      alignment: Alignment.centerRight,
                                      child: Text(
                                          "${invoiceHistoryController.invoiceViewList[0].message!.invoice!.note.toString().replaceAll("null", "")}",
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: context.t.bodyMedium),
                                    )),
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
                                      "Status",
                                      style: context.t.displayMedium?.copyWith(
                                          color: AppThemes.getParagraphColor()),
                                    ),
                                    HSpace(20.w),
                                    if (invoiceHistoryController.invoiceViewList[0].message!.invoice!
                                            .status
                                            .toString() !=
                                        "null")
                                      Expanded(
                                          child: Align(
                                        alignment: Alignment.centerRight,
                                        child: Container(
                                          padding: EdgeInsets.symmetric(
                                              vertical: 1.h, horizontal: 10.w),
                                          decoration: BoxDecoration(
                                              color: invoiceHistoryController
                                                          .invoiceViewList[0]
                                                          .message!
                                                          .invoice!
                                                          .status
                                                          .toString()
                                                          .toLowerCase() ==
                                                      "paid"
                                                  ? Color.fromARGB(
                                                      255, 4, 136, 92)
                                                  : invoiceHistoryController
                                                              .invoiceViewList[
                                                                  0]
                                                              .message!
                                                              .invoice!
                                                              .status
                                                              .toString()
                                                              .toLowerCase() ==
                                                          "unpaid"
                                                      ? AppColors.pendingColor
                                                      : AppColors.redColor,
                                              borderRadius:
                                                  Dimensions.kBorderRadius * 2),
                                          child: Text(
                                              "${invoiceHistoryController.invoiceViewList[0].message!.invoice!.status.toString()}",
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              style: context.t.bodyMedium
                                                  ?.copyWith(
                                                      color: AppColors
                                                          .whiteColor)),
                                        ),
                                      )),
                                  ],
                                ),
                              ],
                            )),
                      VSpace(40.h),
                    ],
                  ),
                ),
              ),
      );
    });
  }
}

class TrianglePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    Paint fillPaint = Paint()
      ..color = AppThemes.getDarkCardColor()
      ..style = PaintingStyle.fill;

    Paint borderPaint = Paint()
      ..color = AppThemes.getSliderInactiveColor()
      ..strokeWidth = Get.isDarkMode ? 0.00 : .5
      ..style = PaintingStyle.stroke;

    Path path = Path();
    path.moveTo(size.width / 2, 0);
    path.lineTo(0, size.height);
    path.lineTo(size.width, size.height);
    path.close();

    canvas.drawPath(path, fillPaint);
    canvas.drawLine(
        Offset(0, size.height), Offset(size.width / 2, 0), borderPaint);
    canvas.drawLine(Offset(size.width, size.height), Offset(size.width / 2, 0),
        borderPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}
