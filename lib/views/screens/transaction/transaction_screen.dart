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

class TransactionScreen extends StatefulWidget {
  final bool? isFromHomePage;
  final bool? isFromWallet;
  const TransactionScreen({
    super.key,
    this.isFromHomePage = false,
    this.isFromWallet = false,
  });

  @override
  State<TransactionScreen> createState() => _TransactionScreenState();
}

class _TransactionScreenState extends State<TransactionScreen> {
  String _selectedFilter = 'All';

  Widget _buildFilterTab(String title, bool isSelected) {
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedFilter = title;
          });
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: EdgeInsets.symmetric(vertical: 8.h),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.mainColor : Colors.transparent,
            borderRadius: BorderRadius.circular(8.r),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: AppColors.mainColor.withValues(alpha: 0.3),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13.sp,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
              color: isSelected
                  ? Colors.white
                  : (Get.isDarkMode ? Colors.white70 : Colors.black87),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    TextTheme t = Theme.of(context).textTheme;
    var storedLanguage = HiveHelp.read(Keys.languageData) ?? {};
    return GetBuilder<TransactionController>(
      builder: (transactionCtrl) {
        final filteredList = transactionCtrl.transactionList.where((item) {
          if (_selectedFilter == 'Purchases') {
            return item.type.toString().trim() == '-';
          } else if (_selectedFilter == 'Payments') {
            return item.type.toString().trim() == '+';
          }
          return true;
        }).toList();

        return PopScope(
          canPop: false,
          onPopInvokedWithResult: (didPop, result) {
            if (didPop) {
              return;
            }
            Get.back();
          },
          child: Scaffold(
            appBar: buildAppbar(
              storedLanguage,
              context,
              transactionCtrl,
              widget.isFromHomePage,
            ),
            body: RefreshIndicator(
              color: AppColors.mainColor,
              onRefresh: () async {
                transactionCtrl.selectedType = "All Type";
                transactionCtrl.transactionIdEditingCtrlr.clear();
                transactionCtrl.dateTimeEditingCtrlr.clear();
                transactionCtrl.resetDataAfterSearching(
                  isFromOnRefreshIndicator: true,
                );
                await transactionCtrl.getTransactionList(
                  page: 1,
                  type: "",
                  created_at: "",
                  utr: "",
                );
              },
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                controller: transactionCtrl.scrollController,
                child: Padding(
                  padding: Dimensions.kDefaultPadding,
                  child: Column(
                    children: [
                      VSpace(12.h),
                      // Segmented Filter Bar: All | Purchases | Payments
                      Container(
                        padding: EdgeInsets.all(4.w),
                        decoration: BoxDecoration(
                          color: Get.isDarkMode
                              ? AppColors.darkCardColor
                              : Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(12.r),
                          border: Border.all(
                            color: Get.isDarkMode
                                ? Colors.white12
                                : Colors.grey.shade300,
                            width: 1,
                          ),
                        ),
                        child: Row(
                          children: [
                            _buildFilterTab("All", _selectedFilter == 'All'),
                            _buildFilterTab(
                              "Purchases",
                              _selectedFilter == 'Purchases',
                            ),
                            _buildFilterTab(
                              "Payments",
                              _selectedFilter == 'Payments',
                            ),
                          ],
                        ),
                      ),
                      VSpace(16.h),
                      transactionCtrl.isLoading
                          ? buildTransactionLoader(
                            itemCount: 20,
                            isReverseColor: true,
                          )
                          : filteredList.isEmpty
                          ? Helpers.notFound()
                          : ListView.builder(
                            physics: const NeverScrollableScrollPhysics(),
                            shrinkWrap: true,
                            itemCount: filteredList.length,
                            itemBuilder: (context, i) {
                              var data = filteredList[i];
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
                                                    data.transactionId ?? '',
                                                    textAlign: TextAlign.center,
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
                                                      : AppColors.blackColor,
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
                                              " ${data.currency.toString().replaceAll("null", "")}",
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
                                        Text(
                                          storedLanguage['Remarks'] ??
                                              "Remarks",
                                          style: t.bodyMedium?.copyWith(
                                            color:
                                                Get.isDarkMode
                                                    ? AppColors.whiteColor
                                                    : AppColors.blackColor,
                                          ),
                                        ),
                                        Text(
                                          data.remarks == null
                                              ? "-"
                                              : data.remarks.toString(),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: t.bodySmall,
                                        ),
                                        VSpace(12.h),
                                      ],
                                    ),
                                  );
                                },
                                child: Builder(
                                  builder: (context) {
                                    final isPayment = data.type.toString().trim() == '+';
                                    final rawRemarks = data.remarks?.toString() ?? '';
                                    final storeTitle = (rawRemarks.isNotEmpty && rawRemarks != 'null')
                                        ? rawRemarks
                                        : (isPayment ? 'Udhar Payment' : 'Store Purchase');

                                    String formattedDate = data.createdTime.toString();
                                    try {
                                      final dt = DateTime.parse(data.createdTime.toString());
                                      formattedDate = DateFormat('dd MMM yyyy, hh:mm a').format(dt);
                                    } catch (_) {}

                                    return Ink(
                                      width: double.maxFinite,
                                      padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 4.w),
                                      child: Row(
                                        crossAxisAlignment: CrossAxisAlignment.center,
                                        children: [
                                          Container(
                                            width: 44.h,
                                            height: 44.h,
                                            decoration: BoxDecoration(
                                              color: isPayment
                                                  ? AppColors.greenColor.withValues(alpha: .12)
                                                  : AppColors.redColor.withValues(alpha: .12),
                                              shape: BoxShape.circle,
                                            ),
                                            child: Icon(
                                              isPayment ? Icons.arrow_downward_rounded : Icons.storefront_rounded,
                                              color: isPayment ? AppColors.greenColor : AppColors.redColor,
                                              size: 22.sp,
                                            ),
                                          ),
                                          HSpace(12.w),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  storeTitle,
                                                  maxLines: 1,
                                                  overflow: TextOverflow.ellipsis,
                                                  style: t.bodyMedium?.copyWith(
                                                    fontWeight: FontWeight.w600,
                                                    fontSize: 14.sp,
                                                  ),
                                                ),
                                                VSpace(4.h),
                                                Row(
                                                  children: [
                                                    Container(
                                                      padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                                                      decoration: BoxDecoration(
                                                        color: isPayment
                                                            ? AppColors.greenColor.withValues(alpha: .12)
                                                            : Colors.orange.withValues(alpha: .15),
                                                        borderRadius: BorderRadius.circular(4.r),
                                                      ),
                                                      child: Text(
                                                        isPayment ? "Payment" : "Purchase",
                                                        style: TextStyle(
                                                          fontSize: 10.sp,
                                                          fontWeight: FontWeight.w600,
                                                          color: isPayment ? AppColors.greenColor : Colors.deepOrange,
                                                        ),
                                                      ),
                                                    ),
                                                    HSpace(6.w),
                                                    Expanded(
                                                      child: Text(
                                                        formattedDate,
                                                        maxLines: 1,
                                                        overflow: TextOverflow.ellipsis,
                                                        style: t.bodySmall?.copyWith(
                                                          fontSize: 11.sp,
                                                          color: AppThemes.getBlack50Color(),
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ),
                                          HSpace(8.w),
                                          Column(
                                            crossAxisAlignment: CrossAxisAlignment.end,
                                            children: [
                                              Text(
                                                "${isPayment ? '+' : '-'} ₹${Helpers.numberFormatWithAsFixed2('', data.amount.toString())}",
                                                style: t.bodyMedium?.copyWith(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 14.sp,
                                                  color: isPayment ? AppColors.greenColor : AppColors.redColor,
                                                ),
                                              ),
                                              VSpace(4.h),
                                              Text(
                                                "Bal: Settled",
                                                style: t.bodySmall?.copyWith(
                                                  fontSize: 10.sp,
                                                  color: AppThemes.getBlack50Color(),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                ),
                              );
                            },
                          ),
                      if (transactionCtrl.isLoadMore == true)
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
  }

  CustomAppBar buildAppbar(
    storedLanguage,
    BuildContext context,
    TransactionController transactionCtrl,
    isFromHomePage,
  ) {
    return CustomAppBar(
      title: storedLanguage['Transaction'] ?? "Transaction",
      leading: BottomNavController.to.selectedIndex == 1 ? SizedBox() : null,
      actions: [
        InkResponse(
          onTap: () {
            searchDialog(
              context: context,
              children: [
                CustomTextField(
                  hintext: "Transaction ID",
                  controller: transactionCtrl.transactionIdEditingCtrlr,
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
                            transactionCtrl
                                .dateTimeEditingCtrlr
                                .text = DateFormat('yyyy-MM-dd').format(value);
                          }
                        });
                      },
                      child: IgnorePointer(
                        ignoring: true,
                        child: CustomTextField(
                          hintext: "Date",
                          controller: transactionCtrl.dateTimeEditingCtrlr,
                          contentPadding: EdgeInsets.only(left: 20.w),
                        ),
                      ),
                    ),
                    InkResponse(
                      onTap: () {
                        transactionCtrl.dateTimeEditingCtrlr.clear();
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
                GetBuilder<TransactionController>(
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
                        items: transactionCtrl.typeList.map((e) => e).toList(),
                        selectedValue: transactionCtrl.selectedType,
                        onChanged: (v) {
                          transactionCtrl.selectedType = v;
                          transactionCtrl.update();
                        },
                        hint: storedLanguage['Type'] ?? "Type",
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
                    transactionCtrl.resetDataAfterSearching(
                      isFromOnRefreshIndicator: true,
                    );
                    Get.back();
                    await transactionCtrl.getTransactionList(
                      page: 1,
                      type:
                          transactionCtrl.selectedType == "All Type"
                              ? ""
                              : transactionCtrl.selectedType,

                      created_at: transactionCtrl.dateTimeEditingCtrlr.text,
                      utr: transactionCtrl.transactionIdEditingCtrlr.text,
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
