import 'dart:async';

import '../../screens/info_day.dart';
import '../../widgets/DayCards.dart';
import '../day_banner.dart';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class Body extends StatefulWidget {
  const Body({super.key});

  @override
  State<Body> createState() => _BodyState();
}

class _BodyState extends State<Body> {
  late DateTime now;
  late String dayWeek;
  late Timer timer;

  @override
  void initState() {
    super.initState();
    actualizar();
    timer = Timer.periodic(Duration(seconds: 1), (_) => actualizar());
  }

  void actualizar() {
    setState(() {
      now = DateTime.now();
      dayWeek = DateFormat('EEEE', 'es').format(now);
    });
  }

  @override
  void dispose() {
    timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        DayBanner(title: dayWeek),
        Expanded(
          child: SingleChildScrollView(
            child: ContainersMain(weekday: now.weekday),
          ),
        ),
      ],
    );
  }
}

const _diasSemana = [
  'Lunes',
  'Martes',
  'Miércoles',
  'Jueves',
  'Viernes',
  'Sábado',
  'Domingo',
];

class ContainersMain extends StatefulWidget {
  const ContainersMain({super.key, required this.weekday});

  final int weekday;

  @override
  State<ContainersMain> createState() => _ContainersMainState();
}

class _ContainersMainState extends State<ContainersMain> {
  int? _selected;

  DayCardVariant _variantFor(int index) {
    if (index + 1 == _selected) return DayCardVariant.selected;
    if (index + 1 == widget.weekday) return DayCardVariant.today;
    return DayCardVariant.normal;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (var i = 0; i < _diasSemana.length; i++)
          DayCard(
            day: _diasSemana[i],
            variant: _variantFor(i),
            onTap: () {
              setState(() => _selected = i + 1);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => InfoDayScreen(dayName: _diasSemana[i]),
                ),
              );
            },
          ),
      ],
    );
  }
}
