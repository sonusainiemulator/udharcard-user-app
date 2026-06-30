

class VirtualCardModel {
    Message? message;

    VirtualCardModel({
        this.message,
    });

    factory VirtualCardModel.fromJson(Map<String, dynamic> json) => VirtualCardModel(
        message: json["message"] == null ? null : Message.fromJson(json["message"]),
    );

  
}

class Message {
    CardOrder? cardOrder;
    List<CardOrder>? approveCards;
    dynamic orderLock;

    Message({
        this.cardOrder,
        this.approveCards,
        this.orderLock,
    });

    factory Message.fromJson(Map<String, dynamic> json) => Message(
        cardOrder: json["cardOrder"] == null ? null : CardOrder.fromJson(json["cardOrder"]),
        approveCards: json["approveCards"] == null ? [] : List<CardOrder>.from(json["approveCards"]!.map((x) => CardOrder.fromJson(x))),
        orderLock: json["orderLock"],
    );
 
}

class CardOrder {
    dynamic id;
    dynamic virtualCardMethodId;
    dynamic userId;
    dynamic currency;
    dynamic status;
    dynamic fundAmount;
    dynamic fundCharge;
    dynamic reason;
    dynamic resubmitted;
    dynamic charge;
    dynamic chargeCurrency;
    dynamic cardInfo;
    dynamic balance;
    dynamic cvv;
    dynamic cardNumber;
    dynamic expiryDate;
    dynamic brand;
    dynamic nameOnCard;
    dynamic cardId;
    dynamic lastError;
    dynamic test;
    dynamic createdAt;
    dynamic updatedAt;
    dynamic isActive;

    CardOrder({
        this.id,
        this.virtualCardMethodId,
        this.userId,
        this.currency,
        this.status,
        this.fundAmount,
        this.fundCharge,
        this.reason,
        this.resubmitted,
        this.charge,
        this.chargeCurrency,
        this.cardInfo,
        this.balance,
        this.cvv,
        this.cardNumber,
        this.expiryDate,
        this.brand,
        this.nameOnCard,
        this.cardId,
        this.lastError,
        this.test,
        this.createdAt,
        this.updatedAt,
        this.isActive,
    });

    factory CardOrder.fromJson(Map<String, dynamic> json) => CardOrder(
        id: json["id"],
        virtualCardMethodId: json["virtual_card_method_id"],
        userId: json["user_id"],
        currency: json["currency"],
        status: json["status"],
        fundAmount: json["fund_amount"],
        fundCharge: json["fund_charge"],
        reason: json["reason"],
        resubmitted: json["resubmitted"],
        charge: json["charge"],
        chargeCurrency: json["charge_currency"],
        cardInfo: json["card_info"],
        balance: json["balance"],
        cvv: json["cvv"],
        cardNumber: json["card_number"],
        expiryDate: json["expiry_date"],
        brand: json["brand"],
        nameOnCard: json["name_on_card"],
        cardId: json["card_Id"],
        lastError: json["last_error"],
        test: json["test"],
        createdAt: json["created_at"] == null ? null : DateTime.parse(json["created_at"]),
        updatedAt: json["updated_at"] == null ? null : DateTime.parse(json["updated_at"]),
        isActive: json["is_active"],
    );

}
