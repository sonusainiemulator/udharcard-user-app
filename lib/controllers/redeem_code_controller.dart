import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:paysecure/views/screens/redeem/redeem_history_screen.dart';
import '../data/models/amount_check_model.dart';
import '../data/models/getRedeem_code_model.dart' as getRedeemCode;
import '../data/models/redeem_code_preview_model.dart' as genCodePrev;
import '../data/repositories/redeem_code_repo.dart';
import '../data/source/errors/check_api_status.dart';
import '../utils/services/helpers.dart';
import '../views/screens/redeem/redeem_preview_screen.dart';
import 'redeem_history_controller.dart';

class RedeemCodeController extends GetxController {
  static RedeemCodeController get to => Get.find<RedeemCodeController>();

  bool isLoading = false;

  TextEditingController amountController = TextEditingController();
  TextEditingController noteController = TextEditingController();
  String amountVal = "";

  List<getRedeemCode.Currency> currencyList = [];
  List<CustomCurrencyModel> customCurrencyList = [];
  String description = "";
  dynamic selectedCurrency = null;
  String selectedCurrencyId = "0";
  bool isChargeFrom = false;
  //------------------redeem screen----
  Future getGenerateCode() async {
    isLoading = true;
    update();
    http.Response response = await RedeemCodeRepo.getGenerateCode();
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
  Future generateCodeSubmit({required Map<String, dynamic> fields}) async {
    isSubmit = true;
    update();
    http.Response response =
        await RedeemCodeRepo.generateCodeSubmit(data: fields);
    isSubmit = false;
    update();
    var data = jsonDecode(response.body);
    if (response.statusCode == 200) {
      if (data['status'] == 'success') {
        if (data['message']['utr'] != null &&
            data['message']['utr'].toString().isNotEmpty) {
          generateCodePreview(utr: data['message']['utr'].toString());
          Get.to(() => RedeemPreviewScreen(
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

  //---------confirm redeem screen--
  List<genCodePrev.Message> generatedCodePreviewList = [];
  Future generateCodePreview({required String utr}) async {
    isLoading = true;
    update();
    http.Response response = await RedeemCodeRepo.generateCodePreview(utr: utr);
    generatedCodePreviewList.clear();
    isLoading = false;
    update();
    var data = jsonDecode(response.body);
    if (response.statusCode == 200) {
      if (data['status'] == 'success') {
        generatedCodePreviewList
            .add(genCodePrev.RedeemPreviewModel.fromJson(data).message!);
      } else {
        ApiStatus.checkStatus(data['status'], data['message']);
      }
    } else {
      Helpers.showSnackBar(msg: '${data['message']}');
    }
  }

  TextEditingController securityPinController = TextEditingController();
  Future generateCodeConfirm(
      {required Map<String, dynamic> fields,
      bool? isFromHistoryPage = false,
      BuildContext? context}) async {
    isSubmit = true;
    update();
    http.Response response =
        await RedeemCodeRepo.generateCodeConfirm(data: fields);
    isSubmit = false;
    update();
    var data = jsonDecode(response.body);
    if (response.statusCode == 200) {
      ApiStatus.checkStatus(data['status'], data['message']);
      if (data['status'] == 'success') {
        securityPinController.clear();
        amountController.clear();
        amountCheckList.clear();
        selectedCurrencyId = "";
        selectedCurrency = null;
        isChargeFrom == false;
        noteController.clear();
        RedeemHistoryController.to
            .resetDataAfterSearching(isFromOnRefreshIndicator: true);
        await RedeemHistoryController.to.getRedeemList(
          page: 1,
          status: "",
          created_at: "",
          utr: "",
          email: "",
        );
        RedeemHistoryController.to.update();
        Get.to(() => RedeemHistoryScreen(isFromRedeemPage: true));
        update();
      }
    } else {
      Helpers.showSnackBar(msg: '${data['message']}');
    }
  }

  //---------insert redeem code--
  TextEditingController insertRedeemCodeController = TextEditingController();
  Future insertRedeemCode({required Map<String, dynamic> fields}) async {
    isSubmit = true;
    update();
    http.Response response =
        await RedeemCodeRepo.insertRedeemCode(data: fields);
    isSubmit = false;
    update();
    var data = jsonDecode(response.body);
    if (response.statusCode == 200) {
      insertRedeemCodeController.clear();
      ApiStatus.checkStatus(data['status'], data['message']);
      if (data['status'] == 'success') {
        update();
      }
    } else {
      Helpers.showSnackBar(msg: '${data['message']}');
    }
  }

  @override
  void onInit() {
    getGenerateCode();
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
