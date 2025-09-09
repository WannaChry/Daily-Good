// lib/pages/home.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';

// Achte auf snake_case-Dateinamen:
import 'package:studyproject/pages/ButtonsReaktion.dart';
import 'package:studyproject/pages/bottom_nav_only.dart';
import 'package:studyproject/pages/pages/activity_page.dart';
import 'package:studyproject/pages/pages/community_page.dart';
import 'package:studyproject/pages/pages/profile_page.dart';
import 'package:studyproject/pages/pages/auth_entry_page.dart';
import 'package:studyproject/pages/pages/sign_in_page.dart';
import 'package:studyproject/pages/pages/sign_up_page.dart';
import 'package:studyproject/pages/subpages/eco_facts_dialog.dart';
import 'package:studyproject/pages/subpages/mood_check_dialog.dart';
import 'dart:ui' show lerpDouble;

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0;
  int _totalPoints = 0; // Summe aus Seite 1

  late final GoalsPage _goalsPage;

  @override
  void initState() {
    super.initState();
    _goalsPage = GoalsPage(
      onPointsChanged: (p) => setState(() => _totalPoints = p),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F3FA),

      // ---------- AppBar ----------
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        toolbarHeight: 72,
        systemOverlayStyle: SystemUiOverlayStyle.dark,
        leading: ReactiveSvgButton(
          asset: 'assets/icons/menu-svgrepo-com.svg',
          size: 32,
          padding: const EdgeInsets.only(left: 12, top: 8),
          color: Colors.black,
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const SignInPage()),
            );
          },
        ),
        title: ReactiveSvgButton(
          asset: 'assets/icons/lightbulb-bolt-svgrepo-com.svg',
          size: 40,
          padding: const EdgeInsets.only(top: 8),
          rotateOnTap: true,
          color: Colors.black,
          onTap: () => showEcoFactDialog(context),
        ),
        actions: [
          ReactiveSvgButton(
            asset: 'assets/icons/checkbox-unchecked-svgrepo-com.svg',
            size: 36,
            padding: const EdgeInsets.only(right: 12, top: 8),
            color: Colors.black,
            onTap: () async {
              final result = await showMoodCheckDialog(context);
              if (!context.mounted || result == null) return;

              const labels = ['Sehr schlecht', 'Schlecht', 'Mittel', 'Gut', 'Sehr gut'];
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Stimmung: ${labels[result]}')),
              );
            },
          ),
        ],
      ),

      // ---------- Body ----------
      body: IndexedStack(
        index: _currentIndex,
        children: [
          _goalsPage,                               // Tab 1
          ActivityPage(totalPoints: _totalPoints),  // Tab 2
          const CommunityPage(),                    // Tab 3
          ProfilePage(totalPoints: _totalPoints),   // Tab 4
        ],
      ),

      // ---------- Bottom Nav ----------
      bottomNavigationBar: NavBar(
        currentIndex: _currentIndex,
        onTap: (i) => setState(() => _currentIndex = i),
      ),
    );
  }
}

// ==================== Tab 1: Ziele ====================
class GoalsPage extends StatefulWidget {
  const GoalsPage({super.key, required this.onPointsChanged});
  final ValueChanged<int> onPointsChanged;

  @override
  State<GoalsPage> createState() => _GoalsPageState();
}

class _GoalsPageState extends State<GoalsPage>
    with AutomaticKeepAliveClientMixin<GoalsPage> {
  // Mehr Aufgaben
  final List<Map<String, dynamic>> tasks = [
    {"text": "Trenne Müll richtig", "points": 5},
    {"text": "Handypause – 3h ohne Handy", "points": 5},
    {"text": "Halte einer Person die Tür auf", "points": 5},
    {"text": "Keine Einwegprodukte verwenden", "points": 10},
    {"text": "Leitungswasser statt Plastikflasche", "points": 5},
    {"text": "ÖPNV statt Auto", "points": 10},
    {"text": "Kleidung spenden/reparieren", "points": 10},
    {"text": "Regional kochen", "points": 10},
    {"text": "Positives Feedback schreiben", "points": 5},
  ];

  final Set<int> _completed = {};
  static const int _dailyTarget = 25; // neu

  int get _currentPoints =>
      _completed.fold<int>(0, (sum, i) => sum + (tasks[i]['points'] as int));

  void _toggleTask(int i, bool isDone) {
    setState(() {
      isDone ? _completed.remove(i) : _completed.add(i);
    });
    widget.onPointsChanged(_currentPoints);
  }

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final taskText =
    GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600);
    final pointsStyle =
    GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w800);

    return Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        children: [
          _TreeGrowth(points: _currentPoints, target: _dailyTarget),
          const SizedBox(height: 10),
          _ProgressCard(current: _currentPoints, target: _dailyTarget),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              children: [
                const Icon(Icons.calendar_today, size: 28),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Tägliche Aufgaben',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Expanded(
            child: ListView.separated(
              itemCount: tasks.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (context, i) {
                final t = tasks[i];
                final isDone = _completed.contains(i);

                return InkWell(
                  borderRadius: BorderRadius.circular(16),
                  onTap: () => _toggleTask(i, isDone),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 12),
                    decoration: BoxDecoration(
                      color: isDone
                          ? Colors.lightGreen.withOpacity(0.5)
                          : Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(t['text'] as String, style: taskText),
                        ),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text('${t['points']}', style: pointsStyle),
                            const SizedBox(width: 2),
                            const Icon(Icons.bolt_rounded, size: 20),
                          ],
                        ),
                        const SizedBox(width: 6),
                        Icon(
                          isDone
                              ? Icons.check_box_rounded
                              : Icons.check_box_outline_blank_rounded,
                          size: 28,
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// Kleiner „wachsender“ Baum
// Ersetzt deine bisherige _TreeGrowth
class _TreeGrowth extends StatelessWidget {
  const _TreeGrowth({required this.points, required this.target});

  final int points;
  final int target;

  @override
  Widget build(BuildContext context) {
    final progress = (points / target).clamp(0.0, 1.0);
    final stage = (points / 5).floor().clamp(0, 5); // 0..5 (bei Ziel 25)

    // Emojis als Platzhalter – später gern durch PNG/SVG ersetzen
    final String emoji =
    stage >= 4 ? '🌳' : stage >= 2 ? '🌿' : '🌱'; // 0–1 = Sprössling, 2–3 = Busch, 4–5 = Baum

    // Skaliert sanft mit Fortschritt
    final double size = lerpDouble(52, 86, progress)!;

    return Container(
      height: 160, // << größerer Bereich
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            const Color(0xFFEFF7EA),
            const Color(0xFFDFF0D8),
          ],
        ),
        border: Border.all(color: Colors.black.withOpacity(0.05)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Himmel-Schimmer
          Positioned.fill(
            child: IgnorePointer(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Colors.white.withOpacity(0.20),
                      Colors.white.withOpacity(0.06),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Boden
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              height: 28,
              margin: const EdgeInsets.symmetric(horizontal: 6),
              decoration: BoxDecoration(
                color: const Color(0xFFB9E0B0),
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),

          // Baum – smoothes Einblenden & Scale je Fortschritt
          Align(
            alignment: Alignment.lerp(
              const Alignment(0.0, 0.5), // tiefer am Anfang
              const Alignment(0.0, 0.2), // etwas höher „wächst“
              progress,
            )!,
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 350),
              switchInCurve: Curves.easeOutBack,
              switchOutCurve: Curves.easeIn,
              transitionBuilder: (child, anim) => ScaleTransition(
                scale: Tween<double>(begin: .92, end: 1).animate(anim),
                child: FadeTransition(opacity: anim, child: child),
              ),
              child: Text(
                emoji,
                key: ValueKey(emoji), // wechselt zwischen 🌱 / 🌿 / 🌳
                style: TextStyle(fontSize: size),
              ),
            ),
          ),

          // kleine „Ast-/Blatt“-Indikatoren (5 Punkte-Schritte)
          Positioned(
            right: 8,
            top: 8,
            child: Row(
              children: List.generate(5, (i) {
                final active = i < (points / 5).floor();
                return Padding(
                  padding: const EdgeInsets.only(left: 6),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 220),
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: active ? Colors.green.shade500 : Colors.white,
                      border: Border.all(
                        color: active
                            ? Colors.green.shade700
                            : Colors.black.withOpacity(0.08),
                      ),
                      boxShadow: active
                          ? [
                        BoxShadow(
                          color: Colors.green.shade300,
                          blurRadius: 6,
                          spreadRadius: 1,
                        )
                      ]
                          : [],
                    ),
                  ),
                );
              }),
            ),
          ),

          // Text links
          Align(
            alignment: Alignment.topLeft,
            child: Padding(
              padding: const EdgeInsets.only(top: 4, left: 2),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Dein Baum wächst',
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w800,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    points >= target
                        ? 'Maximal gewachsen 🌟'
                        : '${(progress * 100).round()}% des Tagesziels',
                    style: GoogleFonts.poppins(
                      fontSize: 12.5,
                      color: Colors.black.withOpacity(0.65),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}


class _ProgressCard extends StatelessWidget {
  const _ProgressCard({required this.current, required this.target});
  final int current;
  final int target;

  @override
  Widget build(BuildContext context) {
    final clamped = current > target ? target : current;
    final progress = target == 0 ? 0.0 : (clamped / target).clamp(0.0, 1.0);

    const barH = 22.0;
    const knobR = 8.0;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.lightGreen.withOpacity(0.5),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Blitz + Text
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.bolt_rounded, size: 28),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Erfülle Ziele um Punkte zu sammeln und lasse deine Pflanze wachsen',
                  style: GoogleFonts.poppins(
                    fontSize: 16.5,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Animierter Fortschrittsbalken
          LayoutBuilder(
            builder: (context, c) {
              final w = c.maxWidth;

              return TweenAnimationBuilder<double>(
                tween: Tween<double>(begin: 0.0, end: progress),
                duration: const Duration(milliseconds: 650),
                curve: Curves.easeInOutCubic,
                builder: (context, value, _) {
                  final knobX = (w - 2 * knobR) * value;

                  return Stack(
                    children: [
                      // Track
                      ClipRRect(
                        borderRadius: BorderRadius.circular(999),
                        child: Container(height: barH, color: Colors.white),
                      ),

                      // Füllung (animierte Breite)
                      ClipRRect(
                        borderRadius: BorderRadius.circular(999),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Container(
                            height: barH,
                            width: w * value,
                            color: Colors.green.shade400,
                          ),
                        ),
                      ),

                      // Knopf
                      Positioned(
                        left: knobX,
                        top: (barH - 2 * knobR) / 2,
                        child: AnimatedScale(
                          scale: 1.0,
                          duration: const Duration(milliseconds: 180),
                          child: Container(
                            width: 2 * knobR,
                            height: 2 * knobR,
                            decoration: BoxDecoration(
                              color: Colors.lightGreen.shade400,
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 2),
                            ),
                          ),
                        ),
                      ),

                      // Label mittig
                      Positioned.fill(
                        child: Center(
                          child: AnimatedSwitcher(
                            duration: const Duration(milliseconds: 180),
                            transitionBuilder: (child, a) =>
                                ScaleTransition(scale: a, child: child),
                            child: Text(
                              '$clamped / $target',
                              key: ValueKey(clamped),
                              style: GoogleFonts.poppins(
                                fontSize: 15.5,
                                fontWeight: FontWeight.w800,
                                color: Colors.black.withOpacity(0.85),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }
}
