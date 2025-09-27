import 'package:flutter/material.dart';
import '../pages/intro/start/splash_page.dart';
import '../pages/intro/start/onboarding_page.dart';
import '../pages/intro/auth/auth_choice.dart';
import '../pages/intro/anmeldung/sign_in.dart';
import '../pages/intro/anmeldung/account_details_summary.dart';
import '../pages/intro/start/questionnaire_page.dart';
import '../pages/models/streak_celebration_page.dart';
import '../pages/home/home.dart';
import '../pages/profil/options.dart';
import 'package:studyproject/pages/models/task.dart';
import 'package:studyproject/pages/models/tipp.dart';

class AppNavigator {
  // liefert alle statischen Routen zurück
  static Map<String, WidgetBuilder> routes({
    List<Tipp> tips = const [], // dynamisch
    List<Task> tasks = const [],
  }) {
    return {
      '/splash': (_) => const SplashPage(), // Splash-Seite
      '/onboarding': (_) => const OnboardingPage(), // Onboarding
      '/auth_choice': (_) => const AuthChoicePage(), // Auth Auswahl
      '/login': (_) => const SignInPage(), // Login
      '/sign-up': (_) => const SignUpPage(), // Registrierung
      '/questionnaire': (_) => const QuestionnairePage(), // Fragebogen
      '/home': (_) => HomePage(tips: tips, tasks: tasks), // Home
      '/verify': (_) => const _VerifyPlaceholderPage(), // Verifizierung
    };
  }

  // dynamische Route für Streak
  static Route<dynamic> generateRoute(RouteSettings settings) {
    if (settings.name == '/streak') {
      final args = settings.arguments as Map? ?? {};
      return MaterialPageRoute(
        builder: (_) => StreakCelebrationPage(
          currentStreak: args['currentStreak'] ?? 1, // aktuelle Serie
          bestStreak: args['bestStreak'] ?? 1, // beste Serie
          lastCheckIn: args['lastCheckIn'] ?? DateTime.now(), // letztes Einchecken
        ),
      );
    }
    // fallback
    return MaterialPageRoute(builder: (_) => const SplashPage());
  }
}

// kleiner Placeholder für Verifizierung
class _VerifyPlaceholderPage extends StatelessWidget {
  const _VerifyPlaceholderPage();

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)?.settings.arguments as Map? ?? {};
    final email = args['email'];
    return Scaffold(
      appBar: AppBar(title: const Text('Verifizierung')), // AppBar
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Text(
            email != null
                ? 'Hier kommt später die Verifizierung für: $email'
                : 'Hier kommt später die Verifizierung hin.',
            textAlign: TextAlign.center, // Text zentriert
          ),
        ),
      ),
    );
  }
}
