import 'package:flutter/material.dart';
import '../services/habits_service.dart';

class HabitProvider extends ChangeNotifier {
  final HabitsApi _habitsApi = HabitsApi();

  List<dynamic> habits = [];
  Map<String, dynamic> dashboardStats = {};
  Map<String, dynamic> habitStats = {};
  Map<String, List<dynamic>> habitHeatmaps = {};
  
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
        final id = habit['id'].toString();
        habitStats[id] = await _habitsApi.getHabitStats(id);
        try {
          final response = await _habitsApi.getHabitHeatmap(id, year: DateTime.now().year);
          habitHeatmaps[id] = response['data'] as List<dynamic>;
        } catch (_) {
          habitHeatmaps[id] = [];
        }
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
    // Optimistic update per UI instantània
    final previousCompleted = habitStats[id]?['completedToday'] == true;
    if (habitStats[id] != null) {
      habitStats[id]['completedToday'] = completed;
    }

    // Actualitzar també dashboardStats optimísticament per TodayProgress
    if (dashboardStats['todayCompletedHabitIds'] != null) {
      final List<dynamic> currentIds = List.from(dashboardStats['todayCompletedHabitIds']);
      final idStr = id.toString();
      
      // Comprovar si hi és com a string o com a int
      bool exists = currentIds.contains(idStr) || currentIds.contains(int.tryParse(idStr));
      
      if (completed) {
        if (!exists) currentIds.add(idStr);
      } else {
        currentIds.remove(idStr);
        currentIds.remove(int.tryParse(idStr));
        currentIds.removeWhere((item) => item.toString() == idStr);
      }
      dashboardStats['todayCompletedHabitIds'] = currentIds;
    }
    
    notifyListeners();

    try {
      await _habitsApi.toggleHabit(id, completed);
      
      // Actualització en segon pla (sense bloquejar ni mostrar loading circular)
      _habitsApi.getProfileStats().then((stats) {
        dashboardStats = stats;
        notifyListeners();
      }).catchError((_) {});

      _habitsApi.getHabitStats(id).then((stats) {
        habitStats[id.toString()] = stats;
        notifyListeners();
      }).catchError((_) {});

    } catch (e) {
      // Revertir si falla
      if (habitStats[id] != null) {
        habitStats[id]['completedToday'] = previousCompleted;
        notifyListeners();
      }
      error = e.toString();
      notifyListeners();
    }
  }

  Future<void> logHabit(String id, String date) async {
    try {
      await _habitsApi.logHabit(id, date, true);
      
      // Actualització en segon pla específica per aquest hàbit
      _habitsApi.getProfileStats().then((stats) {
        dashboardStats = stats;
        notifyListeners();
      }).catchError((_) {});

      _habitsApi.getHabitStats(id).then((stats) {
        habitStats[id.toString()] = stats;
        notifyListeners();
      }).catchError((_) {});
      
    } catch (e) {
      error = e.toString();
      notifyListeners();
    }
  }
}

