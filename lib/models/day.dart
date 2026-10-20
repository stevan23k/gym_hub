class RoutineExercise {
  const RoutineExercise({
    required this.name,
    required this.series,
    required this.reps,
    this.image,
  });

  final String name;
  final int series;
  final int reps;
  final String? image;
}

class DayRoutine {
  DayRoutine({required this.name, List<RoutineExercise>? exercises})
      : exercises = List.of(exercises ?? const []);

  final String name;
  final List<RoutineExercise> exercises;
}
