import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:paysecure/data/repositories/send_monye_repo.dart';
import '../data/models/send_money_history_model.dart' as s;
import '../data/source/errors/check_api_status.dart';

class SendMoneyHistoryController extends GetxController {
  static SendMoneyHistoryController get to =>
      Get.find<SendMoneyHistoryController>();
  TextEditingController emailEditingCtrlr = TextEditingController();
  TextEditingController dateTimeEditingCtrlr = TextEditingController();
  TextEditingController utrEditingCtrlr = TextEditingController();

  late ScrollController scrollController;
  int page = 1;
  bool isLoadMore = false;
  bool hasNextPage = true;
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  List<s.Datum> sendMoeyList = [];
  Future loadMore() async {
    if (_isLoading == false &&
        isLoadMore == false &&
        hasNextPage == true &&
        scrollController.position.extentAfter < 300) {
      isLoadMore = true;
      update();
      page += 1;
      await getSendMoneyList(
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
    sendMoeyList.clear();
    page = 1;
    isSearchTapped = true;
    hasNextPage = true;
    update();
  }

  refreshSearchData() {
    dateTimeEditingCtrlr.clear();
    emailEditingCtrlr.clear();
    utrEditingCtrlr.clear();
    update();
  }

  Future getSendMoneyList(
      {required int page,
      required String email,
      required String utr,
      required String created_at,
      bool? isLoadMoreRunning = false}) async {
    if (isLoadMoreRunning == false) {
      _isLoading = true;
    }
    update();
    http.Response response = await SendMoneyRepo.sendMoneyList(
        page: page, email: email, utr: utr, created_at: created_at);
    if (page == 1 && isLoadMoreRunning == false) {
      sendMoeyList.clear();
    }
    if (isLoadMoreRunning == false) {
      _isLoading = false;
    }
    update();

    if (response.statusCode == 200) {
      var data = jsonDecode(response.body);

      if (data['status'] == 'success') {
        final fetchedData = data['message']['transfers']['data'];
        if (fetchedData.isNotEmpty) {
          sendMoeyList = [
            ...sendMoeyList,
            ...s.SendMoneyHistoryModel.fromJson(data).message!.transfers!.data!
          ];
          if (isLoadMoreRunning == false) {
            _isLoading = false;
          }
          update();
        } else {
          sendMoeyList = [
            ...sendMoeyList,
            ...s.SendMoneyHistoryModel.fromJson(data).message!.transfers!.data!
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
      sendMoeyList = [];
    }
  }

  @override
  void onInit() {
    super.onInit();
    getSendMoneyList(page: page, email: "", created_at: "", utr: "");
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
    sendMoeyList.clear();
  }
}
