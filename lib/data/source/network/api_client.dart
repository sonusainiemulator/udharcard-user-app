import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:http/http.dart';
import '../../../../../utils/app_constants.dart';
import '../../../../../utils/services/localstorage/hive.dart';
import '../../../../../utils/services/localstorage/keys.dart';
import '../errors/api_error.dart';

class ApiClient {
  static String _BASE_URL = AppConstants.baseUrl;
  static const int _TIMEOUT_DURATION = 35; // 35 seconds

  static Map<String, String> _getHeaders() => <String, String>{
        'Accept': 'application/json',
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${HiveHelp.read(Keys.token) ?? ''}',
      };

  static Future<http.Response> _request(
      {required String method,
      required String ENDPOINT_URL,
      Map<String, dynamic>? body,
      Map<String, String>? headers}) async {
    Response? response;
    try {
      final uri = Uri.parse(_BASE_URL + ENDPOINT_URL);
      final request = http.Request(method, uri);
      request.headers.addAll(headers ?? _getHeaders());

      if (body != null) {
        request.body = json.encode(body);
      }

      final streamedResponse =
          await request.send().timeout(Duration(seconds: _TIMEOUT_DURATION));
      response = await http.Response.fromStream(streamedResponse);
      return await ApiResponse.processResponse(response);
    } catch (E) {
      return ApiResponse.handleException(
          E, response == null ? 999 : response.statusCode);
    }
  }

  static Future<http.Response> get({required String ENDPOINT_URL}) =>
      _request(method: 'GET', ENDPOINT_URL: ENDPOINT_URL);

  static Future<http.Response> post(
          {required String ENDPOINT_URL, Map<String, dynamic>? fields}) =>
      _request(method: 'POST', ENDPOINT_URL: ENDPOINT_URL, body: fields);

  static Future<http.Response> patch(
          {required String ENDPOINT_URL, Map<String, dynamic>? fields}) =>
      _request(method: 'PATCH', ENDPOINT_URL: ENDPOINT_URL, body: fields);

  static Future<http.Response> put(
          {required String ENDPOINT_URL, Map<String, dynamic>? fields}) =>
      _request(method: 'PUT', ENDPOINT_URL: ENDPOINT_URL, body: fields);

  static Future<http.Response> delete({required String ENDPOINT_URL}) =>
      _request(method: 'DELETE', ENDPOINT_URL: ENDPOINT_URL);

  static Future<http.Response> postMultipart(
      {required String ENDPOINT_URL,
      Map<String, String>? fields,
      MultipartFile? files,
      Iterable<MultipartFile>? fileList}) async {
    Response? response;
    try {
      MultipartRequest request =
          http.MultipartRequest('POST', Uri.parse(_BASE_URL + ENDPOINT_URL));
      request.headers.addAll(_getHeaders());
      if (fields != null) {
        request.fields.addAll(fields);
      }

      if (files != null) {
        request.files.add(files);
      }

      if (fileList != null && fileList.isNotEmpty) {
        request.files.addAll(fileList);
      }

      http.StreamedResponse streamedResponse =
          await request.send().timeout(Duration(seconds: _TIMEOUT_DURATION));
      response = await http.Response.fromStream(streamedResponse);
      return await ApiResponse.processResponse(response);
    } catch (E) {
      return ApiResponse.handleException(
          E, response == null ? 999 : response.statusCode);
    }
  }
}
