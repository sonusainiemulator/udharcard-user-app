class MakePaymentPreviewModel {
  Message? message;

  MakePaymentPreviewModel({this.message});

  factory MakePaymentPreviewModel.fromJson(Map<String, dynamic> json) =>
      MakePaymentPreviewModel(
        message:
            json["message"] == null ? null : Message.fromJson(json["message"]),
      );

  Map<String, dynamic> toJson() => {"message": message?.toJson()};
}

class Message {
  bool? enable;
  Transaction? transaction;

  Message({this.enable, this.transaction});

  factory Message.fromJson(Map<String, dynamic> json) => Message(
    enable: json["enable"],
    transaction:
        json["transaction"] == null
            ? null
            : Transaction.fromJson(json["transaction"]),
  );

  Map<String, dynamic> toJson() => {
    "enable": enable,
    "transaction": transaction?.toJson(),
  };
}

class Transaction {
  dynamic id;
  dynamic type;
  dynamic currencyId;
  dynamic userId;
  dynamic agentId;
  dynamic amount;
  dynamic charge;
  dynamic netAmount;
  dynamic received_amount;
  dynamic commission;
  dynamic trxId;
  dynamic status;
  dynamic note;
  dynamic createdAt;
  dynamic updatedAt;
  Agent? user;
  Agent? agent;
  Agent? merchant;
  Currency? currency;

  Transaction({
    this.id,
    this.type,
    this.currencyId,
    this.userId,
    this.agentId,
    this.amount,
    this.charge,
    this.netAmount,
    this.received_amount,
    this.commission,
    this.trxId,
    this.status,
    this.note,
    this.createdAt,
    this.updatedAt,
    this.user,
    this.merchant,
    this.agent,
    this.currency,
  });

  factory Transaction.fromJson(Map<String, dynamic> json) => Transaction(
    id: json["id"],
    type: json["type"],
    currencyId: json["currency_id"],
    userId: json["user_id"],
    agentId: json["agent_id"],
    amount: json["amount"],
    charge: json["charge"],
    netAmount: json["net_amount"],
    received_amount: json["received_amount"],
    commission: json["commission"],
    trxId: json["trx_id"],
    status: json["status"],
    note: json["note"],
    createdAt:
        json["created_at"] == null ? null : DateTime.parse(json["created_at"]),
    updatedAt:
        json["updated_at"] == null ? null : DateTime.parse(json["updated_at"]),
    user: json["user"] == null ? null : Agent.fromJson(json["user"]),
    agent: json["agent"] == null ? null : Agent.fromJson(json["agent"]),
    merchant:
        json["merchant"] == null ? null : Agent.fromJson(json["merchant"]),
    currency:
        json["currency"] == null ? null : Currency.fromJson(json["currency"]),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "type": type,
    "currency_id": currencyId,
    "user_id": userId,
    "agent_id": agentId,
    "amount": amount,
    "charge": charge,
    "net_amount": netAmount,
    "commission": commission,
    "trx_id": trxId,
    "status": status,
    "note": note,
    "created_at": createdAt?.toIso8601String(),
    "updated_at": updatedAt?.toIso8601String(),
    "user": user?.toJson(),
    "agent": agent?.toJson(),
    "currency": currency?.toJson(),
  };
}

class Agent {
  dynamic id;
  dynamic username;
  dynamic firstname;
  dynamic lastname;
  dynamic email;
  dynamic phoneCode;
  dynamic phone;
  dynamic image;
  dynamic imageDriver;
  bool? lastSeenActivity;

  Agent({
    this.id,
    this.username,
    this.firstname,
    this.lastname,
    this.email,
    this.phoneCode,
    this.phone,
    this.image,
    this.imageDriver,
    this.lastSeenActivity,
  });

  factory Agent.fromJson(Map<String, dynamic> json) => Agent(
    id: json["id"],
    username: json["username"],
    firstname: json["firstname"],
    lastname: json["lastname"],
    email: json["email"],
    phoneCode: json["phone_code"],
    phone: json["phone"],
    image: json["image"],
    imageDriver: json["image_driver"],
    lastSeenActivity: json["last-seen-activity"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "username": username,
    "firstname": firstname,
    "lastname": lastname,
    "email": email,
    "phone_code": phoneCode,
    "phone": phone,
    "image": image,
    "image_driver": imageDriver,
    "last-seen-activity": lastSeenActivity,
  };
}

class Currency {
  dynamic id;
  dynamic code;
  dynamic symbol;
  dynamic exchangeRate;

  Currency({this.id, this.code, this.symbol, this.exchangeRate});

  factory Currency.fromJson(Map<String, dynamic> json) => Currency(
    id: json["id"],
    code: json["code"],
    symbol: json["symbol"],
    exchangeRate: json["exchange_rate"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "code": code,
    "symbol": symbol,
    "exchange_rate": exchangeRate,
  };
}
