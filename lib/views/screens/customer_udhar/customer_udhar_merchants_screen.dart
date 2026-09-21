import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:paysecure/controllers/bindings/controller_index.dart';
import '../../../../config/app_colors.dart';
import '../../../themes/themes.dart';
import '../../../utils/services/localstorage/hive.dart';
import '../../../utils/services/localstorage/keys.dart';
import '../../widgets/custom_appbar.dart';
import '../../widgets/spacing.dart';
import '../../widgets/merchant_status_badge.dart';
import '../../../utils/merchant_status_helper.dart';
import '../mobile_scanner/mobile_scanner_screen.dart';

class CustomerUdharMerchantsScreen extends StatefulWidget {
  const CustomerUdharMerchantsScreen({super.key});

  @override
  State<CustomerUdharMerchantsScreen> createState() => _CustomerUdharMerchantsScreenState();
}

class _CustomerUdharMerchantsScreenState extends State<CustomerUdharMerchantsScreen> {
  final CustomerUdharController _controller = Get.find<CustomerUdharController>();
  final TextEditingController _searchCtrl = TextEditingController();
  String _selectedFilter = 'All';

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
    TextTheme t = Theme.of(context).textTheme;
    var storedLanguage = HiveHelp.read(Keys.languageData) ?? {};

    return Scaffold(
      appBar: CustomAppBar(
        title: storedLanguage["My Udhar Cards"] ?? "My Udhar Cards",
      ),
      body: GetBuilder<CustomerUdharController>(
        builder: (controller) {
          if (controller.isLoadingMerchants) {
            return const Center(child: CircularProgressIndicator());
          }

          if (controller.merchantsList.isEmpty) {
            return RefreshIndicator(
              color: AppColors.mainColor,
              onRefresh: () async {
                await controller.getMerchantsList();
              },
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 40.h),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    VSpace(20.h),
                    // Decorative Card Container
                    Container(
                      width: 120.r,
                      height: 120.r,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          colors: [
                            AppColors.mainColor.withValues(alpha: 0.15),
                            AppColors.mainColor.withValues(alpha: 0.05),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        border: Border.all(
                          color: AppColors.mainColor.withValues(alpha: 0.25),
                          width: 2,
                        ),
                      ),
                      child: Center(
                        child: Icon(
                          Icons.credit_card_rounded,
                          size: 54.sp,
                          color: AppColors.mainColor,
                        ),
                      ),
                    ),
                    VSpace(24.h),
                    Text(
                      "No Active Udhar Cards Yet",
                      style: t.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        fontSize: 20.sp,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    VSpace(10.h),
                    Text(
                      "Visit any Udharcard partner store or scan the merchant's QR code to activate your digital credit limit instantly.",
                      style: t.bodyMedium?.copyWith(
                        color: AppThemes.getBlack50Color(),
                        fontSize: 13.sp,
                        height: 1.5,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    VSpace(32.h),
                    // Primary CTA
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.mainColor,
                        foregroundColor: Colors.white,
                        minimumSize: Size(double.infinity, 50.h),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14.r),
                        ),
                        elevation: 3,
                      ),
                      onPressed: () {
                        Get.to(() => const MobileScannerScreen(
                              isFromMakePaymentPage: true,
                            ));
                      },
                      icon: Icon(Icons.qr_code_scanner_rounded, size: 22.sp),
                      label: Text(
                        "Scan Store QR Code",
                        style: TextStyle(
                          fontSize: 15.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    VSpace(14.h),
                    // Secondary CTA / Explainer
                    TextButton.icon(
                      onPressed: () {
                        Get.bottomSheet(
                          Container(
                            padding: EdgeInsets.all(24.w),
                            decoration: BoxDecoration(
                              color: Get.isDarkMode ? AppColors.darkCardColor : Colors.white,
                              borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
                            ),
                            child: SafeArea(
                              top: false,
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Center(
                                    child: Container(
                                      width: 40.w,
                                      height: 4.h,
                                      decoration: BoxDecoration(
                                        color: Colors.grey.shade300,
                                        borderRadius: BorderRadius.circular(2.r),
                                      ),
                                    ),
                                  ),
                                  VSpace(16.h),
                                  Text(
                                    "How Udharcard Works",
                                    style: TextStyle(
                                      fontSize: 18.sp,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  VSpace(12.h),
                                  _buildHowItWorksStep(
                                    number: "1",
                                    title: "Scan Shop QR Code",
                                    desc: "Scan the merchant's QR at checkout counter in partner stores.",
                                  ),
                                  VSpace(10.h),
                                  _buildHowItWorksStep(
                                    number: "2",
                                    title: "Instant Digital Credit",
                                    desc: "Merchant approves credit limit directly into your account.",
                                  ),
                                  VSpace(10.h),
                                  _buildHowItWorksStep(
                                    number: "3",
                                    title: "Track & Settle Anytime",
                                    desc: "View clear ledger balance and pay anytime using UPI or Cards.",
                                  ),
                                  VSpace(16.h),
                                  SizedBox(
                                    width: double.infinity,
                                    child: ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: AppColors.mainColor,
                                        foregroundColor: Colors.white,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(12.r),
                                        ),
                                      ),
                                      onPressed: () => Get.back(),
                                      child: const Text("Got it"),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          isScrollControlled: true,
                        );
                      },
                      icon: Icon(Icons.info_outline_rounded, size: 18.sp, color: AppColors.mainColor),
                      label: Text(
                        "How does Udharcard work?",
                        style: TextStyle(
                          color: AppColors.mainColor,
                          fontSize: 13.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          final query = _searchCtrl.text.trim().toLowerCase();
          final filteredMerchants = controller.merchantsList.where((item) {
            final name = (item['shop_name'] ?? '').toString().toLowerCase();
            final phone = (item['phone'] ?? '').toString().toLowerCase();
            final matchesQuery = query.isEmpty || name.contains(query) || phone.contains(query);
            if (!matchesQuery) return false;

            if (_selectedFilter == 'Open Now') {
              final status = MerchantStatusHelper.getStatus(
                item is Map<String, dynamic> ? item : Map<String, dynamic>.from(item),
              );
              return status.isOpen;
            } else if (_selectedFilter == 'Has Due') {
              final due = double.tryParse((item['outstanding_balance'] ?? '0').toString()) ?? 0.0;
              return due > 0;
            }
            return true;
          }).toList();

          return RefreshIndicator(
            color: AppColors.mainColor,
            onRefresh: () async {
              await controller.getMerchantsList();
            },
            child: Column(
              children: [
                // Search Bar
                Padding(
                  padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 6.h),
                  child: TextField(
                    controller: _searchCtrl,
                    onChanged: (_) => setState(() {}),
                    decoration: InputDecoration(
                      hintText: "Search store name or phone...",
                      prefixIcon: const Icon(Icons.search, size: 20),
                      suffixIcon: _searchCtrl.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear, size: 18),
                              onPressed: () {
                                _searchCtrl.clear();
                                setState(() {});
                              },
                            )
                          : null,
                      filled: true,
                      fillColor: Get.isDarkMode ? AppColors.darkCardColor : Colors.grey.shade100,
                      contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.r),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
                // Filter Chips
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 4.h),
                  child: Row(
                    children: [
                      _buildFilterChip('All', _selectedFilter == 'All'),
                      SizedBox(width: 8.w),
                      _buildFilterChip('Open Now', _selectedFilter == 'Open Now'),
                      SizedBox(width: 8.w),
                      _buildFilterChip('Has Due', _selectedFilter == 'Has Due'),
                    ],
                  ),
                ),
                Expanded(
                  child: filteredMerchants.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.search_off_rounded, size: 48.sp, color: Colors.grey),
                              SizedBox(height: 12.h),
                              Text(
                                "No stores found matching your criteria",
                                style: t.bodyMedium?.copyWith(color: Colors.grey),
                              ),
                              SizedBox(height: 8.h),
                              TextButton(
                                onPressed: () {
                                  _searchCtrl.clear();
                                  setState(() => _selectedFilter = 'All');
                                },
                                child: const Text("Reset Filters"),
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                          itemCount: filteredMerchants.length,
                          itemBuilder: (context, index) {
                            final item = filteredMerchants[index];
                            final shopName = item['shop_name'] ?? 'Merchant';
                            final outstanding = item['outstanding_balance'] ?? 0.0;
                            final creditLimit = item['credit_limit'] ?? 0.0;
                            final dueDate = item['due_date'] ?? 'N/A';
                
                final double progress = creditLimit > 0 ? (outstanding / creditLimit).clamp(0.0, 1.0) : 0.0;

                return GestureDetector(
                  onTap: () {
                    Get.toNamed(
                      '/customerUdharLedgerScreen',
                      arguments: {
                        'merchant_id': item['merchant_id'],
                        'shop_name': shopName,
                        'merchant_data': item is Map<String, dynamic>
                            ? item
                            : (item != null ? Map<String, dynamic>.from(item) : null),
                      },
                    );
                  },
                  child: Container(
                    margin: EdgeInsets.only(bottom: 16.h),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16.r),
                      gradient: LinearGradient(
                        colors: Get.isDarkMode
                            ? [const Color(0xff122543), const Color(0xff1A3B66)]
                            : [const Color(0xff1E3D59), const Color(0xff17B890)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.1),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Stack(
                      children: [
                        // Decorative card lines
                        Positioned(
                          right: -20.w,
                          top: -20.h,
                          child: CircleAvatar(
                            radius: 60.r,
                            backgroundColor: Colors.white.withValues(alpha: 0.04),
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.all(20.w),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          shopName.toString().toUpperCase(),
                                          style: t.bodyLarge?.copyWith(
                                            color: Colors.white,
                                            fontSize: 16.sp,
                                            fontWeight: FontWeight.bold,
                                            letterSpacing: 1.2,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        VSpace(6.h),
                                        MerchantStatusBadge(
                                          merchantData: item is Map<String, dynamic>
                                              ? item
                                              : (item != null ? Map<String, dynamic>.from(item) : null),
                                          isCompact: true,
                                          showTiming: true,
                                          onCard: true,
                                        ),
                                      ],
                                    ),
                                  ),
                                  SizedBox(width: 8.w),
                                  Container(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 10.w,
                                      vertical: 4.h,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withValues(alpha: 0.15),
                                      borderRadius: BorderRadius.circular(20.r),
                                    ),
                                    child: Text(
                                      "UDHAR",
                                      style: t.bodySmall?.copyWith(
                                        color: Colors.white,
                                        fontSize: 10.sp,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              VSpace(16.h),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "Outstanding Balance",
                                        style: t.bodySmall?.copyWith(
                                          color: Colors.white.withValues(alpha: 0.7),
                                          fontSize: 11.sp,
                                        ),
                                      ),
                                      VSpace(4.h),
                                      Text(
                                        "₹${outstanding.toStringAsFixed(2)}",
                                        style: t.headlineMedium?.copyWith(
                                          color: Colors.white,
                                          fontSize: 22.sp,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Text(
                                        "Due Date",
                                        style: t.bodySmall?.copyWith(
                                          color: Colors.white.withValues(alpha: 0.7),
                                          fontSize: 11.sp,
                                        ),
                                      ),
                                      VSpace(4.h),
                                      Text(
                                        dueDate,
                                        style: t.bodyMedium?.copyWith(
                                          color: Colors.white,
                                          fontSize: 14.sp,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              VSpace(20.h),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    "Limit: ₹${creditLimit.toStringAsFixed(0)}",
                                    style: t.bodySmall?.copyWith(
                                      color: Colors.white.withValues(alpha: 0.8),
                                      fontSize: 12.sp,
                                    ),
                                  ),
                                  Text(
                                    "${(progress * 100).toStringAsFixed(0)}% Used",
                                    style: t.bodySmall?.copyWith(
                                      color: Colors.white.withValues(alpha: 0.8),
                                      fontSize: 12.sp,
                                    ),
                                  ),
                                ],
                              ),
                              VSpace(8.h),
                              ClipRRect(
                                borderRadius: BorderRadius.circular(10.r),
                                child: LinearProgressIndicator(
                                  value: progress,
                                  minHeight: 6.h,
                                  backgroundColor: Colors.white.withValues(alpha: 0.15),
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    progress > 0.85
                                        ? Colors.redAccent
                                        : progress > 0.6
                                            ? Colors.orangeAccent
                                            : Colors.greenAccent,
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
          ),
        ],
      ),
    );
  },
      ),
    );
  }

  Widget _buildHowItWorksStep({
    required String number,
    required String title,
    required String desc,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CircleAvatar(
          radius: 12.r,
          backgroundColor: AppColors.mainColor,
          child: Text(
            number,
            style: TextStyle(
              color: Colors.white,
              fontSize: 11.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        SizedBox(width: 12.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
              VSpace(2.h),
              Text(
                desc,
                style: TextStyle(
                  fontSize: 12.sp,
                  color: AppThemes.getBlack50Color(),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFilterChip(String label, bool isSelected) {
    return ChoiceChip(
      label: Text(
        label,
        style: TextStyle(
          fontSize: 12.sp,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          color: isSelected ? Colors.white : (Get.isDarkMode ? Colors.white70 : Colors.black87),
        ),
      ),
      selected: isSelected,
      onSelected: (selected) {
        if (selected) {
          setState(() => _selectedFilter = label);
        }
      },
      selectedColor: AppColors.mainColor,
      backgroundColor: Get.isDarkMode ? AppColors.darkCardColor : Colors.grey.shade200,
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20.r),
        side: BorderSide(
          color: isSelected ? AppColors.mainColor : Colors.transparent,
        ),
      ),
    );
  }
}
