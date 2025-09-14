import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:studyproject/pages/models/tipp.dart';

import 'pages/state/social_state.dart';
import 'pages/pages/home.dart';

// Intro-Seiten
import 'pages/intro/splash_page.dart';
import 'pages/intro/onboarding_page.dart';
import 'pages/intro/questionnaire_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp();

  final social = SocialState.demo();

  runApp(
    SocialScope.provide(
      state: social,
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  List<Tipp> tips = []; // dynamisch, nicht final

  @override
  void initState() {
    super.initState();
    _loadTips(); // Tipps beim Start laden
  }

  Future<void> _loadTips() async {
    try {
      final snapshot = await FirebaseFirestore.instance.collection('tipps').get();
      if (snapshot.docs.isEmpty) {
        print('[EcoFacts] Keine Tipps in Firestore gefunden.');
        return;
      }
      setState(() {
        tips.addAll(snapshot.docs.map((doc) => Tipp.fromJson(doc.data())).toList());
      });
      print('[EcoFacts] Erfolgreich ${tips.length} Tipps geladen.');
    } catch (e) {
      print('[EcoFacts] Fehler beim Laden der Tipps: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: '/splash',

      //Routen zu den files
      routes: {
        '/splash': (_) => const SplashPage(),
        '/onboarding': (_) => const OnboardingPage(),
        '/questionnaire': (_) => const QuestionnairePage(),
        // HomePage bekommt jetzt die geladenen Tipps
        '/home': (_) => HomePage(tips: tips),
      },
      onUnknownRoute: (_) =>
          MaterialPageRoute(builder: (_) => const SplashPage()),
    );
  }
}
