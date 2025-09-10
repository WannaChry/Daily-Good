// lib/main.dart
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';

import 'pages/state/social_state.dart';
import 'pages/pages/home.dart';

// Intro-Seiten
import 'pages/intro/splash_page.dart';
import 'pages/intro/onboarding_page.dart';
import 'pages/intro/questionnaire_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Firebase initialisieren (falls noch nicht konfiguriert: vorübergehend auskommentieren)
  await Firebase.initializeApp();

  // App-weit geteilten State vorbereiten
  final social = SocialState.demo();

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
    return MaterialApp(
      debugShowCheckedModeBanner: false,

      // Intro-Flow startet immer bei Splash
      initialRoute: '/splash',

      // Routen für Intro + Home
      routes: {
        '/splash': (_) => const SplashPage(),
        '/onboarding': (_) => const OnboardingPage(),
        '/questionnaire': (_) => const QuestionnairePage(),
        '/home': (_) => const HomePage(),
      },

      // Fallback, falls eine Route fehlt
      onUnknownRoute: (_) =>
          MaterialPageRoute(builder: (_) => const SplashPage()),
    );
  }
}
