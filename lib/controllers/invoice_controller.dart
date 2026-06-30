import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:paysecure/data/repositories/invoice_repo.dart';
import '../data/models/getRedeem_code_model.dart' as getRedeemCode;
import '../data/source/errors/check_api_status.dart';
import '../utils/services/helpers.dart';
import '../views/screens/invoice/invoice_history_screen.dart';

class InvoiceController extends GetxController {
  static InvoiceController get to => Get.find<InvoiceController>();

  bool isLoading = false;

  TextEditingController customerEmailCtrlr = TextEditingController();
  TextEditingController invoiceCtrlr = TextEditingController();
  TextEditingController noteCtrlr = TextEditingController();
  TextEditingController dueDateCtrlr = TextEditingController();
  TextEditingController numOfPaymentCtrlr = TextEditingController();
  TextEditingController firstPayDateCtrlr = TextEditingController();

  //----add service
  TextEditingController titleCtrlr = TextEditingController();
  TextEditingController priceCtrlr = TextEditingController();
  TextEditingController quantityCtrlr = TextEditingController();
  TextEditingController descriptionCtrlr = TextEditingController();

  String titleVal = "";
  String priceVal = "";
  String quantityVal = "";
  String descriptionVal = "";

  TextEditingController taxCtrlr = TextEditingController();
  TextEditingController vatCtrlr = TextEditingController();

  // textfield border color
  bool isCustomerEmailError = false;
  bool isInvoiceNumError = false;
  bool isCurrencyError = false;
  bool isDueDateError = false;
  bool isNumOfPayError = false;
  bool isFirstPayDateError = false;
  bool isEmptyServiceAndTappedOnSaveButton = false;

  List<getRedeemCode.Currency> currencyList = [];
  List<CustomCurrencyModel> customCurrencyList = [];
  String description = "";
  dynamic selectedCurrency = null;
  String selectedCurrencyId = "0";
  int groupVal = 1;
  //------------------invoice screen----
  Future getInvoiceCreate() async {
    isLoading = true;
    update();
    http.Response response = await InvoiceRepo.getInvoiceCreate();
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

  bool isSubmit = false;
  List<ServiceModel> serviceList = [];
  Future invoiceStore({required Map<String, dynamic> fields}) async {
    isSubmit = true;
    update();
    http.Response response = await InvoiceRepo.invoiceStore(data: fields);
    isSubmit = false;
    update();
    var data = jsonDecode(response.body);
    if (response.statusCode == 200) {
      ApiStatus.checkStatus(data['status'], data['message']);
      if (data['status'] == 'success') {
       Get.to(()=> InvoiceHistoryScreen(isFromInvoicePage: true));
      }
    } else {
      Helpers.showSnackBar(msg: '${data['message']}');
    }
  }

  Future onInvoiceSubmit() async {
    try {
      if (customerEmailCtrlr.text.isEmpty) {
        isCustomerEmailError = true;
        update();
        Helpers.showSnackBar(msg: "The customer email field is required.");
      } else if (invoiceCtrlr.text.isEmpty) {
        isInvoiceNumError = true;
        update();
        Helpers.showSnackBar(msg: "The invoice number field is required.");
      } else if (selectedCurrencyId == "0") {
        isCurrencyError = true;
        update();
        Helpers.showSnackBar(msg: "Please select your currency.");
      } else if (groupVal == 1 && dueDateCtrlr.text.isEmpty) {
        isDueDateError = true;
        update();
        Helpers.showSnackBar(
            msg: "The due date field is required when payment is ${groupVal}.");
      } else if (groupVal == 2 || groupVal == 3) {
        if (numOfPaymentCtrlr.text.isEmpty) {
          isNumOfPayError = true;
          update();
          Helpers.showSnackBar(
              msg:
                  "The due date field is required when payment is ${groupVal}.");
        } else if (firstPayDateCtrlr.text.isEmpty) {
          isFirstPayDateError = true;
          update();
          Helpers.showSnackBar(
              msg:
                  "The first pay date field is required when payment is ${groupVal}.");
        } else {
          if (serviceList.isEmpty) {
            isEmptyServiceAndTappedOnSaveButton = true;

            update();
            Helpers.showSnackBar(msg: "The services are required.");
          } else {
            List<Map<String, dynamic>> items =
                serviceList.map((service) => service.toJson()).toList();
            Map<String, dynamic> body = {
              "invoice_number": invoiceCtrlr.text,
              "customer_email": customerEmailCtrlr.text,
              if (groupVal == 1) "due_date": dueDateCtrlr.text,
              if (groupVal == 2 || groupVal == 3)
                "first_pay_date": firstPayDateCtrlr.text,
              if (groupVal == 2 || groupVal == 3)
                "num_payment": numOfPaymentCtrlr.text,
              "button_name": "send",
              "payment": "${groupVal}",
              "items": items,
              "subtotal": subTotal,
              "tax": taxCtrlr.text,
              "vat": vatCtrlr.text,
              "taxRate": taxRate,
              "vatRate": vatRate,
              "garndtotal": grandTotal,
              "currency": selectedCurrencyId,
              "note": noteCtrlr.text,
            };
            await invoiceStore(fields: body);
          }
        }
      } else if (serviceList.isEmpty) {
        isEmptyServiceAndTappedOnSaveButton = true;

        update();
        Helpers.showSnackBar(msg: "The services are required.");
      } else {
        List<Map<String, dynamic>> items =
            serviceList.map((service) => service.toJson()).toList();
        Map<String, dynamic> body = {
          "invoice_number": invoiceCtrlr.text,
          "customer_email": customerEmailCtrlr.text,
          if (groupVal == 1) "due_date": dueDateCtrlr.text,
          if (groupVal == 2 || groupVal == 3)
            "first_pay_date": firstPayDateCtrlr.text,
          if (groupVal == 2 || groupVal == 3)
            "num_payment": numOfPaymentCtrlr.text,
          "button_name": "send",
          "payment": "${groupVal}",
          "items": items,
          "subtotal": subTotal,
          "tax": taxCtrlr.text,
          "vat": vatCtrlr.text,
          "taxRate": taxRate,
          "vatRate": vatRate,
          "garndtotal": grandTotal,
          "currency": selectedCurrencyId,
          "note": noteCtrlr.text,
        };

        await invoiceStore(fields: body);
      }
    } catch (e) {
      Helpers.showSnackBar(msg: e.toString());
    }
  }

  Future onAddService(int i, isFromEdit) async {
    if (titleCtrlr.text.isEmpty) {
      Helpers.showSnackBar(msg: "The title field is required.");
    } else if (priceCtrlr.text.isEmpty) {
      Helpers.showSnackBar(msg: "The price field is required.");
    } else if (quantityCtrlr.text.isEmpty) {
      Helpers.showSnackBar(msg: "The quantity field is required.");
    } else if (titleVal.isNotEmpty &&
        priceVal.isNotEmpty &&
        quantityVal.isNotEmpty) {
      if (isFromEdit == false) {
        serviceList.insert(
            0,
            ServiceModel(
                title: titleVal,
                quantity: quantityVal,
                price: priceVal,
                description: descriptionVal));
      } else {
        serviceList[i].title = titleCtrlr.text;
        serviceList[i].quantity = quantityCtrlr.text;
        serviceList[i].price = priceCtrlr.text;
        serviceList[i].description = descriptionCtrlr.text;
        update();
      }
      await getSubTotal();
      if (taxCtrlr.text.isNotEmpty) {
        await getTaxRate(taxCtrlr.text);
      }
      if (vatCtrlr.text.isNotEmpty) {
        await getVatRate(vatCtrlr.text);
      }
      update();
      Get.back();
    }
  }

  onServiceDeleteTapped(i) {
    try {
      serviceList.removeAt(i);
      if (serviceList.isEmpty) {
        taxCtrlr.clear();
        vatCtrlr.clear();
        taxRate = "0.00";
        vatRate = "0.00";
        update();
      }
      if (taxCtrlr.text.isNotEmpty) {
        getTaxRate(taxCtrlr.text);
      }
      if (vatCtrlr.text.isNotEmpty) {
        getVatRate(vatCtrlr.text);
      }

      getSubTotal();
    } catch (e) {
      Helpers.showSnackBar(msg: e.toString());
    }
    update();
  }

  //-----make calculation
  double subTotal = 0.00;
  Future getSubTotal() async {
    try {
      subTotal = 0.00;
      if (serviceList.isNotEmpty) {
        for (var i in serviceList) {
          subTotal += double.parse(i.price) * double.parse(i.quantity);
          grandTotal = subTotal.toString();
        }
      }
    } catch (e) {
      Helpers.showSnackBar(msg: e.toString());
    }
    update();
  }

  String grandTotal = "0.00";
  String taxRate = "0.00";
  String vatRate = "0.00";
  getTaxRate(v) {
    try {
      if (v.toString().isEmpty) {
        taxRate = "0"; 
        grandTotal = (subTotal + double.parse(vatRate)).toStringAsFixed(2);
      } else {
        taxRate = ((double.parse(v.toString()) * subTotal) / 100)
            .toDouble()
            .toStringAsFixed(2);
        grandTotal = (subTotal + double.parse(taxRate) + double.parse(vatRate))
            .toDouble()
            .toStringAsFixed(2);
      }
    } catch (E, S) { 
      print(S);
      Helpers.showSnackBar(msg: E.toString());
    }

    update();
  }

  getVatRate(v) {
    try {
      if (v.toString().isEmpty) {
        vatRate = "0";
        grandTotal = (subTotal + double.parse(taxRate)).toStringAsFixed(2);
      } else {
        vatRate = ((double.parse(v.toString()) * subTotal) / 100)
            .toDouble()
            .toStringAsFixed(2);
        grandTotal = (subTotal + double.parse(vatRate) + double.parse(taxRate))
            .toDouble()
            .toStringAsFixed(2);
      }
    } catch (e) {
      Helpers.showSnackBar(msg: e.toString());
    }

    update();
  }

  @override
  void onInit() {
    getInvoiceCreate();
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

class ServiceModel {
  String title;
  String quantity;
  String price;
  String? description;
  ServiceModel({
    required this.title,
    required this.quantity,
    required this.price,
    this.description = "",
  });
  Map<String, dynamic> toJson() {
    return {
      "title": title, // 'title' is the key
      "price": price,
      "description": description,
      "quantity": quantity,
    };
  }
}
