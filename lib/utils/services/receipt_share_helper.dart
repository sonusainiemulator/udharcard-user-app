import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import 'helpers.dart';

class ReceiptShareHelper {
  /// Generates a formatted digital receipt string
  static String formatUdharReceipt({
    required String shopName,
    required double amount,
    required String paymentId,
    DateTime? timestamp,
  }) {
    final now = timestamp ?? DateTime.now();
    final dateStr = DateFormat('dd MMM yyyy, hh:mm a').format(now);

    return '''🧾 *UDHARCARD PAYMENT RECEIPT*
━━━━━━━━━━━━━━━━━━━━━
🏪 *Merchant:* $shopName
💰 *Amount Paid:* ₹${amount.toStringAsFixed(2)}
🆔 *Payment ID:* $paymentId
📅 *Date & Time:* $dateStr
✅ *Status:* SUCCESSFUL / SETTLED
━━━━━━━━━━━━━━━━━━━━━
_Thank you for settling your balance with Udharcard!_
_Download the Udharcard App: https://udharcard.shop_''';
  }

  /// Shares receipt text via WhatsApp
  static Future<void> shareToWhatsApp({
    required String receiptText,
    String? phoneNumber,
  }) async {
    final encodedText = Uri.encodeComponent(receiptText);
    Uri uri;

    if (phoneNumber != null && phoneNumber.trim().isNotEmpty) {
      final cleanPhone = phoneNumber.replaceAll(RegExp(r'\D'), '');
      uri = Uri.parse("whatsapp://send?phone=$cleanPhone&text=$encodedText");
    } else {
      uri = Uri.parse("whatsapp://send?text=$encodedText");
    }

    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        // Fallback to web WhatsApp link
        final webUri = Uri.parse("https://wa.me/?text=$encodedText");
        if (await canLaunchUrl(webUri)) {
          await launchUrl(webUri, mode: LaunchMode.externalApplication);
        } else {
          Helpers.showSnackBar(
            msg: "WhatsApp is not installed on this device",
            title: "Cannot Share",
            bgColor: Colors.orange,
          );
        }
      }
    } catch (e) {
      Helpers.showSnackBar(
        msg: "Failed to open WhatsApp: $e",
        title: "Error",
        bgColor: Colors.red,
      );
    }
  }
}
