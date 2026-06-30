import 'package:http/http.dart' as http;
import '../../utils/app_constants.dart';
import '../source/network/api_client.dart';

class CashoutRepo {
  static Future<http.Response> getsendMoney() async =>
      await ApiClient.get(ENDPOINT_URL: AppConstants.sendMoney);

  static Future<http.Response> cashoutPreview({required String utr}) async =>
      await ApiClient.get(ENDPOINT_URL: AppConstants.cashoutPreview + "/$utr");

  static Future<http.Response> cashoutCheckAmount({
    required Map<String, dynamic> data,
  }) async => await ApiClient.post(
    ENDPOINT_URL: AppConstants.cashoutCheckAmount,
    fields: data,
  );
  static Future<http.Response> checkAgent({required String merchant}) async =>
      await ApiClient.post(
        ENDPOINT_URL: AppConstants.checkAgent,
        fields: {'recipient': merchant},
      );

  static Future<http.Response> initCashout({
    required Map<String, dynamic> data,
  }) async => await ApiClient.post(
    ENDPOINT_URL: AppConstants.initCashout,
    fields: data,
  );

  static Future<http.Response> cashoutConfirm({
    required Map<String, dynamic> data,
    required String utr,
  }) async => await ApiClient.post(
    ENDPOINT_URL: AppConstants.cashoutConfirm + "/$utr",
    fields: data,
  );
}
