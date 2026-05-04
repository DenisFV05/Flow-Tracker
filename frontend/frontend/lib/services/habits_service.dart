import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/app_config.dart';
import 'auth_storage.dart';

class HabitsApi {
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

  Future<List<dynamic>> getHabits() async {
    final res = await http.get(
      Uri.parse('$baseUrl/api/habits'),
      headers: await _headers(),
    );

    if (res.statusCode != 200) {
      throw Exception('Error fetching habits (${res.statusCode}): ${res.body}');
    }

    return jsonDecode(res.body);
  }

  Future<Map<String, dynamic>> createHabit(
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

    if (res.statusCode != 201) {
      throw Exception('Error creating habit (${res.statusCode}): ${res.body}');
    }

    return jsonDecode(res.body);
  }

  Future<Map<String, dynamic>> updateHabit(
    String id,
    String name,
    String description,
    List<String> tags,
  ) async {
    final res = await http.put(
      Uri.parse('$baseUrl/api/habits/$id'),
      headers: await _headers(),
      body: jsonEncode({
        "name": name,
        "description": description,
        "tags": tags,
      }),
    );

    if (res.statusCode < 200 || res.statusCode >= 300) {
      throw Exception('Error updating habit (${res.statusCode}): ${res.body}');
    }

    return jsonDecode(res.body);
  }

  Future<void> deleteHabit(String id) async {
    final res = await http.delete(
      Uri.parse('$baseUrl/api/habits/$id'),
      headers: await _headers(),
    );

    if (res.statusCode < 200 || res.statusCode >= 300) {
      throw Exception('Error deleting habit (${res.statusCode}): ${res.body}');
    }
  }

  Future<Map<String, dynamic>> toggleHabit(String id, bool completed) async {
    final res = await http.post(
      Uri.parse('$baseUrl/api/habits/$id/log'),
      headers: await _headers(),
      body: jsonEncode({
        "date": DateTime.now().toIso8601String(),
        "completed": completed,
      }),
    );

    if (res.statusCode != 200 && res.statusCode != 201) {
      throw Exception('Error logging habit (${res.statusCode}): ${res.body}');
    }

    return jsonDecode(res.body);
  }

  Future<Map<String, dynamic>> logHabit(String id, String date, bool completed) async {
    final res = await http.post(
      Uri.parse('$baseUrl/api/habits/$id/log'),
      headers: await _headers(),
      body: jsonEncode({
        "date": date,
        "completed": completed,
      }),
    );

    if (res.statusCode != 200 && res.statusCode != 201) {
      throw Exception('Error logging habit (${res.statusCode}): ${res.body}');
    }

    return jsonDecode(res.body);
  }

  Future<Map<String, dynamic>> getHabitStats(String id) async {
    final res = await http.get(
      Uri.parse('$baseUrl/api/habits/$id/stats'),
      headers: await _headers(),
    );

    if (res.statusCode != 200) {
      throw Exception('Error fetching habit stats (${res.statusCode}): ${res.body}');
    }

    return jsonDecode(res.body);
  }

  Future<Map<String, dynamic>> getProfileStats() async {
    final res = await http.get(
      Uri.parse('$baseUrl/api/profile/stats'),
      headers: await _headers(),
    );

    if (res.statusCode != 200) {
      throw Exception('Error fetching profile stats (${res.statusCode}): ${res.body}');
    }

    return jsonDecode(res.body);
  }

  Future<Map<String, dynamic>> getHabitHeatmap(String id, {int? year}) async {
    final queryParams = <String, String>{
      if (year != null) 'year': year.toString(),
    };

    final uri = Uri.parse('$baseUrl/api/habits/$id/heatmap')
        .replace(queryParameters: queryParams);

    final res = await http.get(uri, headers: await _headers());

    if (res.statusCode != 200) {
      throw Exception('Error fetching heatmap (${res.statusCode}): ${res.body}');
    }

    return jsonDecode(res.body);
  }

  Future<Map<String, dynamic>> getHabitWeekly(String id) async {
    final res = await http.get(
      Uri.parse('$baseUrl/api/habits/$id/weekly'),
      headers: await _headers(),
    );

    if (res.statusCode != 200) {
      throw Exception('Error fetching weekly data (${res.statusCode}): ${res.body}');
    }

    return jsonDecode(res.body);
  }

  Future<Map<String, dynamic>> getHabitMonthly(String id) async {
    final res = await http.get(
      Uri.parse('$baseUrl/api/habits/$id/monthly'),
      headers: await _headers(),
    );

    if (res.statusCode != 200) {
      throw Exception('Error fetching monthly data (${res.statusCode}): ${res.body}');
    }

    return jsonDecode(res.body);
  }
}
