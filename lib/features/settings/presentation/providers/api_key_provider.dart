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
      return storedKey;
    }
    // Return the hardcoded key if no user key is set
    final key = ApiConfig.geminiApiKey;
    print('DEBUG: Decrypted API Key: $key');
    return key;
  }

  Future<void> setApiKey(String apiKey) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyGeminiApiKey, apiKey);
    state = AsyncValue.data(apiKey);
  }

  Future<void> clearApiKey() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyGeminiApiKey);
    // Revert to hardcoded key
    state = AsyncValue.data(ApiConfig.geminiApiKey);
  }
}
