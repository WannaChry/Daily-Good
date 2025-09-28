// Flutter & Firebase
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';

// States
import 'pages/state/auth_state.dart';
import 'pages/state/social_state.dart';
import 'pages/state/task_state.dart';
import 'pages/state/tipp_state.dart';

// Intro Pages
import 'pages/intro/start/splash_page.dart';
import 'pages/intro/start/onboarding_page.dart';
import 'pages/intro/start/questionnaire_page.dart';
import 'pages/intro/auth/auth_choice.dart';
import 'pages/intro/anmeldung/sign_in.dart';
import 'pages/intro/anmeldung/account_details_summary.dart';

// Profil Pages
import 'pages/profil/profile_view.dart';
import 'package:studyproject/pages/subpages/deine_daten_page.dart';

// Home / Main Pages
import 'pages/home/home.dart';
import 'package:studyproject/pages/models/streak_celebration_page.dart';


Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  // States initialisieren
  final authState = AuthState();
  final tipState = TipState();
  final taskState = TaskState();
  final socialState = SocialState.demo();

  // Tipps und Tasks laden
  await tipState.loadTips();
  await taskState.loadTasks();

  runApp(MyApp(
    authState: authState,
    tipState: tipState,
    taskState: taskState,
    socialState: socialState,
  ));
}

class MyApp extends StatelessWidget {
  final AuthState authState;
  final TipState tipState;
  final TaskState taskState;
  final SocialState socialState;

  const MyApp({
    super.key,
    required this.authState,
    required this.tipState,
    required this.taskState,
    required this.socialState,
  });

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: authState.isLoggedIn ? '/home' : '/onboarding',
      routes: {
        // Intro
        '/splash': (_) => const SplashPage(),
        '/onboarding': (_) => const OnboardingPage(),
        '/auth_choice': (_) => const AuthChoicePage(),
        '/login': (_) => const LoginPage(),
        '/questionnaire': (_) => const QuestionnairePage(),
        '/intro/review': (_) => const SignUpPage(),
        '/deine_daten': (_) => const DeineDatenPage(),
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

        // Profil & Home
        '/profile': (_) => const ProfileView(),
        '/home': (_) => HomePage(
          tips: tipState.tips,
          tasks: taskState.tasks,
          authState: authState,
          socialState: socialState,

        ),
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
