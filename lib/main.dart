import 'package:flutter/material.dart';
import 'pages/pages/home.dart';
import 'pages/state/social_state.dart'; // <-- State importieren

void main() {
  final social = SocialState.demo(); // Demo-Daten für Start
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
