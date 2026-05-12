import 'package:flutter/material.dart';
import '../services/habits_service.dart';
import '../services/feed_service.dart';
import '../services/profile_service.dart';

class HabitProvider extends ChangeNotifier {
  final HabitsApi _habitsApi = HabitsApi();
  final FeedApi _feedApi = FeedApi();
  final ProfileApi _profileApi = ProfileApi();

  // =====================
  // HABITS
  // =====================
  List<dynamic> habits = [];
  Map<String, dynamic> dashboardStats = {};
  Map<String, dynamic> habitStats = {};

  // =====================
  // FEED
  // =====================
  List<dynamic> feedPosts = [];
  String? feedNextCursor;

  bool feedLoading = false;
  bool feedLoadingMore = false;

  // =====================
  // PROFILE
  // =====================
  Map<String, dynamic> userProfile = {};
  bool profileLoading = false;

  // =====================
  // GLOBAL STATE
  // =====================
  bool loading = false;
  String? error;

  // =========================================================
  // DASHBOARD
  // =========================================================
  Future<void> loadDashboard() async {
    try {
      loading = true;
      error = null;
      notifyListeners();

      habits = await _habitsApi.getHabits();
      dashboardStats = await _habitsApi.getProfileStats();

      habitStats.clear();

      for (final habit in habits) {
        final id = habit['id'];
        habitStats[id] = await _habitsApi.getHabitStats(id);
      }
    } catch (e) {
      error = e.toString();
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  // =========================================================
  // FEED
  // =========================================================
  Future<void> loadFeed({String? cursor}) async {
    try {
      if (cursor == null) {
        feedLoading = true;
        notifyListeners();
      }

      final result = await _feedApi.getFeed(cursor: cursor);

      if (cursor == null) {
        feedPosts = result['posts'] as List<dynamic>;
      } else {
        feedPosts.addAll(result['posts'] as List<dynamic>);
      }

      feedNextCursor = result['nextCursor'] as String?;
    } catch (e) {
      error = e.toString();
    } finally {
      feedLoading = false;
      feedLoadingMore = false;
      notifyListeners();
    }
  }

  Future<void> refreshFeed() async {
    await loadFeed();
  }

  Future<void> loadMoreFeed() async {
    if (feedNextCursor == null || feedLoadingMore) return;

    try {
      feedLoadingMore = true;
      notifyListeners();

      await loadFeed(cursor: feedNextCursor);
    } finally {
      feedLoadingMore = false;
      notifyListeners();
    }
  }

  Future<void> createPost(String text) async {
    try {
      await _feedApi.createPost(text);
      await refreshFeed();
    } catch (e) {
      error = e.toString();
      notifyListeners();
    }
  }

  Future<void> likePost(String postId) async {
    try {
      await _feedApi.likePost(postId);
      await refreshFeed();
    } catch (e) {
      error = e.toString();
      notifyListeners();
    }
  }

  Future<void> unlikePost(String postId) async {
    try {
      await _feedApi.unlikePost(postId);
      await refreshFeed();
    } catch (e) {
      error = e.toString();
      notifyListeners();
    }
  }

  // =========================================================
  // PROFILE
  // =========================================================
  Future<void> loadProfile() async {
    try {
      profileLoading = true;
      notifyListeners();

      userProfile = await _profileApi.getProfile();
    } catch (e) {
      error = e.toString();
    } finally {
      profileLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateProfile({String? name, String? avatar}) async {
    try {
      userProfile = await _profileApi.updateProfile(
        name: name,
        avatar: avatar,
      );
      notifyListeners();
    } catch (e) {
      error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  // =========================================================
  // HABITS CRUD
  // =========================================================
  Future<void> addHabit(
    String name,
    String description,
    List<String> tags,
  ) async {
    try {
      await _habitsApi.createHabit(name, description, tags);
      await loadDashboard();
    } catch (e) {
      error = e.toString();
      notifyListeners();
    }
  }

  Future<void> editHabit(
    String id,
    String name,
    String description,
    List<String> tags,
  ) async {
    try {
      await _habitsApi.updateHabit(id, name, description, tags);
      await loadDashboard();
    } catch (e) {
      error = e.toString();
      notifyListeners();
    }
  }

  Future<void> deleteHabit(String id) async {
    try {
      await _habitsApi.deleteHabit(id);
      await loadDashboard();
    } catch (e) {
      error = e.toString();
      notifyListeners();
    }
  }

  Future<void> toggleHabit(String id, bool completed) async {
    try {
      await _habitsApi.toggleHabit(id, completed);
      await loadDashboard();
    } catch (e) {
      error = e.toString();
      notifyListeners();
    }
  }

  // =========================================================
  // STATS (read-only)
  // =========================================================
  Future<Map<String, dynamic>> getHabitHeatmap(String id, {int? year}) {
    return _habitsApi.getHabitHeatmap(id, year: year);
  }

  Future<Map<String, dynamic>> getHabitWeekly(String id) {
    return _habitsApi.getHabitWeekly(id);
  }

  Future<Map<String, dynamic>> getHabitMonthly(String id) {
    return _habitsApi.getHabitMonthly(id);
  }
}