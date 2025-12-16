import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/config/api_config.dart';

part 'api_key_provider.g.dart';

@riverpod
class ApiKey extends _$ApiKey {
  static const String _keyGeminiApiKey = 'gemini_api_key';

  @override
  Future<String> build() async {
    final prefs = await SharedPreferences.getInstance();
    final storedKey = prefs.getString(_keyGeminiApiKey);
    if (storedKey != null && storedKey.isNotEmpty) {
      // Try to decrypt the stored key
      final decrypted = ApiConfig.decrypt(storedKey);
      if (decrypted.isNotEmpty) {
          return decrypted;
      }
      // If decryption failed (empty), it might be an old plain text key or invalid.
      // We could try to return storedKey if it looks like a key, but for security, 
      // let's assume we need a fresh start or it was just invalid.
      // Actually, to be user friendly during migration: 
      // if decrypt fails, check if the raw string looks like a key (starts with AIza). 
      // If so, maybe migrate it? 
      // Risk: "AIza" might occur in random bytes? Unlikely.
      // Let's keep it simple: if decrypt fails, ignore it. User re-enters.
    }
    // Return the hardcoded key if no user key is set
    final key = ApiConfig.geminiApiKey;
    return key;
  }

  Future<void> setApiKey(String apiKey) async {
    final prefs = await SharedPreferences.getInstance();
    final encrypted = ApiConfig.encrypt(apiKey);
    await prefs.setString(_keyGeminiApiKey, encrypted);
    state = AsyncValue.data(apiKey);
  }

  Future<void> clearApiKey() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyGeminiApiKey);
    // Revert to hardcoded key
    state = AsyncValue.data(ApiConfig.geminiApiKey);
  }
}
