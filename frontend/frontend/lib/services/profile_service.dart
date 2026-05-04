import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/app_config.dart';
import 'auth_storage.dart';

class ProfileApi {
  final AppConfig _config = AppConfig.instance;
  final AuthStorage _storage = AuthStorage();

  String get baseUrl => _config.serverUrl;

  Future<Map<String, String>> _headers() async {
    final token = _config.token ?? await _storage.getToken();
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  Future<Map<String, dynamic>> getProfile() async {
    final res = await http.get(
      Uri.parse('$baseUrl/api/profile'),
      headers: await _headers(),
    );

    if (res.statusCode != 200) {
      throw Exception('Error fetching profile: ${res.body}');
    }

    return jsonDecode(res.body);
  }

  Future<Map<String, dynamic>> updateProfile({
    String? name,
    String? avatar,
  }) async {
    final body = <String, dynamic>{};
    if (name != null) body['name'] = name;
    if (avatar != null) body['avatar'] = avatar;

    final res = await http.put(
      Uri.parse('$baseUrl/api/profile'),
      headers: await _headers(),
      body: jsonEncode(body),
    );

    if (res.statusCode != 200) {
      throw Exception('Error updating profile: ${res.body}');
    }

    return jsonDecode(res.body);
  }

  Future<Map<String, dynamic>> getProfileStats() async {
    final res = await http.get(
      Uri.parse('$baseUrl/api/profile/stats'),
      headers: await _headers(),
    );

    if (res.statusCode != 200) {
      throw Exception('Error fetching stats: ${res.body}');
    }

    return jsonDecode(res.body);
  }
}
