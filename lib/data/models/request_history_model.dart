

class RequestHistoryModel {
    Message? message;

    RequestHistoryModel({
        this.message,
    });

    factory RequestHistoryModel.fromJson(Map<String, dynamic> json) => RequestHistoryModel(
        message: json["message"] == null ? null : Message.fromJson(json["message"]),
    );

 
}

class Message {
    RequestMoney? requestMoney;

    Message({
        this.requestMoney,
    });

    factory Message.fromJson(Map<String, dynamic> json) => Message(
        requestMoney: json["requestMoney"] == null ? null : RequestMoney.fromJson(json["requestMoney"]),
    );

  
}

class RequestMoney {
    List<Datum>? data;

    RequestMoney({
        this.data,
    });

    factory RequestMoney.fromJson(Map<String, dynamic> json) => RequestMoney(
        data: json["data"] == null ? [] : List<Datum>.from(json["data"]!.map((x) => Datum.fromJson(x))),
    );

}

class Datum {
    dynamic requestTo;
    dynamic senderEmail;
    dynamic transactionId;
    dynamic  amount;
    dynamic currency;
    dynamic status;
    dynamic  createdTime;

    Datum({
        this.requestTo,
        this.senderEmail,
        this.transactionId,
        this.amount,
        this.currency,
        this.status,
        this.createdTime,
    });

    factory Datum.fromJson(Map<String, dynamic> json) => Datum(
        requestTo: json["requestTo"],
        senderEmail: json["senderEmail"],
        transactionId: json["transactionId"],
        amount: json["amount"],
        currency: json["currency"],
        status: json["status"],
        createdTime: json["createdTime"] == null ? null : DateTime.parse(json["createdTime"]),
    );

}
