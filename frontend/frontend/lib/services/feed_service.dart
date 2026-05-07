import 'api_client.dart';

class FeedApi {
  final ApiClient _client = ApiClient();

  Future<Map<String, dynamic>> getFeed(
      {String? cursor, int limit = 20}) async {
    final queryParams = <String, String>{
      'limit': limit.toString(),
      if (cursor != null) 'cursor': cursor,
    };

    final data = await _client.get('/api/feed',
        queryParams: queryParams, expectedStatus: 200);

    final postsData = data['posts'];
    return {
      'posts': postsData is List ? postsData : [],
      'nextCursor': data['nextCursor'],
    };
  }

  Future<void> createPost(String content) async {
    await _client.post('/api/feed',
        body: {'content': content}, expectedStatus: 201);
  }

  Future<void> likePost(String postId) async {
    await _client.post('/api/feed/$postId/like', expectedStatus: 201);
  }

  Future<void> unlikePost(String postId) async {
    await _client.delete('/api/feed/$postId/like', expectedStatus: 200);
  }

  Future<List<dynamic>> getLikes(String postId) async {
    final data =
        await _client.get('/api/feed/$postId/likes', expectedStatus: 200);
    return data as List<dynamic>;
  }
}
