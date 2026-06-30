

class VirtualCardTransactionModel {
    Message? message;

    VirtualCardTransactionModel({
        this.message,
    });

    factory VirtualCardTransactionModel.fromJson(Map<String, dynamic> json) => VirtualCardTransactionModel(
        message: json["message"] == null ? null : Message.fromJson(json["message"]),
    );

}

class Message {
    CardTransactions? cardTransactions;

    Message({
        this.cardTransactions,
    });

    factory Message.fromJson(Map<String, dynamic> json) => Message(
        cardTransactions: json["cardTransactions"] == null ? null : CardTransactions.fromJson(json["cardTransactions"]),
    );

 
}

class CardTransactions {
    List<Datum>? data;

    CardTransactions({
        this.data,
    });

    factory CardTransactions.fromJson(Map<String, dynamic> json) => CardTransactions(
        data: json["data"] == null ? [] : List<Datum>.from(json["data"]!.map((x) => Datum.fromJson(x))),
    );

 
}

class Datum {
    dynamic provider;
    dynamic amount;
    dynamic type;

    Datum({
        this.provider,
        this.amount,
        this.type,
    });

    factory Datum.fromJson(Map<String, dynamic> json) => Datum(
        provider: json["provider"],
        amount: json["amount"],
        type: json["type"],
    );

}
