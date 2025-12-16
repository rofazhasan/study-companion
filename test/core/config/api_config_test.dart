import 'package:flutter_test/flutter_test.dart';
import 'package:study_companion/core/config/api_config.dart';

void main() {
  group('ApiConfig Encryption', () {
    test('Encrypting and decrypting a string returns the original string', () {
      const original = 'AIzaSyTestKey123456';
      final encrypted = ApiConfig.encrypt(original);
      
      expect(encrypted, isNot(equals(original)));
      expect(encrypted, isNotEmpty);
      
      final decrypted = ApiConfig.decrypt(encrypted);
      expect(decrypted, equals(original));
    });

    test('Decrypting invalid data returns empty string', () {
      final decrypted = ApiConfig.decrypt('InvalidBase64%%');
      expect(decrypted, isEmpty);
    });

    test('Decrypting empty string returns empty string', () {
      expect(ApiConfig.decrypt(''), isEmpty);
    });

    test('Hardcoded key is accessible', () {
      expect(ApiConfig.geminiApiKey, isNotEmpty);
    });
  });
}
