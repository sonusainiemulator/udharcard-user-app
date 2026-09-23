import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../config/app_colors.dart';
import '../../../controllers/customer_udhar_controller.dart';
import '../../../utils/services/localstorage/hive.dart';
import '../../../utils/services/localstorage/keys.dart';
import '../../widgets/spacing.dart';
import 'customer_udhar_ledger_screen.dart';

class CustomerUdharMerchantsScreen extends StatefulWidget {
  const CustomerUdharMerchantsScreen({super.key});

  @override
  State<CustomerUdharMerchantsScreen> createState() =>
      _CustomerUdharMerchantsScreenState();
}

class _CustomerUdharMerchantsScreenState
    extends State<CustomerUdharMerchantsScreen> {
  final CustomerUdharController _controller =
      Get.put(CustomerUdharController());
  final TextEditingController _searchCtrl = TextEditingController();
  String _selectedCategory = 'All';

  final List<String> _categories = [
    'All',
    'Grocery',
    'Medical',
    'Electronics',
    'Restaurant',
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _controller.getMerchantsList();
    });
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var storedLanguage = HiveHelp.read(Keys.languageData) ?? {};
    final bool isDark = Get.isDarkMode;

    return GetBuilder<CustomerUdharController>(
      builder: (controller) {
        final query = _searchCtrl.text.toLowerCase().trim();
        final filteredMerchants = controller.merchantsList.where((m) {
          final matchesCategory = _selectedCategory == 'All' ||
              (m.shopName ?? '').toLowerCase().contains(_selectedCategory.toLowerCase()) ||
              (m.merchantName ?? '').toLowerCase().contains(_selectedCategory.toLowerCase());
          final matchesQuery = query.isEmpty ||
              (m.shopName ?? '').toLowerCase().contains(query) ||
              (m.merchantName ?? '').toLowerCase().contains(query);
          return matchesCategory && matchesQuery;
        }).toList();

        return Scaffold(
          backgroundColor: isDark ? AppColors.darkBgColor : const Color(0xFFF8FAFC),
          appBar: AppBar(
            backgroundColor: isDark ? AppColors.darkBgColor : Colors.white,
            elevation: 0,
            scrolledUnderElevation: 0,
            leading: Navigator.of(context).canPop()
                ? IconButton(
                    icon: Icon(
                      Icons.arrow_back_ios_new_rounded,
                      size: 20.sp,
                      color: isDark ? Colors.white : AppColors.textDarkColor,
                    ),
                    onPressed: () => Get.back(),
                  )
                : null,
            centerTitle: true,
            title: Text(
              storedLanguage['Nearby Merchants'] ?? "Nearby Merchants",
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.w700,
                color: isDark ? Colors.white : AppColors.textDarkColor,
              ),
            ),
          ),
          body: RefreshIndicator(
            color: AppColors.mainColor,
            onRefresh: () async {
              await controller.getMerchantsList();
            },
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Search Bar with Filter Icon ──
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          height: 48.h,
                          decoration: BoxDecoration(
                            color: isDark ? AppColors.darkCardColor : Colors.white,
                            borderRadius: BorderRadius.circular(12.r),
                            border: Border.all(
                              color: isDark ? Colors.white12 : AppColors.cardBorderColor,
                              width: 1.2,
                            ),
                          ),
                          child: Row(
                            children: [
                              Padding(
                                padding: EdgeInsets.symmetric(horizontal: 12.w),
                                child: Icon(
                                  Icons.search_rounded,
                                  size: 20.sp,
                                  color: AppColors.textMutedColor,
                                ),
                              ),
                              Expanded(
                                child: TextField(
                                  controller: _searchCtrl,
                                  onChanged: (_) => setState(() {}),
                                  style: TextStyle(
                                    fontSize: 14.sp,
                                    color: isDark ? Colors.white : AppColors.textDarkColor,
                                  ),
                                  decoration: InputDecoration(
                                    border: InputBorder.none,
                                    enabledBorder: InputBorder.none,
                                    focusedBorder: InputBorder.none,
                                    hintText: "Search shops or categories...",
                                    hintStyle: TextStyle(
                                      fontSize: 13.5.sp,
                                      color: AppColors.textFieldHintColor,
                                    ),
                                    contentPadding: EdgeInsets.zero,
                                  ),
                                ),
                              ),
                              if (_searchCtrl.text.isNotEmpty)
                                IconButton(
                                  icon: Icon(Icons.close_rounded, size: 18.sp),
                                  onPressed: () {
                                    _searchCtrl.clear();
                                    setState(() {});
                                  },
                                ),
                            ],
                          ),
                        ),
                      ),
                      HSpace(10.w),
                      Container(
                        width: 48.h,
                        height: 48.h,
                        decoration: BoxDecoration(
                          color: isDark ? AppColors.darkCardColor : Colors.white,
                          borderRadius: BorderRadius.circular(12.r),
                          border: Border.all(
                            color: isDark ? Colors.white12 : AppColors.cardBorderColor,
                            width: 1.2,
                          ),
                        ),
                        child: Center(
                          child: Icon(
                            Icons.tune_rounded,
                            size: 20.sp,
                            color: AppColors.textDarkColor,
                          ),
                        ),
                      ),
                    ],
                  ),

                  VSpace(16.h),

                  // ── Category Chips ──
                  SizedBox(
                    height: 38.h,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: _categories.length,
                      separatorBuilder: (_, __) => HSpace(8.w),
                      itemBuilder: (context, index) {
                        final cat = _categories[index];
                        final isSelected = _selectedCategory == cat;
                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              _selectedCategory = cat;
                            });
                          },
                          child: Container(
                            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? AppColors.mainColor
                                  : (isDark ? AppColors.darkCardColor : const Color(0xFFF1F5F9)),
                              borderRadius: BorderRadius.circular(20.r),
                            ),
                            child: Center(
                              child: Text(
                                cat,
                                style: TextStyle(
                                  fontSize: 13.sp,
                                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                                  color: isSelected
                                      ? Colors.white
                                      : (isDark ? Colors.white70 : const Color(0xFF475569)),
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),

                  VSpace(18.h),

                  // ── Merchants List ──
                  if (controller.isLoadingMerchants)
                    _buildLoadingList()
                  else if (filteredMerchants.isEmpty)
                    _buildMockMerchantsList(isDark)
                  else
                    Column(
                      children: filteredMerchants.map((merchant) {
                        final shopName = merchant.shopName ?? merchant.merchantName ?? "Shop";
                        final iconData = _getCategoryIcon(shopName);
                        final iconColor = _getCategoryColor(shopName);

                        return _buildMerchantCard(
                          title: shopName,
                          category: "Retail Merchant",
                          ratingText: "4.8 | 0.5 km",
                          icon: iconData,
                          iconColor: iconColor,
                          isDark: isDark,
                          onView: () {
                            Get.to(
                              () => const CustomerUdharLedgerScreen(),
                              arguments: {
                                'merchant_id': int.tryParse(merchant.merchantId?.toString() ?? '1') ?? 1,
                                'shop_name': shopName,
                                'merchant_data': null,
                              },
                            );
                          },
                        );
                      }).toList(),
                    ),
                  VSpace(30.h),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildMerchantCard({
    required String title,
    required String category,
    required String ratingText,
    required IconData icon,
    required Color iconColor,
    required bool isDark,
    required VoidCallback onView,
  }) {
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCardColor : Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: isDark ? Colors.white12 : AppColors.cardBorderColor,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 48.r,
            height: 48.r,
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(14.r),
            ),
            child: Center(
              child: Icon(icon, color: iconColor, size: 24.sp),
            ),
          ),
          HSpace(14.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white : AppColors.textDarkColor,
                  ),
                ),
                VSpace(3.h),
                Text(
                  category,
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: AppColors.textMutedColor,
                  ),
                ),
                VSpace(4.h),
                Row(
                  children: [
                    Icon(
                      Icons.star_rounded,
                      size: 14.sp,
                      color: const Color(0xFFF59E0B),
                    ),
                    HSpace(4.w),
                    Text(
                      ratingText,
                      style: TextStyle(
                        fontSize: 11.5.sp,
                        fontWeight: FontWeight.w500,
                        color: isDark ? Colors.white70 : const Color(0xFF475569),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          OutlinedButton(
            onPressed: onView,
            style: OutlinedButton.styleFrom(
              side: BorderSide(
                color: AppColors.mainColor.withValues(alpha: 0.8),
                width: 1.2,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18.r),
              ),
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 6.h),
              minimumSize: Size.zero,
            ),
            child: Text(
              "View",
              style: TextStyle(
                fontSize: 13.sp,
                fontWeight: FontWeight.w600,
                color: AppColors.mainColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Display sample merchants matching screenshot if backend merchants list is currently empty
  Widget _buildMockMerchantsList(bool isDark) {
    final mockMerchants = [
      {
        "title": "Sharma Kirana Store",
        "category": "Grocery",
        "rating": "4.8 | 0.5 km",
        "icon": Icons.shopping_basket_rounded,
        "color": const Color(0xFFEA580C),
      },
      {
        "title": "Gupta Medical",
        "category": "Medical",
        "rating": "4.6 | 0.8 km",
        "icon": Icons.local_pharmacy_rounded,
        "color": const Color(0xFF0284C7),
      },
      {
        "title": "Fashion Hub",
        "category": "Fashion",
        "rating": "4.7 | 1.2 km",
        "icon": Icons.checkroom_rounded,
        "color": const Color(0xFFDB2777),
      },
      {
        "title": "A to Z Electronics",
        "category": "Electronics",
        "rating": "4.5 | 1.5 km",
        "icon": Icons.devices_rounded,
        "color": const Color(0xFF2563EB),
      },
      {
        "title": "Cafe Delight",
        "category": "Restaurant",
        "rating": "4.6 | 1.8 km",
        "icon": Icons.coffee_rounded,
        "color": const Color(0xFFB45309),
      },
    ];

    final filteredMocks = mockMerchants.where((m) {
      final matchesCategory = _selectedCategory == 'All' ||
          (m["category"] as String).toLowerCase() == _selectedCategory.toLowerCase();
      final query = _searchCtrl.text.toLowerCase().trim();
      final matchesQuery = query.isEmpty ||
          (m["title"] as String).toLowerCase().contains(query) ||
          (m["category"] as String).toLowerCase().contains(query);
      return matchesCategory && matchesQuery;
    }).toList();

    return Column(
      children: filteredMocks.map((item) {
        return _buildMerchantCard(
          title: item["title"] as String,
          category: item["category"] as String,
          ratingText: item["rating"] as String,
          icon: item["icon"] as IconData,
          iconColor: item["color"] as Color,
          isDark: isDark,
          onView: () {
            Get.to(
              () => const CustomerUdharLedgerScreen(),
              arguments: {
                'merchant_id': 1,
                'shop_name': item["title"] as String,
                'merchant_data': null,
              },
            );
          },
        );
      }).toList(),
    );
  }

  IconData _getCategoryIcon(String text) {
    final lower = text.toLowerCase();
    if (lower.contains('medical') || lower.contains('pharma')) {
      return Icons.local_pharmacy_rounded;
    } else if (lower.contains('fashion') || lower.contains('wear') || lower.contains('cloth')) {
      return Icons.checkroom_rounded;
    } else if (lower.contains('electro') || lower.contains('mobile')) {
      return Icons.devices_rounded;
    } else if (lower.contains('cafe') || lower.contains('coffee') || lower.contains('restau')) {
      return Icons.coffee_rounded;
    }
    return Icons.shopping_basket_rounded;
  }

  Color _getCategoryColor(String text) {
    final lower = text.toLowerCase();
    if (lower.contains('medical') || lower.contains('pharma')) {
      return const Color(0xFF0284C7);
    } else if (lower.contains('fashion') || lower.contains('wear') || lower.contains('cloth')) {
      return const Color(0xFFDB2777);
    } else if (lower.contains('electro') || lower.contains('mobile')) {
      return const Color(0xFF2563EB);
    } else if (lower.contains('cafe') || lower.contains('coffee') || lower.contains('restau')) {
      return const Color(0xFFB45309);
    }
    return const Color(0xFFEA580C);
  }

  Widget _buildLoadingList() {
    return Column(
      children: List.generate(
        4,
        (index) => Container(
          margin: EdgeInsets.only(bottom: 12.h),
          height: 72.h,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16.r),
          ),
        ),
      ),
    );
  }
}
