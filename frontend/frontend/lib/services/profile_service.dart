import 'api_client.dart';

class ProfileApi {
  final ApiClient _client = ApiClient();

  Future<Map<String, dynamic>> getProfile() async {
    final data = await _client.get('/api/profile', expectedStatus: 200);
    return data as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> updateProfile({
    String? name,
    String? avatar,
  }) async {
    final body = <String, dynamic>{};
    if (name != null) body['name'] = name;
    if (avatar != null) body['avatar'] = avatar;
    final data =
        await _client.put('/api/profile', body: body, expectedStatus: 200);
    return data as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> getProfileStats() async {
    final data = await _client.get('/api/profile/stats', expectedStatus: 200);
    return data as Map<String, dynamic>;
  }
}
