import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:paysecure/data/repositories/exchange_repo.dart';
import '../data/models/exchange_history_model.dart' as e;
import '../data/source/errors/check_api_status.dart';

class ExchangeHistoryController extends GetxController {
  static ExchangeHistoryController get to =>
      Get.find<ExchangeHistoryController>();
  TextEditingController dateTimeEditingCtrlr = TextEditingController();
  TextEditingController utrEditingCtrlr = TextEditingController();

  dynamic selectedStatus = "All Status";
  List<String> statusList = [
    "All Status",
    "Pending",
    "Completed",
  ];

  late ScrollController scrollController;
  int page = 1;
  bool isLoadMore = false;
  bool hasNextPage = true;
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  List<e.Datum> exchangeMoeyList = [];
  Future loadMore() async {
    if (_isLoading == false &&
        isLoadMore == false &&
        hasNextPage == true &&
        scrollController.position.extentAfter < 300) {
      isLoadMore = true;
      update();
      page += 1;
      await getExchangeMoneyList(
          page: page,
          status: selectedStatus == "All Status"
              ? ""
              : selectedStatus == "Pending"
                  ? "0"
                  : "1",
          created_at: dateTimeEditingCtrlr.text,
          utr: utrEditingCtrlr.text,
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
    exchangeMoeyList.clear();
    page = 1;
    isSearchTapped = true;
    hasNextPage = true;
    update();
  }

  refreshSearchData() {
    dateTimeEditingCtrlr.clear();
    utrEditingCtrlr.clear();
    selectedStatus = "All Status";
    update();
  }

  Future getExchangeMoneyList(
      {required int page,
      required String status,
      required String utr,
      required String created_at,
      bool? isLoadMoreRunning = false}) async {
    if (isLoadMoreRunning == false) _isLoading = true;
    update();

    http.Response response = await ExchangeRepo.getExchangeMoneyList(
        page: page, status: status, utr: utr, created_at: created_at);

    if (page == 1 && isLoadMoreRunning == false) exchangeMoeyList.clear();
    if (isLoadMoreRunning == false) _isLoading = false;
    update();

    if (response.statusCode == 200) {
      var data = jsonDecode(response.body);

      if (data['status'] == 'success') {
        final fetchedData = data['message']['exchanges']['data'];
        if (fetchedData.isNotEmpty) {
          exchangeMoeyList = [
            ...exchangeMoeyList,
            ...e.ExchangeMoneyHistoryModel.fromJson(data)
                .message!
                .exchanges!
                .data!
          ];
          if (isLoadMoreRunning == false) {
            _isLoading = false;
          }
          update();
        } else {
          exchangeMoeyList = [
            ...exchangeMoeyList,
            ...e.ExchangeMoneyHistoryModel.fromJson(data)
                .message!
                .exchanges!
                .data!
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
      exchangeMoeyList = [];
    }
  }

  @override
  void onInit() {
    super.onInit();
    getExchangeMoneyList(page: page, status: "", created_at: "", utr: "");
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
    exchangeMoeyList.clear();
  }
}
