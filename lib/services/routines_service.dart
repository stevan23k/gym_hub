import 'package:gym_hub/models/day.dart';

class RoutinesService {
  static final Map<String, DayRoutine> _days = {};

  static const _iniciales = [
    RoutineExercise(
      name: 'Dominada',
      series: 4,
      reps: 10,
      image: 'assets/images/flat/pull-up-start.webp',
    ),
  ];

  static DayRoutine of(String day) => _days.putIfAbsent(
    day,
    () => DayRoutine(name: day, exercises: _iniciales),
  );

  static void add(String day, RoutineExercise exercise) =>
      of(day).exercises.add(exercise);
}
