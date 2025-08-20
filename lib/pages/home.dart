// lib/pages/home.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:studyproject/pages/ButtonsReaktion.dart';
import 'package:studyproject/pages/bottom_nav_only.dart'; // enthält deine NavBar

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0;

  // Falls GoalsPage in einer anderen Datei liegt, darauf achten, dass sie importiert ist.
  late final List<Widget> _pages = const [
    GoalsPage(),                        // Tab 1
    Center(child: Text('Seite 2')),
    Center(child: Text('Seite 3')),
    Center(child: Text('Seite 4')),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F3FA),

      // ---------- AppBar oben (weiß) ----------
      appBar: AppBar(
        backgroundColor: Colors.white,             // <— jetzt weiß
        elevation: 0,                               // kein Schatten
        scrolledUnderElevation: 0,
        centerTitle: true,
        toolbarHeight: 72,
        systemOverlayStyle: SystemUiOverlayStyle.dark, // dunkle Statusbar-Icons

        leading: ReactiveSvgButton(
          asset: 'assets/icons/menu-svgrepo-com.svg',
          size: 32,
          padding: const EdgeInsets.only(left: 12, top: 8),
          color: Colors.black,
          onTap: () => debugPrint('Menü geklickt'),
        ),

        title: ReactiveSvgButton(
          asset: 'assets/icons/lightbulb-bolt-svgrepo-com.svg',
          size: 40,
          padding: const EdgeInsets.only(top: 8),
          rotateOnTap: true,
          color: Colors.black,
          onTap: () => debugPrint('Glühbirne geklickt'),
        ),

        actions: [
          ReactiveSvgButton(
            asset: 'assets/icons/checkbox-unchecked-svgrepo-com.svg',
            size: 36,
            padding: const EdgeInsets.only(right: 12, top: 8),
            color: Colors.black,
            onTap: () => debugPrint('Box geklickt'),
          ),
        ],
      ),

      // ---------- Body: Seite je nach Tab ----------
      body: _pages[_currentIndex],

      // ---------- NavBar unten (grün, aus deiner NavBar-Klasse) ----------
      bottomNavigationBar: NavBar(
        currentIndex: _currentIndex,
        onTap: (i) => setState(() => _currentIndex = i),
      ),
    );
  }
}


// ==================== Tab 1: Ziele – Styling wie im Screenshot ====================

class GoalsPage extends StatefulWidget {
  const GoalsPage({super.key});

  @override
  State<GoalsPage> createState() => _GoalsPageState();
}

class _GoalsPageState extends State<GoalsPage> {
  final List<Map<String, dynamic>> tasks = [
    {"text": "Trenne Müll richtig", "points": 5},
    {"text": "Handypause - 3h ohne Handy", "points": 5},
    {"text": "Halte einer Person die Tür auf", "points": 5},
    {"text": "Keine Einwegprodukte verwenden", "points": 10},
  ];

  final Set<int> _completed = {};
  static const int _dailyTarget = 20;

  int get _currentPoints =>
      _completed.fold<int>(0, (sum, i) => sum + (tasks[i]['points'] as int));

  @override
  Widget build(BuildContext context) {
    // Typografie
    final smallTitle =
    GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w700);
    final taskText =
    GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600);
    final pointsStyle =
    GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w800);

    return Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        children: [
          const Spacer(),

          // ------- Fortschrittskarte (oben) -------
          _ProgressCard(current: _currentPoints, target: _dailyTarget),
          const SizedBox(height: 10),

          // ------- „7 Ziele …“ -------
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8), // flacher
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              children: [
                SvgPicture.asset(
                  'assets/icons/calculator-svgrepo-com.svg',
                  width: 33, height: 33,
                  colorFilter:
                  const ColorFilter.mode(Colors.black, BlendMode.srcIn),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text('7 Ziele für heute noch übrig', style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                  ),
                ),
                // Filter-Icon (wie im Screenshot rechts)
                const Icon(Icons.tune, size: 30, color: Colors.black),
              ],
            ),
          ),
          const SizedBox(height: 10),

          // ------- Aufgabenliste -------
          SafeArea(
            top: false,
            minimum: const EdgeInsets.only(bottom: 8),
            child: ListView.separated(
              physics: const NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              itemCount: tasks.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (context, i) {
                final t = tasks[i];
                final isDone = _completed.contains(i);

                return InkWell(
                  borderRadius: BorderRadius.circular(16),
                  onTap: () {
                    setState(() {
                      isDone ? _completed.remove(i) : _completed.add(i);
                    });
                    // Optional: kleines haptisches Feedback
                    // HapticFeedback.lightImpact();
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    curve: Curves.easeOut,
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    decoration: BoxDecoration(
                      color: isDone ? Colors.lightGreen.withOpacity(0.5) : Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      children: [
                        // Text links
                        Expanded(
                          child: Text(t['text'] as String, style: taskText),
                        ),

                        // Punkte + ⚡ (mit Mikro-Animationen)
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Punkte: kleiner "Bump" beim Abhaken
                            TweenAnimationBuilder<double>(
                              tween: Tween(begin: 1.0, end: isDone ? 1.08 : 1.0),
                              duration: const Duration(milliseconds: 180),
                              curve: Curves.easeOutBack,
                              builder: (_, scale, child) => Transform.scale(scale: scale, child: child),
                              child: Text('${t['points']}', style: pointsStyle),
                            ),
                            const SizedBox(width: 2),

                            // Blitz: ohne Drehung
                            SvgPicture.asset(
                              'assets/icons/thunder2-svgrepo-com.svg',
                              width: 20,
                              height: 20,
                              colorFilter: const ColorFilter.mode(Colors.black, BlendMode.srcIn),
                            ),
                          ],
                        ),

                        const SizedBox(width: 2), // kleiner Abstand zur Checkbox

                        // Checkbox: "Pop"-Effekt beim Toggle
                        SizedBox(
                          width: 34,
                          height: 34,
                          child: Center(
                            child: AnimatedScale(
                              scale: isDone ? 1.1 : 1.0,
                              duration: const Duration(milliseconds: 160),
                              child: AnimatedSwitcher(
                                duration: const Duration(milliseconds: 140),
                                child: SvgPicture.asset(
                                  isDone
                                      ? 'assets/icons/checkmark-square-svgrepo-com.svg'
                                      : 'assets/icons/checkbox-unchecked-svgrepo-com.svg',
                                  key: ValueKey<bool>(isDone),
                                  width: 28,
                                  height: 28,
                                  colorFilter: const ColorFilter.mode(Colors.black, BlendMode.srcIn),
                                ),
                              ),
                            ),
                          ),
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

class _ProgressCard extends StatelessWidget {
  const _ProgressCard({
    required this.current,
    required this.target,
  });

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
        color: Colors.lightGreen.withOpacity(0.5), // 70% Deckkraft
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Blitz + Text nebeneinander
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SvgPicture.asset(
                'assets/icons/thunder2-svgrepo-com.svg',
                width: 20,
                height: 44,
                colorFilter:
                const ColorFilter.mode(Colors.black, BlendMode.srcIn),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Erfülle Ziele um Punkte zu sammeln und lasse deine Pflanze wachsen',
                  textAlign: TextAlign.justify,
                  style: GoogleFonts.poppins(
                    fontSize: 16.5,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),


          // Fortschrittsbalken – volle Breite (animiert)
          LayoutBuilder(
            builder: (context, c) {
              final w = c.maxWidth;

              return TweenAnimationBuilder<double>(
                // animiert vom alten zum neuen progress
                tween: Tween<double>(begin: 0.0, end: progress),
                duration: const Duration(milliseconds: 650),
                curve: Curves.easeInOutCubic,
                builder: (context, value, _) {
                  final knobX = (w - 2 * knobR) * value;

                  return Stack(
                    children: [
                      // weißer Track
                      ClipRRect(
                        borderRadius: BorderRadius.circular(999),
                        child: Container(height: barH, color: Colors.white),
                      ),

                      // grüne Füllung (animierte Breite)
                      ClipRRect(
                        borderRadius: BorderRadius.circular(999),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Container(
                            height: barH,
                            width: w * value, // <- animiert
                            color: Colors.green.shade300,
                          ),
                        ),
                      ),

                      // Knopf (kann leicht „poppen“, wenn du willst)
                      Positioned(
                        left: knobX,
                        top: (barH - 2 * knobR) / 2,
                        child: AnimatedScale(
                          scale: 1.0, // z.B. 1.05 für mini-Bounce
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

                      // „x / target“ mittig (wechselt smooth)
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

