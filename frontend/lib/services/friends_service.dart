import 'api_client.dart';

class FriendsApi {
  final ApiClient _client = ApiClient();

  Future<List<dynamic>> getFriends() async {
    final data = await _client.get('/api/friends', expectedStatus: 200);
    return data as List<dynamic>;
  }

  Future<List<dynamic>> searchUsers(String query) async {
    final data = await _client.get('/api/friends/search',
        queryParams: {'q': query}, expectedStatus: 200);
    return data as List<dynamic>;
  }

  Future<void> sendRequest(String username) async {
    await _client.post('/api/friends/request',
        body: {'username': username}, expectedStatus: 201);
  }

  Future<List<dynamic>> getRequests() async {
    final data = await _client.get('/api/friends/requests', expectedStatus: 200);
    return data as List<dynamic>;
  }

  Future<void> respondRequest(String id, String action) async {
    await _client.put('/api/friends/request/$id',
        body: {'action': action}, expectedStatus: 200);
  }

  Future<void> removeFriend(String id) async {
    await _client.delete('/api/friends/$id', expectedStatus: 200);
  }

  Future<Map<String, dynamic>> getFriendProfile(String friendId) async {
    final data =
        await _client.get('/api/profile/$friendId', expectedStatus: 200);
    return data as Map<String, dynamic>;
  }

  Future<List<dynamic>> getLeaderboard() async {
    final data = await _client.get('/api/friends/leaderboard', expectedStatus: 200);
    return data as List<dynamic>;
  }
}
