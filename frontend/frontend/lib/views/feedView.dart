import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/feed_service.dart';
import '../models/habitsProvider.dart';

class FeedView extends StatefulWidget {
  const FeedView({super.key});

  @override
  State<FeedView> createState() => _FeedViewState();
}

class _FeedViewState extends State<FeedView> {
  List<dynamic> posts = [];
  bool loading = true;
  String? error;
  String? nextCursor;

  @override
  void initState() {
    super.initState();
    _loadFeed();
  }

  Future<void> _loadFeed() async {
    try {
      setState(() {
        loading = true;
        error = null;
      });

      final feedApi = FeedApi("https://flow-tracker.ieti.site");
      final result = await feedApi.getFeed();

      setState(() {
        posts = result['posts'] as List<dynamic>;
        nextCursor = result['nextCursor'] as String?;
        loading = false;
      });
    } catch (e) {
      setState(() {
        error = e.toString();
        loading = false;
      });
    }
  }

  Future<void> _likePost(String postId) async {
    try {
      final feedApi = FeedApi("https://flow-tracker.ieti.site");
      await feedApi.likepost(postId);
      await _loadFeed();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return loading
        ? const Center(child: CircularProgressIndicator())
        : error != null
            ? Center(child: Text(error!))
            : RefreshIndicator(
                onRefresh: _loadFeed,
                child: ListView.builder(
                  padding: const EdgeInsets.all(10),
                  itemCount: posts.length,
                  itemBuilder: (context, index) {
                    final post = posts[index];
                    final user = post['user'] ?? {};
                    final liked = post['liked'] ?? false;

                    return Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      decoration: BoxDecoration(
                        color: canvasColor,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: ListTile(
                        leading: CircleAvatar(
                          child: Text(user['name']?[0] ?? '?'),
                        ),
                        title: Text(user['name'] ?? ''),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(post['content'] ?? ''),
                            const SizedBox(height: 4),
                            Text(
                              post['createdAt']?.toString().substring(0, 10) ?? '',
                              style: const TextStyle(fontSize: 12, color: Colors.grey),
                            ),
                          ],
                        ),
                        trailing: IconButton(
                          icon: Icon(
                            liked ? Icons.favorite : Icons.favorite_border,
                            color: liked ? Colors.red : null,
                          ),
                          onPressed: () => _likePost(post['id']),
                        ),
                      ),
                    );
                  },
                ),
              );
  }
}
