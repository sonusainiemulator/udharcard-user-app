class PayBillHistoryModel {
  Message? message;

  PayBillHistoryModel({
    this.message,
  });

  factory PayBillHistoryModel.fromJson(Map<String, dynamic> json) =>
      PayBillHistoryModel(
        message:
            json["message"] == null ? null : Message.fromJson(json["message"]),
      );
}

class Message {
  Bills? bills;

  Message({
    this.bills,
  });

  factory Message.fromJson(Map<String, dynamic> json) => Message(
        bills: json["bills"] == null ? null : Bills.fromJson(json["bills"]),
      );
}

class Bills {
  List<Datum>? data;

  Bills({
    this.data,
  });

  factory Bills.fromJson(Map<String, dynamic> json) => Bills(
        data: json["data"] == null
            ? []
            : List<Datum>.from(json["data"]!.map((x) => Datum.fromJson(x))),
      );
}

class Datum {
  dynamic category;
  dynamic type;
  dynamic currency;
  dynamic amount;
  dynamic charge;
  dynamic status;
  dynamic createdTime;
  dynamic utr;

  Datum({
    this.category,
    this.type,
    this.currency,
    this.amount,
    this.charge,
    this.status,
    this.createdTime,
    this.utr,
  });

  factory Datum.fromJson(Map<String, dynamic> json) => Datum(
        category: json["category"],
        type: json["type"],
        currency: json["currency"],
        amount: json["amount"],
        charge: json["charge"].toString(),
        status: json["status"],
        utr: json["utr"],
        createdTime: json["createdTime"] == null
            ? null
            : DateTime.parse(json["createdTime"]),
      );
}
