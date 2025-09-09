import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'pages/pages/home.dart';
import 'pages/state/social_state.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // 1. Flutter vorbereiten
  await Firebase.initializeApp();            // 2. Firebase initialisieren

  final social = SocialState.demo();         // 3. State vorbereiten

  // 4. Beides zusammen in runApp
  runApp(
    SocialScope.provide(
      state: social,
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: HomePage(),
    );
  }
}
