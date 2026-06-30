import 'package:http/http.dart' as http;
import '../../utils/app_constants.dart';
import '../source/network/api_client.dart';

class RequestRepo {
  static Future<http.Response> getRequestList({
    required int page,
    required String email,
    required String utr,
    required String created_at,
  }) async =>
      await ApiClient.get(
          ENDPOINT_URL: AppConstants.requestMoneyList +
              "?page=$page&email=$email&utr=$utr&created_at=$created_at");

  static Future<http.Response> getSecurityPinManage() async =>
      await ApiClient.get(ENDPOINT_URL: AppConstants.pinManage);

  static Future<http.Response> getRequestMoney() async =>
      await ApiClient.get(ENDPOINT_URL: AppConstants.requestMoney);

  static Future<http.Response> submitRequestMoney(
          {required Map<String, dynamic> data}) async =>
      await ApiClient.post(
          ENDPOINT_URL: AppConstants.requestMoneySubmit, fields: data);

  static Future<http.Response> requestMoneyPreview(
          {required String utr}) async =>
      await ApiClient.get(
          ENDPOINT_URL: AppConstants.requestMoneyPreview + "/$utr");

  static Future<http.Response> requestMoneyConfirm(
          {required Map<String, dynamic> data}) async =>
      await ApiClient.post(
          ENDPOINT_URL: AppConstants.requestMoneyConfirm, fields: data);

  static Future<http.Response> requestMoneyCheckSubmit(
          {required Map<String, dynamic> data}) async =>
      await ApiClient.post(
          ENDPOINT_URL: AppConstants.requestMoneyCheckSubmit, fields: data);

  static Future<http.Response> requestCancel({required String utr}) async =>
      await ApiClient.post(
          ENDPOINT_URL: AppConstants.requestCancel, fields: {"utr": utr});
}
