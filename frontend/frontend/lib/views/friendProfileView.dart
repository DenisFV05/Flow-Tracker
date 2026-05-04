import 'package:flutter/material.dart';
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
      backgroundColor: const Color(0xFFF0F7FF),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Color(0xFF1A2332)),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          name,
          style: const TextStyle(color: Color(0xFF1A2332), fontWeight: FontWeight.w600),
        ),
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF1E88E5)))
          : error != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: const BoxDecoration(
                          color: Color(0xFFFFEBEE),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.error_outline_rounded, size: 48, color: Color(0xFFE53935)),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'No s\'han pogut carregar les dades',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Color(0xFF1A2332)),
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
                          backgroundColor: const Color(0xFF1E88E5),
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
            color: const Color(0xFF1E88E5).withOpacity(0.06),
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
              border: Border.all(color: const Color(0xFF1E88E5), width: 2),
            ),
            child: CircleAvatar(
              radius: 48,
              backgroundColor: const Color(0xFFE3F2FD),
              backgroundImage: avatar != null && avatar.startsWith('http')
                  ? NetworkImage(avatar)
                  : null,
              child: (avatar == null || !avatar.startsWith('http'))
                  ? Text(
                      name.isNotEmpty ? name[0].toUpperCase() : '?',
                      style: const TextStyle(fontSize: 32, color: Color(0xFF1E88E5), fontWeight: FontWeight.bold),
                    )
                  : null,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            name,
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF1A2332)),
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
            color: const Color(0xFF1E88E5).withOpacity(0.06),
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
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Color(0xFF1A2332)),
          ),
          const SizedBox(height: 16),
          _statRow(Icons.track_changes_rounded, 'Hàbits totals', '$totalHabits', const Color(0xFF1E88E5)),
          const SizedBox(height: 12),
          _statRow(Icons.check_circle_rounded, 'Dies completats', '$completedLogs', const Color(0xFF43A047)),
          const SizedBox(height: 12),
          _statRow(Icons.local_fire_department_rounded, 'Ratxa màxima', '$longestStreak dies', const Color(0xFFFF9800)),
          _statRow(Icons.percent_rounded, 'Percentatge global', '${rate.toStringAsFixed(1)}%', const Color(0xFFAB47BC)),
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
        Text(value, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15, color: Color(0xFF1A2332))),
      ],
    );
  }
}
