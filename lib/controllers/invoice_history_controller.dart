import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:paysecure/data/repositories/invoice_repo.dart';
import '../data/models/invoice_history_model.dart' as invoice;
import '../data/models/invoice_view_model.dart';
import '../data/models/pay_bill_model.dart' as payBill;
import '../data/source/errors/check_api_status.dart';
import '../utils/services/helpers.dart';
import 'redeem_code_controller.dart';

class InvoiceHistoryController extends GetxController {
  static InvoiceHistoryController get to =>
      Get.find<InvoiceHistoryController>();
  TextEditingController emailEditingCtrlr = TextEditingController();
  TextEditingController dateTimeEditingCtrlr = TextEditingController();
  dynamic selectedStatus = "All Status";
  List<String> statusList = [
    "All Status",
    "Paid",
    "UnPaid",
    "Rejected",
  ];
  late ScrollController scrollController;
  int page = 1;
  bool isLoadMore = false;
  bool hasNextPage = true;
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  List<invoice.Datum> invoiceList = [];
  List<payBill.Currency> currencyList = [];
  List<CustomCurrencyModel> customCurrencyList = [];

  dynamic selectedCurrency = null;
  String selectedCurrencyId = "";
  Future loadMore() async {
    if (_isLoading == false &&
        isLoadMore == false &&
        hasNextPage == true &&
        scrollController.position.extentAfter < 300) {
      isLoadMore = true;
      update();
      page += 1;
      await getInvoiceList(
          page: page,
          email: emailEditingCtrlr.text,
          status: selectedStatus == "All Status"
              ? ""
              : selectedStatus == "Paid"
                  ? "paid"
                  : selectedStatus == "UnPaid"
                      ? "unpaid"
                      : selectedStatus == "Rejected"
                          ? "rejected"
                          : selectedStatus,
          created_at: dateTimeEditingCtrlr.text,
          currency_id: selectedCurrencyId,
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
    invoiceList.clear();
    page = 1;
    isSearchTapped = true;
    hasNextPage = true;
    update();
  }

  refreshSearchData() {
    dateTimeEditingCtrlr.clear();
    emailEditingCtrlr.clear();
    selectedCurrency = null;
    selectedCurrencyId = "";
    selectedStatus = "All Status";
    update();
  }

  Future getInvoiceList(
      {required int page,
      required String email,
      required String currency_id,
      required String created_at,
      required String status,
      bool? isLoadMoreRunning = false}) async {
    if (isLoadMoreRunning == false) {
      _isLoading = true;
    }
    update();
    http.Response response = await InvoiceRepo.getInvoiceList(
        page: page,
        email: email,
        currency_id: currency_id,
        created_at: created_at,
        status: status);
    if (page == 1 && isLoadMoreRunning == false) {
      invoiceList.clear();
    }
    if (isLoadMoreRunning == false) {
      _isLoading = false;
    }
    update();

    if (response.statusCode == 200) {
      var data = jsonDecode(response.body);

      if (data['status'] == 'success') {
        // get currency list
        currencyList.clear();
        customCurrencyList.clear();
        currencyList
            .addAll(payBill.PayBillModel.fromJson(data).message!.currencies!);
        if (currencyList.isNotEmpty) {
          for (var i in currencyList) {
            customCurrencyList.add(CustomCurrencyModel(
                id: i.id,
                currency_code: i.code + " - " + i.name,
                currencyType: i.currencyType));
          }
        }
        final fetchedData = data['message']['invoices']['data'];
        if (fetchedData.isNotEmpty) {
          invoiceList = [
            ...invoiceList,
            ...invoice.InvoiceHistoryModel.fromJson(data)
                .message!
                .invoices!
                .data!
          ];
          if (isLoadMoreRunning == false) {
            _isLoading = false;
          }
          update();
        } else {
          invoiceList = [
            ...invoiceList,
            ...invoice.InvoiceHistoryModel.fromJson(data)
                .message!
                .invoices!
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
      invoiceList = [];
    }
  }

  //-----invoice reminder
  bool isRemindering = false;
  Future invoiceReminder(
      {required Map<String, dynamic> fields, context}) async {
    isRemindering = true;
    update();
    http.Response response = await InvoiceRepo.invoiceReminder(data: fields);
    isRemindering = false;
    update();
    var data = jsonDecode(response.body);
    if (response.statusCode == 200) {
      ApiStatus.checkStatus(data['status'], data['message']);
      Navigator.pop(context);
      if (data['status'] == "success") {
        resetDataAfterSearching();
        getInvoiceList(
            page: 1, email: "", status: "", created_at: "", currency_id: "");
      }
    } else {
      Helpers.showSnackBar(msg: '${data['message']}');
    }
  }

  //------invoice view
  bool isViewingInvoice = false;
  List<InvoiceViewModel> invoiceViewList = [];
  String currency = '';
  Future getInvoiceView({required String id}) async {
    isViewingInvoice = true;
    update();
    http.Response response = await InvoiceRepo.getInvoiceView(id: id);
    invoiceViewList.clear();
    isViewingInvoice = false;
    update();
    var data = jsonDecode(response.body);
    if (response.statusCode == 200) {
      if (data['status'] == 'success') {
        invoiceViewList.add(InvoiceViewModel.fromJson(data));
        if (invoiceViewList.isNotEmpty) {
          if (data['message']['currencies'] != null &&
              data['message']['currencies'] is List) {
            var currencyList = data['message']['currencies'];
            currency = currencyList.firstWhere((e) =>
                e['id'] ==
                invoiceViewList[0].message!.invoice!.currencyId)['code'];
          }
        }
      } else {
        ApiStatus.checkStatus(data['status'], data['message']);
      }
    } else {
      Helpers.showSnackBar(msg: '${data['message']}');
    }
  }

  @override
  void onInit() {
    super.onInit();
    getInvoiceList(
        page: page, email: "", status: "", created_at: "", currency_id: "");
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
    invoiceList.clear();
  }
}
