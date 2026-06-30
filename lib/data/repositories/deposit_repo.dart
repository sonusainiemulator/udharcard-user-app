import 'package:http/http.dart' as http;
import '../../utils/app_constants.dart';
import '../source/network/api_client.dart';

class DepositRepo {
  static Future<http.Response> getDepositList({
    required int page,
    required String transaction_id,
    required String currency,
    required String created_at,
  }) async =>
      await ApiClient.get(
          ENDPOINT_URL: AppConstants.depositListUrl +
              "?page=$page&utr=$transaction_id&currency=$currency&created_at=$created_at");

  static Future<http.Response> getGateways() async =>
      await ApiClient.get(ENDPOINT_URL: AppConstants.gatewaysUrl);

  static Future<http.Response> manualPayment(
          {required String trxid,
          required Iterable<http.MultipartFile>? fileList,
          required Map<String, String> fields}) async =>
      await ApiClient.postMultipart(
          ENDPOINT_URL: AppConstants.manualPaymentUrl + "/$trxid",
          fields: fields,
          fileList: fileList);

  static Future<http.Response> webviewPayment(
          {required Map<String, dynamic> fields}) async =>
      await ApiClient.post(
          ENDPOINT_URL: AppConstants.webviewPayment, fields: fields);

  static Future<http.Response> paymentRequest(
          {required Map<String, dynamic> fields}) async =>
      await ApiClient.post(
          ENDPOINT_URL: AppConstants.paymentRequest, fields: fields);

  static Future<http.Response> cardPayment(
          {required Map<String, String> fields}) async =>
      await ApiClient.post(
          ENDPOINT_URL: AppConstants.cardPayment, fields: fields);

  static Future<http.Response> onPaymentDone(
          {required Map<String, String> fields}) async =>
      await ApiClient.post(
          ENDPOINT_URL: AppConstants.onPaymentDone, fields: fields);

            static Future<http.Response> getChargeAndLimit({required String currency_id, required String transaction_type_id, required String gateway_id}) async =>
      await ApiClient.get(
          ENDPOINT_URL: AppConstants.getChargeAndLimit+"?currency_id=$currency_id&transaction_type_id=$transaction_type_id&gateway_id=$gateway_id");
}
