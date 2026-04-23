import 'package:flutter/material.dart';
import '../models/habit.dart';
import '../services/api_service.dart';

class HabitProvider extends ChangeNotifier {
  final ApiService _api;
  List<Habit> _habits = [];
  bool _loading = false;
  String? _error;

  HabitProvider(this._api);

  List<Habit> get habits => _habits;
  bool get loading => _loading;
  String? get error => _error;

  Future<void> loadHabits() async {
    _loading = true;
    _error = null;
    notifyListeners();

    try {
      _habits = await _api.getHabits();
    } catch (e) {
      _error = e.toString();
    }

    _loading = false;
    notifyListeners();
  }

  Future<void> addHabit(String name, String? desc, List<String> tags) async {
    try {
      final habit = await _api.createHabit(name, desc, tags);
      _habits.insert(0, habit);
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> updateHabit(String id, String name, String? desc, List<String> tags) async {
    try {
      final updated = await _api.updateHabit(id, name, desc, tags);
      final idx = _habits.indexWhere((h) => h.id == id);
      if (idx != -1) {
        _habits[idx] = updated;
        notifyListeners();
      }
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> removeHabit(String id) async {
    try {
      await _api.deleteHabit(id);
      _habits.removeWhere((h) => h.id == id);
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> toggleHabitCompletion(String id, String date) async {
    final idx = _habits.indexWhere((h) => h.id == id);
    if (idx == -1) return;

    final habit = _habits[idx];
    final newCompleted = !habit.completedToday;

    try {
      await _api.logHabit(id, date, newCompleted);
      _habits[idx] = habit.copyWith(completedToday: newCompleted);
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  List<Habit> get todayHabits => _habits;
}