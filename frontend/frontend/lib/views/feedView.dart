import 'package:flutter/material.dart';

class FeedView extends StatefulWidget {
  const FeedView({super.key});

  @override
  State<FeedView> createState() => _FeedViewState();
}

class _FeedViewState extends State<FeedView> {
  bool _isLoading = true;
  List<Post> _posts = [];

  @override
  void initState() {
    super.initState();
    _loadMockData();
  }

  Future<void> _loadMockData() async {
    // Simulate loading delay
    await Future.delayed(const Duration(seconds: 1));

    if (!mounted) return;

    setState(() {
      _isLoading = false;
      _posts = [
        Post(
          user: User(name: 'Anna Garcia', avatarUrl: null),
          content: '🎉 Has completat 7 dies seguits d\'exercici!',
          createdAt: DateTime.now().subtract(const Duration(hours: 2)),
        ),
        Post(
          user: User(name: 'Marc Lopez', avatarUrl: null),
          content: '🔥 30 dies seguits estudiant Flutter!',
          createdAt: DateTime.now().subtract(const Duration(hours: 5)),
        ),
        Post(
          user: User(name: 'Laia Martinez', avatarUrl: null),
          content: '💪 Has completat 14 dies seguits d\'entrenament!',
          createdAt: DateTime.now().subtract(const Duration(days: 1)),
        ),
        Post(
          user: User(name: 'Pau Rodriguez', avatarUrl: null),
          content: '🎯 60 dies seguits llegint a l\'objectiu!',
          createdAt: DateTime.now().subtract(const Duration(days: 2)),
        ),
      ];
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (_posts.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.feed,
              size: 64,
              color: Colors.grey,
            ),
            const SizedBox(height: 16),
            Text(
              'No hi ha publicacions',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Segueix amics per veure el seu progrés',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey,
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadMockData,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _posts.length,
        itemBuilder: (context, index) {
          final post = _posts[index];
          return _buildPostCard(post);
        },
      ),
    );
  }

  Widget _buildPostCard(Post post) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Avatar
            CircleAvatar(
              radius: 24,
              backgroundColor: Theme.of(context).primaryColor,
              child: post.user.avatarUrl != null
                  ? ClipOval(
                      child: Image.network(
                        post.user.avatarUrl!,
                        width: 48,
                        height: 48,
                        fit: BoxFit.cover,
                      ),
                    )
                  : Text(
                      post.user.name.isNotEmpty
                          ? post.user.name[0].toUpperCase()
                          : '?',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
            ),

            const SizedBox(width: 12),

            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // User name
                  Text(
                    post.user.name,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 4),

                  // Achievement text
                  Text(
                    post.content,
                    style: const TextStyle(
                      fontSize: 14,
                      height: 1.4,
                    ),
                  ),

                  const SizedBox(height: 8),

                  // Timestamp
                  Text(
                    _formatTimestamp(post.createdAt),
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),

            // Like button (UI only)
            IconButton(
              icon: const Icon(Icons.favorite_border),
              color: Colors.grey,
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Like functionality coming soon!'),
                    duration: Duration(seconds: 1),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  String _formatTimestamp(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 60) {
      return '${difference.inMinutes} min';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} h';
    } else {
      return '${difference.inDays} d';
    }
  }
}

class User {
  final String name;
  final String? avatarUrl;

  User({required this.name, this.avatarUrl});
}

class Post {
  final User user;
  final String content;
  final DateTime createdAt;

  Post({
    required this.user,
    required this.content,
    required this.createdAt,
  });
}
