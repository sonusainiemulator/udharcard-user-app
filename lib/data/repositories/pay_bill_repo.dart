import 'package:http/http.dart' as http;
import '../../utils/app_constants.dart';
import '../source/network/api_client.dart';

class PayBillRepo {
  static Future<http.Response> getPayBillList({
    required int page,
    required String type,
    required String category_name,
    required String created_at,
    required String status,
  }) async =>
      await ApiClient.get(
          ENDPOINT_URL: AppConstants.payBillList +
              "?page=$page&status=$status&category_name=$category_name&created_at=$created_at&status=$status");

  static Future<http.Response> getPayBill() async =>
      await ApiClient.get(ENDPOINT_URL: AppConstants.payBill);

  static Future<http.Response> getPayBillPreview({required String utr}) async =>
      await ApiClient.get(ENDPOINT_URL: AppConstants.payBillPreview + "/$utr");

  static Future<http.Response> submitPayBill(
          {Map<String, dynamic>? fields}) async =>
      await ApiClient.post(
          ENDPOINT_URL: AppConstants.submitPayBill, fields: fields);

  static Future<http.Response> payBillPreviewSubmit(
          {Map<String, dynamic>? fields}) async =>
      await ApiClient.post(
          ENDPOINT_URL: AppConstants.payBillPreviewSubmit, fields: fields);
}
