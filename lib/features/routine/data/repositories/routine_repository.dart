import 'package:isar/isar.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../../core/data/isar_service.dart';
import '../models/routine_block.dart';
import '../models/daily_routine.dart';
import '../models/mission.dart';
import '../../../focus_mode/data/models/study_session.dart';
import 'mission_repository.dart';

part 'routine_repository.g.dart';

@Riverpod(keepAlive: true)
@Riverpod(keepAlive: true)
RoutineRepository routineRepository(RoutineRepositoryRef ref) {
  final isarService = ref.watch(isarServiceProvider);
  final missionRepo = ref.watch(missionRepositoryProvider);
  return RoutineRepository(isarService, missionRepo);
}

class RoutineRepository {
  final IsarService _isarService;
  final MissionRepository _missionRepository;

  RoutineRepository(this._isarService, this._missionRepository);

  Future<List<RoutineBlock>> getBlocksForDate(DateTime date) async {
    // Normalize date to midnight
    final startOfDay = DateTime(date.year, date.month, date.day);
    
    return await _isarService.db.routineBlocks
        .filter()
        .dateEqualTo(startOfDay)
        .sortByStartTime()
        .findAll();
  }

  Future<void> addBlock(RoutineBlock block) async {
    await _isarService.db.writeTxn(() async {
      await _isarService.db.routineBlocks.put(block);
    });
    await _syncMissionTarget(block.date);
  }

  Future<void> updateBlock(RoutineBlock block) async {
    await _isarService.db.writeTxn(() async {
      await _isarService.db.routineBlocks.put(block);
    });
    await _syncMissionTarget(block.date);
  }

  Future<void> deleteBlock(Id id) async {
    final block = await _isarService.db.routineBlocks.get(id);
    final date = block?.date;
    
    await _isarService.db.writeTxn(() async {
      await _isarService.db.routineBlocks.delete(id);
    });
    
    if (date != null) {
      await _syncMissionTarget(date);
    }
  }

  Future<DailyRoutine?> getDailyRoutine(DateTime date) async {
    final startOfDay = DateTime(date.year, date.month, date.day);
    return await _isarService.db.dailyRoutines
        .filter()
        .dateEqualTo(startOfDay)
        .findFirst();
  }
  
  Future<void> saveDailyRoutine(DailyRoutine routine) async {
    await _isarService.db.writeTxn(() async {
      await _isarService.db.dailyRoutines.put(routine);
    });
  }

  Future<void> toggleBlockCompletion(Id id) async {
    final block = await _isarService.db.routineBlocks.get(id);
    if (block != null) {
      block.isCompleted = !block.isCompleted;
      
      // INTEGRATION: Update Mission Progress & Analytics
      if (block.isCompleted) {
        await _updateMissionForBlock(block);
        await _createManualSession(block);
      } else {
        // If unchecking, remove the linked session
        if (block.linkedSessionId != null) {
          await _deleteLinkedSession(block.linkedSessionId!);
          block.linkedSessionId = null;
        }
      }
      
      await updateBlock(block);
      await calculateDailyScore(block.date);
    }
  }

  Future<void> setBlockCompletion(Id id, bool isCompleted, {bool createSession = false}) async {
    final block = await _isarService.db.routineBlocks.get(id);
    if (block != null) {
      if (block.isCompleted != isCompleted) {
        block.isCompleted = isCompleted;
        
        // INTEGRATION: Update Mission Progress
        if (isCompleted) {
          await _updateMissionForBlock(block);
          if (createSession) {
            await _createManualSession(block);
          }
        } else {
           // If unchecking, remove the linked session
          if (block.linkedSessionId != null) {
            await _deleteLinkedSession(block.linkedSessionId!);
            block.linkedSessionId = null;
          }
        }
        
        await updateBlock(block);
        await calculateDailyScore(block.date);
      }
    }
  }

  Future<void> _createManualSession(RoutineBlock block) async {
    // Only create session for study-related blocks
    if (block.type == BlockType.study || 
        block.type == BlockType.homework || 
        block.type == BlockType.revision) {
      
      // Prevent duplicate if already linked
      if (block.linkedSessionId != null) return;

      final session = StudySession()
        ..startTime = DateTime.now().subtract(Duration(minutes: block.durationMinutes))
        ..endTime = DateTime.now()
        ..durationSeconds = block.durationMinutes * 60
        ..phase = 'focus'
        ..isCompleted = true
        ..focusIntent = block.title ?? block.type.name
        ..isDeepFocus = false // Manual ticks are considered normal focus
        ..targetDuration = block.durationMinutes * 60;
        
      await _isarService.db.writeTxn(() async {
        final id = await _isarService.db.studySessions.put(session);
        block.linkedSessionId = id;
        // Note: block update happens in caller
      });
    }
  }
  
  Future<void> _deleteLinkedSession(int sessionId) async {
    await _isarService.db.writeTxn(() async {
      await _isarService.db.studySessions.delete(sessionId);
    });
  }
  
  Future<void> _updateMissionForBlock(RoutineBlock block) async {
    // Generic study block count
    if (block.type == BlockType.study || block.type == BlockType.homework || block.type == BlockType.revision) {
      await _missionRepository.updateProgress(block.date, MissionType.studyBlocks, 1);
    }
    
    // Revision specific
    if (block.type == BlockType.revision) {
      await _missionRepository.updateProgress(block.date, MissionType.revision, 1);
    }
    
    // Focus time (approximate from block duration if manually ticked)
    // Note: Focus Mode handles exact time separately. This is for manual ticks.
    // We might want to avoid double counting if Focus Mode calls setBlockCompletion.
    // However, setBlockCompletion is called by Focus Mode.
    // Let's assume Focus Mode will ALSO call updateProgress for focusTime specifically.
    // Here we only update block counts.
  }

  Future<void> calculateDailyScore(DateTime date) async {
    final blocks = await getBlocksForDate(date);
    if (blocks.isEmpty) return;

    final completedCount = blocks.where((b) => b.isCompleted).length;
    final score = (completedCount / blocks.length * 100).round();

    var dailyRoutine = await getDailyRoutine(date);
    if (dailyRoutine == null) {
      final startOfDay = DateTime(date.year, date.month, date.day);
      dailyRoutine = DailyRoutine()..date = startOfDay;
    }

    dailyRoutine.healthScore = score;
    await saveDailyRoutine(dailyRoutine);
  }

  Future<void> _syncMissionTarget(DateTime date) async {
    final blocks = await getBlocksForDate(date);
    
    // Count study-related blocks
    final studyBlockCount = blocks.where((b) => 
      b.type == BlockType.study || 
      b.type == BlockType.homework || 
      b.type == BlockType.revision
    ).length;

    // Update mission target
    // If 0 blocks, we might want to keep a minimum or set to 0? 
    // Let's set a minimum of 1 if they have no blocks, or just sync to count.
    // If they have 0 blocks, maybe they shouldn't have a study mission? 
    // For now, let's sync to the count, but if 0, maybe default to 3 (standard challenge) or 1.
    // User request: "if you have 3 study block you complete one it must see the percentage"
    // This implies the target should match the schedule.
    
    final target = studyBlockCount > 0 ? studyBlockCount : 3; // Default to 3 if no schedule
    
    await _missionRepository.updateTarget(date, MissionType.studyBlocks, target);
  }
}
