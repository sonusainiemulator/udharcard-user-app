

class DepositHistoryModel {
    final Message? message;

    DepositHistoryModel({
        this.message,
    });

    factory DepositHistoryModel.fromJson(Map<String, dynamic> json) => DepositHistoryModel(
        message: json["message"] == null ? null : Message.fromJson(json["message"]),
    );
}

class Message {
    final List<Fund>? funds;

    Message({
        this.funds,
    });

    factory Message.fromJson(Map<String, dynamic> json) => Message(
        funds: json["funds"] == null ? [] : List<Fund>.from(json["funds"]!.map((x) => Fund.fromJson(x))),
    );

}

class Fund {
    final dynamic id;
    final dynamic trxId;
    final dynamic amount;
    final dynamic charge;
    final dynamic payableAmount;
    final dynamic payableAmountInBaseCurrency;
    final dynamic status;
    final Currency? currency;
    final Gateway? user;
    final Gateway? gateway;
    final dynamic createdAt;

    Fund({
        this.id,
        this.trxId,
        this.amount,
        this.charge,
        this.payableAmount,
        this.payableAmountInBaseCurrency,
        this.status,
        this.currency,
        this.user,
        this.gateway,
        this.createdAt,
    });

    factory Fund.fromJson(Map<String, dynamic> json) => Fund(
        id: json["id"],
        trxId: json["trx_id"],
        amount: json["amount"],
        charge: json["charge"],
        payableAmount: json["payable_amount"],
        payableAmountInBaseCurrency: json["payable_amount_in_base_currency"]?.toDouble(),
        status: json["status"],
        currency: json["currency"] == null ? null : Currency.fromJson(json["currency"]),
        user: json["user"] == null ? null : Gateway.fromJson(json["user"]),
        gateway: json["gateway"] == null ? null : Gateway.fromJson(json["gateway"]),
        createdAt: json["created_at"] == null ? null : DateTime.parse(json["created_at"]),
    );

}

class Currency {
    final dynamic code;
    final dynamic symbol;

    Currency({
        this.code,
        this.symbol,
    });

    factory Currency.fromJson(Map<String, dynamic> json) => Currency(
        code: json["code"],
        symbol: json["symbol"],
    );

}

class Gateway {
    final dynamic name;
    final dynamic image;

    Gateway({
        this.name,
        this.image,
    });

    factory Gateway.fromJson(Map<String, dynamic> json) => Gateway(
        name: json["name"],
        image: json["image"],
    );

}
