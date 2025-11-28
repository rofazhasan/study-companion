import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../../core/data/isar_service.dart';
import '../../../ai_chat/presentation/providers/chat_provider.dart';
import '../../data/datasources/quiz_service.dart';
import '../../data/models/quiz_question.dart';
import '../../../ai_chat/presentation/providers/chat_provider.dart';
import '../../data/datasources/quiz_service.dart';
import '../../data/models/quiz_question.dart';

part 'quiz_provider.g.dart';

@Riverpod(keepAlive: true)
class QuizNotifier extends _$QuizNotifier {
  @override
  Future<QuizState> build() async {
    return QuizState(questions: [], topic: '', language: 'English');
  }

  void reset() {
    state = AsyncValue.data(QuizState(questions: [], topic: '', language: 'English'));
  }

  Future<void> generateQuiz(String topic, {String difficulty = 'Medium', int count = 5, String language = 'English'}) async {
    print('Generating quiz for $topic, $difficulty, $count, $language');
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final aiService = ref.read(aiServiceProvider);
      final quizService = QuizService(aiService);
      final questions = await quizService.generateQuiz(topic, difficulty: difficulty, count: count, language: language);
      print('Generated ${questions.length} questions');
      return QuizState(questions: questions, topic: topic, language: language);
    });
  }
}

class QuizState {
  final List<QuizQuestion> questions;
  final String topic;
  final String language;

  QuizState({required this.questions, required this.topic, required this.language});
}
