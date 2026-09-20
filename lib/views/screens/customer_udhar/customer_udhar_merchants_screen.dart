import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:paysecure/controllers/bindings/controller_index.dart';
import '../../../../config/app_colors.dart';
import '../../../themes/themes.dart';
import '../../../utils/services/localstorage/hive.dart';
import '../../../utils/services/localstorage/keys.dart';
import '../../widgets/custom_appbar.dart';
import '../../widgets/spacing.dart';

class CustomerUdharMerchantsScreen extends StatefulWidget {
  const CustomerUdharMerchantsScreen({super.key});

  @override
  State<CustomerUdharMerchantsScreen> createState() => _CustomerUdharMerchantsScreenState();
}

class _CustomerUdharMerchantsScreenState extends State<CustomerUdharMerchantsScreen> {
  final CustomerUdharController _controller = Get.find<CustomerUdharController>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _controller.getMerchantsList();
    });
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
              child: Stack(
                children: [
                  ListView(),
                  Center(
                    child: Text(
                      "No active Udhar cards found",
                      style: t.bodyMedium?.copyWith(
                        color: AppThemes.getBlack50Color(),
                      ),
                    ),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            color: AppColors.mainColor,
            onRefresh: () async {
              await controller.getMerchantsList();
            },
            child: ListView.builder(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
              itemCount: controller.merchantsList.length,
              itemBuilder: (context, index) {
                final item = controller.merchantsList[index];
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
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Text(
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
                                  ),
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
                              VSpace(25.h),
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
          );
        },
      ),
    );
  }
}
