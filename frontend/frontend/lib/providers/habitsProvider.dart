import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/habit.dart';
import '../models/User.dart';

class HabitProvider extends ChangeNotifier {
  String? _serverUrl;
  String? _token;
  List<Habit> _habits = [];
  User? _user;
  bool _loading = false;
  String? _error;

  void init(String serverUrl, String token) {
    _serverUrl = serverUrl;
    _token = token;
  }

  Map<String, String> get _headers => {
    'Content-Type': 'application/json',
    'Authorization': 'Bearer $_token',
  };

  List<Habit> get habits => _habits;
  bool get loading => _loading;
  String? get error => _error;
  User? get user => _user;

  Future<void> loadHabits() async {
    if (_serverUrl == null || _token == null) return;
    
    _loading = true;
    _error = null;
    notifyListeners();

    try {
      final profileRes = await http.get(
        Uri.parse('$_serverUrl/api/profile'),
        headers: _headers,
      );
      if (profileRes.statusCode == 200) {
        final profileData = jsonDecode(profileRes.body);
        _user = User(
          id: profileData['id'] ?? '',
          name: profileData['name'] ?? 'Usuari',
          email: profileData['email'] ?? '',
        );
      }

      final habitsRes = await http.get(
        Uri.parse('$_serverUrl/api/habits'),
        headers: _headers,
      );
      
      if (habitsRes.statusCode == 200) {
        final List data = jsonDecode(habitsRes.body);
        _habits = data.map((h) => Habit.fromJson(h)).toList();
      }
    } catch (e) {
      _error = e.toString();
    }

    _loading = false;
    notifyListeners();
  }

  Future<void> addHabit(String name, String? desc, List<String> tags) async {
    if (_serverUrl == null || _token == null) return;
    
    try {
      final res = await http.post(
        Uri.parse('$_serverUrl/api/habits'),
        headers: _headers,
        body: jsonEncode({'name': name, 'description': desc, 'tags': tags}),
      );
      
      if (res.statusCode == 201) {
        final habit = Habit.fromJson(jsonDecode(res.body));
        _habits.insert(0, habit);
        notifyListeners();
      }
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> updateHabit(String id, String name, String? desc, List<String> tags) async {
    if (_serverUrl == null || _token == null) return;
    
    try {
      final res = await http.put(
        Uri.parse('$_serverUrl/api/habits/$id'),
        headers: _headers,
        body: jsonEncode({'name': name, 'description': desc, 'tags': tags}),
      );
      
      if (res.statusCode == 200) {
        final updated = Habit.fromJson(jsonDecode(res.body));
        final idx = _habits.indexWhere((h) => h.id == id);
        if (idx != -1) {
          _habits[idx] = updated;
          notifyListeners();
        }
      }
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> removeHabit(String id) async {
    if (_serverUrl == null || _token == null) return;
    
    try {
      await http.delete(
        Uri.parse('$_serverUrl/api/habits/$id'),
        headers: _headers,
      );
      _habits.removeWhere((h) => h.id == id);
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> toggleHabitCompletion(String id, String date) async {
    if (_serverUrl == null || _token == null) return;
    
    final idx = _habits.indexWhere((h) => h.id == id);
    if (idx == -1) return;

    final habit = _habits[idx];
    final newCompleted = !habit.completedToday;

    try {
      await http.post(
        Uri.parse('$_serverUrl/api/habits/$id/log'),
        headers: _headers,
        body: jsonEncode({'date': date, 'completed': newCompleted}),
      );
      _habits[idx] = habit.copyWith(completedToday: newCompleted);
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  List<Habit> get todayHabits => _habits;
}