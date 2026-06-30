

class RedeemHistoryModel {
    Message? message;

    RedeemHistoryModel({
        this.message,
    });

    factory RedeemHistoryModel.fromJson(Map<String, dynamic> json) => RedeemHistoryModel(
        message: json["message"] == null ? null : Message.fromJson(json["message"]),
    );
}

class Message {
    RedeemCodes? redeemCodes;

    Message({
        this.redeemCodes,
    });

    factory Message.fromJson(Map<String, dynamic> json) => Message(
        redeemCodes: json["redeemCodes"] == null ? null : RedeemCodes.fromJson(json["redeemCodes"]),
    );
}

class RedeemCodes {
    List<Datum>? data;

    RedeemCodes({
        this.data,
    });

    factory RedeemCodes.fromJson(Map<String, dynamic> json) => RedeemCodes(
        data: json["data"] == null ? [] : List<Datum>.from(json["data"]!.map((x) => Datum.fromJson(x))),
    );

}

class Datum {
    dynamic sender;
    dynamic receiver;
    dynamic receiverEMail;
    dynamic transactionId;
    dynamic amount;
    dynamic currency;
    dynamic type;
    dynamic status;
    dynamic createdTime;

    Datum({
        this.sender,
        this.receiver,
        this.receiverEMail,
        this.transactionId,
        this.amount,
        this.currency,
        this.type,
        this.status,
        this.createdTime,
    });

    factory Datum.fromJson(Map<String, dynamic> json) => Datum(
        sender: json["sender"],
        receiver: json["receiver"],
        receiverEMail: json["receiverEMail"],
        transactionId: json["transactionId"],
        amount: json["amount"],
        currency: json["currency"],
        type: json["type"],
        status: json["status"],
        createdTime: json["createdTime"] == null ? null : DateTime.parse(json["createdTime"]),
    );


}
