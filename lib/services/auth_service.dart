import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  static FirebaseAuth get _auth => FirebaseAuth.instance;

  static Stream<User?> authStateChanges() => _auth.authStateChanges();

  static Future<UserCredential> registrarse({
    required String email,
    required String password,
  }) {
    return _auth.createUserWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
  }

  static Future<UserCredential> iniciarSesion({
    required String email,
    required String password,
  }) {
    return _auth.signInWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
  }

  static Future<void> cerrarSesion() => _auth.signOut();

  static String mensajeError(FirebaseAuthException e) {
    switch (e.code) {
      case 'invalid-email':
        return 'El correo electrónico no es válido.';
      case 'email-already-in-use':
        return 'Ya existe una cuenta con este correo.';
      case 'weak-password':
        return 'La contraseña debe tener al menos 6 caracteres.';
      case 'user-not-found':
        return 'No existe una cuenta con este correo.';
      case 'wrong-password':
      case 'invalid-credential':
        return 'Correo o contraseña incorrectos.';
      case 'too-many-requests':
        return 'Demasiados intentos. Intenta de nuevo más tarde.';
      case 'network-request-failed':
        return 'Sin conexión. Revisa tu internet e intenta de nuevo.';
      case 'operation-not-allowed':
        return 'El acceso con correo no está habilitado en Firebase.';
      default:
        return e.message ?? 'Ocurrió un error. Intenta de nuevo.';
    }
  }
}
