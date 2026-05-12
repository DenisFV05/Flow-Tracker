import 'package:flutter/material.dart';
import '../services/habits_service.dart';

class HabitProvider extends ChangeNotifier {
  final HabitsApi _habitsApi = HabitsApi();

  List<dynamic> habits = [];
  Map<String, dynamic> dashboardStats = {};
  Map<String, dynamic> habitStats = {};
  
  bool loading = false;
  String? error;

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

  Future<void> addHabit(String name, String description, List<String> tags) async {
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

// Dentro de HabitProvider
  Future<void> logHabit(String id, String date) async {
    try {
      await _habitsApi.logHabit(id, date, true);
      await loadDashboard(); 
    } catch (e) {
      error = e.toString();
      notifyListeners();
    }
  }
}

