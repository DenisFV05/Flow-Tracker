import 'package:flutter/material.dart';
import '../services/habits_service.dart';
import '../services/feed_service.dart';
import '../services/profile_service.dart';

class HabitProvider extends ChangeNotifier {
  final HabitsApi api = HabitsApi();
  final FeedApi feedApi = FeedApi();
  final ProfileApi profileApi = ProfileApi();

  List<dynamic> habits = [];

  Map<String, dynamic> dashboardStats = {};

  Map<String, dynamic> habitStats = {};

  List<dynamic> feedPosts = [];
  String? feedNextCursor;

  Map<String, dynamic> userProfile = {};
  bool profileLoading = false;

  bool loading = false;
  String? error;

  Future<void> loadDashboard() async {
    try {
      loading = true;
      error = null;
      notifyListeners();

      habits = await api.getHabits();

      dashboardStats = await api.getProfileStats();

      for (final habit in habits) {
        final habitId = habit['id'];
        final stats = await api.getHabitStats(habitId);
        habitStats[habitId] = stats;
      }

    } catch (e) {
      error = e.toString();
      print("DASHBOARD ERROR: $e");
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  Future<void> loadFeed({String? cursor}) async {
    try {
      final result = await feedApi.getFeed(cursor: cursor);
      
      if (cursor == null) {
        feedPosts = result['posts'] as List<dynamic>;
      } else {
        feedPosts.addAll(result['posts'] as List<dynamic>);
      }
      
      feedNextCursor = result['nextCursor'] as String?;
      notifyListeners();
    } catch (e) {
      error = e.toString();
      notifyListeners();
    }
  }

  Future<void> loadProfile() async {
    try {
      profileLoading = true;
      notifyListeners();

      userProfile = await profileApi.getProfile();
    } catch (e) {
      error = e.toString();
    } finally {
      profileLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateProfile({String? name, String? avatar}) async {
    try {
      userProfile = await profileApi.updateProfile(
        name: name,
        avatar: avatar,
      );
      notifyListeners();
    } catch (e) {
      print("UPDATE PROFILE ERROR: $e");
      rethrow;
    }
  }

  Future<Map<String, dynamic>> addHabit(
    String name,
    String description,
    List<String> tags,
  ) async {
    try {
      final result = await api.createHabit(name, description, tags);
      await loadDashboard();
      return result;
    } catch (e) {
      error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  Future<void> editHabit(
    String id,
    String name,
    String description,
    List<String> tags,
  ) async {
    try {
      await api.updateHabit(id, name, description, tags);
      await loadDashboard();
    } catch (e) {
      error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  Future<void> deleteHabit(String id) async {
    try {
      await api.deleteHabit(id);
      await loadDashboard();
    } catch (e) {
      error = e.toString();
      notifyListeners();
      rethrow;
    }
  }
  Future<void> updateHabit(
    String id,
    String name,
    String description,
    List<String> tags,
  ) async {
    try {
      await api.updateHabit(
        id,
        name,
        description,
        tags,
      );

      await loadDashboard();
    } catch (e) {
      error = e.toString();
      notifyListeners();
    }
  }


  Future<void> deleteHabit(String id) async {
    try {
      await api.deleteHabit(id);

      habits.removeWhere((h) => h['id'].toString() == id);

      habitStats.remove(id); // opcional pero recomendable

      notifyListeners();
    } catch (e) {
      error = e.toString();
      notifyListeners();
    }
  }


  Future<void> toggleHabit(String id, bool completed) async {
    try {
      await api.toggleHabit(id, completed);
      await loadDashboard();
    } catch (e) {
      error = e.toString();
      notifyListeners();
    }
  }

  Future<Map<String, dynamic>> getHabitHeatmap(String id, {int? year}) async {
    return await api.getHabitHeatmap(id, year: year);
  }

  Future<Map<String, dynamic>> getHabitWeekly(String id) async {
    return await api.getHabitWeekly(id);
  }

  Future<Map<String, dynamic>> getHabitMonthly(String id) async {
    return await api.getHabitMonthly(id);
  }
}
