import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:paysecure/controllers/bindings/controller_index.dart';
import 'package:paysecure/routes/routes_name.dart';
import 'package:paysecure/views/widgets/mediaquery_extension.dart';
import 'package:paysecure/views/widgets/text_theme_extension.dart';
import '../../../../config/app_colors.dart';
import '../../../config/dimensions.dart';
import '../../../themes/themes.dart';
import '../../../utils/app_constants.dart';
import '../../../utils/services/helpers.dart';
import '../../../utils/services/localstorage/hive.dart';
import '../../../utils/services/localstorage/keys.dart';
import '../../widgets/custom_appbar.dart';
import '../../widgets/spacing.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  var scaffoldKey = GlobalKey<ScaffoldState>();
  bool isCollapsed1 = false;
  bool isCollapsed2 = false;
  bool isCollapsed3 = false;

  @override
  void initState() {
    super.initState();
    Get.put(TransactionController());
    Get.delete<CardController>();
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
    TextTheme t = Theme.of(context).textTheme;
    var storedLanguage = HiveHelp.read(Keys.languageData) ?? {};

    return Scaffold(
      backgroundColor: Get.isDarkMode ? AppColors.darkBgColor : AppColors.scaffoldColor,
      key: scaffoldKey,
      appBar: CustomAppBar(
        toolberHeight: 70.h,
        prefferSized: 70.h,
        bgColor: Get.isDarkMode ? AppColors.darkBgColor : AppColors.fillColorColor,
        isTitleMarginTop: false,
        titleWidget: Text(
          "Udharcard",
          style: t.displayMedium?.copyWith(fontSize: 18.sp, color: AppColors.mainColor),
        ),
        leading: IconButton(
          onPressed: () {
            scaffoldKey.currentState?.openDrawer();
          },
          icon: Icon(Icons.menu, color: AppThemes.getIconBlackColor(), size: 28.sp),
        ),
        actions: [

          IconButton(
            onPressed: () => Get.put(PushNotificationController()).isNotiSeen(),
            icon: Icon(Icons.notifications_none, color: AppThemes.getIconBlackColor(), size: 24.sp),
          ),
          HSpace(10.w),
        ],
      ),
      drawer: buildDrawer(context, storedLanguage),
      body: RefreshIndicator(
        color: AppColors.mainColor,
        onRefresh: () async {
          await Get.find<AppController>().getDashboard();
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
                  style: t.displayMedium?.copyWith(fontSize: 16.sp),
                ),
                Text(
                  "${HiveHelp.read(Keys.userFullName) ?? 'USER'}",
                  style: t.bodyMedium?.copyWith(fontSize: 18.sp),
                ),
                VSpace(20.h),
                GetBuilder<AppController>(
                  builder: (appCtrl) {
                    return GetBuilder<ProfileController>(
                      builder: (profileCtrl) {
                        return _buildUdharVirtualCard(context, appCtrl, profileCtrl, t);
                      },
                    );
                  },
                ),
                VSpace(24.h),
                GetBuilder<AppController>(
                  builder: (appCtrl) {
                    return _buildQuickFeatures(context, appCtrl, t, storedLanguage);
                  }
                ),
                VSpace(24.h),
              ],
            ),
          ),
        ),
      ),
    );
  }


  Widget _buildQuickFeatures(BuildContext context, AppController appCtrl, TextTheme t, Map storedLanguage) {
    List<Map<String, dynamic>> features = [
      {
        "name": storedLanguage['My Udhar'] ?? "My Udhar",
        "icon": Icons.credit_card_rounded,
        "route": RoutesName.customerUdharMerchantsScreen,
        "enabled": true,
      },
      {
        "name": storedLanguage['Scan & Pay'] ?? "Scan & Pay",
        "icon": Icons.qr_code_scanner_rounded,
        "route": RoutesName.qrPaymentScreen,
        "enabled": true,
      },
      {
        "name": "Voice AI",
        "icon": Icons.mic_rounded,
        "route": RoutesName.voiceModeScreen,
        "enabled": true,
      },
      {
        "name": storedLanguage['Send Money'] ?? "Send Money",
        "icon": Icons.send_rounded,
        "route": RoutesName.sendMoneyScreen,
        "enabled": appCtrl.basicCtrlList.isNotEmpty && appCtrl.basicCtrlList[0].transfer.toString() == '1',
      },
      {
        "name": storedLanguage['Deposit'] ?? "Deposit",
        "icon": Icons.account_balance_wallet_rounded,
        "route": RoutesName.depositScreen,
        "enabled": appCtrl.basicCtrlList.isNotEmpty && appCtrl.basicCtrlList[0].deposit.toString() == '1',
      },
      {
        "name": storedLanguage['Withdraw'] ?? "Withdraw",
        "icon": Icons.money_off_rounded,
        "route": RoutesName.withdrawScreen,
        "enabled": appCtrl.basicCtrlList.isNotEmpty && appCtrl.basicCtrlList[0].payout.toString() == '1',
      },
      {
        "name": storedLanguage['History'] ?? "History",
        "icon": Icons.history_rounded,
        "route": RoutesName.transactionScreen,
        "enabled": true,
      },
      {
        "name": storedLanguage['Support'] ?? "Support",
        "icon": Icons.headset_mic_rounded,
        "route": RoutesName.supportTicketListScreen,
        "enabled": true,
      },
    ];

    features = features.where((element) => element['enabled'] == true).toList();

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        crossAxisSpacing: 10.w,
        mainAxisSpacing: 16.h,
        childAspectRatio: 0.85,
      ),
      itemCount: features.length,
      itemBuilder: (context, index) {
        var feature = features[index];
        return InkWell(
          borderRadius: BorderRadius.circular(12.r),
          onTap: () => Get.toNamed(feature['route']),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: EdgeInsets.all(12.h),
                decoration: BoxDecoration(
                  color: AppColors.mainColor.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(feature['icon'], color: AppColors.mainColor, size: 28.h),
              ),
              VSpace(8.h),
              Text(
                feature['name'],
                textAlign: TextAlign.center,
                style: t.bodySmall?.copyWith(fontSize: 12.sp, fontWeight: FontWeight.w600),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
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
    final balanceVal = double.tryParse(balance.replaceAll(',', '')) ?? 0;

    return GestureDetector(
      onTap: () => Get.toNamed(RoutesName.customerUdharMerchantsScreen),
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
            // ── Passbook content
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Row 1: Logo + "UDHAR PASSBOOK" label
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
                          'UDHAR PASSBOOK',
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
                  VSpace(15.h),
                  // Row 2: Balance display
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
                        '${balanceVal < 0 ? '-' : (balanceVal > 0 ? '+' : '')}$symbol ${Helpers.numberFormatWithAsFixed2('', balanceVal.abs().toString())} $code',
                        style: t.titleMedium?.copyWith(
                          color: balanceVal < 0 ? AppColors.redColor : AppColors.greenColor,
                          fontSize: 22.sp,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  // Walkthrough / Call to Action
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.symmetric(vertical: 10.h, horizontal: 12.w),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12.r),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.2),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.list_alt_rounded,
                          color: Color(0xffF5A623),
                          size: 20.sp,
                        ),
                        HSpace(10.w),
                        Expanded(
                          child: Text(
                            'Tap to view your merchant-wise assigned virtual cards list',
                            style: t.bodySmall?.copyWith(
                              color: Colors.white,
                              fontSize: 11.sp,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        Icon(
                          Icons.chevron_right_rounded,
                          color: Colors.white.withValues(alpha: 0.7),
                          size: 20.sp,
                        ),
                      ],
                    ),
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
                        buildTile(
                          context,
                          onTap: () {
                            Get.toNamed(RoutesName.profileSettingScreen);
                          },
                          img: "$rootImageDir/person.webp",
                          name: storedLanguage['Profile'] ?? 'Profile',
                        ),
                        buildTile(
                          context,
                          onTap: () {
                            Get.toNamed(RoutesName.supportTicketListScreen);
                          },
                          img: "$rootImageDir/support.webp",
                          name: storedLanguage['Support Tickets'] ?? 'Support Tickets',
                        ),
                        buildTile(
                          context,
                          onTap: () {
                            Get.toNamed(RoutesName.notificationScreen);
                          },
                          img: "$rootImageDir/notification.webp",
                          name: storedLanguage['Notifications'] ?? 'Notifications',
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

