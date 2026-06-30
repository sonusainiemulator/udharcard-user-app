import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import '../data/models/pay_bill_history_model.dart' as p;
import '../data/repositories/pay_bill_repo.dart';
import '../data/source/errors/check_api_status.dart';

class PayBillHistoryController extends GetxController {
  TextEditingController categoryEditingCtrlr = TextEditingController();
  TextEditingController dateTimeEditingCtrlr = TextEditingController();
  TextEditingController typeEditingCtrlr = TextEditingController();
  dynamic selectedStatus = "All";
  List<String> statusList = [
    "All",
    "Generate",
    "Pending",
    "Payment Completed",
    "Bill Completed",
    "Bill Return",
  ];
  late ScrollController scrollController;
  int page = 1;
  bool isLoadMore = false;
  bool hasNextPage = true;
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  List<p.Datum> payBillList = [];
  Future loadMore() async {
    if (_isLoading == false &&
        isLoadMore == false &&
        hasNextPage == true &&
        scrollController.position.extentAfter < 300) {
      isLoadMore = true;
      update();
      page += 1;
      await getPayBillList(
          page: page,
          type: "",
          status: "",
          created_at: "",
          category_name: "",
          isLoadMoreRunning: true);
      if (kDebugMode) {
        print("====================loaded from load more: " + page.toString());
      }
      isLoadMore = false;
      update();
    }
  }

  bool isSearchTapped = false;
  resetDataAfterSearching({bool? isFromOnRefreshIndicator = false}) {
    payBillList.clear();
    page = 1;
    isSearchTapped = true;
    hasNextPage = true;
    update();
  }

  Future getPayBillList(
      {required int page,
      required String type,
      required String category_name,
      required String created_at,
      required String status,
      bool? isLoadMoreRunning = false}) async {
    if (isLoadMoreRunning == false) {
      _isLoading = true;
    }
    update();
    http.Response response = await PayBillRepo.getPayBillList(
        page: page,
        type: type,
        category_name: category_name,
        created_at: created_at,
        status: status);
    if (page == 1 && isLoadMoreRunning == false) {
      payBillList.clear();
    }
    if (isLoadMoreRunning == false) {
      _isLoading = false;
    }
    update();

    if (response.statusCode == 200) {
      var data = jsonDecode(response.body);

      if (data['status'] == 'success') {
        final fetchedData = data['message']['bills']['data'];
        if (fetchedData.isNotEmpty) {
          payBillList = [
            ...payBillList,
            ...p.PayBillHistoryModel.fromJson(data).message!.bills!.data!
          ];
          if (isLoadMoreRunning == false) {
            _isLoading = false;
          }
          update();
        } else {
          payBillList = [
            ...payBillList,
            ...p.PayBillHistoryModel.fromJson(data).message!.bills!.data!
          ];
          hasNextPage = false;
          if (isLoadMoreRunning == false) {
            _isLoading = false;
          }
          if (kDebugMode) {
            print("================isDataEmpty: true");
          }

          update();
        }
      } else {
        ApiStatus.checkStatus(data['status'], data['message']);
      }
    } else {
      payBillList = [];
    }
  }

  @override
  void onInit() {
    super.onInit();
    getPayBillList(
        page: page, type: "", status: "", created_at: "", category_name: "");
    scrollController = ScrollController()..addListener(loadMore);
  }

  @override
  void onClose() {
    scrollController.removeListener(loadMore);
    scrollController.dispose();
    super.onClose();
  }

  @override
  void dispose() {
    super.dispose();
    scrollController.dispose();
    payBillList.clear();
  }
}
