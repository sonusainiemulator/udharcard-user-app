import 'package:http/http.dart' as http;
import '../../utils/app_constants.dart';
import '../source/network/api_client.dart';

class RedeemCodeRepo {
  static Future<http.Response> getRedeemList({
    required int page,
    required String email,
    required String utr,
    required String created_at,
    required String status,
  }) async =>
      await ApiClient.get(
          ENDPOINT_URL: AppConstants.getRedeemList +
              "?page=$page&email=$email&utr=$utr&created_at=$created_at&status=$status");

  static Future<http.Response> getGenerateCode() async =>
      await ApiClient.get(ENDPOINT_URL: AppConstants.getGenerateCode);

  static Future<http.Response> generateCodePreview(
          {required String utr}) async =>
      await ApiClient.get(
          ENDPOINT_URL: AppConstants.generateCodePreview + "/$utr");

  static Future<http.Response> checkRedeemAmount(
          {required Map<String, dynamic> data}) async =>
      await ApiClient.post(
          ENDPOINT_URL: AppConstants.checkRedeemAmount, fields: data);
          


  static Future<http.Response> generateCodeSubmit(
          {required Map<String, dynamic> data}) async =>
      await ApiClient.post(
          ENDPOINT_URL: AppConstants.generateCodeSubmit, fields: data);

  static Future<http.Response> generateCodeConfirm(
          {required Map<String, dynamic> data}) async =>
      await ApiClient.post(
          ENDPOINT_URL: AppConstants.generateCodeConfirm, fields: data);

  static Future<http.Response> insertRedeemCode(
          {required Map<String, dynamic> data}) async =>
      await ApiClient.post(
          ENDPOINT_URL: AppConstants.insertRedeemCode, fields: data);
}
