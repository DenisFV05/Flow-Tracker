import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import '../config/app_theme.dart';
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
  bool _loadingMore = false;
  bool _creatingPost = false;
  bool _hasNewPosts = false;
  String? error;
  String? nextCursor;
  Timer? _pollTimer;
  final _postController = TextEditingController();
  final Set<String> _likingPostIds = {};
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _loadFeed();
    _startPolling();
  }

  @override
  void dispose() {
    _pollTimer?.cancel();
    _postController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _startPolling() {
    _pollTimer = Timer.periodic(const Duration(seconds: 30), (_) async {
      if (!mounted || _hasNewPosts) return;
      try {
        final result = await _feedApi.getFeed(limit: 1);
        final newPosts = result['posts'] as List<dynamic>;
        if (newPosts.isEmpty) return;
        if (posts.isEmpty || newPosts.first['id'] != posts.first['id']) {
          if (mounted) setState(() => _hasNewPosts = true);
        }
      } catch (_) {}
    });
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      if (nextCursor != null && !_loadingMore && !loading) {
        _loadMore();
      }
    }
  }

  Future<void> _loadMore() async {
    setState(() => _loadingMore = true);
    try {
      final result = await _feedApi.getFeed(cursor: nextCursor);
      setState(() {
        posts.addAll(result['posts'] as List<dynamic>);
        nextCursor = result['nextCursor'] as String?;
        _loadingMore = false;
      });
    } catch (e) {
      setState(() => _loadingMore = false);
    }
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
        _hasNewPosts = false;
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
    if (_postController.text.trim().isEmpty || _creatingPost) return;
    _creatingPost = true;
    try {
      await _feedApi.createPost(_postController.text.trim());
      _postController.clear();
      await _loadFeed();
      _hasNewPosts = false;
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Publicació creada!'),
            backgroundColor: AppTheme.primary,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      _creatingPost = false;
    }
  }

  Future<void> _likePost(String postId) async {
    if (_likingPostIds.contains(postId)) return;
    _likingPostIds.add(postId);
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
    } finally {
      _likingPostIds.remove(postId);
    }
  }

  Future<void> _unlikePost(String postId) async {
    if (_likingPostIds.contains(postId)) return;
    _likingPostIds.add(postId);
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
    } finally {
      _likingPostIds.remove(postId);
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
        color: AppTheme.background,
        child: const Center(child: CircularProgressIndicator(color: AppTheme.primary)),
      );
    }

    if (error != null) {
      return Container(
        color: AppTheme.background,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: const BoxDecoration(
                  color: AppTheme.surfaceLight,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.signal_wifi_off_rounded, size: 48, color: AppTheme.primary),
              ),
              const SizedBox(height: 16),
              const Text(
                'No s\'ha pogut carregar el feed',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textPrimary,
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
                  backgroundColor: AppTheme.primary,
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
      color: AppTheme.background,
      child: Column(
        children: [
          _buildPostComposer(),
          if (_hasNewPosts)
            GestureDetector(
              onTap: () {
                _loadFeed();
                _hasNewPosts = false;
              },
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                color: AppTheme.primary,
                child: const Text(
                  'Noves publicacions — Toca per veure',
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.w500, fontSize: 13),
                ),
              ),
            ),
          Expanded(
            child: posts.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: const BoxDecoration(
                            color: AppTheme.surfaceLight,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.feed_rounded, size: 48, color: AppTheme.primary),
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'No hi ha publicacions',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.textPrimary,
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
                    color: AppTheme.primary,
                    child: ListView.builder(
                      controller: _scrollController,
                      padding: const EdgeInsets.all(20),
                      itemCount: posts.length + (_loadingMore ? 1 : 0),
                      itemBuilder: (context, index) {
                        if (index == posts.length) {
                          return const Padding(
                            padding: EdgeInsets.all(16),
                            child: Center(child: CircularProgressIndicator(strokeWidth: 2, color: AppTheme.primary)),
                          );
                        }
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
                                color: AppTheme.primary.withOpacity(0.06),
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
                                  backgroundColor: AppTheme.primary.withOpacity(0.1),
                                  backgroundImage: user['avatar'] != null
                                      ? (user['avatar'].toString().startsWith('data:')
                                          ? MemoryImage(base64Decode(user['avatar'].toString().split(',').last))
                                          : NetworkImage(user['avatar']))
                                      : null,
                                  child: user['avatar'] == null
                                      ? Text(
                                          (user['name']?.toString().isNotEmpty == true
                                              ? user['name'][0].toUpperCase()
                                              : '?'),
                                          style: const TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                            color: AppTheme.primary,
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
                                                color: AppTheme.textPrimary,
                                              ),
                                            ),
                                          ),
                                          if (isOwn)
                                            Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                              decoration: BoxDecoration(
                                                color: AppTheme.surfaceLight,
                                                borderRadius: BorderRadius.circular(4),
                                              ),
                                              child: const Text(
                                                'Tu',
                                                style: TextStyle(
                                                  fontSize: 10,
                                                  color: AppTheme.primary,
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
                                          color: AppTheme.textDark,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    InkWell(
                                      onTap: () => liked ? _unlikePost(post['id']) : _likePost(post['id']),
                                      borderRadius: BorderRadius.circular(24),
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                        child: Icon(
                                          liked ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                                          color: liked ? AppTheme.error : Colors.grey[400],
                                          size: 22,
                                        ),
                                      ),
                                    ),
                                    Text(
                                      '${post['likesCount'] ?? 0}',
                                      style: TextStyle(fontSize: 11, color: Colors.grey[500]),
                                    ),
                                  ],
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
            color: AppTheme.primary.withOpacity(0.06),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          const SizedBox(width: 12),
          Expanded(
            child: TextField(
              controller: _postController,
              decoration: InputDecoration(
                hintText: 'Comparteix el teu progrés...',
                filled: true,
                fillColor: AppTheme.background,
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
            icon: const Icon(Icons.send_rounded, color: AppTheme.primary),
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
            const Icon(Icons.emoji_events_rounded, size: 12, color: AppTheme.warning),
            const SizedBox(width: 4),
            Text(
              'Assoliment: $habitName',
              style: const TextStyle(
                fontSize: 11,
                color: AppTheme.warning,
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
        color: AppTheme.surfaceLight,
        borderRadius: BorderRadius.circular(6),
      ),
      child: const Text(
        'Publicació',
        style: TextStyle(
          fontSize: 11,
          color: AppTheme.primary,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
