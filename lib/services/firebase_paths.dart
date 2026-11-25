import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:gym_hub/constants.dart';

/// Rutas comunes de Firestore y utilidades de fecha para el usuario actual.
class FirebasePaths {
  static FirebaseFirestore get db => FirebaseFirestore.instance;

  static String get uid {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      throw StateError('No hay un usuario autenticado.');
    }
    return uid;
  }

  static CollectionReference<Map<String, dynamic>> routines(String uid) =>
      db.collection('users').doc(uid).collection('routines');

  static CollectionReference<Map<String, dynamic>> history(String uid) =>
      db.collection('users').doc(uid).collection('history');

  /// Clave de documento para un día, p. ej. "2026-11-23".
  static String dateKey(DateTime date) =>
      '${date.year.toString().padLeft(4, '0')}-'
      '${date.month.toString().padLeft(2, '0')}-'
      '${date.day.toString().padLeft(2, '0')}';

  /// Fecha concreta de un día de semana dentro de la semana actual.
  ///
  static DateTime dateForDay(String dayName) {
    final now = DateTime.now();
    final hoy = DateTime(now.year, now.month, now.day);
    final lunes = hoy.subtract(Duration(days: hoy.weekday - 1));
    final indice = kDiasSemana.indexOf(dayName);
    return DateTime(
      lunes.year,
      lunes.month,
      lunes.day + (indice < 0 ? 0 : indice),
    );
  }
}
