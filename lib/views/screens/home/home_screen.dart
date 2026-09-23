import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../config/app_colors.dart';
import '../../../controllers/app_controller.dart';
import '../../../controllers/customer_udhar_controller.dart';
import '../../../controllers/profile_controller.dart';
import '../../../controllers/transaction_controller.dart';
import '../../../notification_service/notification_controller.dart';
import '../../../routes/routes_name.dart';
import '../../../utils/app_constants.dart';
import '../../../utils/services/localstorage/hive.dart';
import '../../../utils/services/localstorage/keys.dart';
import '../../widgets/spacing.dart';
import '../mobile_scanner/mobile_scanner_screen.dart';

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
    Get.put(CustomerUdharController());
  }

  @override
  Widget build(BuildContext context) {
    var storedLanguage = HiveHelp.read(Keys.languageData) ?? {};
    final bool isDark = Get.isDarkMode;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBgColor : const Color(0xFFF8FAFC),
      key: scaffoldKey,
      drawer: buildDrawer(context, storedLanguage),
      body: SafeArea(
        child: RefreshIndicator(
          color: AppColors.mainColor,
          onRefresh: () async {
            await Future.wait([
              Get.find<AppController>().getDashboard(),
              Get.find<ProfileController>().getProfile(),
              Get.find<TransactionController>().getTransactionList(
                page: 1,
                type: "",
                created_at: "",
                utr: "",
              ),
            ]);
          },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── 1. Top Bar (Avatar + Hello Name, Bell Icon, Profile Thumb) ──
                GetBuilder<ProfileController>(
                  builder: (profileCtrl) {
                    final userName = profileCtrl.userName.isNotEmpty
                        ? profileCtrl.userName
                        : (HiveHelp.read(Keys.userFullName) ?? 'Sonu Saini');
                    return Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // Left: Drawer menu & Greeting
                        Row(
                          children: [
                            GestureDetector(
                              onTap: () {
                                scaffoldKey.currentState?.openDrawer();
                              },
                              child: _buildAvatarCircle(
                                profileCtrl.userPhoto,
                                size: 44.r,
                              ),
                            ),
                            HSpace(12.w),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Hello,",
                                  style: TextStyle(
                                    fontSize: 13.sp,
                                    color: isDark ? Colors.white70 : AppColors.textMutedColor,
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                                Text(
                                  userName,
                                  style: TextStyle(
                                    fontSize: 17.sp,
                                    fontWeight: FontWeight.w700,
                                    color: isDark ? Colors.white : AppColors.textDarkColor,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),

                        // Right: Notification Bell with Badge & Profile Thumbnail
                        Row(
                          children: [
                            Stack(
                              children: [
                                Container(
                                  width: 42.r,
                                  height: 42.r,
                                  decoration: BoxDecoration(
                                    color: isDark ? AppColors.darkCardColor : Colors.white,
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: isDark ? Colors.white24 : AppColors.cardBorderColor,
                                    ),
                                  ),
                                  child: IconButton(
                                    icon: Icon(
                                      Icons.notifications_none_rounded,
                                      size: 22.sp,
                                      color: isDark ? Colors.white : AppColors.textDarkColor,
                                    ),
                                    onPressed: () {
                                      Get.put(PushNotificationController()).isNotiSeen();
                                      Get.toNamed(RoutesName.notificationScreen);
                                    },
                                  ),
                                ),
                                Positioned(
                                  top: 10.r,
                                  right: 10.r,
                                  child: Container(
                                    width: 8.r,
                                    height: 8.r,
                                    decoration: const BoxDecoration(
                                      color: Color(0xFFEF4444),
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            HSpace(10.w),
                            GestureDetector(
                              onTap: () {
                                Get.toNamed(RoutesName.profileSettingScreen);
                              },
                              child: _buildAvatarCircle(
                                profileCtrl.userPhoto,
                                size: 40.r,
                              ),
                            ),
                          ],
                        ),
                      ],
                    );
                  },
                ),

                VSpace(20.h),

                // ── 2. Hero Card: Your Available Limit ──
                GetBuilder<AppController>(
                  builder: (appCtrl) {
                    final balance = appCtrl.walletList.isNotEmpty
                        ? appCtrl.walletList[0].totalBalance?.toString() ?? '25,000'
                        : '25,000';
                    final symbol = appCtrl.walletList.isNotEmpty
                        ? appCtrl.walletList[0].currency?.symbol ?? '₹'
                        : '₹';
                    return _buildAvailableLimitHeroCard(
                      limitAmount: "$symbol$balance",
                      onViewDetails: () {
                        Get.toNamed(RoutesName.customerUdharMerchantsScreen);
                      },
                    );
                  },
                ),

                VSpace(24.h),

                // ── 3. Quick Action 4-Grid ──
                _buildQuickActionGrid(),

                VSpace(28.h),

                // ── 4. Nearby Merchants Section Header & Categories ──
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      storedLanguage['Nearby Merchants'] ?? "Nearby Merchants",
                      style: TextStyle(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.w700,
                        color: isDark ? Colors.white : AppColors.textDarkColor,
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        Get.toNamed(RoutesName.customerUdharMerchantsScreen);
                      },
                      child: Text(
                        storedLanguage['View All'] ?? "View All",
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w600,
                          color: AppColors.mainColor,
                        ),
                      ),
                    ),
                  ],
                ),
                VSpace(14.h),
                _buildMerchantCategories(),

                VSpace(24.h),

                // ── 5. Promo Banner: Shop Now Pay Later ──
                _buildShopNowPayLaterBanner(),

                VSpace(28.h),

                // ── 6. Recent Transactions Section ──
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      storedLanguage['Recent Transactions'] ?? "Recent Transactions",
                      style: TextStyle(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.w700,
                        color: isDark ? Colors.white : AppColors.textDarkColor,
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        Get.toNamed(RoutesName.transactionScreen);
                      },
                      child: Text(
                        storedLanguage['View All'] ?? "View All",
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w600,
                          color: AppColors.mainColor,
                        ),
                      ),
                    ),
                  ],
                ),
                VSpace(14.h),
                _buildRecentTransactionsList(),

                VSpace(30.h),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAvatarCircle(String? url, {required double size}) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: AppColors.mainColor.withValues(alpha: 0.3),
          width: 1.5,
        ),
        color: AppColors.lightBlueTint,
      ),
      child: ClipOval(
        child: (url != null && url.isNotEmpty)
            ? CachedNetworkImage(
                imageUrl: url,
                fit: BoxFit.cover,
                errorWidget: (_, __, ___) => Image.asset(
                  "$rootImageDir/avatar.webp",
                  fit: BoxFit.cover,
                ),
              )
            : Image.asset(
                "$rootImageDir/avatar.webp",
                fit: BoxFit.cover,
              ),
      ),
    );
  }

  Widget _buildAvailableLimitHeroCard({
    required String limitAmount,
    required VoidCallback onViewDetails,
  }) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 22.w, vertical: 22.h),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22.r),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.heroGradientStart,
            AppColors.heroGradientEnd,
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.mainColor.withValues(alpha: 0.35),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Subtle decorative shapes
          Positioned(
            right: -30.w,
            top: -30.h,
            child: Container(
              width: 130.r,
              height: 130.r,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.08),
              ),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Your Available Limit",
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w400,
                  color: Colors.white.withValues(alpha: 0.85),
                  letterSpacing: 0.3,
                ),
              ),
              VSpace(8.h),
              Text(
                limitAmount,
                style: TextStyle(
                  fontSize: 32.sp,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                  letterSpacing: -0.5,
                ),
              ),
              VSpace(18.h),
              GestureDetector(
                onTap: onViewDetails,
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 8.h),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24.r),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.08),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        "View Details",
                        style: TextStyle(
                          fontSize: 13.sp,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textDarkColor,
                        ),
                      ),
                      HSpace(6.w),
                      Icon(
                        Icons.arrow_forward_rounded,
                        size: 15.sp,
                        color: AppColors.textDarkColor,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionGrid() {
    final actions = [
      {
        "label": "Scan & Pay",
        "icon": Icons.qr_code_scanner_rounded,
        "color": const Color(0xFF0284C7),
        "bgColor": const Color(0xFFE0F2FE),
        "onTap": () => Get.to(() => const MobileScannerScreen(isFromMakePaymentPage: true)),
      },
      {
        "label": "My Udhari",
        "icon": Icons.credit_card_rounded,
        "color": const Color(0xFF4F46E5),
        "bgColor": const Color(0xFFEEF2FF),
        "onTap": () => Get.toNamed(RoutesName.customerUdharMerchantsScreen),
      },
      {
        "label": "Payments",
        "icon": Icons.account_balance_wallet_rounded,
        "color": const Color(0xFF2563EB),
        "bgColor": const Color(0xFFEFF6FF),
        "onTap": () => Get.toNamed(RoutesName.makePaymentScreen),
      },
      {
        "label": "Offers",
        "icon": Icons.card_giftcard_rounded,
        "color": const Color(0xFFD97706),
        "bgColor": const Color(0xFFFEF3C7),
        "onTap": () => Get.toNamed(RoutesName.voucherScreen),
      },
    ];

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: actions.map((item) {
        return GestureDetector(
          onTap: item["onTap"] as VoidCallback,
          child: Column(
            children: [
              Container(
                width: 68.w,
                height: 68.w,
                decoration: BoxDecoration(
                  color: item["bgColor"] as Color,
                  borderRadius: BorderRadius.circular(18.r),
                  border: Border.all(
                    color: (item["color"] as Color).withValues(alpha: 0.15),
                    width: 1,
                  ),
                ),
                child: Center(
                  child: Icon(
                    item["icon"] as IconData,
                    size: 28.sp,
                    color: item["color"] as Color,
                  ),
                ),
              ),
              VSpace(8.h),
              Text(
                item["label"] as String,
                style: TextStyle(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w600,
                  color: Get.isDarkMode ? Colors.white : AppColors.textDarkColor,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildMerchantCategories() {
    final categories = [
      {"name": "Grocery", "icon": Icons.shopping_basket_rounded, "color": const Color(0xFFEA580C)},
      {"name": "Medical", "icon": Icons.local_pharmacy_rounded, "color": const Color(0xFF0284C7)},
      {"name": "Electronics", "icon": Icons.devices_rounded, "color": const Color(0xFF2563EB)},
      {"name": "Fashion", "icon": Icons.checkroom_rounded, "color": const Color(0xFFDB2777)},
      {"name": "Restaurant", "icon": Icons.coffee_rounded, "color": const Color(0xFFB45309)},
    ];

    return SizedBox(
      height: 80.h,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        separatorBuilder: (_, __) => HSpace(12.w),
        itemBuilder: (context, index) {
          final cat = categories[index];
          final color = cat["color"] as Color;
          return GestureDetector(
            onTap: () => Get.toNamed(RoutesName.customerUdharMerchantsScreen),
            child: Column(
              children: [
                Container(
                  width: 52.w,
                  height: 52.w,
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(16.r),
                    border: Border.all(
                      color: color.withValues(alpha: 0.2),
                    ),
                  ),
                  child: Center(
                    child: Icon(
                      cat["icon"] as IconData,
                      size: 24.sp,
                      color: color,
                    ),
                  ),
                ),
                VSpace(6.h),
                Text(
                  cat["name"] as String,
                  style: TextStyle(
                    fontSize: 11.5.sp,
                    fontWeight: FontWeight.w500,
                    color: Get.isDarkMode ? Colors.white70 : AppColors.textDarkColor,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildShopNowPayLaterBanner() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20.r),
        gradient: LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [
            const Color(0xFF1D4ED8),
            const Color(0xFF3B82F6),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF3B82F6).withValues(alpha: 0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Shop Now\nPay Later",
                  style: TextStyle(
                    fontSize: 19.sp,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    height: 1.2,
                  ),
                ),
                VSpace(6.h),
                Text(
                  "Support Local Business",
                  style: TextStyle(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w500,
                    color: Colors.white.withValues(alpha: 0.9),
                  ),
                ),
              ],
            ),
          ),
          Image.asset(
            "$rootImageDir/shopping_bags_promo.png",
            height: 72.h,
            fit: BoxFit.contain,
          ),
        ],
      ),
    );
  }

  Widget _buildRecentTransactionsList() {
    return GetBuilder<TransactionController>(
      builder: (txCtrl) {
        if (txCtrl.transactionList.isNotEmpty) {
          final recentList = txCtrl.transactionList.take(3).toList();
          return Column(
            children: recentList.map((tx) {
              final isPositive = tx.type.toString().trim() == '+';
              return _buildTransactionItem(
                title: tx.remarks?.toString() ?? "Sharma Kirana Store",
                date: tx.createdTime?.toString() ?? "22 Sep 2026",
                amount: "${isPositive ? '+' : '-'}₹${tx.amount ?? '560'}",
                statusText: isPositive ? "Paid" : "Due",
                isPositive: isPositive,
                icon: Icons.store_mall_directory_rounded,
                iconColor: const Color(0xFF16A34A),
              );
            }).toList(),
          );
        }

        // Default display matching screenshot when list is empty
        return Column(
          children: [
            _buildTransactionItem(
              title: "Sharma Kirana Store",
              date: "22 Sep 2026",
              amount: "₹560",
              statusText: "Due",
              isPositive: false,
              icon: Icons.store_mall_directory_rounded,
              iconColor: const Color(0xFF16A34A),
            ),
          ],
        );
      },
    );
  }

  Widget _buildTransactionItem({
    required String title,
    required String date,
    required String amount,
    required String statusText,
    required bool isPositive,
    required IconData icon,
    required Color iconColor,
  }) {
    final bool isDark = Get.isDarkMode;
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCardColor : Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: isDark ? Colors.white12 : AppColors.cardBorderColor,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 44.r,
            height: 44.r,
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Center(
              child: Icon(icon, color: iconColor, size: 22.sp),
            ),
          ),
          HSpace(12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14.5.sp,
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white : AppColors.textDarkColor,
                  ),
                ),
                VSpace(3.h),
                Text(
                  date,
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: AppColors.textMutedColor,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                amount,
                style: TextStyle(
                  fontSize: 15.sp,
                  fontWeight: FontWeight.w700,
                  color: isDark ? Colors.white : AppColors.textDarkColor,
                ),
              ),
              VSpace(2.h),
              Text(
                statusText,
                style: TextStyle(
                  fontSize: 11.5.sp,
                  fontWeight: FontWeight.w600,
                  color: isPositive ? const Color(0xFF16A34A) : const Color(0xFFEA580C),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ── Drawer ───────────────────────────────────────────────────────────────────
  Widget buildDrawer(BuildContext context, Map storedLanguage) {
    final bool isDark = Get.isDarkMode;
    return Drawer(
      backgroundColor: isDark ? AppColors.darkBgColor : Colors.white,
      child: SafeArea(
        child: Column(
          children: [
            GetBuilder<ProfileController>(
              builder: (profileCtrl) {
                return Container(
                  padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 24.h),
                  decoration: BoxDecoration(
                    color: AppColors.mainColor.withValues(alpha: 0.08),
                  ),
                  child: Row(
                    children: [
                      _buildAvatarCircle(profileCtrl.userPhoto, size: 56.r),
                      HSpace(14.w),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              profileCtrl.userName.isNotEmpty
                                  ? profileCtrl.userName
                                  : "Sonu Saini",
                              style: TextStyle(
                                fontSize: 16.sp,
                                fontWeight: FontWeight.w700,
                                color: isDark ? Colors.white : AppColors.textDarkColor,
                              ),
                            ),
                            VSpace(2.h),
                            Text(
                              profileCtrl.userEmail.isNotEmpty
                                  ? profileCtrl.userEmail
                                  : "Customer",
                              style: TextStyle(
                                fontSize: 12.sp,
                                color: AppColors.textMutedColor,
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
              child: ListView(
                padding: EdgeInsets.symmetric(vertical: 10.h),
                children: [
                  _buildDrawerTile(
                    icon: Icons.credit_card_rounded,
                    title: "My Udhar Cards",
                    onTap: () => Get.toNamed(RoutesName.customerUdharMerchantsScreen),
                  ),
                  _buildDrawerTile(
                    icon: Icons.history_rounded,
                    title: "Transactions",
                    onTap: () => Get.toNamed(RoutesName.transactionScreen),
                  ),
                  _buildDrawerTile(
                    icon: Icons.qr_code_scanner_rounded,
                    title: "Scan & Pay",
                    onTap: () => Get.to(() => const MobileScannerScreen(isFromMakePaymentPage: true)),
                  ),
                  _buildDrawerTile(
                    icon: Icons.person_outline_rounded,
                    title: "My Profile",
                    onTap: () => Get.toNamed(RoutesName.profileSettingScreen),
                  ),
                  _buildDrawerTile(
                    icon: Icons.support_agent_rounded,
                    title: "Support",
                    onTap: () => Get.toNamed(RoutesName.supportTicketListScreen),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawerTile({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: AppColors.mainColor, size: 22.sp),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 15.sp,
          fontWeight: FontWeight.w500,
        ),
      ),
      trailing: Icon(Icons.chevron_right_rounded, size: 20.sp),
      onTap: onTap,
    );
  }
}

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
          color: isReverseColor == true
              ? const Color(0xFFF1F5F9)
              : (Get.isDarkMode ? AppColors.darkCardColor : Colors.white),
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(
            color: Get.isDarkMode ? Colors.white12 : AppColors.cardBorderColor,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 40.h,
              height: 40.h,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12.r),
                color: Get.isDarkMode
                    ? AppColors.darkBgColor
                    : const Color(0xFFE2E8F0),
              ),
            ),
            SizedBox(width: 10.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    height: 10.h,
                    width: double.maxFinite,
                    decoration: BoxDecoration(
                      color: Get.isDarkMode
                          ? AppColors.darkBgColor
                          : const Color(0xFFE2E8F0),
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                  ),
                  SizedBox(height: 5.h),
                  Container(
                    height: 10.h,
                    width: 100.w,
                    decoration: BoxDecoration(
                      color: Get.isDarkMode
                          ? AppColors.darkBgColor
                          : const Color(0xFFE2E8F0),
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

