import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:gym_hub/constants.dart';
import 'package:gym_hub/ruta/rutas.dart';
import 'package:gym_hub/services/auth_service.dart';
import 'package:gym_hub/widgets/custom_button.dart';
import 'package:gym_hub/widgets/custom_text_field.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmController = TextEditingController();

  bool _cargando = false;
  bool _verPassword = false;
  String? _error;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  Future<void> _registrarse() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    if (email.isEmpty || password.isEmpty || _confirmController.text.isEmpty) {
      setState(() => _error = 'Completa todos los campos.');
      return;
    }
    if (password != _confirmController.text) {
      setState(() => _error = 'Las contraseñas no coinciden.');
      return;
    }
    if (password.length < 6) {
      setState(
        () => _error = 'La contraseña debe tener al menos 6 caracteres.',
      );
      return;
    }

    setState(() {
      _cargando = true;
      _error = null;
    });

    try {
      await AuthService.registrarse(email: email, password: password);
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
      appBar: AppBar(
        title: const Text('Crear cuenta'),
        backgroundColor: kPrimaryColor,
        foregroundColor: textColor,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Regístrate',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: kPrimaryColor,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Crea tu cuenta para empezar a entrenar',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Color(0xFF555555)),
              ),
              const SizedBox(height: 32),
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
              const SizedBox(height: 16),
              CustomTextField(
                controller: _confirmController,
                label: 'Confirmar contraseña',
                obscureText: !_verPassword,
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
                text: _cargando ? 'Creando cuenta...' : 'Crear cuenta',
                onPressed: _cargando ? () {} : _registrarse,
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    '¿Ya tienes cuenta?',
                    style: TextStyle(color: Color(0xFF555555)),
                  ),
                  TextButton(
                    onPressed: () =>
                        Navigator.of(context).pushReplacementNamed(Rutas.login),
                    child: const Text('Inicia sesión'),
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
