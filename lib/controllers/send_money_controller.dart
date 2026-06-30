import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:paysecure/controllers/send_money_history_controller.dart';
import 'package:paysecure/data/repositories/send_monye_repo.dart';
import '../data/models/amount_check_model.dart';
import '../data/models/getRedeem_code_model.dart' as getRedeemCode;
import '../data/models/send_money_preview_model.dart' as prev;
import '../data/repositories/redeem_code_repo.dart';
import '../data/source/errors/check_api_status.dart';
import '../utils/services/helpers.dart';
import '../views/screens/send_money/send_money_history_screen.dart';
import '../views/screens/send_money/send_money_preview_screen.dart';

class SendMoneyController extends GetxController {
  static SendMoneyController get to => Get.find<SendMoneyController>();

  bool isLoading = false;

  TextEditingController amountController = TextEditingController();
  TextEditingController noteController = TextEditingController();
  TextEditingController recipientEmailController = TextEditingController();
  String amountVal = "";
  List<getRedeemCode.Currency> currencyList = [];
  List<CustomCurrencyModel> customCurrencyList = [];
  String description = "";
  dynamic selectedCurrency = null;
  String selectedCurrencyId = "0";
  bool isChargeFrom = false;
  //------------------send money screen----
  Future getsendMoney() async {
    isLoading = true;
    update();
    http.Response response = await SendMoneyRepo.getsendMoney();
    currencyList.clear();
    customCurrencyList.clear();
    isLoading = false;
    update();
    var data = jsonDecode(response.body);
    if (response.statusCode == 200) {
      if (data['status'] == 'success') {
        if (data['message']['template'] != null &&
            data['message']['template']['description'] != null) {
          description =
              data['message']['template']['description']['short_description']
                  .toString();
        }

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
    http.Response response = await RedeemCodeRepo.checkRedeemAmount(
      data: fields,
    );
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
  Future checkRecipient({required String recipient}) async {
    isGettingAmountCheck = true;
    update();
    http.Response response = await SendMoneyRepo.checkRecipient(
      recipient: recipient,
    );
    isGettingAmountCheck = false;
    amountCheckList = [];
    update();
    var data = jsonDecode(response.body);
    if (response.statusCode == 200) {
      if (data['status'] == 'success') {
        checkRecipientmessage = data['message']['message'];
        update();
      } else {
        ApiStatus.checkStatus(data['status'], data['message']);
      }
    } else {
      Helpers.showSnackBar(msg: '${data['message']}');
    }
  }

  bool isSubmit = false;
  Future submitSendMoney({required Map<String, dynamic> fields}) async {
    isSubmit = true;
    update();
    http.Response response = await SendMoneyRepo.submitSendMoney(data: fields);
    isSubmit = false;
    update();
    var data = jsonDecode(response.body);
    if (response.statusCode == 200) {
      if (data['status'] == 'success') {
        if (data['message'] != null && data['message'].toString().isNotEmpty) {
          sendMoneyPreview(utr: data['message'].toString());
          Get.to(() => SendMoneyPreviewScreen(utr: data['message'].toString()));
        }
        update();
      } else {
        ApiStatus.checkStatus(data['status'], data['message']);
      }
    } else {
      Helpers.showSnackBar(msg: '${data['message']}');
    }
  }

  //---------confirm send money screen--
  List<prev.Message> sendMoneyPreviewList = [];
  Future sendMoneyPreview({required String utr}) async {
    isLoading = true;
    update();
    http.Response response = await SendMoneyRepo.sendMoneyPreview(utr: utr);
    sendMoneyPreviewList.clear();
    isLoading = false;
    update();
    var data = jsonDecode(response.body);
    if (response.statusCode == 200) {
      if (data['status'] == 'success') {
        sendMoneyPreviewList.add(
          prev.SendMoneyPreviewModel.fromJson(data).message!,
        );
      } else {
        ApiStatus.checkStatus(data['status'], data['message']);
      }
    } else {
      Helpers.showSnackBar(msg: '${data['message']}');
    }
  }

  TextEditingController securityPinController = TextEditingController();
  Future sendMoneyConfirm({
    required Map<String, dynamic> fields,
    bool? isFromHistoryPage = false,
    required BuildContext context,
  }) async {
    isSubmit = true;
    update();
    http.Response response = await SendMoneyRepo.sendMoneyConfirm(data: fields);
    isSubmit = false;
    update();
    var data = jsonDecode(response.body);
    if (response.statusCode == 200) {
      ApiStatus.checkStatus(data['status'], data['message']);
      if (data['status'] == 'success') {
        securityPinController.clear();
        amountController.clear();
        recipientEmailController.clear();
        selectedCurrencyId = "0";
        selectedCurrency = null;
        isChargeFrom == false;
        noteController.clear();
        amountCheckList.clear();
        SendMoneyHistoryController.to.resetDataAfterSearching();
        SendMoneyHistoryController.to.getSendMoneyList(
          page: 1,
          email: "",
          created_at: "",
          utr: "",
        );

        Get.to(() => SendMoneyHistoryScreen(isFromSendMoneyPage: true));

        update();
      }
    } else {
      Helpers.showSnackBar(msg: '${data['message']}');
    }
  }

  @override
  void onInit() {
    getsendMoney();
    super.onInit();
  }
}

class CustomCurrencyModel {
  dynamic id;
  dynamic currency_code;
  dynamic currencyType;
  CustomCurrencyModel({this.id, this.currency_code, this.currencyType});
}
