import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import '../data/models/dispute_history_model.dart' as dispute;
import '../data/repositories/dispute_repo.dart';
import '../data/source/errors/check_api_status.dart';

class DisputeHistoryController extends GetxController {
  static DisputeHistoryController get to =>
      Get.find<DisputeHistoryController>();
  TextEditingController utrEditingCtrlr = TextEditingController();
  TextEditingController dateTimeEditingCtrlr = TextEditingController();
  dynamic selectedStatus = "All Status";
  List<String> statusList = [
    "All Status",
    "Open",
    "Solved",
    "Closed",
  ];
  late ScrollController scrollController;
  int page = 1;
  bool isLoadMore = false;
  bool hasNextPage = true;
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  List<dispute.Datum> disputeList = [];
  Future loadMore() async {
    if (_isLoading == false &&
        isLoadMore == false &&
        hasNextPage == true &&
        scrollController.position.extentAfter < 300) {
      isLoadMore = true;
      update();
      page += 1;
      await getDisputeList(
          page: page,
          utr: utrEditingCtrlr.text,
          status: selectedStatus == "All Status" ? "" : selectedStatus,
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
    disputeList.clear();
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

  Future getDisputeList(
      {required int page,
      required String utr,
      required String created_at,
      required String status,
      bool? isLoadMoreRunning = false}) async {
    if (isLoadMoreRunning == false) {
      _isLoading = true;
    }
    update();
    http.Response response = await DisputeRepo.getDisputeList(
        page: page, utr: utr, created_at: created_at, status: status);
    if (page == 1 && isLoadMoreRunning == false) {
      disputeList.clear();
    }
    if (isLoadMoreRunning == false) {
      _isLoading = false;
    }
    update();

    if (response.statusCode == 200) {
      var data = jsonDecode(response.body);

      if (data['status'] == 'success') {
        final fetchedData = data['message']['disputes']['target']['data'];
        if (fetchedData.isNotEmpty) {
          disputeList = [
            ...disputeList,
            ...dispute.DisputeHistoryModel.fromJson(data)
                .message!
                .disputes!
                .target!
                .data!
          ];
          if (isLoadMoreRunning == false) {
            _isLoading = false;
          }
          update();
        } else {
          disputeList = [
            ...disputeList,
            ...dispute.DisputeHistoryModel.fromJson(data)
                .message!
                .disputes!
                .target!
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
      disputeList = [];
    }
  }

  @override
  void onInit() {
    super.onInit();
    getDisputeList(page: page, utr: "", status: "", created_at: "");
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
    disputeList.clear();
  }
}
