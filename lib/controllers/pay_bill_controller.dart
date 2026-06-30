import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:paysecure/views/screens/pay_bill/pay_bill_preview_screen.dart';
import '../data/models/pay_bill_model.dart' as payBill;
import '../data/models/pay_bill_preview_model.dart';
import '../data/repositories/pay_bill_repo.dart';
import '../data/source/errors/check_api_status.dart';
import '../routes/routes_name.dart';
import '../utils/services/helpers.dart';
import 'redeem_code_controller.dart';

class PayBillController extends GetxController {
  static PayBillController get to => Get.find<PayBillController>();

  bool isLoading = false;

  TextEditingController amountController = TextEditingController();

  // category
  int selectedIndex = 0;
  String selectedCategoryVal = "";
  ScrollController scrollController = ScrollController();
  onCategoryTapped(index, context) {
    selectedIndex = index;
    selectedCategoryVal = categoryList[index].value.toString().toLowerCase();
    if (selectedCategoryVal.isNotEmpty) {
      checkServiceList();
    }

    update();
  }

  List<payBill.Category> categoryList = [];

  // currency
  List<payBill.Currency> currencyList = [];
  List<CustomCurrencyModel> customCurrencyList = [];
  dynamic selectedCurrency = null;
  String selectedCurrencyId = "0";

  // for displaying data
  double fixedCharge = 0.00;
  double percentCharge = 0.00;
  dynamic minAmount = 0;
  dynamic maxAmount = 0;
  String currency = "";

  // dynamic form
  List<String> labelName = [];
  String type = "";
  String validation = "";

  Color fileColorOfDField = Colors.transparent;

  // country
  Map<String, dynamic> countryMap = {};
  dynamic selectedCountryVal = null;
  dynamic selectedCountryKey = "";
  onCountryChange(V) {
    selectedCountryVal = V;
    countryMap.entries.forEach((e) {
      if (e.value == V) {
        selectedCountryKey = e.key;
      }
    });
    checkServiceList();
    update();
  }

  // check service list and filter it
  checkServiceList() {
    selectedService = null;
    if (selectedCountryKey.toString().isNotEmpty) {
      filteredBillServiceList = billServiceList
          .where(
            (e) =>
                e.country == selectedCountryKey.toString() &&
                e.service.toString().toLowerCase() == selectedCategoryVal,
          )
          .toList();
    }
    update();
  }

  // service
  String serviceId = "";
  dynamic selectedService = null;
  List<payBill.BillService> billServiceList = [];
  List<payBill.BillService> filteredBillServiceList = [];
  Map<String, TextEditingController> labelControllerMap = {};
  List<AmountDescription> filteredAmountDescriptionList = [];
  onServiceChange(V) {
    try {
      labelControllerMap.clear();

      selectedService = V;
      print(selectedService);

      if (selectedCountryKey.toString().isNotEmpty) {
        var filteredList = filteredBillServiceList.firstWhere(
          (e) => e.type == V,
        );
        filteredAmountDescriptionList = amountDescriptionList
            .where((e) => e.type == selectedService)
            .toList();
        serviceId = filteredList.id.toString();
        labelName = filteredList.labelName ?? [];
        if (filteredList.labelName != null &&
            filteredList.labelName!.isNotEmpty) {
          for (var i in filteredList.labelName!) {
            labelControllerMap[i] = TextEditingController();
          }
        }
        fixedCharge = double.parse(filteredList.fixedCharge.toString());
        percentCharge = double.parse(filteredList.percentCharge.toString());
        minAmount = filteredList.minAmount;
        maxAmount = filteredList.maxAmount;
        currency = filteredList.currency;
      }
    } catch (e, s) {
      print(s);
      Helpers.showSnackBar(msg: e.toString());
    }

    update();
  }

  var selectedAmountVAl;
  var selectedAmountKey;
  onAmountChanged(v) {
    selectedAmountVAl = v;
    selectedAmountKey =
        filteredAmountDescriptionList.firstWhere((e) => e.value == v).key;
    update();
  }

  List<AmountDescription> amountDescriptionList = [];
  Future getPayBill() async {
    isLoading = true;
    update();
    http.Response response = await PayBillRepo.getPayBill();
    categoryList.clear();
    currencyList.clear();
    customCurrencyList.clear();
    amountDescriptionList.clear();
    billServiceList.clear();
    countryMap.clear();
    isLoading = false;
    update();
    var data = jsonDecode(response.body);
    if (response.statusCode == 200) {
      if (data['status'] == 'success') {
        try {
          // get amount descriptions
          if (data['message']['billMethod']['bill_services'] != null)
            for (var i in data['message']['billMethod']['bill_services']) {
              var service = i['type'];

              if (i['info'] != null &&
                  i['info']['fixedAmountsDescriptions'] != null &&
                  i['info']['fixedAmountsDescriptions'] is Map) {
                Map map = i['info']['fixedAmountsDescriptions'];
                for (var j in map.entries) {
                  amountDescriptionList.add(
                    AmountDescription(
                      type: service,
                      key: j.key,
                      value: j.value,
                    ),
                  );
                }
              } else if (i['info'] != null &&
                  i['info']['localFixedAmountsDescriptions'] != null &&
                  i['info']['localFixedAmountsDescriptions'] is Map) {
                Map map = i['info']['localFixedAmountsDescriptions'];
                for (var j in map.entries) {
                  amountDescriptionList.add(
                    AmountDescription(
                      type: service,
                      key: j.key,
                      value: j.value,
                    ),
                  );
                }
              }
            }
          // get category list
          categoryList.addAll(
            payBill.PayBillModel.fromJson(data).message!.categories!,
          );

          // category
          if (categoryList.isNotEmpty) {
            selectedCategoryVal = categoryList[0].value;
          }
          // get currency list
          currencyList.addAll(
            payBill.PayBillModel.fromJson(data).message!.currencies!,
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
          // get country
          if (data['message']['countries'] != null &&
              data['message']['countries'] is Map) {
            Map countries = data['message']['countries'];
            for (var i in countries.entries) {
              countryMap[i.key] = i.value['name'];
            }
          }

          // get services
          if (data['message']['billMethod'] != null) {
            billServiceList.addAll(
              payBill.PayBillModel.fromJson(
                data,
              ).message!.billMethod!.billServices!,
            );
          }
        } catch (e, s) {
          print(s);
          Helpers.showSnackBar(msg: e.toString());
        }
      } else {
        ApiStatus.checkStatus(data['status'], data['message']);
      }
    } else {
      Helpers.showSnackBar(msg: '${data['message']}');
    }
  }

  refreshPayBillData() {
    selectedCurrency = null;
    selectedCurrencyId = "0";
    selectedCountryVal = null;
    selectedCountryKey = "";
    selectedService = null;
    serviceId = "";
    amountController.clear();
    update();
  }

  // submit pay bill
  bool isSubmit = false;
  Future submitPayBill({required Map<String, dynamic> fields}) async {
    isSubmit = true;
    update();
    http.Response response = await PayBillRepo.submitPayBill(fields: fields);
    isSubmit = false;
    update();
    var data = jsonDecode(response.body);
    if (response.statusCode == 200) {
      if (data['status'] == 'success') {
        Get.to(PayBillPreviewScreen(utr: data['message']['utr'].toString()));
        await getPayBillPreview(utr: data['message']['utr'].toString());
        update();
      } else {
        ApiStatus.checkStatus(data['status'], data['message']);
      }
    } else {
      Helpers.showSnackBar(msg: '${data['message']}');
    }
  }

  bool isGettingPrev = false;
  List<PayBillPreviewModel> payBillPrevList = [];
  Future getPayBillPreview({required String utr}) async {
    isGettingPrev = true;
    update();
    http.Response response = await PayBillRepo.getPayBillPreview(utr: utr);
    isGettingPrev = false;
    payBillPrevList.clear();
    update();
    var data = jsonDecode(response.body);
    if (response.statusCode == 200) {
      if (data['status'] == 'success') {
        payBillPrevList.add(PayBillPreviewModel.fromJson(data));
        update();
      } else {
        ApiStatus.checkStatus(data['status'], data['message']);
      }
    } else {
      Helpers.showSnackBar(msg: '${data['message']}');
    }
  }

  // pay bill preview submit
  TextEditingController securityPinController = TextEditingController();
  Future payBillPreviewSubmit({required Map<String, dynamic> fields}) async {
    isSubmit = true;
    update();
    http.Response response = await PayBillRepo.payBillPreviewSubmit(
      fields: fields,
    );
    isSubmit = false;
    update();
    var data = jsonDecode(response.body);
    if (response.statusCode == 200) {
      if (data['status'] == 'success') {
        Get.offAllNamed(RoutesName.bottomNavBar);
        update();
      } else {
        securityPinController.clear();
        ApiStatus.checkStatus(data['status'], data['message']);
      }
    } else {
      Helpers.showSnackBar(msg: '${data['message']}');
    }
  }

  // filter dynamic form
  final formKey = GlobalKey<FormState>();
  dynamic pickedFile = "";
  Future<void> pickFile() async {
    try {
      final picker = ImagePicker()..pickImage(source: ImageSource.camera);
      final pickedImageFile = await picker.pickImage(
        source: ImageSource.camera,
      );

      if (pickedImageFile != null) {
        pickedFile = pickedImageFile.path;

        update();
      }
    } catch (e) {
      if (kDebugMode) {
        print("Error while picking files: $e");
      }
    }
  }

  @override
  void onInit() {
    getPayBill();
    super.onInit();
  }
}

class AmountDescription {
  String type;
  String key;
  String value;
  AmountDescription({
    required this.type,
    required this.key,
    required this.value,
  });
}
