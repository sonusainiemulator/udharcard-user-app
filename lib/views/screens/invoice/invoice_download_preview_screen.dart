import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:paysecure/config/dimensions.dart';
import 'package:paysecure/views/widgets/custom_appbar.dart';
import 'package:paysecure/views/widgets/text_theme_extension.dart';
import '../../../config/app_colors.dart';
import '../../../themes/themes.dart';
import '../../../utils/services/localstorage/hive.dart';
import '../../../utils/services/localstorage/keys.dart';
import '../../widgets/expandable_text.dart';
import '../../widgets/spacing.dart';

class InvoiceDownloadPreviewScreen extends StatelessWidget {
  const InvoiceDownloadPreviewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    var storedLanguage = HiveHelp.read(Keys.languageData) ?? {};
    return Scaffold(
      backgroundColor:
          Get.isDarkMode ? AppColors.darkBgColor : AppColors.scaffoldColor,
      appBar: CustomAppBar(
          title: storedLanguage['Invoice Preview'] ?? "Invoice Preview"),
      body: SingleChildScrollView(
        child: Padding(
          padding: Dimensions.kDefaultPadding,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              VSpace(40.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    width: 37.h,
                    height: 37.h,
                    decoration: BoxDecoration(
                      color: Get.isDarkMode
                          ? AppColors.mainColor
                          : AppColors.blackColor,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Stack(
                        clipBehavior: Clip.none,
                        children: [
                          Positioned(
                            left: 7.w,
                            top: -3.h,
                            child: Row(
                              children: [
                                Text(
                                  'Ri',
                                  style: context.t.titleLarge!.copyWith(
                                    fontSize: 32.sp,
                                    fontWeight: FontWeight.w700,
                                    color: Get.isDarkMode == false
                                        ? AppColors.mainColor
                                        : AppColors.whiteColor,
                                  ),
                                ),
                                HSpace(1),
                                Text(
                                  'pple Pay',
                                  style: context.t.titleLarge!.copyWith(
                                      fontSize: 32.sp,
                                      fontWeight: FontWeight.w700,
                                      color: Get.isDarkMode == false
                                          ? AppColors.mainColor
                                          : AppColors.whiteColor),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Text(
                    "Invoice",
                    style: context.t.titleSmall
                        ?.copyWith(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              VSpace(27.h),
              Row(
                children: [
                  Text(
                    "Pay to",
                    style: context.t.displayMedium
                        ?.copyWith(color: AppThemes.getParagraphColor()),
                  ),
                  HSpace(5.w),
                  Expanded(
                    child: LayoutBuilder(builder: (context, constraints) {
                      return Row(
                        children: [
                          ...List.generate(
                              (constraints.maxWidth / 3.5).floor(),
                              (index) => Container(
                                    height: 1,
                                    margin:
                                        EdgeInsets.only(left: 2.w, top: 6.h),
                                    width: (constraints.maxWidth / 100),
                                    color: Get.isDarkMode
                                        ? AppColors.black60
                                        : Color(0xffD1D1D1),
                                  )),
                        ],
                      );
                    }),
                  ),
                  ExpandableText(text: "example@gmail.com", textWidth: 24),
                ],
              ),
              VSpace(23.h),
              Row(
                children: [
                  Text(
                    "Invoiced To:",
                    style: context.t.displayMedium
                        ?.copyWith(color: AppThemes.getParagraphColor()),
                  ),
                  HSpace(5.w),
                  Expanded(
                    child: LayoutBuilder(builder: (context, constraints) {
                      return Row(
                        children: [
                          ...List.generate(
                              (constraints.maxWidth / 3.3).floor(),
                              (index) => Container(
                                    height: 1,
                                    margin:
                                        EdgeInsets.only(left: 2.w, top: 6.h),
                                    width: (constraints.maxWidth / 100),
                                    color: Get.isDarkMode
                                        ? AppColors.black60
                                        : Color(0xffD1D1D1),
                                  )),
                        ],
                      );
                    }),
                  ),
                  ExpandableText(text: "caped@mailinator.com", textWidth: 24),
                ],
              ),
              VSpace(23.h),
              Row(
                children: [
                  Text(
                    "Invoice Number",
                    style: context.t.displayMedium
                        ?.copyWith(color: AppThemes.getParagraphColor()),
                  ),
                  HSpace(5.w),
                  Expanded(
                    child: LayoutBuilder(builder: (context, constraints) {
                      return Row(
                        children: [
                          ...List.generate(
                              (constraints.maxWidth / 3.5).floor(),
                              (index) => Container(
                                    height: 1,
                                    margin:
                                        EdgeInsets.only(left: 2.w, top: 6.h),
                                    width: (constraints.maxWidth / 100),
                                    color: Get.isDarkMode
                                        ? AppColors.black60
                                        : Color(0xffD1D1D1),
                                  )),
                        ],
                      );
                    }),
                  ),
                  ExpandableText(text: "9837477347834", textWidth: 24),
                ],
              ),
              VSpace(23.h),
              Row(
                children: [
                  Text(
                    "Date",
                    style: context.t.displayMedium
                        ?.copyWith(color: AppThemes.getParagraphColor()),
                  ),
                  HSpace(5.w),
                  Expanded(
                    child: LayoutBuilder(builder: (context, constraints) {
                      return Row(
                        children: [
                          ...List.generate(
                              (constraints.maxWidth / 4.4).floor(),
                              (index) => Container(
                                    height: 1,
                                    margin:
                                        EdgeInsets.only(left: 2.w, top: 6.h),
                                    width: (constraints.maxWidth / 100),
                                    color: Get.isDarkMode
                                        ? AppColors.black60
                                        : Color(0xffD1D1D1),
                                  )),
                        ],
                      );
                    }),
                  ),
                  ExpandableText(text: "09/09/2024", textWidth: 24),
                ],
              ),
              VSpace(40.h),
              Container(
                height: 46.h,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: AppThemes.getDarkCardColor(),
                  borderRadius:
                      BorderRadius.vertical(top: Radius.circular(12.r)),
                ),
                alignment: Alignment.center,
                child: Text("Invoice Summery", style: context.t.bodyMedium),
              ),
              CustomTable(),
              VSpace(40.h),
            ],
          ),
        ),
      ),
    );
  }
}

class CustomTable extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Table(
      border: TableBorder(
        horizontalInside: BorderSide(
          width: 1,
          color: AppColors.black80,
        ),
        verticalInside: BorderSide(width: 1, color: AppColors.black80),
        left: BorderSide(width: 1, color: AppColors.black80),
        right: BorderSide(width: 1, color: AppColors.black80),
        bottom: BorderSide(width: 1, color: AppColors.black80),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(19.r)),
      ),
      children: [
        TableRow(
          children: [
            TableCell(
                child: Padding(
              padding: EdgeInsets.all(12.0.r),
              child: Text(
                "Title",
                style: context.t.displayMedium
                    ?.copyWith(color: AppThemes.getParagraphColor()),
              ),
            )),
            TableCell(
                child: Padding(
              padding: EdgeInsets.all(12.0.r),
              child: Text(
                "Pay Secure",
                style: context.t.displayMedium
                    ?.copyWith(color: AppThemes.getParagraphColor()),
              ),
            )),
          ],
        ),
        TableRow(
          children: [
            TableCell(
                child: Padding(
              padding: EdgeInsets.all(12.0.r),
              child: Text(
                "Price",
                style: context.t.displayMedium
                    ?.copyWith(color: AppThemes.getParagraphColor()),
              ),
            )),
            TableCell(
                child: Padding(
              padding: EdgeInsets.all(12.0.r),
              child: Text(
                "\$75",
                style: context.t.displayMedium
                    ?.copyWith(color: AppThemes.getParagraphColor()),
              ),
            )),
          ],
        ),
        TableRow(
          children: [
            TableCell(
                child: Padding(
              padding: EdgeInsets.all(12.0.r),
              child: Text(
                "Quantity",
                style: context.t.displayMedium
                    ?.copyWith(color: AppThemes.getParagraphColor()),
              ),
            )),
            TableCell(
                child: Padding(
              padding: EdgeInsets.all(12.0.r),
              child: Text(
                "1",
                style: context.t.displayMedium
                    ?.copyWith(color: AppThemes.getParagraphColor()),
              ),
            )),
          ],
        ),
        TableRow(
          children: [
            TableCell(
                verticalAlignment: TableCellVerticalAlignment.middle,
                child: Padding(
                  padding: EdgeInsets.all(12.0.r),
                  child: Text(
                    "Description",
                    style: context.t.displayMedium
                        ?.copyWith(color: AppThemes.getParagraphColor()),
                  ),
                )),
            TableCell(
                child: Padding(
              padding: EdgeInsets.all(12.0.r),
              child: Text(
                "Lorem Ipsum create the industry.",
                style: context.t.displayMedium
                    ?.copyWith(color: AppThemes.getParagraphColor()),
              ),
            )),
          ],
        ),
      ],
    );
  }
}
