class SendMoneyPreviewModel {
  Message? message;

  SendMoneyPreviewModel({
    this.message,
  });

  factory SendMoneyPreviewModel.fromJson(Map<String, dynamic> json) =>
      SendMoneyPreviewModel(
        message:
            json["message"] == null ? null : Message.fromJson(json["message"]),
      );
}

class Message {
  dynamic enableFor;
  dynamic receiverName;
  dynamic currency;
  dynamic percentageCharge;
  dynamic percentage;
  dynamic fixedCharge;
  dynamic totalCharge;
  dynamic payableAmount;
  dynamic receiverWillReceive;
  dynamic chargeDeductFrom;
  dynamic note;
  dynamic utr;

  Message({
    this.enableFor,
    this.receiverName,
    this.currency,
    this.percentageCharge,
    this.percentage,
    this.fixedCharge,
    this.totalCharge,
    this.payableAmount,
    this.receiverWillReceive,
    this.chargeDeductFrom,
    this.note,
    this.utr,
  });

  factory Message.fromJson(Map<String, dynamic> json) => Message(
        enableFor: json["enable_for"],
        receiverName: json["receiverName"],
        currency: json["currency"],
        percentageCharge:json["percentageCharge"] == null ? "0.00": json["percentageCharge"].toString(),
        percentage: json["percentage"] == null ? "0.00":json["percentage"].toString(),
        fixedCharge:json["fixedCharge"] == null ? "0.00": json["fixedCharge"],
        totalCharge:json["totalCharge"] == null ? "0.00": json["totalCharge"].toString(),
        payableAmount:json["payableAmount"] == null ? "0.00": json["payableAmount"].toString(),
        receiverWillReceive:json["receiverWillReceive"] == null ? "0.00": json["receiverWillReceive"].toString(),
        chargeDeductFrom: json["chargeDeductFrom"],
        note: json["note"],
        utr: json["utr"],
      );
}
