import 'package:flutter/material.dart';

import 'package:flutter_lucide/flutter_lucide.dart';

class NavBar extends StatefulWidget {
  const NavBar({super.key});

  @override
  State<NavBar> createState() => _NavBarState();
}

class _NavBarState extends State<NavBar> {
  int _currentPage = 0;

  void _navigate(int index) {
    setState(() {
      _currentPage = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: _currentPage,
      onTap: _navigate,
      items: [
        BottomNavigationBarItem(icon: Icon(LucideIcons.house), label: "Inicio"),
        BottomNavigationBarItem(
          icon: Icon(LucideIcons.calendar),
          label: "Calendario",
        ),
      ],
    );
  }
}
