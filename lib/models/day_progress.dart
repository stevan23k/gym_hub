/// Avance de un día concreto del calendario.
class DayProgress {
  const DayProgress({
    required this.date,
    required this.completed,
    required this.total,
  });

  /// Clave del día en Firestore, p. ej. "2026-11-24".
  final String date;
  final int completed;
  final int total;

  double get percentage {
    if (total <= 0) return 0;
    final value = completed / total;
    return value > 1 ? 1 : value;
  }

  int get percent => (percentage * 100).round();

  bool get isTrained => completed > 0;
}
