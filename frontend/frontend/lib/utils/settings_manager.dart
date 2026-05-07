import 'dart:io';
import 'dart:convert';
import 'package:path_provider/path_provider.dart';

class SettingsManager {
  static const String _fileName = 'settings.json';
  
  static Future<void> saveSettings({
    required String serverUrl,
  }) async {
    try {
      final file = await _getSettingsFile();
      
      final settings = {
        'serverUrl': serverUrl,
      };
      
      await file.writeAsString(jsonEncode(settings));
    } catch (e) {
      print('Error saving settings: $e');
      rethrow;
    }
  }
  
  static Future<Map<String, String?>> loadSettings() async {
    try {
      final file = await _getSettingsFile();
      
      if (!await file.exists()) {
        return {'serverUrl': null};
      }
      
      final contents = await file.readAsString();
      final Map<String, dynamic> data = jsonDecode(contents);
      
      return {
        'serverUrl': data['serverUrl'] as String?,
      };
    } catch (e) {
      print('Error loading settings: $e');
      return {'serverUrl': null};
    }
  }
  
  // Obtener el archivo settings.json
  static Future<File> _getSettingsFile() async {
    final directory = await getApplicationDocumentsDirectory();
    return File('${directory.path}/$_fileName');
  }
}

