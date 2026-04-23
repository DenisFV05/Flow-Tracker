import 'dart:convert';
import 'package:http/http.dart' as http;
import 'auth_storage.dart';

class HabitsApi {
  final String baseUrl;
  final AuthStorage _storage = AuthStorage();

  HabitsApi(this.baseUrl);

  // -------------------------
  // 🔐 HEADERS CON TOKEN
  // -------------------------
  Future<Map<String, String>> _headers() async {
    final token = await _storage.getToken();

    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  // -------------------------
  // 📥 GET HABITS
  // -------------------------
  Future<List<dynamic>> getHabits() async {
    final res = await http.get(
      Uri.parse('$baseUrl/api/habits'),
      headers: await _headers(),
    );

    print('STATUS GET HABITS: ${res.statusCode}');
    print('BODY: ${res.body}');

    if (res.statusCode != 200) {
      throw Exception('Error fetching habits: ${res.body}');
    }

    return jsonDecode(res.body);
  }

  // -------------------------
  // ➕ CREATE HABIT
  // -------------------------
  Future<void> createHabit(
    String name,
    String description,
    List<String> tags,
  ) async {
    final res = await http.post(
      Uri.parse('$baseUrl/api/habits'),
      headers: await _headers(),
      body: jsonEncode({
        "name": name,
        "description": description,
        "tags": tags,
      }),
    );

    print('STATUS CREATE: ${res.statusCode}');
    print('BODY: ${res.body}');

    if (res.statusCode != 201) {
      throw Exception('Error creating habit: ${res.body}');
    }
  }

  // -------------------------
  // 📝 UPDATE HABIT
  // -------------------------
  Future<void> updateHabit(
    String id,
    String name,
    String description,
  ) async {
    final res = await http.put(
      Uri.parse('$baseUrl/api/habits/$id'),
      headers: await _headers(),
      body: jsonEncode({
        "name": name,
        "description": description,
      }),
    );

    if (res.statusCode != 200) {
      throw Exception('Error updating habit: ${res.body}');
    }
  }

  // -------------------------
  // ❌ DELETE HABIT
  // -------------------------
  Future<void> deleteHabit(String id) async {
    final res = await http.delete(
      Uri.parse('$baseUrl/api/habits/$id'),
      headers: await _headers(),
    );

    if (res.statusCode != 200) {
      throw Exception('Error deleting habit: ${res.body}');
    }
  }

  // -------------------------
  // 📌 TOGGLE / LOG HABIT
  // -------------------------
  Future<void> toggleHabit(String id, bool completed) async {
    final res = await http.post(
      Uri.parse('$baseUrl/api/habits/$id/log'),
      headers: await _headers(),
      body: jsonEncode({
        "date": DateTime.now().toIso8601String(),
        "completed": completed,
      }),
    );

    if (res.statusCode != 200) {
      throw Exception('Error logging habit: ${res.body}');
    }
  }

  // -------------------------
  // 📊 STATS HABIT
  // -------------------------
  Future<Map<String, dynamic>> getStats(String id) async {
    final res = await http.get(
      Uri.parse('$baseUrl/api/habits/$id/stats'),
      headers: await _headers(),
    );

    if (res.statusCode != 200) {
      throw Exception('Error fetching stats: ${res.body}');
    }

    return jsonDecode(res.body);
  }
}
