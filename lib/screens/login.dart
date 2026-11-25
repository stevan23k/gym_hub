import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:gym_hub/constants.dart';
import 'package:gym_hub/ruta/rutas.dart';
import 'package:gym_hub/services/auth_service.dart';
import 'package:gym_hub/widgets/custom_button.dart';
import 'package:gym_hub/widgets/custom_text_field.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _cargando = false;
  bool _verPassword = false;
  String? _error;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _iniciarSesion() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    if (email.isEmpty || password.isEmpty) {
      setState(() => _error = 'Ingresa tu correo y contraseña.');
      return;
    }

    setState(() {
      _cargando = true;
      _error = null;
    });

    try {
      await AuthService.iniciarSesion(email: email, password: password);
      if (!mounted) return;
      Navigator.of(context).pushNamedAndRemoveUntil(Rutas.inicio, (_) => false);
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
      setState(() => _error = AuthService.mensajeError(e));
    } catch (_) {
      if (!mounted) return;
      setState(() => _error = 'Ocurrió un error. Intenta de nuevo.');
    } finally {
      if (mounted) {
        setState(() => _cargando = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 48),
              const Icon(Icons.fitness_center, size: 72, color: kPrimaryColor),
              const SizedBox(height: 16),
              const Text(
                'Gym Hub',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: kPrimaryColor,
                ),
              ),
              const Text(
                'Inicia sesión para continuar',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Color(0xFF555555)),
              ),
              const SizedBox(height: 40),
              CustomTextField(
                controller: _emailController,
                label: 'Correo electrónico',
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 16),
              CustomTextField(
                controller: _passwordController,
                label: 'Contraseña',
                obscureText: !_verPassword,
                suffixIcon: IconButton(
                  icon: Icon(
                    _verPassword ? Icons.visibility_off : Icons.visibility,
                    color: kPrimaryColor,
                  ),
                  tooltip: _verPassword
                      ? 'Ocultar contraseña'
                      : 'Ver contraseña',
                  onPressed: () => setState(() => _verPassword = !_verPassword),
                ),
              ),
              const SizedBox(height: 20),
              if (_error != null) ...[
                Text(
                  _error!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: kPrimaryColor),
                ),
                const SizedBox(height: 12),
              ],
              CustomButton(
                text: _cargando ? 'Iniciando sesión...' : 'Iniciar sesión',
                onPressed: _cargando ? () {} : _iniciarSesion,
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    '¿No tienes cuenta?',
                    style: TextStyle(color: Color(0xFF555555)),
                  ),
                  TextButton(
                    onPressed: () =>
                        Navigator.of(context).pushNamed(Rutas.registro),
                    child: const Text('Regístrate'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
