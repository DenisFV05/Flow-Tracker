import 'package:flutter/material.dart';
import '../services/auth_storage.dart';
import '../utils/settings_manager.dart';

class AppConfig extends ChangeNotifier {
  static final AppConfig _instance = AppConfig._internal();
  factory AppConfig() => _instance;
  AppConfig._internal();

  static AppConfig get instance => _instance;

  String _serverUrl = 'http://localhost:3000';
  String? _token;

  String get serverUrl => _serverUrl;
  String? get token => _token;
  bool get isAuthenticated => _token != null && _token!.isNotEmpty;

  Future<void> load() async {
    final settings = await SettingsManager.loadSettings();
    if (settings['serverUrl'] != null && settings['serverUrl']!.isNotEmpty) {
      _serverUrl = settings['serverUrl']!;
    }
    _token = settings['token'];
    if (_token == null || _token!.isEmpty) {
      final storedToken = await AuthStorage().getToken();
      _token = storedToken;
    }
    notifyListeners();
  }

  Future<void> login({
    required String serverUrl,
    required String token,
  }) async {
    _serverUrl = serverUrl;
    _token = token;
    await SettingsManager.saveSettings(serverUrl: serverUrl, token: token);
    await AuthStorage().saveToken(token);
    notifyListeners();
  }

  Future<void> logout() async {
    _token = null;
    await SettingsManager.clearToken();
    await AuthStorage().clear();
    notifyListeners();
  }

  Future<void> updateServerUrl(String url) async {
    _serverUrl = url;
    await SettingsManager.saveSettings(serverUrl: url, token: _token);
    notifyListeners();
  }
}
