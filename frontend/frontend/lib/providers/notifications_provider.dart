import 'dart:async';
import 'package:flutter/material.dart';
import '../services/api_client.dart';

class NotificationsProvider extends ChangeNotifier {
  final ApiClient _client = ApiClient();

  List<dynamic> notifications = [];
  int unreadCount = 0;
  Timer? _pollTimer;

  NotificationsProvider() {
    _loadUnreadCount();
    _startPolling();
  }

  @override
  void dispose() {
    _pollTimer?.cancel();
    super.dispose();
  }

  void _startPolling() {
    _pollTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      _loadUnreadCount();
    });
  }

  Future<void> _loadUnreadCount() async {
    try {
      final data = await _client.get('/api/notifications/unread-count');
      unreadCount = data['count'] ?? 0;
      notifyListeners();
    } catch (_) {}
  }

  Future<void> loadNotifications() async {
    try {
      final data = await _client.get('/api/notifications');
      notifications = data as List<dynamic>;
      notifyListeners();
    } catch (_) {}
  }

  Future<void> markAllRead() async {
    try {
      await _client.put('/api/notifications/read-all');
      unreadCount = 0;
      for (var n in notifications) {
        n['read'] = true;
      }
      notifyListeners();
    } catch (_) {}
  }
}
