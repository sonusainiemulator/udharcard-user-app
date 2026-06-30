import 'package:avatar_glow/avatar_glow.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:paysecure/controllers/bindings/controller_index.dart';
import 'package:paysecure/routes/routes_name.dart';
import 'package:paysecure/views/screens/home/dummy_data.dart';
import 'package:paysecure/views/widgets/mediaquery_extension.dart';
import 'package:paysecure/views/widgets/text_theme_extension.dart';
import '../../../../config/app_colors.dart';
import '../../../config/dimensions.dart';
import '../../../themes/themes.dart';
import '../../../utils/app_constants.dart';
import '../../../utils/services/helpers.dart';
import '../../../utils/services/localstorage/hive.dart';
import '../../../utils/services/localstorage/keys.dart';
import '../../widgets/appDialog.dart';
import '../../widgets/custom_appbar.dart';
import '../../widgets/spacing.dart';
import '../transaction/transaction_screen.dart';
import '../mobile_scanner/mobile_scanner_screen.dart';
import '../qr_payment/deposit_qr_screen.dart';
import '../qr_payment/qr_code_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  bool _isTapped = false;
  bool _showBalance = false;
  bool _isButtonDisabled = false;
  double _iconPosition = 5.w;
  final double _finalPosition = 193.w - 34.w;
  var scaffoldKey = GlobalKey<ScaffoldState>();
  bool isCollapsed1 = false;
  bool isCollapsed2 = false;
  bool isCollapsed3 = false;
  void _reverseAnimation() {
    Future.delayed(Duration(seconds: 5), () {
      setState(() {
        _isTapped = false;
      });

      Future.delayed(Duration(milliseconds: 500), () {
        setState(() {
          _showBalance = false;
          _isButtonDisabled = false;
        });
      });
    });
  }

  final int hour = DateTime.now().hour;
  String greetingMessage() {
    if (hour >= 5 && hour < 12) {
      return "Good Morning,";
    } else if (hour >= 12 && hour < 17) {
      return "Good Afternoon,";
    } else {
      return "Good Evening,";
    }
  }

  @override
  Widget build(BuildContext context) {
    Get.put(TransactionController());
    Get.delete<CardController>();
    TextTheme t = Theme.of(context).textTheme;
    return GetBuilder<AppController>(
      builder: (appCtrl) {
        var storedLanguage = HiveHelp.read(Keys.languageData) ?? {};
        return GetBuilder<AuthController>(
          builder: (authController) {
            return GetBuilder<TransactionController>(
              builder: (transactionCtrl) {
                return GetBuilder<ProfileController>(
                  builder: (profileCtrl) {
                    return Scaffold(
                      backgroundColor:
                          Get.isDarkMode
                              ? AppColors.darkBgColor
                              : AppColors.scaffoldColor,
                      key: scaffoldKey,
                      appBar: CustomAppBar(
                        toolberHeight: 100.h,
                        prefferSized: 100.h,
                        bgColor:
                            Get.isDarkMode
                                ? AppColors.darkBgColor
                                : AppColors.fillColorColor,
                        isTitleMarginTop: true,
                        titleWidget: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Stack(
                              alignment: Alignment.center,
                              clipBehavior: Clip.none,
                              children: [
                                InkWell(
                                  borderRadius: BorderRadius.circular(60.r),
                                  onTap:
                                      _isButtonDisabled
                                          ? null
                                          : () {
                                            Future.delayed(
                                              Duration(milliseconds: 200),
                                              () {
                                                setState(() {
                                                  _isButtonDisabled = true;
                                                  _isTapped = true;
                                                });
                                              },
                                            );

                                            Future.delayed(
                                              Duration(milliseconds: 700),
                                              () {
                                                setState(() {
                                                  _showBalance = true;
                                                });
                                              },
                                            );
                                            _reverseAnimation();
                                          },
                                  child: Ink(
                                    width: 193.w,
                                    height: 36.h,
                                    decoration: BoxDecoration(
                                      color: AppColors.mainColor,
                                      borderRadius: BorderRadius.circular(60.r),
                                    ),
                                    child: Stack(
                                      alignment: Alignment.centerLeft,
                                      children: [
                                        AnimatedPositioned(
                                          duration: Duration(milliseconds: 600),
                                          left:
                                              _isTapped
                                                  ? _finalPosition
                                                  : _iconPosition,
                                          top: 4.h,
                                          child: AnimatedOpacity(
                                            opacity: _isTapped ? .6 : 1.0,
                                            duration: Duration(
                                              milliseconds: 500,
                                            ),
                                            child: AvatarGlow(
                                              animate: true,
                                              startDelay: const Duration(
                                                milliseconds: 1000,
                                              ),
                                              glowColor:
                                                  Get.isDarkMode
                                                      ? AppColors.whiteColor
                                                      : AppColors.black50,
                                              glowShape: BoxShape.circle,
                                              curve: Curves.fastOutSlowIn,
                                              glowRadiusFactor: .5,
                                              child: Container(
                                                padding: EdgeInsets.all(
                                                  appCtrl.walletList.isNotEmpty
                                                      ? 0
                                                      : 4.5.r,
                                                ),
                                                width: 28.h,
                                                height: 28.h,
                                                decoration: BoxDecoration(
                                                  color: Colors.white,
                                                  shape: BoxShape.circle,
                                                ),
                                                child: Center(
                                                  child:
                                                      appCtrl
                                                              .walletList
                                                              .isNotEmpty
                                                          ? ClipOval(
                                                            child: CachedNetworkImage(
                                                              imageUrl:
                                                                  appCtrl
                                                                      .walletList[0]
                                                                      .currency!
                                                                      .image ??
                                                                  "",
                                                              fit: BoxFit.cover,
                                                            ),
                                                          )
                                                          : Image.asset(
                                                            "$rootImageDir/dlr.webp",
                                                            color:
                                                                AppColors
                                                                    .mainColor,
                                                          ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                        Center(
                                          child:
                                              _showBalance
                                                  ? AnimatedOpacity(
                                                    opacity:
                                                        _isTapped == false
                                                            ? 0.0
                                                            : 1.0,
                                                    duration: Duration(
                                                      milliseconds: 300,
                                                    ),
                                                    child: Text(
                                                      appCtrl
                                                              .walletList
                                                              .isNotEmpty
                                                          ? Helpers.numberFormatWithAsFixed2(
                                                            '',
                                                            appCtrl
                                                                .walletList[0]
                                                                .totalBalance
                                                                .toString(),
                                                          )
                                                          : "0.00",
                                                      style: t.bodySmall
                                                          ?.copyWith(
                                                            color:
                                                                AppColors
                                                                    .whiteColor,
                                                            fontSize: 14.sp,
                                                            fontWeight:
                                                                FontWeight.bold,
                                                          ),
                                                    ),
                                                  )
                                                  : AnimatedOpacity(
                                                    opacity:
                                                        _isTapped ? 0.0 : 1.0,
                                                    duration: Duration(
                                                      milliseconds: 300,
                                                    ),
                                                    child: Text(
                                                      "Tap for Balance",
                                                      style: t.bodySmall
                                                          ?.copyWith(
                                                            color:
                                                                AppColors
                                                                    .whiteColor,
                                                            fontSize: 14.sp,
                                                          ),
                                                    ),
                                                  ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        leading: Padding(
                          padding: EdgeInsets.only(left: 7.w),
                          child: IconButton(
                            onPressed: () {
                              scaffoldKey.currentState?.openDrawer();
                            },
                            icon: Container(
                              width: 34.h,
                              height: 34.h,
                              padding: EdgeInsets.all(8.5.h),
                              decoration: BoxDecoration(
                                color:
                                    Get.isDarkMode
                                        ? AppColors.darkCardColor
                                        : AppColors.whiteColor,
                                borderRadius: BorderRadius.circular(12.r),
                                border: Border.all(
                                  color: AppColors.mainColor,
                                  width: Dimensions.appThinBorder,
                                ),
                              ),
                              child: Image.asset(
                                "$rootImageDir/menu.webp",
                                height: 32.h,
                                width: 32.h,
                                color: AppThemes.getIconBlackColor(),
                                fit: BoxFit.fitHeight,
                              ),
                            ),
                          ),
                        ),
                        actions: [
                          IconButton(
                            onPressed: () {
                              Get.to(() => const DepositQrScreen());
                            },
                            icon: Container(
                              height: 33.h,
                              width: 33.h,
                              padding: EdgeInsets.all(6.h),
                              decoration: BoxDecoration(
                                color: Get.isDarkMode
                                    ? AppColors.darkCardColor
                                    : AppColors.whiteColor,
                                border: Border.all(
                                  color: AppColors.mainColor,
                                  width: .02,
                                ),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.qr_code_2_rounded,
                                color: AppColors.mainColor,
                                size: 18.h,
                              ),
                            ),
                          ),
                          HSpace(8.w),
                          Stack(
                            children: [
                              IconButton(
                                onPressed: () {
                                  Get.put(
                                    PushNotificationController(),
                                  ).isNotiSeen();
                                },
                                icon: Container(
                                  height: 33.h,
                                  width: 33.h,
                                  padding: EdgeInsets.all(8.h),
                                  decoration: BoxDecoration(
                                    color:
                                        Get.isDarkMode
                                            ? AppColors.darkCardColor
                                            : AppColors.whiteColor,
                                    border: Border.all(
                                      color: AppColors.mainColor,
                                      width: .02,
                                    ),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Image.asset(
                                    "$rootImageDir/notification.webp",
                                    color: AppThemes.getIconBlackColor(),
                                    fit: BoxFit.fitHeight,
                                  ),
                                ),
                              ),
                              Obx(
                                () => Positioned(
                                  top: 15.h,
                                  right: 17.w,
                                  child: InkWell(
                                    onTap: () {
                                      Get.put(
                                        PushNotificationController(),
                                      ).isNotiSeen();
                                    },
                                    child: CircleAvatar(
                                      radius:
                                          Get.put(PushNotificationController())
                                                      .isSeen
                                                      .value ==
                                                  false
                                              ? 5.r
                                              : 0,
                                      backgroundColor:
                                          Get.put(PushNotificationController())
                                                      .isSeen
                                                      .value ==
                                                  false
                                              ? AppColors.redColor
                                              : Colors.transparent,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          HSpace(20.w),
                        ],
                      ),
                      body: RefreshIndicator(
                        color: AppColors.mainColor,
                        onRefresh: () async {
                          transactionCtrl.resetDataAfterSearching();
                          await transactionCtrl.getTransactionList(
                            page: 1,
                            type: "",
                            created_at: "",
                            utr: "",
                          );
                          await appCtrl.getDashboard();
                        },
                        child: SingleChildScrollView(
                          physics: const AlwaysScrollableScrollPhysics(),
                          child: Padding(
                            padding: Dimensions.kDefaultPadding,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  greetingMessage(),
                                  style: t.displayMedium?.copyWith(
                                    fontSize: 16.sp,
                                  ),
                                ),
                                Text(
                                  "${HiveHelp.read(Keys.userFullName)}",
                                  style: t.bodyMedium?.copyWith(
                                    fontSize: 18.sp,
                                  ),
                                ),
                                VSpace(20.h),
                                // ──── Udhar Card Virtual Card ─────────────
                                _buildUdharVirtualCard(
                                  context, appCtrl, profileCtrl, t),
                                VSpace(32.h),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      storedLanguage['Recent Activity'] ??
                                          'Recent Activity',
                                      style: t.bodyLarge?.copyWith(
                                        fontSize: 20.sp,
                                      ),
                                    ),
                                    InkWell(
                                      onTap: () {
                                        Get.to(
                                          () => TransactionScreen(
                                            isFromHomePage: true,
                                          ),
                                        );
                                      },
                                      child: Padding(
                                        padding: EdgeInsets.symmetric(
                                          vertical: 10.h,
                                        ),
                                        child: Text(
                                          storedLanguage['See All'] ??
                                              'See All',
                                          style: t.displayMedium?.copyWith(
                                            color: AppColors.mainColor,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                VSpace(17.h),
                                transactionCtrl.isLoading
                                    ? buildTransactionLoader()
                                    : transactionCtrl.transactionList.isEmpty
                                    ? Center(
                                      child: Container(
                                        height: 140.h,
                                        width: 140.h,
                                        margin: EdgeInsets.only(top: 50.h),
                                        child: Image.asset(
                                          Get.isDarkMode
                                              ? "$rootImageDir/not_found_dark.webp"
                                              : "$rootImageDir/not_found.webp",
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                    )
                                    : ListView.builder(
                                      physics:
                                          const NeverScrollableScrollPhysics(),
                                      shrinkWrap: true,
                                      itemCount:
                                          transactionCtrl
                                                      .transactionList
                                                      .length >
                                                  5
                                              ? 5
                                              : transactionCtrl
                                                  .transactionList
                                                  .length,
                                      itemBuilder: (context, i) {
                                        var clampedIndex = i.clamp(
                                          i,
                                          transactionCtrl
                                              .transactionList
                                              .length,
                                        );
                                        var data =
                                            transactionCtrl
                                                .transactionList[clampedIndex];
                                        return InkWell(
                                          borderRadius:
                                              Dimensions.kBorderRadius,
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
                                                      padding: EdgeInsets.all(
                                                        7.h,
                                                      ),
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
                                                                ? AppColors
                                                                    .whiteColor
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
                                                        msg:
                                                            "Copied Successfully",
                                                        title: 'Success',
                                                        bgColor:
                                                            AppColors
                                                                .greenColor,
                                                      );
                                                    },
                                                    child: Container(
                                                      color: Colors.transparent,
                                                      child: Column(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
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
                                                              data.transactionId ??
                                                                  '',
                                                              textAlign:
                                                                  TextAlign
                                                                      .center,
                                                              style:
                                                                  t.bodySmall,
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
                                                                ? AppColors
                                                                    .whiteColor
                                                                : AppColors
                                                                    .blackColor,
                                                      ),
                                                    ),
                                                    Text(
                                                      data.status.toString(),
                                                      maxLines: 1,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                      style: t.bodySmall,
                                                    ),
                                                  ],
                                                  VSpace(12.h),
                                                  Text(
                                                    storedLanguage['Amount'] ??
                                                        "Amount",
                                                    style: t.bodyMedium?.copyWith(
                                                      color:
                                                          Get.isDarkMode
                                                              ? AppColors
                                                                  .whiteColor
                                                              : AppColors
                                                                  .blackColor,
                                                    ),
                                                  ),
                                                  Text(
                                                    data.amount.toString() +
                                                        " ${data.currency.toString().replaceAll("null", "")}",
                                                    style: t.bodySmall,
                                                  ),

                                                  VSpace(12.h),
                                                  Text(
                                                    storedLanguage['Charge'] ??
                                                        "Charge",
                                                    style: t.bodyMedium?.copyWith(
                                                      color:
                                                          Get.isDarkMode
                                                              ? AppColors
                                                                  .whiteColor
                                                              : AppColors
                                                                  .blackColor,
                                                    ),
                                                  ),
                                                  Text(
                                                    data.charge.toString() +
                                                        " ${data.currency}",
                                                    style: t.bodySmall
                                                        ?.copyWith(
                                                          color:
                                                              AppColors
                                                                  .redColor,
                                                        ),
                                                  ),

                                                  VSpace(12.h),
                                                  Text(
                                                    storedLanguage['Remarks'] ??
                                                        "Remarks",
                                                    style: t.bodyMedium?.copyWith(
                                                      color:
                                                          Get.isDarkMode
                                                              ? AppColors
                                                                  .whiteColor
                                                              : AppColors
                                                                  .blackColor,
                                                    ),
                                                  ),
                                                  Text(
                                                    data.remarks == null
                                                        ? "-"
                                                        : data.remarks
                                                            .toString(),
                                                    maxLines: 1,
                                                    overflow:
                                                        TextOverflow.ellipsis,
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
                                                    color: AppColors.mainColor
                                                        .withValues(alpha: .1),
                                                    shape: BoxShape.circle,
                                                  ),
                                                  child: Image.asset(
                                                    "$rootImageDir/approved.webp",
                                                    color: AppColors.mainColor,
                                                  ),
                                                ),
                                                HSpace(12.w),
                                                Expanded(
                                                  child: Column(
                                                    children: [
                                                      Row(
                                                        children: [
                                                          Expanded(
                                                            flex: 14,
                                                            child: Column(
                                                              crossAxisAlignment:
                                                                  CrossAxisAlignment
                                                                      .start,
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .spaceBetween,
                                                              children: [
                                                                Text(
                                                                  data.remarks
                                                                      .toString(),
                                                                  maxLines: 1,
                                                                  overflow:
                                                                      TextOverflow
                                                                          .fade,
                                                                  style:
                                                                      t.bodyMedium,
                                                                ),
                                                                VSpace(3.h),
                                                                Text(
                                                                  data.createdTime
                                                                      .toString(),

                                                                  maxLines: 1,
                                                                  overflow:
                                                                      TextOverflow
                                                                          .ellipsis,
                                                                  style: t
                                                                      .bodySmall
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
                                                            child: Align(
                                                              alignment:
                                                                  Alignment
                                                                      .centerRight,
                                                              child: Text(
                                                                data.type +
                                                                    "${data.amount.toString()} ${data.currency.toString().replaceAll("null", "")}",
                                                                maxLines: 1,
                                                                overflow:
                                                                    TextOverflow
                                                                        .ellipsis,
                                                                style: t.bodyMedium?.copyWith(
                                                                  color:
                                                                      data.type ==
                                                                              "+"
                                                                          ? AppColors
                                                                              .greenColor
                                                                          : AppColors
                                                                              .redColor,
                                                                ),
                                                              ),
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
                                VSpace(24.h),
                                ExpandableCategoryList(
                                  onCategoryTapped: (v) {
                                    onCategoryTapped(v);
                                  },
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      drawer: buildDrawer(context, storedLanguage),
                    );
                  },
                );
              },
            );
          },
        );
      },
    );
  }

  // ─── Udhar Card Virtual Credit Card Widget ───────────────────────────────
  Widget _buildUdharVirtualCard(
    BuildContext context,
    AppController appCtrl,
    ProfileController profileCtrl,
    TextTheme t,
  ) {
    final balance = appCtrl.walletList.isNotEmpty
        ? appCtrl.walletList[0].totalBalance?.toString() ?? '0.00'
        : '0.00';
    final symbol = appCtrl.walletList.isNotEmpty
        ? appCtrl.walletList[0].currency?.symbol ?? '₹'
        : '₹';
    final code = appCtrl.walletList.isNotEmpty
        ? appCtrl.walletList[0].currency?.code ?? 'INR'
        : 'INR';
    final userName = profileCtrl.userName.isNotEmpty
        ? profileCtrl.userName.toUpperCase()
        : (HiveHelp.read(Keys.userFullName) ?? 'USER').toUpperCase();

    // Parse balance for limit bar
    final double balanceVal = double.tryParse(balance.replaceAll(',', '')) ?? 0;
    const double creditLimit = 50000;
    final double usedRatio = (balanceVal / creditLimit).clamp(0.0, 1.0);

    return GestureDetector(
      onTap: () => Get.toNamed(RoutesName.qrCodeScreen),
      child: Container(
        width: double.infinity,
        height: 200.h,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20.r),
          gradient: const LinearGradient(
            colors: [
              Color(0xff0D2247),
              Color(0xff1B3A6B),
              Color(0xff1E4E8C),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: Color(0xff1B3A6B).withValues(alpha: .45),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Stack(
          children: [
            // ── Background decorative circles
            Positioned(
              top: -30.h,
              right: -20.w,
              child: Container(
                width: 130.h,
                height: 130.h,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color(0xffF5A623).withValues(alpha: .07),
                ),
              ),
            ),
            Positioned(
              bottom: -40.h,
              left: -20.w,
              child: Container(
                width: 120.h,
                height: 120.h,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color(0xffF5A623).withValues(alpha: .05),
                ),
              ),
            ),
            Positioned(
              top: 30.h,
              right: 80.w,
              child: Container(
                width: 70.h,
                height: 70.h,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: .04),
                ),
              ),
            ),
            // ── Card content
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Row 1: Logo + "VIRTUAL CARD" label
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Logo
                      SizedBox(
                        height: 36.h,
                        child: Image.asset(
                          '$rootImageDir/app_logo.png',
                          fit: BoxFit.contain,
                        ),
                      ),
                      // Card type badge
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 10.w,
                          vertical: 4.h,
                        ),
                        decoration: BoxDecoration(
                          color: Color(0xffF5A623).withValues(alpha: .15),
                          borderRadius: BorderRadius.circular(20.r),
                          border: Border.all(
                            color: Color(0xffF5A623).withValues(alpha: .4),
                            width: 1,
                          ),
                        ),
                        child: Text(
                          'UDHAR CREDIT',
                          style: t.bodySmall?.copyWith(
                            color: Color(0xffF5A623),
                            fontSize: 10.sp,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1.2,
                          ),
                        ),
                      ),
                    ],
                  ),
                  VSpace(10.h),
                  // Row 2: Chip + balance
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // SIM chip
                      Container(
                        width: 30.w,
                        height: 22.h,
                        decoration: BoxDecoration(
                          color: Color(0xffF5A623).withValues(alpha: .85),
                          borderRadius: BorderRadius.circular(4.r),
                        ),
                        child: CustomPaint(painter: _ChipPainter()),
                      ),
                      HSpace(12.w),
                      // Balance display
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Available Balance',
                            style: t.bodySmall?.copyWith(
                              color: Colors.white.withValues(alpha: .6),
                              fontSize: 10.sp,
                              letterSpacing: 0.5,
                            ),
                          ),
                          Text(
                            '$symbol ${Helpers.numberFormatWithAsFixed2('', balance)} $code',
                            style: t.titleMedium?.copyWith(
                              color: AppColors.whiteColor,
                              fontSize: 18.sp,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  VSpace(8.h),
                  // Card number (masked)
                  Text(
                    '•••• •••• •••• ${(profileCtrl.userId.isNotEmpty ? profileCtrl.userId : "0000").padLeft(4, '0').substring(0, 4)}',
                    style: t.bodyMedium?.copyWith(
                      color: Colors.white.withValues(alpha: .75),
                      fontSize: 14.sp,
                      letterSpacing: 2.5,
                    ),
                  ),
                  const Spacer(),
                  // Row 3: Name + Validity + limit bar
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'CARD HOLDER',
                            style: t.bodySmall?.copyWith(
                              color: Colors.white.withValues(alpha: .5),
                              fontSize: 9.sp,
                              letterSpacing: 1,
                            ),
                          ),
                          Text(
                            userName,
                            style: t.bodySmall?.copyWith(
                              color: AppColors.whiteColor,
                              fontSize: 12.sp,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            'VALID THRU',
                            style: t.bodySmall?.copyWith(
                              color: Colors.white.withValues(alpha: .5),
                              fontSize: 9.sp,
                              letterSpacing: 1,
                            ),
                          ),
                          Text(
                            '12/28',
                            style: t.bodySmall?.copyWith(
                              color: AppColors.whiteColor,
                              fontSize: 12.sp,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  VSpace(8.h),
                  // Credit limit bar
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Credit Limit',
                            style: t.bodySmall?.copyWith(
                              color: Colors.white.withValues(alpha: .55),
                              fontSize: 9.sp,
                            ),
                          ),
                          Text(
                            '$symbol ${Helpers.numberFormatWithAsFixed2('', creditLimit.toString())} $code',
                            style: t.bodySmall?.copyWith(
                              color: Color(0xffF5A623),
                              fontSize: 9.sp,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      VSpace(4.h),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4.r),
                        child: LinearProgressIndicator(
                          value: usedRatio,
                          minHeight: 4.h,
                          backgroundColor: Colors.white.withValues(alpha: .15),
                          valueColor: const AlwaysStoppedAnimation<Color>(
                            Color(0xffF5A623),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  onCategoryTapped(cateName) {
    switch (cateName) {
      case "Deposit":
        Get.toNamed(RoutesName.depositScreen);
      case "Withdraw":
        Get.toNamed(RoutesName.withdrawScreen);
      case "Send Money":
        Get.toNamed(RoutesName.sendMoneyScreen);
      case "Request Money":
        Get.toNamed(RoutesName.requestMoneyScreen);
      case "Exchange Money":
        Get.toNamed(RoutesName.exchangeScreen);
      case "Redeem":
        Get.toNamed(RoutesName.redeemScreen);
      case "Escrow":
        Get.toNamed(RoutesName.escrowScreen);
      case "Transaction":
        Get.toNamed(RoutesName.transactionScreen);
      case "Dispute":
        Get.toNamed(RoutesName.disputeHistoryScreen);
      case "QR Payment":
        Get.toNamed(RoutesName.qrPaymentScreen);
      case "Voucher":
        Get.toNamed(RoutesName.voucherScreen);
      case "Invoice":
        Get.toNamed(RoutesName.invoiceScreen);
      case "Pay Bill":
        Get.toNamed(RoutesName.billCategoryScreen);
      case "Support Ticket":
        Get.toNamed(RoutesName.supportTicketListScreen);
      default:
        Get.offAllNamed(RoutesName.bottomNavBar);
    }
  }

  Widget buildContainer(
    TextTheme t, [
    Color? bgColor,
    String? img,
    String? currency,
    String? amout,
  ]) {
    return Container(
      padding: EdgeInsets.only(
        top: 20.h,
        left: 16.h,
        bottom: 16.h,
        right: 16.h,
      ),
      height: 134.h,
      decoration: BoxDecoration(
        color: bgColor ?? AppColors.dollerColor.withValues(alpha: .1),
        borderRadius: Dimensions.kBorderRadius * 2,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Image.asset(
            img ?? "$rootImageDir/doller.webp",
            height: 36.h,
            width: 36.h,
            fit: BoxFit.cover,
          ),
          VSpace(5.h),
          Text(
            currency ?? "Us Dollar",
            style: t.bodySmall?.copyWith(
              fontSize: 14.sp,
              color: AppThemes.getIconBlackColor(),
            ),
          ),
          Text(
            amout ?? "\$7468.28",
            maxLines: 2,
            style: t.bodyMedium?.copyWith(fontSize: 16.sp),
          ),
        ],
      ),
    );
  }

  Widget buildAccountsLoader() {
    return SizedBox(
      height: 200.h,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: 3,
        itemBuilder: (context, i) {
          return Container(
            height: 200.h,
            width: 250.w,
            margin: EdgeInsets.only(right: 20.h),
            decoration: BoxDecoration(
              color:
                  Get.isDarkMode
                      ? AppColors.darkCardColor
                      : AppColors.whiteColor,
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                VSpace(10.h),
                Row(
                  children: [
                    Container(
                      width: 32.h,
                      height: 32.h,
                      margin: EdgeInsets.only(left: 8.w),
                      padding: EdgeInsets.all(10.h),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color:
                            Get.isDarkMode
                                ? AppColors.darkBgColor
                                : AppColors.fillColorColor,
                      ),
                    ),
                    Spacer(),
                    Container(
                      width: 5.w,
                      height: 25.h,
                      margin: EdgeInsets.only(right: 20.w),
                      padding: EdgeInsets.all(10.h),
                      decoration: BoxDecoration(
                        color:
                            Get.isDarkMode
                                ? AppColors.darkBgColor
                                : AppColors.fillColorColor,
                      ),
                    ),
                  ],
                ),
                VSpace(25.h),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 80.w,
                      height: 15.h,
                      margin: EdgeInsets.only(left: 8.w),
                      padding: EdgeInsets.all(10.h),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(4.r),
                        color:
                            Get.isDarkMode
                                ? AppColors.darkBgColor
                                : AppColors.fillColorColor,
                      ),
                    ),
                    VSpace(6.w),
                    Container(
                      width: 150.w,
                      height: 25.h,
                      margin: EdgeInsets.only(left: 8.w),
                      padding: EdgeInsets.all(10.h),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(4.r),
                        color:
                            Get.isDarkMode
                                ? AppColors.darkBgColor
                                : AppColors.fillColorColor,
                      ),
                    ),
                  ],
                ),
                Spacer(),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 80.w,
                      height: 15.h,
                      margin: EdgeInsets.only(left: 8.w),
                      padding: EdgeInsets.all(10.h),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(4.r),
                        color:
                            Get.isDarkMode
                                ? AppColors.darkBgColor
                                : AppColors.fillColorColor,
                      ),
                    ),
                    VSpace(6.w),
                    Container(
                      width: 170.w,
                      height: 25.h,
                      margin: EdgeInsets.only(left: 8.w),
                      padding: EdgeInsets.all(10.h),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(4.r),
                        color:
                            Get.isDarkMode
                                ? AppColors.darkBgColor
                                : AppColors.fillColorColor,
                      ),
                    ),
                  ],
                ),
                VSpace(15.h),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget buildDrawer(BuildContext context, storedLanguage) {
    Color lightenColor(Color color, [double amount = 0.1]) {
      assert(amount >= 0 && amount <= 1, 'Amount should be between 0 and 1');
      final hsl = HSLColor.fromColor(color);
      final hslLightened = hsl.withLightness(
        (hsl.lightness + amount).clamp(0.0, 1.0),
      );
      return hslLightened.toColor();
    }

    return Drawer(
      backgroundColor: Colors.transparent,
      elevation: 0,
      child: Padding(
        padding: EdgeInsets.only(right: 60.w),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Positioned(
              top: 0,
              bottom: 0,
              right: 0,
              child: Image.asset(
                "$rootImageDir/drawer_bg_right.webp",
                color: AppColors.mainColor,
                fit: BoxFit.cover,
              ),
            ),
            Positioned(
              top: 0,
              bottom: 0,
              left: 0,
              child: Image.asset(
                "$rootImageDir/drawer_bg_left.webp",
                color: lightenColor(AppColors.mainColor, 0.05),
                width: context.mQuery.width * .6,
                fit: BoxFit.cover,
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                GetBuilder<ProfileController>(
                  builder: (profileController) {
                    return SizedBox(
                      height: 240.h,
                      child: Column(
                        children: [
                          VSpace(90.h),
                          SizedBox(
                            height: 110.h,
                            width: context.mQuery.width * .58,
                            child: Stack(
                              alignment: Alignment.centerLeft,
                              clipBehavior: Clip.none,
                              children: [
                                Positioned(
                                  right: -60.w,
                                  child: Container(
                                    height: 120.h,
                                    width: 120.h,
                                    padding: EdgeInsets.all(20.h),
                                    decoration: BoxDecoration(
                                      color: AppColors.mainColor,
                                      shape: BoxShape.circle,
                                    ),
                                    child: Container(
                                      height: 80.h,
                                      width: 80.h,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: AppColors.imageBgColor,
                                        image:
                                            profileController.isLoading ||
                                                    profileController
                                                            .userPhoto ==
                                                        ''
                                                ? DecorationImage(
                                                  image: AssetImage(
                                                    "$rootImageDir/avatar.webp",
                                                  ),
                                                  fit: BoxFit.cover,
                                                )
                                                : DecorationImage(
                                                  image:
                                                      CachedNetworkImageProvider(
                                                        profileController
                                                            .userPhoto,
                                                      ),
                                                  fit: BoxFit.cover,
                                                ),
                                      ),
                                    ),
                                  ),
                                ),
                                Align(
                                  alignment: Alignment.centerLeft,
                                  child: Padding(
                                    padding: EdgeInsets.only(left: 24.w),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        VSpace(30.h),
                                        Text(
                                          profileController.isLoading
                                              ? ""
                                              : profileController.userName,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: context.t.bodyLarge?.copyWith(
                                            fontSize: 20.sp,
                                            color: AppColors.whiteColor,
                                          ),
                                        ),
                                        VSpace(5.h),
                                        Text(
                                          profileController.isLoading
                                              ? ""
                                              : profileController.userEmail,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: context.t.displayMedium
                                              ?.copyWith(
                                                fontSize: 16.sp,
                                                color: AppColors.whiteColor,
                                              ),
                                        ),
                                      ],
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
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        if (AppController.to.basicCtrlList.isNotEmpty &&
                            AppController.to.basicCtrlList[0].request
                                    .toString() ==
                                '1')
                          expansionTileWidget(
                            context,
                            isCollapsed: isCollapsed1,
                            img: '$rootImageDir/request-money.webp',
                            categoryName:
                                storedLanguage['Request Money'] ??
                                'Request Money',
                            subCategoryList: ['New Request', 'All Request'],
                            onTap: (v) {
                              if (v == 'New Request') {
                                Get.toNamed(RoutesName.requestMoneyScreen);
                              } else {
                                Get.toNamed(
                                  RoutesName.requestMoneyHistoryScreen,
                                );
                              }
                            },
                            onExpansionChanged: (v) {
                              setState(() {
                                isCollapsed1 = v;
                              });
                            },
                          ),
                        if (AppController.to.basicCtrlList.isNotEmpty &&
                            AppController.to.basicCtrlList[0].exchange
                                    .toString() ==
                                '1')
                          expansionTileWidget(
                            context,
                            isCollapsed: isCollapsed2,
                            img: '$rootImageDir/exchange_money.webp',
                            categoryName:
                                storedLanguage['Exchange Money'] ??
                                'Exchange Money',
                            subCategoryList: ['Exchange', 'All Exchange'],
                            onTap: (v) {
                              if (v == 'Exchange') {
                                Get.toNamed(RoutesName.exchangeScreen);
                              } else {
                                Get.toNamed(
                                  RoutesName.exchangeMoneyHistoryScreen,
                                );
                              }
                            },
                            onExpansionChanged: (v) {
                              setState(() {
                                isCollapsed2 = v;
                              });
                            },
                          ),
                        if (AppController.to.basicCtrlList.isNotEmpty &&
                            AppController.to.basicCtrlList[0].redeem
                                    .toString() ==
                                '1')
                          expansionTileWidget(
                            context,
                            isCollapsed: isCollapsed3,
                            img: '$rootImageDir/redeem.webp',
                            categoryName: storedLanguage['Redeem'] ?? 'Redeem',
                            subCategoryList: [
                              'Generate New Code',
                              'Generated List',
                              'Insert Redeem Code',
                            ],
                            onTap: (v) {
                              if (v == 'Generate New Code') {
                                Get.toNamed(RoutesName.redeemScreen);
                              } else if (v == 'Generated List') {
                                Get.toNamed(RoutesName.redeemHistoryScreen);
                              } else {
                                Get.toNamed(RoutesName.insertRedeemCodeScreen);
                              }
                            },
                            onExpansionChanged: (v) {
                              setState(() {
                                isCollapsed3 = v;
                              });
                            },
                          ),
                        if (AppController.to.basicCtrlList.isNotEmpty &&
                            AppController.to.basicCtrlList[0].make_payment
                                    .toString() ==
                                '1')
                          buildTile(
                            context,
                            onTap: () {
                              Get.toNamed(RoutesName.makePaymentScreen);
                            },
                            img: "$rootImageDir/make-payment.webp",
                            name:
                                storedLanguage['Make Payment'] ??
                                'Make Payment',
                          ),
                        if (AppController.to.basicCtrlList.isNotEmpty &&
                            AppController.to.basicCtrlList[0].cash_out
                                    .toString() ==
                                '1')
                          buildTile(
                            context,
                            onTap: () {
                              Get.toNamed(RoutesName.cashoutScreen);
                            },
                            img: "$rootImageDir/cash-out.webp",
                            name: storedLanguage['Cash Out'] ?? 'Cash Out',
                          ),

                        buildTile(
                          context,
                          onTap: () {
                            Get.toNamed(RoutesName.securityPinSetupScreen);
                          },
                          img: "$rootImageDir/pin.webp",
                          name: storedLanguage['Reset Pin'] ?? 'Reset Pin',
                        ),
                        if (AppController.to.basicCtrlList.isNotEmpty &&
                            AppController.to.basicCtrlList[0].deposit
                                    .toString() ==
                                '1')
                          buildTile(
                            context,
                            onTap: () {
                              Get.toNamed(RoutesName.depositHistoryScreen);
                            },
                            img: "$rootImageDir/add_fund.webp",
                            name:
                                storedLanguage['Deposit History'] ??
                                'Deposit History',
                          ),
                        if (AppController.to.basicCtrlList.isNotEmpty &&
                            AppController.to.basicCtrlList[0].payout
                                    .toString() ==
                                '1')
                          buildTile(
                            context,
                            onTap: () {
                              Get.toNamed(RoutesName.withdrawHistoryScreen);
                            },
                            img: "$rootImageDir/payout.webp",
                            name:
                                storedLanguage['Withdraw History'] ??
                                'Withdraw History',
                          ),
                        if (AppController.to.basicCtrlList.isNotEmpty &&
                            AppController.to.basicCtrlList[0].transfer
                                    .toString() ==
                                '1')
                          buildTile(
                            context,
                            onTap: () {
                              Get.toNamed(RoutesName.sendMoneyHistoryScreen);
                            },
                            img: "$rootImageDir/money_transfer.webp",
                            name:
                                storedLanguage['Transfer History'] ??
                                'Transfer History',
                          ),
                        if (AppController.to.basicCtrlList.isNotEmpty &&
                            AppController.to.basicCtrlList[0].escrow
                                    .toString() ==
                                '1')
                          buildTile(
                            context,
                            onTap: () {
                              Get.toNamed(RoutesName.escrowHistoryScreen);
                            },
                            img: "$rootImageDir/escrow.webp",
                            name:
                                storedLanguage['Escrow History'] ??
                                'Escrow History',
                          ),
                        if (AppController.to.basicCtrlList.isNotEmpty &&
                            AppController.to.basicCtrlList[0].voucher
                                    .toString() ==
                                '1')
                          buildTile(
                            context,
                            onTap: () {
                              Get.toNamed(RoutesName.voucherHistoryScreen);
                            },
                            img: "$rootImageDir/voucher.webp",
                            name:
                                storedLanguage['Voucher History'] ??
                                'Voucher History',
                          ),
                        if (AppController.to.basicCtrlList.isNotEmpty &&
                            AppController.to.basicCtrlList[0].invoice
                                    .toString() ==
                                '1')
                          buildTile(
                            context,
                            onTap: () {
                              Get.toNamed(RoutesName.invoiceHistoryScreen);
                            },
                            img: "$rootImageDir/invoice.webp",
                            name:
                                storedLanguage['Invoice History'] ??
                                'Invoice History',
                          ),
                        if (AppController.to.basicCtrlList.isNotEmpty &&
                            AppController.to.basicCtrlList[0].billPayment
                                    .toString() ==
                                '1')
                          buildTile(
                            context,
                            onTap: () {
                              Get.toNamed(RoutesName.payBillHistoryScreen);
                            },
                            img: "$rootImageDir/pay_bill.webp",
                            name:
                                storedLanguage['Pay History'] ?? 'Pay History',
                          ),
                        VSpace(60.h),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  ExpansionTile expansionTileWidget(
    BuildContext context, {
    required String img,
    required String categoryName,
    required List<String> subCategoryList,
    required Function(String) onTap,
    void Function(bool)? onExpansionChanged,
    required bool isCollapsed,
  }) {
    return ExpansionTile(
      shape: const RoundedRectangleBorder(),
      tilePadding: EdgeInsets.zero,
      childrenPadding: const EdgeInsets.all(0),
      iconColor: AppThemes.getIconBlackColor(),
      title: Row(
        children: [
          HSpace(18.w),
          SizedBox(
            width: 18.w,
            height: 18.w,
            child: Image.asset(
              img,
              color: AppColors.whiteColor,
              fit: BoxFit.cover,
            ),
          ),
          HSpace(27.w),
          Text(
            categoryName,
            style: context.t.bodyMedium?.copyWith(
              fontSize: 18.sp,
              color: AppColors.whiteColor,
            ),
          ),
        ],
      ),
      trailing:
          isCollapsed
              ? Padding(
                padding: EdgeInsets.only(right: 15.w),
                child: const Icon(
                  Icons.arrow_drop_up,
                  color: AppColors.whiteColor,
                ),
              )
              : Padding(
                padding: EdgeInsets.only(right: 15.w),
                child: const Icon(
                  Icons.arrow_drop_down,
                  color: AppColors.whiteColor,
                ),
              ),
      onExpansionChanged: onExpansionChanged,
      children:
          subCategoryList
              .map(
                (e) => SizedBox(
                  height: 40,
                  child: ListTile(
                    onTap: () => onTap(e),
                    contentPadding: EdgeInsets.only(left: 65.w),
                    title: Text(
                      e,
                      style: context.t.bodySmall?.copyWith(
                        fontSize: 16.sp,
                        color: AppColors.whiteColor,
                      ),
                    ),
                  ),
                ),
              )
              .toList(),
    );
  }

  ListTile buildTile(
    BuildContext context, {
    required String name,
    required String img,
    void Function()? onTap,
  }) {
    return ListTile(
      onTap: onTap,
      leading: SizedBox(
        width: 18.w,
        height: 18.w,
        child: Image.asset(img, color: AppColors.whiteColor, fit: BoxFit.cover),
      ),
      title: Text(
        name,
        style: context.t.bodyMedium?.copyWith(
          fontSize: 18.sp,
          color: AppColors.whiteColor,
        ),
      ),
    );
  }
}

class ExpandableCategoryList extends StatefulWidget {
  final Function(String) onCategoryTapped;

  const ExpandableCategoryList({super.key, required this.onCategoryTapped});

  @override
  State<ExpandableCategoryList> createState() => _ExpandableCategoryListState();
}

class _ExpandableCategoryListState extends State<ExpandableCategoryList> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final allCategories = DummyData().categoryBigList;
    final visibleItems =
        _expanded ? allCategories : allCategories.take(8).toList();

    return Container(
      width: double.maxFinite,
      decoration: BoxDecoration(borderRadius: Dimensions.kBorderRadius * 2),
      child: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          Padding(
            padding: EdgeInsets.only(bottom: _expanded ? 60.h : 0),
            child: Column(
              children: [
                Wrap(
                  alignment: WrapAlignment.spaceBetween,
                  spacing: 40.w,
                  runSpacing: 20.w,
                  children: [
                    ...List.generate(
                      visibleItems.length,
                      (i) => InkWell(
                        onTap:
                            () => widget.onCategoryTapped(visibleItems[i].text),
                        child: Container(
                          color: Colors.transparent,
                          child: Column(
                            children: [
                              Container(
                                width: 44.h,
                                height: 44.h,
                                padding: EdgeInsets.all(i == 3 ? 13.r : 10.r),
                                child: Image.asset(
                                  visibleItems[i].img,
                                  color: AppColors.mainColor,
                                  fit: BoxFit.cover,
                                ),
                              ),
                              VSpace(8.h),
                              Text(
                                visibleItems[i].text,
                                style: context.t.displayMedium?.copyWith(
                                  fontSize: 16.sp,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          if (!_expanded)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                height: 70.h,
                decoration: BoxDecoration(
                  boxShadow: [
                    BoxShadow(
                      color:
                          Get.isDarkMode
                              ? AppColors.darkBgColor.withValues(alpha: .6)
                              : AppColors.whiteColor.withValues(alpha: .6),
                      blurRadius: 15.0,
                      spreadRadius: 5.0,
                      offset: Offset(0, -12.h),
                    ),
                  ],
                ),
              ),
            ),
          InkWell(
            onTap: () {
              setState(() {
                _expanded = !_expanded;
              });
            },
            child: Container(
              width: 130.w,
              padding: EdgeInsets.symmetric(vertical: 3.h, horizontal: 6.w),
              alignment: Alignment.bottomCenter,
              decoration: BoxDecoration(
                color:
                    Get.isDarkMode
                        ? AppColors.darkCardColorDeep
                        : AppColors.whiteColor,
                borderRadius: Dimensions.kBorderRadius * 3,
                boxShadow: [
                  BoxShadow(
                    color:
                        Get.isDarkMode
                            ? AppColors.darkCardColorDeep.withValues(alpha: .3)
                            : AppColors.black20.withValues(alpha: .6),
                    blurRadius: 15.0,
                    spreadRadius: 5.0,
                    offset: Offset(0, 0.h),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    _expanded ? "See less" : "See more",
                    style: context.t.displayMedium,
                  ),
                  Icon(
                    _expanded
                        ? Icons.keyboard_arrow_up
                        : Icons.keyboard_arrow_down,
                    size: 30.sp,
                    color:
                        Get.isDarkMode
                            ? AppColors.whiteColor
                            : AppColors.mainColor,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// 1+ 1(design+project)+
Widget buildTransactionLoader({
  int? itemCount = 5,
  bool? isReverseColor = false,
}) {
  return ListView.builder(
    shrinkWrap: true,
    physics: const NeverScrollableScrollPhysics(),
    itemCount: itemCount,
    itemBuilder: (context, i) {
      return Container(
        width: double.maxFinite,
        margin: EdgeInsets.only(bottom: 12.h),
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
        decoration: BoxDecoration(
          color:
              isReverseColor == true
                  ? AppThemes.getFillColor()
                  : AppThemes.getDarkCardColor(),
          borderRadius: Dimensions.kBorderRadius,
          border: Border.all(
            color: AppThemes.borderColor(),
            width: Dimensions.appThinBorder,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 40.h,
              height: 40.h,
              padding: EdgeInsets.all(10.h),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12.r),
                color:
                    Get.isDarkMode
                        ? AppColors.darkBgColor
                        : isReverseColor == true
                        ? AppColors.whiteColor
                        : AppColors.fillColorColor,
              ),
            ),
            HSpace(10.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    height: 10.h,
                    width: double.maxFinite,
                    decoration: BoxDecoration(
                      color:
                          Get.isDarkMode
                              ? AppColors.darkBgColor
                              : isReverseColor == true
                              ? AppColors.whiteColor
                              : AppColors.fillColorColor,
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                  ),
                  VSpace(5.h),
                  Container(
                    height: 10.h,
                    width: 100.w,
                    decoration: BoxDecoration(
                      color:
                          Get.isDarkMode
                              ? AppColors.darkBgColor
                              : isReverseColor == true
                              ? AppColors.whiteColor
                              : AppColors.fillColorColor,
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    },
  );
}

// ── SIM Chip painter for the virtual card ────────────────────────────────────
class _ChipPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black.withValues(alpha: .25)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.8;

    // horizontal center line
    canvas.drawLine(
      Offset(0, size.height * 0.5),
      Offset(size.width, size.height * 0.5),
      paint,
    );
    // vertical center line
    canvas.drawLine(
      Offset(size.width * 0.5, 0),
      Offset(size.width * 0.5, size.height),
      paint,
    );
    // Top-left box
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width * 0.48, size.height * 0.48),
      paint,
    );
    // Top-right box
    canvas.drawRect(
      Rect.fromLTWH(size.width * 0.52, 0, size.width * 0.48, size.height * 0.48),
      paint,
    );
    // Bottom-left box
    canvas.drawRect(
      Rect.fromLTWH(0, size.height * 0.52, size.width * 0.48, size.height * 0.48),
      paint,
    );
    // Bottom-right box
    canvas.drawRect(
      Rect.fromLTWH(
        size.width * 0.52, size.height * 0.52,
        size.width * 0.48, size.height * 0.48,
      ),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
