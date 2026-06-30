import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:paysecure/controllers/bindings/controller_index.dart';
import 'package:paysecure/views/screens/escrow/escrow_preview_screen.dart';
import '../data/models/amount_check_model.dart';
import '../data/models/getRedeem_code_model.dart' as getRedeemCode;
import '../data/models/escrow_preview_model.dart' as esPrev;
import '../data/repositories/escrow_repo.dart';
import '../data/repositories/redeem_code_repo.dart';
import '../data/source/errors/check_api_status.dart';
import '../utils/services/helpers.dart';
import '../views/screens/escrow/escrow_history_screen.dart';

class EscrowController extends GetxController {
  static EscrowController get to => Get.find<EscrowController>();

  bool isLoading = false;

  TextEditingController recipientEmailController = TextEditingController();
  TextEditingController amountController = TextEditingController();
  TextEditingController noteController = TextEditingController();
  String amountVal = "";

  List<getRedeemCode.Currency> currencyList = [];
  List<CustomCurrencyModel> customCurrencyList = [];
  String description = "";
  dynamic selectedCurrency = null;
  String selectedCurrencyId = "0";
  //------------------Escrow screen----
  Future getEscrow() async {
    isLoading = true;
    update();
    http.Response response = await EscrowRepo.getEscrow();
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
  bool isClickedAcceptBtn = false;
  bool isClickedCancelBtn = false;
  Future submitEscrow({required Map<String, dynamic> fields}) async {
    isSubmit = true;
    update();
    http.Response response = await EscrowRepo.escrowSubmit(data: fields);
    isSubmit = false;
    update();
    var data = jsonDecode(response.body);
    if (response.statusCode == 200) {
      if (data['status'] == 'success') {
        if (data['message']['utr'] != null &&
            data['message']['utr'].toString().isNotEmpty) {
          escrowPreview(utr: data['message']['utr'].toString());
          Get.to(() => EscrowPreviewScreen(
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

  Future escrowPaymentSubmit(
      {required Map<String, dynamic> fields,
      required BuildContext context}) async {
    isSubmit = true;
    update();
    http.Response response = await EscrowRepo.escrowPaymentSubmit(data: fields);
    isSubmit = false;
    update();
    var data = jsonDecode(response.body);
    if (response.statusCode == 200) {
      ApiStatus.checkStatus(data['status'], data['message']);
      if (data['status'] == 'success') {
        EscrowHistoryController.to.refreshSearchData();
        EscrowHistoryController.to.resetDataAfterSearching();
        await EscrowHistoryController.to.getEscrowList(
            page: 1, email: "", utr: "", created_at: "", status: "");
        EscrowHistoryController.to.update();
        Navigator.pop(context);
        update();
      }
    } else {
      Helpers.showSnackBar(msg: '${data['message']}');
    }
  }

  //---------confirm escrow screen--
  List<esPrev.Message> escrowPreviewList = [];
  Future escrowPreview({required String utr}) async {
    isLoading = true;
    update();
    http.Response response = await EscrowRepo.escrowPreview(utr: utr);
    escrowPreviewList.clear();
    isLoading = false;
    update();
    var data = jsonDecode(response.body);
    if (response.statusCode == 200) {
      if (data['status'] == 'success') {
        escrowPreviewList
            .add(esPrev.EscrowPreviewModel.fromJson(data).message!);
      } else {
        ApiStatus.checkStatus(data['status'], data['message']);
      }
    } else {
      Helpers.showSnackBar(msg: '${data['message']}');
    }
  }

  TextEditingController securityPinController = TextEditingController();
  Future escrowConfirm(
      {required Map<String, dynamic> fields,
      bool? isFromHistoryPage = false,
      BuildContext? context}) async {
    isSubmit = true;
    update();
    http.Response response = await EscrowRepo.escrowConfirm(data: fields);
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
        recipientEmailController.clear();
        EscrowHistoryController.to.refreshSearchData();
        EscrowHistoryController.to.resetDataAfterSearching();
        await EscrowHistoryController.to.getEscrowList(
            page: 1, email: "", utr: "", created_at: "", status: "");
        EscrowHistoryController.to.update();
        Get.to(() => EscrowHistoryScreen(isFromEscrowPage: true));
        update();
      }
    } else {
      Helpers.showSnackBar(msg: '${data['message']}');
    }
  }

  @override
  void onInit() {
    getEscrow();
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
