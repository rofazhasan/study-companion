import 'dart:async';
import 'ai_service.dart';

import '../../../learning/data/models/quiz_question.dart';

class MockAIService implements AIService {
  @override
  Stream<String> generateResponse(String prompt) async* {
    await Future.delayed(const Duration(milliseconds: 500));
    yield "I am currently offline. Please download an AI model in Settings to enable smart features.";
  }

  @override
  Future<List<QuizQuestion>> generateQuiz({
    required String topic,
    required String difficulty,
    required String language,
    required int count,
  }) async {
    return [
      QuizQuestion(
        question: "Mock Question about $topic",
        options: ["Option A", "Option B", "Option C", "Option D"],
        correctIndex: 0,
        explanation: "This is a mock explanation.",
      )
    ];
  }
}
