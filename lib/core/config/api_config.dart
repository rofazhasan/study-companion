class ApiConfig {
  static const List<int> _encryptedKey = [18, 61, 15, 5, 42, 58, 45, 24, 65, 13, 11, 13, 54, 27, 85, 119, 116, 67, 17, 22, 7, 33, 16, 5, 59, 41, 54, 5, 49, 91, 24, 59, 107, 3, 121, 120, 28, 2, 44];
  static const String _secret = 'StudyCompanion2024';

  static String get geminiApiKey {
    final List<int> decrypted = [];
    final secretBytes = _secret.codeUnits;
    
    for (var i = 0; i < _encryptedKey.length; i++) {
      decrypted.add(_encryptedKey[i] ^ secretBytes[i % secretBytes.length]);
    }
    
    return String.fromCharCodes(decrypted);
  }
}
