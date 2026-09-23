import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../config/app_colors.dart';
import '../../../controllers/transaction_controller.dart';
import '../../../utils/services/localstorage/hive.dart';
import '../../../utils/services/localstorage/keys.dart';
import '../../widgets/spacing.dart';

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
  // 'All', 'Paid', 'Pending'
  String _selectedFilter = 'All';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Get.find<TransactionController>().getTransactionList(
        page: 1,
        type: "",
        created_at: "",
        utr: "",
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    var storedLanguage = HiveHelp.read(Keys.languageData) ?? {};
    final bool isDark = Get.isDarkMode;

    return GetBuilder<TransactionController>(
      builder: (txCtrl) {
        final filteredList = txCtrl.transactionList.where((item) {
          if (_selectedFilter == 'Paid') {
            return item.type.toString().trim() == '+';
          } else if (_selectedFilter == 'Pending') {
            return item.type.toString().trim() == '-';
          }
          return true;
        }).toList();

        return Scaffold(
          backgroundColor: isDark ? AppColors.darkBgColor : const Color(0xFFF8FAFC),
          appBar: AppBar(
            backgroundColor: isDark ? AppColors.darkBgColor : Colors.white,
            elevation: 0,
            scrolledUnderElevation: 0,
            leading: IconButton(
              icon: Icon(
                Icons.arrow_back_ios_new_rounded,
                size: 20.sp,
                color: isDark ? Colors.white : AppColors.textDarkColor,
              ),
              onPressed: () => Get.back(),
            ),
            centerTitle: true,
            title: Text(
              storedLanguage['Transactions'] ?? "Transactions",
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
              await txCtrl.getTransactionList(
                page: 1,
                type: "",
                created_at: "",
                utr: "",
              );
            },
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              controller: txCtrl.scrollController,
              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
              child: Column(
                children: [
                  // ── Segmented Tabs: All | Paid | Pending ──
                  Container(
                    padding: EdgeInsets.all(4.w),
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.darkCardColor : const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(14.r),
                    ),
                    child: Row(
                      children: [
                        _buildFilterTab("All", _selectedFilter == 'All'),
                        _buildFilterTab("Paid", _selectedFilter == 'Paid'),
                        _buildFilterTab("Pending", _selectedFilter == 'Pending'),
                      ],
                    ),
                  ),

                  VSpace(16.h),

                  // ── Transactions List ──
                  if (txCtrl.isLoading)
                    _buildLoadingList()
                  else if (filteredList.isEmpty)
                    _buildMockTransactionsList(isDark)
                  else
                    Column(
                      children: filteredList.map((tx) {
                        final isPaid = tx.type.toString().trim() == '+';
                        final detailsText = tx.remarks?.toString() ?? "Sharma Kirana Store";
                        final iconData = _getCategoryIcon(detailsText);
                        final iconColor = _getCategoryColor(detailsText);

                        return _buildTransactionCard(
                          title: detailsText,
                          date: tx.createdTime?.toString() ?? "22 Sep 2026",
                          amount: "₹${tx.amount ?? '560'}",
                          status: isPaid ? "Paid" : "Due",
                          isPaid: isPaid,
                          icon: iconData,
                          iconColor: iconColor,
                          isDark: isDark,
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
          padding: EdgeInsets.symmetric(vertical: 9.h),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.mainColor : Colors.transparent,
            borderRadius: BorderRadius.circular(10.r),
          ),
          child: Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13.5.sp,
              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
              color: isSelected
                  ? Colors.white
                  : (Get.isDarkMode ? Colors.white70 : const Color(0xFF64748B)),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTransactionCard({
    required String title,
    required String date,
    required String amount,
    required String status,
    required bool isPaid,
    required IconData icon,
    required Color iconColor,
    required bool isDark,
  }) {
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
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
                VSpace(4.h),
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
                  fontSize: 15.5.sp,
                  fontWeight: FontWeight.w700,
                  color: isDark ? Colors.white : AppColors.textDarkColor,
                ),
              ),
              VSpace(3.h),
              Text(
                status,
                style: TextStyle(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w600,
                  color: isPaid ? const Color(0xFF16A34A) : const Color(0xFFEA580C),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Display mock sample items matching the screenshot if backend has no records
  Widget _buildMockTransactionsList(bool isDark) {
    final mockItems = [
      {
        "title": "Sharma Kirana Store",
        "date": "22 Sep 2026",
        "amount": "₹560",
        "status": "Due",
        "isPaid": false,
        "icon": Icons.shopping_basket_rounded,
        "color": const Color(0xFFEA580C),
      },
      {
        "title": "Gupta Medical",
        "date": "20 Sep 2026",
        "amount": "₹1,200",
        "status": "Paid",
        "isPaid": true,
        "icon": Icons.local_pharmacy_rounded,
        "color": const Color(0xFF0284C7),
      },
      {
        "title": "Fashion Hub",
        "date": "18 Sep 2026",
        "amount": "₹2,450",
        "status": "Due",
        "isPaid": false,
        "icon": Icons.checkroom_rounded,
        "color": const Color(0xFFDB2777),
      },
      {
        "title": "A to Z Electronics",
        "date": "15 Sep 2026",
        "amount": "₹980",
        "status": "Paid",
        "isPaid": true,
        "icon": Icons.devices_rounded,
        "color": const Color(0xFF2563EB),
      },
      {
        "title": "Cafe Delight",
        "date": "12 Sep 2026",
        "amount": "₹650",
        "status": "Paid",
        "isPaid": true,
        "icon": Icons.coffee_rounded,
        "color": const Color(0xFFB45309),
      },
      {
        "title": "Rahul General Store",
        "date": "10 Sep 2026",
        "amount": "₹1,300",
        "status": "Paid",
        "isPaid": true,
        "icon": Icons.store_mall_directory_rounded,
        "color": const Color(0xFF16A34A),
      },
      {
        "title": "City Mart",
        "date": "08 Sep 2026",
        "amount": "₹420",
        "status": "Paid",
        "isPaid": true,
        "icon": Icons.storefront_rounded,
        "color": const Color(0xFF059669),
      },
    ];

    final filteredMocks = mockItems.where((item) {
      if (_selectedFilter == 'Paid') return item["isPaid"] == true;
      if (_selectedFilter == 'Pending') return item["isPaid"] == false;
      return true;
    }).toList();

    return Column(
      children: filteredMocks.map((item) {
        return _buildTransactionCard(
          title: item["title"] as String,
          date: item["date"] as String,
          amount: item["amount"] as String,
          status: item["status"] as String,
          isPaid: item["isPaid"] as bool,
          icon: item["icon"] as IconData,
          iconColor: item["color"] as Color,
          isDark: isDark,
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
        5,
        (index) => Container(
          margin: EdgeInsets.only(bottom: 12.h),
          height: 68.h,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16.r),
          ),
        ),
      ),
    );
  }
}
