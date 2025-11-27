import 'dart:convert';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../../core/data/isar_service.dart';
import '../../../ai_chat/presentation/providers/chat_provider.dart';
import '../../data/models/routine_block.dart';
import '../../data/repositories/routine_repository.dart';
import '../providers/routine_provider.dart';

part 'routine_ai_provider.g.dart';

@riverpod
class RoutineAI extends _$RoutineAI {
  @override
  FutureOr<void> build() {}

  Future<void> generateSchedule({
    required List<String> subjects,
    required String mood,
    required DateTime date,
    required int totalHours,
  }) async {
    state = const AsyncValue.loading();

    try {
      final aiService = ref.read(aiServiceProvider);
      final repository = ref.read(routineRepositoryProvider);

      // Construct Prompt
      final prompt = '''
You are a study planner. Create a daily schedule for a student.
Date: ${date.toIso8601String().split('T')[0]}
Subjects to study: ${subjects.join(', ')}
Student Mood: $mood
Total Study Time: $totalHours hours
Start Time: 09:00 AM

Rules:
1. Mix study blocks with short breaks.
2. If mood is 'Tired', use shorter study blocks (25m) and more breaks.
3. If mood is 'Energetic', use longer study blocks (50m).
4. Output ONLY a valid JSON array. Do not include markdown formatting like ```json ... ```.
5. Format: [{"title": "Math", "type": "study", "duration": 60, "start": "09:00"}, ...]
Types: study, homework, revision, breakTime, personal.
''';

      // Generate Response
      String fullResponse = "";
      final stream = aiService.generateResponse(prompt);
      await for (final chunk in stream) {
        fullResponse += chunk;
      }

      print("AI Response: $fullResponse"); // Debug log

      // Robust JSON extraction
      String jsonStr = fullResponse.trim();
      List<dynamic>? data;

      // Attempt 1: Direct Decode
      try {
        data = jsonDecode(jsonStr);
      } catch (_) {
        // Attempt 2: Regex extraction
        final jsonPattern = RegExp(r'\[\s*\{.*\}\s*\]', multiLine: true, dotAll: true);
        final match = jsonPattern.firstMatch(fullResponse);
        if (match != null) {
          try {
            data = jsonDecode(match.group(0)!);
          } catch (e) {
             print("Regex decode failed: $e");
          }
        }
      }
      
      if (data != null) {
        print("Parsed ${data.length} blocks from AI response");
        
        for (final item in data) {
          final startTimeStr = item['start'] as String;
          // Handle "9:00" vs "09:00"
          final parts = startTimeStr.split(':');
          final hour = int.parse(parts[0]);
          final minute = int.parse(parts[1]);
          
          final startTime = DateTime(
            date.year,
            date.month,
            date.day,
            hour,
            minute,
          );

          final block = RoutineBlock()
            ..date = DateTime(date.year, date.month, date.day)
            ..title = item['title']
            ..type = _parseType(item['type'])
            ..durationMinutes = item['duration']
            ..startTime = startTime
            ..difficulty = TaskDifficulty.medium; // Default

          await repository.addBlock(block);
          print("Added block: ${block.title} at $startTime");
        }
        
        // Verify blocks were saved
        final savedBlocks = await repository.getBlocksForDate(date);
        print("Verified: Found ${savedBlocks.length} blocks in DB for $date");
        
        // Refresh the UI
        ref.invalidate(dailyRoutineBlocksProvider);
        print("Invalidated dailyRoutineBlocksProvider");
      } else {
        throw Exception("Failed to find JSON array in response");
      }

      state = const AsyncValue.data(null);
    } catch (e, st) {
      print("RoutineAI Error: $e");
      // If AI fails (or returns non-JSON text), fallback to a basic template schedule
      try {
        print("Generating template schedule due to error...");
        final repository = ref.read(routineRepositoryProvider);
        await _generateTemplateSchedule(repository, date, subjects, totalHours);
        print("Template schedule generated.");
        state = const AsyncValue.data(null);
      } catch (fallbackError, fallbackStack) {
        print("Fallback Error: $fallbackError");
        state = AsyncValue.error(e, st); // Return original error
      }
    }
  }

  Future<void> _generateTemplateSchedule(
    RoutineRepository repository, 
    DateTime date, 
    List<String> subjects, 
    int totalHours
  ) async {
    // Basic template: 50m study, 10m break
    final startTime = DateTime(date.year, date.month, date.day, 9, 0);
    int minutesAdded = 0;
    int subjectIndex = 0;

    while (minutesAdded < totalHours * 60) {
      // Study Block
      if (subjects.isNotEmpty) {
        final subject = subjects[subjectIndex % subjects.length];
        await repository.addBlock(RoutineBlock()
          ..date = date
          ..title = "Study $subject"
          ..type = BlockType.study
          ..durationMinutes = 50
          ..startTime = startTime.add(Duration(minutes: minutesAdded))
          ..difficulty = TaskDifficulty.medium
        );
        minutesAdded += 50;
        subjectIndex++;
      }

      // Break Block
      if (minutesAdded < totalHours * 60) {
        await repository.addBlock(RoutineBlock()
          ..date = date
          ..title = "Break"
          ..type = BlockType.breakTime
          ..durationMinutes = 10
          ..startTime = startTime.add(Duration(minutes: minutesAdded))
          ..difficulty = TaskDifficulty.easy
        );
        minutesAdded += 10;
      }
    }
    
    ref.invalidate(dailyRoutineBlocksProvider);
  }

  BlockType _parseType(String type) {
    switch (type.toLowerCase()) {
      case 'study': return BlockType.study;
      case 'homework': return BlockType.homework;
      case 'revision': return BlockType.revision;
      case 'breaktime': 
      case 'break': return BlockType.breakTime;
      case 'personal': return BlockType.personal;
      default: return BlockType.other;
    }
  }
}
