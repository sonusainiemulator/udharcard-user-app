import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import '../data/models/qr_payment_history_model.dart' as QR;
import '../data/repositories/qr_payment_repo.dart';
import '../data/source/errors/check_api_status.dart';

class QrPaymentController extends GetxController {
  TextEditingController dateTimeEditingCtrlr = TextEditingController();
  TextEditingController emailEditingCtrlr = TextEditingController();
  late ScrollController scrollController;
  int page = 1;
  bool isLoadMore = false;
  bool hasNextPage = true;
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  List<QR.Datum> qrPaymentList = [];
  List<QR.Gateway> gatewayList = [];
  dynamic selectedGateway = null;
  String selectedGatewayId = "0";
  Future loadMore() async {
    if (_isLoading == false &&
        isLoadMore == false &&
        hasNextPage == true &&
        scrollController.position.extentAfter < 300) {
      isLoadMore = true;
      update();
      page += 1;
      await getQrPaymentList(
          page: page,
          gateway: selectedGatewayId,
          email: emailEditingCtrlr.text,
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
    qrPaymentList.clear();
    page = 1;
    isSearchTapped = true;
    hasNextPage = true;
    update();
  }

  Future getQrPaymentList(
      {required int page,
      required String gateway,
      required String email,
      required String created_at,
      bool? isLoadMoreRunning = false}) async {
    if (isLoadMoreRunning == false) {
      _isLoading = true;
    }
    update();
    http.Response response = await QRPaymentRepo.getQrPaymentList(
        page: page, email: email, datetrx: created_at, gateway: gateway);
    if (isLoadMoreRunning == false) {
      _isLoading = false;
    }
    update();

    if (response.statusCode == 200) {
      var data = jsonDecode(response.body);

      if (data['status'] == 'success') {
        gatewayList = [];
        gatewayList.add(QR.Gateway(id: "", name: "All", status: "1"));
        gatewayList
            .addAll(QR.QrPaymentHistoryModel.fromJson(data).message!.gateways!);
        final fetchedData = data['message']['qrPayments']['data'];

        if (fetchedData.isNotEmpty) {
          qrPaymentList = [
            ...qrPaymentList,
            ...QR.QrPaymentHistoryModel.fromJson(data)
                .message!
                .qrPayments!
                .data!
          ];
          if (isLoadMoreRunning == false) {
            _isLoading = false;
          }
          update();
        } else {
          qrPaymentList = [
            ...qrPaymentList,
            ...QR.QrPaymentHistoryModel.fromJson(data)
                .message!
                .qrPayments!
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
      qrPaymentList = [];
    }
  }

  @override
  void onInit() {
    super.onInit();
    getQrPaymentList(page: page, gateway: "", email: "", created_at: "");
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
    qrPaymentList.clear();
  }
}
