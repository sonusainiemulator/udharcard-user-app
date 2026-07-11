import 'package:http/http.dart' as http;
import '../../utils/app_constants.dart';
import '../source/network/api_client.dart';

class CustomerUdharRepo {
  static Future<http.Response> getMerchantsList() async =>
      await ApiClient.get(ENDPOINT_URL: AppConstants.customerUdharMerchantsUrl);

  static Future<http.Response> getLedgerList({
    required int merchantId,
    required int page,
  }) async =>
      await ApiClient.get(
        ENDPOINT_URL: "${AppConstants.customerUdharLedgerUrl}/$merchantId?page=$page",
      );

  static Future<http.Response> verifyLedgerEntry({
    required int ledgerId,
    required String status,
    String? notes,
  }) async =>
      await ApiClient.post(
        ENDPOINT_URL: "${AppConstants.customerUdharVerifyUrl}/$ledgerId",
        fields: {
          'status': status,
          if (notes != null) 'notes': notes,
        },
      );
}
