import 'dart:async';
import 'dart:convert';
import 'package:flowTracker/models/habit.dart';
import 'package:flowTracker/providers/feedProvider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../config/app_theme.dart';
import '../providers/habitProvider.dart';

class FeedView extends StatefulWidget {
  const FeedView({super.key});

  @override
  State<FeedView> createState() => _FeedViewState();
}

class _FeedViewState extends State<FeedView> {
  Timer? _pollTimer;
  final _postController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final Set<String> _likingPostIds = {};

@override
void initState() {
  super.initState();
  _scrollController.addListener(_onScroll);
  WidgetsBinding.instance.addPostFrameCallback((_) {
    context.read<FeedProvider>().loadFeed();
  });

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
    final provider = context.read<FeedProvider>();

    _pollTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      provider.loadFeed(cursor: null);
    });
  }

  void _onScroll() {
    final provider = context.read<FeedProvider>();

    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      provider.loadFeed(cursor: provider.feedNextCursor);
    }
  }

  Future<void> _createPost() async {
    final provider = context.read<FeedProvider>();
    final text = _postController.text.trim();

    if (text.isEmpty) return;

    await provider.createPost(text);
    _postController.clear();

    provider.loadFeed();

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Publicació creada!'),
          backgroundColor: AppTheme.primary,
        ),
      );
    }
  }

  Future<void> _likePost(String postId, bool liked) async {
    final provider = context.read<FeedProvider>();

    if (_likingPostIds.contains(postId)) return;
    _likingPostIds.add(postId);

    try {
      if (liked) {
        await provider.unlikePost(postId);
      } else {
        await provider.likePost(postId);
      }

      provider.loadFeed();
    } finally {
      _likingPostIds.remove(postId);
    }
  }

  String _formatTimestamp(String dateStr) {
    try {
      final dateTime = DateTime.parse(dateStr);
      final now = DateTime.now();
      final diff = now.difference(dateTime);

      if (diff.inMinutes < 1) return 'Ara mateix';
      if (diff.inMinutes < 60) return 'Fa ${diff.inMinutes} min';
      if (diff.inHours < 24) return 'Fa ${diff.inHours} h';
      return 'Fa ${diff.inDays} d';
    } catch (_) {
      return dateStr;
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<FeedProvider>();

    if (provider.feedLoading) {
      return const Center(
        child: CircularProgressIndicator(color: AppTheme.primary),
      );
    }

    if (provider.error != null) {
      return Center(
        child: Text('Error: ${provider.error}'),
      );
    }

    final posts = provider.feedPosts;

    return Column(
      children: [
        // Eliminado MediaQuery viewInsets para evitar doble desplazamiento
        _buildComposer(provider),
        Expanded(
          child: posts.isEmpty
              ? const Center(child: Text("No hi ha publicacions"))
              : RefreshIndicator(
                  onRefresh: () => provider.loadFeed(),
                  child: ListView.builder(
                    controller: _scrollController,
                    itemCount: posts.length,
                    itemBuilder: (context, index) {
                      final post = posts[index];
                      final user = post['user'] ?? {};
                      final liked = post['liked'] ?? false;

                      return Card(
                        margin: const EdgeInsets.all(8),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundImage: user['avatar'] != null
                                ? MemoryImage(
                                    base64Decode(
                                      user['avatar'].toString().split(',').last,
                                    ),
                                  )
                                : null,
                            child: user['avatar'] == null
                                ? Text(user['name']?[0] ?? '?')
                                : null,
                          ),
                          title: Text(user['name'] ?? ''),
                          subtitle: Text(post['content'] ?? ''),
                          trailing: Column(
                            mainAxisSize: MainAxisSize.min, // Solución al overflow
                            children: [
                              IconButton(
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(),
                                icon: Icon(
                                  liked
                                      ? Icons.favorite
                                      : Icons.favorite_border,
                                  color: liked ? Colors.red : null,
                                ),
                                onPressed: () =>
                                    _likePost(post['id'], liked),
                              ),
                              const SizedBox(height: 4),
                              Text('${post['likesCount'] ?? 0}'),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
        ),
      ],
    );
  }

  Widget _buildComposer(FeedProvider provider) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _postController,
              decoration: const InputDecoration(
                hintText: 'Comparteix el teu progrés...',
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.send, color: AppTheme.primary),
            onPressed: _createPost,
          ),
        ],
      ),
    );
  }
}