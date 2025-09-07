import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'pages/pages/home.dart'; // deine Home-Seite

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // Flutter vorbereiten
  await Firebase.initializeApp();            // Firebase initialisieren
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: HomePage(), // <-- zeigt deine ursprüngliche HomePage
    );
  }
}
