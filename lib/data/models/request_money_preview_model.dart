class RequestMoneyPreviewModel {
  Message? message;

  RequestMoneyPreviewModel({
    this.message,
  });

  factory RequestMoneyPreviewModel.fromJson(Map<String, dynamic> json) =>
      RequestMoneyPreviewModel(
        message:
            json["message"] == null ? null : Message.fromJson(json["message"]),
      );
}

class Message {
  dynamic enableFor;
  dynamic utr;
  dynamic name;
  dynamic currency;
  dynamic currencyId;
  dynamic percent;
  dynamic percentCharge;
  dynamic fixedCharge;
  dynamic totalCharge;
  dynamic payableAmount;
  dynamic receiverWillReceive;
  dynamic chargeDeductFrom;
  dynamic note;

  Message({
    this.enableFor,
    this.utr,
    this.name,
    this.currency,
    this.currencyId,
    this.percent,
    this.percentCharge,
    this.fixedCharge,
    this.totalCharge,
    this.payableAmount,
    this.receiverWillReceive,
    this.chargeDeductFrom,
    this.note,
  });

  factory Message.fromJson(Map<String, dynamic> json) => Message(
        enableFor: json["enable_for"],
        utr: json["utr"],
        name: json["name"],
        currency: json["currency"],
        currencyId: json["currency_id"],
        percent: json["percent"].toString(),
        percentCharge: json["percentCharge"] == null
            ? "0.00"
            : json["percentCharge"].toString(),
        fixedCharge: json["fixedCharge"] == null
            ? "0.00"
            : json["fixedCharge"].toString(),
        totalCharge: json["totalCharge"] == null
            ? "0.00"
            : json["totalCharge"].toString(),
        payableAmount:
            json["payableAmount"] == null ? "0.00" : json["payableAmount"],
        receiverWillReceive: json["receiverWillReceive"],
        chargeDeductFrom: json["chargeDeductFrom"],
        note: json["note"] ?? "",
      );
}
