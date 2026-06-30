import 'package:http/http.dart' as http;
import '../../utils/app_constants.dart';
import '../source/network/api_client.dart';

class SendMoneyRepo {
  static Future<http.Response> sendMoneyList({
    required int page,
    required String email,
    required String utr,
    required String created_at,
  }) async => await ApiClient.get(
    ENDPOINT_URL:
        AppConstants.sendMoneyList +
        "?page=$page&email=$email&utr=$utr&created_at=$created_at",
  );

  static Future<http.Response> getsendMoney() async =>
      await ApiClient.get(ENDPOINT_URL: AppConstants.sendMoney);

  static Future<http.Response> sendMoneyPreview({required String utr}) async =>
      await ApiClient.get(
        ENDPOINT_URL: AppConstants.sendMoneyPreview + "/$utr",
      );

  static Future<http.Response> checkRedeemAmount({
    required Map<String, dynamic> data,
  }) async => await ApiClient.post(
    ENDPOINT_URL: AppConstants.checkRedeemAmount,
    fields: data,
  );

  static Future<http.Response> submitSendMoney({
    required Map<String, dynamic> data,
  }) async => await ApiClient.post(
    ENDPOINT_URL: AppConstants.submitSendMoney,
    fields: data,
  );

  static Future<http.Response> checkRecipient({
    required String recipient,
  }) async => await ApiClient.post(
    ENDPOINT_URL: AppConstants.checkRecipient,
    fields: {'recipient': recipient},
  );

  static Future<http.Response> sendMoneyConfirm({
    required Map<String, dynamic> data,
  }) async => await ApiClient.post(
    ENDPOINT_URL: AppConstants.sendMoneyConfirm,
    fields: data,
  );
}
