import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:paysecure/data/repositories/request_money_repo.dart';
import '../data/models/request_history_model.dart' as r;
import '../data/source/errors/check_api_status.dart';

class RequestHistoryController extends GetxController {
  static RequestHistoryController get to =>
      Get.find<RequestHistoryController>();
  TextEditingController dateTimeEditingCtrlr = TextEditingController();
  TextEditingController utrEditingCtrlr = TextEditingController();
  TextEditingController emailEditingCtrlr = TextEditingController();

  late ScrollController scrollController;
  int page = 1;
  bool isLoadMore = false;
  bool hasNextPage = true;
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  List<r.Datum> requestMoeyList = [];
  Future loadMore() async {
    if (_isLoading == false &&
        isLoadMore == false &&
        hasNextPage == true &&
        scrollController.position.extentAfter < 300) {
      isLoadMore = true;
      update();
      page += 1;
      await getRequestList(
          page: page,
          email: emailEditingCtrlr.text,
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
    requestMoeyList.clear();
    page = 1;
    isSearchTapped = true;
    hasNextPage = true;
    update();
  }

  refreshSearchData() {
    dateTimeEditingCtrlr.clear();
    utrEditingCtrlr.clear();
    emailEditingCtrlr.clear();
    update();
  }

  Future getRequestList(
      {required int page,
      required String email,
      required String utr,
      required String created_at,
      bool? isLoadMoreRunning = false}) async {
    if (isLoadMoreRunning == false) {
      _isLoading = true;
    }
    update();
    http.Response response = await RequestRepo.getRequestList(
        page: page, email: email, utr: utr, created_at: created_at);
    if (page == 1 && isLoadMoreRunning == false) {
      requestMoeyList.clear();
    }
    if (isLoadMoreRunning == false) {
      _isLoading = false;
    }
    update();

    if (response.statusCode == 200) {
      var data = jsonDecode(response.body);

      if (data['status'] == 'success') {
        final fetchedData = data['message']['requestMoney']['data'];
        if (fetchedData.isNotEmpty) {
          requestMoeyList = [
            ...requestMoeyList,
            ...r.RequestHistoryModel.fromJson(data).message!.requestMoney!.data!
          ];
          if (isLoadMoreRunning == false) {
            _isLoading = false;
          }
          update();
        } else {
          requestMoeyList = [
            ...requestMoeyList,
            ...r.RequestHistoryModel.fromJson(data).message!.requestMoney!.data!
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
      requestMoeyList = [];
    }
  }

  @override
  void onInit() {
    super.onInit();
    getRequestList(page: page, email: "", created_at: "", utr: "");
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
    requestMoeyList.clear();
  }
}
