import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:gym_hub/models/exercise.dart';

class ExerciseService {
  static List<Exercise>? _cache;

  static Future<List<Exercise>> load() async {
    if (_cache != null) return _cache!;
    final raw = await rootBundle.loadString('assets/exercises.json');
    final dataset = ExerciseDataset.fromJson(
      jsonDecode(raw) as Map<String, dynamic>,
    );
    _cache = dataset.exercises;
    return _cache!;
  }

  static List<Exercise> search(String query) {
    final normalized = _normalize(query);
    if (normalized.isEmpty) return const [];
    return (_cache ?? const [])
        .where((e) => _normalize(e.nameEs).contains(normalized))
        .toList();
  }

  static String _normalize(String value) {
    var result = value.toLowerCase();
    const equivalents = {
      'á': 'a',
      'à': 'a',
      'ä': 'a',
      'â': 'a',
      'é': 'e',
      'è': 'e',
      'ë': 'e',
      'ê': 'e',
      'í': 'i',
      'ì': 'i',
      'ï': 'i',
      'î': 'i',
      'ó': 'o',
      'ò': 'o',
      'ö': 'o',
      'ô': 'o',
      'ú': 'u',
      'ù': 'u',
      'ü': 'u',
      'û': 'u',
      'ñ': 'n',
      'ç': 'c',
    };
    equivalents.forEach((from, to) => result = result.replaceAll(from, to));
    return result;
  }
}
