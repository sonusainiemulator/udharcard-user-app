import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:fluttertoast/fluttertoast.dart';
import '../data/repositories/customer_udhar_repo.dart';
import '../data/source/errors/check_api_status.dart';

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

  double outstandingBalance = 0.0;
  double creditLimit = 0.0;
  String? dueDate = '';
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
            update();
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

  @override
  void onInit() {
    super.onInit();
    scrollController = ScrollController()..addListener(loadMore);
  }

  @override
  void onClose() {
    scrollController.removeListener(loadMore);
    scrollController.dispose();
    super.onClose();
  }
}
