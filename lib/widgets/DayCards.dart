import 'package:flutter/material.dart';
import 'package:gym_hub/constants.dart';

enum DayCardVariant { normal, selected, today }

class WeekDays extends StatefulWidget {
  const WeekDays({super.key, required this.days, this.onDayTap});

  final List<String> days;
  final void Function(int index)? onDayTap;

  @override
  State<WeekDays> createState() => _WeekDaysState();
}

class _WeekDaysState extends State<WeekDays> {
  int? _selected;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: List.generate(widget.days.length, (index) {
        return DayCard(
          day: widget.days[index],
          variant: _selected == index
              ? DayCardVariant.selected
              : DayCardVariant.normal,
          onTap: () {
            setState(() => _selected = index);
            widget.onDayTap?.call(index);
          },
        );
      }),
    );
  }
}

class DayCard extends StatefulWidget {
  const DayCard({
    super.key,
    required this.day,
    this.variant = DayCardVariant.normal,
    this.onTap,
  });

  final String day;
  final DayCardVariant variant;
  final VoidCallback? onTap;

  @override
  State<DayCard> createState() => _DayCardState();
}

class _DayCardState extends State<DayCard> {
  bool _pressed = false;

  void _setPressed(bool value) {
    if (_pressed == value) return;
    setState(() => _pressed = value);
  }

  @override
  Widget build(BuildContext context) {
    final color = switch (widget.variant) {
      DayCardVariant.normal => backgroundColor,
      DayCardVariant.selected => kPrimaryColor,
      DayCardVariant.today => backgroundCard,
    };

    return Padding(
      padding: const EdgeInsets.only(top: 10, bottom: 20),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTapDown: (_) => _setPressed(true),
        onTapUp: (_) => _setPressed(false),
        onTapCancel: () => _setPressed(false),
        onTap: widget.onTap,
        child: AnimatedScale(
          scale: _pressed ? 0.94 : 1,
          duration: const Duration(milliseconds: 120),
          curve: Curves.easeOutCubic,
          child: Container(
            width: widget.variant == DayCardVariant.normal ? 350 : 380,
            height: 95,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(50),
              border: Border.all(
                color: widget.variant == DayCardVariant.normal
                    ? kPrimaryColor
                    : textColor,
                width: 4,
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.only(left: 20, right: 10),
              child: Row(
                children: [
                  Text(
                    widget.day,
                    style: TextStyle(
                      fontSize: 30,
                      color: widget.variant == DayCardVariant.normal
                          ? kPrimaryColor
                          : textColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
