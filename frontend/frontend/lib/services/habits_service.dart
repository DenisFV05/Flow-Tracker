import 'api_client.dart';

class HabitsApi {
  final ApiClient _client = ApiClient();

  Future<List<dynamic>> getHabits() async {
    final data = await _client.get('/api/habits', expectedStatus: 200);
    return data as List<dynamic>;
  }

  Future<Map<String, dynamic>> createHabit(
    String name,
    String description,
    List<String> tags,
  ) async {
    final data = await _client.post('/api/habits',
        body: {'name': name, 'description': description, 'tags': tags},
        expectedStatus: 201);
    return data as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> updateHabit(
    String id,
    String name,
    String description,
    List<String> tags,
  ) async {
    final data = await _client.put('/api/habits/$id',
        body: {'name': name, 'description': description, 'tags': tags});
    return data as Map<String, dynamic>;
  }

  Future<void> deleteHabit(String id) async {
    await _client.delete('/api/habits/$id');
  }

  Future<Map<String, dynamic>> toggleHabit(
    String id,
    bool completed,
  ) async {
    final data = await _client.post('/api/habits/$id/log',
        body: {
          'date': DateTime.now().toIso8601String(),
          'completed': completed,
        });
    return data as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> logHabit(
    String id,
    String date,
    bool completed,
  ) async {
    final data = await _client.post('/api/habits/$id/log',
        body: {'date': date, 'completed': completed});
    return data as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> getHabitStats(String id) async {
    final data = await _client.get('/api/habits/$id/stats', expectedStatus: 200);
    return data as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> getProfileStats() async {
    final data = await _client.get('/api/profile/stats', expectedStatus: 200);
    return data as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> getHabitHeatmap(
    String id, {
    int? year,
  }) async {
    final data = await _client.get('/api/habits/$id/heatmap',
        queryParams: year != null ? {'year': year.toString()} : null);
    return data as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> getHabitWeekly(String id) async {
    final data = await _client.get('/api/habits/$id/weekly', expectedStatus: 200);
    return data as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> getHabitMonthly(String id) async {
    final data =
        await _client.get('/api/habits/$id/monthly', expectedStatus: 200);
    return data as Map<String, dynamic>;
  }
}
