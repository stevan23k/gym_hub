class RoutineExercise {
  const RoutineExercise({
    required this.name,
    required this.series,
    required this.reps,
    this.image,
    this.id = '',
  });

  factory RoutineExercise.fromJson(Map<String, dynamic> json) {
    final name = json['name'] as String;
    final series = (json['series'] as num).toInt();
    final reps = (json['reps'] as num).toInt();
    return RoutineExercise(
      id: json['id'] as String? ?? idFrom(name, series, reps),
      name: name,
      series: series,
      reps: reps,
      image: json['image'] as String?,
    );
  }

  /// Identificador estable para documentos antiguos que aún no tenían id.
  static String idFrom(String name, int series, int reps) =>
      '${name.trim().toLowerCase()}|$series|$reps';

  /// Identificador del ejercicio, usado como clave en el historial.
  final String id;
  final String name;
  final int series;
  final int reps;
  final String? image;

  String get storageId => id.isEmpty ? idFrom(name, series, reps) : id;

  Map<String, dynamic> toJson() => {
    'id': storageId,
    'name': name,
    'series': series,
    'reps': reps,
    if (image != null) 'image': image,
  };
}

class DayRoutine {
  DayRoutine({required this.name, List<RoutineExercise>? exercises})
    : exercises = List.of(exercises ?? const []);

  factory DayRoutine.fromJson(Map<String, dynamic> json) {
    return DayRoutine(
      name: json['name'] as String,
      exercises: (json['exercises'] as List? ?? const [])
          .map((e) => RoutineExercise.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  final String name;
  final List<RoutineExercise> exercises;

  Map<String, dynamic> toJson() => {
    'name': name,
    'exercises': exercises.map((e) => e.toJson()).toList(),
  };
}
