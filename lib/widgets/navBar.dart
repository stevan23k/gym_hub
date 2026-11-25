import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:gym_hub/constants.dart';

class NavBar extends StatelessWidget {
  const NavBar({super.key, required this.currentIndex, required this.onTap});

  final int currentIndex;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: currentIndex,
      onTap: onTap,
      selectedItemColor: kPrimaryColor,
      unselectedItemColor: Colors.grey,
      items: const [
        BottomNavigationBarItem(icon: Icon(LucideIcons.house), label: 'Inicio'),
        BottomNavigationBarItem(
          icon: Icon(LucideIcons.calendar),
          label: 'Calendario',
        ),
      ],
    );
  }
}
