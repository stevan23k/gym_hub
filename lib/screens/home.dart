import 'package:flutter/material.dart';
import 'package:gym_hub/constants.dart';
import 'package:gym_hub/services/auth_service.dart';
import 'package:gym_hub/services/migration_service.dart';

import '../widgets/home/body.dart';
import '../widgets/navBar.dart';
import 'calendar.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _pagina = 0;

  @override
  void initState() {
    super.initState();
    MigrationService.limpiarEjercicioDemo();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Theme.of(context).colorScheme.primary,
        title: Text(
          _pagina == 0 ? 'Gym Hub' : 'Calendario',
          style: const TextStyle(fontWeight: FontWeight.bold, color: textColor),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            color: textColor,
            tooltip: 'Cerrar sesión',
            onPressed: () async {
              await AuthService.cerrarSesion();
            },
          ),
        ],
      ),
      body: IndexedStack(
        index: _pagina,
        children: const [Body(), CalendarScreen()],
      ),
      bottomNavigationBar: NavBar(
        currentIndex: _pagina,
        onTap: (index) => setState(() => _pagina = index),
      ),
    );
  }
}
