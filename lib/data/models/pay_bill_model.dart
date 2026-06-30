class PayBillModel {
  Message? message;

  PayBillModel({
    this.message,
  });

  factory PayBillModel.fromJson(Map<String, dynamic> json) => PayBillModel(
        message:
            json["message"] == null ? null : Message.fromJson(json["message"]),
      );
}

class Message {
  List<Category>? categories;
  List<Currency>? currencies;
  BillMethod? billMethod;

  Message({
    this.categories,
    this.currencies,
    this.billMethod,
  });

  factory Message.fromJson(Map<String, dynamic> json) => Message(
        categories: json["categories"] == null
            ? []
            : List<Category>.from(
                json["categories"]!.map((x) => Category.fromJson(x))),
        currencies: json["currencies"] == null
            ? []
            : List<Currency>.from(
                json["currencies"]!.map((x) => Currency.fromJson(x))),
        billMethod: json["billMethod"] == null
            ? null
            : BillMethod.fromJson(json["billMethod"]),
      );
}

class BillMethod {
  dynamic id;
  InputForm? inputForm;
  List<BillService>? billServices;

  BillMethod({
    this.id,
    this.inputForm,
    this.billServices,
  });

  factory BillMethod.fromJson(Map<String, dynamic> json) => BillMethod(
        id: json["id"],
        inputForm: json["inputForm"] == null
            ? null
            : InputForm.fromJson(json["inputForm"]),
        billServices: json["bill_services"] == null
            ? []
            : List<BillService>.from(
                json["bill_services"]!.map((x) => BillService.fromJson(x))),
      );
}

class BillService {
  dynamic id;
  dynamic billMethodId;
  dynamic service;
  dynamic code;
  dynamic type;
  dynamic country;
  Info? info;
  List<String>? labelName;
  dynamic amount;
  dynamic percentCharge;
  dynamic fixedCharge;
  dynamic minAmount;
  dynamic maxAmount;
  dynamic currency;
  dynamic status;
  dynamic createdAt;
  dynamic updatedAt;

  BillService({
    this.id,
    this.billMethodId,
    this.service,
    this.code,
    this.type,
    this.country,
    this.info,
    this.labelName,
    this.amount,
    this.percentCharge,
    this.fixedCharge,
    this.minAmount,
    this.maxAmount,
    this.currency,
    this.status,
    this.createdAt,
    this.updatedAt,
  });

  factory BillService.fromJson(Map<String, dynamic> json) => BillService(
        id: json["id"],
        billMethodId: json["bill_method_id"],
        service: json["service"],
        code: json["code"],
        type: json["type"],
        country: json["country"],
        info: json["info"] == null ? null : Info.fromJson(json["info"]),
       labelName: json["label_name"] == null
            ? []
            : List<String>.from(
                json["label_name"]!.map((x) => x)),
        amount: json["amount"] ?? "0",
        percentCharge: json["percent_charge"] ?? "0",
        fixedCharge: json["fixed_charge"] ?? "0",
        minAmount: json["min_amount"] ?? "0",
        maxAmount: json["max_amount"] ?? "0",
        currency: json["currency"],
        status: json["status"],
        createdAt: json["created_at"] == null
            ? null
            : DateTime.parse(json["created_at"]),
        updatedAt: json["updated_at"] == null
            ? null
            : DateTime.parse(json["updated_at"]),
      );
}

class Info {
  dynamic id;
  dynamic billerCode;
  dynamic name;
  dynamic defaultCommission;
  dynamic dateAdded;
  dynamic country;
  dynamic isAirtime;
  dynamic billerName;
  dynamic itemCode;
  dynamic shortName;
  dynamic fee;
  dynamic commissionOnFee;
  dynamic amount;

  Info({
    this.id,
    this.billerCode,
    this.name,
    this.defaultCommission,
    this.dateAdded,
    this.country,
    this.isAirtime,
    this.billerName,
    this.itemCode,
    this.shortName,
    this.fee,
    this.commissionOnFee,
    this.amount,
  });

  factory Info.fromJson(Map<String, dynamic> json) => Info(
        id: json["id"],
        billerCode: json["biller_code"],
        name: json["name"],
        defaultCommission: json["default_commission"],
        dateAdded: json["date_added"] == null
            ? null
            : DateTime.parse(json["date_added"]),
        country: json["country"],
        isAirtime: json["is_airtime"],
        billerName: json["biller_name"],
        itemCode: json["item_code"],
        shortName: json["short_name"],
        fee: json["fee"],
        commissionOnFee: json["commission_on_fee"],
        amount: json["amount"],
      );
}

class InputForm {
  Customer? customer;

  InputForm({
    this.customer,
  });

  factory InputForm.fromJson(Map<String, dynamic> json) => InputForm(
        customer: json["customer"] == null
            ? null
            : Customer.fromJson(json["customer"]),
      );
}

class Customer {
  dynamic name;
  dynamic label;
  dynamic type;
  dynamic validation;

  Customer({
    this.name,
    this.label,
    this.type,
    this.validation,
  });

  factory Customer.fromJson(Map<String, dynamic> json) => Customer(
        name: json["name"],
        label: json["label"],
        type: json["type"],
        validation: json["validation"],
      );
}

class Category {
  dynamic name;
  dynamic value;
  dynamic img;

  Category({
    this.name,
    this.value,
    this.img,
  });

  factory Category.fromJson(Map<String, dynamic> json) => Category(
        name: json["name"],
        value: json["value"],
        img: json["img"],
      );
}

class Currency {
  dynamic id;
  dynamic code;
  dynamic name;
  dynamic currencyType;

  Currency({
    this.id,
    this.code,
    this.name,
    this.currencyType,
  });

  factory Currency.fromJson(Map<String, dynamic> json) => Currency(
        id: json["id"],
        code: json["code"],
        name: json["name"],
        currencyType: json["currency_type"],
      );
}
