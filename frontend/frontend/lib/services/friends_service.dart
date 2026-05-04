import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/app_config.dart';
import 'auth_storage.dart';

class FriendsApi {
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

  Future<List<dynamic>> getFriends() async {
    final headers = await _headers();
    final uri = Uri.parse('$baseUrl/api/friends');
    print('[FRIENDS] Requesting: $uri');
    final res = await http.get(uri, headers: headers);
    print('[FRIENDS] Status: ${res.statusCode}');

    if (res.statusCode != 200) {
      throw Exception('Error fetching friends (${res.statusCode}): ${res.body}');
    }

    final data = jsonDecode(res.body);
    print('[FRIENDS] Friends count: ${data.length}');
    return data;
  }

  Future<List<dynamic>> searchUsers(String query) async {
    final res = await http.get(
      Uri.parse('$baseUrl/api/friends/search?q=$query'),
      headers: await _headers(),
    );

    if (res.statusCode != 200) {
      throw Exception('Error searching users: ${res.body}');
    }

    return jsonDecode(res.body);
  }

  Future<void> sendRequest(String username) async {
    final res = await http.post(
      Uri.parse('$baseUrl/api/friends/request'),
      headers: await _headers(),
      body: jsonEncode({'username': username}),
    );

    if (res.statusCode != 201) {
      throw Exception('Error sending request: ${res.body}');
    }
  }

  Future<List<dynamic>> getRequests() async {
    final res = await http.get(
      Uri.parse('$baseUrl/api/friends/requests'),
      headers: await _headers(),
    );

    if (res.statusCode != 200) {
      throw Exception('Error fetching requests (${res.statusCode}): ${res.body}');
    }

    return jsonDecode(res.body);
  }

  Future<void> respondRequest(String id, String action) async {
    final res = await http.put(
      Uri.parse('$baseUrl/api/friends/request/$id'),
      headers: await _headers(),
      body: jsonEncode({'action': action}),
    );

    if (res.statusCode != 200) {
      throw Exception('Error responding to request: ${res.body}');
    }
  }

  Future<void> removeFriend(String id) async {
    final res = await http.delete(
      Uri.parse('$baseUrl/api/friends/$id'),
      headers: await _headers(),
    );

    if (res.statusCode != 200) {
      throw Exception('Error removing friend: ${res.body}');
    }
  }

  Future<Map<String, dynamic>> getFriendProfile(String friendId) async {
    final uri = Uri.parse('$baseUrl/api/profile/$friendId');
    print('[FRIEND PROFILE] Requesting: $uri');
    final res = await http.get(uri, headers: await _headers());
    print('[FRIEND PROFILE] Status: ${res.statusCode}');
    print('[FRIEND PROFILE] Body: ${res.body.substring(0, res.body.length > 200 ? 200 : res.body.length)}');

    if (res.statusCode != 200) {
      final body = jsonDecode(res.body);
      throw Exception(body['error'] ?? 'Error fetching friend profile (${res.statusCode})');
    }

    return jsonDecode(res.body);
  }
}
