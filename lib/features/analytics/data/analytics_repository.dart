import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../../core/data/isar_service.dart';
import '../../focus_mode/data/models/study_session.dart';

part 'analytics_repository.g.dart';

@Riverpod(keepAlive: true)
AnalyticsRepository analyticsRepository(AnalyticsRepositoryRef ref) {
  return AnalyticsRepository(ref.read(isarServiceProvider));
}

class AnalyticsRepository {
  final IsarService _isarService;

  AnalyticsRepository(this._isarService);

  Future<List<StudySession>> getSessionsForDateRange(DateTime start, DateTime end) {
    return _isarService.getSessionsByDateRange(start, end);
  }

  Future<Map<DateTime, int>> getDailyFocusTime(DateTime start, DateTime end) async {
    final sessions = await _isarService.getSessionsByDateRange(start, end);
    final Map<DateTime, int> dailyMap = {};

    // Initialize all days in range with 0
    // Normalize start to midnight to ensure consistent iteration
    final normalizedStart = DateTime(start.year, start.month, start.day);
    
    // Iterate day by day
    for (var d = normalizedStart; d.isBefore(end); d = d.add(const Duration(days: 1))) {
      final date = DateTime(d.year, d.month, d.day);
      dailyMap[date] = 0;
    }

    for (var session in sessions) {
      if (session.phase == 'focus' && session.isCompleted) {
        final date = DateTime(session.startTime.year, session.startTime.month, session.startTime.day);
        // Only update if the date is within our initialized map (it should be, but safety check)
        if (dailyMap.containsKey(date)) {
          dailyMap[date] = (dailyMap[date] ?? 0) + session.durationSeconds;
        } else {
           // Handle edge case where session might fall on the exact 'end' boundary if inclusive logic differs
           // But based on loop, we cover [start, end).
           // If custom range includes 'end' as 23:59:59, the loop covers that day.
           // If session is exactly at end time (rare), it might be excluded.
           // For now, let's just add it if it's missing, or ignore if strictly outside.
           // Actually, let's add it to be safe, but normalized.
           dailyMap[date] = (dailyMap[date] ?? 0) + session.durationSeconds;
        }
      }
    }
    return dailyMap;
  }

  Future<Map<DateTime, int>> getMonthlyFocusTime(DateTime start, DateTime end) async {
    final sessions = await _isarService.getSessionsByDateRange(start, end);
    final Map<DateTime, int> monthlyMap = {};

    // Initialize all months in range with 0
    final normalizedStart = DateTime(start.year, start.month, 1);
    
    // Iterate month by month
    // Note: Adding months can be tricky with days (e.g. Jan 31 + 1 month -> Feb 28).
    // Best to increment month field.
    var current = normalizedStart;
    while (current.isBefore(end)) {
      monthlyMap[current] = 0;
      // Move to next month
      if (current.month == 12) {
        current = DateTime(current.year + 1, 1, 1);
      } else {
        current = DateTime(current.year, current.month + 1, 1);
      }
    }

    for (var session in sessions) {
      if (session.phase == 'focus' && session.isCompleted) {
        final date = DateTime(session.startTime.year, session.startTime.month, 1);
        if (monthlyMap.containsKey(date)) {
          monthlyMap[date] = (monthlyMap[date] ?? 0) + session.durationSeconds;
        } else {
           monthlyMap[date] = (monthlyMap[date] ?? 0) + session.durationSeconds;
        }
      }
    }
    return monthlyMap;
  }

  Future<int> getTotalFocusTime(DateTime start, DateTime end) async {
    final sessions = await _isarService.getSessionsByDateRange(start, end);
    return sessions.fold<int>(0, (sum, session) {
      if (session.phase == 'focus' && session.isCompleted) {
        return sum + session.durationSeconds;
      }
      return sum;
    });
  }
  Future<void> deleteSession(int id) {
    return _isarService.deleteSession(id);
  }

  Future<void> updateSession(StudySession session) {
    return _isarService.updateSession(session);
  }
}
