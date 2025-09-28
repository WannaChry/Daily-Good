import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:studyproject/pages/state/auth_state.dart';

// Shared UI Widgets (wie bei der anderen Login-Page)
import 'package:studyproject/pages/intro/widgets/fancy_login_background.dart';
import 'package:studyproject/pages/intro/widgets/party_sheep_captcha.dart';
import 'package:studyproject/pages/intro/widgets/brand_button.dart';

class SignInPage extends StatefulWidget {
  const SignInPage({super.key});

  @override
  State<SignInPage> createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
  final _formKey = GlobalKey<FormState>();
  final _userCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _captchaCtrl = TextEditingController();

  bool _obscure = true;
  int _captchaAnswer = 0; // richtige Anzahl 🐑 (1..8)

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
      SnackBar(content: Text('Willkommen, ${_userCtrl.text}! (Demo-Anmeldung)')),
    );
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final auth = AuthState.of(context);
    final theme = Theme.of(context);

    // Bereits eingeloggt? -> Status-Screen (Logik wie gehabt)
    if (auth.isLoggedIn) {
      final email = auth.user?.email ?? 'Anonymes Konto';
      final name = auth.user?.displayName ?? 'Anonymer Nutzer';
      final initial = (name.isNotEmpty ? name.trim()[0] : '?').toUpperCase();

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
            const Positioned.fill(
              child: FancyLoginBackground(tint: Color(0xFF60BFA0)), // 🌿 grün
            ),
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(16),
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
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Du bist bereits angemeldet',
                                style: GoogleFonts.poppins(fontSize: 22, fontWeight: FontWeight.w800)),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                CircleAvatar(
                                  radius: 26,
                                  backgroundColor: Colors.grey.shade300,
                                  child: Text(
                                    initial,
                                    style: GoogleFonts.poppins(fontWeight: FontWeight.w800, fontSize: 18),
                                  ),
                                ),
                                const SizedBox(width: 14),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(name, style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w800)),
                                    Text(email, style: GoogleFonts.poppins(fontSize: 13, color: Colors.grey.shade600)),
                                  ],
                                ),
                              ],
                            ),
                            const SizedBox(height: 24),
                            SizedBox(
                              width: double.infinity,
                              child: OutlinedButton.icon(
                                onPressed: () => Navigator.pushNamed(context, '/deine_daten'),
                                icon: const Icon(Icons.person_outline),
                                label: Text(
                                  'Deine Daten',
                                  style: GoogleFonts.poppins(fontWeight: FontWeight.w800),
                                ),
                                style: OutlinedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(vertical: 14),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                  side: const BorderSide(width: 1.4),
                                ),
                              ),
                            ),
                            const SizedBox(height: 10),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: () async {
                                  await auth.signOut();
                                  if (!mounted) return;
                                  Navigator.of(context)
                                      .pushNamedAndRemoveUntil('/auth_choice', (r) => false);
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.red.shade400,
                                  foregroundColor: Colors.white,
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
            ),
          ],
        ),
      );
    }

    // Nicht eingeloggt → neues Design wie die andere Sign-In-Page
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
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Stack(
        children: [
          const Positioned.fill(
            child: FancyLoginBackground(tint: Color(0xFF60BFA0)), // 🌿 grün (Gradient + Bubbles)
          ),
          SafeArea(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 520),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  child: Form(
                    key: _formKey,
                    child: Card(
                      elevation: 12,
                      color: theme.colorScheme.surface,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 26),
                        // -------------------- Overflow-FIX: scrollbarer Card-Inhalt --------------------
                        child: LayoutBuilder(
                          builder: (context, constraints) {
                            final kb = MediaQuery.of(context).viewInsets.bottom; // Tastaturhöhe
                            return SingleChildScrollView(
                              padding: EdgeInsets.only(bottom: kb + 24),
                              physics: const ClampingScrollPhysics(),
                              child: ConstrainedBox(
                                constraints: BoxConstraints(minWidth: constraints.maxWidth),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    // Header-Icon (scharf)
                                    Container(
                                      padding: const EdgeInsets.all(14),
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: Colors.black.withOpacity(0.06),
                                      ),
                                      child: const Icon(Icons.lock, size: 28, color: Colors.black87),
                                    ),
                                    const SizedBox(height: 12),
                                    Text('Willkommen zurück 👋',
                                        style: GoogleFonts.poppins(fontSize: 22, fontWeight: FontWeight.w800)),
                                    const SizedBox(height: 4),
                                    Text('Melde dich mit deinem Konto an.',
                                        style: GoogleFonts.poppins(
                                          fontSize: 14,
                                          color: Theme.of(context)
                                              .textTheme
                                              .bodyMedium
                                              ?.color
                                              ?.withOpacity(0.80),
                                        )),

                                    const SizedBox(height: 22),

                                    // Benutzername
                                    TextFormField(
                                      controller: _userCtrl,
                                      decoration: InputDecoration(
                                        labelText: 'Benutzername',
                                        prefixIcon: const Icon(Icons.person_outline),
                                        border: border,
                                        enabledBorder: border,
                                        focusedBorder: border.copyWith(
                                          borderSide: BorderSide(color: theme.colorScheme.primary, width: 1.6),
                                        ),
                                      ),
                                      validator: (v) =>
                                      (v == null || v.trim().length < 3) ? 'Mindestens 3 Zeichen.' : null,
                                    ),
                                    const SizedBox(height: 14),

                                    // Passwort
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
                                        enabledBorder: border,
                                        focusedBorder: border.copyWith(
                                          borderSide: BorderSide(color: theme.colorScheme.primary, width: 1.6),
                                        ),
                                      ),
                                      validator: (v) => (v == null || v.length < 6) ? 'Mindestens 6 Zeichen.' : null,
                                    ),

                                    const SizedBox(height: 16),

                                    // 🐑 PartySheepCaptcha (1..8)
                                    PartySheepCaptcha(
                                      minCount: 1,
                                      maxCount: 8,
                                      onNewAnswer: (ans) => _captchaAnswer = ans,
                                    ),
                                    const SizedBox(height: 10),

                                    // Antwortfeld – Schaf-Emoji mit Abstand
                                    TextFormField(
                                      controller: _captchaCtrl,
                                      keyboardType: TextInputType.number,
                                      decoration: InputDecoration(
                                        labelText: 'Anzahl eingeben',
                                        hintText: 'z. B. 5',
                                        prefixIcon: const Padding(
                                          padding: EdgeInsets.only(left: 10, right: 6),
                                          child: Text('🐑', style: TextStyle(fontSize: 18)),
                                        ),
                                        prefixIconConstraints: const BoxConstraints(minWidth: 56),
                                        border: border,
                                        enabledBorder: border,
                                        focusedBorder: border.copyWith(
                                          borderSide: const BorderSide(color: Colors.black, width: 1.6),
                                        ),
                                      ),
                                      validator: (v) {
                                        if (v == null || v.trim().isEmpty) return 'Bitte Anzahl eingeben.';
                                        if (int.tryParse(v.trim()) == null) return 'Nur Zahlen eingeben.';
                                        return null;
                                      },
                                    ),

                                    const SizedBox(height: 20),

                                    // 🖤 Einloggen – schwarz, größere graue Schrift
                                    BrandButton(
                                      label: 'Einloggen',
                                      loading: false,
                                      backgroundColor: Colors.black,
                                      foregroundColor: Colors.white,
                                      textStyle: const TextStyle(
                                        fontSize: 17,
                                        fontWeight: FontWeight.w800,
                                        color: Color(0xFFEDEDED), // hell-grau
                                      ),
                                      onPressed: _submit,
                                    ),

                                    const SizedBox(height: 12),

                                    // ◻️ Konto erstellen – invertiert, gleicher Stil, mehr Präsenz
                                    BrandButton(
                                      label: 'Konto erstellen',
                                      backgroundColor: Colors.white,
                                      foregroundColor: Colors.black,
                                      borderSide: const BorderSide(color: Colors.black, width: 1.4),
                                      textStyle: const TextStyle(
                                        fontSize: 16.5,
                                        fontWeight: FontWeight.w800,
                                        color: Colors.black,
                                      ),
                                      onPressed: () =>
                                          Navigator.pushReplacementNamed(context, '/auth_choice'),
                                    ),

                                    const SizedBox(height: 10),
                                    Opacity(
                                      opacity: 0.7,
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Icon(Icons.https_outlined,
                                              size: 16, color: theme.colorScheme.outline),
                                          const SizedBox(width: 6),
                                          Text(
                                            'Deine Daten bleiben geschützt.',
                                            style: GoogleFonts.poppins(
                                              fontSize: 12,
                                              color: theme.colorScheme.outline,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                        // ------------------ Ende Overflow-FIX ------------------
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
