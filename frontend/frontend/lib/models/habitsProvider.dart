import 'package:flutter/material.dart';
import '../services/habits_service.dart';
import '../services/feed_service.dart';
import '../services/profile_service.dart';

class HabitProvider extends ChangeNotifier {
  final HabitsApi api =
      HabitsApi("https://flow-tracker.ieti.site");
  final FeedApi feedApi =
      FeedApi("https://flow-tracker.ieti.site");
  final ProfileApi profileApi =
      ProfileApi("https://flow-tracker.ieti.site");

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

      // cargar hábitos
      habits = await api.getHabits();

      // cargar stats globales
      dashboardStats = await api.getProfileStats();

      // cargar stats por cada hábito
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
      print("FEED ERROR: $e");
    }
  }

  Future<void> loadProfile() async {
    try {
      profileLoading = true;
      notifyListeners();

      userProfile = await profileApi.getProfile();
    } catch (e) {
      print("PROFILE ERROR: $e");
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

  Future<void> addHabit(
    String name,
    String description,
    List<String> tags,
  ) async {
    try {
      await api.createHabit(name, description, tags);
      await loadDashboard();
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
}
