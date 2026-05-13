import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../config/app_theme.dart';
import '../providers/notifications_provider.dart';

class NotificationsView extends StatefulWidget {
  const NotificationsView({super.key});

  @override
  State<NotificationsView> createState() => _NotificationsViewState();
}

class _NotificationsViewState extends State<NotificationsView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final provider = context.read<NotificationsProvider>();
      await provider.loadNotifications();
      await provider.markAllRead();
    });
  }

  IconData _iconForType(String type) {
    switch (type) {
      case 'like':
        return Icons.favorite_rounded;
      case 'friend_request':
        return Icons.person_add_rounded;
      case 'achievement':
        return Icons.emoji_events_rounded;
      default:
        return Icons.notifications_rounded;
    }
  }

  Color _colorForType(String type) {
    switch (type) {
      case 'like':
        return Colors.red;
      case 'friend_request':
        return AppTheme.primary;
      case 'achievement':
        return const Color(0xFFFFD700);
      default:
        return Colors.grey;
    }
  }

  String _formatTime(String dateStr) {
    try {
      final dt = DateTime.parse(dateStr).toLocal();
      final diff = DateTime.now().difference(dt);
      if (diff.inMinutes < 1) return 'Ara mateix';
      if (diff.inMinutes < 60) return 'Fa ${diff.inMinutes} min';
      if (diff.inHours < 24) return 'Fa ${diff.inHours} h';
      return 'Fa ${diff.inDays} d';
    } catch (_) {
      return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<NotificationsProvider>();
    final notifications = provider.notifications;

    return Scaffold(
      backgroundColor: context.backgroundColor,
      appBar: AppBar(
        title: Text(
          'Notificacions',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: context.surfaceColor,
        foregroundColor: context.textPrimaryColor,
        elevation: 0,
      ),
      body: notifications.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: context.surfaceLightColor,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.notifications_off_rounded,
                      size: 48,
                      color: AppTheme.primary,
                    ),
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Cap notificació de moment',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: context.textPrimaryColor,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Les notificacions de likes i amistats apareixeran aquí',
                    style: TextStyle(fontSize: 13, color: Colors.grey[500]),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: EdgeInsets.all(16),
              itemCount: notifications.length,
              itemBuilder: (context, index) {
                final n = notifications[index];
                final type = n['type'] ?? '';
                final read = n['read'] ?? true;

                return Container(
                  margin: EdgeInsets.only(bottom: 10),
                  decoration: BoxDecoration(
                    color: read ? context.surfaceColor : context.surfaceLightColor,
                    borderRadius: BorderRadius.circular(14),
                    border: read
                        ? null
                        : Border.all(color: AppTheme.primary.withOpacity(0.2)),
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.primary.withOpacity(0.05),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: ListTile(
                    leading: Container(
                      padding: EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: _colorForType(type).withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        _iconForType(type),
                        color: _colorForType(type),
                        size: 20,
                      ),
                    ),
                    title: Text(
                      n['message'] ?? '',
                      style: TextStyle(
                        fontWeight: read ? FontWeight.normal : FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                    subtitle: Text(
                      _formatTime(n['createdAt'] ?? ''),
                      style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                    ),
                    trailing: read
                        ? null
                        : Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: AppTheme.primary,
                              shape: BoxShape.circle,
                            ),
                          ),
                  ),
                );
              },
            ),
    );
  }
}
