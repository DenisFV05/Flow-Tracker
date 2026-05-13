import 'dart:convert';

class ImageValidator {
  static bool isValidBase64Image(String input) {
    try {
      if (!input.startsWith('data:image/')) return false;
      
      final parts = input.split(',');
      if (parts.length != 2) return false;
      
      final base64Data = parts[1];
      final bytes = base64Decode(base64Data);
      
      if (bytes.length > 2 * 1024 * 1024) return false;
      
      final signatures = {
        'png': [0x89, 0x50, 0x4E, 0x47],
        'jpeg': [0xFF, 0xD8, 0xFF],
        'jpg': [0xFF, 0xD8, 0xFF],
        'gif': [0x47, 0x49, 0x46],
        'webp': [0x52, 0x49, 0x46, 0x46],
      };
      
      final extension = _getExtension(input);
      final expectedSignature = signatures[extension];
      
      if (expectedSignature != null) {
        final firstBytes = bytes.sublist(0, expectedSignature.length);
        if (!_matchesSignature(firstBytes, expectedSignature)) {
          return false;
        }
      }
      
      return true;
    } catch (_) {
      return false;
    }
  }
  
  static String? _getExtension(String input) {
    final match = RegExp(r'data:image/(\w+);').firstMatch(input);
    return match?.group(1)?.toLowerCase();
  }
  
  static bool _matchesSignature(List<int> bytes, List<int> signature) {
    if (bytes.length < signature.length) return false;
    for (int i = 0; i < signature.length; i++) {
      if (bytes[i] != signature[i]) return false;
    }
    return true;
  }
}