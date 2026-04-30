import 'dart:convert';
import 'package:http/http.dart' as http;

class AuthService {
  final String baseUrl;

  AuthService(this.baseUrl);

  Future<String> login(String email, String password) async {
    final url = Uri.parse('$baseUrl/api/auth/login');

    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'email': email,
        'password': password,
      }),
    );

    print('STATUS: ${response.statusCode}');
    print('BODY: ${response.body}');

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
