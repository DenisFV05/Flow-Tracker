import 'package:flutter/material.dart';
import '../services/habits_service.dart';

class HabitProvider extends ChangeNotifier {
  final HabitsApi api =
      HabitsApi("https://flow-tracker.ieti.site");

  List<dynamic> habits = [];
  bool loading = false;
  String? error;

  // -------------------------
  // 📥 LOAD HABITS
  // -------------------------
  Future<void> loadHabits() async {
    try {
      loading = true;
      error = null;
      notifyListeners();

      habits = await api.getHabits();
    } catch (e) {
      error = e.toString();
      print("LOAD HABITS ERROR: $e");
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  // -------------------------
  // ➕ ADD HABIT
  // -------------------------
  Future<void> addHabit(
    String name,
    String description,
    List<String> tags,
  ) async {
    try {
      await api.createHabit(name, description, tags);
      await loadHabits();
    } catch (e) {
      error = e.toString();
      notifyListeners();
    }
  }

  // -------------------------
  // 🔁 TOGGLE HABIT
  // -------------------------
  Future<void> toggleHabit(String id, bool completed) async {
    try {
      await api.toggleHabit(id, completed);
      await loadHabits();
    } catch (e) {
      error = e.toString();
      notifyListeners();
    }
  }
}
