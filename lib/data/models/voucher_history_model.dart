

class VoucherHistoryModel {
    Message? message;

    VoucherHistoryModel({
        this.message,
    });

    factory VoucherHistoryModel.fromJson(Map<String, dynamic> json) => VoucherHistoryModel(
        message: json["message"] == null ? null : Message.fromJson(json["message"]),
    );

}

class Message {
    Vouchers? vouchers;

    Message({
        this.vouchers,
    });

    factory Message.fromJson(Map<String, dynamic> json) => Message(
        vouchers: json["vouchers"] == null ? null : Vouchers.fromJson(json["vouchers"]),
    );

}

class Vouchers {
    List<Datum>? data;

    Vouchers({
        this.data,
    });

    factory Vouchers.fromJson(Map<String, dynamic> json) => Vouchers(
        data: json["data"] == null ? [] : List<Datum>.from(json["data"]!.map((x) => Datum.fromJson(x))),
    );

 
}

class Datum {
    dynamic senderId;
    dynamic receiverId;
    dynamic userId;
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
        this.senderId,
        this.receiverId,
        this.userId,
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
        senderId: json["senderId"],
        receiverId: json["receiverId"],
        userId: json["userId"],
        sender: json["sender"],
        receiver: json["receiver"],
        receiverEmail: json["receiverEmail"],
        currency: json["currency"],
        transactionId: json["transactionId"],
        requestedAmount: json["requestedAmount"],
        currencyCode: json["currencyCode"],
        type: json["type"],
        status: json["status"],
        createdTime: json["createdTime"] == null ? null : DateTime.parse(json["createdTime"]),
    );


}
