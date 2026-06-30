import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:paysecure/controllers/bindings/controller_index.dart';
import 'package:paysecure/data/repositories/exchange_repo.dart';
import 'package:paysecure/views/screens/exchange/exchange_money_preview_screen.dart';
import '../data/models/amount_check_model.dart';
import '../data/models/getRedeem_code_model.dart' as getRedeemCode;
import '../data/models/exchange_preview_model.dart' as exPrev;
import '../data/repositories/redeem_code_repo.dart';
import '../data/source/errors/check_api_status.dart';
import '../utils/services/helpers.dart';
import '../views/screens/exchange/exchange_money_history_screen.dart';

class ExchangeController extends GetxController {
  static ExchangeController get to => Get.find<ExchangeController>();
  bool isLoading = false;

  TextEditingController amountController = TextEditingController();
  String amountVal = "";
  FocusNode amountFocusNode = FocusNode();

  List<getRedeemCode.Currency> currencyList = [];
  List<CustomCurrencyModel> customFromWalletCurrencyList = [];
  String description = "";
  dynamic selectedFromWalletCurrency = null;
  String selectedFromWalletCurrencyId = "0";
  //------------------Exchange Money screen----
  Future getexchangeMoney() async {
    isLoading = true;
    update();
    http.Response response = await ExchangeRepo.getexchangeMoney();
    currencyList.clear();
    customFromWalletCurrencyList.clear();
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
            customFromWalletCurrencyList.add(CustomCurrencyModel(
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

  List<CustomCurrencyModel> toWalletList = [];
  dynamic selectedToWalletCurrency = null;
  String selectedToWalletCurrencyId = "0";
  filterToWalletData(v) {
    selectedToWalletCurrency = null;
    selectedToWalletCurrencyId = "0";
    int indexToRemove =
        customFromWalletCurrencyList.indexWhere((e) => e.currency_code == v);
    toWalletList = [...customFromWalletCurrencyList];
    toWalletList.removeAt(indexToRemove);
    update();
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
    http.Response response =
        await RedeemCodeRepo.checkRedeemAmount(data: fields);
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

  bool isSubmit = false;
  bool isClickedAcceptBtn = false;
  bool isClickedCancelBtn = false;
  Future submitExchangeMoney({required Map<String, dynamic> fields}) async {
    isSubmit = true;
    update();
    http.Response response =
        await ExchangeRepo.submitExchangeMoney(data: fields);
    isSubmit = false;
    update();
    var data = jsonDecode(response.body);
    if (response.statusCode == 200) {
      if (data['status'] == 'success') {
        selectedFromWalletCurrency = null;
        selectedFromWalletCurrencyId = "";
        selectedToWalletCurrency = null;
        selectedToWalletCurrencyId = "";
        amountController.clear();
        amountCheckList.clear();
        if (data['message']['utr'] != null &&
            data['message']['utr'].toString().isNotEmpty) {
          exchangeMoneyPreview(utr: data['message']['utr'].toString());
          Get.to(() => ExchangeMoneyPreviewScreen(
                utr: data['message']['utr'].toString(),
              ));
        }
        update();
      } else {
        ApiStatus.checkStatus(data['status'], data['message']);
      }
    } else {
      Helpers.showSnackBar(msg: '${data['message']}');
    }
  }

  //---------confirm exchange screen--
  List<exPrev.Message> exchangePreviewList = [];
  Future exchangeMoneyPreview({required String utr}) async {
    isLoading = true;
    update();
    http.Response response = await ExchangeRepo.exchangeMoneyPreview(utr: utr);
    exchangePreviewList.clear();
    isLoading = false;
    update();
    var data = jsonDecode(response.body);
    if (response.statusCode == 200) {
      if (data['status'] == 'success') {
        exchangePreviewList
            .add(exPrev.ExchangeMoneyPreviewModel.fromJson(data).message!);
      } else {
        ApiStatus.checkStatus(data['status'], data['message']);
      }
    } else {
      Helpers.showSnackBar(msg: '${data['message']}');
    }
  }

  TextEditingController securityPinController = TextEditingController();
  Future exchangeMoneyConfirm(
      {required Map<String, dynamic> fields,
      bool? isFromHistoryPage = false,
      required BuildContext context}) async {
    isSubmit = true;
    update();
    http.Response response =
        await ExchangeRepo.exchangeMoneyConfirm(data: fields);
    isSubmit = false;
    update();
    var data = jsonDecode(response.body);
    if (response.statusCode == 200) {
      ApiStatus.checkStatus(data['status'], data['message']);
      if (data['status'] == 'success') {
        securityPinController.clear();
        amountController.clear();
        selectedFromWalletCurrencyId = "";
        ExchangeHistoryController.to.refreshSearchData();
        ExchangeHistoryController.to
            .resetDataAfterSearching(isFromOnRefreshIndicator: true);
        await ExchangeHistoryController.to.getExchangeMoneyList(
          page: 1,
          status: "",
          created_at: "",
          utr: "",
        );
        ExchangeHistoryController.to.update();
        Get.to(() => ExchangeMoneyHistoryScreen(isFromExchangeMoneyPage: true));
        update();
      }
    } else {
      Helpers.showSnackBar(msg: '${data['message']}');
    }
  }

  @override
  void onInit() {
    amountFocusNode.addListener(() {
      update();
    });
    WidgetsBinding.instance.addPostFrameCallback((v) {
      getexchangeMoney();
    });
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
