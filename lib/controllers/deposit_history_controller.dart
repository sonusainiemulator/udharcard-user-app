import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import '../data/models/deposit_history_model.dart' as d;
import '../data/repositories/deposit_repo.dart';
import '../data/source/errors/check_api_status.dart';

class DepositHistoryController extends GetxController {
  TextEditingController dateTimeEditingCtrlr = TextEditingController();
  TextEditingController utrEditingCtrlr = TextEditingController();
  late ScrollController scrollController;
  int page = 1;
  bool isLoadMore = false;
  bool hasNextPage = true;
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  List<d.Fund> depositList = [];
  Future loadMore() async {
    if (_isLoading == false &&
        isLoadMore == false &&
        hasNextPage == true &&
        scrollController.position.extentAfter < 300) {
      isLoadMore = true;
      update();
      page += 1;
      await getDepositList(
          page: page,
          transaction_id: utrEditingCtrlr.text,
          currency: "",
          created_at: dateTimeEditingCtrlr.text,
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
    depositList.clear();
    page = 1;
    isSearchTapped = true;
    hasNextPage = true;
    update();
  }

  Future getDepositList(
      {required int page,
      required String transaction_id,
      required String currency,
      required String created_at,
      bool? isLoadMoreRunning = false}) async {
    if (isLoadMoreRunning == false) _isLoading = true;
    update();

    http.Response response = await DepositRepo.getDepositList(
        page: page,
        transaction_id: transaction_id,
        created_at: created_at,
        currency: currency);

    if (page == 1 && isLoadMoreRunning == false) depositList.clear();
    if (isLoadMoreRunning == false) _isLoading = false;
    update();

    if (response.statusCode == 200) {
      var data = jsonDecode(response.body);

      if (data['status'] == 'success') {
        final fetchedData = data['message']['funds'];

        if (fetchedData.isNotEmpty) {
          depositList = [
            ...depositList,
            ...d.DepositHistoryModel.fromJson(data).message!.funds!
          ];
          if (isLoadMoreRunning == false) _isLoading = false;
          update();
        } else {
          depositList = [
            ...depositList,
            ...d.DepositHistoryModel.fromJson(data).message!.funds!
          ];
          hasNextPage = false;
          if (isLoadMoreRunning == false) _isLoading = false;

          if (kDebugMode) {
            print("================isDataEmpty: true");
          }

          update();
        }
      } else {
        ApiStatus.checkStatus(data['status'], data['message']);
      }
    } else {
      depositList = [];
    }
  }

  @override
  void onInit() {
    super.onInit();
    getDepositList(
        page: page, transaction_id: "", currency: "", created_at: "");
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
    depositList.clear();
  }
}
