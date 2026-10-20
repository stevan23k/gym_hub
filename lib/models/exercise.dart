import 'exercise_enums.dart';

class Exercise {
  const Exercise({
    required this.id,
    required this.nameEn,
    required this.nameDe,
    required this.nameEs,
    required this.descriptionEn,
    required this.descriptionDe,
    required this.descriptionEs,
    required this.category,
    required this.forceType,
    required this.mechanic,
    required this.difficulty,
    required this.bodyPart,
    required this.primaryMuscles,
    required this.goals,
    required this.isUnilateral,
    required this.isBodyweight,
    required this.instructionsEn,
    required this.instructionsDe,
    required this.instructionsEs,
    required this.tipsEn,
    required this.tipsDe,
    required this.tipsEs,
    required this.met,
    required this.images,
    this.equipment,
    this.secondaryMuscles = const [],
    this.tags = const [],
    this.variationGroup,
  });

  factory Exercise.fromJson(Map<String, dynamic> json) {
    return Exercise(
      id: json['id'] as String,
      nameEn: json['name_en'] as String,
      nameDe: json['name_de'] as String,
      nameEs: json['name_es'] as String,
      descriptionEn: json['description_en'] as String,
      descriptionDe: json['description_de'] as String,
      descriptionEs: json['description_es'] as String,
      category: ExerciseCategory.fromJson(json['category']),
      forceType: ForceType.fromJson(json['force_type']),
      mechanic: Mechanic.fromJson(json['mechanic']),
      difficulty: Difficulty.fromJson(json['difficulty']),
      equipment: json['equipment'] == null
          ? null
          : Equipment.fromJson(json['equipment']),
      bodyPart: BodyPart.fromJson(json['body_part']),
      primaryMuscles: (json['primary_muscles'] as List)
          .map((m) => Muscle.fromJson(m))
          .toList(),
      secondaryMuscles: (json['secondary_muscles'] as List? ?? const [])
          .map((m) => Muscle.fromJson(m))
          .toList(),
      goals:
          (json['goals'] as List).map((g) => ExerciseGoal.fromJson(g)).toList(),
      tags: List<String>.from(json['tags'] as List? ?? const []),
      variationGroup: json['variation_group'] as String?,
      isUnilateral: json['is_unilateral'] as bool,
      isBodyweight: json['is_bodyweight'] as bool,
      instructionsEn: List<String>.from(json['instructions_en'] as List),
      instructionsDe: List<String>.from(json['instructions_de'] as List),
      instructionsEs: List<String>.from(json['instructions_es'] as List),
      tipsEn: List<String>.from(json['tips_en'] as List),
      tipsDe: List<String>.from(json['tips_de'] as List),
      tipsEs: List<String>.from(json['tips_es'] as List),
      met: (json['met'] as num).toDouble(),
      images: ExerciseImages.fromJson(json['images'] as Map<String, dynamic>),
    );
  }

  final String id;
  final String nameEn;
  final String nameDe;
  final String nameEs;
  final String descriptionEn;
  final String descriptionDe;
  final String descriptionEs;
  final ExerciseCategory category;
  final ForceType forceType;
  final Mechanic mechanic;
  final Difficulty difficulty;
  final Equipment? equipment;
  final BodyPart bodyPart;
  final List<Muscle> primaryMuscles;
  final List<Muscle> secondaryMuscles;
  final List<ExerciseGoal> goals;
  final List<String> tags;
  final String? variationGroup;
  final bool isUnilateral;
  final bool isBodyweight;
  final List<String> instructionsEn;
  final List<String> instructionsDe;
  final List<String> instructionsEs;
  final List<String> tipsEn;
  final List<String> tipsDe;
  final List<String> tipsEs;
  final double met;
  final ExerciseImages images;

  String get name => nameEs;
  String get description => descriptionEs;
  List<String> get instructions => instructionsEs;
  List<String> get tips => tipsEs;
  String? get equipmentAsset => equipment?.imageAsset;

  Map<String, dynamic> toJson() => {
        'id': id,
        'name_en': nameEn,
        'name_de': nameDe,
        'name_es': nameEs,
        'description_en': descriptionEn,
        'description_de': descriptionDe,
        'description_es': descriptionEs,
        'category': category.toJson(),
        'force_type': forceType.toJson(),
        'mechanic': mechanic.toJson(),
        'difficulty': difficulty.toJson(),
        if (equipment != null) 'equipment': equipment!.toJson(),
        'body_part': bodyPart.toJson(),
        'primary_muscles': primaryMuscles.map((m) => m.toJson()).toList(),
        if (secondaryMuscles.isNotEmpty)
          'secondary_muscles': secondaryMuscles.map((m) => m.toJson()).toList(),
        'goals': goals.map((g) => g.toJson()).toList(),
        if (tags.isNotEmpty) 'tags': tags,
        if (variationGroup != null) 'variation_group': variationGroup,
        'is_unilateral': isUnilateral,
        'is_bodyweight': isBodyweight,
        'instructions_en': instructionsEn,
        'instructions_de': instructionsDe,
        'instructions_es': instructionsEs,
        'tips_en': tipsEn,
        'tips_de': tipsDe,
        'tips_es': tipsEs,
        'met': met,
        'images': images.toJson(),
      };
}

class ExerciseImages {
  const ExerciseImages({this.start, this.peak, this.main});

  factory ExerciseImages.fromJson(Map<String, dynamic> json) {
    final flat = json['flat'] as Map<String, dynamic>? ?? const {};
    return ExerciseImages(
      start: flat['start'] as String?,
      peak: flat['peak'] as String?,
      main: flat['main'] as String?,
    );
  }

  final String? start;
  final String? peak;
  final String? main;

  String? get startAsset => _asset(start);
  String? get peakAsset => _asset(peak);
  String? get mainAsset => _asset(main);

  Map<String, dynamic> toJson() => {
        'flat': {
          if (start != null) 'start': start,
          if (peak != null) 'peak': peak,
          if (main != null) 'main': main,
        },
      };

  static String? _asset(String? path) => path == null ? null : 'assets/$path';
}

class ExerciseDataset {
  const ExerciseDataset({
    required this.name,
    required this.schemaVersion,
    required this.count,
    required this.exercises,
    this.homepage,
    this.license,
    this.note,
  });

  factory ExerciseDataset.fromJson(Map<String, dynamic> json) {
    return ExerciseDataset(
      name: json['name'] as String,
      homepage: json['homepage'] as String?,
      license: json['license'] as String?,
      schemaVersion: json['schema_version'] as int,
      count: json['count'] as int,
      note: json['note'] as String?,
      exercises: (json['exercises'] as List)
          .map((e) => Exercise.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  final String name;
  final String? homepage;
  final String? license;
  final int schemaVersion;
  final int count;
  final String? note;
  final List<Exercise> exercises;

  Map<String, dynamic> toJson() => {
        'name': name,
        'homepage': homepage,
        'license': license,
        'schema_version': schemaVersion,
        'count': count,
        'note': note,
        'exercises': exercises.map((e) => e.toJson()).toList(),
      };
}
