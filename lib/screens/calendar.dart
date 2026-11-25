import 'package:flutter/material.dart';
import 'package:gym_hub/constants.dart';
import 'package:gym_hub/models/day_progress.dart';
import 'package:gym_hub/services/calendar_service.dart';
import 'package:gym_hub/services/firebase_paths.dart';
import 'package:intl/intl.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  final DateTime _hoy = DateTime.now();
  DateTime _mes = DateTime(DateTime.now().year, DateTime.now().month);
  late Stream<List<DayProgress>> _stream = CalendarService.watchMonth(_mes);

  String _capitalizar(String texto) =>
      texto.isEmpty ? texto : texto[0].toUpperCase() + texto.substring(1);

  bool _mismoDia(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  String get _tituloMes =>
      _capitalizar(DateFormat('MMMM yyyy', 'es').format(_mes));

  /// Semanas completas (lunes a domingo) que cubren el mes mostrado.
  List<DateTime> get _celdas {
    final primero = DateTime(_mes.year, _mes.month, 1);
    final inicio = primero.subtract(Duration(days: primero.weekday - 1));
    final ultimo = DateTime(_mes.year, _mes.month + 1, 0);
    final fin = ultimo.add(Duration(days: 7 - ultimo.weekday));

    final celdas = <DateTime>[];
    var dia = inicio;
    while (!dia.isAfter(fin)) {
      celdas.add(dia);
      dia = dia.add(const Duration(days: 1));
    }
    return celdas;
  }

  void _cambiarMes(int delta) {
    setState(() {
      _mes = DateTime(_mes.year, _mes.month + delta);
      _stream = CalendarService.watchMonth(_mes);
    });
  }

  void _irHoy() {
    setState(() {
      _mes = DateTime(_hoy.year, _hoy.month);
      _stream = CalendarService.watchMonth(_mes);
    });
  }

  void _mostrarDetalle(DayProgress progreso, DateTime fecha) {
    final titulo = _capitalizar(
      DateFormat("EEEE d 'de' MMMM", 'es').format(fecha),
    );

    showModalBottomSheet<void>(
      context: context,
      backgroundColor: backgroundColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      builder: (sheetContext) => Padding(
        padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
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
              titulo,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: kPrimaryColor,
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: LinearProgressIndicator(
                      value: progreso.percentage,
                      minHeight: 10,
                      backgroundColor: kSecondary,
                      color: kPrimaryColor,
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Text(
                  '${progreso.percent}%',
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: kPrimaryColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Text(
              progreso.total == 0
                  ? 'No hay rutina cargada para este día.'
                  : '${progreso.completed} de ${progreso.total} ejercicios completados',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 15, color: Color(0xFF555555)),
            ),
            if (!progreso.isTrained)
              const Padding(
                padding: EdgeInsets.only(top: 8),
                child: Text(
                  'Sin actividad registrada.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 13, color: Color(0xFF999999)),
                ),
              ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: const Icon(Icons.chevron_left),
                color: kPrimaryColor,
                onPressed: () => _cambiarMes(-1),
              ),
              Text(
                _tituloMes,
                style: const TextStyle(
                  fontSize: 19,
                  fontWeight: FontWeight.bold,
                  color: kPrimaryColor,
                ),
              ),
              Row(
                children: [
                  TextButton(onPressed: _irHoy, child: const Text('Hoy')),
                  IconButton(
                    icon: const Icon(Icons.chevron_right),
                    color: kPrimaryColor,
                    onPressed: () => _cambiarMes(1),
                  ),
                ],
              ),
            ],
          ),
        ),
        Expanded(
          child: StreamBuilder<List<DayProgress>>(
            stream: _stream,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(color: kPrimaryColor),
                );
              }
              if (snapshot.hasError) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Text(
                      'Error al cargar el calendario: ${snapshot.error}',
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: kPrimaryColor),
                    ),
                  ),
                );
              }

              final dias = snapshot.data ?? const <DayProgress>[];
              final progresos = {for (final p in dias) p.date: p};
              final entrenados = dias.where((d) => d.isTrained).toList();
              final promedio = entrenados.isEmpty
                  ? 0.0
                  : entrenados.fold<double>(
                          0,
                          (suma, d) => suma + d.percentage,
                        ) /
                        entrenados.length;
              final celdas = _celdas;

              return LayoutBuilder(
                builder: (context, constraints) {
                  final semanas = (celdas.length / 7).ceil();
                  final altoCelda =
                      ((constraints.maxHeight - 190 - (semanas - 1) * 5) /
                              semanas)
                          .clamp(36.0, 52.0)
                          .toDouble();
                  return SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(14, 6, 14, 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 18,
                            vertical: 16,
                          ),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [kPrimaryColor, Color(0xFFB7122C)],
                            ),
                            borderRadius: BorderRadius.circular(22),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: _Stat(
                                  valor: '${entrenados.length}',
                                  etiqueta: 'días entrenados',
                                ),
                              ),
                              Container(
                                width: 1,
                                height: 40,
                                color: Colors.white54,
                              ),
                              Expanded(
                                child: _Stat(
                                  valor: '${(promedio * 100).round()}%',
                                  etiqueta: 'cumplimiento promedio',
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 14),
                        Container(
                          padding: const EdgeInsets.fromLTRB(8, 12, 8, 10),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(22),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.05),
                                blurRadius: 10,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  for (final letra in [
                                    'L',
                                    'M',
                                    'M',
                                    'J',
                                    'V',
                                    'S',
                                    'D',
                                  ])
                                    Expanded(
                                      child: Center(
                                        child: Text(
                                          letra,
                                          style: const TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold,
                                            color: kPrimaryColor,
                                          ),
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              GridView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                gridDelegate:
                                    SliverGridDelegateWithFixedCrossAxisCount(
                                      crossAxisCount: 7,
                                      mainAxisExtent: altoCelda,
                                      crossAxisSpacing: 3,
                                      mainAxisSpacing: 5,
                                    ),
                                itemCount: celdas.length,
                                itemBuilder: (context, index) {
                                  final fecha = celdas[index];
                                  final delMes =
                                      fecha.month == _mes.month &&
                                      fecha.year == _mes.year;
                                  final clave = FirebasePaths.dateKey(fecha);
                                  final progreso = delMes
                                      ? progresos[clave]
                                      : null;
                                  final entrenado =
                                      delMes && (progreso?.isTrained ?? false);
                                  final esHoy =
                                      delMes && _mismoDia(fecha, _hoy);

                                  final fondo = entrenado
                                      ? kPrimaryColor
                                      : (delMes
                                            ? const Color(0xFFFAFAFA)
                                            : Colors.white);
                                  final borde = esHoy
                                      ? kPrimaryColor
                                      : (entrenado
                                            ? kPrimaryColor
                                            : (delMes
                                                  ? const Color(0xFFEDEDED)
                                                  : Colors.transparent));
                                  final colorNumero = entrenado
                                      ? Colors.white
                                      : (delMes
                                            ? const Color(0xFF444444)
                                            : const Color(0xFFC4C4C4));

                                  return InkWell(
                                    onTap: delMes
                                        ? () => _mostrarDetalle(
                                            progreso ??
                                                DayProgress(
                                                  date: clave,
                                                  completed: 0,
                                                  total: 0,
                                                ),
                                            fecha,
                                          )
                                        : null,
                                    borderRadius: BorderRadius.circular(12),
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: fondo,
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(
                                          color: borde,
                                          width: esHoy ? 2 : 1,
                                        ),
                                      ),
                                      child: Center(
                                        child: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Text(
                                              '${fecha.day}',
                                              style: TextStyle(
                                                fontSize: 14,
                                                fontWeight: entrenado || esHoy
                                                    ? FontWeight.bold
                                                    : FontWeight.w500,
                                                color: colorNumero,
                                              ),
                                            ),
                                            if (entrenado) ...[
                                              const SizedBox(height: 1),
                                              Text(
                                                '${progreso!.percent}%',
                                                style: const TextStyle(
                                                  fontSize: 9,
                                                  color: Colors.white,
                                                ),
                                              ),
                                              const SizedBox(height: 2),
                                              ClipRRect(
                                                borderRadius:
                                                    BorderRadius.circular(4),
                                                child: SizedBox(
                                                  width: 24,
                                                  height: 3,
                                                  child:
                                                      LinearProgressIndicator(
                                                        value:
                                                            progreso.percentage,
                                                        backgroundColor:
                                                            Colors.white54,
                                                        color: Colors.white,
                                                      ),
                                                ),
                                              ),
                                            ],
                                          ],
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 14),
                        const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.circle, size: 10, color: kPrimaryColor),
                            SizedBox(width: 6),
                            Text(
                              'Entrenamiento',
                              style: TextStyle(
                                fontSize: 12,
                                color: Color(0xFF666666),
                              ),
                            ),
                            SizedBox(width: 16),
                            Icon(
                              Icons.circle_outlined,
                              size: 10,
                              color: Color(0xFFBBBBBB),
                            ),
                            SizedBox(width: 6),
                            Text(
                              'Sin actividad',
                              style: TextStyle(
                                fontSize: 12,
                                color: Color(0xFF666666),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({required this.valor, required this.etiqueta});

  final String valor;
  final String etiqueta;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          valor,
          style: const TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        Text(
          etiqueta,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 11, color: Colors.white),
        ),
      ],
    );
  }
}
