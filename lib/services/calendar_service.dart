import 'package:gym_hub/constants.dart';
import 'package:gym_hub/models/day_progress.dart';
import 'package:gym_hub/services/firebase_paths.dart';
import 'package:gym_hub/services/history_service.dart';
import 'package:gym_hub/services/routines_service.dart';

class CalendarService {
  static Stream<List<DayProgress>> watchMonth(DateTime month) async* {
    await for (final snapshot in HistoryService.historySnapshotsInMonth(
      month,
    )) {
      final counts = <String, int>{};
      for (final doc in snapshot.docs) {
        final completed = doc.data()['completed'] as List? ?? const [];
        counts[doc.id] = completed.length;
      }

      final totals = <String, int>{};
      for (final dayName in kDiasSemana) {
        totals[dayName] = (await RoutinesService.getDay(dayName))
            .exercises
            .length;
      }

      final first = DateTime(month.year, month.month, 1);
      final lastDay = DateTime(month.year, month.month + 1, 0).day;
      final days = <DayProgress>[];

      for (var d = 1; d <= lastDay; d++) {
        final date = DateTime(first.year, first.month, d);
        final key = FirebasePaths.dateKey(date);
        final total = totals[kDiasSemana[date.weekday - 1]] ?? 0;
        final completed = counts[key] ?? 0;
        days.add(
          DayProgress(
            date: key,
            completed: total > 0 && completed > total ? total : completed,
            total: total,
          ),
        );
      }

      yield days;
    }
  }
}
