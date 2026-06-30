class ExchangeMoneyHistoryModel {
  Message? message;

  ExchangeMoneyHistoryModel({
    this.message,
  });

  factory ExchangeMoneyHistoryModel.fromJson(Map<String, dynamic> json) =>
      ExchangeMoneyHistoryModel(
        message:
            json["message"] == null ? null : Message.fromJson(json["message"]),
      );
}

class Message {
  Exchanges? exchanges;

  Message({
    this.exchanges,
  });

  factory Message.fromJson(Map<String, dynamic> json) => Message(
        exchanges: json["exchanges"] == null
            ? null
            : Exchanges.fromJson(json["exchanges"]),
      );
}

class Exchanges {
  List<Datum>? data;

  Exchanges({
    this.data,
  });

  factory Exchanges.fromJson(Map<String, dynamic> json) => Exchanges(
        data: json["data"] == null
            ? []
            : List<Datum>.from(json["data"]!.map((x) => Datum.fromJson(x))),
      );
}

class Datum {
  dynamic exchange;
  dynamic fromCurrency;
  dynamic toCurrency;
  dynamic amount;
  dynamic charge;
  dynamic exchangeRate;
  dynamic exchangeAmount;
  dynamic transactionId;
  dynamic status;
  dynamic createdTime;

  Datum({
    this.exchange,
    this.fromCurrency,
    this.toCurrency,
    this.amount,
    this.charge,
    this.exchangeRate,
    this.exchangeAmount,
    this.transactionId,
    this.status,
    this.createdTime,
  });

  factory Datum.fromJson(Map<String, dynamic> json) => Datum(
        exchange: json["exchange"],
        fromCurrency: json["fromCurrency"],
        toCurrency: json["toCurrency"],
        amount: json["amount"],
        charge: json["charge"].toString(),
        exchangeRate: json["exchangeRate"],
        exchangeAmount: json["exchangeAmount"],
        transactionId: json["transactionId"],
        status: json["status"],
        createdTime: json["createdTime"] == null
            ? null
            : DateTime.parse(json["createdTime"]),
      );
}
