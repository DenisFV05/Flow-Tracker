import 'package:shared_preferences/shared_preferences.dart';

class SettingsManager {
  static const String _keyServerUrl = 'serverUrl';
  
  static Future<void> saveSettings({
    required String serverUrl,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_keyServerUrl, serverUrl);
    } catch (e) {
      print('Error saving settings: $e');
    }
  }
  
  static Future<Map<String, String?>> loadSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final serverUrl = prefs.getString(_keyServerUrl);
      
      return {
        'serverUrl': serverUrl,
      };
    } catch (e) {
      print('Error loading settings: $e');
      return {'serverUrl': null};
    }
  }
}

