import 'dart:convert';
import 'dart:math';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'ai_service.dart';
import '../../../learning/data/models/quiz_question.dart';

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

  @override
  Future<List<QuizQuestion>> generateQuiz({
    required String topic,
    required String difficulty,
    required String language,
    required int count,
  }) async {
    if (apiKey.isEmpty) throw Exception('API Key not set');

    // Inject randomness to ensure variety
    final random = Random();
    final focusAreas = [
      'theoretical concepts',
      'practical applications',
      'historical context',
      'problem solving',
      'advanced nuances',
      'fundamental principles',
      'real-world examples',
      'comparative analysis'
    ];
    final focus = focusAreas[random.nextInt(focusAreas.length)];
    final seed = random.nextInt(1000000);

    final prompt = '''
    Generate $count unique and diverse multiple-choice questions on "$topic" (Difficulty: $difficulty) in $language.
    Focus area: $focus.
    Random seed: $seed (Use this to vary the questions from previous requests).
    
    Format the output as a JSON list of objects.
    Each object must have:
    - "question": The question text (use LaTeX for math, enclosed in \$...\$).
    - "options": A list of 4 string options (use LaTeX for math, enclosed in \$...\$).
    - "correctIndex": The integer index (0-3) of the correct option.
    - "explanation": A brief explanation of the answer.
    
    IMPORTANT: Escape all backslashes in the JSON string. For example, use "\\\\int" instead of "\\int", and "\\\\," instead of "\\,".
    Do not include markdown code blocks (```json). Just the raw JSON array.
    ''';

    int attempts = 0;
    while (attempts < 3) {
      try {
        attempts++;
        final content = [Content.text(prompt)];
        final response = await _model.generateContent(content);
        var text = response.text?.replaceAll('```json', '').replaceAll('```', '').trim() ?? '[]';
        
        // Aggressive sanitization
        text = _sanitizeJson(text);
        
        final List<dynamic> jsonList = jsonDecode(text);
        return jsonList.map((json) => QuizQuestion.fromJson(json)).toList();
      } catch (e) {
        print('Gemini Quiz Error (Attempt $attempts): $e');
        if (attempts == 3) return [];
        await Future.delayed(const Duration(seconds: 1)); // Wait before retry
      }
    }
    return [];
  }

  String _sanitizeJson(String text) {
    // Robust Sanitization:
    // 1. Match valid double backslashes (\\) and preserve them.
    // 2. Match invalid single backslashes (not followed by valid escape chars) and double them.
    
    // Pattern:
    // Group 1: \\\\ (matches \\)
    // Group 2: \\ (matches \) followed by negative lookahead for valid escapes
    // Valid escapes: / " \ b f n r t uXXXX
    // Note: u is only valid if followed by 4 hex digits.
    
    final regex = RegExp(r'(\\\\)|(\\)(?![/\\bfnrt"]|u[0-9a-fA-F]{4})');
    
    String sanitized = text.replaceAllMapped(regex, (match) {
      if (match.group(1) != null) {
        // Matched valid double backslash, keep it
        return r'\\';
      }
      // Matched invalid single backslash, double it
      return r'\\';
    });
    
    return sanitized;
  }
}
