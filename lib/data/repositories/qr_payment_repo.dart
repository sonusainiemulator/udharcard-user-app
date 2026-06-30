import 'package:http/http.dart' as http;
import '../../utils/app_constants.dart';
import '../source/network/api_client.dart';

class QRPaymentRepo {
  static Future<http.Response> getQrPaymentList({
    required int page,
    required String gateway,
    required String email,
    required String datetrx,
  }) async =>
      await ApiClient.get(
          ENDPOINT_URL: AppConstants.qrPaymentList +
              "?page=$page&gateway=$gateway&email=$email&datetrx=$datetrx");
}
