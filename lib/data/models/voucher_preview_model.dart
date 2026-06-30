class VoucherPreviewModel {
  Message? message;

  VoucherPreviewModel({
    this.message,
  });

  factory VoucherPreviewModel.fromJson(Map<String, dynamic> json) =>
      VoucherPreviewModel(
        message:
            json["message"] == null ? null : Message.fromJson(json["message"]),
      );
}

class Message {
  dynamic enableFor;
  dynamic requestedAmount;
  dynamic currencyCode;
  dynamic percentage;
  dynamic percentageCharge;
  dynamic fixedCharge;
  dynamic totalCharge;
  dynamic receivableAmount;
  dynamic note;
  dynamic showCharges;
  dynamic status;
  dynamic acceptBtn;
  dynamic cancelBtn;
  dynamic utr;

  Message({
    this.enableFor,
    this.requestedAmount,
    this.currencyCode,
    this.percentage,
    this.percentageCharge,
    this.fixedCharge,
    this.totalCharge,
    this.receivableAmount,
    this.note,
    this.showCharges,
    this.status,
    this.acceptBtn,
    this.cancelBtn,
    this.utr,
  });

  factory Message.fromJson(Map<String, dynamic> json) => Message(
        enableFor: json["enable_for"],
        requestedAmount: json["requestedAmount"],
        currencyCode: json["currencyCode"],
        percentage: json["percentage"].toString(),
        percentageCharge: json["percentageCharge"].toString(),
        fixedCharge: json["fixedCharge"],
        totalCharge: json["totalCharge"].toString(),
        receivableAmount: json["receivableAmount"].toString(),
        note: json["note"],
        showCharges: json["showCharges"],
        status: json["status"],
        acceptBtn: json["acceptBtn"],
        cancelBtn: json["cancelBtn"],
        utr: json["utr"],
      );
}
