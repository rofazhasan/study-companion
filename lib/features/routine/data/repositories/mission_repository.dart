import 'package:isar/isar.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../../core/data/isar_service.dart';
import '../models/mission.dart';

part 'mission_repository.g.dart';

@Riverpod(keepAlive: true)
MissionRepository missionRepository(MissionRepositoryRef ref) {
  final isarService = ref.watch(isarServiceProvider);
  return MissionRepository(isarService);
}

class MissionRepository {
  final IsarService _isarService;

  MissionRepository(this._isarService);

  Future<DailyMission?> getMissionForDate(DateTime date) async {
    final startOfDay = DateTime(date.year, date.month, date.day);
    return await _isarService.db.dailyMissions
        .filter()
        .dateEqualTo(startOfDay)
        .findFirst();
  }

  Future<void> saveMission(DailyMission mission) async {
    await _isarService.db.writeTxn(() async {
      await _isarService.db.dailyMissions.put(mission);
    });
  }

  Future<void> createDefaultMission(DateTime date, {int studyBlockCount = 3}) async {
    final startOfDay = DateTime(date.year, date.month, date.day);
    final mission = DailyMission()
      ..date = startOfDay
      ..items = [
        MissionItem()
          ..title = 'Complete $studyBlockCount Study Blocks'
          ..xpReward = 50
          ..type = MissionType.studyBlocks
          ..target = studyBlockCount
          ..isManual = false,
        MissionItem()
          ..title = 'Focus for 60 Minutes'
          ..xpReward = 40
          ..type = MissionType.focusTime
          ..target = 60
          ..isManual = false,
        MissionItem()
          ..title = 'Review Flashcards'
          ..xpReward = 20
          ..type = MissionType.revision
          ..target = 1
          ..isManual = false,
      ];
    await saveMission(mission);
  }

  Future<void> updateProgress(DateTime date, MissionType type, int amount) async {
    final mission = await getMissionForDate(date);
    if (mission == null) return;

    bool changed = false;
    final newItems = List<MissionItem>.from(mission.items);

    for (int i = 0; i < newItems.length; i++) {
      final item = newItems[i];
      if (item.type == type && !item.isCompleted) {
        item.current += amount;
        if (item.current >= item.target) {
          item.current = item.target;
          item.isCompleted = true;
        }
        newItems[i] = item;
        changed = true;
      }
    }

    if (changed) {
      mission.items = newItems;
      await saveMission(mission);
    }
  }

  Future<void> updateTarget(DateTime date, MissionType type, int newTarget) async {
    final mission = await getMissionForDate(date);
    if (mission == null) {
      // If mission doesn't exist, create it with the correct target
      await createDefaultMission(date, studyBlockCount: newTarget);
      return;
    }

    bool changed = false;
    final newItems = List<MissionItem>.from(mission.items);

    for (int i = 0; i < newItems.length; i++) {
      final item = newItems[i];
      if (item.type == type) {
        if (item.target != newTarget) {
          item.target = newTarget;
          item.title = 'Complete $newTarget Study Blocks';
          // Re-evaluate completion
          if (item.current >= item.target) {
            item.isCompleted = true;
          } else {
            item.isCompleted = false;
          }
          newItems[i] = item;
          changed = true;
        }
      }
    }

    if (changed) {
      mission.items = newItems;
      await saveMission(mission);
    }
  }

  Future<void> setMissions(DateTime date, List<MissionItem> items) async {
    var mission = await getMissionForDate(date);
    if (mission == null) {
      final startOfDay = DateTime(date.year, date.month, date.day);
      mission = DailyMission()..date = startOfDay;
    }
    
    mission.items = items;
    await saveMission(mission);
  }
}
