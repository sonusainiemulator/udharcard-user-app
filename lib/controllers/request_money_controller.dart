import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:paysecure/controllers/bindings/controller_index.dart';
import '../data/models/amount_check_model.dart';
import '../data/models/getRedeem_code_model.dart' as getRedeemCode;
import '../data/models/request_money_preview_model.dart' as rPrev;
import '../data/repositories/redeem_code_repo.dart';
import '../data/repositories/request_money_repo.dart';
import '../data/source/errors/check_api_status.dart';
import '../utils/services/helpers.dart';
import '../views/screens/request_money/request_money_history_screen.dart';
import '../views/screens/request_money/request_money_preview_confirm_screen.dart';

class RequestMoneyController extends GetxController {
  static RequestMoneyController get to => Get.find<RequestMoneyController>();

  bool isLoading = false;

  TextEditingController recipientEmailController = TextEditingController();
  TextEditingController amountController = TextEditingController();
  TextEditingController noteController = TextEditingController();
  String amountVal = "";

  //------------------Security Pin manage----
  bool isActiveSecurityPin = false;
  Future getSecurityPinManage() async {
    isLoading = true;
    update();
    http.Response response = await RequestRepo.getSecurityPinManage();
    isLoading = false;
    update();
    var data = jsonDecode(response.body);
    if (response.statusCode == 200) {
      if (data['status'] == 'success') {
        if (data['message']['enable_for'] != null &&
            data['message']['enable_for'] is List) {
          List enableForList = data['message']['enable_for'];
          if (enableForList.isNotEmpty) {
            for (var i in enableForList) {
              print(i);
              if (i.toString() == "request") {
                isActiveSecurityPin = true;
              }
            }
          }
        }
        update();
      } else {
        ApiStatus.checkStatus(data['status'], data['message']);
      }
    } else {
      Helpers.showSnackBar(msg: '${data['message']}');
    }
  }

  List<getRedeemCode.Currency> currencyList = [];
  List<CustomCurrencyModel> customCurrencyList = [];
  String description = "";
  dynamic selectedCurrency = null;
  String selectedCurrencyId = "0";
  bool isChargeFrom = false;
  //------------------Request Money screen----
  Future getRequestMoney() async {
    isLoading = true;
    update();
    http.Response response = await RequestRepo.getRequestMoney();
    currencyList.clear();
    customCurrencyList.clear();
    isLoading = false;
    update();
    var data = jsonDecode(response.body);
    if (response.statusCode == 200) {
      if (data['status'] == 'success') {
        if (data['message']['template'] != null &&
            data['message']['template']['description'] != null) {
          description = data['message']['template']['description']
                  ['short_description']
              .toString();
        }

        currencyList.addAll(getRedeemCode.GetRedeemCodeModel.fromJson(data)
            .message!
            .currencies!);
        if (currencyList.isNotEmpty) {
          for (var i in currencyList) {
            customCurrencyList.add(CustomCurrencyModel(
                id: i.id,
                currency_code: i.code + " - " + i.name,
                currencyType: i.currencyType));
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
  String availableBalance = "";
  String fixedCharge = "";
  String percentage = "";
  String percentageCharge = "";
  String receivedAmount = "";
  String payableAmount = "";
  String charge = "";
  String chargeFrom = "";
  String note = "";

  bool isGettingAmountCheck = false;
  /*
  Whatever section you want to check then you have to put one of the transaction_type_id of below this-
  'transfer' => 1,
  'request' => 2,
  'exchange' => 3,
  'redeem' => 4,
  'escrow' => 5,
  'voucher' => 6,
  'deposit' => 7,
  'payout' => 8,
  'invoice' => 9,
  'virtual_card' => 10,
  'bill_payment' => 11
  */
  Future checkRedeemAmount({required Map<String, dynamic> fields}) async {
    isGettingAmountCheck = true;
    update();
    http.Response response =
        await RedeemCodeRepo.checkRedeemAmount(data: fields);
    isGettingAmountCheck = false;
    amountCheckList = [];
    update();
    var data = jsonDecode(response.body);
    if (response.statusCode == 200) {
      if (data['status'] == 'success') {
        amountCheckList.add(AmountCheckModel.fromJson(data));
        if (amountCheckList.isNotEmpty) {
          fixedCharge = amountCheckList[0].message!.fixedCharge.toString();
          percentage = amountCheckList[0].message!.percentage.toString();
          percentageCharge =
              amountCheckList[0].message!.percentageCharge.toString();
          receivedAmount = amountCheckList[0].message!.amount.toString();
          payableAmount = amountCheckList[0].message!.receivedAmount.toString();
          charge = amountCheckList[0].message!.charge.toString();
          chargeFrom = amountCheckList[0].message!.chargeFrom.toString();
        }
        update();
      } else {
        ApiStatus.checkStatus(data['status'], data['message']);
      }
    } else {
      Helpers.showSnackBar(msg: '${data['message']}');
    }
  }

  bool isSubmit = false;
  bool isClickedAcceptBtn = false;
  bool isClickedCancelBtn = false;
  Future submitRequestMoney({required Map<String, dynamic> fields}) async {
    isSubmit = true;
    update();
    http.Response response = await RequestRepo.submitRequestMoney(data: fields);
    isSubmit = false;
    update();
    var data = jsonDecode(response.body);
    if (response.statusCode == 200) {
      ApiStatus.checkStatus(data['status'], data['message']);
      if (data['status'] == 'success') {
        recipientEmailController.clear();
        selectedCurrency = null;
        selectedCurrencyId = "";
        amountController.clear();
        noteController.clear();
        RequestHistoryController.to.resetDataAfterSearching();
        RequestHistoryController.to
            .getRequestList(page: 1, email: '', utr: '', created_at: '');
        Get.to((RequestMoneyHistoryScreen(isFromRequestMoneyPage: true)));
        update();
      }
    } else {
      Helpers.showSnackBar(msg: '${data['message']}');
    }
  }

  //---------confirm money request screen--
  List<rPrev.Message> requestMoneyPreviewList = [];
  Future requestMoneyPreview({required String utr}) async {
    isLoading = true;
    update();
    http.Response response = await RequestRepo.requestMoneyPreview(utr: utr);
    requestMoneyPreviewList.clear();
    isLoading = false;
    update();
    var data = jsonDecode(response.body);
    if (response.statusCode == 200) {
      if (data['status'] == 'success') {
        requestMoneyPreviewList
            .add(rPrev.RequestMoneyPreviewModel.fromJson(data).message!);
        if (requestMoneyPreviewList.isNotEmpty) {
          isChargeFrom = requestMoneyPreviewList[0]
                      .chargeDeductFrom
                      .toString()
                      .toLowerCase() ==
                  "sender"
              ? false
              : true;
          selectedCurrencyId = requestMoneyPreviewList[0].currencyId.toString();
          recipientEmailController.text =
              requestMoneyPreviewList[0].name.toString();
          noteController.text = requestMoneyPreviewList[0].note.toString();
          amountController.text =
              requestMoneyPreviewList[0].payableAmount.toString();
          selectedCurrency = requestMoneyPreviewList[0].currency.toString();
          fixedCharge = requestMoneyPreviewList[0].fixedCharge.toString();
          percentage = requestMoneyPreviewList[0].percent.toString();
          percentageCharge =
              requestMoneyPreviewList[0].percentCharge.toString();
          receivedAmount = requestMoneyPreviewList[0].payableAmount.toString();
          payableAmount =
              requestMoneyPreviewList[0].receiverWillReceive.toString();
          charge = requestMoneyPreviewList[0].totalCharge.toString();
          chargeFrom = requestMoneyPreviewList[0].chargeDeductFrom.toString();
          note = requestMoneyPreviewList[0].note.toString();

          update();
        }
      } else {
        ApiStatus.checkStatus(data['status'], data['message']);
      }
    } else {
      Helpers.showSnackBar(msg: '${data['message']}');
    }
  }

  Future requestMoneyCheckSubmit(
      {required Map<String, dynamic> fields,
      required BuildContext context}) async {
    isSubmit = true;
    update();
    http.Response response =
        await RequestRepo.requestMoneyCheckSubmit(data: fields);
    isSubmit = false;
    update();
    var data = jsonDecode(response.body);
    if (response.statusCode == 200) {
      if (data['status'] == 'success') {
        if (data['message']['utr'] != null) {
          requestMoneyPreview(utr: data['message']['utr']);
          Get.to(() =>
              RequestMoneyPreviewConfirmScreen(utr: data['message']['utr']));
        }
      } else {
        ApiStatus.checkStatus(data['status'], data['message']);
      }
    } else {
      Helpers.showSnackBar(msg: '${data['message']}');
    }
  }

  String utr = "";
  Future requestMoneyConfirm(
      {required Map<String, dynamic> fields,
      required BuildContext context}) async {
    isSubmit = true;
    update();
    http.Response response =
        await RequestRepo.requestMoneyConfirm(data: fields);
    isSubmit = false;
    update();
    var data = jsonDecode(response.body);
    if (response.statusCode == 200) {
      ApiStatus.checkStatus(data['status'], data['message']);
      if (data['status'] == 'success') {
        RequestHistoryController.to.refreshSearchData();
        RequestHistoryController.to.resetDataAfterSearching();
        await RequestHistoryController.to
            .getRequestList(page: 1, email: "", utr: "", created_at: "");
        RequestHistoryController.to.update();
        Get.to(() => RequestMoneyHistoryScreen(isFromRequestMoneyPage: true));
        update();
      }
    } else {
      Helpers.showSnackBar(msg: '${data['message']}');
    }
  }

  TextEditingController securityPinController = TextEditingController();
  int tappedIndex = 0;
  Future requestCancel({required String utr}) async {
    isSubmit = true;
    update();
    http.Response response = await RequestRepo.requestCancel(utr: utr);
    isSubmit = false;
    update();
    var data = jsonDecode(response.body);
    if (response.statusCode == 200) {
      ApiStatus.checkStatus(data['status'], data['message']);
      if (data['status'] == 'success') {
        RequestHistoryController.to.resetDataAfterSearching();
        RequestHistoryController.to.getRequestList(
          page: 1,
          email: "",
          created_at: "",
          utr: "",
        );
        update();
      }
    } else {
      Helpers.showSnackBar(msg: '${data['message']}');
    }
  }

  @override
  void onInit() {
    getRequestMoney();
    getSecurityPinManage();
    super.onInit();
  }
}

class CustomCurrencyModel {
  dynamic id;
  dynamic currency_code;
  dynamic currencyType;
  CustomCurrencyModel({
    this.id,
    this.currency_code,
    this.currencyType,
  });
}
