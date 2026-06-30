 
class EscrowPreviewModel {
    Message? message;

    EscrowPreviewModel({
        this.message,
    });

    factory EscrowPreviewModel.fromJson(Map<String, dynamic> json) => EscrowPreviewModel(
        message: json["message"] == null ? null : Message.fromJson(json["message"]),
    );
}

class Message {
    Escrows? escrows;

    Message({
        this.escrows,
    });

    factory Message.fromJson(Map<String, dynamic> json) => Message(
        escrows: json["escrows"] == null ? null : Escrows.fromJson(json["escrows"]),
    );


}

class Escrows {
    List<Datum>? data;

    Escrows({
        this.data,
    });

    factory Escrows.fromJson(Map<String, dynamic> json) => Escrows(
        data: json["data"] == null ? [] : List<Datum>.from(json["data"]!.map((x) => Datum.fromJson(x))),
    );
}

class Datum {
    dynamic receiver;
    dynamic receiverEmail;
    dynamic transactionId;
    dynamic amount;
    dynamic currency;
    dynamic type;
    dynamic status;
    dynamic createdTime;

    Datum({
        this.receiver,
        this.receiverEmail,
        this.transactionId,
        this.amount,
        this.currency,
        this.type,
        this.status,
        this.createdTime,
    });

    factory Datum.fromJson(Map<String, dynamic> json) => Datum(
        receiver: json["receiver"],
        receiverEmail: json["receiverEmail"],
        transactionId: json["transactionId"],
        amount: json["amount"],
        currency: json["currency"],
        type: json["type"],
        status: json["status"],
        createdTime: json["createdTime"] == null ? null : DateTime.parse(json["createdTime"]),
    );
}
