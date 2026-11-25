import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:gym_hub/models/day.dart';
import 'package:gym_hub/services/firebase_paths.dart';

/// Rutina de cada día guardada en Firestore bajo users/{uid}/routines/{dia}.
class RoutinesService {
  /// Las rutinas arrancan vacías: el usuario agrega sus propios ejercicios.
  static const List<RoutineExercise> _iniciales = [];

  static DocumentReference<Map<String, dynamic>> _dayRef(String day) =>
      FirebasePaths.routines(FirebasePaths.uid).doc(day);

  static DayRoutine _routineFrom(
    DocumentSnapshot<Map<String, dynamic>> snap,
    String day,
  ) {
    if (!snap.exists || snap.data() == null) {
      return DayRoutine(name: day, exercises: _iniciales);
    }
    return DayRoutine.fromJson(snap.data()!);
  }

  /// Rutina en tiempo real del día indicado para el usuario actual.
  static Stream<DayRoutine> watchDay(String day) =>
      _dayRef(day).snapshots().map((snap) => _routineFrom(snap, day));

  /// Lectura puntual de la rutina del día.
  static Future<DayRoutine> getDay(String day) async =>
      _routineFrom(await _dayRef(day).get(), day);

  /// Agrega un ejercicio de forma atómica (seguro si se guarda desde varios dispositivos).
  static Future<void> addExercise(String day, RoutineExercise exercise) async {
    final ref = _dayRef(day);
    final toAdd = exercise.id.isEmpty
        ? RoutineExercise(
            id: DateTime.now().microsecondsSinceEpoch.toString(),
            name: exercise.name,
            series: exercise.series,
            reps: exercise.reps,
            image: exercise.image,
          )
        : exercise;

    await FirebasePaths.db.runTransaction((transaction) async {
      final routine = _routineFrom(await transaction.get(ref), day);
      final updated = DayRoutine(
        name: routine.name,
        exercises: [...routine.exercises, toAdd],
      );
      transaction.set(ref, {
        ...updated.toJson(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    });
  }

  /// Reemplaza el ejercicio en la posición indicada (mantiene su id).
  static Future<void> updateExercise(
    String day,
    int index,
    RoutineExercise exercise,
  ) async {
    final ref = _dayRef(day);
    await FirebasePaths.db.runTransaction((transaction) async {
      final routine = _routineFrom(await transaction.get(ref), day);
      if (index < 0 || index >= routine.exercises.length) return;
      final updated = DayRoutine(
        name: routine.name,
        exercises: [
          for (var i = 0; i < routine.exercises.length; i++)
            i == index ? exercise : routine.exercises[i],
        ],
      );
      transaction.set(ref, {
        ...updated.toJson(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    });
  }

  /// Elimina el ejercicio en la posición indicada.
  static Future<void> removeExercise(String day, int index) async {
    final ref = _dayRef(day);
    await FirebasePaths.db.runTransaction((transaction) async {
      final routine = _routineFrom(await transaction.get(ref), day);
      if (index < 0 || index >= routine.exercises.length) return;
      final updated = DayRoutine(
        name: routine.name,
        exercises: [...routine.exercises]..removeAt(index),
      );
      transaction.set(ref, {
        ...updated.toJson(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    });
  }
}
