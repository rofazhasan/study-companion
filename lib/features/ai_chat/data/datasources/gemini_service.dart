import 'package:google_generative_ai/google_generative_ai.dart';
import 'ai_service.dart';

class GeminiService implements AIService {
  late final GenerativeModel _model;
  
  // API key should be provided by the user in app settings or via environment configuration
  // NEVER commit actual API keys to version control
  static const _apiKey = ''; // Users must provide their own Gemini API key in settings

  GeminiService() {
    _model = GenerativeModel(
      model: 'gemini-2.5-flash',
      apiKey: _apiKey.isEmpty ? 'YOUR_GEMINI_API_KEY_HERE' : _apiKey,
    );
  }

  @override
  Stream<String> generateResponse(String prompt) async* {
    try {
      final content = [Content.text(prompt)];
      final response = _model.generateContentStream(content);
      
      await for (final chunk in response) {
        if (chunk.text != null) {
          yield chunk.text!;
        }
      }
    } catch (e) {
      yield "Error generating response: $e";
    }
  }
}
