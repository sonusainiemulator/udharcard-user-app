import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:paysecure/views/screens/cashout/cash_out_preview_screen.dart';
import '../data/models/amount_check_model.dart';
import '../data/models/getRedeem_code_model.dart' as getRedeemCode;
import '../data/models/makePayment_preview_model.dart' as prev;
import '../data/repositories/cashout_repo.dart';
import '../data/source/errors/check_api_status.dart';
import '../utils/services/helpers.dart';

class CashoutController extends GetxController {
  static CashoutController get to => Get.find<CashoutController>();

  bool isLoading = false;

  TextEditingController amountController = TextEditingController();
  TextEditingController noteController = TextEditingController();
  TextEditingController agentEmailController = TextEditingController();
  String amountVal = "";
  List<getRedeemCode.Currency> currencyList = [];
  List<CustomCurrencyModel> customCurrencyList = [];
  dynamic selectedCurrency = null;
  String selectedCurrencyId = "0";
  //------------------cashout screen----
  Future getCurrency() async {
    isLoading = true;
    update();
    http.Response response = await CashoutRepo.getsendMoney();
    currencyList.clear();
    customCurrencyList.clear();
    isLoading = false;
    update();
    var data = jsonDecode(response.body);
    if (response.statusCode == 200) {
      if (data['status'] == 'success') {
        currencyList.addAll(
          getRedeemCode.GetRedeemCodeModel.fromJson(data).message!.currencies!,
        );
        if (currencyList.isNotEmpty) {
          for (var i in currencyList) {
            customCurrencyList.add(
              CustomCurrencyModel(
                id: i.id,
                currency_code: i.code + " - " + i.name,
                currencyType: i.currencyType,
              ),
            );
          }
        }
      } else {
        ApiStatus.checkStatus(data['status'], data['message']);
      }
    } else {
      Helpers.showSnackBar(msg: '${data['message']}');
    }
  }

  //------------check amount----
  List<AmountCheckModel> amountCheckList = [];
  bool isGettingAmountCheck = false;
  Future cashoutCheckAmount({required Map<String, dynamic> fields}) async {
    isGettingAmountCheck = true;
    update();
    http.Response response = await CashoutRepo.cashoutCheckAmount(data: fields);
    isGettingAmountCheck = false;
    amountCheckList = [];
    update();
    var data = jsonDecode(response.body);
    if (response.statusCode == 200) {
      if (data['status'] == 'success') {
        amountCheckList.add(AmountCheckModel.fromJson(data));
        update();
      } else {
        ApiStatus.checkStatus(data['status'], data['message']);
      }
    } else {
      Helpers.showSnackBar(msg: '${data['message']}');
    }
  }

  String checkRecipientmessage = "";
  Future checkAgent({required String agent}) async {
    isGettingAmountCheck = true;
    update();
    http.Response response = await CashoutRepo.checkAgent(merchant: agent);
    isGettingAmountCheck = false;
    amountCheckList = [];
    update();
    var data = jsonDecode(response.body);
    if (response.statusCode == 200) {
      if (data['status'] == 'success') {
        checkRecipientmessage = data['message']['message'];
        update();
      }
    } else {
      Helpers.showSnackBar(msg: '${data['message']}');
    }
  }

  bool isSubmit = false;
  Future initCashout({required Map<String, dynamic> fields}) async {
    isSubmit = true;
    update();
    http.Response response = await CashoutRepo.initCashout(data: fields);
    isSubmit = false;
    update();
    var data = jsonDecode(response.body);
    if (response.statusCode == 200) {
      if (data['status'] == 'success') {
        if (data['message'] != null) {
          cashoutPreview(utr: data['message']['trx_id'].toString());
          Get.to(
            () =>
                CashoutPreviewScreen(utr: data['message']['trx_id'].toString()),
          );
        }
        update();
      } else {
        ApiStatus.checkStatus(data['status'], data['message']);
      }
    } else {
      Helpers.showSnackBar(msg: '${data['message']}');
    }
  }

  //---------make payment preview screen--
  List<prev.Message> makePaymentPreviewList = [];
  Future cashoutPreview({required String utr}) async {
    isLoading = true;
    update();
    http.Response response = await CashoutRepo.cashoutPreview(utr: utr);
    makePaymentPreviewList.clear();
    isLoading = false;
    update();
    var data = jsonDecode(response.body);
    if (response.statusCode == 200) {
      if (data['status'] == 'success') {
        makePaymentPreviewList.add(
          prev.MakePaymentPreviewModel.fromJson(data).message!,
        );
      } else {
        ApiStatus.checkStatus(data['status'], data['message']);
      }
    } else {
      Helpers.showSnackBar(msg: '${data['message']}');
    }
  }

  TextEditingController securityPinController = TextEditingController();
  Future cashoutConfirm({
    required Map<String, dynamic> fields,
    bool? isFromHistoryPage = false,
    required String utr,
    required BuildContext context,
  }) async {
    isSubmit = true;
    update();
    http.Response response = await CashoutRepo.cashoutConfirm(
      data: fields,
      utr: utr,
    );
    isSubmit = false;
    update();
    var data = jsonDecode(response.body);
    if (response.statusCode == 200) {
      if (data['status'] == 'success') {
        securityPinController.clear();
        amountController.clear();
        agentEmailController.clear();
        selectedCurrencyId = "0";
        selectedCurrency = null;
        noteController.clear();
        amountCheckList.clear();
        Get.back();
        Get.back();
        Get.back();

        update();
      }
      ApiStatus.checkStatus(data['status'], data['message']);
    } else {
      Helpers.showSnackBar(msg: '${data['message']}');
    }
  }

  @override
  void onInit() {
    getCurrency();
    super.onInit();
  }
}

class CustomCurrencyModel {
  dynamic id;
  dynamic currency_code;
  dynamic currencyType;
  CustomCurrencyModel({this.id, this.currency_code, this.currencyType});
}
