class RedeemPreviewModel {
  Message? message;

  RedeemPreviewModel({
    this.message,
  });

  factory RedeemPreviewModel.fromJson(Map<String, dynamic> json) =>
      RedeemPreviewModel(
        message:
            json["message"] == null ? null : Message.fromJson(json["message"]),
      );
}

class Message {
  dynamic transactionTypeId;
  dynamic utr;
  dynamic currency;
  dynamic percentage;
  dynamic percentageCharge;
  dynamic fixedCharge;
  dynamic totalCharge;
  dynamic payableAmount;
  dynamic receiverWillReceive;
  dynamic chargeDeductFrom;
  dynamic note;

  Message({
    this.transactionTypeId,
    this.utr,
    this.currency,
    this.percentage,
    this.percentageCharge,
    this.fixedCharge,
    this.totalCharge,
    this.payableAmount,
    this.receiverWillReceive,
    this.chargeDeductFrom,
    this.note,
  });

  factory Message.fromJson(Map<String, dynamic> json) => Message(
        transactionTypeId: json["transactionTypeId"],
        utr: json["utr"],
        currency: json["currency"],
        percentage: json["percentage"].toString(),
        percentageCharge: json["percentageCharge"].toString(),
        fixedCharge: json["fixedCharge"].toString(),
        totalCharge: json["totalCharge"].toString(),
        payableAmount: json["payableAmount"],
        receiverWillReceive: json["receiverWillReceive"].toString(),
        chargeDeductFrom: json["chargeDeductFrom"],
        note: json["note"],
      );
}
