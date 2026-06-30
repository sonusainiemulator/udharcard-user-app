

class InvoiceViewModel {
    Message? message;

    InvoiceViewModel({
        this.message,
    });

    factory InvoiceViewModel.fromJson(Map<String, dynamic> json) => InvoiceViewModel(
        message: json["message"] == null ? null : Message.fromJson(json["message"]),
    );
}

class Message {
    Invoice? invoice;
    dynamic payToPhone;
    dynamic payToEmail;
    dynamic image;
    dynamic requestLink;

    Message({
        this.invoice,
        this.payToPhone,
        this.payToEmail,
        this.image,
        this.requestLink,
    });

    factory Message.fromJson(Map<String, dynamic> json) => Message(
        invoice: json["invoice"] == null ? null : Invoice.fromJson(json["invoice"]),
        payToPhone: json["payToPhone"],
        payToEmail: json["payToEmail"],
        image: json["image"],
        requestLink: json["requestLink"],
    );
}

class Invoice {
    dynamic id;
    dynamic senderId;
    dynamic currencyId;
    dynamic recuringInvoiceId;
    dynamic customerEmail;
    dynamic invoiceNumber;
    dynamic subtotal;
    dynamic percentage;
    dynamic chargePercentage;
    dynamic chargeFixed;
    dynamic charge;
    dynamic tax;
    dynamic vat;
    dynamic taxRate;
    dynamic vatRate;
    dynamic grandTotal;
    dynamic frequency;
    dynamic hasSlug;
    dynamic dueDate;
    dynamic note;
    dynamic chargePay;
    dynamic status;
    dynamic seenAt;
    dynamic paidAt;
    dynamic rejectedAt;
    dynamic markAsPaidAt;
    dynamic reminderAt;
    dynamic createdAt;
    dynamic updatedAt;
    List<Item>? items;

    Invoice({
        this.id,
        this.senderId,
        this.currencyId,
        this.recuringInvoiceId,
        this.customerEmail,
        this.invoiceNumber,
        this.subtotal,
        this.percentage,
        this.chargePercentage,
        this.chargeFixed,
        this.charge,
        this.tax,
        this.vat,
        this.taxRate,
        this.vatRate,
        this.grandTotal,
        this.frequency,
        this.hasSlug,
        this.dueDate,
        this.note,
        this.chargePay,
        this.status,
        this.seenAt,
        this.paidAt,
        this.rejectedAt,
        this.markAsPaidAt,
        this.reminderAt,
        this.createdAt,
        this.updatedAt,
        this.items,
    });

    factory Invoice.fromJson(Map<String, dynamic> json) => Invoice(
        id: json["id"],
        senderId: json["sender_id"],
        currencyId: json["currency_id"],
        recuringInvoiceId: json["recuring_invoice_id"],
        customerEmail: json["customer_email"],
        invoiceNumber: json["invoice_number"],
        subtotal: json["subtotal"],
        percentage: json["percentage"],
        chargePercentage: json["charge_percentage"],
        chargeFixed: json["charge_fixed"],
        charge: json["charge"],
        tax: json["tax"],
        vat: json["vat"],
        taxRate: json["tax_rate"],
        vatRate: json["vat_rate"],
        grandTotal: json["grand_total"],
        frequency: json["frequency"],
        hasSlug: json["has_slug"],
        dueDate: json["due_date"] == null ? null : DateTime.parse(json["due_date"]),
        note: json["note"],
        chargePay: json["charge_pay"],
        status: json["status"],
        seenAt: json["seen_at"],
        paidAt: json["paid_at"],
        rejectedAt: json["rejected_at"],
        markAsPaidAt: json["mark_as_paid_at"],
        reminderAt: json["reminder_at"],
        createdAt: json["created_at"] == null ? null : DateTime.parse(json["created_at"]),
        updatedAt: json["updated_at"] == null ? null : DateTime.parse(json["updated_at"]),
        items: json["items"] == null ? [] : List<Item>.from(json["items"]!.map((x) => Item.fromJson(x))),
    );
}

class Item {
    dynamic id;
    dynamic lineItemType;
    dynamic lineItemId;
    dynamic title;
    dynamic price;
    dynamic description;
    dynamic quantity;
    dynamic subtotal;
    dynamic createdAt;
    dynamic updatedAt;

    Item({
        this.id,
        this.lineItemType,
        this.lineItemId,
        this.title,
        this.price,
        this.description,
        this.quantity,
        this.subtotal,
        this.createdAt,
        this.updatedAt,
    });

    factory Item.fromJson(Map<String, dynamic> json) => Item(
        id: json["id"],
        lineItemType: json["line_item_type"],
        lineItemId: json["line_item_id"],
        title: json["title"],
        price: json["price"],
        description: json["description"],
        quantity: json["quantity"],
        subtotal: json["subtotal"],
        createdAt: json["created_at"] == null ? null : DateTime.parse(json["created_at"]),
        updatedAt: json["updated_at"] == null ? null : DateTime.parse(json["updated_at"]),
    );
}
