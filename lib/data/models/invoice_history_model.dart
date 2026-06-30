class InvoiceHistoryModel {
  Message? message;

  InvoiceHistoryModel({
    this.message,
  });

  factory InvoiceHistoryModel.fromJson(Map<String, dynamic> json) =>
      InvoiceHistoryModel(
        message:
            json["message"] == null ? null : Message.fromJson(json["message"]),
      );
}

class Message {
  Invoices? invoices;

  Message({
    this.invoices,
  });

  factory Message.fromJson(Map<String, dynamic> json) => Message(
        invoices: json["invoices"] == null
            ? null
            : Invoices.fromJson(json["invoices"]),
      );
}

class Invoices {
  List<Datum>? data;

  Invoices({
    this.data,
  });

  factory Invoices.fromJson(Map<String, dynamic> json) => Invoices(
        data: json["data"] == null
            ? []
            : List<Datum>.from(json["data"]!.map((x) => Datum.fromJson(x))),
      );
}

class Datum {
  dynamic id;
  dynamic sender;
  dynamic receiver;
  dynamic receiverEmail;
  dynamic currency;
  dynamic transactionId;
  dynamic requestedAmount;
  dynamic currencyCode;
  dynamic type;
  dynamic status;
  dynamic createdTime;

  Datum({
    this.id,
    this.sender,
    this.receiver,
    this.receiverEmail,
    this.currency,
    this.transactionId,
    this.requestedAmount,
    this.currencyCode,
    this.type,
    this.status,
    this.createdTime,
  });

  factory Datum.fromJson(Map<String, dynamic> json) => Datum(
        id: json["id"],
        sender: json["sender"],
        receiver: json["receiver"],
        receiverEmail: json["receiverEmail"],
        currency: json["currency"],
        transactionId: json["transactionId"],
        requestedAmount: json["requestedAmount"].toString(),
        currencyCode: json["currencyCode"],
        type: json["type"],
        status: json["status"],
        createdTime: json["createdTime"] == null
            ? null
            : DateTime.parse(json["createdTime"]),
      );
}
