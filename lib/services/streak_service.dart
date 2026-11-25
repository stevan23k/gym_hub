import 'package:gym_hub/services/firebase_paths.dart';

/// Racha de días consecutivos con al menos un ejercicio completado.
class StreakService {
  /// La racha se cuenta hasta hoy. Si hoy todavía no se entrenó, se muestra
  /// la racha terminada ayer (para no perderla a primera hora del día).
  static Stream<int> watchStreak() {
    return FirebasePaths.history(FirebasePaths.uid).snapshots().map((snap) {
      final diasEntrenados = snap.docs
          .where(
            (doc) => (doc.data()['completed'] as List? ?? const []).isNotEmpty,
          )
          .map((doc) => doc.id)
          .toSet();
      return calcular(diasEntrenados);
    });
  }

  /// Calcula la racha a partir de las claves de fecha "yyyy-MM-dd".
  /// Extraído para poder probarlo sin Firestore.
  static int calcular(Set<String> diasEntrenados, {DateTime? ahora}) {
    final hoy = ahora ?? DateTime.now();
    final inicio = DateTime(hoy.year, hoy.month, hoy.day);

    var cursor = diasEntrenados.contains(FirebasePaths.dateKey(inicio))
        ? inicio
        : inicio.subtract(const Duration(days: 1));

    var racha = 0;
    while (diasEntrenados.contains(FirebasePaths.dateKey(cursor))) {
      racha++;
      cursor = cursor.subtract(const Duration(days: 1));
    }
    return racha;
  }
}
