import 'package:http/http.dart' as http;
import 'package:http/http.dart';
import '../../utils/app_constants.dart';
import '../source/network/api_client.dart';

class CardRepo {
  static Future<http.Response> getVirtualCards() async =>
      await ApiClient.get(ENDPOINT_URL: AppConstants.virtualCardsUrl);

  static Future<http.Response> cardOrder() async =>
      await ApiClient.get(ENDPOINT_URL: AppConstants.cardOrderForm);

  static Future<http.Response> cardTransaction(
          {required String id, required String page}) async =>
      await ApiClient.get(
          ENDPOINT_URL:
              AppConstants.cardTransaction + "?page=$page" + "&card_id=$id");

  static Future<http.Response> cardOrderSubmit(
          {required Iterable<MultipartFile>? fileList,
          required Map<String, String> fields}) async =>
      await ApiClient.postMultipart(
          ENDPOINT_URL: AppConstants.cardOrderFormSubmit,
          fields: fields,
          fileList: fileList);

  static Future<http.Response> cardOrderReSubmit(
          {required Iterable<MultipartFile>? fileList,
          required Map<String, String> fields}) async =>
      await ApiClient.postMultipart(
          ENDPOINT_URL: AppConstants.cardOrderFormReSubmit,
          fields: fields,
          fileList: fileList);
  
  static Future<http.Response> blockCard(
          {required String id, required String reason}) async =>
      await ApiClient.post(
          ENDPOINT_URL: AppConstants.cardBlockUrl,
          fields: {"reason": reason, "id": id});
}