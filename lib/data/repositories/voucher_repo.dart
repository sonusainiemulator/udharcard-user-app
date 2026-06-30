import 'package:http/http.dart' as http;
import '../../utils/app_constants.dart';
import '../source/network/api_client.dart';

class VoucherRepo {
  static Future<http.Response> getVoucherList({
    required int page,
    required String email,
    required String utr,
    required String created_at,
    required String status,
  }) async =>
      await ApiClient.get(
          ENDPOINT_URL: AppConstants.getVoucherList +
              "?page=$page&email=$email&utr=$utr&created_at=$created_at&status=$status");

  static Future<http.Response> getVoucher() async =>
      await ApiClient.get(ENDPOINT_URL: AppConstants.getVoucher);

  static Future<http.Response> voucherSubmit(
          {required Map<String, dynamic> data}) async =>
      await ApiClient.post(
          ENDPOINT_URL: AppConstants.voucherSubmit, fields: data);

  static Future<http.Response> voucherPreview({required String utr}) async =>
      await ApiClient.get(ENDPOINT_URL: AppConstants.voucherPreview + "/$utr");

  static Future<http.Response> voucherPreviewSubmit(
          {required Map<String, dynamic> data}) async =>
      await ApiClient.post(
          ENDPOINT_URL: AppConstants.voucherPreviewSubmit, fields: data);

  static Future<http.Response> voucherPaymentSubmit(
          {required Map<String, dynamic> data}) async =>
      await ApiClient.post(
          ENDPOINT_URL: AppConstants.voucherPaymentSubmit, fields: data);
}
