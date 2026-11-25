import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:gym_hub/constants.dart';
import 'package:gym_hub/services/streak_service.dart';
import 'package:intl/intl.dart';

class DayBanner extends StatefulWidget {
  const DayBanner({super.key, required this.title});

  final String title;

  @override
  State<DayBanner> createState() => _DayBannerState();
}

class _DayBannerState extends State<DayBanner> {
  late Timer _timer;
  late String _hour;

  @override
  void initState() {
    super.initState();
    _hour = _currentHour();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      setState(() => _hour = _currentHour());
    });
  }

  String _currentHour() => DateFormat('HH:mm:ss').format(DateTime.now());

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Container(
      height: math.max(size.height * 0.2 - 50, 110),
      decoration: BoxDecoration(
        color: kPrimaryColor,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(60),
          bottomRight: Radius.circular(60),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.only(left: 35),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.title,
              style: const TextStyle(
                fontSize: 48,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(LucideIcons.clock, color: Colors.grey, size: 20),
                const SizedBox(width: 6),
                Text(
                  _hour,
                  style: const TextStyle(fontSize: 18, color: Colors.grey),
                ),
                const SizedBox(width: 20),
                const Icon(LucideIcons.flame, color: Colors.yellow, size: 24),
                const SizedBox(width: 6),
                StreamBuilder<int>(
                  stream: StreakService.watchStreak(),
                  builder: (context, snapshot) {
                    final racha = snapshot.data ?? 0;
                    return Text(
                      '$racha',
                      style: const TextStyle(
                        color: Colors.yellow,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    );
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
