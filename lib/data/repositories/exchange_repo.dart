import 'package:http/http.dart' as http;
import '../../utils/app_constants.dart';
import '../source/network/api_client.dart';

class ExchangeRepo {
  static Future<http.Response> getExchangeMoneyList({
    required int page,
    required String utr,
    required String created_at,
    required String status,
  }) async =>
      await ApiClient.get(
          ENDPOINT_URL: AppConstants.exchangeMoneyList +
              "?page=$page&utr=$utr&created_at=$created_at&status=$status");

  static Future<http.Response> getexchangeMoney() async =>
      await ApiClient.get(ENDPOINT_URL: AppConstants.exchangeMoney);

  static Future<http.Response> submitExchangeMoney(
          {required Map<String, dynamic> data}) async =>
      await ApiClient.post(
          ENDPOINT_URL: AppConstants.submitExchangeMoney, fields: data);

  static Future<http.Response> exchangeMoneyPreview(
          {required String utr}) async =>
      await ApiClient.get(
          ENDPOINT_URL: AppConstants.exchangeMoneyPreview + "/$utr");

  static Future<http.Response> exchangeMoneyConfirm(
          {required Map<String, dynamic> data}) async =>
      await ApiClient.post(
          ENDPOINT_URL: AppConstants.exchangeMoneyConfirm, fields: data);
}
