// lib/pages/pages/sign_in_page.dart
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:studyproject/pages/state/auth_state.dart';
import 'package:studyproject/pages/pages/sign_up_page.dart';

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

  late int _a;
  late int _b;

  bool _obscure = true;

  @override
  void initState() {
    super.initState();
    _genCaptcha();
  }

  @override
  void dispose() {
    _userCtrl.dispose();
    _passCtrl.dispose();
    _captchaCtrl.dispose();
    super.dispose();
  }

  void _genCaptcha() {
    final rnd = Random.secure();
    setState(() {
      _a = rnd.nextInt(6) + 2; // 2..7
      _b = rnd.nextInt(6) + 3; // 3..8
      _captchaCtrl.clear();
    });
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    final answer = int.tryParse(_captchaCtrl.text.trim());
    if (answer != _a + _b) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('CAPTCHA ist falsch. Versuch‘s nochmal.')),
      );
      _genCaptcha();
      return;
    }

    // Demo-Login (kein echter Login hier)
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Willkommen, ${_userCtrl.text}! (Demo-Anmeldung)')),
    );
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final auth = AuthState.of(context);

    final h1 = GoogleFonts.poppins(fontSize: 22, fontWeight: FontWeight.w800);
    final label = GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w700);

    // ------------------------------------------
    // Schon eingeloggt? → Status-Screen mit Avatar
    // ------------------------------------------
    if (auth.isLoggedIn) {
      final uid = auth.user!.uid;
      final email = auth.user?.email ?? 'Anonymes Konto';

      return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
        stream: FirebaseFirestore.instance.collection('users').doc(uid).snapshots(),
        builder: (context, snap) {
          final data = snap.data?.data();
          final name = (data?['name'] as String?) ??
              auth.user?.displayName ??
              'Anonymer Nutzer';
          final photoUrl = (data?['photoUrl'] as String?) ??
              auth.user?.photoURL;

          final initial =
          (name.isNotEmpty ? name.trim()[0] : '?').toUpperCase();

          return Scaffold(
            backgroundColor: const Color(0xFFF8F3FA),
            appBar: AppBar(
              backgroundColor: Colors.white,
              elevation: 0,
              title: Text('Anmelden',
                  style: GoogleFonts.poppins(fontWeight: FontWeight.w700)),
              centerTitle: true,
            ),
            body: SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Du bist bereits angemeldet', style: h1),
                    const SizedBox(height: 16),

                    // Karte mit Avatar, Name, E-Mail
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                        border: Border.all(color: Colors.grey.shade200),
                      ),
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 26,
                            backgroundColor: Colors.grey.shade300,
                            backgroundImage:
                            photoUrl != null ? NetworkImage(photoUrl) : null,
                            child: photoUrl == null
                                ? Text(
                              initial,
                              style: GoogleFonts.poppins(
                                fontWeight: FontWeight.w800,
                                fontSize: 18,
                              ),
                            )
                                : null,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(name,
                                    style: GoogleFonts.poppins(
                                        fontSize: 16, fontWeight: FontWeight.w800)),
                                const SizedBox(height: 2),
                                Text(
                                  email,
                                  style: GoogleFonts.poppins(
                                    fontSize: 13,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    const Spacer(),

                    // Buttons: Zur Startseite / Logout
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => Navigator.of(context)
                                .pushNamedAndRemoveUntil('/home', (r) => false),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              side: BorderSide(color: Colors.grey.shade400),
                              backgroundColor: Colors.white,
                            ),
                            child: Text(
                              'Zur Startseite',
                              style:
                              GoogleFonts.poppins(fontWeight: FontWeight.w700),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () async {
                              await auth.signOut();
                              if (!mounted) return;
                              Navigator.of(context).maybePop();
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red.shade400,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                            child: Text(
                              'Logout',
                              style:
                              GoogleFonts.poppins(fontWeight: FontWeight.w800),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      );
    }

    // ------------------------------------------
    // Nicht eingeloggt → normales Sign-In-Form
    // ------------------------------------------
    return Scaffold(
      backgroundColor: const Color(0xFFF8F3FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text('Anmelden',
            style: GoogleFonts.poppins(fontWeight: FontWeight.w700)),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text('Willkommen zurück 👋', style: h1),
                const SizedBox(height: 14),

                // Benutzername
                Text('Benutzername', style: label),
                const SizedBox(height: 6),
                TextFormField(
                  controller: _userCtrl,
                  decoration: _inputDecoration('z. B. max.mustermann'),
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) {
                      return 'Bitte Benutzernamen eingeben.';
                    }
                    if (v.trim().length < 3) return 'Mindestens 3 Zeichen.';
                    return null;
                  },
                ),
                const SizedBox(height: 14),

                // Passwort
                Text('Passwort', style: label),
                const SizedBox(height: 6),
                TextFormField(
                  controller: _passCtrl,
                  obscureText: _obscure,
                  decoration: _inputDecoration('••••••••').copyWith(
                    suffixIcon: IconButton(
                      onPressed: () => setState(() => _obscure = !_obscure),
                      icon: Icon(
                          _obscure ? Icons.visibility : Icons.visibility_off),
                    ),
                  ),
                  validator: (v) {
                    if (v == null || v.isEmpty) {
                      return 'Bitte Passwort eingeben.';
                    }
                    if (v.length < 6) return 'Mindestens 6 Zeichen.';
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // CAPTCHA Block
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Sicherheitsabfrage', style: label),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: Container(
                              height: 48,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: Colors.grey.shade200,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                '$_a + $_b = ?',
                                style: GoogleFonts.poppins(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          IconButton(
                            onPressed: _genCaptcha,
                            splashRadius: 22,
                            icon: const Icon(Icons.refresh),
                            tooltip: 'Neu laden',
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      TextFormField(
                        controller: _captchaCtrl,
                        keyboardType: TextInputType.number,
                        decoration: _inputDecoration('Ergebnis eingeben'),
                        validator: (v) {
                          if (v == null || v.trim().isEmpty) {
                            return 'Bitte das Ergebnis eingeben.';
                          }
                          if (int.tryParse(v.trim()) == null) {
                            return 'Nur Zahlen eingeben.';
                          }
                          return null;
                        },
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // CTA – Einloggen (Demo)
                Material(
                  color: const Color(0xFFA8D5A2),
                  borderRadius: BorderRadius.circular(16),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(16),
                    onTap: _submit,
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      alignment: Alignment.center,
                      child: Text(
                        'Einloggen',
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                // CTA – Konto erstellen
                OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    side: BorderSide(color: Colors.grey.shade400),
                    backgroundColor: Colors.white,
                  ),
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const SignUpPage()),
                    );
                  },
                  child: Text(
                    "Konto erstellen",
                    style: GoogleFonts.poppins(fontWeight: FontWeight.w700),
                  ),
                ),

                const SizedBox(height: 12),

                TextButton(
                  onPressed: () => Navigator.of(context).maybePop(),
                  child: Text(
                    'Später',
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w700,
                      color: Colors.grey.shade700,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle:
      GoogleFonts.poppins(color: Colors.grey.shade600, fontSize: 14),
      contentPadding:
      const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide:
        BorderSide(color: Colors.green.shade400, width: 2),
      ),
    );
  }
}
