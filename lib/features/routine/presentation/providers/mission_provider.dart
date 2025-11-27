import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../data/models/mission.dart';
import '../../data/repositories/mission_repository.dart';

part 'mission_provider.g.dart';

@riverpod
class DailyMissionController extends _$DailyMissionController {
  @override
  Future<DailyMission?> build(DateTime date) async {
    return _fetchMission(date);
  }

  Future<DailyMission?> _fetchMission(DateTime date) async {
    final repository = ref.read(missionRepositoryProvider);
    var mission = await repository.getMissionForDate(date);
    
    if (mission == null) {
      // Auto-create default mission for today if it doesn't exist
      // In a real app, this might be triggered by a "Start Day" action or background job
      // For now, we lazy create it when viewed
      await repository.createDefaultMission(date);
      mission = await repository.getMissionForDate(date);
    }
    
    return mission;
  }

  Future<void> setMissions(List<MissionItem> items) async {
    final repository = ref.read(missionRepositoryProvider);
    // Use the date from the family provider argument if possible, but here we don't have access to it directly in method args easily unless we store it.
    // Actually, we can't access the family arg 'date' inside the method easily without storing it in state or passing it.
    // But wait, the provider is `dailyMissionControllerProvider(date)`. 
    // We can't access `date` here directly.
    // Let's rely on the state's date if available, or pass it.
    // Better: The controller is built with `date`. We can store it.
    // Ah, Riverpod 2.0 classes don't expose family args directly in methods.
    // We should store it in build.
    
    // Workaround: We'll assume the state has the date.
    final currentMission = state.value;
    if (currentMission != null) {
      await repository.setMissions(currentMission.date, items);
      ref.invalidateSelf();
    }
  }

  Future<void> toggleItem(int index) async {
    final mission = state.value;
    if (mission == null) return;

    final item = mission.items[index];
    
    // PREVENT MANUAL TOGGLE FOR AUTOMATED MISSIONS
    if (!item.isManual) return;

    // Create a new list to trigger updates (Isar embedded objects need care)
    final newItems = List<MissionItem>.from(mission.items);
    
    // Toggle
    item.isCompleted = !item.isCompleted;
    if (item.isCompleted) {
      item.current = item.target;
    } else {
      item.current = 0;
    }
    
    newItems[index] = item; // Update list

    mission.items = newItems;
    
    final repository = ref.read(missionRepositoryProvider);
    await repository.saveMission(mission);
    
    ref.invalidateSelf();
  }
}
