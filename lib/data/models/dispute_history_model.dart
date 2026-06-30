class DisputeHistoryModel {
  Message? message;

  DisputeHistoryModel({
    this.message,
  });

  factory DisputeHistoryModel.fromJson(Map<String, dynamic> json) =>
      DisputeHistoryModel(
        message:
            json["message"] == null ? null : Message.fromJson(json["message"]),
      );
}

class Message {
  Disputes? disputes;

  Message({
    this.disputes,
  });

  factory Message.fromJson(Map<String, dynamic> json) => Message(
        disputes: json["disputes"] == null
            ? null
            : Disputes.fromJson(json["disputes"]),
      );
}

class Disputes {
  Target? target;

  Disputes({
    this.target,
  });

   factory Disputes.fromJson(Map<String, dynamic> json) => Disputes(
        target: json["target"] == null
            ? null
            : Target.fromJson(json["target"]),
      );
}

class Target {
  List<Datum>? data;

  Target({this.data});

  factory Target.fromJson(Map<String, dynamic> json) => Target(
        data: json["data"] == null
            ? []
            : List<Datum>.from(json["data"]!.map((x) => Datum.fromJson(x))),
      );
}

class Datum {
  dynamic disputeFor;
  dynamic escrowRoute;
  dynamic disputeId;
  dynamic status;
  dynamic createdTime;

  Datum({
    this.disputeFor,
    this.escrowRoute,
    this.disputeId,
    this.status,
    this.createdTime,
  });

  factory Datum.fromJson(Map<String, dynamic> json) => Datum(
        disputeFor: json["disputeFor"],
        escrowRoute: json["escrowRoute"],
        disputeId: json["disputeId"],
        status: json["status"],
        createdTime: json["createdTime"],
      );
}
