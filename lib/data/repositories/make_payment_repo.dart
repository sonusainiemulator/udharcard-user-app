import 'package:http/http.dart' as http;
import '../../utils/app_constants.dart';
import '../source/network/api_client.dart';

class MakePaymentRepo {
  static Future<http.Response> getsendMoney() async =>
      await ApiClient.get(ENDPOINT_URL: AppConstants.sendMoney);

  static Future<http.Response> makePaymentPreview({
    required String utr,
  }) async => await ApiClient.get(
    ENDPOINT_URL: AppConstants.makePaymentPreview + "/$utr",
  );

  static Future<http.Response> makePaymentCheckAmount({
    required Map<String, dynamic> data,
  }) async => await ApiClient.post(
    ENDPOINT_URL: AppConstants.makePaymentCheckAmount,
    fields: data,
  );
  static Future<http.Response> checkMerchant({
    required String merchant,
  }) async => await ApiClient.post(
    ENDPOINT_URL: AppConstants.checkMerchant,
    fields: {'recipient': merchant},
  );

  static Future<http.Response> initMakePayment({
    required Map<String, dynamic> data,
  }) async => await ApiClient.post(
    ENDPOINT_URL: AppConstants.initMakePayment,
    fields: data,
  );

  static Future<http.Response> makePaymentConfirm({
    required Map<String, dynamic> data,
    required String utr,
  }) async => await ApiClient.post(
    ENDPOINT_URL: AppConstants.makePaymentConfirm + "/$utr",
    fields: data,
  );
}
