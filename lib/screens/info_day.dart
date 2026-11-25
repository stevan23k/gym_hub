import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:gym_hub/constants.dart';
import 'package:gym_hub/models/day.dart';
import 'package:gym_hub/services/firebase_paths.dart';
import 'package:gym_hub/services/history_service.dart';
import 'package:gym_hub/services/routines_service.dart';
import 'package:intl/intl.dart';

import '../widgets/day_banner.dart';
import 'add_exercise.dart';
import 'edit_exercise.dart';

enum _AccionEjercicio { editar, eliminar }

class InfoDayScreen extends StatefulWidget {
  const InfoDayScreen({super.key, required this.dayName});

  final String dayName;

  @override
  State<InfoDayScreen> createState() => _InfoDayScreenState();
}

class _InfoDayScreenState extends State<InfoDayScreen> {
  /// Cada día de semana apunta a su fecha real dentro de la semana actual.
  late final DateTime _date = FirebasePaths.dateForDay(widget.dayName);

  late final Stream<DayRoutine> _routineStream = RoutinesService.watchDay(
    widget.dayName,
  );
  late final Stream<Set<String>> _historyStream = HistoryService.watchDay(
    _date,
  );

  String get _fechaLegible {
    final texto = DateFormat("EEEE d 'de' MMMM", 'es').format(_date);
    return texto[0].toUpperCase() + texto.substring(1);
  }

  Future<void> _setCompleted(RoutineExercise exercise, bool completed) {
    return HistoryService.setExerciseCompleted(
      date: _date,
      dayName: widget.dayName,
      exerciseId: exercise.storageId,
      completed: completed,
    );
  }

  Future<void> _mostrarOpciones(RoutineExercise exercise, int index) async {
    final accion = await showModalBottomSheet<_AccionEjercicio>(
      context: context,
      backgroundColor: backgroundColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      builder: (sheetContext) => Padding(
        padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: kSecondary,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              exercise.name,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: kPrimaryColor,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Rutina del ${widget.dayName}',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 14, color: Color(0xFF555555)),
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.edit, color: kPrimaryColor),
              title: const Text('Editar'),
              onTap: () => Navigator.pop(sheetContext, _AccionEjercicio.editar),
            ),
            ListTile(
              leading: const Icon(Icons.delete_outline, color: kPrimaryColor),
              title: const Text('Eliminar'),
              onTap: () =>
                  Navigator.pop(sheetContext, _AccionEjercicio.eliminar),
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: () => Navigator.pop(sheetContext),
              child: const Text('Cancelar'),
            ),
          ],
        ),
      ),
    );

    if (accion == null || !mounted) return;

    switch (accion) {
      case _AccionEjercicio.editar:
        final guardado = await Navigator.push<bool>(
          context,
          MaterialPageRoute(
            builder: (_) => EditExerciseScreen(
              dayName: widget.dayName,
              index: index,
              exercise: exercise,
            ),
          ),
        );
        if (guardado == true && mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Ejercicio actualizado'),
              backgroundColor: kPrimaryColor,
            ),
          );
        }
      case _AccionEjercicio.eliminar:
        try {
          await RoutinesService.removeExercise(widget.dayName, index);
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Ejercicio eliminado'),
              backgroundColor: kPrimaryColor,
            ),
          );
        } catch (e) {
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('No se pudo eliminar: $e'),
              backgroundColor: kPrimaryColor,
            ),
          );
        }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: kPrimaryColor,
        foregroundColor: textColor,
        shape: const CircleBorder(),
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => AddExerciseScreen(dayName: widget.dayName),
            ),
          );
        },
        child: const Icon(LucideIcons.plus, size: 32),
      ),
      body: Column(
        children: [
          DayBanner(title: widget.dayName),
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Text(
              _fechaLegible,
              style: const TextStyle(fontSize: 14, color: Color(0xFF666666)),
            ),
          ),
          Expanded(
            child: StreamBuilder<DayRoutine>(
              stream: _routineStream,
              builder: (context, routineSnapshot) {
                if (routineSnapshot.connectionState ==
                    ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (routineSnapshot.hasError) {
                  return _Error(message: '${routineSnapshot.error}');
                }

                final exercises =
                    routineSnapshot.data?.exercises ??
                    const <RoutineExercise>[];

                return StreamBuilder<Set<String>>(
                  stream: _historyStream,
                  builder: (context, historySnapshot) {
                    if (historySnapshot.hasError) {
                      return _Error(message: '${historySnapshot.error}');
                    }
                    if (historySnapshot.connectionState ==
                        ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    final completed = historySnapshot.data ?? const <String>{};

                    return ListView.builder(
                      padding: const EdgeInsets.only(top: 10, bottom: 100),
                      itemCount: exercises.length,
                      itemBuilder: (context, index) {
                        final exercise = exercises[index];
                        return _ExercisePill(
                          exercise: exercise,
                          completed: completed.contains(exercise.storageId),
                          onChanged: (value) =>
                              _setCompleted(exercise, value ?? false),
                          onLongPress: () => _mostrarOpciones(exercise, index),
                        );
                      },
                    );
                  },
                );
              },
            ),
          ),
          const Padding(
            padding: EdgeInsets.only(bottom: 12, right: 70),
            child: Text(
              'Mantén presionado un ejercicio para editarlo o eliminarlo',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12, color: Color(0xFF777777)),
            ),
          ),
        ],
      ),
    );
  }
}

class _Error extends StatelessWidget {
  const _Error({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Text(
          'Error al cargar la rutina: $message',
          textAlign: TextAlign.center,
          style: const TextStyle(color: kPrimaryColor),
        ),
      ),
    );
  }
}

class _ExercisePill extends StatelessWidget {
  const _ExercisePill({
    required this.exercise,
    required this.completed,
    required this.onChanged,
    required this.onLongPress,
  });

  final RoutineExercise exercise;
  final bool completed;
  final ValueChanged<bool?> onChanged;
  final VoidCallback onLongPress;

  @override
  Widget build(BuildContext context) {
    final foreground = completed ? textColor : kPrimaryColor;

    return GestureDetector(
      onLongPress: onLongPress,
      child: Padding(
        padding: const EdgeInsets.only(top: 10, bottom: 10),
        child: Container(
          width: 360,
          decoration: BoxDecoration(
            color: completed ? backgroundCard : backgroundColor,
            borderRadius: BorderRadius.circular(50),
            border: Border.all(
              color: completed ? textColor : kPrimaryColor,
              width: 4,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
            child: Row(
              children: [
                Checkbox(
                  value: completed,
                  onChanged: onChanged,
                  activeColor: kPrimaryColor,
                  checkColor: textColor,
                  side: const BorderSide(color: kPrimaryColor, width: 2),
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        exercise.name,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: foreground,
                          decoration: completed
                              ? TextDecoration.lineThrough
                              : null,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${exercise.series} series · ${exercise.reps} reps',
                        style: TextStyle(fontSize: 14, color: foreground),
                      ),
                    ],
                  ),
                ),
                ClipRRect(
                  borderRadius: BorderRadius.circular(35),
                  child: exercise.image == null
                      ? const SizedBox(
                          width: 70,
                          height: 70,
                          child: Icon(
                            LucideIcons.dumbbell,
                            size: 34,
                            color: kSecondary,
                          ),
                        )
                      : Image.asset(
                          exercise.image!,
                          width: 70,
                          height: 70,
                          fit: BoxFit.cover,
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
