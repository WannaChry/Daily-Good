import 'package:flutter/material.dart';
import '../widgets/cute_sunny_landscape.dart';

class AuthChoicePage extends StatelessWidget {
  const AuthChoicePage({super.key});

  void _goToRegister(BuildContext context) {
    Navigator.pushNamed(context, '/questionnaire'); // Registrierung → Questionnaire
  }

  void _goToLogin(BuildContext context) {
    Navigator.pushNamed(context, '/login'); // Anmeldung → LoginPage
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Button Styles
    final primaryBtnStyle = ElevatedButton.styleFrom(
      minimumSize: const Size.fromHeight(56),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
      elevation: 2,
    );

    final secondaryBtnStyle = OutlinedButton.styleFrom(
      minimumSize: const Size.fromHeight(56),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      side: BorderSide(color: theme.colorScheme.outline.withOpacity(0.5), width: 1.2),
      textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
    );

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        title: const Text('Willkommen'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pushReplacementNamed(context, '/onboarding'),
          tooltip: 'Zurück zum Onboarding',
        ),
      ),
      body: Stack(
        children: [
          // 🌞+🌿 Hintergrund
          const Positioned.fill(child: CuteSunnyLandscape()),
          // Vordergrund: Inhalt
          SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final isCompact = constraints.maxWidth < 360 || constraints.maxHeight < 680;

                return Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 520),
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: isCompact ? 16 : 24,
                        vertical: isCompact ? 12 : 16,
                      ),
                      child: Card(
                        elevation: 12,
                        color: theme.colorScheme.surface, // opak
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                        child: Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: isCompact ? 18 : 24,
                            vertical: isCompact ? 20 : 28,
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // Branding / Icon
                              Container(
                                padding: const EdgeInsets.all(14),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: (isDark ? Colors.white : Colors.black).withOpacity(0.06),
                                ),
                                child: Icon(
                                  Icons.favorite_outline_rounded,
                                  size: 32,
                                  color: theme.colorScheme.primary,
                                ),
                              ),
                              const SizedBox(height: 16),

                              Text(
                                'Schön, dass du da bist!',
                                textAlign: TextAlign.center,
                                style: theme.textTheme.headlineSmall?.copyWith(
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(height: 8),

                              Text(
                                'Erstelle ein neues Konto, oder melde dich bei deinem bestehenden Konto an.',
                                textAlign: TextAlign.center,
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: theme.textTheme.bodyMedium?.color?.withOpacity(0.85),
                                ),
                              ),
                              const SizedBox(height: 24),

                              // Primär: Login
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton.icon(
                                  style: primaryBtnStyle,
                                  onPressed: () => _goToLogin(context),
                                  icon: const Icon(Icons.login_rounded),
                                  label: const Text('Bei Konto anmelden'),
                                ),
                              ),
                              const SizedBox(height: 14),

                              // Sekundär: Sign Up → Questionnaire
                              SizedBox(
                                width: double.infinity,
                                child: OutlinedButton.icon(
                                  style: secondaryBtnStyle,
                                  onPressed: () => _goToRegister(context),
                                  icon: const Icon(Icons.person_add_alt_1_rounded),
                                  label: const Text('Neues Konto erstellen'),
                                ),
                              ),

                              const SizedBox(height: 18),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.lock_outline_rounded,
                                      size: 16, color: theme.colorScheme.outline),
                                  const SizedBox(width: 6),
                                  Flexible(
                                    child: Text(
                                      'Deine Daten bleiben geschützt.',
                                      style: theme.textTheme.bodySmall?.copyWith(
                                        color: theme.colorScheme.outline,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
