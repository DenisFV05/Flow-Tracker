import 'package:flutter/material.dart';
import '../services/feed_service.dart';

class FeedView extends StatefulWidget {
  const FeedView({super.key});

  @override
  State<FeedView> createState() => _FeedViewState();
}

class _FeedViewState extends State<FeedView> {
  final FeedApi _feedApi = FeedApi();
  List<dynamic> posts = [];
  bool loading = true;
  String? error;
  String? nextCursor;
  final _postController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadFeed();
  }

  @override
  void dispose() {
    _postController.dispose();
    super.dispose();
  }

  Future<void> _loadFeed() async {
    try {
      setState(() {
        loading = true;
        error = null;
      });

      final result = await _feedApi.getFeed();

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

  Future<void> _createPost() async {
    if (_postController.text.trim().isEmpty) return;

    try {
      await _feedApi.createPost(_postController.text.trim());
      _postController.clear();
      await _loadFeed();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Publicació creat!'),
            backgroundColor: const Color(0xFF1E88E5),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  Future<void> _likePost(String postId) async {
    try {
      await _feedApi.likePost(postId);
      await _loadFeed();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No s\'ha pogut fer like'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    }
  }

  Future<void> _unlikePost(String postId) async {
    try {
      await _feedApi.unlikePost(postId);
      await _loadFeed();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No s\'ha pogut treure el like'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    }
  }

  String _formatTimestamp(String dateStr) {
    try {
      final dateTime = DateTime.parse(dateStr);
      final now = DateTime.now();
      final difference = now.difference(dateTime);

      if (difference.inMinutes < 1) {
        return 'Ara mateix';
      } else if (difference.inMinutes < 60) {
        return 'Fa ${difference.inMinutes} min';
      } else if (difference.inHours < 24) {
        return 'Fa ${difference.inHours} h';
      } else {
        return 'Fa ${difference.inDays} d';
      }
    } catch (e) {
      return dateStr;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return Container(
        color: const Color(0xFFF0F7FF),
        child: const Center(child: CircularProgressIndicator(color: Color(0xFF1E88E5))),
      );
    }

    if (error != null) {
      return Container(
        color: const Color(0xFFF0F7FF),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: const BoxDecoration(
                  color: Color(0xFFE3F2FD),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.signal_wifi_off_rounded, size: 48, color: Color(0xFF1E88E5)),
              ),
              const SizedBox(height: 16),
              const Text(
                'No s\'ha pogut carregar el feed',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1A2332),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Comprova la teva connexió i torna-ho a intentar',
                style: TextStyle(fontSize: 14, color: Colors.grey[500]),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: _loadFeed,
                icon: const Icon(Icons.refresh, size: 18),
                label: const Text('Reintentar'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1E88E5),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Container(
      color: const Color(0xFFF0F7FF),
      child: Column(
        children: [
          _buildPostComposer(),
          Expanded(
            child: posts.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: const BoxDecoration(
                            color: Color(0xFFE3F2FD),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.feed_rounded, size: 48, color: Color(0xFF1E88E5)),
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'No hi ha publicacions',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF1A2332),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Crea una publicació o afegeix amics per veure el seu progrés',
                          style: TextStyle(fontSize: 14, color: Colors.grey[500]),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  )
                : RefreshIndicator(
                    onRefresh: _loadFeed,
                    color: const Color(0xFF1E88E5),
                    child: ListView.builder(
                      padding: const EdgeInsets.all(20),
                      itemCount: posts.length,
                      itemBuilder: (context, index) {
                        final post = posts[index];
                        final user = post['user'] ?? {};
                        final liked = post['liked'] ?? false;
                        final isOwn = post['isOwn'] ?? false;

                        return Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(14),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF1E88E5).withOpacity(0.06),
                                blurRadius: 12,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                CircleAvatar(
                                  radius: 24,
                                  backgroundColor: const Color(0xFF1E88E5).withOpacity(0.1),
                                  backgroundImage: user['avatar'] != null
                                      ? NetworkImage(user['avatar'])
                                      : null,
                                  child: user['avatar'] == null
                                      ? Text(
                                          (user['name']?.toString().isNotEmpty == true
                                              ? user['name'][0].toUpperCase()
                                              : '?'),
                                          style: const TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                            color: Color(0xFF1E88E5),
                                          ),
                                        )
                                      : null,
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Expanded(
                                            child: Text(
                                              user['name'] ?? '',
                                              style: const TextStyle(
                                                fontSize: 15,
                                                fontWeight: FontWeight.w600,
                                                color: Color(0xFF1A2332),
                                              ),
                                            ),
                                          ),
                                          if (isOwn)
                                            Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                              decoration: BoxDecoration(
                                                color: const Color(0xFFE3F2FD),
                                                borderRadius: BorderRadius.circular(4),
                                              ),
                                              child: const Text(
                                                'Tu',
                                                style: TextStyle(
                                                  fontSize: 10,
                                                  color: Color(0xFF1E88E5),
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                            ),
                                          const SizedBox(width: 8),
                                          Text(
                                            _formatTimestamp(post['createdAt'] ?? ''),
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: Colors.grey[500],
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 4),
                                      _buildPostTypeBadge(post),
                                      const SizedBox(height: 8),
                                      Text(
                                        post['content'] ?? '',
                                        style: const TextStyle(
                                          fontSize: 14,
                                          height: 1.4,
                                          color: Color(0xFF374151),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 8),
                                InkWell(
                                  onTap: () => liked ? _unlikePost(post['id']) : _likePost(post['id']),
                                  borderRadius: BorderRadius.circular(24),
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
                                    child: Icon(
                                      liked ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                                      color: liked ? const Color(0xFFE53935) : Colors.grey[400],
                                      size: 22,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildPostComposer() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1E88E5).withOpacity(0.06),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: const Color(0xFF1E88E5).withOpacity(0.1),
            child: const Icon(Icons.edit_note_rounded, color: Color(0xFF1E88E5), size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: TextField(
              controller: _postController,
              decoration: InputDecoration(
                hintText: 'Comparteix el teu progrés...',
                filled: true,
                fillColor: const Color(0xFFF0F7FF),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              ),
              maxLines: null,
              textInputAction: TextInputAction.newline,
              onSubmitted: (_) => _createPost(),
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            onPressed: _createPost,
            icon: const Icon(Icons.send_rounded, color: Color(0xFF1E88E5)),
          ),
        ],
      ),
    );
  }

  Widget _buildPostTypeBadge(Map<String, dynamic> post) {
    final type = post['type'] ?? 'manual';
    final habitName = post['habitName'];

    if (type == 'achievement' && habitName != null) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFFFFF8E1), Color(0xFFFFECB3)],
          ),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.emoji_events_rounded, size: 12, color: Color(0xFFFF9800)),
            const SizedBox(width: 4),
            Text(
              'Assoliment: $habitName',
              style: const TextStyle(
                fontSize: 11,
                color: Color(0xFFFF9800),
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: const Color(0xFFE3F2FD),
        borderRadius: BorderRadius.circular(6),
      ),
      child: const Text(
        'Publicació',
        style: TextStyle(
          fontSize: 11,
          color: Color(0xFF1E88E5),
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
