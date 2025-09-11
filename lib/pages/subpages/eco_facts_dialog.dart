import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:studyproject/pages/models/tipp.dart';

/// Zeigt einen stylischen, zentrierten Klima-/Sozial-Fakt.
/// Schließen: Tap außerhalb oder auf das X oben rechts.
Future<void> showEcoFactDialog(BuildContext context) async {
  final rnd = Random();


  // Kurze, gut lesbare Fakten – gern beliebig erweitern.
  /*final facts = <String>[
    'Bambuswälder produzieren bis zu 35 % mehr Sauerstoff als gleich große Baumbestände.',
    'LED-Lampen verbrauchen ~80 % weniger Strom als Glühbirnen – und halten viel länger.',
    'Regional & saisonal einkaufen spart Transportwege und Verpackungsmüll.',
    'Eine vegetarische Mahlzeit spart im Schnitt 1–2 kg CO₂ im Vergleich zu Fleisch.',
    'Eine Mehrweg-Glasflasche kann 30–50 Mal wiederbefüllt werden.',
    '3 km zu Fuß statt Auto spart ~500 g CO₂ – und tut gut.',
    '1 °C weniger Heizung ≈ 6 % weniger Energieverbrauch.',
    'Geräte komplett ausschalten statt Standby spart bis zu 10 % Strom.',
    'Sharing statt Kaufen: Werkzeuge teilen reduziert Ressourcenverbrauch deutlich.',
    'Wälder schützen bindet langfristig mehr CO₂ als einzelne Neupflanzungen.',
    "Ein baum filtert pro Jahr bis zu 100kg CO₂ aus der Luft.",
    "Recycling von Aluminium spart bis zu 95 % der Energie im Vergleich zur Neuproduktion.",
    "Mit einer Stunde Radfahren statt Autofahren sparst du rund 250 g CO₂.",
    "Wasserhahn zu beim Zähneputzen spart bis zu 12 Liter Wasser pro Minute",
    "Ein Fairtrade-Kaffee sichert bessere Arbeitsbedingungen für Bauern weltweit.",
    "Mit ÖPNV fahren verursacht bis zu 75 % weniger CO₂ als Autofahren.",
    "Second-Hand-Kleidung reduziert den Ressourcenverbrauch der Textilindustrie drastisch.",
  ];
   */
  // Firestore-Tipps laden
  final snapshot = await FirebaseFirestore.instance.collection('tipps').get();
  if (snapshot.docs.isEmpty) return; // Keine Tipps vorhanden
  // Tipp-Liste aus Dokumenten erstellen
  final tips = snapshot.docs.map((doc) => Tipp.fromJson(doc.data())).toList();

  // Zufälligen Fakt + Akzentfarben wählen
  final selectedtips = tips[rnd.nextInt(tips.length)];
  final accents = [
    [const Color(0xFFA7E3A1), const Color(0xFF74C69D)],
    [const Color(0xFFB8E1FF), const Color(0xFF91C3F2)],
    [const Color(0xFFFFE29A), const Color(0xFFF9C46B)],
    [const Color(0xFFF7C5CC), const Color(0xFFF3A7B1)],
  ];
  final colors = accents[rnd.nextInt(accents.length)];

  await showGeneralDialog(
    context: context,
    barrierLabel: 'EcoFact',
    barrierDismissible: true,
    barrierColor: Colors.black.withOpacity(0.25),
    transitionDuration: const Duration(milliseconds: 260),
    pageBuilder: (_, __, ___) {
      // Inhalt kommt im transitionBuilder
      return const SizedBox.shrink();
    },
    transitionBuilder: (context, anim, _, __) {
      final curved = CurvedAnimation(parent: anim, curve: Curves.easeOutCubic);
      return Center(
        child: FadeTransition(
          opacity: curved,
          child: ScaleTransition(
            scale: Tween<double>(begin: 0.96, end: 1.0).animate(curved),
            child: Material(
              color: Colors.transparent,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Stack(
                  children: [
                    // Glas/Blur Hintergrund
                    BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
                      child: Container(
                        width: MediaQuery.of(context).size.width * 0.82,
                        constraints: const BoxConstraints(maxWidth: 460),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              Colors.white.withOpacity(0.78),
                              Colors.white.withOpacity(0.62),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: Colors.white.withOpacity(0.7), width: 1.2),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.10),
                              blurRadius: 22,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            // zarter farbiger Schimmer
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                colors[0].withOpacity(0.18),
                                colors[1].withOpacity(0.10),
                              ],
                            ),
                          ),
                          padding: const EdgeInsets.fromLTRB(18, 18, 18, 16),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Kopfzeile
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Container(
                                    width: 38,
                                    height: 38,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      gradient: LinearGradient(
                                        colors: [colors[0], colors[1]],
                                      ),
                                    ),
                                    child: const Icon(Icons.eco, color: Colors.black, size: 22),
                                  ),
                                  const SizedBox(width: 12),
                                  Text(
                                    'Wusstest du schon?',
                                    style: GoogleFonts.poppins(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                  const Spacer(),
                                  IconButton(
                                    tooltip: 'Schließen',
                                    splashRadius: 20,
                                    icon: const Icon(Icons.close_rounded),
                                    onPressed: () => Navigator.of(context).maybePop(),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10),
                              // Fakt
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(14),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(14),
                                  border: Border.all(color: Colors.black.withOpacity(0.05)),
                                ),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // stylischer Quote-Balken
                                    Container(
                                      width: 4,
                                      height: null,
                                      margin: const EdgeInsets.only(right: 12, top: 2),
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(999),
                                        gradient: LinearGradient(colors: [colors[0], colors[1]]),
                                      ),
                                    ),
                                    Expanded(
                                      child: Text(
                                        selectedtips.message,
                                        style: GoogleFonts.poppins(
                                          height: 1.35,
                                          fontSize: 15.5,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 10),
                              // subtile Fußzeile
                              Row(
                                children: [
                                  Icon(Icons.bolt_rounded,
                                      size: 18, color: Colors.black.withOpacity(0.65)),
                                  const SizedBox(width: 6),
                                  Text(
                                    'Kleine Tat, große Wirkung.',
                                    style: GoogleFonts.poppins(
                                      fontSize: 12.5,
                                      color: Colors.black.withOpacity(0.65),
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
    },
  );
}
