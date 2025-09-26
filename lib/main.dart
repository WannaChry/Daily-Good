import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:studyproject/pages/intro/auth/auth_choice.dart';
import 'package:studyproject/pages/intro/anmeldung/sign_in.dart';

//models
import 'package:studyproject/pages/models/tipp.dart';
import 'package:studyproject/pages/models/task.dart';
import 'package:studyproject/pages/models/streak_celebration_page.dart';

import 'pages/state/social_state.dart';
import 'pages/state/auth_state.dart'; // Auth-State
import 'pages/home/home.dart';

// Intro-Seiten
import 'pages/intro/start/splash_page.dart';
import 'pages/intro/start/onboarding_page.dart';
import 'pages/intro/start/questionnaire_page.dart';
import 'pages/intro/anmeldung/sign_up.dart';

// Auth-Seiten
import 'pages/profil/options.dart';
//import 'profil/profil/sign_up_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  final social = SocialState.demo();
  final auth = AuthState(); // globaler Auth-State

  runApp(
    SocialScope.provide(
      state: social,
      child: AuthState.provide( // globaler Auth-Provider
        state: auth,
        child: const MyApp(),
      ),
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  List<Tipp> tips = []; // dynamisch
  List<Task> tasks =[];

  @override
  void initState() {
    super.initState();
    _loadTips();
    _loadTasks();
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
  Future<void> _loadTasks() async {
    print('[Tasks] Lade Tasks von Firestore...');

    try {
      final snapshot = await FirebaseFirestore.instance.collection('tasks').get();

      if (snapshot.docs.isEmpty) {
        print('[Tasks] Keine Dokumente in der Collection gefunden.');
        return;
      }

      print('[Tasks] Firestore-Dokumente gefunden: ${snapshot.docs.length}');

      final loadedTasks = snapshot.docs.map((doc) {
        final data = doc.data();
        if (data == null) {
          print('[Tasks] Dokument ${doc.id} enthält null!');
          return null;
        }
        print('[Tasks] Dokument ${doc.id} Daten: $data');
        try {
          return Task.fromJson(data as Map<String, dynamic>);
        } catch (e) {
          print('[Tasks] Fehler beim Mapping von Dokument ${doc.id}: $e');
          return null;
        }
      }).where((t) => t != null).cast<Task>().toList();

      print('[Tasks] Nach Mapping gültige Tasks: ${loadedTasks.length}');

      if (loadedTasks.isEmpty) {
        print('[Tasks] Kein gültiger Task nach Mapping gefunden.');
        return;
      }

      setState(() {
        tasks = loadedTasks;
      });

      print('[Tasks] Erfolgreich ${tasks.length} Tasks geladen.');
    } catch (e) {
      print('[Tasks] Fehler beim Laden der Tasks: $e');
    }
  }
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: '/splash',

      routes: {
        // Intro
        '/splash': (_) => const SplashPage(),
        '/onboarding': (_) => const OnboardingPage(),
        '/auth_choice': (_) => const AuthChoicePage(),
        '/login': (_) => const LoginPage(),
        '/questionnaire': (_) => const QuestionnairePage(),
        '/intro/review': (_) => const SignUpPage(),

        // NEU: Streak-Celebration (liest Arguments)
        '/streak': (ctx) {
          final args = ModalRoute.of(ctx)?.settings.arguments as Map? ?? {};
          final current = (args['currentStreak'] ?? 1) as int;
          final best = (args['bestStreak'] ?? current) as int;
          final last = (args['lastCheckIn'] as DateTime?) ?? DateTime.now();
          return StreakCelebrationPage(
            currentStreak: current,
            bestStreak: best,
            lastCheckIn: last,
          );
        },

        // Auth
        '/sign-in': (_) => const SignInPage(),
        '/sign-up': (_) => const SignUpPage(),
        '/verify': (_) => const _VerifyPlaceholderPage(), // Platzhalter

        // Home
        '/home': (_) => HomePage(tips: tips, tasks: tasks),
      },

      onUnknownRoute: (_) =>
          MaterialPageRoute(builder: (_) => const SplashPage()),
    );
  }
}

// ---------------------------------------------------------
// Kleiner Stub, damit "2-Faktor aktivieren" / Verifizierung
// nicht crasht. Später durch echte Seite ersetzen.
// ---------------------------------------------------------
class _VerifyPlaceholderPage extends StatelessWidget {
  const _VerifyPlaceholderPage();

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)?.settings.arguments as Map? ?? {};
    final email = args['email'];
    return Scaffold(
      appBar: AppBar(title: const Text('Verifizierung')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Text(
            email != null
                ? 'Hier kommt später die Verifizierung für: $email'
                : 'Hier kommt später die Verifizierung hin.',
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}
