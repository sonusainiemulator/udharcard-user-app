import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:paysecure/controllers/voucher_history_controller.dart';
import 'package:paysecure/data/repositories/voucher_repo.dart';
import 'package:paysecure/routes/page_index.dart';
import '../data/models/amount_check_model.dart';
import '../data/models/getRedeem_code_model.dart' as getRedeemCode;
import '../data/models/voucher_preview_model.dart' as vPrev;
import '../data/repositories/redeem_code_repo.dart';
import '../data/source/errors/check_api_status.dart';
import '../utils/services/helpers.dart';

class VoucherController extends GetxController {
  static VoucherController get to => Get.find<VoucherController>();

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
  //------------------Voucher screen----
  Future getVoucher() async {
    isLoading = true;
    update();
    http.Response response = await VoucherRepo.getVoucher();
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
  Future voucherSubmit({required Map<String, dynamic> fields}) async {
    isSubmit = true;
    update();
    http.Response response = await VoucherRepo.voucherSubmit(data: fields);
    isSubmit = false;
    update();
    var data = jsonDecode(response.body);
    if (response.statusCode == 200) {
      if (data['status'] == 'success') {
        if (data['message']['utr'] != null &&
            data['message']['utr'].toString().isNotEmpty) {
          voucherPreview(utr: data['message']['utr'].toString());
          Get.to(() => VoucherPreviewScreen(
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

  //---------confirm voucher screen--
  List<vPrev.Message> voucherPreviewList = [];
  Future voucherPreview({required String utr}) async {
    isLoading = true;
    update();
    http.Response response = await VoucherRepo.voucherPreview(utr: utr);
    voucherPreviewList.clear();
    isLoading = false;
    update();
    var data = jsonDecode(response.body);
    if (response.statusCode == 200) {
      if (data['status'] == 'success') {
        voucherPreviewList
            .add(vPrev.VoucherPreviewModel.fromJson(data).message!);
      } else {
        ApiStatus.checkStatus(data['status'], data['message']);
      }
    } else {
      Helpers.showSnackBar(msg: '${data['message']}');
    }
  }

  TextEditingController securityPinController = TextEditingController();
  Future voucherPreviewSubmit(
      {required Map<String, dynamic> fields,
      bool? isFromHistoryPage = false,
      required BuildContext context}) async {
    isSubmit = true;
    update();
    http.Response response =
        await VoucherRepo.voucherPreviewSubmit(data: fields);
    isSubmit = false;
    update();
    var data = jsonDecode(response.body);
    if (response.statusCode == 200) {
      ApiStatus.checkStatus(data['status'], data['message']);
      if (data['status'] == 'success') {
        securityPinController.clear();
        amountController.clear();
        selectedCurrencyId = "";
        selectedCurrency = null;
        amountCheckList.clear();
        recipientEmailController.clear();
        VoucherHistoryController.to.resetDataAfterSearching();
        VoucherHistoryController.to.getVoucherList(
          page: 1,
          email: "",
          status: "",
          created_at: "",
          utr: "",
        );

        VoucherHistoryController.to.update();
        Get.to(() => VoucherHistoryScreen(isFromVoucherPage: true));

        update();
      }
    } else {
      Helpers.showSnackBar(msg: '${data['message']}');
    }
  }

  bool isClickedAcceptBtn = false;
  bool isClickedCancelBtn = false;
  Future voucherPaymentSubmit(
      {required Map<String, dynamic> fields,
      bool? isFromHistoryPage = false,
      required BuildContext context}) async {
    isSubmit = true;
    update();
    http.Response response =
        await VoucherRepo.voucherPaymentSubmit(data: fields);
    isSubmit = false;
    update();
    var data = jsonDecode(response.body);
    if (response.statusCode == 200) {
      ApiStatus.checkStatus(data['status'], data['message']);
      if (data['status'] == 'success') {
        VoucherHistoryController.to.resetDataAfterSearching();
        VoucherHistoryController.to.getVoucherList(
          page: 1,
          email: "",
          status: "",
          created_at: "",
          utr: "",
        );
        Navigator.pop(context);

        update();
      }
    } else {
      Helpers.showSnackBar(msg: '${data['message']}');
    }
  }

  @override
  void onInit() {
    getVoucher();
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
