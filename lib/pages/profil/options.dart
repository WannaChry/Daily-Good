import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:studyproject/pages/state/auth_state.dart';
import 'package:studyproject/pages/intro/widgets/fancy_login_background.dart';
import 'package:studyproject/pages/intro/widgets/party_sheep_captcha.dart';
import 'package:studyproject/pages/intro/widgets/brand_button.dart';

class SignInPage extends StatefulWidget {
  final AuthState authState;
  const SignInPage({super.key, required this.authState});

  @override
  State<SignInPage> createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
  final _formKey = GlobalKey<FormState>();
  final _userCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _captchaCtrl = TextEditingController();

  bool _obscure = true;
  int _captchaAnswer = 0;

  @override
  void dispose() {
    _userCtrl.dispose();
    _passCtrl.dispose();
    _captchaCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    final answer = int.tryParse(_captchaCtrl.text.trim());
    if (answer != _captchaAnswer) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Captcha falsch – bitte Schafe neu zählen 🐑')),
      );
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Willkommen, ${_userCtrl.text}!')),
    );
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final auth = widget.authState;
    final theme = Theme.of(context);

    // Bereits eingeloggt
    if (auth.isLoggedIn) {
      final user = auth.user!;
      final name = user.displayName ?? 'Anonymer Nutzer';
      final email = user.email ?? 'Anonym';
      final initial = name.isNotEmpty ? name[0].toUpperCase() : '?';

      return Scaffold(
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          elevation: 0,
          backgroundColor: Colors.transparent,
          title: Text('Anmelden', style: GoogleFonts.poppins(fontWeight: FontWeight.w700)),
          centerTitle: true,
        ),
        body: Stack(
          children: [
            const Positioned.fill(child: FancyLoginBackground(tint: Color(0xFF60BFA0))),
            SafeArea(
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 520),
                  child: Card(
                    elevation: 12,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text('Du bist bereits angemeldet',
                              style: GoogleFonts.poppins(fontSize: 22, fontWeight: FontWeight.w800)),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              CircleAvatar(
                                radius: 26,
                                backgroundColor: Colors.grey.shade300,
                                child: Text(initial,
                                    style: GoogleFonts.poppins(fontWeight: FontWeight.w800, fontSize: 18)),
                              ),
                              const SizedBox(width: 14),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(name, style: GoogleFonts.poppins(fontWeight: FontWeight.w800)),
                                  Text(email, style: GoogleFonts.poppins(fontSize: 13, color: Colors.grey.shade600)),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: () async {
                                await auth.signOut();
                                if (!mounted) return;
                                Navigator.of(context)
                                    .pushNamedAndRemoveUntil('/auth_choice', (route) => false);
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red.shade400,
                                padding: const EdgeInsets.symmetric(vertical: 14),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                              ),
                              child: Text('Logout', style: GoogleFonts.poppins(fontWeight: FontWeight.w800)),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    }

    // Nicht eingeloggt → Formular
    final border = OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: BorderSide(color: theme.colorScheme.outline.withOpacity(0.4)),
    );

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        title: Text('Anmelden', style: GoogleFonts.poppins(fontWeight: FontWeight.w700)),
        centerTitle: true,
        leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => Navigator.pop(context)),
      ),
      body: Stack(
        children: [
          const Positioned.fill(child: FancyLoginBackground(tint: Color(0xFF60BFA0))),
          SafeArea(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 520),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Form(
                    key: _formKey,
                    child: Card(
                      elevation: 12,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          children: [
                            Icon(Icons.lock, size: 28, color: Colors.black87),
                            const SizedBox(height: 12),
                            Text('Willkommen zurück 👋',
                                style: GoogleFonts.poppins(fontSize: 22, fontWeight: FontWeight.w800)),
                            const SizedBox(height: 14),
                            TextFormField(
                              controller: _userCtrl,
                              decoration: InputDecoration(
                                labelText: 'Benutzername',
                                prefixIcon: const Icon(Icons.person_outline),
                                border: border,
                              ),
                              validator: (v) => (v == null || v.trim().length < 3) ? 'Mindestens 3 Zeichen.' : null,
                            ),
                            const SizedBox(height: 12),
                            TextFormField(
                              controller: _passCtrl,
                              obscureText: _obscure,
                              decoration: InputDecoration(
                                labelText: 'Passwort',
                                prefixIcon: const Icon(Icons.lock_outline),
                                suffixIcon: IconButton(
                                  onPressed: () => setState(() => _obscure = !_obscure),
                                  icon: Icon(_obscure ? Icons.visibility : Icons.visibility_off),
                                ),
                                border: border,
                              ),
                              validator: (v) => (v == null || v.length < 6) ? 'Mindestens 6 Zeichen.' : null,
                            ),
                            const SizedBox(height: 16),
                            PartySheepCaptcha(
                              minCount: 1,
                              maxCount: 8,
                              onNewAnswer: (ans) => _captchaAnswer = ans,
                            ),
                            const SizedBox(height: 12),
                            TextFormField(
                              controller: _captchaCtrl,
                              keyboardType: TextInputType.number,
                              decoration: InputDecoration(labelText: 'Anzahl eingeben', border: border),
                              validator: (v) {
                                if (v == null || v.trim().isEmpty) return 'Bitte Anzahl eingeben.';
                                if (int.tryParse(v.trim()) == null) return 'Nur Zahlen eingeben.';
                                return null;
                              },
                            ),
                            const SizedBox(height: 20),
                            BrandButton(label: 'Einloggen', loading: false, onPressed: _submit),
                            const SizedBox(height: 12),
                            BrandButton(
                              label: 'Konto erstellen',
                              backgroundColor: Colors.white,
                              foregroundColor: Colors.black,
                              borderSide: const BorderSide(color: Colors.black, width: 1.4),
                              onPressed: () => Navigator.pushReplacementNamed(context, '/auth_choice'),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
