

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
    dynamic enableFor;
    dynamic requestAmount;
    dynamic currency;
    dynamic percentage;
    dynamic percentageCharge;
    dynamic fixedCharge;
    dynamic totalCharge;
    dynamic receiveAmount;
    dynamic note;
    dynamic status;
    dynamic userId;
    dynamic receiverId;
    dynamic utr;
    dynamic acceptCancelBtn;
    dynamic requestPaymentBtn;
    dynamic paymentDisbursedBtn;

    Message({
        this.enableFor,
        this.requestAmount,
        this.currency,
        this.percentage,
        this.percentageCharge,
        this.fixedCharge,
        this.totalCharge,
        this.receiveAmount,
        this.note,
        this.status,
        this.userId,
        this.receiverId,
        this.utr,
        this.acceptCancelBtn,
        this.requestPaymentBtn,
        this.paymentDisbursedBtn,
    });

    factory Message.fromJson(Map<String, dynamic> json) => Message(
        enableFor: json["enable_for"],
        requestAmount: json["requestAmount"],
        currency: json["currency"],
        percentage: json["percentage"],
        percentageCharge: json["percentageCharge"],
        fixedCharge: json["fixedCharge"],
        totalCharge: json["totalCharge"],
        receiveAmount: json["receiveAmount"],
        note: json["note"],
        status: json["status"],
        userId: json["userId"],
        receiverId: json["receiverId"],
        acceptCancelBtn: json["acceptCancelBtn"],
        requestPaymentBtn: json["requestPaymentBtn"],
        paymentDisbursedBtn: json["paymentDisbursedBtn"],
        utr: json["utr"],
    );
  


       
   
 
}
