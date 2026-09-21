import 'dart:convert';

class QrParserHelper {
  /// Extracts the most likely merchant identifier (email, phone, UPI ID, or merchant code)
  /// from a scanned QR payload.
  static String extractMerchantIdentifier(String rawCode) {
    final trimmed = rawCode.trim();
    if (trimmed.isEmpty) return "";

    // 1. Check if it's a JSON payload
    if (trimmed.startsWith('{') && trimmed.endsWith('}')) {
      try {
        final Map<String, dynamic> data = jsonDecode(trimmed);
        if (data.containsKey('merchant')) {
          return data['merchant'].toString();
        }
        if (data.containsKey('merchant_email')) {
          return data['merchant_email'].toString();
        }
        if (data.containsKey('email')) {
          return data['email'].toString();
        }
        if (data.containsKey('phone')) {
          return data['phone'].toString();
        }
        if (data.containsKey('merchant_id')) {
          return data['merchant_id'].toString();
        }
      } catch (_) {
        // Fall through if not valid JSON
      }
    }

    // 2. Check if it's a UPI URL (e.g. upi://pay?pa=store@okaxis&pn=Store)
    if (trimmed.toLowerCase().startsWith('upi://pay')) {
      try {
        final uri = Uri.parse(trimmed);
        final pa = uri.queryParameters['pa'];
        if (pa != null && pa.isNotEmpty) {
          return pa;
        }
      } catch (_) {}
    }

    // 3. Check if it's an HTTP/HTTPS web link (e.g. https://udharcard.shop/pay?merchant=9876543210)
    if (trimmed.toLowerCase().startsWith('http://') ||
        trimmed.toLowerCase().startsWith('https://')) {
      try {
        final uri = Uri.parse(trimmed);
        if (uri.queryParameters.containsKey('merchant')) {
          return uri.queryParameters['merchant']!;
        }
        if (uri.queryParameters.containsKey('phone')) {
          return uri.queryParameters['phone']!;
        }
        if (uri.queryParameters.containsKey('email')) {
          return uri.queryParameters['email']!;
        }
        if (uri.pathSegments.isNotEmpty) {
          return uri.pathSegments.last;
        }
      } catch (_) {}
    }

    // 4. Default: return the trimmed string directly (standard phone or email)
    return trimmed;
  }
}
