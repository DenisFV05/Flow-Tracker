import 'package:flutter/material.dart';
import '../models/habit.dart';
import '../models/mockHabits.dart';

class HabitProvider extends ChangeNotifier {
  List<Habit> _habits = mockHabits;

  List<Habit> get habits => _habits;

  void addHabit(Habit habit) {
    _habits.add(habit);
    notifyListeners();
  }

  void toggleHabit(String id) {
    final index = _habits.indexWhere((h) => h.id == id);

    if (index != -1) {
      _habits[index] = _habits[index].copyWith(
        completedToday: !_habits[index].completedToday,
      );
      notifyListeners();
    }
  }

  void removeHabit(String id) {
    _habits.removeWhere((h) => h.id == id);
    notifyListeners();
  }
}
