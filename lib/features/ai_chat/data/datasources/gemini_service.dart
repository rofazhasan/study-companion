import 'package:google_generative_ai/google_generative_ai.dart';
import 'ai_service.dart';

class GeminiService implements AIService {
  late final GenerativeModel _model;
  final String apiKey;
  
  // API key should be provided by the user in app settings
  // NEVER commit actual API keys to version control
  GeminiService({required this.apiKey}) {
    _model = GenerativeModel(
      model: 'gemini-2.0-flash',
      apiKey: apiKey.isEmpty ? 'INVALID_KEY_PLEASE_SET_IN_SETTINGS' : apiKey,
    );
  }

  @override
  Stream<String> generateResponse(String prompt) async* {
    if (apiKey.isEmpty) {
      yield "⚠️ Please set your Gemini API key in Settings to use AI features.\n\n"
            "1. Go to Settings\n"
            "2. Tap 'AI Configuration'\n"
            "3. Enter your API key from https://aistudio.google.com/apikey";
      return;
    }

    try {
      final content = [Content.text(prompt)];
      final response = _model.generateContentStream(content);
      
      await for (final chunk in response) {
        if (chunk.text != null) {
          yield chunk.text!;
        }
      }
    } catch (e) {
      if (e.toString().contains('API_KEY_INVALID') || e.toString().contains('400')) {
        yield "❌ Invalid API key. Please check your API key in Settings.\n\n"
              "Get a valid key from: https://aistudio.google.com/apikey";
      } else {
        yield "Error generating response: $e";
      }
    }
  }
}
