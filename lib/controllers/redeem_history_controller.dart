import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:paysecure/data/repositories/redeem_code_repo.dart';
import '../data/models/redeem_history_model.dart' as r;
import '../data/source/errors/check_api_status.dart';

class RedeemHistoryController extends GetxController {
  static RedeemHistoryController get to => Get.find<RedeemHistoryController>();
  TextEditingController emailEditingCtrlr = TextEditingController();
  TextEditingController dateTimeEditingCtrlr = TextEditingController();
  TextEditingController utrEditingCtrlr = TextEditingController();
  dynamic selectedStatus = "All";
  List<String> statusList = [
    "All",
    "Pending",
    "Unused",
    "Used",
  ];
  late ScrollController scrollController;
  int page = 1;
  bool isLoadMore = false;
  bool hasNextPage = true;
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  List<r.Datum> redeemList = [];
  Future loadMore() async {
    if (_isLoading == false &&
        isLoadMore == false &&
        hasNextPage == true &&
        scrollController.position.extentAfter < 300) {
      isLoadMore = true;
      update();
      page += 1;
      await getRedeemList(
          page: page,
          email: emailEditingCtrlr.text,
          status: selectedStatus == "All" ? "" : selectedStatus,
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
    redeemList.clear();
    page = 1;
    isSearchTapped = true;
    hasNextPage = true;
    update();
  }

  refreshSearchData() {
    dateTimeEditingCtrlr.clear();
    emailEditingCtrlr.clear();
    utrEditingCtrlr.clear();
    selectedStatus = "All";
    update();
  }

  Future getRedeemList(
      {required int page,
      required String email,
      required String utr,
      required String created_at,
      required String status,
      bool? isLoadMoreRunning = false}) async {
    if (isLoadMoreRunning == false) {
      _isLoading = true;
    }
    update();
    http.Response response = await RedeemCodeRepo.getRedeemList(
        page: page,
        email: email,
        utr: utr,
        created_at: created_at,
        status: status);
    if (page == 1 && isLoadMoreRunning == false) {
      redeemList.clear();
    }
    if (isLoadMoreRunning == false) {
      _isLoading = false;
    }
    update();

    if (response.statusCode == 200) {
      var data = jsonDecode(response.body);

      if (data['status'] == 'success') {
        final fetchedData = data['message']['redeemCodes']['data'];
        if (fetchedData.isNotEmpty) {
          redeemList = [
            ...redeemList,
            ...r.RedeemHistoryModel.fromJson(data).message!.redeemCodes!.data!
          ];
          if (isLoadMoreRunning == false) {
            _isLoading = false;
          }
          update();
        } else {
          redeemList = [
            ...redeemList,
            ...r.RedeemHistoryModel.fromJson(data).message!.redeemCodes!.data!
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
      redeemList = [];
    }
  }

  @override
  void onInit() {
    super.onInit();
    getRedeemList(page: page, email: "", status: "", created_at: "", utr: "");
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
    redeemList.clear();
  }
}
