import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:paysecure/controllers/bindings/controller_index.dart';
import '../../../../config/app_colors.dart';
import '../../../config/dimensions.dart';
import '../../../themes/themes.dart';
import '../../../utils/services/helpers.dart';
import '../../../utils/services/localstorage/hive.dart';
import '../../../utils/services/localstorage/keys.dart';
import '../../widgets/app_button.dart';
import '../../widgets/custom_appbar.dart';
import '../../widgets/custom_textfield.dart';
import '../../widgets/spacing.dart';

class CustomerUdharLedgerScreen extends StatefulWidget {
  const CustomerUdharLedgerScreen({super.key});

  @override
  State<CustomerUdharLedgerScreen> createState() => _CustomerUdharLedgerScreenState();
}

class _CustomerUdharLedgerScreenState extends State<CustomerUdharLedgerScreen> {
  final CustomerUdharController _controller = Get.find<CustomerUdharController>();
  late int merchantId;
  late String shopName;

  @override
  void initState() {
    super.initState();
    final args = Get.arguments as Map<String, dynamic>;
    merchantId = args['merchant_id'];
    shopName = args['shop_name'];

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _controller.getLedgerList(merchantId: merchantId, page: 1);
    });
  }

  void _showDisputeDialog(int ledgerId) {
    final TextEditingController disputeNotesCtrl = TextEditingController();
    Get.dialog(
      AlertDialog(
        title: const Text("Dispute Transaction"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              "Please provide details regarding why you are disputing this transaction. The merchant will be notified.",
              style: TextStyle(fontSize: 13),
            ),
            VSpace(12.h),
            CustomTextField(
              controller: disputeNotesCtrl,
              hintext: "Enter reason for dispute...",
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            onPressed: () {
              if (disputeNotesCtrl.text.trim().isNotEmpty) {
                Get.back();
                _controller.verifyLedgerEntry(
                  ledgerId: ledgerId,
                  status: 'disputed',
                  notes: disputeNotesCtrl.text.trim(),
                );
              }
            },
            child: const Text("Submit Dispute"),
          ),
        ],
      ),
    );
  }

  void _showPaymentSheet(double amount) {
    Get.bottomSheet(
      Container(
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
        decoration: BoxDecoration(
          color: Get.isDarkMode ? AppColors.darkCardColor : Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20.r),
            topRight: Radius.circular(20.r),
          ),
        ),
        child: SafeArea(
          top: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                "Settle Outstanding Balance",
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      fontSize: 18.sp,
                    ),
                textAlign: TextAlign.center,
              ),
              VSpace(8.h),
              Text(
                "Pay to $shopName",
                textAlign: TextAlign.center,
                style: TextStyle(color: AppThemes.getBlack50Color(), fontSize: 14.sp),
              ),
              VSpace(6.h),
              Text(
                "₹${amount.toStringAsFixed(2)}",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 28.sp,
                  fontWeight: FontWeight.bold,
                  color: AppColors.mainColor,
                ),
              ),
              VSpace(16.h),
              AppButton(
                text: "Pay via QR Code / UPI",
                onTap: () {
                  Get.back();
                  // Redirect user to their QR Scanner/payment flow
                  Get.toNamed('/qrCodeScreen');
                },
              ),
              VSpace(6.h),
              TextButton(
                onPressed: () => Get.back(),
                style: TextButton.styleFrom(
                  minimumSize: Size.zero,
                  padding: EdgeInsets.symmetric(vertical: 4.h),
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: Text(
                  "Cancel",
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      isScrollControlled: false,
    );
  }

  @override
  Widget build(BuildContext context) {
    TextTheme t = Theme.of(context).textTheme;
    var storedLanguage = HiveHelp.read(Keys.languageData) ?? {};

    return Scaffold(
      appBar: CustomAppBar(
        title: shopName,
        actions: [
          GetBuilder<CustomerUdharController>(
            builder: (controller) => IconButton(
              icon: Icon(
                Icons.filter_alt_outlined,
                color: AppColors.mainColor,
                size: 20,
              ),
              onPressed: () async {
                final DateTimeRange? picked = await showDateRangePicker(
                  context: context,
                  firstDate: DateTime(2000),
                  lastDate: DateTime.now(),
                  initialDateRange: controller.ledgerDateRange,
                );
                if (picked != null) {
                  controller.setLedgerDateRange(picked);
                } else if (controller.ledgerDateRange != null) {
                  controller.setLedgerDateRange(null); // Clear filter
                }
              },
            ),
          ),
          SizedBox(width: 16),
        ],
      ),
      body: GetBuilder<CustomerUdharController>(
        builder: (controller) {
          if (controller.isLoading && controller.ledgerList.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          final progress = controller.creditLimit > 0
              ? (controller.outstandingBalance / controller.creditLimit).clamp(0.0, 1.0)
              : 0.0;

          return RefreshIndicator(
            color: AppColors.mainColor,
            onRefresh: () async {
              await controller.getLedgerList(merchantId: merchantId, page: 1);
            },
            child: SingleChildScrollView(
              controller: controller.scrollController,
              physics: const AlwaysScrollableScrollPhysics(),
              child: Column(
                children: [
                  // Balance summary card
              Container(
                width: double.infinity,
                margin: EdgeInsets.all(16.w),
                padding: EdgeInsets.all(16.w),
                decoration: BoxDecoration(
                  color: Get.isDarkMode ? AppColors.darkCardColor : Colors.white,
                  borderRadius: BorderRadius.circular(16.r),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Net Outstanding",
                              style: TextStyle(
                                color: AppThemes.getBlack50Color(),
                                fontSize: 13.sp,
                              ),
                            ),
                            VSpace(4.h),
                            Text(
                              "₹${controller.outstandingBalance.toStringAsFixed(2)}",
                              style: TextStyle(
                                fontSize: 24.sp,
                                fontWeight: FontWeight.bold,
                                color: controller.outstandingBalance > 0
                                    ? Colors.redAccent
                                    : Colors.green,
                              ),
                            ),
                          ],
                        ),
                        if (controller.outstandingBalance > 0)
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.mainColor,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10.r),
                              ),
                            ),
                            onPressed: () => _showPaymentSheet(controller.outstandingBalance),
                            child: const Text("Pay Now"),
                          ),
                      ],
                    ),
                    VSpace(16.h),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Credit Limit Used: ₹${controller.outstandingBalance.toStringAsFixed(0)} / ₹${controller.creditLimit.toStringAsFixed(0)}",
                          style: TextStyle(fontSize: 12.sp, color: AppThemes.getBlack50Color()),
                        ),
                        Text(
                          "${(progress * 100).toStringAsFixed(0)}%",
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    VSpace(6.h),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10.r),
                      child: LinearProgressIndicator(
                        value: progress,
                        minHeight: 6.h,
                        backgroundColor: Colors.grey.withOpacity(0.2),
                        valueColor: AlwaysStoppedAnimation<Color>(
                          progress > 0.85
                              ? Colors.redAccent
                              : progress > 0.6
                                  ? Colors.orangeAccent
                                  : Colors.greenAccent,
                        ),
                      ),
                    ),
                    if (controller.dueDate != null) ...[
                      VSpace(10.h),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text("Due Date:", style: TextStyle(fontSize: 12.sp, color: AppThemes.getBlack50Color())),
                          Text(
                            controller.dueDate!,
                            style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.orange),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),

              // Ledger Transactions List
              if (controller.filteredLedgerList.isEmpty)
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 40.h),
                  child: Center(
                    child: Text(
                      "No transactions recorded yet.",
                      style: TextStyle(color: AppThemes.getBlack50Color()),
                    ),
                  ),
                )
              else
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  padding: EdgeInsets.symmetric(horizontal: 16.w),
                          itemCount: controller.filteredLedgerList.length,
                          itemBuilder: (context, index) {
                            final tx = controller.filteredLedgerList[index];
                            final isCredit = tx['type'] == 'credit';
                            final status = tx['verification_status'] ?? 'unverified';
                            final date = DateTime.parse(tx['created_at']);
                            final formattedDate = DateFormat('dd MMM yyyy, hh:mm a').format(date);

                            return Card(
                              margin: EdgeInsets.only(bottom: 12.h),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12.r),
                              ),
                              child: Padding(
                                padding: EdgeInsets.all(12.w),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Row(
                                          children: [
                                            CircleAvatar(
                                              backgroundColor: isCredit
                                                  ? Colors.red.withOpacity(0.1)
                                                  : Colors.green.withOpacity(0.1),
                                              child: Icon(
                                                isCredit
                                                    ? Icons.arrow_outward
                                                    : Icons.arrow_downward,
                                                color: isCredit ? Colors.red : Colors.green,
                                              ),
                                            ),
                                            HSpace(10.w),
                                            Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  isCredit ? "Borrowed (Credit)" : "Paid (Debit)",
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 14.sp,
                                                  ),
                                                ),
                                                VSpace(2.h),
                                                Text(
                                                  formattedDate,
                                                  style: TextStyle(
                                                    color: AppThemes.getBlack50Color(),
                                                    fontSize: 11.sp,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                        Text(
                                          "${isCredit ? '+' : '-'} ₹${tx['amount'].toStringAsFixed(2)}",
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16.sp,
                                            color: isCredit ? Colors.red : Colors.green,
                                          ),
                                        ),
                                      ],
                                    ),
                                    if (tx['notes'] != null && tx['notes'].toString().isNotEmpty) ...[
                                      VSpace(8.h),
                                      Text(
                                        "Note: ${tx['notes']}",
                                        style: TextStyle(
                                          fontSize: 12.sp,
                                          color: AppThemes.getBlack50Color(),
                                          fontStyle: FontStyle.italic,
                                        ),
                                      ),
                                    ],
                                    VSpace(10.h),
                                    const Divider(height: 1),
                                    VSpace(8.h),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Row(
                                          children: [
                                            Text(
                                              "Status: ",
                                              style: TextStyle(
                                                fontSize: 12.sp,
                                                color: AppThemes.getBlack50Color(),
                                              ),
                                            ),
                                            Container(
                                              padding: EdgeInsets.symmetric(
                                                horizontal: 8.w,
                                                vertical: 2.h,
                                              ),
                                              decoration: BoxDecoration(
                                                color: status == 'verified'
                                                    ? Colors.green.withOpacity(0.15)
                                                    : status == 'disputed'
                                                        ? Colors.red.withOpacity(0.15)
                                                        : Colors.orange.withOpacity(0.15),
                                                borderRadius: BorderRadius.circular(4.r),
                                              ),
                                              child: Text(
                                                status.toUpperCase(),
                                                style: TextStyle(
                                                  fontSize: 10.sp,
                                                  fontWeight: FontWeight.bold,
                                                  color: status == 'verified'
                                                      ? Colors.green
                                                      : status == 'disputed'
                                                          ? Colors.red
                                                          : Colors.orange,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        if (status == 'unverified')
                                          Row(
                                            children: [
                                              TextButton(
                                                onPressed: () => _showDisputeDialog(tx['id']),
                                                style: TextButton.styleFrom(
                                                  foregroundColor: Colors.red,
                                                  padding: EdgeInsets.zero,
                                                ),
                                                child: const Text("Dispute"),
                                              ),
                                              HSpace(8.w),
                                              ElevatedButton(
                                                onPressed: () {
                                                  controller.verifyLedgerEntry(
                                                    ledgerId: tx['id'],
                                                    status: 'verified',
                                                  );
                                                },
                                                style: ElevatedButton.styleFrom(
                                                  backgroundColor: Colors.green,
                                                  foregroundColor: Colors.white,
                                                  padding: EdgeInsets.symmetric(
                                                    horizontal: 12.w,
                                                    vertical: 4.h,
                                                  ),
                                                  minimumSize: Size.zero,
                                                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                                ),
                                                child: const Text("Approve"),
                                              ),
                                            ],
                                          ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
