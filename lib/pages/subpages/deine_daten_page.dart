import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:async';

class DeineDatenPage extends StatefulWidget {
  const DeineDatenPage({super.key});

  @override
  State<DeineDatenPage> createState() => _DeineDatenPageState();
}

class _DeineDatenPageState extends State<DeineDatenPage> {
  // Profilfelder
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _ageCtrl = TextEditingController();
  final _jobCtrl = TextEditingController();
  final _aboutCtrl = TextEditingController();
  final _birthdayCtrl = TextEditingController();
  final _aboutFocus = FocusNode();
  final _bioDebounce = _Debouncer(ms: 400);

  late final DocumentReference<Map<String, dynamic>> _userDoc;
  bool _prefilled = false;
  bool _saving = false;

  // Freundschaftscode + Verknüpfungen
  late String _friendCode;
  bool _googleLinked = false;
  bool _appleLinked = false;

  @override
  void initState() {
    super.initState();

    final uid = FirebaseAuth.instance.currentUser!.uid;
    _userDoc = FirebaseFirestore.instance.collection('users').doc(uid);
    _friendCode = _generateFriendCode(9);
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _ageCtrl.dispose();
    _jobCtrl.dispose();
    _aboutCtrl.dispose();
    _birthdayCtrl.dispose();
    _aboutFocus.dispose();
    _bioDebounce.dispose();
    super.dispose();
  }

  // generiert Freundescode
  String _generateFriendCode(int length) {
    const chars = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';
    final rnd = Random.secure();
    return List.generate(
      length,
      (_) => chars[rnd.nextInt(chars.length)],
    ).join();
  }

  DateTime? _parseBirthday(String s) {
    try {
      if (RegExp(r'^\d{2}\.\d{2}\.\d{4}$').hasMatch(s)) {
        final p = s.split('.');
        return DateTime(int.parse(p[2]), int.parse(p[1]), int.parse(p[0]));
      } else if (RegExp(r'^\d{4}-\d{2}-\d{2}$').hasMatch(s)) {
        final p = s.split('-');
        return DateTime(int.parse(p[0]), int.parse(p[1]), int.parse(p[2]));
      }
    } catch (_) {}
    return null;
  }

  String _fmt2(int n) => n.toString().padLeft(2, '0');

  String _formatDate(DateTime d) =>
      '${_fmt2(d.day)}.${_fmt2(d.month)}.${d.year}';

  int? _calcAge(String s) {
    final dob = _parseBirthday(s);
    if (dob == null) return null;
    final now = DateTime.now();
    var age = now.year - dob.year;
    if (now.month < dob.month || (now.month == dob.month && now.day < dob.day))
      age--;
    return age;
  }

  Future<void> _pickBirthday() async {
    final now = DateTime.now();
    final initial =
        _parseBirthday(_birthdayCtrl.text) ??
        DateTime(now.year - 18, now.month, now.day);
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(1900, 1, 1),
      lastDate: now,
      helpText: 'Geburtstag wählen',
    );
    if (picked != null) {
      final text = _formatDate(picked);
      setState(() {
        _birthdayCtrl.text = text;
        _ageCtrl.text = (_calcAge(text) ?? '').toString();
      });
    }
  }

  Map<String, dynamic> _collectData() {
    return {
      'profile': {
        'username': _nameCtrl.text.trim(),
        'email': _emailCtrl.text.trim(),
        'age': int.tryParse(_ageCtrl.text.trim()),
        'job': _jobCtrl.text.trim(),
        'about': _aboutCtrl.text.trim(),
        'friendCode': _friendCode,
      },
      'linkedAccounts': {'google': _googleLinked, 'apple': _appleLinked},
      // Platzhalter für spätere Erweiterungen (Punkte, Tasks, Communities)
      'meta': {
        'exportedAt': DateTime.now().toIso8601String(),
        'schemaVersion': 1,
      },
    };
  }

  Future<void> _exportData() async {
    final data = _collectData();
    final pretty = const JsonEncoder.withIndent('  ').convert(data);

    await Clipboard.setData(ClipboardData(text: pretty));
    if (!mounted) return;
    _showDialog(
      title: 'Daten exportiert',
      content:
          'Die JSON-Daten wurden in die Zwischenablage kopiert.\n\n'
          'Du kannst sie jetzt sichern oder teilen.',
      actions: [
        TextButton(
          onPressed: () {
            Navigator.pop(context);
            _showScrollDialog('Exportierte Daten (JSON)', pretty);
          },
          child: const Text('ANZEIGEN'),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('OK'),
        ),
      ],
    );
  }

  Future<void> _importData() async {
    String buffer = '';
    await _showScrollInputDialog(
      title: 'Daten importieren',
      hint:
          '{\n  "profile": { ... },\n  "linkedAccounts": { ... },\n  "meta": { ... }\n}',
      onSubmit: (text) => buffer = text,
    );
    if (!mounted || buffer.trim().isEmpty) return;

    try {
      final Map<String, dynamic> json = jsonDecode(buffer);

      final p = (json['profile'] as Map?) ?? {};
      setState(() {
        _nameCtrl.text = (p['username'] ?? '').toString();
        _emailCtrl.text = (p['email'] ?? '').toString();
        _ageCtrl.text = (p['age']?.toString() ?? '');
        _jobCtrl.text = (p['job'] ?? '').toString();
        _aboutCtrl.text = (p['about'] ?? '').toString();
        _friendCode = (p['friendCode'] ?? _friendCode).toString();

        final l = (json['linkedAccounts'] as Map?) ?? {};
        _googleLinked = (l['google'] == true);
        _appleLinked = (l['apple'] == true);
      });

      _showDialog(
        title: 'Import erfolgreich',
        content: 'Deine Daten wurden übernommen.',
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      );
    } catch (e) {
      _showDialog(
        title: 'Import fehlgeschlagen',
        content: 'Die JSON-Daten konnten nicht gelesen werden.\n\nFehler: $e',
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      );
    }
  }

  void _clearCache() {
    // Placeholder – später shared_preferences / Cache leeren
    _showDialog(
      title: 'Cache geleert',
      content: 'Lokale App-Daten wurden (Demo) zurückgesetzt.',
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('OK'),
        ),
      ],
    );
  }

  void _showDialog({
    required String title,
    required String content,
    required List<Widget> actions,
  }) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(
          title,
          style: GoogleFonts.poppins(fontWeight: FontWeight.w700),
        ),
        content: Text(content, style: GoogleFonts.poppins()),
        actions: actions,
      ),
    );
  }

  void _showScrollDialog(String title, String bigText) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(
          title,
          style: GoogleFonts.poppins(fontWeight: FontWeight.w700),
        ),
        content: SizedBox(
          width: double.maxFinite,
          child: SingleChildScrollView(
            child: SelectableText(
              bigText,
              style: GoogleFonts.robotoMono(fontSize: 13),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('SCHLIESSEN'),
          ),
        ],
      ),
    );
  }

  Future<void> _showScrollInputDialog({
    required String title,
    required String hint,
    required ValueChanged<String> onSubmit,
  }) async {
    final ctrl = TextEditingController();
    await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(
          title,
          style: GoogleFonts.poppins(fontWeight: FontWeight.w700),
        ),
        content: SizedBox(
          width: double.maxFinite,
          child: TextField(
            controller: ctrl,
            maxLines: 12,
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: GoogleFonts.robotoMono(color: Colors.grey.shade600),
              border: const OutlineInputBorder(),
            ),
            style: GoogleFonts.robotoMono(fontSize: 13),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('ABBRECHEN'),
          ),
          TextButton(
            onPressed: () {
              onSubmit(ctrl.text);
              Navigator.pop(context);
            },
            child: const Text('IMPORTIEREN'),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmRegenerateCode() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(
          'Code neu generieren',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w700),
        ),
        content: Text(
          'Dein aktueller Freundschaftscode wird ungültig. Fortfahren?',
          style: GoogleFonts.poppins(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('ABBRECHEN'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('NEU GENERIEREN'),
          ),
        ],
      ),
    );
    if (ok == true) {
      setState(() => _friendCode = _generateFriendCode(9));
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Neuer Code erstellt.')));
    }
  }

  Future<void> _saveProfile() async {
    FocusScope.of(context).unfocus();
    setState(() => _saving = true);
    try {
      final age = _calcAge(_birthdayCtrl.text);
      await _userDoc.set({
        'name': _nameCtrl.text.trim(),
        'email': _emailCtrl.text.trim(),
        'birthday': _birthdayCtrl.text.trim(),
        'age': age,
        'occupation': _jobCtrl.text.trim(),
        'bio': _aboutCtrl.text.trim(),
        'friendCode': _friendCode,
        // 'ageRange': _ageCtrl.text.trim(),
      }, SetOptions(merge: true));

      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Gespeichert')));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Fehler: $e')));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final h1 = GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w800);
    final hint = GoogleFonts.poppins(
      fontSize: 12.5,
      color: Colors.grey.shade700,
    );

    return Scaffold(
      backgroundColor: const Color(0xFFF8F3FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: Text(
          'Deine Daten',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w700),
        ),
      ),

      body: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
        stream: _userDoc.snapshots(),
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snap.hasData || !snap.data!.exists) {
            return const Center(child: Text('Keine Profildaten gefunden'));
          }

          final d = snap.data!.data()!;
          if (!_prefilled) {
            _prefilled = true;
            _nameCtrl.text = (d['name'] ?? '') as String;
            _emailCtrl.text = (d['email'] ?? '') as String;
            _birthdayCtrl.text = (d['birthday'] ?? '') as String;
            _ageCtrl.text = (d['ageRange'] ?? '') as String;
            _ageCtrl.text = (_calcAge(_birthdayCtrl.text) ?? '').toString();
            _jobCtrl.text = (d['occupation'] ?? '') as String;
            _aboutCtrl.text = (d['bio'] ?? '') as String;
            final remoteBio = (d['bio'] ?? '') as String;
            if (!_aboutFocus.hasFocus && _aboutCtrl.text != remoteBio) {
              _aboutCtrl.text = remoteBio;
            }

            final code = (d['friendCode'] ?? '') as String;
            if (code.isNotEmpty) {
              _friendCode = code;
            } else {
              _userDoc.set({
                'friendCode': _friendCode,
              }, SetOptions(merge: true));
            }
          }

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // ---------- Profil ----------
              Text('Profil', style: h1),
              const SizedBox(height: 8),
              _Card(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    children: [
                      _TextRow(
                        label: 'Benutzername',
                        controller: _nameCtrl,
                        hint: 'z. B. max.mustermann',
                      ),
                      const Divider(height: 1),
                      _TextRow(
                        label: 'E-Mail',
                        controller: _emailCtrl,
                        hint: 'z. B. max@mail.com',
                        keyboard: TextInputType.emailAddress,
                      ),
                      const Divider(height: 1),
                      _TextRow(
                        label: 'Geburtstag',
                        controller: _birthdayCtrl,
                        hint: 'TT.MM.JJJJ',
                        readOnly: true,
                        onTap: _pickBirthday,
                        suffix: const Icon(
                          Icons.calendar_today_outlined,
                          size: 18,
                        ),
                      ),
                      const Divider(height: 1),
                      _TextRow(
                        label: 'Alter',
                        controller: _ageCtrl,
                        hint: 'wird berechnet',
                        readOnly: true,
                      ),
                      const Divider(height: 1),
                      _TextRow(
                        label: 'Beruf',
                        controller: _jobCtrl,
                        hint: 'z. B. Student:in',
                      ),
                      const Divider(height: 1),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Über mich',
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      const SizedBox(height: 6),
                      TextField(
                        controller: _aboutCtrl,
                        focusNode: _aboutFocus,
                        minLines: 2,
                        maxLines: 4,
                        onChanged: (v) => _bioDebounce.run(
                          () => _userDoc.update({'bio': v.trim()}),
                        ),
                        // <— live in Firestore speichern
                        decoration: const InputDecoration(
                          isDense: true,
                          border: OutlineInputBorder(),
                          hintText: 'Kurzbeschreibung…',
                        ),
                      ),

                      const SizedBox(height: 10),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFA8D5A2),
                            foregroundColor: Colors.black,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          onPressed: _saving ? null : _saveProfile,
                          child: _saving
                              ? const SizedBox(
                                  height: 18,
                                  width: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Text('Speichern'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // ---------- Freundschaftscode ----------
              Text('Freundschaftscode', style: h1),
              const SizedBox(height: 8),
              _Card(
                child: ListTile(
                  title: Text(
                    _friendCode,
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.8,
                    ),
                  ),
                  subtitle: Text(
                    'Teile diesen Code, damit dich Freunde finden.',
                    style: hint,
                  ),
                  trailing: Wrap(
                    spacing: 8,
                    children: [
                      OutlinedButton(
                        onPressed: () {
                          Clipboard.setData(ClipboardData(text: _friendCode));
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Code kopiert.')),
                          );
                        },
                        child: const Text('KOPIEREN'),
                      ),
                      ElevatedButton(
                        onPressed: _confirmRegenerateCode,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.grey.shade200,
                          foregroundColor: Colors.black,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: const Text('NEU'),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // ---------- Portabilität ----------
              Text('Portabilität', style: h1),
              const SizedBox(height: 8),
              _Card(
                child: Column(
                  children: [
                    ListTile(
                      title: const Text('Daten exportieren'),
                      subtitle: Text(
                        'Profil, Verknüpfungen – als JSON',
                        style: hint,
                      ),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: _exportData,
                    ),
                    const Divider(height: 1),
                    ListTile(
                      title: const Text('Daten importieren'),
                      subtitle: Text(
                        'JSON einfügen und übernehmen',
                        style: hint,
                      ),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: _importData,
                    ),
                    const Divider(height: 1),
                    ListTile(
                      title: const Text('Lokalen Cache leeren'),
                      subtitle: Text(
                        'Zurücksetzen von App-Zwischenspeichern',
                        style: hint,
                      ),
                      trailing: const Icon(Icons.delete_outline),
                      onTap: _clearCache,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // ---------- Verknüpfte Konten ----------
              Text('Verknüpfte Konten', style: h1),
              const SizedBox(height: 8),
              _Card(
                child: Column(
                  children: [
                    SwitchListTile(
                      value: _googleLinked,
                      onChanged: (v) => setState(() => _googleLinked = v),
                      title: const Text('Google'),
                      subtitle: Text(
                        _googleLinked ? 'Verbunden' : 'Nicht verbunden',
                        style: hint,
                      ),
                    ),
                    const Divider(height: 1),
                    SwitchListTile(
                      value: _appleLinked,
                      onChanged: (v) => setState(() => _appleLinked = v),
                      title: const Text('Apple'),
                      subtitle: Text(
                        _appleLinked ? 'Verbunden' : 'Nicht verbunden',
                        style: hint,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),
            ],
          );
        },
      ),
    );
  }
}

// ---------- Helpers ----------

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
          ),
        ],
      ),
      child: child,
    );
  }
}

class _Debouncer {
  _Debouncer({this.ms = 300});

  final int ms;
  Timer? _t;

  void run(void Function() f) {
    _t?.cancel();
    _t = Timer(Duration(milliseconds: ms), f);
  }

  void dispose() => _t?.cancel();
}

class _TextRow extends StatelessWidget {
  const _TextRow({
    required this.label,
    required this.controller,
    this.hint,
    this.keyboard,
    this.readOnly = false,
    this.onTap,
    this.suffix,
  });

  final String label;
  final TextEditingController controller;
  final String? hint;
  final TextInputType? keyboard;
  final bool readOnly;
  final VoidCallback? onTap;
  final Widget? suffix;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
      child: Row(
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: GoogleFonts.poppins(fontWeight: FontWeight.w700),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              controller: controller,
              readOnly: readOnly,
              onTap: onTap,
              keyboardType: keyboard,
              decoration: InputDecoration(
                isDense: true,
                hintText: hint,
                border: const OutlineInputBorder(),
                suffixIcon: suffix,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
