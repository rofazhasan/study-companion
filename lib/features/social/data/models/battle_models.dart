import 'package:cloud_firestore/cloud_firestore.dart';

enum BattleStatus { waiting, starting, inProgress, completed }

class BattleSession {
  final String id;
  final String creatorId;
  final String topic;
  final String language;
  final int questionCount;
  final int timePerQuestion;
  final String joinCode;
  final BattleStatus status;
  final List<BattlePlayer> players;
  final List<BattleQuestion> questions; // Embedded questions!
  final int currentQuestionIndex;
  final DateTime? startTime; // Time when the current question started

  BattleSession({
    required this.id,
    required this.creatorId,
    required this.topic,
    required this.language,
    required this.questionCount,
    required this.timePerQuestion,
    required this.joinCode,
    required this.status,
    required this.players,
    required this.questions,
    required this.currentQuestionIndex,
    this.startTime,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'creatorId': creatorId,
      'topic': topic,
      'language': language,
      'questionCount': questionCount,
      'timePerQuestion': timePerQuestion,
      'joinCode': joinCode,
      'status': status.name,
      'players': players.map((p) => p.toMap()).toList(),
      'questions': questions.map((q) => q.toMap()).toList(),
      'currentQuestionIndex': currentQuestionIndex,
      'startTime': startTime?.toIso8601String(),
    };
  }

  factory BattleSession.fromMap(Map<String, dynamic> map) {
    return BattleSession(
      id: map['id'] ?? '',
      creatorId: map['creatorId'] ?? '',
      topic: map['topic'] ?? '',
      language: map['language'] ?? 'en',
      questionCount: map['questionCount'] ?? 5,
      timePerQuestion: map['timePerQuestion'] ?? 30,
      joinCode: map['joinCode'] ?? '',
      status: BattleStatus.values.firstWhere(
        (e) => e.name == map['status'],
        orElse: () => BattleStatus.waiting,
      ),
      players: List<BattlePlayer>.from(
        (map['players'] ?? []).map((x) => BattlePlayer.fromMap(x)),
      ),
      questions: List<BattleQuestion>.from(
        (map['questions'] ?? []).map((x) => BattleQuestion.fromMap(x)),
      ),
      currentQuestionIndex: map['currentQuestionIndex'] ?? 0,
      startTime: map['startTime'] != null ? DateTime.parse(map['startTime']) : null,
    );
  }
}

class BattlePlayer {
  final String userId;
  final String name;
  final String? avatarUrl;
  final int score;
  final int streak;
  final bool hasAnswered; // For the current question
  final double answerTime; // For the current question
  final bool isBot;
  final Map<String, int> answers; // questionId -> selectedOptionIndex
  final Map<String, double> answerTimes; // questionId -> timeTaken

  BattlePlayer({
    required this.userId,
    required this.name,
    this.avatarUrl,
    this.score = 0,
    this.streak = 0,
    this.hasAnswered = false,
    this.answerTime = 0.0,
    this.isBot = false,
    this.answers = const {},
    this.answerTimes = const {},
  });

  BattlePlayer copyWith({
    String? userId,
    String? name,
    String? avatarUrl,
    int? score,
    int? streak,
    bool? hasAnswered,
    double? answerTime,
    bool? isBot,
    Map<String, int>? answers,
    Map<String, double>? answerTimes,
  }) {
    return BattlePlayer(
      userId: userId ?? this.userId,
      name: name ?? this.name,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      score: score ?? this.score,
      streak: streak ?? this.streak,
      hasAnswered: hasAnswered ?? this.hasAnswered,
      answerTime: answerTime ?? this.answerTime,
      isBot: isBot ?? this.isBot,
      answers: answers ?? this.answers,
      answerTimes: answerTimes ?? this.answerTimes,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'name': name,
      'avatarUrl': avatarUrl,
      'score': score,
      'streak': streak,
      'hasAnswered': hasAnswered,
      'answerTime': answerTime,
      'isBot': isBot,
      'answers': answers,
      'answerTimes': answerTimes,
    };
  }

  factory BattlePlayer.fromMap(Map<String, dynamic> map) {
    return BattlePlayer(
      userId: map['userId'] ?? map['id'] ?? '', // Handle both for safety
      name: map['name'] ?? 'Unknown',
      avatarUrl: map['avatarUrl'],
      score: map['score'] ?? 0,
      streak: map['streak'] ?? 0,
      hasAnswered: map['hasAnswered'] ?? false,
      answerTime: (map['answerTime'] ?? 0).toDouble(),
      isBot: map['isBot'] ?? false,
      answers: Map<String, int>.from(map['answers'] ?? {}),
      answerTimes: Map<String, double>.from(map['answerTimes'] ?? {}),
    );
  }
}

class BattleQuestion {
  final String id;
  final String question;
  final List<String> options;
  final int correctIndex;
  final String explanation;

  BattleQuestion({
    required this.id,
    required this.question,
    required this.options,
    required this.correctIndex,
    required this.explanation,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'question': question,
      'options': options,
      'correctIndex': correctIndex,
      'explanation': explanation,
    };
  }

  factory BattleQuestion.fromMap(Map<String, dynamic> map) {
    return BattleQuestion(
      id: map['id'] ?? '',
      question: map['question'] ?? '',
      options: List<String>.from(map['options'] ?? []),
      correctIndex: map['correctIndex'] ?? 0,
      explanation: map['explanation'] ?? '',
    );
  }
}
