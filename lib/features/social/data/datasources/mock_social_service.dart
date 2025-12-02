import 'dart:async';
import 'package:uuid/uuid.dart';

import '../models/leaderboard_entry.dart';
import '../models/battle_match.dart';

class MockSocialService {
  final _uuid = const Uuid();
  
  // Group and Chat logic moved to SocialRepository


  Future<List<LeaderboardEntry>> getLeaderboard() async {
    await Future.delayed(const Duration(milliseconds: 800));
    return [
      LeaderboardEntry(userId: 'u1', username: 'Alice', weeklyHours: 42, streak: 15, rank: 1),
      LeaderboardEntry(userId: 'u2', username: 'Bob', weeklyHours: 38, streak: 12, rank: 2),
      LeaderboardEntry(userId: 'u3', username: 'Charlie', weeklyHours: 35, streak: 8, rank: 3),
      LeaderboardEntry(userId: 'me', username: 'You', weeklyHours: 20, streak: 5, rank: 12),
      LeaderboardEntry(userId: 'u4', username: 'Dave', weeklyHours: 15, streak: 2, rank: 25),
    ];
  }

  // Battle Mode
  Future<BattleMatch> findMatch() async {
    await Future.delayed(const Duration(seconds: 3)); // Simulate searching
    return BattleMatch(
      id: _uuid.v4(),
      opponentName: 'Opponent_${_uuid.v4().substring(0, 4)}',
      status: BattleStatus.playing,
    );
  }
}
