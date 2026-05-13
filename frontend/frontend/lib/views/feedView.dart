import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:file_picker/file_picker.dart';
import 'package:flowTracker/providers/feedProvider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../config/app_theme.dart';

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
  Uint8List? _selectedImageBytes;
  String? _selectedImageBase64;

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
      if (provider.feedNextCursor != null) {
        provider.loadFeed(cursor: provider.feedNextCursor);
      }
    }
  }

  Future<void> _pickImage() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      withData: true,
    );
    if (result != null && result.files.first.bytes != null) {
      final bytes = result.files.first.bytes!;
      final base64Str = 'data:image/jpeg;base64,${base64Encode(bytes)}';
      setState(() {
        _selectedImageBytes = bytes;
        _selectedImageBase64 = base64Str;
      });
    }
  }

  Future<void> _createPost() async {
    final provider = context.read<FeedProvider>();
    final text = _postController.text.trim();

    if (text.isEmpty && _selectedImageBase64 == null) return;

    // If there's an image, embed it as a special marker in the content
    final content = _selectedImageBase64 != null
        ? '${text.isNotEmpty ? '$text\n' : ''}[IMG]$_selectedImageBase64[/IMG]'
        : text;

    await provider.createPost(content);
    _postController.clear();
    setState(() {
      _selectedImageBytes = null;
      _selectedImageBase64 = null;
    });

    provider.loadFeed();

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Publicació creada!'),
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

  void _showDeletePostDialog(String postId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Eliminar publicació'),
        content: Text('Segur que vols eliminar aquesta publicació?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text('Cancel·lar')),
          TextButton(
            onPressed: () {
              context.read<FeedProvider>().deletePost(postId);
              Navigator.pop(context);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: Text('Eliminar'),
          ),
        ],
      ),
    );
  }

  String _formatTimestamp(String dateStr) {
    try {
      // toLocal() converts UTC server time to the device's local timezone
      final dateTime = DateTime.parse(dateStr).toLocal();
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
      return Center(
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
              ? Center(child: Text("No hi ha publicacions"))
              : RefreshIndicator(
                  onRefresh: () => provider.loadFeed(),
                  child: ListView.builder(
                    controller: _scrollController,
                    itemCount: posts.length,
                    itemBuilder: (context, index) {
                      final post = posts[index];
                      final user = post['user'] ?? {};
                      final liked = post['liked'] ?? false;
                      final isAchievement = post['type'] == 'achievement';

                      return _buildPostCard(post, user, liked, isAchievement);
                    },
                  ),
                ),
        ),
      ],
    );
  }

  Widget _buildComposer(FeedProvider provider) {
    return Container(
      margin: EdgeInsets.all(12),
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color ?? Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primary.withOpacity(0.06),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _postController,
                  maxLines: 2,
                  maxLength: 280,
                  decoration: InputDecoration(
                    hintText: 'Comparteix el teu progrés...',
                    border: InputBorder.none,
                    counterText: '',
                    hintStyle: TextStyle(color: Colors.grey[400]),
                  ),
                ),
              ),
            ],
          ),
          // Image preview
          if (_selectedImageBytes != null)
            Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.memory(
                    _selectedImageBytes!,
                    height: 120,
                    width: double.infinity,
                    fit: BoxFit.contain,
                  ),
                ),
                Positioned(
                  top: 4,
                  right: 4,
                  child: GestureDetector(
                    onTap: () => setState(() {
                      _selectedImageBytes = null;
                      _selectedImageBase64 = null;
                    }),
                    child: Container(
                      padding: EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Colors.black54,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.close, color: context.surfaceColor, size: 16),
                    ),
                  ),
                ),
              ],
            ),
          const Divider(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Image picker button
              IconButton(
                icon: Icon(
                  Icons.image_rounded,
                  color: _selectedImageBytes != null ? AppTheme.primary : Colors.grey[400],
                ),
                tooltip: 'Adjuntar imatge',
                onPressed: _pickImage,
              ),
              // Send button
              ElevatedButton.icon(
                onPressed: _createPost,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                ),
                icon: Icon(Icons.send_rounded, size: 16),
                label: Text('Publicar'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAvatarWidget(Map<dynamic, dynamic> user) {
    final avatar = user['avatar'];
    if (avatar != null && avatar.toString().startsWith('data:')) {
      try {
        return CircleAvatar(
          backgroundImage: MemoryImage(base64Decode(avatar.toString().split(',').last)),
        );
      } catch (_) {}
    }
    if (avatar != null && avatar.toString().startsWith('http')) {
      return CircleAvatar(backgroundImage: NetworkImage(avatar.toString()));
    }
    return CircleAvatar(
      backgroundColor: context.surfaceLightColor,
      child: Text(
        user['name']?[0]?.toUpperCase() ?? '?',
        style: TextStyle(color: AppTheme.primary, fontWeight: FontWeight.bold),
      ),
    );
  }

  // Extract text and optional base64 image from post content
  Map<String, String?> _parsePostContent(String? rawContent) {
    if (rawContent == null) return {'text': '', 'image': null};
    final imgRegex = RegExp(r'\[IMG\](.*?)\[/IMG\]', dotAll: true);
    final match = imgRegex.firstMatch(rawContent);
    if (match != null) {
      final imageData = match.group(1);
      final text = rawContent.replaceAll(match.group(0)!, '').trim();
      return {'text': text, 'image': imageData};
    }
    return {'text': rawContent, 'image': null};
  }

  Widget _buildPostCard(
    Map<dynamic, dynamic> post,
    Map<dynamic, dynamic> user,
    bool liked,
    bool isAchievement,
  ) {
    final timestamp = post['createdAt'] != null
        ? _formatTimestamp(post['createdAt'].toString())
        : '';
    final parsed = _parsePostContent(post['content']?.toString());
    final postText = parsed['text'] ?? '';
    final postImage = parsed['image'];

    if (isAchievement) {
      // ─── Achievement card: gradient daurat ───
      return Container(
        margin: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFFFFF8E1), Color(0xFFFFF3CD)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: const Color(0xFFFFD54F), width: 1.5),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFFFD700).withOpacity(0.15),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Trophy icon
              Container(
                padding: EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFD700).withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.emoji_events_rounded, color: Color(0xFFE65100), size: 26),
              ),
              SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          user['name'] ?? '',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                        ),
                        SizedBox(width: 6),
                        Text(
                          'ha aconseguit un assoliment!',
                          style: TextStyle(fontSize: 13, color: Color(0xFF8D6E63)),
                        ),
                      ],
                    ),
                    SizedBox(height: 6),
                    Text(
                      postText,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFFE65100),
                      ),
                    ),
                    SizedBox(height: 6),
                    Text(
                      timestamp,
                      style: TextStyle(fontSize: 11, color: Color(0xFFBCAAA4)),
                    ),
                  ],
                ),
              ),
                child: Column(
                  children: [
                    if (post['isOwn'] == true)
                      IconButton(
                        icon: Icon(Icons.delete_outline, color: Colors.red.withOpacity(0.5), size: 18),
                        onPressed: () => _showDeletePostDialog(post['id']),
                        padding: EdgeInsets.zero,
                        constraints: BoxConstraints(),
                      ),
                    SizedBox(height: post['isOwn'] == true ? 8 : 0),
                    GestureDetector(
                      onTap: () => _likePost(post['id'], liked),
                      child: Icon(
                        liked ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                        color: liked ? Colors.red : Colors.grey,
                        size: 22,
                      ),
                    ),
                    Text(
                      '${post['likesCount'] ?? 0}',
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    }

    // ─── Manual post card: estàndard net ───
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color ?? Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primary.withOpacity(0.06),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildAvatarWidget(user),
            SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        user['name'] ?? '',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                      ),
                      SizedBox(width: 6),
                      Text(
                        '@${user['username'] ?? ''}',
                        style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                      ),
                    ],
                  ),
                  SizedBox(height: 6),
                  if (postText.isNotEmpty)
                    Text(
                      postText,
                      style: TextStyle(fontSize: 15, height: 1.4),
                    ),
                  if (postImage != null) ...[
                    SizedBox(height: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Builder(builder: (context) {
                        try {
                          final bytes = base64Decode(postImage.split(',').last);
                          return ConstrainedBox(
                            constraints: const BoxConstraints(maxHeight: 300),
                            child: Image.memory(
                              bytes,
                              fit: BoxFit.contain,
                              width: double.infinity,
                              errorBuilder: (_, _, _) => SizedBox.shrink(),
                            ),
                          );
                        } catch (_) {
                          return SizedBox.shrink();
                        }
                      }),
                    ),
                  ],
                  if (post['habit'] != null && post['habit']['name'] != null)
                    Padding(
                      padding: EdgeInsets.only(top: 8),
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: context.surfaceLightColor,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.track_changes_rounded, size: 14, color: AppTheme.primary),
                            SizedBox(width: 4),
                            Text(
                              post['habit']['name'],
                              style: TextStyle(fontSize: 12, color: AppTheme.primary, fontWeight: FontWeight.w500),
                            ),
                          ],
                        ),
                      ),
                    ),
                  SizedBox(height: 6),
                  Text(
                    timestamp,
                    style: TextStyle(fontSize: 11, color: Colors.grey[400]),
                  ),
                ],
              ),
            ),
            Column(
              children: [
                if (post['isOwn'] == true)
                  PopupMenuButton<String>(
                    icon: Icon(Icons.more_vert, size: 20, color: Colors.grey),
                    padding: EdgeInsets.zero,
                    onSelected: (value) {
                      if (value == 'delete') {
                        _showDeletePostDialog(post['id']);
                      }
                    },
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          children: [
                            Icon(Icons.delete_outline, color: Colors.red, size: 20),
                            SizedBox(width: 8),
                            Text('Eliminar', style: TextStyle(color: Colors.red)),
                          ],
                        ),
                      ),
                    ],
                  ),
                GestureDetector(
                  onTap: () => _likePost(post['id'], liked),
                  child: Icon(
                    liked ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                    color: liked ? Colors.red : Colors.grey,
                    size: 22,
                  ),
                ),
                Text(
                  '${post['likesCount'] ?? 0}',
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}