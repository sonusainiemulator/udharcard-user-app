import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:http/http.dart' as http;
import 'package:paysecure/utils/app_constants.dart';
import '../config/app_colors.dart';
import '../data/models/gateways_model.dart' as g;
import '../data/repositories/deposit_repo.dart';
import '../data/source/errors/check_api_status.dart';
import '../routes/page_index.dart';
import '../utils/services/helpers.dart';
import '../views/screens/deposit/card_payment/card_payment_screen.dart';
import '../views/screens/deposit/paynow_webview_screen.dart';
import '../views/widgets/app_payment_fail.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';

class DepositController extends GetxController {
  static DepositController get to => Get.find<DepositController>();

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  TextEditingController amountCtrl = TextEditingController();

  bool isUserIsFromMoneyTransferPage = true;
  Future getPaymentGateways() async {
    _isLoading = true;
    update();
    http.Response response = await DepositRepo.getGateways();
    _isLoading = false;
    update();

    if (response.statusCode == 200) {
      var data = jsonDecode(response.body);
      if (data['status'] == 'success') {
        await getPaymentGateway(data);
        listenRazorPay();
        update();
      } else {
        ApiStatus.checkStatus(data['status'], data['message']);
        update();
      }
    } else {
      Helpers.showSnackBar(msg: jsonDecode(response.body)['message']);
      update();
    }
  }

  @override
  void onInit() {
    super.onInit();
    getPaymentGateways();
  }

  bool isSearchTapped = false;

  int selectedGatewayIndex = -1;
  bool isLoadingDetails = false;
  TextEditingController gatewayEditingController = TextEditingController();

  //----GET PAYMENT GATEWAY DATA
  int selectedGatewayType = 0;
  Future getGatewayData(index) async {
    //---GATEWAY DATA
    g.Method data =
        isGatewaySearching
            ? searchedGatewayItem[index]
            : paymentGatewayList[index];
    gatewayName = data.name;
    // get the selected list and filter it
    var selectedGatewayElement =
        await paymentGatewayList.where((e) => e.name == data.name).toList();
    for (var i in selectedGatewayElement) {
      // check which type of gateway is selected
      // 1 = manual payement; 2 = other payment; 3 = card payment
      if (i.id! > 999) {
        selectedGatewayType = 1;
      } else if (i.code.toString().trim().toLowerCase() == "securionpay" ||
          i.code.toString().trim().toLowerCase() == "authorize.net") {
        selectedGatewayType = 3;
      } else {
        selectedGatewayType = 2;
      }
    }
  }

  bool isShopDetailsLoading = false;
  List<g.Method> paymentGatewayList = [];
  List<g.Currency> currencyList = [];
  List<ManualPaymentDynamicFormModel> manualPaymentElementList = [];

  bool is_crypto = false;
  Future getPaymentGateway(data) async {
    // if the payment gateways are from add fund and gateway field is null
    if (data['message']['methods'] is List) {
      paymentGatewayList = [];
      currencyList = [];

      paymentGatewayList.addAll(
        g.GatewayModel.fromJson(data).message!.methods!,
      );
      currencyList.addAll(g.GatewayModel.fromJson(data).message!.currencies!);

      getNeededGatewayKeys(data['message']['methods']);
      // filter manual payment list
      manualPaymentElementList = [];
      List allList = data['message']['methods'];
      var manualList = allList.where((e) => e['id'] > 999).toList();
      // filter the dynamic field data of manual payments
      Map<String, dynamic> fieldList = {};
      for (var i in manualList) {
        fieldList.addAll(i['parameters']);
        fieldList.forEach((key, value) {
          manualPaymentElementList.add(
            ManualPaymentDynamicFormModel(
              gatewayName: i['name'],
              note: i['note'] ?? "",
              fieldName: value['field_name'],
              fieldLevel: value['field_label'],
              type: value['type'],
              validation: value['validation'],
            ),
          );
        });
      }
      update();
    }
  }

  List<g.Method> searchedGatewayItem = [];
  bool isGatewaySearching = false;
  TextEditingController gatewaySearchCtrl = TextEditingController();
  queryPaymentGateway(String v) {
    searchedGatewayItem =
        paymentGatewayList
            .where(
              (e) => e.name.toString().toLowerCase().contains(v.toLowerCase()),
            )
            .toList();
    selectedGatewayIndex = -1;
    if (v.isEmpty) {
      isGatewaySearching = false;
      searchedGatewayItem.clear();
      update();
    } else if (v.isNotEmpty) {
      isGatewaySearching = true;
      update();
    }
    update();
  }

  int gatewayId = 0;
  String gatewayName = "";
  String gatewayCode = "";
  dynamic selectedCurrency = "USD";
  dynamic selectedCurrencyId = "0";
  dynamic selectedCryptoCurrency = null;
  String baseCurrency = "";
  List<g.ReceivableCurrency> receivableCurrencies = [];
  List<dynamic> supportedCurrencyList = [];
  bool isSelectedGatewayIsLive = false;

  Future getSelectedGatewayData(
    index, {
    bool? isFromMoneyTransferPage = true,
  }) async {
    var data =
        isGatewaySearching == true
            ? searchedGatewayItem[index]
            : paymentGatewayList[index];
    gatewayId = data.id;
    isSelectedGatewayIsLive =
        data.environment.toString() == "live" ? true : false;
    gatewayName = data.name;
    gatewayCode = data.code.toString().trim().toLowerCase();
    if (data.currencyType.toString() == "0") {
      is_crypto = true;
    }
    amountCtrl.clear();
    amountValue = "";

    // get the selected payment gateway's currency for getting the min, max, charge
    receivableCurrencies = [];
    if (data.receivableCurrencies != null) {
      receivableCurrencies = data.receivableCurrencies!;
    }
    // get the supported currencies for displaying in the payout page
    supportedCurrencyList = [];
    if (data.supportedCurrency != null) {
      supportedCurrencyList = data.supportedCurrency!;
      if (supportedCurrencyList.isNotEmpty) {
        // check the stripe gateway and fixed currency for SDK's payment
        if (gatewayCode.trim().toLowerCase() == "stripe") {
          selectedCurrency = "USD";
          supportedCurrencyList = ["USD"];
          await getSelectedCurrencyData(selectedCurrency);

          update();
        }
        // if the payment gateway is other and not stripe
        else {
          selectedCurrency = supportedCurrencyList[0].toString();
          await getSelectedCurrencyData(selectedCurrency);
        }
      } else {
        Helpers.showSnackBar(msg: "No supported currency found!");
      }
    }

    update();
  }

  bool isCurrencySupportedFromAdmin = false;
  Future getSelectedCurrencyData(value) async {
    try {
      // check which currencies are active from admin panel
      List<String> filteredCurrencyList = [];
      for (var i in currencyList) {
        filteredCurrencyList.add(i.code);
      }

      if (filteredCurrencyList.isNotEmpty &&
          filteredCurrencyList.contains(value)) {
        isCurrencySupportedFromAdmin = true;
        selectedCurrencyId =
            currencyList
                .firstWhere(
                  (e) => e.code == value,
                  orElse: () => g.Currency(id: "0"),
                )
                .id
                .toString();
      } else {
        isCurrencySupportedFromAdmin = false;
        Helpers.showSnackBar(msg: "This currency is unavailable for deposits");
      }
      await calculatePayableAmount();

      update();
    } catch (e, s) {
      print(s);
      Helpers.showSnackBar(msg: e.toString());
    }
  }

  // this value is for send amount of SDK's gateway
  String sendAmount = "0";

  String amountValue = "";
  bool isFollowedTransactionLimit = true;
  onChangedAmount(v) async {
    try {
      amountValue = v.toString();
      if (selectedCurrency != null) {
        await getChargeAndLimit(
          currency_id: selectedCurrencyId,
          transaction_type_id: '7',
          gateway_id: gatewayId.toString(),
        );
      }
      if (v.toString().isNotEmpty) {
        if ((double.parse(v.toString()) >= double.parse(minAmount)) &&
            (double.parse(v.toString()) <= double.parse(maxAmount))) {
          isFollowedTransactionLimit = true;

          await calculatePayableAmount();
        } else {
          isFollowedTransactionLimit = false;
          Helpers.showSnackBar(
            msg:
                "minimum payment ${double.parse(minAmount).toStringAsFixed(2)} and maximum payment limit ${double.parse(maxAmount).toStringAsFixed(2)}",
          );
        }
      }
      update();
    } catch (e, s) {
      print(s);
      Helpers.showSnackBar(msg: e.toString());
    }
  }

  // calculate total payable amount
  String totalChargedAmount = "0.00";
  String percentageCharge = "0.00";
  String totalPayableAmountInBaseCurrency = "0.00";
  calculatePayableAmount() {
    try {
      if (amountValue.isNotEmpty && selectedCurrency != null) {
        percentageCharge = ((double.parse(amountValue.toString()) *
                    double.parse(percentage.toString()).toInt() /
                    100) +
                double.parse(fixedCharge))
            .toStringAsFixed(2);
        totalChargedAmount = (double.parse(amountValue.toString()) +
                double.parse(percentageCharge))
            .toStringAsFixed(2);
        sendAmount = totalChargedAmount;
        totalPayableAmountInBaseCurrency = ((double.parse(
                  totalChargedAmount.toString(),
                )) *
                double.parse(conversion_rate))
            .toStringAsFixed(2);
        update();
      }
    } catch (e, s) {
      print(s);
      Helpers.showSnackBar(msg: e.toString());
    }
  }

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
  //------------check amount----
  // get the selected currency data
  String minAmount = "0.00";
  String maxAmount = "0.00";
  String fixedCharge = "0.00";
  String conversion_rate = "0.00";
  String percentage = "0";

  bool isGettingAmountCheck = false;
  Future getChargeAndLimit({
    required String currency_id,
    required String transaction_type_id,
    required String gateway_id,
  }) async {
    isGettingAmountCheck = true;
    update();
    http.Response response = await DepositRepo.getChargeAndLimit(
      currency_id: currency_id,
      transaction_type_id: transaction_type_id,
      gateway_id: gateway_id,
    );
    isGettingAmountCheck = false;
    update();
    var data = jsonDecode(response.body);
    if (response.statusCode == 200) {
      if (data['status'] == 'success') {
        if (data['message']['chargesLimit'] == null) {
          Helpers.showSnackBar(
            msg: "Payment method not available for this transaction",
          );
        } else {
          conversion_rate =
              data['message']['chargesLimit']['convention_rate'].toString();
          minAmount = data['message']['chargesLimit']['min_limit'].toString();
          maxAmount = data['message']['chargesLimit']['max_limit'].toString();
          percentage =
              data['message']['chargesLimit']['percentage_charge'].toString();
          fixedCharge =
              data['message']['chargesLimit']['fixed_charge'].toString();

          update();
        }
      } else {
        ApiStatus.checkStatus(data['status'], data['message']);
      }
    } else {
      Helpers.showSnackBar(msg: '${data['message']}');
    }
  }

  final formKey = GlobalKey<FormState>();

  //---------------------PAYMENT GATEWAY--------------------//

  // on buy now clicked
  List<ManualPaymentDynamicFormModel> selectedManualPaymentList = [];
  bool isLoadingPaymentSheet = false;
  onBuyNowTapped({required BuildContext context}) async {
    //----if the selected payment type is empty
    if (selectedGatewayType == 0) {
      Helpers.showSnackBar(msg: "Please select a Payment Gateway first.");
    }
    //----manual payment
    else if (selectedGatewayType == 1) {
      selectedManualPaymentList =
          await manualPaymentElementList
              .where((e) => e.gatewayName == gatewayName)
              .toList();
      Get.to(() => ManualPaymentScreen(title: gatewayName));
      isLoadingPaymentSheet = true;
      update();
      isLoadingPaymentSheet = false;
      update();
    }
    //-----other payment and sdk payment
    else if (selectedGatewayType == 2) {
      if (gatewayCode == "stripe") {
        isLoadingPaymentSheet = true;
        update();
        await stripeDepositRequest();
        isLoadingPaymentSheet = false;
        update();
      }
      //  else if (gatewayCode == "paypal") {
      //   makePaypalPaymentRequest();
      // }
      else if (gatewayCode == "razorpay") {
        isLoadingPaymentSheet = true;
        update();
        await razorPayPaymentRequest();
        isLoadingPaymentSheet = false;
        update();
      } else {
        isLoadingPaymentSheet = true;
        update();
        await webviewPayment(trxId: this.trxId);
        isLoadingPaymentSheet = false;
        update();
      }
    }
    //----card payment
    else if (selectedGatewayType == 3) {
      Get.to(() => CardPaymentScreen(gatewayCode: gatewayCode));
    }
    update();
  }

  //------MANUAL PAYMENT
  Color fileColorOfDField = AppColors.mainColor;
  Future manualPayment({
    required String trxId,
    required Map<String, String> fields,
    required Iterable<http.MultipartFile>? fileList,
  }) async {
    _isLoading = true;
    update();
    http.Response response = await DepositRepo.manualPayment(
      trxid: trxId,
      fields: fields,
      fileList: fileList,
    );
    _isLoading = false;
    update();
    var data = jsonDecode(response.body);
    if (response.statusCode == 200) {
      if (data['status'] == 'success') {
        Get.offAll(
          () => PaymentSuccessScreen(
            isFromDepositPage: true,
            amount: amountValue,
            currencySymbol: selectedCurrency,
            gateway: gatewayName,
          ),
        );
        update();
      } else {
        ApiStatus.checkStatus(data['status'], data['message']);
      }
    } else {
      Helpers.showSnackBar(msg: '${data['message']}');
    }
  }

  //------PAYMENT REQUEST DONE (this api will be called when add fund)
  var selectedWallet;
  String trxId = "";
  Future paymentRequest({
    required Map<String, dynamic> fields,
    required BuildContext context,
  }) async {
    isLoadingPaymentSheet = true;
    update();
    http.Response response = await DepositRepo.paymentRequest(fields: fields);
    isLoadingPaymentSheet = false;
    update();
    var data = jsonDecode(response.body);
    if (response.statusCode == 200) {
      if (data['status'] == 'success') {
        trxId = data['message'].toString();
        await onBuyNowTapped(context: context);
        update();
      } else {
        ApiStatus.checkStatus(data['status'], data['message']);
      }
      update();
    } else {
      Helpers.showSnackBar(msg: '${data['message']}');
    }
  }

  //  WEBVIEW PAYMENT
  Future webviewPayment({required String trxId}) async {
    _isLoading = true;
    update();
    http.Response response = await DepositRepo.webviewPayment(
      fields: {"trx_id": trxId},
    );
    _isLoading = false;
    update();

    if (response.statusCode == 200) {
      var data = jsonDecode(response.body);
      if (data['status'] == 'success') {
        if (data['message']['url'] != null) {
          Get.to(() => CheckoutWebView(url: data['message']['url']));
        }
        update();
      } else {
        ApiStatus.checkStatus(data['status'], data['message']);
        update();
      }
    } else {
      try {
        Helpers.showSnackBar(msg: jsonDecode(response.body)['message']);
      } catch (e) {
        Helpers.showSnackBar(msg: e.toString());
      }
      update();
    }
  }

  //------CARD PAYMENT
  Future cardPayment({required Map<String, String> fields}) async {
    _isLoading = true;
    update();
    http.Response response = await DepositRepo.cardPayment(fields: fields);
    _isLoading = false;
    update();
    var data = jsonDecode(response.body);
    if (response.statusCode == 200) {
      if (data['status'] == 'success') {
        // Get.offAll(() => PaymentSuccessScreen());
        update();
      } else {
        ApiStatus.checkStatus(data['status'], data['message']);
      }
      update();
    } else {
      Helpers.showSnackBar(msg: '${data['message']}');
    }
  }

  //------ON PAYMENT DONE
  Future onPaymentDone({required Map<String, String> fields}) async {
    isLoadingPaymentSheet = true;
    update();
    http.Response response = await DepositRepo.onPaymentDone(fields: fields);
    isLoadingPaymentSheet = false;
    update();
    var data = jsonDecode(response.body);
    if (response.statusCode == 200) {
      if (data['status'] == "success") {
        Get.offAll(
          () => PaymentSuccessScreen(
            isFromDepositPage: true,
            amount: amountValue,
            currencySymbol: selectedCurrency,
            gateway: gatewayName,
          ),
        );
      } else {
        ApiStatus.checkStatus(data['status'], data['message']);
        Get.offAll(() => BottomNavBar());
      }
    } else {
      Helpers.showSnackBar(msg: '${data['message']}');
    }
  }

  ///-------------------------All key of Payment Gateway--------------------
  getNeededGatewayKeys(List<dynamic> allList) {
    for (var i in allList) {
      // IF THE PARAMETERS FIELD IS EXIST
      if (i['parameters'] != null) {
        if (i['code'].toString().trim().toLowerCase() == 'stripe') {
          secretKeyStripe = i['parameters']['secret_key'];
          publishableKeyStripe = i['parameters']['publishable_key'];
        } else if (i['code'].toString().trim().toLowerCase() == 'razorpay') {
          razorPayKey = i['parameters']['key_id'];
        } else if (i['code'].toString().trim().toLowerCase() == 'paypal') {
          paypalClientId = i['parameters']['cleint_id'];
          paypalSecretKey = i['parameters']['secret'];
        }
      }
    }
  }

  // STRIPE
  String secretKeyStripe = "";
  String publishableKeyStripe = "";
  // RAZORPAY
  String razorPayKey = "";
  // PAYPAL
  String paypalClientId = "";
  String paypalSecretKey = "";

  ///-------------------------Stripe Payment Integration
  dynamic stripePaymentData;
  var stripe = Stripe.instance;

  Future<void> stripeDepositRequest() async {
    try {
      stripePaymentData = await stripePaymentCreate(
        calculateAmount(sendAmount),
        "USD",
      );
      await stripe.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
          returnURL:
              isSelectedGatewayIsLive
                  ? "${AppConstants.baseUrl.split("/api").first}/success"
                  : null,
          paymentIntentClientSecret: stripePaymentData['client_secret'],
          style: Get.isDarkMode ? ThemeMode.dark : ThemeMode.light,
          merchantDisplayName: '${AppConstants.appName}',
        ),
      );

      displayPaymentSheet();
    } catch (e, s) {
      Helpers.showSnackBar(msg: e.toString());
      if (kDebugMode) {
        print('Payment exception: $e$s');
      }
    }
  }

  Future displayPaymentSheet() async {
    try {
      await stripe
          .presentPaymentSheet()
          .then((newValue) async {
            onPaymentDone(fields: {"utr": this.trxId});
            stripePaymentData = null;
          })
          .onError((error, stackTrace) async {
            if (kDebugMode) {
              print(
                'OnErrorException/DISPLAYPAYMENTSHEET==> $error $stackTrace',
              );
            }
            _isLoading = false;
            Get.dialog(
              AlertDialog(
                content: Container(
                  height: 60.h,
                  child: Center(
                    child: Text(
                      "Payment Cancelled!",
                      style: TextStyle(color: AppColors.redColor),
                    ),
                  ),
                ),
              ),
            );
            update();
          });
    } on StripeException catch (e) {
      Helpers.showSnackBar(msg: e.toString());
      if (kDebugMode) {
        print('StripeException/DISPLAYPAYMENTSHEET==> $e');
      }
      await Future.delayed(Duration(seconds: 3));
      Get.back();
    } catch (e) {
      Helpers.showSnackBar(msg: e.toString());
      if (kDebugMode) {
        print('$e');
      }
    }
  }

  stripePaymentCreate(String amount, String currency) async {
    try {
      Map<String, dynamic> body = {'amount': amount, 'currency': currency};
      var response = await http.post(
        Uri.parse('https://api.stripe.com/v1/payment_intents'),
        body: body,
        headers: {
          'Authorization': 'Bearer ' + "${secretKeyStripe}",
          'Content-Type': 'application/x-www-form-urlencoded',
        },
      );
      return jsonDecode(response.body);
    } catch (err) {
      Helpers.showSnackBar(msg: err.toString());
      if (kDebugMode) {
        print('err charging user: ${err.toString()}');
      }
      return {};
    }
  }

  // calculate Amount
  calculateAmount(String amount) {
    final doubVal = double.parse(amount);
    final calculatedAmount = (doubVal.toInt() * 100);
    return calculatedAmount.toString();
  }

  ///----------------------Razor Payment Integration
  Razorpay? razorpay;

  listenRazorPay() {
    razorpay =
        Razorpay()
          ..on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess)
          ..on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError)
          ..on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) async {
    onPaymentDone(fields: {"utr": this.trxId});
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    print(response.message);
    print(response.error);
    // Handle payment failure
    Get.dialog(AppPaymentFail(errorText: response.message!));
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    // Handle external wallet payment
  }

  Future razorPayPaymentRequest() async {
    final options = {
      // Replace with your actual Razorpay key
      'key': razorPayKey,
      'amount': calculateAmount(sendAmount),
      'name': 'Test',
      'description': 'Test Payment',
      'prefill': {'contact': '1234567890', 'email': 'test@gmail.com'},
      'external': {
        'wallets': ['paytm'],
      },
      'currency': '$selectedCurrency',
    };

    try {
      razorpay!.open(options);
    } catch (e) {
      Helpers.showSnackBar(msg: e.toString());
    }
  }
}

// create a model class for dynamic form list of manual payment gateway
class ManualPaymentDynamicFormModel {
  String note;
  String gatewayName;
  String fieldName;
  String fieldLevel;
  String type;
  String validation;
  ManualPaymentDynamicFormModel({
    required this.note,
    required this.gatewayName,
    required this.fieldName,
    required this.fieldLevel,
    required this.type,
    required this.validation,
  });
}
