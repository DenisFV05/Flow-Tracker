import 'dart:convert';
import 'package:http/http.dart' as http;
import 'auth_storage.dart';

class HabitsApi {
  final String baseUrl;
  final AuthStorage _storage = AuthStorage();

  HabitsApi(this.baseUrl);

  // Construye headers incluyendo el token de autenticación si existe
  Future<Map<String, String>> _headers() async {
    final token = await _storage.getToken();

    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  // Obtiene la lista de hábitos del usuario
  Future<List<dynamic>> getHabits() async {
    final res = await http.get(
      Uri.parse('$baseUrl/api/habits'),
      headers: await _headers(),
    );

    if (res.statusCode != 200) {
      throw Exception('Error fetching habits: ${res.body}');
    }

    return jsonDecode(res.body);
  }

  // Crea un nuevo hábito
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

    if (res.statusCode != 201) {
      throw Exception('Error creating habit: ${res.body}');
    }
  }

  // Actualiza un hábito existente
  Future<void> updateHabit(
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
        'tags': tags,

      }),
    );

    if (res.statusCode < 200 || res.statusCode >= 300) {
      throw Exception('Error updating habit: ${res.body}');
    }
  }

  // Elimina un hábito por su id
  Future<void> deleteHabit(String id) async {
    final res = await http.delete(
      Uri.parse('$baseUrl/api/habits/$id'),
      headers: await _headers(),
    );

    if (res.statusCode < 200 || res.statusCode >= 300) {
      throw Exception('Error deleting habit: ${res.body}');
    }
  }

  // Registra o actualiza el estado de completado de un hábito
  Future<void> toggleHabit(String id, bool completed) async {
    final res = await http.post(
      Uri.parse('$baseUrl/api/habits/$id/log'),
      headers: await _headers(),
      body: jsonEncode({
        "date": DateTime.now().toIso8601String(),
        "completed": completed,
      }),
    );

    if (res.statusCode != 200 && res.statusCode != 201) {
      throw Exception('Error logging habit: ${res.body}');
    }
  }

  // Obtiene estadísticas de un hábito concreto
  Future<Map<String, dynamic>> getHabitStats(String id) async {
    final res = await http.get(
      Uri.parse('$baseUrl/api/habits/$id/stats'),
      headers: await _headers(),
    );

    if (res.statusCode != 200) {
      throw Exception('Error fetching habit stats: ${res.body}');
    }

    return jsonDecode(res.body);
  }

  // Obtiene estadísticas generales del perfil del usuario
  Future<Map<String, dynamic>> getProfileStats() async {
    final res = await http.get(
      Uri.parse('$baseUrl/api/profile/stats'),
      headers: await _headers(),
    );

    if (res.statusCode != 200) {
      throw Exception('Error fetching profile stats: ${res.body}');
    }

    return jsonDecode(res.body);
  }

  // Obtiene el heatmap de un hábito para un año
  Future<Map<String, dynamic>> getHabitHeatmap(String id, {int? year}) async {
    final queryParams = <String, String>{
      if (year != null) 'year': year.toString(),
    };

    final uri = Uri.parse('$baseUrl/api/habits/$id/heatmap')
        .replace(queryParameters: queryParams);

    final res = await http.get(uri, headers: await _headers());

    if (res.statusCode != 200) {
      throw Exception('Error fetching heatmap: ${res.body}');
    }

    return jsonDecode(res.body);
  }

  // Obtiene datos semanales de un hábito
  Future<Map<String, dynamic>> getHabitWeekly(String id) async {
    final res = await http.get(
      Uri.parse('$baseUrl/api/habits/$id/weekly'),
      headers: await _headers(),
    );

    if (res.statusCode != 200) {
      throw Exception('Error fetching weekly data: ${res.body}');
    }

    return jsonDecode(res.body);
  }

  // Obtiene datos mensuales de un hábito
  Future<Map<String, dynamic>> getHabitMonthly(String id) async {
    final res = await http.get(
      Uri.parse('$baseUrl/api/habits/$id/monthly'),
      headers: await _headers(),
    );

    if (res.statusCode != 200) {
      throw Exception('Error fetching monthly data: ${res.body}');
    }

    return jsonDecode(res.body);
  }
}
