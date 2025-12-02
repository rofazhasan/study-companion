import 'dart:async';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../data/models/battle_models.dart';
import '../../data/repositories/battle_repository.dart';

part 'battle_provider.g.dart';

@riverpod
Stream<BattleSession> battleSession(BattleSessionRef ref, String battleId) {
  return ref.watch(battleRepositoryProvider).streamBattle(battleId);
}

@riverpod
class BattleController extends _$BattleController {
  @override
  void build() {}

  Future<void> checkGameState(String battleId, BattleSession session, String currentUserId) async {
    // Only Host runs game logic
    if (session.creatorId != currentUserId) return;
    if (session.status != BattleStatus.inProgress) return;

    // 1. Check Timer
    final now = DateTime.now();
    final startTime = session.startTime ?? now;
    final elapsed = now.difference(startTime).inSeconds;
    
    // 2. Check if everyone answered
    final allAnswered = session.players.every((p) => p.hasAnswered);
    
    if (elapsed >= session.timePerQuestion || allAnswered) {
      // Move to next question or end game
      if (session.currentQuestionIndex < session.questions.length - 1) {
        await ref.read(battleRepositoryProvider).nextQuestion(battleId, session.currentQuestionIndex + 1);
      } else {
        await ref.read(battleRepositoryProvider).endGame(battleId);
      }
    } else {
      // Simulate bots if game is still running
      await ref.read(battleRepositoryProvider).simulateBotAnswers(battleId);
    }
  }
}
