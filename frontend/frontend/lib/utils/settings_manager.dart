import 'dart:io';
import 'dart:convert';
import 'package:path_provider/path_provider.dart';

class SettingsManager {
  static const String _fileName = 'settings.json';
  
  // Guardar configuración (URL del servidor y token)
  static Future<void> saveSettings({
    required String serverUrl,
    String? token,
  }) async {
    try {
      final file = await _getSettingsFile();
      
      final settings = {
        'serverUrl': serverUrl,
        'token': token,
      };
      
      await file.writeAsString(jsonEncode(settings));
    } catch (e) {
      print('Error saving settings: $e');
      rethrow;
    }
  }
  
  // Cargar configuración
  static Future<Map<String, String?>> loadSettings() async {
    try {
      final file = await _getSettingsFile();
      
      if (!await file.exists()) {
        return {'serverUrl': null, 'token': null};
      }
      
      final contents = await file.readAsString();
      final Map<String, dynamic> data = jsonDecode(contents);
      
      return {
        'serverUrl': data['serverUrl'] as String?,
        'token': data['token'] as String?,
      };
    } catch (e) {
      print('Error loading settings: $e');
      return {'serverUrl': null, 'token': null};
    }
  }
  
  // Limpiar solo el token (para logout)
  static Future<void> clearToken() async {
    try {
      final settings = await loadSettings();
      final serverUrl = settings['serverUrl'];
      
      if (serverUrl != null) {
        await saveSettings(serverUrl: serverUrl, token: null);
      }
    } catch (e) {
      print('Error clearing token: $e');
      rethrow;
    }
  }
  
  // Obtener el archivo settings.json
  static Future<File> _getSettingsFile() async {
    final directory = await getApplicationDocumentsDirectory();
    return File('${directory.path}/$_fileName');
  }
}

