import 'api_client.dart';

class AuthService {
  final ApiClient _client = ApiClient();

  Future<String> login(String email, String password) async {
    final data = await _client.post('/api/auth/login',
        body: {'email': email, 'password': password}, auth: false);

    final token = data['token'] as String?;
    if (token == null) {
      throw Exception('Token no recibido');
    }
    return token;
  }

  Future<String> register(
    String email,
    String password,
    String name,
    String username,
  ) async {
    final data = await _client.post('/api/auth/register',
        body: {
          'email': email,
          'password': password,
          'name': name,
          'username': username
        },
        auth: false,
        expectedStatus: 201);

    return data['id'] as String;
  }
}
