import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';

import '../config/app_theme.dart';
import '../services/friends_service.dart';
import 'friendProfileView.dart';

class AmicsView extends StatefulWidget {
  const AmicsView({super.key});

  @override
  State<AmicsView> createState() => _AmicsViewState();
}

class _AmicsViewState extends State<AmicsView> {
  final FriendsApi _friendsApi = FriendsApi();
  List<dynamic> friends = [];
  List<dynamic> requests = [];
  List<dynamic> leaderboard = [];
  bool loading = true;
  bool _hasChanges = false;
  String? error;
  Timer? _pollTimer;

  @override
  void initState() {
    super.initState();
    _loadData();
    _startPolling();
  }

  @override
  void dispose() {
    _pollTimer?.cancel();
    super.dispose();
  }

  void _startPolling() {
    _pollTimer = Timer.periodic(const Duration(seconds: 30), (_) async {
      if (!mounted || _hasChanges) return;
      try {
        final results = await Future.wait([
          _friendsApi.getFriends(),
          _friendsApi.getRequests(),
        ]);
        final newFriends = results[0];
        final newRequests = results[1];
        if (newFriends.length != friends.length || newRequests.length != requests.length) {
          if (mounted) setState(() => _hasChanges = true);
        }
      } catch (_) {}
    });
  }

  Future<void> _loadData() async {
    try {
      setState(() {
        loading = true;
        error = null;
      });

      final results = await Future.wait([
        _friendsApi.getFriends(),
        _friendsApi.getRequests(),
        _friendsApi.getLeaderboard(),
      ]);

      setState(() {
        friends = results[0];
        requests = results[1];
        leaderboard = results[2];
        _hasChanges = false;
        loading = false;
      });
    } catch (e) {
      setState(() {
        error = e.toString();
        loading = false;
      });
    }
  }

  Future<void> _sendRequest(String username) async {
    try {
      await _friendsApi.sendRequest(username);
      await _loadData();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Sol·licitud enviada!'),
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
    }
  }

  Future<void> _respondRequest(String id, String action) async {
    try {
      await _friendsApi.respondRequest(id, action);
      await _loadData();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  Future<void> _removeFriend(String id, String name) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Eliminar amic'),
        content: Text('Segur que vols eliminar $name com a amic?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text('Cancel·lar')),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: Text('Eliminar'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    try {
      await _friendsApi.removeFriend(id);
      await _loadData();
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
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: context.backgroundColor,
        appBar: AppBar(
          toolbarHeight: 0,
          bottom: TabBar(
            indicatorColor: AppTheme.primary,
            labelColor: AppTheme.primary,
            unselectedLabelColor: Colors.grey,
            tabs: [
              Tab(icon: Icon(Icons.people), text: 'Amics'),
              Tab(icon: Icon(Icons.emoji_events), text: 'Rànquing'),
            ],
          ),
        ),
        body: loading
            ? Center(child: CircularProgressIndicator(color: AppTheme.primary))
            : error != null
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
                        SizedBox(height: 16),
                        Text(
                          'No s\'han pogut carregar les dades',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                        ),
                        SizedBox(height: 8),
                        Text(error!, style: TextStyle(color: Colors.grey[500])),
                        SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: _loadData,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.primary,
                            foregroundColor: Colors.white,
                            padding: EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          child: Text('Reintentar'),
                        ),
                      ],
                    ),
                  )
                : TabBarView(
                    children: [
                      _buildFriendsTab(),
                      _buildLeaderboardTab(),
                    ],
                  ),
      ),
    );
  }

  Widget _buildFriendsTab() {
    return Column(
      children: [
        if (_hasChanges)
          GestureDetector(
            onTap: () {
              _loadData();
              _hasChanges = false;
            },
            child: Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              color: AppTheme.primary,
              child: Text(
                'Canvis detectats — Toca per veure',
                style: TextStyle(color: context.surfaceColor, fontWeight: FontWeight.w500, fontSize: 13),
              ),
            ),
          ),
        Expanded(
          child: RefreshIndicator(
            onRefresh: _loadData,
            color: AppTheme.primary,
            child: SingleChildScrollView(
              padding: EdgeInsets.all(20),
              physics: const AlwaysScrollableScrollPhysics(),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final isWide = constraints.maxWidth > 700;

                  if (isWide) {
                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(flex: 2, child: _buildFriendsSection()),
                        SizedBox(width: 20),
                        Expanded(flex: 1, child: _buildRequestsSection()),
                      ],
                    );
                  }

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildFriendsSection(),
                      SizedBox(height: 24),
                      _buildRequestsSection(),
                    ],
                  );
                },
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLeaderboardTab() {
    return RefreshIndicator(
      onRefresh: _loadData,
      color: AppTheme.primary,
      child: ListView.builder(
        padding: EdgeInsets.all(20),
        itemCount: leaderboard.length,
        itemBuilder: (context, index) {
          final user = leaderboard[index];
          final streak = user['longestStreak'] ?? 0;
          final isTop = index < 3;
          final rankColors = [const Color(0xFFFFD700), const Color(0xFFC0C0C0), const Color(0xFFCD7F32)];

          return Container(
            margin: EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              color: context.surfaceColor,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.primary.withOpacity(0.06),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: ListTile(
              leading: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    width: 24,
                    child: Text(
                      '${index + 1}',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: isTop ? rankColors[index] : Colors.grey,
                      ),
                    ),
                  ),
                  SizedBox(width: 8),
                  CircleAvatar(
                    backgroundColor: context.surfaceLightColor,
                    backgroundImage: user['avatar'] != null
                        ? (user['avatar'].toString().startsWith('data:')
                            ? MemoryImage(base64Decode(user['avatar'].toString().split(',').last))
                            : NetworkImage(user['avatar']))
                        : null,
                    child: user['avatar'] == null ? Text(user['name']?[0] ?? '?') : null,
                  ),
                ],
              ),
              title: Text(user['name'] ?? '', style: TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text('${user['totalHabits'] ?? 0} hàbits'),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.local_fire_department, color: Colors.orange),
                  SizedBox(width: 4),
                  Text(
                    '$streak',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildFriendsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Amics',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: context.textPrimaryColor,
              ),
            ),
            TextButton.icon(
              onPressed: _showSearchDialog,
              icon: Icon(Icons.person_add, size: 18, color: AppTheme.primary),
              label: Text('Afegir', style: TextStyle(color: AppTheme.primary)),
            ),
          ],
        ),
        SizedBox(height: 16),
        if (friends.isEmpty)
          _emptyFriends()
        else
          ...friends.map((friend) {
            final user = friend['friend'];
            return _friendCard(user, friend['friendshipId']);
          }),
      ],
    );
  }

  Widget _buildRequestsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Sol·licituds',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: context.textPrimaryColor,
          ),
        ),
        SizedBox(height: 16),
        if (requests.isEmpty)
          _emptyRequests()
        else
          ...requests.map((req) {
            final user = req['user'];
            return _requestCard(user, req['id']);
          }),
      ],
    );
  }

  Widget _friendCard(Map<String, dynamic> user, String friendshipId) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => FriendProfileView(friend: user),
          ),
        );
      },
      child: Container(
        margin: EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
          color: context.surfaceColor,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: AppTheme.primary.withOpacity(0.06),
              blurRadius: 12,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: ListTile(
          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          leading: CircleAvatar(
            radius: 22,
            backgroundColor: AppTheme.primary.withOpacity(0.1),
            backgroundImage: user['avatar'] != null
                ? (user['avatar'].toString().startsWith('data:')
                    ? MemoryImage(base64Decode(user['avatar'].toString().split(',').last))
                    : NetworkImage(user['avatar']))
                : null,
            child: user['avatar'] == null
                ? Text(
                    user['name']?[0]?.toUpperCase() ?? '?',
                    style: TextStyle(
                      color: AppTheme.primary,
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                    ),
                  )
                : null,
          ),
          title: Text(
            user['name'] ?? '',
            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15, color: context.textPrimaryColor),
          ),
          subtitle: Text(
            '@${user['username'] ?? ''}',
            style: TextStyle(fontSize: 13, color: Colors.grey[500]),
          ),
          trailing: TextButton(
            onPressed: () => _removeFriend(friendshipId, user['name'] ?? ''),
            style: TextButton.styleFrom(
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: Text(
              'Eliminar',
              style: TextStyle(color: AppTheme.error, fontSize: 13, fontWeight: FontWeight.w500),
            ),
          ),
        ),
      ),
    );
  }

  Widget _requestCard(Map<String, dynamic> user, String id) {
    return Container(
      margin: EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: context.surfaceColor,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primary.withOpacity(0.06),
            blurRadius: 12,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        leading: CircleAvatar(
          radius: 22,
          backgroundColor: context.surfaceLightColor,
          child: Text(
            user['name']?[0]?.toUpperCase() ?? '?',
            style: TextStyle(
              color: AppTheme.primary,
              fontWeight: FontWeight.w700,
              fontSize: 16,
            ),
          ),
        ),
        title: Text(
          user['name'] ?? '',
          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15, color: context.textPrimaryColor),
        ),
        subtitle: Text(
          '@${user['username'] ?? ''}',
          style: TextStyle(fontSize: 13, color: Colors.grey[500]),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              decoration: BoxDecoration(
                color: AppTheme.successBg,
                borderRadius: BorderRadius.circular(8),
              ),
              child: IconButton(
                icon: Icon(Icons.check, size: 20, color: AppTheme.success),
                onPressed: () => _respondRequest(id, 'accept'),
                constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
              ),
            ),
            SizedBox(width: 8),
            Container(
              decoration: BoxDecoration(
                color: AppTheme.errorBg,
                borderRadius: BorderRadius.circular(8),
              ),
              child: IconButton(
                icon: Icon(Icons.close, size: 20, color: AppTheme.error),
                onPressed: () => _respondRequest(id, 'reject'),
                constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _emptyFriends() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(vertical: 48),
      decoration: BoxDecoration(
        color: context.surfaceColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primary.withOpacity(0.06),
            blurRadius: 12,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: context.surfaceLightColor,
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.people_outline, size: 40, color: AppTheme.primary),
          ),
          SizedBox(height: 16),
          Text(
            'Encara no tens amics',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: context.textPrimaryColor),
          ),
          SizedBox(height: 8),
          Text(
            'Cerca usuaris per connectar',
            style: TextStyle(fontSize: 13, color: Colors.grey[500]),
          ),
          SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: _showSearchDialog,
            icon: Icon(Icons.search, size: 18),
            label: Text('Cercar'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _emptyRequests() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(vertical: 40),
      decoration: BoxDecoration(
        color: context.surfaceColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primary.withOpacity(0.06),
            blurRadius: 12,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: context.surfaceLightColor,
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.mail_outline, size: 40, color: AppTheme.primary),
          ),
          SizedBox(height: 16),
          Text(
            'Cap sol·licitud',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: context.textPrimaryColor),
          ),
          SizedBox(height: 8),
          Text(
            'Les sol·licituds pendents apareixeran aquí',
            style: TextStyle(fontSize: 13, color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }

  void _showSearchDialog() {
    final controller = TextEditingController();
    List<dynamic> searchResults = [];
    bool searching = false;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return Dialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Cercar usuari',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: context.textPrimaryColor),
                    ),
                    SizedBox(height: 16),
                    TextField(
                      controller: controller,
                      decoration: InputDecoration(
                        hintText: 'Escriu el username',
                        prefixIcon: Icon(Icons.search, color: AppTheme.primary),
                        filled: true,
                        fillColor: context.backgroundColor,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      ),
                      onChanged: (value) async {
                        if (value.length >= 2) {
                          setDialogState(() => searching = true);
                          try {
                            final results = await _friendsApi.searchUsers(value);
                            setDialogState(() {
                              searchResults = results;
                              searching = false;
                            });
                          } catch (e) {
                            setDialogState(() => searching = false);
                          }
                        } else {
                          setDialogState(() => searchResults = []);
                        }
                      },
                    ),
                    SizedBox(height: 16),
                    if (searching)
                      SizedBox(
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2, color: AppTheme.primary),
                      )
                    else if (searchResults.isNotEmpty)
                      SizedBox(
                        height: 200,
                        child: ListView.builder(
                          itemCount: searchResults.length,
                          itemBuilder: (context, index) {
                            final user = searchResults[index];
                            final isFriend = user['isFriend'] ?? false;
                            final requestSent = user['requestSent'] ?? false;

                            return ListTile(
                              contentPadding: EdgeInsets.symmetric(horizontal: 8),
                              leading: CircleAvatar(
                                backgroundColor: AppTheme.primary.withOpacity(0.1),
                                child: Text(
                                  user['name']?[0]?.toUpperCase() ?? '?',
                                  style: TextStyle(
                                    color: AppTheme.primary,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                              title: Text(user['name'] ?? '', style: TextStyle(fontWeight: FontWeight.w500)),
                              subtitle: Text('@${user['username'] ?? ''}', style: TextStyle(fontSize: 12, color: Colors.grey[500])),
                              trailing: isFriend
                                  ? Icon(Icons.check_circle, color: AppTheme.success, size: 20)
                                  : requestSent
                                      ? Text('Enviat', style: TextStyle(color: AppTheme.primary, fontSize: 13, fontWeight: FontWeight.w500))
                                      : TextButton(
                                          onPressed: () {
                                            _sendRequest(user['username']);
                                            Navigator.pop(context);
                                          },
                                          style: TextButton.styleFrom(
                                            backgroundColor: AppTheme.primary,
                                            foregroundColor: Colors.white,
                                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                          ),
                                          child: Text('Afegir', style: TextStyle(fontSize: 13)),
                                        ),
                            );
                          },
                        ),
                      ),
                    SizedBox(height: 16),
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: Text('Tancar', style: TextStyle(color: AppTheme.primary)),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
