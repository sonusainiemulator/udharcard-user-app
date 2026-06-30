class QrPaymentHistoryModel {
  Message? message;

  QrPaymentHistoryModel({
    this.message,
  });

  factory QrPaymentHistoryModel.fromJson(Map<String, dynamic> json) =>
      QrPaymentHistoryModel(
        message:
            json["message"] == null ? null : Message.fromJson(json["message"]),
      );
}

class Message {
  List<Gateway>? gateways;
  QrPayments? qrPayments;

  Message({
    this.gateways,
    this.qrPayments,
  });

  factory Message.fromJson(Map<String, dynamic> json) => Message(
        gateways: json["gateways"] == null
            ? []
            : List<Gateway>.from(
                json["gateways"]!.map((x) => Gateway.fromJson(x))),
        qrPayments: json["qrPayments"] == null
            ? null
            : QrPayments.fromJson(json["qrPayments"]),
      );
}

class Gateway {
  dynamic id;
  dynamic status;
  dynamic name;

  Gateway({
    this.id,
    this.status,
    this.name,
  });

  factory Gateway.fromJson(Map<String, dynamic> json) => Gateway(
        id: json["id"],
        status: json["status"],
        name: json["name"],
      );
}

class QrPayments {
  List<Datum>? data;

  QrPayments({
    this.data,
  });

  factory QrPayments.fromJson(Map<String, dynamic> json) => QrPayments(
        data: json["data"] == null
            ? []
            : List<Datum>.from(json["data"]!.map((x) => Datum.fromJson(x))),
      );
}

class Datum {
  dynamic senderEmail;
  dynamic receiverName;
  dynamic amount;
  dynamic currency;
  dynamic charge;
  dynamic gateway;
  dynamic createdTime;
  dynamic status;

  Datum({
    this.senderEmail,
    this.receiverName,
    this.amount,
    this.currency,
    this.charge,
    this.gateway,
    this.createdTime,
    this.status,
  });

  factory Datum.fromJson(Map<String, dynamic> json) => Datum(
        senderEmail: json["senderEmail"],
        receiverName: json["receiverName"],
        amount: json["amount"],
        currency: json["currency"],
        charge: json["charge"].toString(),
        gateway: json["gateway"],
        status: json["status"],
        createdTime: json["createdTime"] == null
            ? null
            : DateTime.parse(json["createdTime"]),
      );
}
