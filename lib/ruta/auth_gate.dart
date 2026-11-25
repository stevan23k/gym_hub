import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:gym_hub/constants.dart';
import 'package:gym_hub/screens/home.dart';
import 'package:gym_hub/screens/login.dart';
import 'package:gym_hub/services/auth_service.dart';

/// Muestra la home si hay sesión activa y el login en caso contrario.
class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: AuthService.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            backgroundColor: backgroundColor,
            body: Center(
              child: CircularProgressIndicator(color: kPrimaryColor),
            ),
          );
        }

        if (snapshot.hasData) {
          return HomePage();
        }

        return const LoginScreen();
      },
    );
  }
}
