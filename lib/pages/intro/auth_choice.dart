import 'package:flutter/material.dart';

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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Willkommen'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pushReplacementNamed(context, '/onboarding');
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ElevatedButton(
                onPressed: () => _goToLogin(context),
                child: const Text('Bei Konto anmelden'),
              ),
              const SizedBox(height: 30),
              OutlinedButton(
                onPressed: () => _goToRegister(context),
                child: const Text('Neues Konto erstellen'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
