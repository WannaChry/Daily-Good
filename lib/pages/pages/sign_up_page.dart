import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final _formKey = GlobalKey<FormState>();

  final _userCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _pass2Ctrl = TextEditingController();
  final _captchaCtrl = TextEditingController();

  bool _obscure1 = true;
  bool _obscure2 = true;
  bool _agree = false;

  late int _a;
  late int _b;

  @override
  void initState() {
    super.initState();
    _genCaptcha();
  }

  @override
  void dispose() {
    _userCtrl.dispose();
    _emailCtrl.dispose();
    _passCtrl.dispose();
    _pass2Ctrl.dispose();
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

    // CAPTCHA check
    final answer = int.tryParse(_captchaCtrl.text.trim());
    if (answer != _a + _b) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('CAPTCHA ist falsch.')),
      );
      _genCaptcha();
      return;
    }

    // TODO: Hier später echte Registrierung (API/Firebase) einbauen.
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Konto erstellt: ${_userCtrl.text} (Demo)')),
    );
    Navigator.of(context).pop(); // zurück
  }

  @override
  Widget build(BuildContext context) {
    final h1 = GoogleFonts.poppins(fontSize: 22, fontWeight: FontWeight.w800);
    final label = GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w700);

    return Scaffold(
      backgroundColor: const Color(0xFFF8F3FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text('Konto erstellen', style: GoogleFonts.poppins(fontWeight: FontWeight.w700)),
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
                Text('Schön, dass du dabei bist ✨', style: h1),
                const SizedBox(height: 14),

                // Benutzername
                Text('Benutzername', style: label),
                const SizedBox(height: 6),
                TextFormField(
                  controller: _userCtrl,
                  decoration: _inputDecoration('z. B. max.mustermann'),
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) return 'Bitte Benutzernamen eingeben.';
                    if (v.trim().length < 3) return 'Mindestens 3 Zeichen.';
                    return null;
                  },
                ),
                const SizedBox(height: 14),

                // E-Mail
                Text('E-Mail', style: label),
                const SizedBox(height: 6),
                TextFormField(
                  controller: _emailCtrl,
                  keyboardType: TextInputType.emailAddress,
                  decoration: _inputDecoration('z. B. max@mail.com'),
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) return 'Bitte E-Mail eingeben.';
                    final email = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
                    if (!email.hasMatch(v.trim())) return 'Bitte gültige E-Mail eingeben.';
                    return null;
                  },
                ),
                const SizedBox(height: 14),

                // Passwort
                Text('Passwort', style: label),
                const SizedBox(height: 6),
                TextFormField(
                  controller: _passCtrl,
                  obscureText: _obscure1,
                  decoration: _inputDecoration('Mind. 6 Zeichen').copyWith(
                    suffixIcon: IconButton(
                      onPressed: () => setState(() => _obscure1 = !_obscure1),
                      icon: Icon(_obscure1 ? Icons.visibility : Icons.visibility_off),
                    ),
                  ),
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Bitte Passwort eingeben.';
                    if (v.length < 6) return 'Mindestens 6 Zeichen.';
                    return null;
                  },
                ),
                const SizedBox(height: 14),

                // Passwort wiederholen
                Text('Passwort wiederholen', style: label),
                const SizedBox(height: 6),
                TextFormField(
                  controller: _pass2Ctrl,
                  obscureText: _obscure2,
                  decoration: _inputDecoration('Passwort bestätigen').copyWith(
                    suffixIcon: IconButton(
                      onPressed: () => setState(() => _obscure2 = !_obscure2),
                      icon: Icon(_obscure2 ? Icons.visibility : Icons.visibility_off),
                    ),
                  ),
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Bitte wiederholen.';
                    if (v != _passCtrl.text) return 'Passwörter stimmen nicht überein.';
                    return null;
                  },
                ),

                const SizedBox(height: 16),

                // CAPTCHA
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
                          if (v == null || v.trim().isEmpty) return 'Bitte das Ergebnis eingeben.';
                          if (int.tryParse(v.trim()) == null) return 'Nur Zahlen eingeben.';
                          return null;
                        },
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 14),

                // AGB/Datenschutz (nur Häkchen, ohne Navigation)
                Row(
                  children: [
                    Checkbox(
                      value: _agree,
                      onChanged: (v) => setState(() => _agree = v ?? false),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                    ),
                    Expanded(
                      child: Text(
                        'Ich akzeptiere die Nutzungsbedingungen und Datenschutzrichtlinien.',
                        style: GoogleFonts.poppins(fontSize: 12.5, color: Colors.grey.shade700),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                // CTA – Konto erstellen
                Material(
                  color: _agree ? const Color(0xFFA8D5A2) : Colors.grey.shade400,
                  borderRadius: BorderRadius.circular(16),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(16),
                    onTap: _agree ? _submit : null,
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      alignment: Alignment.center,
                      child: Text(
                        'Konto erstellen',
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: _agree ? Colors.black : Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                // Zurück
                TextButton(
                  onPressed: () => Navigator.of(context).maybePop(),
                  child: Text(
                    'Zurück',
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
      hintStyle: GoogleFonts.poppins(color: Colors.grey.shade600, fontSize: 14),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
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
        borderSide: BorderSide(color: Colors.green.shade400, width: 2),
      ),
    );
  }
}
