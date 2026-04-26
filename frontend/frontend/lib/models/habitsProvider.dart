import 'package:flutter/material.dart';
import '../services/habits_service.dart';

class HabitProvider extends ChangeNotifier {
  final HabitsApi api =
      HabitsApi("https://flow-tracker.ieti.site");

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
