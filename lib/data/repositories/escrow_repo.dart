import 'package:http/http.dart' as http;
import '../../utils/app_constants.dart';
import '../source/network/api_client.dart';

class EscrowRepo {
  static Future<http.Response> getEscrowList({
    required int page,
    required String email,
    required String utr,
    required String created_at,
    required String status,
  }) async =>
      await ApiClient.get(
          ENDPOINT_URL: AppConstants.getEscrowList +
              "?page=$page&email=$email&utr=$utr&created_at=$created_at&status=$status");

  static Future<http.Response> getEscrow() async =>
      await ApiClient.get(ENDPOINT_URL: AppConstants.getEscrow);

  static Future<http.Response> escrowSubmit(
          {required Map<String, dynamic> data}) async =>
      await ApiClient.post(
          ENDPOINT_URL: AppConstants.escrowSubmit, fields: data);

  static Future<http.Response> escrowPaymentSubmit(
          {required Map<String, dynamic> data}) async =>
      await ApiClient.post(
          ENDPOINT_URL: AppConstants.escrowPaymentSubmit, fields: data);

  static Future<http.Response> escrowPreview({required String utr}) async =>
      await ApiClient.get(ENDPOINT_URL: AppConstants.escrowPreview + "/$utr");

  static Future<http.Response> escrowConfirm(
          {required Map<String, dynamic> data}) async =>
      await ApiClient.post(
          ENDPOINT_URL: AppConstants.escrowConfirm, fields: data);
}
