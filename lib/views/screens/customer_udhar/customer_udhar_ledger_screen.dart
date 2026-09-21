import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:paysecure/controllers/bindings/controller_index.dart';
import '../../../../config/app_colors.dart';
import '../../../themes/themes.dart';
import '../../widgets/custom_appbar.dart';
import '../../widgets/custom_textfield.dart';
import '../../widgets/spacing.dart';
import '../../widgets/merchant_status_badge.dart';
import '../mobile_scanner/mobile_scanner_screen.dart';
import '../../../utils/services/helpers.dart';

class CustomerUdharLedgerScreen extends StatefulWidget {
  const CustomerUdharLedgerScreen({super.key});

  @override
  State<CustomerUdharLedgerScreen> createState() => _CustomerUdharLedgerScreenState();
}

class _CustomerUdharLedgerScreenState extends State<CustomerUdharLedgerScreen> {
  final CustomerUdharController _controller = Get.find<CustomerUdharController>();
  late int merchantId;
  late String shopName;
  Map<String, dynamic>? initialMerchantData;

  @override
  void initState() {
    super.initState();
    final args = Get.arguments as Map<String, dynamic>;
    merchantId = args['merchant_id'];
    shopName = args['shop_name'];
    initialMerchantData = args['merchant_data'];

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

  void _showPaymentSheet(double totalAmount) {
    final TextEditingController amountController =
        TextEditingController(text: totalAmount.toStringAsFixed(2));

    Get.bottomSheet(
      StatefulBuilder(
        builder: (context, setSheetState) {
          return Container(
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
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
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
                    VSpace(12.h),
                    Text(
                      "Settle Outstanding Balance",
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            fontSize: 18.sp,
                          ),
                      textAlign: TextAlign.center,
                    ),
                    VSpace(4.h),
                    Text(
                      "Pay to $shopName",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: AppThemes.getBlack50Color(),
                        fontSize: 13.sp,
                      ),
                    ),
                    VSpace(16.h),
                    // Amount Input
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                      decoration: BoxDecoration(
                        color: Get.isDarkMode
                            ? Colors.black.withValues(alpha: 0.2)
                            : Colors.grey.shade50,
                        borderRadius: BorderRadius.circular(14.r),
                        border: Border.all(color: AppColors.mainColor.withValues(alpha: 0.3)),
                      ),
                      child: Row(
                        children: [
                          Text(
                            "₹",
                            style: TextStyle(
                              fontSize: 26.sp,
                              fontWeight: FontWeight.bold,
                              color: AppColors.mainColor,
                            ),
                          ),
                          SizedBox(width: 8.w),
                          Expanded(
                            child: TextField(
                              controller: amountController,
                              keyboardType:
                                  const TextInputType.numberWithOptions(decimal: true),
                              style: TextStyle(
                                fontSize: 24.sp,
                                fontWeight: FontWeight.bold,
                                color: Get.isDarkMode ? Colors.white : Colors.black87,
                              ),
                              decoration: const InputDecoration(
                                border: InputBorder.none,
                                hintText: "0.00",
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    VSpace(10.h),
                    // Quick chips
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ActionChip(
                          label: Text(
                            "Full: ₹${totalAmount.toStringAsFixed(0)}",
                            style: TextStyle(
                              fontSize: 12.sp,
                              color: AppColors.mainColor,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          backgroundColor: AppColors.mainColor.withValues(alpha: 0.1),
                          side: BorderSide(color: AppColors.mainColor.withValues(alpha: 0.3)),
                          onPressed: () {
                            setSheetState(() {
                              amountController.text = totalAmount.toStringAsFixed(2);
                            });
                          },
                        ),
                        if (totalAmount > 500) ...[
                          SizedBox(width: 8.w),
                          ActionChip(
                            label: Text(
                              "₹500",
                              style: TextStyle(fontSize: 12.sp),
                            ),
                            onPressed: () {
                              setSheetState(() {
                                amountController.text = "500.00";
                              });
                            },
                          ),
                        ],
                        if (totalAmount > 1000) ...[
                          SizedBox(width: 8.w),
                          ActionChip(
                            label: Text(
                              "₹1000",
                              style: TextStyle(fontSize: 12.sp),
                            ),
                            onPressed: () {
                              setSheetState(() {
                                amountController.text = "1000.00";
                              });
                            },
                          ),
                        ],
                      ],
                    ),
                    VSpace(16.h),
                    // Primary Pay Online Button
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.mainColor,
                        foregroundColor: Colors.white,
                        minimumSize: Size(double.infinity, 48.h),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        elevation: 2,
                      ),
                      onPressed: () {
                        final enteredAmount =
                            double.tryParse(amountController.text.trim()) ?? 0.0;
                        if (enteredAmount <= 0) {
                          Helpers.showSnackBar(
                            msg: "Please enter a valid amount",
                            title: "Invalid Amount",
                            bgColor: Colors.red,
                          );
                          return;
                        }
                        Get.back();
                        _controller.payUdharViaRazorpay(
                          amount: enteredAmount,
                          merchantId: merchantId,
                          shopName: shopName,
                        );
                      },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.payment_rounded, size: 20.sp),
                          SizedBox(width: 8.w),
                          Text(
                            "Pay Now (UPI / Cards / NetBanking)",
                            style: TextStyle(
                              fontSize: 15.sp,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    VSpace(10.h),
                    // Secondary: Scan Merchant QR
                    OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.mainColor,
                        side: BorderSide(color: AppColors.mainColor),
                        minimumSize: Size(double.infinity, 44.h),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                      ),
                      onPressed: () {
                        Get.back();
                        Get.to(() => const MobileScannerScreen(
                              isFromMakePaymentPage: true,
                            ));
                      },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.qr_code_scanner_rounded, size: 18.sp),
                          SizedBox(width: 8.w),
                          Text(
                            "Scan Store QR Code",
                            style: TextStyle(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    VSpace(8.h),
                    TextButton(
                      onPressed: () => Get.back(),
                      style: TextButton.styleFrom(
                        minimumSize: Size.zero,
                        padding: EdgeInsets.symmetric(vertical: 6.h),
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: Text(
                        "Cancel",
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 13.sp,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
      isScrollControlled: true,
    );
  }

  @override
  Widget build(BuildContext context) {
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
                  // Merchant Shop Status Banner
                  Padding(
                    padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 0),
                    child: MerchantStatusBadge(
                      merchantData: controller.merchantDetails.isNotEmpty
                          ? controller.merchantDetails
                          : initialMerchantData,
                      isCompact: false,
                      showTiming: true,
                    ),
                  ),

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
                      color: Colors.black.withValues(alpha: 0.05),
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
                        backgroundColor: Colors.grey.withValues(alpha: 0.2),
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
                                                  ? Colors.red.withValues(alpha: 0.1)
                                                  : Colors.green.withValues(alpha: 0.1),
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
                                                    ? Colors.green.withValues(alpha: 0.15)
                                                    : status == 'disputed'
                                                        ? Colors.red.withValues(alpha: 0.15)
                                                        : Colors.orange.withValues(alpha: 0.15),
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
