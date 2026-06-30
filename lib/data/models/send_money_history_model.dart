class SendMoneyHistoryModel {
  Message? message;

  SendMoneyHistoryModel({
    this.message,
  });

  factory SendMoneyHistoryModel.fromJson(Map<String, dynamic> json) =>
      SendMoneyHistoryModel(
        message:
            json["message"] == null ? null : Message.fromJson(json["message"]),
      );
}

class Message {
  Transfers? transfers;

  Message({
    this.transfers,
  });

  factory Message.fromJson(Map<String, dynamic> json) => Message(
        transfers: json["transfers"] == null
            ? null
            : Transfers.fromJson(json["transfers"]),
      );
}

class Transfers {
  List<Datum>? data;

  Transfers({
    this.data,
  });

  factory Transfers.fromJson(Map<String, dynamic> json) => Transfers(
        data: json["data"] == null
            ? []
            : List<Datum>.from(json["data"]!.map((x) => Datum.fromJson(x))),
      );
}

class Datum {
  dynamic sender;
  dynamic receiver;
  dynamic receiverEmail;
  dynamic transactionId;
  dynamic amount;
  dynamic currencyCode;
  dynamic type;
  dynamic status;
  dynamic createdTime;

  Datum({
    this.sender,
    this.receiver,
    this.receiverEmail,
    this.transactionId,
    this.amount,
    this.currencyCode,
    this.type,
    this.status,
    this.createdTime,
  });

  factory Datum.fromJson(Map<String, dynamic> json) => Datum(
        sender: json["sender"],
        receiver: json["receiver"],
        receiverEmail: json["receiverEmail"],
        transactionId: json["transactionId"],
        amount: json["amount"],
        currencyCode: json["currencyCode"],
        type: json["type"],
        status: json["status"],
        createdTime: json["createdTime"] == null
            ? null
            : DateTime.parse(json["createdTime"]),
      );
}
