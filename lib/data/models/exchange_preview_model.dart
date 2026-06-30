

class ExchangeMoneyPreviewModel {
    Message? message;

    ExchangeMoneyPreviewModel({
        this.message,
    });

    factory ExchangeMoneyPreviewModel.fromJson(Map<String, dynamic> json) => ExchangeMoneyPreviewModel(
        message: json["message"] == null ? null : Message.fromJson(json["message"]),
    );

    
}

class Message {
    dynamic enableFor;
    dynamic exchangeFrom;
    dynamic exchangeTo;
    dynamic exchangeRate;
    dynamic percentage;
    dynamic percentageCharge;
    dynamic fixedCharge;
    dynamic totalCharge;
    dynamic payableAmount;
    dynamic youWillGet;
    dynamic utr;

    Message({
        this.enableFor,
        this.exchangeFrom,
        this.exchangeTo,
        this.exchangeRate,
        this.percentage,
        this.percentageCharge,
        this.fixedCharge,
        this.totalCharge,
        this.payableAmount,
        this.youWillGet,
        this.utr,
    });

    factory Message.fromJson(Map<String, dynamic> json) => Message(
        enableFor: json["enable_for"],
        exchangeFrom: json["exchangeFrom"],
        exchangeTo: json["exchangeTo"],
        exchangeRate: json['exchangeRate'] == null ? "0.00": json["exchangeRate"].toString(),
        percentage: json['percentage'] == null ? "0.00": json["percentage"],
        percentageCharge:json['percentageCharge'] == null ? "0.00":  json["percentageCharge"].toString(),
        fixedCharge:json['fixedCharge'] == null ? "0.00":  json["fixedCharge"],
        totalCharge:json['totalCharge'] == null ? "0.00":  json["totalCharge"].toString(),
        payableAmount:json['payableAmount'] == null ? "0.00":  json["payableAmount"].toString(),
        youWillGet:json['youWillGet'] == null ? "0.00":  json["youWillGet"].toString(),
        utr: json["utr"],
    );


}
