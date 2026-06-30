import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:paysecure/config/dimensions.dart';
import 'package:paysecure/controllers/app_controller.dart';
import 'package:paysecure/controllers/card_controller.dart';
import 'package:paysecure/routes/routes_name.dart';
import 'package:paysecure/utils/app_constants.dart';
import 'package:paysecure/utils/services/helpers.dart';
import 'package:paysecure/views/screens/card/virtual_card_form_screen.dart';
import 'package:paysecure/views/widgets/custom_appbar.dart';
import 'package:paysecure/views/widgets/mediaquery_extension.dart';
import 'package:paysecure/views/widgets/spacing.dart';
import 'package:paysecure/views/widgets/text_theme_extension.dart';
import '../../../config/app_colors.dart';
import '../../../controllers/card_transaction_controller.dart';
import '../../../themes/themes.dart';
import '../../../utils/services/localstorage/hive.dart';
import '../../../utils/services/localstorage/keys.dart';
import '../../widgets/app_button.dart';
import '../../widgets/custom_textfield.dart';

class VirtualCardScreen extends StatelessWidget {
  const VirtualCardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    TextTheme t = Theme.of(context).textTheme;

    return GetBuilder<AppController>(
      builder: (appCtrl) {
        var storedLanguage = HiveHelp.read(Keys.languageData) ?? {};
        return GetBuilder<CardController>(
          builder: (cardCtrl) {
            return Scaffold(
              appBar: CustomAppBar(
                title: storedLanguage['Virtual Card'] ?? "Virtual Card",
                leading: const SizedBox(),
              ),
              body: RefreshIndicator(
                color: AppColors.mainColor,
                onRefresh: () async {
                  await cardCtrl.getVirtualCards(isFromRefreshIndicator: true);
                },
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: Padding(
                    padding: Dimensions.kDefaultPadding,
                    child:
                        cardCtrl.isLoading
                            ? SizedBox(
                              height: Dimensions.screenHeight,
                              width: Dimensions.screenWidth,
                              child: Helpers.appLoader(),
                            )
                            : Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                VSpace(30.h),
                                if (cardCtrl.virtualCardFormList.isNotEmpty)
                                  if (cardCtrl.virtualCardFormList[0].status
                                          .toString() ==
                                      "2")
                                    Padding(
                                      padding: EdgeInsets.only(bottom: 30.h),
                                      child: InkWell(
                                        borderRadius: BorderRadius.circular(
                                          6.r,
                                        ),
                                        onTap: () {
                                          showDialog<void>(
                                            barrierDismissible: true,
                                            context: context,
                                            builder: (BuildContext context) {
                                              return GetBuilder<CardController>(
                                                builder: (profileCtrl) {
                                                  return Padding(
                                                    padding:
                                                        EdgeInsets.symmetric(
                                                          vertical: 60.h,
                                                          horizontal: 30.w,
                                                        ),
                                                    child: Material(
                                                      // Wrap with Material
                                                      elevation: 0,
                                                      type:
                                                          MaterialType
                                                              .transparency,
                                                      child: Center(
                                                        child: Column(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .center,
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .start,
                                                          children: [
                                                            Container(
                                                              width:
                                                                  context
                                                                      .mQuery
                                                                      .width,
                                                              padding:
                                                                  Dimensions
                                                                      .kDefaultPadding,
                                                              decoration: BoxDecoration(
                                                                color:
                                                                    AppThemes.getDarkBgColor(),
                                                                borderRadius:
                                                                    BorderRadius.circular(
                                                                      32.r,
                                                                    ),
                                                              ),
                                                              child: Column(
                                                                crossAxisAlignment:
                                                                    CrossAxisAlignment
                                                                        .start,
                                                                children: [
                                                                  VSpace(20.h),
                                                                  Row(
                                                                    mainAxisAlignment:
                                                                        MainAxisAlignment
                                                                            .spaceBetween,
                                                                    children: [
                                                                      Text(
                                                                        storedLanguage['Rejected reason'] ??
                                                                            "Rejected reason",
                                                                        style:
                                                                            t.displayMedium,
                                                                      ),
                                                                      InkResponse(
                                                                        onTap: () {
                                                                          Get.back();
                                                                        },
                                                                        child: Container(
                                                                          padding: EdgeInsets.all(
                                                                            7.h,
                                                                          ),
                                                                          decoration: BoxDecoration(
                                                                            color:
                                                                                AppThemes.getFillColor(),
                                                                            shape:
                                                                                BoxShape.circle,
                                                                          ),
                                                                          child: Icon(
                                                                            Icons.close,
                                                                            size:
                                                                                14.h,
                                                                            color:
                                                                                Get.isDarkMode
                                                                                    ? AppColors.whiteColor
                                                                                    : AppColors.blackColor,
                                                                          ),
                                                                        ),
                                                                      ),
                                                                    ],
                                                                  ),
                                                                  VSpace(30.h),
                                                                  Text(
                                                                    cardCtrl
                                                                        .virtualCardFormList[0]
                                                                        .reason
                                                                        .toString(),
                                                                    style:
                                                                        t.displayMedium,
                                                                  ),
                                                                  VSpace(24.h),
                                                                  GetBuilder<
                                                                    CardController
                                                                  >(
                                                                    builder: (
                                                                      cardCtrl,
                                                                    ) {
                                                                      return Material(
                                                                        color:
                                                                            Colors.transparent,
                                                                        child: AppButton(
                                                                          isLoading:
                                                                              cardCtrl.isBlocking
                                                                                  ? true
                                                                                  : false,
                                                                          onTap:
                                                                              cardCtrl.isBlocking
                                                                                  ? null
                                                                                  : () async {
                                                                                    Get.back();
                                                                                    if (cardCtrl.virtualCardFormList[0].resubmitted.toString() ==
                                                                                        "1") {
                                                                                      cardCtrl.getVirtualCards();
                                                                                      Get.to(
                                                                                        () => VirtualCardFormScreen(
                                                                                          isFromResubmit:
                                                                                              true,
                                                                                        ),
                                                                                      );
                                                                                    }
                                                                                  },
                                                                          text:
                                                                              cardCtrl.virtualCardFormList[0].resubmitted.toString() ==
                                                                                      "1"
                                                                                  ? storedLanguage['Resubmit Now'] ??
                                                                                      'Resubmit Now'
                                                                                  : storedLanguage['Close'] ??
                                                                                      "Close",
                                                                        ),
                                                                      );
                                                                    },
                                                                  ),
                                                                  VSpace(20.h),
                                                                ],
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    ),
                                                  );
                                                },
                                              );
                                            },
                                          );
                                        },
                                        child: Container(
                                          padding: EdgeInsets.symmetric(
                                            vertical: 10.h,
                                            horizontal: 4.w,
                                          ),
                                          decoration: BoxDecoration(
                                            color: AppColors.redColor
                                                .withValues(alpha: .1),
                                            border: Border.all(
                                              color: AppColors.redColor,
                                              width: .4,
                                            ),
                                            borderRadius: BorderRadius.circular(
                                              6.r,
                                            ),
                                          ),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text(
                                                storedLanguage['Your virtual card request is rejected by authority.'] ??
                                                    "Your virtual card request is rejected by authority.",
                                                style: context.t.bodySmall
                                                    ?.copyWith(
                                                      color: AppColors.redColor,
                                                      fontSize: 14.sp,
                                                    ),
                                              ),
                                              HSpace(12.w),
                                              Icon(
                                                Icons.info,
                                                size: 22.h,
                                                color: AppColors.redColor,
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                if (cardCtrl.virtualCardFormList.isNotEmpty)
                                  if (cardCtrl.virtualCardFormList[0].status
                                              .toString() ==
                                          "0" ||
                                      cardCtrl.virtualCardFormList[0].status
                                              .toString() ==
                                          "3")
                                    Padding(
                                      padding: EdgeInsets.only(bottom: 30.h),
                                      child: Container(
                                        padding: EdgeInsets.symmetric(
                                          vertical: 10.h,
                                          horizontal: 4.w,
                                        ),
                                        decoration: BoxDecoration(
                                          color: AppColors.pendingColor
                                              .withValues(alpha: .1),
                                          border: Border.all(
                                            color: AppColors.pendingColor,
                                            width: .4,
                                          ),
                                          borderRadius: BorderRadius.circular(
                                            6.r,
                                          ),
                                        ),
                                        child: Row(
                                          children: [
                                            HSpace(10.w),
                                            Image.asset(
                                              "$rootImageDir/pending.webp",
                                              color: AppColors.pendingColor,
                                              width: 18.h,
                                              height: 18.h,
                                              fit: BoxFit.cover,
                                            ),
                                            HSpace(10.w),
                                            Text(
                                              storedLanguage['Your virtual card request is pending.'] ??
                                                  "Your virtual card request is pending.",
                                              style: context.t.bodySmall
                                                  ?.copyWith(
                                                    color:
                                                        AppColors.pendingColor,
                                                  ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                cardCtrl.virtualCardList.isEmpty
                                    ? Center(
                                      child: Padding(
                                        padding: EdgeInsets.only(
                                          bottom: 90.h,
                                          top: 30.h,
                                        ),
                                        child: Text(
                                          storedLanguage['No virtual cards available.'] ??
                                              "No virtual cards available.",
                                          style: context.t.bodyLarge,
                                        ),
                                      ),
                                    )
                                    : ListView.builder(
                                      shrinkWrap: true,
                                      physics:
                                          const NeverScrollableScrollPhysics(),
                                      itemCount:
                                          cardCtrl.virtualCardList.length,
                                      itemBuilder: (context, i) {
                                        var data = cardCtrl.virtualCardList[i];
                                        return Container(
                                          width: double.maxFinite,
                                          padding: Dimensions.kDefaultPadding,
                                          margin: EdgeInsets.only(bottom: 15.h),
                                          height: 200.h,
                                          decoration: BoxDecoration(
                                            borderRadius:
                                                Dimensions.kBorderRadius * 2,
                                            image: DecorationImage(
                                              image: AssetImage(
                                                Get.isDarkMode
                                                    ? "$rootImageDir/card_design_dark.webp"
                                                    : "$rootImageDir/card_design.webp",
                                              ),
                                              fit: BoxFit.cover,
                                            ),
                                          ),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              VSpace(25.h),
                                              Row(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Flexible(
                                                    child: Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        Row(
                                                          children: [
                                                            Flexible(
                                                              child: Text(
                                                                data.nameOnCard ??
                                                                    "Card User",
                                                                maxLines: 1,
                                                                overflow:
                                                                    TextOverflow
                                                                        .ellipsis,
                                                                style: t
                                                                    .displayMedium
                                                                    ?.copyWith(
                                                                      fontSize:
                                                                          18.sp,
                                                                      color:
                                                                          AppColors
                                                                              .black30,
                                                                    ),
                                                              ),
                                                            ),
                                                            HSpace(10.w),
                                                            if (data.status ==
                                                                5)
                                                              Text(
                                                                storedLanguage['Requested block'] ??
                                                                    "Requested block",
                                                                maxLines: 1,
                                                                style: context
                                                                    .t
                                                                    .bodySmall
                                                                    ?.copyWith(
                                                                      color:
                                                                          AppColors
                                                                              .redColor,
                                                                    ),
                                                              ),
                                                          ],
                                                        ),
                                                        VSpace(5.h),
                                                        Text(
                                                          "${data.balance ?? "00938479"} ${data.currency ?? "USD"}",
                                                          maxLines: 1,
                                                          overflow:
                                                              TextOverflow
                                                                  .ellipsis,
                                                          style: context
                                                              .t
                                                              .bodyMedium
                                                              ?.copyWith(
                                                                color:
                                                                    AppColors
                                                                        .whiteColor,
                                                                fontSize: 24.sp,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w600,
                                                              ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                  SizedBox(
                                                    width: 30.w,
                                                    height: 30.h,
                                                    child: PopupMenuButton(
                                                      padding: EdgeInsets.zero,
                                                      icon: Icon(
                                                        Icons.more_vert,
                                                        size: 25.h,
                                                        color:
                                                            AppColors
                                                                .whiteColor,
                                                      ),
                                                      onSelected: (value) {},
                                                      itemBuilder: (
                                                        BuildContext _,
                                                      ) {
                                                        return [
                                                          if (data.status != 9)
                                                            if (data.status !=
                                                                    5 &&
                                                                data.status !=
                                                                    6)
                                                              PopupMenuItem(
                                                                onTap: () async {
                                                                  await buildReasonDialog(
                                                                    context,
                                                                    t,
                                                                    storedLanguage,
                                                                    cardCtrl,
                                                                    data.id
                                                                        .toString(),
                                                                  );
                                                                },
                                                                height: 40.h,
                                                                child: Text(
                                                                  'Block Card',
                                                                  style:
                                                                      context
                                                                          .t
                                                                          .displayMedium,
                                                                ),
                                                              ),
                                                          PopupMenuItem(
                                                            onTap: () async {
                                                              if (data.cardId ==
                                                                  null) {
                                                                Helpers.showSnackBar(
                                                                  msg:
                                                                      "Card ID is invalid or null",
                                                                );
                                                              } else {
                                                                CardTransactionController
                                                                    .to
                                                                    .id = data
                                                                        .cardId
                                                                        .toString();

                                                                CardTransactionController
                                                                    .to
                                                                    .resetDataAfterSearching(
                                                                      isFromOnRefreshIndicator:
                                                                          true,
                                                                    );
                                                                CardTransactionController
                                                                    .to
                                                                    .cardTransaction(
                                                                      page:
                                                                          1.toString(),
                                                                      id:
                                                                          data.cardId,
                                                                    );
                                                                Get.toNamed(
                                                                  RoutesName
                                                                      .cardTransactionScreen,
                                                                );
                                                              }
                                                            },
                                                            height: 40.h,
                                                            child: Text(
                                                              'Transaction',
                                                              style:
                                                                  context
                                                                      .t
                                                                      .displayMedium,
                                                            ),
                                                          ),
                                                        ];
                                                      },
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              Spacer(),
                                              Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Row(
                                                    children: [
                                                      Column(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        children: [
                                                          Text(
                                                            "Account Number",
                                                            style: t.bodySmall
                                                                ?.copyWith(
                                                                  fontSize:
                                                                      14.sp,
                                                                  color:
                                                                      AppColors
                                                                          .black30,
                                                                ),
                                                          ),
                                                          VSpace(5.h),
                                                          Text(
                                                            data.cardNumber ??
                                                                "45155121554155",
                                                            maxLines: 1,
                                                            overflow:
                                                                TextOverflow
                                                                    .ellipsis,
                                                            style: context
                                                                .t
                                                                .bodySmall
                                                                ?.copyWith(
                                                                  fontSize:
                                                                      16.sp,
                                                                  color:
                                                                      AppColors
                                                                          .sliderInActiveColor,
                                                                ),
                                                          ),
                                                        ],
                                                      ),
                                                      Spacer(),
                                                      Column(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .end,
                                                        children: [
                                                          Container(
                                                            padding:
                                                                EdgeInsets.only(
                                                                  left: 8.w,
                                                                  right: 8.w,
                                                                  bottom: 3.h,
                                                                ),
                                                            decoration: BoxDecoration(
                                                              color: AppColors
                                                                  .whiteColor
                                                                  .withValues(
                                                                    alpha: .1,
                                                                  ),
                                                              border: Border.all(
                                                                color:
                                                                    AppColors
                                                                        .black60,
                                                              ),
                                                              borderRadius:
                                                                  BorderRadius.circular(
                                                                    16.r,
                                                                  ),
                                                            ),
                                                            child: Row(
                                                              mainAxisSize:
                                                                  MainAxisSize
                                                                      .min,
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .center,
                                                              children: [
                                                                Text(
                                                                  "•",
                                                                  style: context.t.bodySmall?.copyWith(
                                                                    color:
                                                                        data.isActive.toString() ==
                                                                                "Active"
                                                                            ? AppColors.greenColor
                                                                            : AppColors.redColor,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w900,
                                                                  ),
                                                                ),
                                                                HSpace(4.w),
                                                                Text(
                                                                  data.isActive ??
                                                                      "Inactive",
                                                                  style: context
                                                                      .t
                                                                      .bodySmall
                                                                      ?.copyWith(
                                                                        color:
                                                                            AppColors.whiteColor,
                                                                      ),
                                                                ),
                                                              ],
                                                            ),
                                                          ),
                                                          VSpace(5.h),
                                                          Text(
                                                            "Valid Thru: " +
                                                                "${data.expiryDate == null ? "03/24" : DateFormat('MM/yy').format(DateTime.parse(data.expiryDate.toString()))}",
                                                            maxLines: 1,
                                                            overflow:
                                                                TextOverflow
                                                                    .ellipsis,
                                                            style: context
                                                                .t
                                                                .bodySmall
                                                                ?.copyWith(
                                                                  fontSize:
                                                                      16.sp,
                                                                  color:
                                                                      AppColors
                                                                          .sliderInActiveColor,
                                                                ),
                                                          ),
                                                        ],
                                                      ),
                                                    ],
                                                  ),
                                                ],
                                              ),
                                              VSpace(20.h),
                                            ],
                                          ),
                                        );
                                      },
                                    ),
                                InkWell(
                                  borderRadius: Dimensions.kBorderRadius * 2,
                                  onTap: () {
                                    if (cardCtrl.orderLock == "true") {
                                      cardCtrl.getCardOrder();
                                    } else {
                                      cardCtrl.getCardOrder();
                                      Get.toNamed(
                                        RoutesName.virtualCardFormScreen,
                                      );
                                    }
                                  },
                                  child: Ink(
                                    width: double.maxFinite,
                                    padding: Dimensions.kDefaultPadding,
                                    height: 200.h,
                                    decoration: BoxDecoration(
                                      borderRadius:
                                          Dimensions.kBorderRadius * 2,
                                      image: DecorationImage(
                                        image: AssetImage(
                                          Get.isDarkMode
                                              ? "$rootImageDir/card_design_dark.webp"
                                              : "$rootImageDir/card_design.webp",
                                        ),
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        VSpace(25.h),
                                        Row(
                                          children: [
                                            Text(
                                              storedLanguage['Virtual Card'] ??
                                                  "Virtual Card",
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              style: context.t.bodyMedium
                                                  ?.copyWith(
                                                    fontSize: 18.sp,
                                                    color: AppColors.black30,
                                                  ),
                                            ),
                                            Spacer(),
                                            cardCtrl.orderLock == "true"
                                                ? Icon(
                                                  Icons.lock,
                                                  size: 19.h,
                                                  color: AppColors.whiteColor,
                                                )
                                                : const SizedBox(),
                                          ],
                                        ),
                                        VSpace(5.h),
                                        if (cardCtrl
                                            .virtualCardFormList
                                            .isNotEmpty)
                                          Text(
                                            "Per Card Request Charge ${cardCtrl.virtualCardFormList[0].charge} ${cardCtrl.virtualCardFormList[0].currency}",
                                            maxLines: 1,
                                            style: context.t.bodyMedium
                                                ?.copyWith(
                                                  color: AppColors.redColor,
                                                ),
                                          ),
                                        Spacer(),
                                        Text(
                                          storedLanguage['Request For Get A Virtual Card'] ??
                                              "Request For Get A Virtual Card",
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: context.t.bodyLarge?.copyWith(
                                            color: AppColors.whiteColor,
                                            fontSize: 18.sp,
                                          ),
                                        ),
                                        VSpace(20.h),
                                      ],
                                    ),
                                  ),
                                ),
                                VSpace(50.h),
                              ],
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

  Future<void> buildReasonDialog(
    BuildContext context,
    TextTheme t,
    storedLanguage,
    CardController cardCtrl,
    String id,
  ) {
    return showDialog<void>(
      barrierDismissible: true,
      context: context,
      builder: (BuildContext context) {
        return GetBuilder<CardController>(
          builder: (profileCtrl) {
            return Padding(
              padding: EdgeInsets.symmetric(vertical: 60.h, horizontal: 30.w),
              child: Material(
                // Wrap with Material
                elevation: 0,
                type: MaterialType.transparency,
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: context.mQuery.width,
                        padding: Dimensions.kDefaultPadding,
                        decoration: BoxDecoration(
                          color: AppThemes.getDarkBgColor(),
                          borderRadius: BorderRadius.circular(32.r),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            VSpace(20.h),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  storedLanguage['Block Confirmation'] ??
                                      "Block Confirmation",
                                  style: t.displayMedium,
                                ),
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
                            VSpace(30.h),
                            Text(
                              storedLanguage['Are You sure to send block request for this card?'] ??
                                  "Are You sure to send block request for this card?",
                              style: t.displayMedium,
                            ),
                            VSpace(10.h),
                            CustomTextField(
                              isBorderColor: true,
                              hintext:
                                  storedLanguage['Reason For Block'] ??
                                  "Reason For Block",
                              controller: cardCtrl.reasonCtrl,
                              contentPadding: EdgeInsets.only(left: 20.w),
                            ),
                            VSpace(24.h),
                            GetBuilder<CardController>(
                              builder: (cardCtrl) {
                                return Material(
                                  color: Colors.transparent,
                                  child: AppButton(
                                    isLoading:
                                        cardCtrl.isBlocking ? true : false,
                                    onTap:
                                        cardCtrl.isBlocking
                                            ? null
                                            : () async {
                                              if (cardCtrl
                                                  .reasonCtrl
                                                  .text
                                                  .isEmpty) {
                                                Helpers.showSnackBar(
                                                  msg:
                                                      "Email field is required",
                                                );
                                              } else {
                                                await cardCtrl.blockCard(
                                                  context: context,
                                                  id: "$id",
                                                  reason:
                                                      cardCtrl.reasonCtrl.text,
                                                );
                                              }
                                            },
                                    text: storedLanguage['Submit'] ?? 'Submit',
                                  ),
                                );
                              },
                            ),
                            VSpace(20.h),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}
