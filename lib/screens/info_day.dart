import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:gym_hub/constants.dart';
import 'package:gym_hub/models/day.dart';
import 'package:gym_hub/services/routines_service.dart';

import '../widgets/day_banner.dart';
import 'add_exercise.dart';

class InfoDayScreen extends StatefulWidget {
  const InfoDayScreen({super.key, required this.dayName});

  final String dayName;

  @override
  State<InfoDayScreen> createState() => _InfoDayScreenState();
}

class _InfoDayScreenState extends State<InfoDayScreen> {
  final Set<int> _completed = {};

  @override
  Widget build(BuildContext context) {
    final exercises = RoutinesService.of(widget.dayName).exercises;

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
          if (mounted) setState(() {});
        },
        child: const Icon(LucideIcons.plus, size: 32),
      ),
      body: Column(
        children: [
          DayBanner(title: widget.dayName),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.only(top: 10, bottom: 100),
              itemCount: exercises.length,
              itemBuilder: (context, index) => _ExercisePill(
                exercise: exercises[index],
                completed: _completed.contains(index),
                onChanged: (value) {
                  setState(() {
                    if (value == true) {
                      _completed.add(index);
                    } else {
                      _completed.remove(index);
                    }
                  });
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ExercisePill extends StatelessWidget {
  const _ExercisePill({
    required this.exercise,
    required this.completed,
    required this.onChanged,
  });

  final RoutineExercise exercise;
  final bool completed;
  final ValueChanged<bool?> onChanged;

  @override
  Widget build(BuildContext context) {
    final foreground = completed ? textColor : kPrimaryColor;

    return Padding(
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
    );
  }
}
