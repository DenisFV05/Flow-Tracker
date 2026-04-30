import 'dart:convert';
import 'package:http/http.dart' as http;
import 'auth_storage.dart';

class FeedApi {
  final String baseUrl;
  final AuthStorage _storage = AuthStorage();

  FeedApi(this.baseUrl);

  Future<Map<String, String>> _headers() async {
    final token = await _storage.getToken();
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  // Get feed posts with pagination
  Future<Map<String, dynamic>> getFeed({String? cursor, int limit = 20}) async {
    final queryParams = <String, String>{
      'limit': limit.toString(),
      if (cursor != null) 'cursor': cursor,
    };

    final uri = Uri.parse('$baseUrl/api/feed').replace(queryParameters: queryParams);
    final res = await http.get(uri, headers: await _headers());

    if (res.statusCode != 200) {
      throw Exception('Error fetching feed: ${res.body}');
    }

    final data = jsonDecode(res.body);
    return {
      'posts': data['posts'] as List<dynamic>,
      'nextCursor': data['nextCursor'],
    };
  }

  // Create manual post
  Future<void> createPost(String content) async {
    final res = await http.post(
      Uri.parse('$baseUrl/api/feed'),
      headers: await _headers(),
      body: jsonEncode({'content': content}),
    );

    if (res.statusCode != 201) {
      throw Exception('Error creating post: ${res.body}');
    }
  }

  // Like a post
  Future<void> likePost(String postId) async {
    final res = await http.post(
      Uri.parse('$baseUrl/api/feed/$postId/like'),
      headers: await _headers(),
    );

    if (res.statusCode != 201) {
      throw Exception('Error liking post: ${res.body}');
    }
  }

  // Unlike a post
  Future<void> unlikePost(String postId) async {
    final res = await http.delete(
      Uri.parse('$baseUrl/api/feed/$postId/like'),
      headers: await _headers(),
    );

    if (res.statusCode != 200) {
      throw Exception('Error removing like: ${res.body}');
    }
  }

  // Get likes for a post
  Future<List<dynamic>> getLikes(String postId) async {
    final res = await http.get(
      Uri.parse('$baseUrl/api/feed/$postId/likes'),
      headers: await _headers(),
    );

    if (res.statusCode != 200) {
      throw Exception('Error fetching likes: ${res.body}');
    }

    return jsonDecode(res.body);
  }
}
