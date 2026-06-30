import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:paysecure/data/repositories/escrow_repo.dart';
import 'package:paysecure/utils/services/helpers.dart';
import '../data/models/escrow_history_model.dart' as escrow;
import '../data/source/errors/check_api_status.dart';

class EscrowHistoryController extends GetxController {
  static EscrowHistoryController get to => Get.find<EscrowHistoryController>();
  TextEditingController emailEditingCtrlr = TextEditingController();
  TextEditingController dateTimeEditingCtrlr = TextEditingController();
  TextEditingController utrEditingCtrlr = TextEditingController();
  dynamic selectedStatus = "All Status";
  List<String> statusList = [
    "All Status",
    "Pending",
    "Generated",
    "Payment done",
    "Request for payment",
    "Payment disbursed",
    "Cancel",
  ];
  late ScrollController scrollController;
  int page = 1;
  bool isLoadMore = false;
  bool hasNextPage = true;
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  List<escrow.Datum> escrowList = [];
  Future loadMore() async {
    if (_isLoading == false &&
        isLoadMore == false &&
        hasNextPage == true &&
        scrollController.position.extentAfter < 300) {
      isLoadMore = true;
      update();
      page += 1;
      await getEscrowList(
          page: page,
          email: emailEditingCtrlr.text,
          status: selectedStatus == "All Status"
              ? ""
              : selectedStatus == "Pending"
                  ? "0"
                  : selectedStatus == "Generated"
                      ? "1"
                      : selectedStatus == "Payment done"
                          ? "2"
                          : selectedStatus == "Request for payment"
                              ? "3"
                              : selectedStatus == "Payment disbursed"
                                  ? "4"
                                  : "5",
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
    escrowList.clear();
    page = 1;
    isSearchTapped = true;
    hasNextPage = true;
    update();
  }

  refreshSearchData() {
    dateTimeEditingCtrlr.clear();
    emailEditingCtrlr.clear();
    utrEditingCtrlr.clear();
    selectedStatus = "All Status";
    update();
  }

  Future getEscrowList(
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
    http.Response response = await EscrowRepo.getEscrowList(
        page: page,
        email: email,
        utr: utr,
        created_at: created_at,
        status: status);
    if (page == 1 && isLoadMoreRunning == false) {
      escrowList.clear();
    }
    if (isLoadMoreRunning == false) {
      _isLoading = false;
    }
    update();

    if (response.statusCode == 200) {
      var data = jsonDecode(response.body);

      if (data['status'] == 'success') {
        try {
          final fetchedData = data['message']['escrows']['data'];
          if (fetchedData.isNotEmpty) {
            escrowList = [
              ...escrowList,
              ...escrow.EscrowPreviewModel.fromJson(data)
                  .message!
                  .escrows!
                  .data!
            ];
            if (isLoadMoreRunning == false) {
              _isLoading = false;
            }
            update();
          } else {
            escrowList = [
              ...escrowList,
              ...escrow.EscrowPreviewModel.fromJson(data)
                  .message!
                  .escrows!
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
        } catch (e) {
          Helpers.showSnackBar(msg: e.toString());
        }
      } else {
        ApiStatus.checkStatus(data['status'], data['message']);
      }
    } else {
      escrowList = [];
    }
  }

  @override
  void onInit() {
    super.onInit();
    getEscrowList(page: page, email: "", status: "", created_at: "", utr: "");
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
    escrowList.clear();
  }
}
