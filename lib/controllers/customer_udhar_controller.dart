import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:fluttertoast/fluttertoast.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../data/repositories/customer_udhar_repo.dart';
import '../data/source/errors/check_api_status.dart';
import '../utils/services/helpers.dart';
import '../utils/services/receipt_share_helper.dart';

class CustomerUdharController extends GetxController {
  late ScrollController scrollController;
  int page = 1;
  bool isLoadMore = false;
  bool hasNextPage = true;
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  bool _isLoadingMerchants = false;
  bool get isLoadingMerchants => _isLoadingMerchants;

  List<dynamic> merchantsList = [];
  List<dynamic> ledgerList = [];
  List<dynamic> filteredLedgerList = [];
  DateTimeRange? ledgerDateRange;

  double outstandingBalance = 0.0;
  double creditLimit = 0.0;
  String? dueDate = '';

  void setLedgerDateRange(DateTimeRange? range) {
    ledgerDateRange = range;
    _applyLedgerDateFilter();
  }

  void _applyLedgerDateFilter() {
    if (ledgerDateRange == null) {
      filteredLedgerList = List.from(ledgerList);
    } else {
      filteredLedgerList = ledgerList.where((tx) {
        if (tx['created_at'] == null) return true;
        try {
          final DateTime txDate = DateTime.parse(tx['created_at'].toString());
          final start = ledgerDateRange!.start;
          final end = ledgerDateRange!.end.add(const Duration(days: 1)); // Include the end day fully
          return txDate.isAfter(start) && txDate.isBefore(end);
        } catch (_) {
          return true;
        }
      }).toList();
    }
    update();
  }
  Map<String, dynamic> merchantDetails = {};

  int activeMerchantId = 0;

  Future getMerchantsList() async {
    _isLoadingMerchants = true;
    update();

    try {
      http.Response response = await CustomerUdharRepo.getMerchantsList();
      _isLoadingMerchants = false;

      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        if (data['status'] == 'success') {
          merchantsList = data['data'];
        } else {
          ApiStatus.checkStatus(data['status'], data['message']);
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print("Error fetching merchants: $e");
      }
    }
    update();
  }

  Future getLedgerList({
    required int merchantId,
    required int page,
    bool? isLoadMoreRunning = false,
  }) async {
    activeMerchantId = merchantId;
    if (isLoadMoreRunning == false) {
      _isLoading = true;
      ledgerList.clear();
    }
    update();

    try {
      http.Response response = await CustomerUdharRepo.getLedgerList(
        merchantId: merchantId,
        page: page,
      );

      if (isLoadMoreRunning == false) {
        _isLoading = false;
      }
      update();

      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        if (data['status'] == 'success') {
          final payload = data['data'];
          outstandingBalance = double.tryParse(payload['outstanding_balance'].toString()) ?? 0.0;
          creditLimit = double.tryParse(payload['credit_limit'].toString()) ?? 0.0;
          dueDate = payload['due_date'];
          merchantDetails = payload['merchant'] ?? {};

          final fetchedData = payload['ledgers']['data'];
          if (fetchedData.isNotEmpty) {
            if (page == 1) {
              ledgerList = fetchedData;
            } else {
              ledgerList.addAll(fetchedData);
            }
            _applyLedgerDateFilter();
          } else {
            hasNextPage = false;
            update();
          }
        } else {
          ApiStatus.checkStatus(data['status'], data['message']);
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print("Error fetching ledger: $e");
      }
    }
    update();
  }

  Future verifyLedgerEntry({
    required int ledgerId,
    required String status,
    String? notes,
  }) async {
    _isLoading = true;
    update();

    try {
      http.Response response = await CustomerUdharRepo.verifyLedgerEntry(
        ledgerId: ledgerId,
        status: status,
        notes: notes,
      );
      _isLoading = false;

      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        if (data['status'] == 'success') {
          Fluttertoast.showToast(
            msg: status == 'verified'
                ? "Transaction approved successfully"
                : "Dispute submitted successfully",
            backgroundColor: Colors.green,
            textColor: Colors.white,
          );
          // Refresh active ledger timeline
          getLedgerList(merchantId: activeMerchantId, page: 1);
        } else {
          ApiStatus.checkStatus(data['status'], data['message']);
        }
      }
    } catch (e) {
      _isLoading = false;
      if (kDebugMode) {
        print("Error verifying ledger: $e");
      }
    }
    update();
  }

  Future loadMore() async {
    if (_isLoading == false &&
        isLoadMore == false &&
        hasNextPage == true &&
        scrollController.position.extentAfter < 300) {
      isLoadMore = true;
      update();
      page += 1;
      await getLedgerList(
        merchantId: activeMerchantId,
        page: page,
        isLoadMoreRunning: true,
      );
      isLoadMore = false;
      update();
    }
  }

  // ─────────────────── Native Razorpay Udhar Settlement ───────────────────
  Razorpay? razorpay;
  double lastPayingAmount = 0.0;
  String lastPayingShopName = "";

  void listenRazorPay() {
    razorpay = Razorpay()
      ..on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess)
      ..on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError)
      ..on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) async {
    final paymentId = response.paymentId ?? "PAY_${DateTime.now().millisecondsSinceEpoch}";
    debugPrint("Razorpay Udhar Settlement Success: $paymentId");

    Helpers.showSnackBar(
      msg: "Payment Successful! ₹${lastPayingAmount.toStringAsFixed(2)} settled with $lastPayingShopName",
      title: "Settlement Complete",
      bgColor: Colors.green,
    );

    _showReceiptBottomSheet(
      paymentId: paymentId,
      amount: lastPayingAmount,
      shopName: lastPayingShopName,
    );

    if (activeMerchantId > 0) {
      await getLedgerList(merchantId: activeMerchantId, page: 1);
    }
    await getMerchantsList();
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    debugPrint("Razorpay Payment Error: ${response.message} ${response.error}");
    Helpers.showSnackBar(
      msg: "Payment Failed: ${response.message ?? 'Transaction could not be completed'}",
      title: "Payment Error",
      bgColor: Colors.red,
    );
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    Helpers.showSnackBar(
      msg: "Redirecting to ${response.walletName ?? 'external wallet'}...",
      title: "External Wallet",
      bgColor: Colors.orange,
    );
  }

  Future<void> payUdharViaRazorpay({
    required double amount,
    required int merchantId,
    required String shopName,
    String? phone,
    String? email,
  }) async {
    if (amount <= 0) {
      Helpers.showSnackBar(msg: "Please enter an amount greater than ₹0");
      return;
    }

    lastPayingAmount = amount;
    lastPayingShopName = shopName;
    activeMerchantId = merchantId;

    final String keyToUse = dotenv.env['RAZORPAY_KEY_ID']?.trim() ?? 'rzp_test_default';

    if (razorpay == null) {
      listenRazorPay();
    }

    final options = {
      'key': keyToUse,
      'amount': (amount * 100).toInt(),
      'name': shopName,
      'description': "Udhar Settlement for $shopName",
      'timeout': 300,
      'retry': {'enabled': true, 'max_count': 1},
      'send_sms_hash': true,
      'prefill': {
        if (phone != null && phone.isNotEmpty) 'contact': phone,
        if (email != null && email.isNotEmpty) 'email': email,
      },
      'notes': {
        'merchant_id': merchantId.toString(),
        'shop_name': shopName,
        'type': 'udhar_settlement',
      },
      'external': {
        'wallets': ['paytm']
      }
    };

    try {
      razorpay!.open(options);
    } catch (e) {
      debugPrint("Razorpay launch error: $e");
      Helpers.showSnackBar(msg: "Failed to open Razorpay: $e");
    }
  }

  void _showReceiptBottomSheet({
    required String paymentId,
    required double amount,
    required String shopName,
  }) {
    final receiptText = ReceiptShareHelper.formatUdharReceipt(
      shopName: shopName,
      amount: amount,
      paymentId: paymentId,
    );

    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Get.isDarkMode ? const Color(0xFF1E293B) : Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: SafeArea(
          top: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 16),
              const CircleAvatar(
                radius: 28,
                backgroundColor: Color(0xFFDCFCE7),
                child: Icon(Icons.check_circle_rounded, color: Color(0xFF16A34A), size: 36),
              ),
              const SizedBox(height: 12),
              const Text(
                "Payment Successful!",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              Text(
                "₹${amount.toStringAsFixed(2)} settled with $shopName",
                style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
              ),
              const SizedBox(height: 16),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Get.isDarkMode ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: Text(
                  receiptText,
                  style: const TextStyle(fontSize: 11, fontFamily: 'monospace'),
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF25D366),
                  foregroundColor: Colors.white,
                  minimumSize: const Size.fromHeight(48),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: () {
                  ReceiptShareHelper.shareToWhatsApp(receiptText: receiptText);
                },
                icon: const Icon(Icons.share_rounded),
                label: const Text(
                  "Share Receipt on WhatsApp",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                ),
              ),
              const SizedBox(height: 8),
              TextButton(
                onPressed: () => Get.back(),
                child: const Text("Done"),
              ),
            ],
          ),
        ),
      ),
      isScrollControlled: true,
    );
  }

  @override
  void onInit() {
    super.onInit();
    listenRazorPay();
    scrollController = ScrollController()..addListener(loadMore);
  }

  @override
  void onClose() {
    razorpay?.clear();
    scrollController.removeListener(loadMore);
    scrollController.dispose();
    super.onClose();
  }
}
