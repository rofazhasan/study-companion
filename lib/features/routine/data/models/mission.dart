import 'package:isar/isar.dart';

part 'mission.g.dart';

@collection
class DailyMission {
  Id id = Isar.autoIncrement;

  @Index(unique: true)
  late DateTime date;

  List<MissionItem> items = [];

  bool get isAllCompleted => items.every((item) => item.isCompleted);
  
  int get completionPercentage {
    if (items.isEmpty) return 0;
    final completed = items.where((item) => item.isCompleted).length;
    return ((completed / items.length) * 100).round();
  }
}

@embedded
class MissionItem {
  late String title;
  bool isCompleted = false;
  int xpReward = 10;
  
  @Enumerated(EnumType.name)
  MissionType type = MissionType.custom;
  
  int target = 1; // e.g., 3 blocks
  int current = 0; // e.g., 1 block completed
  
  bool isManual = true; // If false, user cannot manually tick
}

enum MissionType {
  studyBlocks, // Count of study/homework/revision blocks
  focusTime,   // Minutes of focus
  revision,    // Count of revision blocks
  custom       // Manual only
}
