import 'package:isar/isar.dart';
import 'quiz_question.dart';

part 'saved_exam.g.dart';

@collection
class SavedExam {
  Id id = Isar.autoIncrement;

  late String topic;
  late int score;
  late int totalQuestions;
  late DateTime date;
  
  // Embedded list of questions to preserve the exact exam taken
  late List<QuizQuestionEmbedded> questions;
  
  late String language;
}

@embedded
class QuizQuestionEmbedded {
  late String question;
  late List<String> options;
  late int correctIndex;
  late String explanation;
  
  // Optional: record user's answer if we want to show what they selected
  int? userAnswerIndex;
}
