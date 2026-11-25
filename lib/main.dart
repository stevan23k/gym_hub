import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:gym_hub/constants.dart';
import 'package:gym_hub/firebase_options.dart';
import 'package:gym_hub/ruta/rutas.dart';

import 'package:intl/date_symbol_data_local.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await initializeDateFormatting('es');
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Gym Hub',
      theme: ThemeData(
        scaffoldBackgroundColor: backgroundColor,
        colorScheme: ColorScheme.fromSeed(
          seedColor: kPrimaryColor,
          primary: kPrimaryColor,
        ),
        textTheme: Theme.of(context).textTheme.apply(bodyColor: textColor),
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      initialRoute: Rutas.inicio,
      onGenerateRoute: Rutas.generarRuta,
    );
  }
}
