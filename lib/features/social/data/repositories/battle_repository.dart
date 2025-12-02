import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:uuid/uuid.dart';
import '../models/battle_models.dart';
import '../../../ai_chat/data/datasources/ai_service.dart';
import '../../../ai_chat/presentation/providers/chat_provider.dart';
import '../../../../core/data/isar_service.dart';
import '../models/battle_history.dart';

part 'battle_repository.g.dart';

@Riverpod(keepAlive: true)


@Riverpod(keepAlive: true)
BattleRepository battleRepository(BattleRepositoryRef ref) {
  return BattleRepository(ref.watch(aiServiceProvider), ref.watch(isarServiceProvider));
}

class BattleRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final AIService _aiService;
  final IsarService _isarService;
  final _uuid = const Uuid();

  BattleRepository(this._aiService, this._isarService);

  // --- 1. Create Battle (The "All-in-One" Method) ---
  Future<String> createBattle({
    required String creatorId,
    required String creatorName,
    required String topic,
    required String language,
    required int questionCount,
    required int timePerQuestion,
  }) async {
    final battleId = _uuid.v4();
    final joinCode = (100000 + Random().nextInt(900000)).toString();

    // 1. Generate Questions FIRST (Blocking)
    // This ensures we never have a battle without questions.
    final questions = await _aiService.generateQuiz(
      topic: topic,
      difficulty: 'Medium',
      language: language,
      count: questionCount,
    );

    if (questions.isEmpty) {
      throw Exception('Failed to generate questions. Please try again.');
    }

    final battleQuestions = questions.map((q) => BattleQuestion(
      id: _uuid.v4(),
      question: q.question,
      options: q.options,
      correctIndex: q.correctIndex,
      explanation: q.explanation,
    )).toList();

    // 2. Create the Session Object
    final session = BattleSession(
      id: battleId,
      creatorId: creatorId,
      topic: topic,
      language: language,
      questionCount: battleQuestions.length, // Use actual count
      timePerQuestion: timePerQuestion,
      joinCode: joinCode,
      status: BattleStatus.waiting,
      players: [
        BattlePlayer(userId: creatorId, name: creatorName),
      ],
      questions: battleQuestions, // EMBEDDED!
      currentQuestionIndex: 0,
    );

    // 3. Save to Firestore (Single Document)
    await _firestore.collection('battles').doc(battleId).set(session.toMap());
    
    return battleId;
  }

  // --- 2. Join Battle ---
  Future<String> joinBattle(String joinCode, String userId, String userName) async {
    // Simple query. No complex indexes needed.
    final query = await _firestore
        .collection('battles')
        .where('joinCode', isEqualTo: joinCode)
        .limit(1)
        .get();

    if (query.docs.isEmpty) {
      throw Exception('Invalid battle code');
    }

    final doc = query.docs.first;
    final battleId = doc.id;
    final data = doc.data();

    if (data['status'] != BattleStatus.waiting.name) {
       throw Exception('Battle already started or ended');
    }

    // Add player using arrayUnion (Atomic)
    final players = List<dynamic>.from(data['players'] ?? []);
    if (players.any((p) => p['userId'] == userId)) {
      return battleId; // Already joined
    }

    final newPlayer = BattlePlayer(userId: userId, name: userName);
    await _firestore.collection('battles').doc(battleId).update({
      'players': FieldValue.arrayUnion([newPlayer.toMap()]),
    });

    return battleId;
  }

  // --- 3. Stream Battle (The "Source of Truth") ---
  Stream<BattleSession> streamBattle(String battleId) {
    return _firestore.collection('battles').doc(battleId).snapshots().map((doc) {
      if (!doc.exists) throw Exception('Battle not found');
      return BattleSession.fromMap(doc.data()!);
    });
  }

  // --- 4. Game Logic (Host Only) ---
  Future<void> startBattle(String battleId) async {
    await _firestore.collection('battles').doc(battleId).update({
      'status': BattleStatus.inProgress.name,
      'startTime': DateTime.now().toIso8601String(),
      'currentQuestionIndex': 0,
    });
  }

  Future<void> nextQuestion(String battleId, int nextIndex) async {
    // Reset player answered status manually since we can't easily update array items in place
    // We have to read-modify-write inside a transaction or just overwrite the players list
    // For simplicity/speed, we'll just update the index and startTime.
    // The clients will see the new index and reset their local UI state.
    
    // BUT we need to clear `hasAnswered` flags on the server so we can track the next question.
    // This requires a transaction.
    
    await _firestore.runTransaction((transaction) async {
      final docRef = _firestore.collection('battles').doc(battleId);
      final snapshot = await transaction.get(docRef);
      if (!snapshot.exists) return;
      
      final session = BattleSession.fromMap(snapshot.data()!);
      
      // Reset players
      final updatedPlayers = session.players.map((p) => BattlePlayer(
        userId: p.userId,
        name: p.name,
        avatarUrl: p.avatarUrl,
        score: p.score,
        streak: p.streak,
        hasAnswered: false, // Reset
        answerTime: 0.0,   // Reset
        isBot: p.isBot,
        answers: p.answers, // KEEP ANSWERS
        answerTimes: p.answerTimes, // KEEP TIMES
      )).toList();
      
      transaction.update(docRef, {
        'currentQuestionIndex': nextIndex,
        'startTime': DateTime.now().toIso8601String(),
        'players': updatedPlayers.map((p) => p.toMap()).toList(),
      });
    });
  }

  Future<void> endGame(String battleId) async {
    await _firestore.collection('battles').doc(battleId).update({
      'status': BattleStatus.completed.name,
    });
    // Auto-delete removed. Host must manually delete.
  }

  Future<void> deleteBattle(String battleId) async {
    await _firestore.collection('battles').doc(battleId).delete();
  }

  Future<void> saveLocalHistory(String battleId, String userId) async {
    try {
      final doc = await _firestore.collection('battles').doc(battleId).get();
      if (!doc.exists) return;
      
      final session = BattleSession.fromMap(doc.data()!);
      final player = session.players.firstWhere((p) => p.userId == userId, orElse: () => BattlePlayer(userId: '', name: ''));
      
      if (player.userId.isEmpty) return;
      
      // Calculate Rank
      final players = List.from(session.players)..sort((a, b) => b.score.compareTo(a.score));
      final rank = players.indexWhere((p) => p.userId == userId) + 1;
      
      final history = BattleHistory()
        ..battleId = battleId
        ..topic = session.topic
        ..date = DateTime.now()
        ..score = player.score
        ..rank = rank
        ..totalPlayers = session.players.length
        ..isWinner = rank == 1
        ..sessionJson = jsonEncode(session.toMap());
        
      await _isarService.saveBattleHistory(history);
    } catch (e) {
      print('Error saving history: $e');
    }
  }

  Future<void> deleteLocalHistory(int id) async {
    await _isarService.deleteBattleHistory(id);
  }

  // --- 5. Player Actions ---
  Future<void> submitAnswer(String battleId, String userId, int answerIndex, double timeTaken) async {
    await _firestore.runTransaction((transaction) async {
      final docRef = _firestore.collection('battles').doc(battleId);
      final snapshot = await transaction.get(docRef);
      if (!snapshot.exists) return;

      final session = BattleSession.fromMap(snapshot.data()!);
      
      // Find player
      final playerIndex = session.players.indexWhere((p) => p.userId == userId);
      if (playerIndex == -1) return;
      
      final player = session.players[playerIndex];
      if (player.hasAnswered) return; // Already answered

      // Check correctness
      final question = session.questions[session.currentQuestionIndex];
      final isCorrect = question.correctIndex == answerIndex;
      
      // Calculate Score
      int points = 0;
      if (isCorrect) {
        points = 10; // Base points
        // Speed bonus
        final ratio = timeTaken / session.timePerQuestion;
        if (ratio <= 0.2) points += 5;
        else if (ratio <= 0.5) points += 2;
      }

      // Update Player
      final updatedPlayer = BattlePlayer(
        userId: player.userId,
        name: player.name,
        avatarUrl: player.avatarUrl,
        score: player.score + points,
        streak: isCorrect ? player.streak + 1 : 0,
        hasAnswered: true,
        answerTime: timeTaken,
        isBot: player.isBot,
        answers: {...player.answers, question.id: answerIndex}, // Record Answer
        answerTimes: {...player.answerTimes, question.id: timeTaken}, // Record Time
      );
      
      // Update List
      final updatedPlayers = List<BattlePlayer>.from(session.players);
      updatedPlayers[playerIndex] = updatedPlayer;
      
      // Check if ALL players have answered
      final allAnswered = updatedPlayers.every((p) => p.hasAnswered);

      if (allAnswered) {
        final nextIndex = session.currentQuestionIndex + 1;
        
        if (nextIndex >= session.questions.length) {
          // End Game
          transaction.update(docRef, {
            'players': updatedPlayers.map((p) => p.toMap()).toList(),
            'status': BattleStatus.completed.name,
          });
        } else {
          // Advance to Next Question immediately
          final resetPlayers = updatedPlayers.map((p) => BattlePlayer(
            userId: p.userId,
            name: p.name,
            avatarUrl: p.avatarUrl,
            score: p.score,
            streak: p.streak,
            hasAnswered: false, // Reset
            answerTime: 0.0,   // Reset
            isBot: p.isBot,
            answers: p.answers,
            answerTimes: p.answerTimes,
          )).toList();

          transaction.update(docRef, {
            'players': resetPlayers.map((p) => p.toMap()).toList(),
            'currentQuestionIndex': nextIndex,
            'startTime': DateTime.now().toIso8601String(),
          });
        }
      } else {
        // Just update players
        transaction.update(docRef, {
          'players': updatedPlayers.map((p) => p.toMap()).toList(),
        });
      }
    });
  }
  
  // --- Bot Logic ---
  Future<void> addBot(String battleId) async {
    final botId = _uuid.v4();
    final botName = 'Bot ${Random().nextInt(100)}';
    final botPlayer = BattlePlayer(userId: botId, name: botName, isBot: true);
    
    await _firestore.collection('battles').doc(battleId).update({
      'players': FieldValue.arrayUnion([botPlayer.toMap()]),
    });
  }
  
  Future<void> simulateBotAnswers(String battleId) async {
    // Similar to before, but operating on the single doc
    final doc = await _firestore.collection('battles').doc(battleId).get();
    if (!doc.exists) return;
    
    final session = BattleSession.fromMap(doc.data()!);
    if (session.status != BattleStatus.inProgress) return;
    
    final now = DateTime.now();
    final startTime = session.startTime ?? now;
    final elapsed = now.difference(startTime).inSeconds;
    
    if (elapsed < 3) return; // Wait a bit
    
    for (final player in session.players) {
      if (player.isBot && !player.hasAnswered) {
        if (Random().nextDouble() < 0.2) { // Chance to answer
           // 70% accuracy
           final question = session.questions[session.currentQuestionIndex];
           int answerIndex = question.correctIndex;
           if (Random().nextDouble() > 0.7) {
             answerIndex = (answerIndex + 1) % 4; // Wrong answer
           }
           await submitAnswer(battleId, player.userId, answerIndex, elapsed.toDouble());
        }
      }
    }
  }
}
