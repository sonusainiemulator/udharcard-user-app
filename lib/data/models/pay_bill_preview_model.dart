class PayBillPreviewModel {
  Message? message;

  PayBillPreviewModel({
    this.message,
  });

  factory PayBillPreviewModel.fromJson(Map<String, dynamic> json) =>
      PayBillPreviewModel(
        message:
            json["message"] == null ? null : Message.fromJson(json["message"]),
      );
}

class Message {
  bool? enableFor;
  dynamic category;
  dynamic service;
  dynamic countryCode;
  dynamic fromWalletCode;
  dynamic fromWalletName;
  dynamic currencyCode;
  dynamic exchangeRate;
  dynamic amount;
  dynamic charge;
  dynamic payableAmount;
  dynamic utr;

  Message({
    this.enableFor,
    this.category,
    this.service,
    this.countryCode,
    this.fromWalletCode,
    this.fromWalletName,
    this.currencyCode,
    this.exchangeRate,
    this.amount,
    this.charge,
    this.payableAmount,
    this.utr,
  });

  factory Message.fromJson(Map<String, dynamic> json) => Message(
        enableFor: json["enable_for"],
        category: json["category"],
        service: json["service"],
        countryCode: json["countryCode"],
        fromWalletCode: json["fromWalletCode"],
        fromWalletName: json["fromWalletName"],
        currencyCode: json["currencyCode"],
        exchangeRate: json["exchangeRate"],
        amount: json["amount"],
        charge: json["charge"].toString(),
        payableAmount: json["payableAmount"].toString(),
        utr: json["utr"],
      );
}
