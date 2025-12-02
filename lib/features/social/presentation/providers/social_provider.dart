import 'package:firebase_auth/firebase_auth.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../data/models/social_models.dart';
import '../../data/models/leaderboard_entry.dart';
import '../../data/repositories/social_repository.dart';
import '../../data/datasources/mock_social_service.dart';
import '../../data/models/battle_history.dart';
import '../../../../core/data/isar_service.dart';

part 'social_provider.g.dart';

@riverpod
class SocialNotifier extends _$SocialNotifier {
  @override
  Stream<List<StudyGroup>> build() {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      // Sync groups from Firestore on load (handles reinstall case)
      ref.read(socialRepositoryProvider).startGroupSync(user.uid);
    }
    return ref.watch(socialRepositoryProvider).watchGroups();
  }

  Future<void> createGroup(String name, String topic) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) throw Exception('Must be logged in');
    
    await ref.read(socialRepositoryProvider).createGroup(name, topic, user.uid);
  }

  Future<void> joinGroup(String code) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) throw Exception('Must be logged in');

    await ref.read(socialRepositoryProvider).joinGroup(code, user.uid);
  }
}

@riverpod
Stream<List<SocialChatMessage>> groupChat(GroupChatRef ref, String groupId) {
  // Sync is now handled globally by SocialRepository.startGroupSync
  // final user = FirebaseAuth.instance.currentUser;
  // if (user != null) {
  //   ref.read(socialRepositoryProvider).syncMessages(groupId, user.uid).listen((_) {});
  // }
  return ref.watch(socialRepositoryProvider).watchMessages(groupId);
}

@riverpod
Stream<List<String>> typingStatus(TypingStatusRef ref, String groupId) {
  final user = FirebaseAuth.instance.currentUser;
  if (user == null) return Stream.value([]);
  return ref.watch(socialRepositoryProvider).watchTypingStatus(groupId, user.uid);
}



@riverpod
Future<List<Map<String, String>>> groupMembers(GroupMembersRef ref, String groupId) {
  return ref.read(socialRepositoryProvider).getGroupMembers(groupId);
}

@riverpod
Future<List<Map<String, String>>> bannedMembers(BannedMembersRef ref, String groupId) {
  return ref.read(socialRepositoryProvider).getBannedMembers(groupId);
}

@riverpod
Future<List<LeaderboardEntry>> leaderboard(LeaderboardRef ref) {
  return ref.watch(socialRepositoryProvider).getLeaderboard();
}

@riverpod
Future<List<BattleHistory>> battleHistory(BattleHistoryRef ref) {
  return ref.watch(isarServiceProvider).getBattleHistory();
}
