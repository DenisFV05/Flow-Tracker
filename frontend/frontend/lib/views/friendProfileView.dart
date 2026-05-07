import 'dart:convert';
import 'package:flutter/material.dart';
import '../config/app_theme.dart';
import '../services/friends_service.dart';

class FriendProfileView extends StatefulWidget {
  final Map<String, dynamic> friend;

  const FriendProfileView({super.key, required this.friend});

  @override
  State<FriendProfileView> createState() => _FriendProfileViewState();
}

class _FriendProfileViewState extends State<FriendProfileView> {
  final FriendsApi _friendsApi = FriendsApi();
  Map<String, dynamic>? profile;
  bool loading = true;
  String? error;

  @override
  void initState() {
    super.initState();
    _loadFriendProfile();
  }

  Future<void> _loadFriendProfile() async {
    try {
      setState(() {
        loading = true;
        error = null;
      });

      final friendId = widget.friend['id'] as String?;
      if (friendId == null || friendId.isEmpty) {
        throw Exception('ID de usuari no vàlid');
      }

      final result = await _friendsApi.getFriendProfile(friendId);
      setState(() {
        profile = result;
        loading = false;
      });
    } catch (e) {
      setState(() {
        error = e.toString();
        loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = widget.friend;
    final name = user['name'] as String? ?? 'Usuari';
    final username = user['username'] as String? ?? '';
    final avatar = user['avatar'] as String?;

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppTheme.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          name,
          style: const TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.w600),
        ),
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator(color: AppTheme.primary))
          : error != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: const BoxDecoration(
                          color: AppTheme.errorBg,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.error_outline_rounded, size: 48, color: AppTheme.error),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'No s\'han pogut carregar les dades',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppTheme.textPrimary),
                      ),
                      const SizedBox(height: 8),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 32),
                        child: Text(
                          error!,
                          style: TextStyle(color: Colors.grey[500]),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton.icon(
                        onPressed: _loadFriendProfile,
                        icon: const Icon(Icons.refresh_rounded, size: 18),
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
                )
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      _buildHeader(name, username, avatar),
                      const SizedBox(height: 24),
                      if (profile != null) _buildStats(profile!),
                    ],
                  ),
                ),
    );
  }

  Widget _buildHeader(String name, String username, String? avatar) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primary.withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: AppTheme.primary, width: 2),
            ),
            child: CircleAvatar(
              radius: 48,
              backgroundColor: AppTheme.surfaceLight,
              backgroundImage: avatar != null
                  ? (avatar.startsWith('data:')
                      ? MemoryImage(base64Decode(avatar.split(',').last))
                      : (avatar.startsWith('http')
                          ? NetworkImage(avatar)
                          : null))
                  : null,
              child: avatar == null || (!avatar.startsWith('http') && !avatar.startsWith('data:'))
                  ? Text(
                      name.isNotEmpty ? name[0].toUpperCase() : '?',
                      style: const TextStyle(fontSize: 32, color: AppTheme.primary, fontWeight: FontWeight.bold),
                    )
                  : null,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            name,
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
          ),
          const SizedBox(height: 4),
          Text(
            '@$username',
            style: TextStyle(fontSize: 14, color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }

  Widget _buildStats(Map<String, dynamic> stats) {
    final totalHabits = stats['totalHabits'] ?? 0;
    final completedLogs = stats['completedLogs'] ?? 0;
    final longestStreak = stats['longestStreak'] ?? 0;
    final rate = stats['overallCompletionRate'] ?? 0;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primary.withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Estadístiques',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: AppTheme.textPrimary),
          ),
          const SizedBox(height: 16),
          _statRow(Icons.track_changes_rounded, 'Hàbits totals', '$totalHabits', AppTheme.primary),
          const SizedBox(height: 12),
          _statRow(Icons.check_circle_rounded, 'Dies completats', '$completedLogs', AppTheme.success),
          const SizedBox(height: 12),
          _statRow(Icons.local_fire_department_rounded, 'Ratxa màxima', '$longestStreak dies', AppTheme.warning),
          _statRow(Icons.percent_rounded, 'Percentatge global', '${rate.toStringAsFixed(1)}%', AppTheme.purple),
        ],
      ),
    );
  }

  Widget _statRow(IconData icon, String label, String value, Color color) {
    return Row(
      children: [
        Icon(icon, size: 20, color: color),
        const SizedBox(width: 10),
        Expanded(child: Text(label, style: TextStyle(color: Colors.grey[600], fontSize: 14))),
        Text(value, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15, color: AppTheme.textPrimary)),
      ],
    );
  }
}
