import '../../../learning/data/models/quiz_question.dart';

abstract class AIService {
  Stream<String> generateResponse(String prompt);
  Future<List<QuizQuestion>> generateQuiz({
    required String topic,
    required String difficulty,
    required String language,
    required int count,
  });
}
