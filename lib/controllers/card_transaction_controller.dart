import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import '../data/models/virtual_card_transaction_model.dart' as t;
import '../data/repositories/card_repo.dart';
import '../data/source/errors/check_api_status.dart';

class CardTransactionController extends GetxController {
  static CardTransactionController get to =>
      Get.find<CardTransactionController>();
  late ScrollController scrollController;
  int page = 1;
  bool isLoadMore = false;
  bool hasNextPage = true;
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  List<t.Datum> virtualCartTransactionList = [];
  String id = "";
  Future loadMore() async {
    if (_isLoading == false &&
        isLoadMore == false &&
        hasNextPage == true &&
        scrollController.position.extentAfter < 300) {
      isLoadMore = true;
      update();
      page += 1;
      await cardTransaction(
          page: page.toString(), id: id, isLoadMoreRunning: true);
      if (kDebugMode) {
        print("====================loaded from load more: " + page.toString());
      }
      isLoadMore = false;
      update();
    }
  }

  bool isSearchTapped = false;
  resetDataAfterSearching({bool? isFromOnRefreshIndicator = false}) {
    virtualCartTransactionList.clear();
    isSearchTapped = true;
    hasNextPage = true;
    page = 1;
    update();
  }

  Future cardTransaction(
      {required String page,
      required String id,
      bool? isLoadMoreRunning = false}) async {
    if (isLoadMoreRunning == false) _isLoading = true;
    update();

    http.Response response = await CardRepo.cardTransaction(id: id, page: page);

    if (isLoadMoreRunning == false) _isLoading = false;
    update();

    if (response.statusCode == 200) {
      var data = jsonDecode(response.body);

      if (data['status'] == 'success') {
        final fetchedData = data['message']['cardTransactions'];
        if (fetchedData.isNotEmpty) {
          virtualCartTransactionList = [
            ...virtualCartTransactionList,
            ...t.VirtualCardTransactionModel.fromJson(data)
                .message!
                .cardTransactions!
                .data!
          ];
          if (isLoadMoreRunning == false) {
            _isLoading = false;
          }
          update();
        } else {
          virtualCartTransactionList = [
            ...virtualCartTransactionList,
            ...t.VirtualCardTransactionModel.fromJson(data)
                .message!
                .cardTransactions!
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
        if (id.isNotEmpty) {
          ApiStatus.checkStatus(data['status'], data['message']);
        }
      }
    } else {
      virtualCartTransactionList = [];
    }
  }

  @override
  void onInit() {
    super.onInit();
    cardTransaction(
        page: page.toString(), id: this.id, isLoadMoreRunning: true);
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
    virtualCartTransactionList.clear();
  }
}
