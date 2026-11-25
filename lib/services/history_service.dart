import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:gym_hub/services/firebase_paths.dart';

/// Historial de ejercicios completados por día: users/{uid}/history/{fecha}.
class HistoryService {
  /// IDs de los ejercicios marcados como completados en una fecha.
  static Stream<Set<String>> watchDay(DateTime date) {
    return FirebasePaths.history(FirebasePaths.uid)
        .doc(FirebasePaths.dateKey(date))
        .snapshots()
        .map((snap) {
          final completed = snap.data()?['completed'] as List? ?? const [];
          return completed.cast<String>().toSet();
        });
  }

  /// Guarda (o quita) un ejercicio completado en la fecha indicada.
  static Future<void> setExerciseCompleted({
    required DateTime date,
    required String dayName,
    required String exerciseId,
    required bool completed,
  }) async {
    final key = FirebasePaths.dateKey(date);
    final ref = FirebasePaths.history(FirebasePaths.uid).doc(key);

    await FirebasePaths.db.runTransaction((transaction) async {
      final snap = await transaction.get(ref);
      final current = snap.data()?['completed'] as List? ?? const [];
      final ids = current.cast<String>().toSet();

      if (completed) {
        ids.add(exerciseId);
      } else {
        ids.remove(exerciseId);
      }

      transaction.set(ref, {
        'date': key,
        'dayName': dayName,
        'completed': ids.toList(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    });
  }

  /// Documentos de historial de un mes (usado por el calendario).
  static Stream<QuerySnapshot<Map<String, dynamic>>> historySnapshotsInMonth(
    DateTime month,
  ) {
    final from = FirebasePaths.dateKey(DateTime(month.year, month.month));
    final to = FirebasePaths.dateKey(DateTime(month.year, month.month + 1));

    return FirebasePaths.history(FirebasePaths.uid)
        .where('date', isGreaterThanOrEqualTo: from)
        .where('date', isLessThan: to)
        .snapshots();
  }

  /// Días del mes con al menos un ejercicio completado.
  static Stream<Set<String>> watchCompletedDaysInMonth(DateTime month) {
    return historySnapshotsInMonth(month).map(
      (snap) => snap.docs
          .where(
            (doc) => (doc.data()['completed'] as List? ?? const []).isNotEmpty,
          )
          .map((doc) => doc.id)
          .toSet(),
    );
  }
}
