class AmountCheckModel {
  Message? message;

  AmountCheckModel({this.message});

  factory AmountCheckModel.fromJson(Map<String, dynamic> json) =>
      AmountCheckModel(
        message:
            json["message"] == null ? null : Message.fromJson(json["message"]),
      );
}

class Message {
  dynamic message;
  dynamic fixedCharge;
  dynamic percentage;
  dynamic percentageCharge;
  dynamic minLimit;
  dynamic maxLimit;
  dynamic balance;
  dynamic transferAmount;
  dynamic receivedAmount;
  dynamic remainingBalance;
  dynamic charge;
  dynamic chargeFrom;
  dynamic commission;
  dynamic payable_amount;
  dynamic charge_applied_to;
  dynamic amount;
  dynamic currencyId;
  dynamic currencyLimit;

  Message({
    this.message,
    this.fixedCharge,
    this.percentage,
    this.percentageCharge,
    this.minLimit,
    this.maxLimit,
    this.balance,
    this.commission,
    this.transferAmount,
    this.payable_amount,
    this.charge_applied_to,
    this.receivedAmount,
    this.remainingBalance,
    this.charge,
    this.chargeFrom,
    this.amount,
    this.currencyId,
    this.currencyLimit,
  });

  factory Message.fromJson(Map<String, dynamic> json) => Message(
    message: json["message"],
    fixedCharge: json["fixed_charge"].toString(),
    commission: json["commission"].toString(),
    percentage: json["percentage"].toString(),
    percentageCharge:
        json["percentage_charge"] == null
            ? '0.00'
            : json["percentage_charge"].toString(),
    payable_amount: json["payable_amount"].toString(),
    charge_applied_to: json["charge_applied_to"].toString(),
    minLimit: json["min_limit"],
    maxLimit: json["max_limit"],
    balance: json["balance"] == null ? '0.00' : json["balance"].toString(),
    transferAmount:
        json["transfer_amount"] == null
            ? '0.00'
            : json["transfer_amount"].toString(),
    receivedAmount:
        json["received_amount"] == null
            ? '0.00'
            : json["received_amount"].toString(),
    remainingBalance:
        json["remaining_balance"] == null
            ? '0.00'
            : json["remaining_balance"].toString(),
    charge: json["charge"] == null ? '0.00' : json["charge"].toString(),
    chargeFrom: json["charge_from"],
    amount: json["amount"] == null ? '0.00' : json["amount"].toString(),
    currencyId: json["currency_id"],
    currencyLimit: json["currency_limit"],
  );
}
