import 'package:http/http.dart' as http;
import '../../utils/app_constants.dart';
import '../source/network/api_client.dart';

class InvoiceRepo {
  static Future<http.Response> getInvoiceCreate() async =>
      await ApiClient.get(ENDPOINT_URL: AppConstants.invoiceCreate);

  static Future<http.Response> getInvoiceView({required String id}) async =>
      await ApiClient.get(ENDPOINT_URL: AppConstants.invoiceView + "/$id");

  static Future<http.Response> invoiceStore(
          {required Map<String, dynamic> data}) async =>
      await ApiClient.post(
          ENDPOINT_URL: AppConstants.invoiceStore, fields: data);

  static Future<http.Response> invoiceReminder(
          {required Map<String, dynamic> data}) async =>
      await ApiClient.post(
          ENDPOINT_URL: AppConstants.invoiceReminder, fields: data);

  static Future<http.Response> getInvoiceList({
    required int page,
    required String email,
    required String currency_id,
    required String created_at,
    required String status,
  }) async =>
      await ApiClient.get(
          ENDPOINT_URL: AppConstants.invoiceList +
              "?page=$page&email=$email&currency_id=$currency_id&created_at=$created_at&status=$status");
}
