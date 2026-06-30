import 'package:flutter/material.dart';
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
import '../../widgets/app_button.dart';
import '../../widgets/app_custom_dropdown.dart';
import '../../widgets/custom_appbar.dart';
import '../../widgets/custom_textfield.dart';
import '../../widgets/search_dialog.dart';
import '../../widgets/spacing.dart';
import '../home/home_screen.dart';

class DisputeHistoryScreen extends StatelessWidget {
  const DisputeHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    TextTheme t = Theme.of(context).textTheme;
    var storedLanguage = HiveHelp.read(Keys.languageData) ?? {};
    return GetBuilder<DisputeHistoryController>(
      builder: (disputeHistoryController) {
        return Scaffold(
          appBar: buildAppbar(
            storedLanguage,
            context,
            disputeHistoryController,
          ),
          body: RefreshIndicator(
            color: AppColors.mainColor,
            onRefresh: () async {
              disputeHistoryController.refreshSearchData();
              disputeHistoryController.resetDataAfterSearching(
                isFromOnRefreshIndicator: true,
              );
              await disputeHistoryController.getDisputeList(
                page: 1,
                utr: "",
                status: "",
                created_at: "",
              );
            },
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              controller: disputeHistoryController.scrollController,
              child: Padding(
                padding: Dimensions.kDefaultPadding,
                child: Column(
                  children: [
                    VSpace(20.h),
                    disputeHistoryController.isLoading
                        ? buildTransactionLoader(
                          itemCount: 20,
                          isReverseColor: true,
                        )
                        : disputeHistoryController.disputeList.isEmpty
                        ? Helpers.notFound()
                        : ListView.builder(
                          physics: const NeverScrollableScrollPhysics(),
                          shrinkWrap: true,
                          itemCount:
                              disputeHistoryController.disputeList.length,
                          itemBuilder: (context, i) {
                            var data = disputeHistoryController.disputeList[i];
                            return Ink(
                              width: double.maxFinite,
                              padding: EdgeInsets.symmetric(vertical: 10.h),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    width: 58.h,
                                    height: 58.h,
                                    margin: EdgeInsets.only(left: 15.w),
                                    padding: EdgeInsets.all(15.h),
                                    decoration: BoxDecoration(
                                      color:
                                          Get.isDarkMode
                                              ? AppColors.darkCardColor
                                              : AppColors.whiteColor,
                                      shape: BoxShape.circle,
                                    ),
                                    child: Image.asset(
                                      checkStatusIcon(data.status),
                                      width: 28.w,
                                      height: 26.h,
                                    ),
                                  ),
                                  HSpace(12.w),
                                  Flexible(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Text(
                                              data.disputeFor.toString(),
                                              maxLines: 1,
                                              overflow: TextOverflow.fade,
                                              style: t.bodyMedium?.copyWith(
                                                fontSize: 17.sp,
                                              ),
                                            ),
                                            Spacer(),
                                            Text(
                                              data.createdTime == null
                                                  ? ""
                                                  : DateFormat(
                                                    'dd MMM yyyy',
                                                  ).format(
                                                    DateTime.parse(
                                                      data.createdTime
                                                          .toString(),
                                                    ),
                                                  ),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              style: t.bodySmall?.copyWith(
                                                color:
                                                    AppThemes.getBlack50Color(),
                                              ),
                                            ),
                                          ],
                                        ),
                                        Align(
                                          alignment: Alignment.centerLeft,
                                          child: SelectableText(
                                            "${data.disputeId}",
                                            maxLines: 1,
                                            style: t.bodySmall?.copyWith(
                                              fontSize: 14.sp,
                                            ),
                                          ),
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
                            );
                          },
                        ),
                    if (disputeHistoryController.isLoadMore == true)
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
    DisputeHistoryController disputeHistoryController,
  ) {
    return CustomAppBar(
      title: storedLanguage['Dispute History'] ?? "Dispute History",
      leading: BottomNavController.to.selectedIndex == 2 ? SizedBox() : null,
      actions: [
        InkResponse(
          onTap: () {
            searchDialog(
              context: context,
              children: [
                VSpace(24.h),
                CustomTextField(
                  hintext: storedLanguage['Dispute ID'] ?? "Dispute ID",
                  controller: disputeHistoryController.utrEditingCtrlr,
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
                            disputeHistoryController
                                .dateTimeEditingCtrlr
                                .text = DateFormat('yyyy-MM-dd').format(value);
                          }
                        });
                      },
                      child: IgnorePointer(
                        ignoring: true,
                        child: CustomTextField(
                          hintext: storedLanguage['Date'] ?? "Date",
                          controller:
                              disputeHistoryController.dateTimeEditingCtrlr,
                          contentPadding: EdgeInsets.only(left: 20.w),
                        ),
                      ),
                    ),
                    InkResponse(
                      onTap: () {
                        disputeHistoryController.dateTimeEditingCtrlr.clear();
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
                GetBuilder<DisputeHistoryController>(
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
                            disputeHistoryController.statusList
                                .map((e) => e)
                                .toList(),
                        selectedValue: disputeHistoryController.selectedStatus,
                        onChanged: (v) {
                          disputeHistoryController.selectedStatus = v;
                          disputeHistoryController.update();
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
                  text: storedLanguage['Search Now'] ?? "Search Now",
                  onTap: () async {
                    disputeHistoryController.resetDataAfterSearching(
                      isFromOnRefreshIndicator: true,
                    );
                    Get.back();
                    await disputeHistoryController.getDisputeList(
                      page: 1,
                      utr: disputeHistoryController.utrEditingCtrlr.text,
                      status: disputeHistoryController.selectedStatus,
                      created_at:
                          disputeHistoryController.dateTimeEditingCtrlr.text,
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

  checkStatusIcon(dynamic status) {
    if (status == "Closed") {
      return "$rootImageDir/closed.webp";
    } else if (status == "Solved") {
      return "$rootImageDir/tick-mark.webp";
    } else {
      return "$rootImageDir/open.webp";
    }
  }
}
