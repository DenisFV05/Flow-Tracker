import 'dart:convert';
import 'package:http/http.dart' as http;
import 'auth_storage.dart';

class FriendsApi {
  final String baseUrl;
  final AuthStorage _storage = AuthStorage();

  FriendsApi(this.baseUrl);

  Future<Map<String, String>> _headers() async {
    final token = await _storage.getToken();
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  // Get friends list
  Future<List<dynamic>> getFriends() async {
    final res = await http.get(
      Uri.parse('$baseUrl/api/friends'),
      headers: await _headers(),
    );

    if (res.statusCode != 200) {
      throw Exception('Error fetching friends: ${res.body}');
    }

    return jsonDecode(res.body);
  }

  // Search users
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

  // Send friend request
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

  // Get pending requests
  Future<List<dynamic>> getRequests() async {
    final res = await http.get(
      Uri.parse('$baseUrl/api/friends/requests'),
      headers: await _headers(),
    );

    if (res.statusCode != 200) {
      throw Exception('Error fetching requests: ${res.body}');
    }

    return jsonDecode(res.body);
  }

  // Respond to friend request (accept/reject)
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

  // Remove friend
  Future<void> removeFriend(String id) async {
    final res = await http.delete(
      Uri.parse('$baseUrl/api/friends/$id'),
      headers: await _headers(),
    );

    if (res.statusCode != 200) {
      throw Exception('Error removing friend: ${res.body}');
    }
  }
}
