import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AuthEntryPage extends StatelessWidget {
  const AuthEntryPage({super.key});

  @override
  Widget build(BuildContext context) {
    final h1 = GoogleFonts.poppins(fontSize: 22, fontWeight: FontWeight.w800);
    final p  = GoogleFonts.poppins(fontSize: 14, color: Colors.grey.shade700);

    return Scaffold(
      backgroundColor: const Color(0xFFF8F3FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: Text("Konto", style: GoogleFonts.poppins(fontWeight: FontWeight.w700)),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header Card
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Melde dich an", style: h1),
                    const SizedBox(height: 8),
                    Text(
                      "Sichere deinen Fortschritt, synchronisiere Geräte und finde Freunde.",
                      style: p,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Primary CTA – Anmelden
              Material(
                color: const Color(0xFFA8D5A2),
                borderRadius: BorderRadius.circular(16),
                child: InkWell(
                  borderRadius: BorderRadius.circular(16),
                  onTap: () {
                    // TODO: später zur echten Anmeldung/Onboarding navigieren
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Anmelden (kommt später)")),
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    alignment: Alignment.center,
                    child: Text(
                      "Anmelden",
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 12),

              // Secondary CTA – Konto erstellen
              OutlinedButton(
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  side: BorderSide(color: Colors.grey.shade400),
                  backgroundColor: Colors.white,
                ),
                onPressed: () {
                  // TODO: später Registrierung
                },
                child: Text(
                  "Konto erstellen",
                  style: GoogleFonts.poppins(fontWeight: FontWeight.w700),
                ),
              ),

              const SizedBox(height: 8),

              // „Später“ / Gastmodus
              TextButton(
                onPressed: () {
                  Navigator.of(context).maybePop(); // zurück zur App
                },
                child: Text(
                  "Später",
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w700,
                    color: Colors.grey.shade700,
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Vorteile / Info-Kacheln (nur Formen & Text)
              _BenefitTile(
                title: "Fortschritt sichern",
                text: "Deine Punkte und Levels bleiben erhalten – auch bei Gerätewechsel.",
              ),
              const SizedBox(height: 12),
              _BenefitTile(
                title: "Freunde finden",
                text: "Nutze deinen Freundschaftscode, um dich mit anderen zu verbinden.",
              ),
              const SizedBox(height: 12),
              _BenefitTile(
                title: "Synchronisiert",
                text: "Automatische Sicherung und Synchronisierung deiner Daten.",
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BenefitTile extends StatelessWidget {
  const _BenefitTile({required this.title, required this.text});
  final String title;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: GoogleFonts.poppins(fontWeight: FontWeight.w800)),
          const SizedBox(height: 6),
          Text(text, style: GoogleFonts.poppins(fontSize: 13, color: Colors.grey.shade700)),
        ],
      ),
    );
  }
}
