import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/habit.dart';
import '../models/habit_stats.dart';

class ApiService {
  final String baseUrl;
  final String token;

  ApiService(this.baseUrl, this.token);

  Map<String, String> get _headers => {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      };

  // Auth
  Future<Map<String, dynamic>> getProfile() async {
    final res = await http.get(
      Uri.parse('$baseUrl/api/profile'),
      headers: _headers,
    );
    return jsonDecode(res.body);
  }

  Future<Map<String, dynamic>> updateProfile(String name, String? avatar) async {
    final res = await http.put(
      Uri.parse('$baseUrl/api/profile'),
      headers: _headers,
      body: jsonEncode({'name': name, 'avatar': avatar}),
    );
    return jsonDecode(res.body);
  }

  // Habits
  Future<List<Habit>> getHabits() async {
    final res = await http.get(
      Uri.parse('$baseUrl/api/habits'),
      headers: _headers,
    );
    final List data = jsonDecode(res.body);
    return data.map((h) => Habit.fromJson(h)).toList();
  }

  Future<Habit> createHabit(String name, String? desc, List<String> tags) async {
    final res = await http.post(
      Uri.parse('$baseUrl/api/habits'),
      headers: _headers,
      body: jsonEncode({'name': name, 'description': desc, 'tags': tags}),
    );
    return Habit.fromJson(jsonDecode(res.body));
  }

  Future<Habit> updateHabit(String id, String name, String? desc, List<String> tags) async {
    final res = await http.put(
      Uri.parse('$baseUrl/api/habits/$id'),
      headers: _headers,
      body: jsonEncode({'name': name, 'description': desc, 'tags': tags}),
    );
    return Habit.fromJson(jsonDecode(res.body));
  }

  Future<void> deleteHabit(String id) async {
    await http.delete(
      Uri.parse('$baseUrl/api/habits/$id'),
      headers: _headers,
    );
  }

  Future<void> logHabit(String id, String date, bool completed) async {
    await http.post(
      Uri.parse('$baseUrl/api/habits/$id/log'),
      headers: _headers,
      body: jsonEncode({'date': date, 'completed': completed}),
    );
  }

  Future<List<Map<String, dynamic>>> getHabitLogs(String id, {String? startDate, String? endDate}) async {
    var url = '$baseUrl/api/habits/$id/logs';
    final params = <String>[];
    if (startDate != null) params.add('startDate=$startDate');
    if (endDate != null) params.add('endDate=$endDate');
    if (params.isNotEmpty) url += '?${params.join('&')}';
    
    final res = await http.get(Uri.parse(url), headers: _headers);
    return List<Map<String, dynamic>>.from(jsonDecode(res.body));
  }

  // Stats
  Future<HabitStats> getHabitStats(String id) async {
    final res = await http.get(
      Uri.parse('$baseUrl/api/habits/$id/stats'),
      headers: _headers,
    );
    return HabitStats.fromJson(jsonDecode(res.body));
  }

  Future<Map<String, dynamic>> getHabitHeatmap(String id, {int? year}) async {
    var url = '$baseUrl/api/habits/$id/heatmap';
    if (year != null) url += '?year=$year';
    final res = await http.get(Uri.parse(url), headers: _headers);
    return jsonDecode(res.body);
  }

  Future<Map<String, dynamic>> getHabitWeekly(String id) async {
    final res = await http.get(
      Uri.parse('$baseUrl/api/habits/$id/weekly'),
      headers: _headers,
    );
    return jsonDecode(res.body);
  }

  Future<Map<String, dynamic>> getHabitMonthly(String id) async {
    final res = await http.get(
      Uri.parse('$baseUrl/api/habits/$id/monthly'),
      headers: _headers,
    );
    return jsonDecode(res.body);
  }

  Future<Map<String, dynamic>> getProfileStats() async {
    final res = await http.get(
      Uri.parse('$baseUrl/api/profile/stats'),
      headers: _headers,
    );
    return jsonDecode(res.body);
  }

  // Tags
  Future<List<Map<String, dynamic>>> getTags() async {
    final res = await http.get(
      Uri.parse('$baseUrl/api/tags'),
      headers: _headers,
    );
    return List<Map<String, dynamic>>.from(jsonDecode(res.body));
  }

  Future<Map<String, dynamic>> createTag(String name) async {
    final res = await http.post(
      Uri.parse('$baseUrl/api/tags'),
      headers: _headers,
      body: jsonEncode({'name': name}),
    );
    return jsonDecode(res.body);
  }

  Future<void> deleteTag(String id) async {
    await http.delete(
      Uri.parse('$baseUrl/api/tags/$id'),
      headers: _headers,
    );
  }

  // Friends
  Future<List<Map<String, dynamic>>> searchUsers(String query) async {
    final res = await http.get(
      Uri.parse('$baseUrl/api/friends/search?q=$query'),
      headers: _headers,
    );
    return List<Map<String, dynamic>>.from(jsonDecode(res.body));
  }

  Future<List<Map<String, dynamic>>> getFriends() async {
    final res = await http.get(
      Uri.parse('$baseUrl/api/friends'),
      headers: _headers,
    );
    return List<Map<String, dynamic>>.from(jsonDecode(res.body));
  }

  Future<List<Map<String, dynamic>>> getFriendRequests() async {
    final res = await http.get(
      Uri.parse('$baseUrl/api/friends/requests'),
      headers: _headers,
    );
    return List<Map<String, dynamic>>.from(jsonDecode(res.body));
  }

  Future<void> sendFriendRequest(String username) async {
    await http.post(
      Uri.parse('$baseUrl/api/friends/request'),
      headers: _headers,
      body: jsonEncode({'username': username}),
    );
  }

  Future<void> respondToFriendRequest(String id, String action) async {
    await http.put(
      Uri.parse('$baseUrl/api/friends/request/$id'),
      headers: _headers,
      body: jsonEncode({'action': action}),
    );
  }

  Future<void> removeFriend(String id) async {
    await http.delete(
      Uri.parse('$baseUrl/api/friends/$id'),
      headers: _headers,
    );
  }

  // Feed
  Future<Map<String, dynamic>> getFeed({String? cursor, int limit = 20}) async {
    var url = '$baseUrl/api/feed?limit=$limit';
    if (cursor != null) url += '&cursor=$cursor';
    final res = await http.get(Uri.parse(url), headers: _headers);
    return jsonDecode(res.body);
  }

  Future<Map<String, dynamic>> createPost(String content) async {
    final res = await http.post(
      Uri.parse('$baseUrl/api/feed'),
      headers: _headers,
      body: jsonEncode({'content': content}),
    );
    return jsonDecode(res.body);
  }

  Future<void> likePost(String id) async {
    await http.post(
      Uri.parse('$baseUrl/api/feed/$id/like'),
      headers: _headers,
    );
  }

  Future<void> unlikePost(String id) async {
    await http.delete(
      Uri.parse('$baseUrl/api/feed/$id/like'),
      headers: _headers,
    );
  }
}