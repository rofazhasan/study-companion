import 'dart:convert';

class ApiConfig {
  static const List<int> _encryptedKey = [18, 61, 15, 5, 42, 58, 45, 24, 65, 13, 11, 13, 54, 27, 85, 119, 116, 67, 17, 22, 7, 33, 16, 5, 59, 41, 54, 5, 49, 91, 24, 59, 107, 3, 121, 120, 28, 2, 44];
  static const String _secret = 'StudyCompanion2024';

  static String get geminiApiKey {
    return _decrypt(_encryptedKey);
  }

  static String encrypt(String plainText) {
    if (plainText.isEmpty) return '';
    final plainBytes = plainText.codeUnits;
    final secretBytes = _secret.codeUnits;
    final encrypted = <int>[];
    
    for (var i = 0; i < plainBytes.length; i++) {
        encrypted.add(plainBytes[i] ^ secretBytes[i % secretBytes.length]);
    }
    return base64Encode(encrypted);
  }

  static String decrypt(String encryptedText) {
      if (encryptedText.isEmpty) return '';
      try {
          final encryptedBytes = base64Decode(encryptedText);
          return _decrypt(encryptedBytes);
      } catch (e) {
          // Fallback if not base64 or other error (e.g. old plain text key)
          // Ideally we might want to return the text itself if it looks like a key, 
          // but for safety let's just fail or return empty causing a prompt to re-enter.
          return '';
      }
  }

  static String _decrypt(List<int> encryptedBytes) {
    final decrypted = <int>[];
    final secretBytes = _secret.codeUnits;
    
    for (var i = 0; i < encryptedBytes.length; i++) {
      decrypted.add(encryptedBytes[i] ^ secretBytes[i % secretBytes.length]);
    }
    
    return String.fromCharCodes(decrypted);
  }
}
