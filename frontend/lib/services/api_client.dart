import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/app_config.dart';
import 'auth_storage.dart';

class ApiClient {
  final AppConfig _config = AppConfig.instance;
  final AuthStorage _storage = AuthStorage();

  String get baseUrl => _config.serverUrl;

  Future<Map<String, String>> _headers({bool auth = true}) async {
    final headers = {'Content-Type': 'application/json'};
    if (auth) {
      final token = _config.token ?? await _storage.getToken();
      if (token != null) headers['Authorization'] = 'Bearer $token';
    }
    return headers;
  }

  dynamic _handleResponse(http.Response res, {int? expectedStatus}) {
    dynamic data;
    try {
      data = jsonDecode(res.body);
    } catch (_) {
      data = null;
    }

    final errorMsg = data is Map
        ? (data['error'] as String? ?? 'Request failed')
        : 'Request failed';

    if (expectedStatus != null && res.statusCode != expectedStatus) {
      throw Exception(errorMsg);
    }
    if (res.statusCode < 200 || res.statusCode >= 300) {
      throw Exception(errorMsg);
    }

    return data;
  }

  Future<dynamic> get(String path,
      {Map<String, String>? queryParams,
      bool auth = true,
      int? expectedStatus}) async {
    var uri = Uri.parse('$baseUrl$path');
    if (queryParams != null) uri = uri.replace(queryParameters: queryParams);
    final res = await http.get(uri, headers: await _headers(auth: auth));
    return _handleResponse(res, expectedStatus: expectedStatus);
  }

  Future<dynamic> post(String path,
      {Map<String, dynamic>? body,
      bool auth = true,
      int? expectedStatus}) async {
    final res = await http.post(
      Uri.parse('$baseUrl$path'),
      headers: await _headers(auth: auth),
      body: body != null ? jsonEncode(body) : null,
    );
    return _handleResponse(res, expectedStatus: expectedStatus);
  }

  Future<dynamic> put(String path,
      {Map<String, dynamic>? body,
      bool auth = true,
      int? expectedStatus}) async {
    final res = await http.put(
      Uri.parse('$baseUrl$path'),
      headers: await _headers(auth: auth),
      body: body != null ? jsonEncode(body) : null,
    );
    return _handleResponse(res, expectedStatus: expectedStatus);
  }

  Future<dynamic> delete(String path,
      {bool auth = true, int? expectedStatus}) async {
    final res = await http.delete(
      Uri.parse('$baseUrl$path'),
      headers: await _headers(auth: auth),
    );
    return _handleResponse(res, expectedStatus: expectedStatus);
  }
}
