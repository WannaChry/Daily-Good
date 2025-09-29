import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';

class PrivacySecurityPage extends StatefulWidget {
  const PrivacySecurityPage({super.key});

  @override
  State<PrivacySecurityPage> createState() => _PrivacySecurityPageState();
}

class _PrivacySecurityPageState extends State<PrivacySecurityPage> {
  // Privatsphäre
  String visibility = 'Freunde'; // Öffentlich / Freunde / Privat
  bool locationAllowed = false;
  bool personalization = true;
  bool analytics = true;

  // Zwei Faktor UI Toggle nur visuell
  bool _twoFAEnabled = false;

  // Sessions Demo
  final List<_Session> sessions = [
    _Session(device: 'Pixel 7 • Android', lastActive: 'Gerade eben', current: true),
    _Session(device: 'iPad • iPadOS', lastActive: 'Gestern, 21:14'),
    _Session(device: 'Chrome • Windows', lastActive: '2. Sep, 10:03'),
  ];

  // Passwort Felder für den Dialog
  final _oldCtrl = TextEditingController();
  final _newCtrl = TextEditingController();
  final _new2Ctrl = TextEditingController();

  // Busy State für den Speichern Button im Dialog
  bool _changingPw = false;

  @override
  void dispose() {
    _oldCtrl.dispose();
    _newCtrl.dispose();
    _new2Ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final h1 = GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w800);
    final hint = GoogleFonts.poppins(fontSize: 12.5, color: Colors.grey.shade700);

    return Scaffold(
      backgroundColor: const Color(0xFFF8F3FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: Text('Datenschutz & Sicherheit', style: GoogleFonts.poppins(fontWeight: FontWeight.w700)),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Kontoschutz
          Text('Kontoschutz', style: h1),
          const SizedBox(height: 8),
          _Card(
            child: Column(
              children: [
                ListTile(
                  title: const Text('Passwort ändern'),
                  subtitle: Text('Empfohlen alle 6–12 Monate', style: hint),
                  trailing: const Icon(Icons.chevron_right),
                  onTap:  () => Navigator.pushNamed(context, '/password_change'),
                ),
                const Divider(height: 1),
                ListTile(
                  title: const Text('Zwei-Faktor-Authentifizierung'),
                  subtitle: Text('Extra Schutz mit Code', style: hint),
                  trailing: Switch(
                    value: _twoFAEnabled,
                    onChanged: (v) => setState(() => _twoFAEnabled = v),
                  ),
                  onTap: () => setState(() => _twoFAEnabled = !_twoFAEnabled),
                ),
                const Divider(height: 1),
                ExpansionTile(
                  tilePadding: const EdgeInsets.symmetric(horizontal: 16),
                  title: const Text('Geräte & Sitzungen'),
                  subtitle: Text('Aktive Logins verwalten', style: hint),
                  childrenPadding: const EdgeInsets.only(bottom: 8),
                  children: [
                    ...sessions.map((s) => _SessionTile(
                      session: s,
                      onSignOut: () => setState(() => sessions.remove(s)),
                    )),
                    const SizedBox(height: 4),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: _signOutAllOther,
                          child: const Text('Alle anderen abmelden'),
                        ),
                      ),
                    )
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Privatsphäre
          Text('Privatsphäre', style: h1),
          const SizedBox(height: 8),
          _Card(
            child: Column(
              children: [
                ListTile(
                  title: const Text('Profil-Sichtbarkeit'),
                  subtitle: Text('Wer kann dein Profil sehen?', style: hint),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
                  child: Wrap(
                    spacing: 8,
                    children: ['Öffentlich', 'Freunde', 'Privat'].map((opt) {
                      final sel = visibility == opt;
                      return ChoiceChip(
                        label: Text(opt),
                        selected: sel,
                        onSelected: (_) => setState(() => visibility = opt),
                      );
                    }).toList(),
                  ),
                ),
                const Divider(height: 1),
                SwitchListTile(
                  value: locationAllowed,
                  onChanged: (v) => setState(() => locationAllowed = v),
                  title: const Text('Standortzugriff'),
                  subtitle: Text('Für lokale Empfehlungen', style: hint),
                ),
                const Divider(height: 1),
                SwitchListTile(
                  value: personalization,
                  onChanged: (v) => setState(() => personalization = v),
                  title: const Text('Personalisierte Inhalte'),
                  subtitle: Text('Aufgaben und Tipps zugeschnitten', style: hint),
                ),
                const Divider(height: 1),
                SwitchListTile(
                  value: analytics,
                  onChanged: (v) => setState(() => analytics = v),
                  title: const Text('Analytics & Crashberichte'),
                  subtitle: Text('Hilft uns, die App zu verbessern', style: hint),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Datenkontrolle
          Text('Datenkontrolle', style: h1),
          const SizedBox(height: 8),
          _Card(
            child: Column(
              children: [
                ListTile(
                  title: const Text('Meine Daten anfordern'),
                  subtitle: Text('Auskunft über gespeicherte Daten', style: hint),
                  trailing: const Icon(Icons.download_outlined),
                  onTap: () => _toast('Datenanforderung gesendet.'),
                ),
                const Divider(height: 1),
                ListTile(
                  title: const Text('Konto löschen'),
                  subtitle: Text('Dauerhaft und unwiderruflich, vorsichtig', style: hint),
                  trailing: const Icon(Icons.delete_forever, color: Colors.red),
                  onTap: _confirmDeleteAccount,
                ),
              ],
            ),
          ),

          const SizedBox(height: 32),
        ],
      ),
    );
  }

  void _toast(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  void _signOutAllOther() {
    setState(() {
      sessions.removeWhere((s) => !s.current);
    });
    _toast('Andere Sitzungen abgemeldet.');
  }

  // Passwortänderung: Busy-State, Re-Auth, Update, Logout, Navigation
  Future<void> _applyPasswordChange(BuildContext dialogCtx) async {
    setState(() => _changingPw = true);

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      _toast('Kein Nutzer angemeldet.');
      if (mounted) setState(() => _changingPw = false);
      return;
    }

    final email = user.email;
    if (email == null || email.isEmpty) {
      _toast('Für dieses Konto ist keine E-Mail hinterlegt.');
      if (mounted) setState(() => _changingPw = false);
      return;
    }

    final current = _oldCtrl.text.trim();
    final newPw = _newCtrl.text.trim();
    final repeat = _new2Ctrl.text.trim();

    if (newPw.length < 8) {
      _toast('Neues Passwort ist zu kurz. Mindestens 8 Zeichen.');
      if (mounted) setState(() => _changingPw = false);
      return;
    }
    if (newPw == current) {
      _toast('Neues Passwort darf nicht dem aktuellen entsprechen.');
      if (mounted) setState(() => _changingPw = false);
      return;
    }
    if (newPw != repeat) {
      _toast('Passwörter stimmen nicht überein.');
      if (mounted) setState(() => _changingPw = false);
      return;
    }

    try {
      // Re Auth, schlägt bei falschem Passwort oder ohne Passwort Provider fehl
      final cred = EmailAuthProvider.credential(email: email, password: current);
      await user.reauthenticateWithCredential(cred);

      // Neues Passwort setzen
      await user.updatePassword(newPw);

      // Abmelden, Dialog schließen, zur Login Seite
      await FirebaseAuth.instance.signOut();
      if (!mounted) return;
      Navigator.of(dialogCtx).pop();
      Navigator.pushNamedAndRemoveUntil(context, '/login', (_) => false);
      _toast('Passwort erfolgreich geändert.');
    } on FirebaseAuthException catch (e) {
      if (e.code == 'wrong-password') {
        _toast('Aktuelles Passwort ist falsch.');
      } else if (e.code == 'user-mismatch' ||
          e.code == 'user-not-found' ||
          e.code == 'invalid-credential' ||
          e.code == 'requires-recent-login') {
        await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
        _toast('Kein Passwort Login verknüpft. Reset Mail gesendet.');
        if (mounted) Navigator.of(dialogCtx).pop();
      } else {
        _toast(e.message ?? 'Fehler beim Ändern.');
      }
    } catch (e) {
      _toast('Unerwarteter Fehler: $e');
    } finally {
      if (mounted) setState(() => _changingPw = false);
    }
  }

  void _showChangePasswordDialog() {
    _oldCtrl.clear();
    _newCtrl.clear();
    _new2Ctrl.clear();

    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        title: Text('Passwort ändern', style: GoogleFonts.poppins(fontWeight: FontWeight.w700)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _PwdField(label: 'Aktuelles Passwort', controller: _oldCtrl),
            const SizedBox(height: 10),
            _PwdField(label: 'Neues Passwort', controller: _newCtrl),
            const SizedBox(height: 10),
            _PwdField(label: 'Neues Passwort wiederholen', controller: _new2Ctrl),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx),
            child: const Text('Abbrechen'),
          ),
          TextButton(
            onPressed: _changingPw
                ? null
                : () async {
              await _applyPasswordChange(dialogCtx);
            },
            child: _changingPw
                ? const SizedBox(
                width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
                : const Text('Speichern'),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmDeleteAccount() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Konto löschen?', style: GoogleFonts.poppins(fontWeight: FontWeight.w700)),
        content: Text(
          'Dein Konto und alle zugehörigen Daten werden dauerhaft gelöscht. '
              'Dieser Vorgang kann nicht rückgängig gemacht werden.',
          style: GoogleFonts.poppins(),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Abbrechen')),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Ja, löschen', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (ok == true) {
      _toast('Konto gelöscht.');
      if (mounted) Navigator.pop(context);
    }
  }
}

// Helpers

class _Card extends StatelessWidget {
  const _Card({required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade300),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          )
        ],
      ),
      child: child,
    );
  }
}

class _PwdField extends StatefulWidget {
  const _PwdField({required this.label, required this.controller});
  final String label;
  final TextEditingController controller;

  @override
  State<_PwdField> createState() => _PwdFieldState();
}

class _PwdFieldState extends State<_PwdField> {
  bool _obscure = true;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: widget.controller,
      obscureText: _obscure,
      decoration: InputDecoration(
        labelText: widget.label,
        border: const OutlineInputBorder(),
        suffixIcon: IconButton(
          icon: Icon(_obscure ? Icons.visibility : Icons.visibility_off),
          onPressed: () => setState(() => _obscure = !_obscure),
        ),
      ),
    );
  }
}

class _Session {
  _Session({required this.device, required this.lastActive, this.current = false});
  final String device;
  final String lastActive;
  final bool current;
}

class _SessionTile extends StatelessWidget {
  const _SessionTile({required this.session, required this.onSignOut});
  final _Session session;
  final VoidCallback onSignOut;

  @override
  Widget build(BuildContext context) {
    final style = GoogleFonts.poppins(fontSize: 13, color: Colors.grey.shade700);
    return ListTile(
      title: Text(session.device, style: GoogleFonts.poppins(fontWeight: FontWeight.w700)),
      subtitle: Text(session.current ? 'Diese Sitzung • ${session.lastActive}' : session.lastActive, style: style),
      trailing: session.current
          ? const Text('Aktiv', style: TextStyle(fontWeight: FontWeight.w700))
          : TextButton(onPressed: onSignOut, child: const Text('Abmelden')),
    );
  }
}
