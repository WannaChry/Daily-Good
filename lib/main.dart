import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';

// Services
import 'package:studyproject/pages/home/services/task_service.dart';
import 'package:studyproject/pages/home/services/tip_service.dart';

// Models/Pages
import 'package:studyproject/pages/models/tipp.dart';
import 'package:studyproject/pages/models/task.dart';
import 'package:studyproject/pages/models/streak_celebration_page.dart';

import 'pages/state/social_state.dart';
import 'pages/state/auth_state.dart';
import 'pages/home/home.dart';

import 'pages/intro/start/splash_page.dart';
import 'pages/intro/start/onboarding_page.dart';
import 'pages/intro/start/questionnaire_page.dart';
import 'pages/intro/auth/auth_choice.dart';
import 'pages/intro/anmeldung/sign_in.dart';                // LoginPage
import 'pages/intro/anmeldung/account_details_summary.dart'; // SignUpPage

import 'pages/profil/profile_view.dart'; // Profilanzeige
import 'package:studyproject/pages/subpages/deine_daten_page.dart';
import 'package:studyproject/pages/subpages/password_change_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  final social = SocialState.demo();
  final auth = AuthState(); // globaler Auth-State

  runApp(
    SocialScope.provide(
      state: social,
      child: AuthState.provide(
        // globaler Auth-Provider
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
  List<Task> tasks = [];

  @override
  void initState() {
    super.initState();
    // Tipps und Tasks beim Start laden
    TippService.fetchTips().then((loadedTips) {
      setState(() => tips = loadedTips);
    });
    TaskService().fetchAllTasks().then((loadedTasks) {
      if (mounted) setState(() => tasks = loadedTasks);
    });
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
        '/deine_daten': (_) => const DeineDatenPage(),
        '/password_change': (_) => const PasswordChangePage(),
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

        // Profil und Home
        '/profile': (_) => const ProfileView(),
        '/home': (_) => HomePage(tips: tips, tasks: tasks),
      },
      onUnknownRoute: (_) =>
          MaterialPageRoute(builder: (_) => const SplashPage()),
    );
  }
}

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
