import 'package:gym_hub/models/day.dart';
import 'package:gym_hub/services/firebase_paths.dart';

/// Limpieza única del ejercicio de demostración que se guardó en versiones
/// anteriores de la app (tanto en rutinas como en el historial).
class MigrationService {
  static bool _ejecutada = false;

  static const _idsDemo = {'inicial-dominada', 'dominada|4|10'};

  static bool _esDemo(RoutineExercise exercise) =>
      _idsDemo.contains(exercise.storageId);

  static Future<void> limpiarEjercicioDemo() async {
    if (_ejecutada) return;

    try {
      final uid = FirebasePaths.uid;
      final db = FirebasePaths.db;
      final batch = db.batch();
      var cambios = 0;

      final rutinas = await FirebasePaths.routines(uid).get();
      for (final doc in rutinas.docs) {
        final originales = doc.data()['exercises'] as List? ?? const [];
        final limpios = originales
            .map((e) => RoutineExercise.fromJson(e as Map<String, dynamic>))
            .where((e) => !_esDemo(e))
            .toList();
        if (limpios.length != originales.length) {
          batch.update(doc.reference, {
            'exercises': limpios.map((e) => e.toJson()).toList(),
          });
          cambios++;
        }
      }

      final historial = await FirebasePaths.history(uid).get();
      for (final doc in historial.docs) {
        final originales = doc.data()['completed'] as List? ?? const [];
        final limpios = originales.cast<String>().where(
          (id) => !_idsDemo.contains(id),
        );
        if (limpios.length != originales.length) {
          batch.update(doc.reference, {'completed': limpios.toList()});
          cambios++;
        }
      }

      if (cambios > 0) await batch.commit();
      _ejecutada = true;
    } catch (_) {
      // Si falla, se reintenta en el próximo inicio de sesión.
    }
  }
}
