import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class HelpSupportPage extends StatelessWidget {
  const HelpSupportPage({super.key, this.initialTab = 0});

  /// 0=FAQ, 1=Kontakt, 2=Feedback, 3=Fehler, 4=Richtlinien
  final int initialTab;

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 5,
      initialIndex: initialTab.clamp(0, 4),
      child: Scaffold(
        backgroundColor: const Color(0xFFF8F3FA),
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          centerTitle: true,
          title: Text('Hilfe & Support',
              style: GoogleFonts.poppins(fontWeight: FontWeight.w700)),
          bottom: const TabBar(
            isScrollable: true,
            tabs: [
              Tab(text: 'FAQ'),
              Tab(text: 'Kontakt'),
              Tab(text: 'Feedback'),
              Tab(text: 'Fehler melden'),
              Tab(text: 'Richtlinien'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            _FaqTab(),
            _ContactTab(),
            _FeedbackTab(),
            _BugReportTab(),
            _GuidelinesTab(),
          ],
        ),
      ),
    );
  }
}

// ---------- Tabs ----------

class _FaqTab extends StatelessWidget {
  const _FaqTab();

  @override
  Widget build(BuildContext context) {
    final qa = const [
      ('Wie sammle ich Punkte?', 'Erledige Ziele auf der Startseite. Jede Aufgabe bringt Punkte.'),
      ('Wie funktioniert das Level-System?', 'Du steigst automatisch auf, wenn du genug Punkte gesammelt hast.'),
      ('Wofür ist der Freundschaftscode?', 'Damit dich Freunde finden und sich verbinden können.'),
      ('Wie ändere ich Benachrichtigungen?', 'Profil → Account → Benachrichtigungen.'),
    ];
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: qa.length,
      itemBuilder: (_, i) {
        final (q, a) = qa[i];
        return _Card(
          child: ExpansionTile(
            tilePadding: const EdgeInsets.symmetric(horizontal: 12),
            title: Text(q, style: GoogleFonts.poppins(fontWeight: FontWeight.w700)),
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
                child: Text(a, style: GoogleFonts.poppins()),
              )
            ],
          ),
        );
      },
    );
  }
}

class _ContactTab extends StatefulWidget {
  const _ContactTab();

  @override
  State<_ContactTab> createState() => _ContactTabState();
}

class _ContactTabState extends State<_ContactTab> {
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _msg = TextEditingController();

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _msg.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final hint = GoogleFonts.poppins(fontSize: 12.5, color: Colors.grey.shade700);
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _Card(
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text('Kontaktiere uns', style: GoogleFonts.poppins(fontWeight: FontWeight.w800)),
                const SizedBox(height: 10),
                _TextField(label: 'Name', controller: _name),
                const SizedBox(height: 8),
                _TextField(label: 'E-Mail', controller: _email, keyboard: TextInputType.emailAddress),
                const SizedBox(height: 8),
                _TextField(label: 'Nachricht', controller: _msg, maxLines: 5),
                const SizedBox(height: 12),
                ElevatedButton(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Nachricht gesendet (Demo).')),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFA8D5A2),
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('Senden'),
                ),
                const SizedBox(height: 8),
                Text('Antwort innerhalb von 1–2 Werktagen (Demo).', style: hint),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _FeedbackTab extends StatefulWidget {
  const _FeedbackTab();

  @override
  State<_FeedbackTab> createState() => _FeedbackTabState();
}

class _FeedbackTabState extends State<_FeedbackTab> {
  double rating = 4;
  final _text = TextEditingController();

  @override
  void dispose() {
    _text.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _Card(
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text('Wie gefällt dir die App?',
                    style: GoogleFonts.poppins(fontWeight: FontWeight.w800)),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Text('Bewertung'),
                    Expanded(
                      child: Slider(
                        value: rating,
                        min: 1,
                        max: 5,
                        divisions: 8,
                        label: rating.toStringAsFixed(1),
                        onChanged: (v) => setState(() => rating = v),
                      ),
                    ),
                  ],
                ),
                _TextField(label: 'Optionales Feedback', controller: _text, maxLines: 4),
                const SizedBox(height: 12),
                ElevatedButton(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Danke für ${rating.toStringAsFixed(1)} Sterne (Demo).')),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFA8D5A2),
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('Absenden'),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _BugReportTab extends StatefulWidget {
  const _BugReportTab();

  @override
  State<_BugReportTab> createState() => _BugReportTabState();
}

class _BugReportTabState extends State<_BugReportTab> {
  final _title = TextEditingController();
  final _steps = TextEditingController();
  final _expected = TextEditingController();
  final _actual = TextEditingController();
  String severity = 'Mittel'; // Niedrig/Mittel/Hoch/Kritisch

  @override
  void dispose() {
    _title.dispose();
    _steps.dispose();
    _expected.dispose();
    _actual.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final severities = ['Niedrig', 'Mittel', 'Hoch', 'Kritisch'];
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _Card(
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text('Fehler melden', style: GoogleFonts.poppins(fontWeight: FontWeight.w800)),
                const SizedBox(height: 10),
                _TextField(label: 'Kurztitel', controller: _title),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  value: severity,
                  items: severities.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                  onChanged: (v) => setState(() => severity = v ?? severity),
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Schweregrad',
                  ),
                ),
                const SizedBox(height: 8),
                _TextField(label: 'Schritte zur Reproduktion', controller: _steps, maxLines: 4),
                const SizedBox(height: 8),
                _TextField(label: 'Erwartetes Verhalten', controller: _expected, maxLines: 3),
                const SizedBox(height: 8),
                _TextField(label: 'Tatsächliches Verhalten', controller: _actual, maxLines: 3),
                const SizedBox(height: 12),
                ElevatedButton(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Bugreport gesendet (Demo).')),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFA8D5A2),
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('Senden'),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _GuidelinesTab extends StatelessWidget {
  const _GuidelinesTab();

  @override
  Widget build(BuildContext context) {
    final items = const [
      ('Community-Richtlinien', 'Respektvoller Umgang, keine Beleidigungen, keine SPAM-Inhalte.'),
      ('Datennutzung', 'Wir verarbeiten nur notwendige Daten für Kernfunktionen.'),
      ('Meldewege', 'Verstöße können über „Fehler melden“ gemeldet werden.'),
    ];
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: items.length,
      itemBuilder: (_, i) {
        final (t, s) = items[i];
        return _Card(
          child: ListTile(
            title: Text(t, style: GoogleFonts.poppins(fontWeight: FontWeight.w700)),
            subtitle: Text(s, style: GoogleFonts.poppins()),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              showDialog(
                context: context,
                builder: (_) => AlertDialog(
                  title: Text(t, style: GoogleFonts.poppins(fontWeight: FontWeight.w700)),
                  content: Text(s, style: GoogleFonts.poppins()),
                  actions: [
                    TextButton(onPressed: () => Navigator.pop(context), child: const Text('Schließen')),
                  ],
                ),
              );
            },
          ),
        );
      },
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
          )
        ],
      ),
      child: child,
    );
  }
}

class _TextField extends StatelessWidget {
  const _TextField({
    required this.label,
    required this.controller,
    this.maxLines = 1,
    this.keyboard,
  });

  final String label;
  final TextEditingController controller;
  final int maxLines;
  final TextInputType? keyboard;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: keyboard,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
      ),
    );
  }
}
