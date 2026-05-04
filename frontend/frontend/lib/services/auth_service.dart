import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/app_config.dart';
import 'auth_storage.dart';

class AuthService {
  final AppConfig _config = AppConfig.instance;
  final AuthStorage _storage = AuthStorage();

  String get baseUrl => _config.serverUrl;

  Future<String?> get _token async {
    return _config.token ?? await _storage.getToken();
  }

  Future<Map<String, String>> _headers({bool requireAuth = false}) async {
    final headers = {'Content-Type': 'application/json'};
    final token = await _token;
    if (token != null) {
      headers['Authorization'] = 'Bearer $token';
    }
    return headers;
  }

  Future<String> login(String email, String password) async {
    final url = Uri.parse('$baseUrl/api/auth/login');

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'email': email,
        'password': password,
      }),
    );

    final data = jsonDecode(response.body);

    if (response.statusCode == 200) {
      final token = data['token'];
      if (token == null) {
        throw Exception('Token no recibido');
      }
      return token;
    } else {
      throw Exception(data['error'] ?? 'Error login');
    }
  }

  Future<String> register(
    String email,
    String password,
    String name,
    String username,
  ) async {
    final url = Uri.parse('$baseUrl/api/auth/register');

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'email': email,
        'password': password,
        'name': name,
        'username': username,
      }),
    );

    final data = jsonDecode(response.body);

    if (response.statusCode != 201) {
      throw Exception(data['error'] ?? 'Error register');
    }

    return data['id'];
  }
}
