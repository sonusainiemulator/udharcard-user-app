import 'package:http/http.dart' as http;
import '../../utils/app_constants.dart';
import '../source/network/api_client.dart';

class DisputeRepo {
  static Future<http.Response> getDisputeList({
    required int page,
    required String utr,
    required String created_at,
    required String status,
  }) async =>
      await ApiClient.get(
          ENDPOINT_URL: AppConstants.disputeList +
              "?page=$page&utr=$utr&created_at=$created_at&status=$status");
}
