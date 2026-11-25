import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:gym_hub/constants.dart';
import 'package:gym_hub/models/day.dart';
import 'package:gym_hub/models/exercise.dart';
import 'package:gym_hub/services/exercise_service.dart';
import 'package:gym_hub/services/routines_service.dart';
import 'package:gym_hub/widgets/custom_button.dart';
import 'package:gym_hub/widgets/custom_text_field.dart';

class EditExerciseScreen extends StatefulWidget {
  const EditExerciseScreen({
    super.key,
    required this.dayName,
    required this.index,
    required this.exercise,
  });

  final String dayName;
  final int index;
  final RoutineExercise exercise;

  @override
  State<EditExerciseScreen> createState() => _EditExerciseScreenState();
}

class _EditExerciseScreenState extends State<EditExerciseScreen> {
  late final TextEditingController _exerciseController = TextEditingController(
    text: widget.exercise.name,
  );
  late final TextEditingController _seriesController = TextEditingController(
    text: widget.exercise.series.toString(),
  );
  late final TextEditingController _repsController = TextEditingController(
    text: widget.exercise.reps.toString(),
  );

  Exercise? _selected;
  String? _imagePath;
  bool _buscando = false;
  bool _guardando = false;

  @override
  void initState() {
    super.initState();
    _imagePath = widget.exercise.image;
    _loadExercises();
  }

  @override
  void dispose() {
    _exerciseController.dispose();
    _seriesController.dispose();
    _repsController.dispose();
    super.dispose();
  }

  Future<void> _loadExercises() async {
    await ExerciseService.load();
    if (!mounted) return;
    setState(() {});
  }

  String get _query => _exerciseController.text.trim();

  List<Exercise> get _results {
    if (!_buscando || _query.isEmpty) return const [];
    if (_selected != null && _selected!.nameEs.trim() == _query) {
      return const [];
    }
    return ExerciseService.search(_query).take(5).toList();
  }

  void _select(Exercise exercise) {
    FocusScope.of(context).unfocus();
    setState(() {
      _selected = exercise;
      _exerciseController.text = exercise.nameEs;
      _imagePath =
          exercise.images.startAsset ??
          exercise.images.peakAsset ??
          exercise.images.mainAsset;
    });
  }

  int? _positiveInt(TextEditingController controller) {
    final value = int.tryParse(controller.text.trim());
    return value == null || value <= 0 ? null : value;
  }

  Future<void> _guardar() async {
    final name = _query;
    final series = _positiveInt(_seriesController);
    final reps = _positiveInt(_repsController);
    if (name.isEmpty || series == null || reps == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Completa el ejercicio, las series y las repeticiones'),
          backgroundColor: kPrimaryColor,
        ),
      );
      return;
    }

    setState(() => _guardando = true);
    try {
      await RoutinesService.updateExercise(
        widget.dayName,
        widget.index,
        RoutineExercise(
          id: widget.exercise.storageId,
          name: name,
          series: series,
          reps: reps,
          image: _imagePath,
        ),
      );
      if (mounted) Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('No se pudo guardar: $e'),
          backgroundColor: kPrimaryColor,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _guardando = false);
      }
    }
  }

  Widget _buildResults(List<Exercise> results) {
    return Container(
      margin: const EdgeInsets.only(top: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
        border: Border.all(color: kSecondary, width: 2),
      ),
      child: Column(
        children: [
          for (final exercise in results)
            InkWell(
              onTap: () => _select(exercise),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        exercise.nameEs,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: kPrimaryColor,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final results = _results;

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: const Text(
          'Editar ejercicio',
          style: TextStyle(fontWeight: FontWeight.bold, color: textColor),
        ),
        elevation: 0,
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 25),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 20, bottom: 20),
              child: Text(
                widget.dayName,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                  color: kPrimaryColor,
                ),
              ),
            ),
            CustomTextField(
              controller: _exerciseController,
              onChanged: (_) => setState(() {
                _selected = null;
                _buscando = true;
              }),
              label: 'Ejercicio',
            ),
            if (results.isNotEmpty) _buildResults(results),
            const SizedBox(height: 6),
            const Text(
              'Escribí para buscar otro ejercicio y cambiar su imagen',
              style: TextStyle(fontSize: 12, color: Color(0xFF777777)),
            ),
            const SizedBox(height: 15),
            Row(
              children: [
                Expanded(
                  child: CustomTextField(
                    controller: _repsController,
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    label: 'Repeticiones',
                  ),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: CustomTextField(
                    controller: _seriesController,
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    label: 'Series',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Container(
              height: 180,
              clipBehavior: Clip.antiAlias,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(25),
                border: Border.all(color: kSecondary, width: 2),
                color: Colors.white,
              ),
              child: _imagePath == null
                  ? const Center(
                      child: Icon(
                        LucideIcons.dumbbell,
                        size: 60,
                        color: kSecondary,
                      ),
                    )
                  : Image.asset(_imagePath!, fit: BoxFit.cover),
            ),
            const SizedBox(height: 25),
            CustomButton(
              text: _guardando ? 'Guardando...' : 'Guardar cambios',
              onPressed: _guardando ? () {} : () => _guardar(),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}
