import 'package:flutter/material.dart';
import 'package:gym_hub/ruta/auth_gate.dart';
import 'package:gym_hub/screens/home.dart';
import 'package:gym_hub/screens/login.dart';
import 'package:gym_hub/screens/register.dart';

/// Rutas nombradas de la app y generador centralizado de páginas.
class Rutas {
  static const String inicio = '/';
  static const String login = '/login';
  static const String registro = '/registro';
  static const String home = '/home';

  static Route<dynamic> generarRuta(RouteSettings settings) {
    switch (settings.name) {
      case login:
        return MaterialPageRoute(
          builder: (_) => const LoginScreen(),
          settings: settings,
        );
      case registro:
        return MaterialPageRoute(
          builder: (_) => const RegisterScreen(),
          settings: settings,
        );
      case home:
        return MaterialPageRoute(
          builder: (_) => HomePage(),
          settings: settings,
        );
      case inicio:
      default:
        return MaterialPageRoute(
          builder: (_) => const AuthGate(),
          settings: settings,
        );
    }
  }
}
