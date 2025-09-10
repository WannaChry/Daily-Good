// lib/pages/pages/home.dart
import 'dart:ui' show lerpDouble;
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

// ==================== Tab 1: Ziele (Home) ====================
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

    final unlocked = _demoBadges.where((b) => b.unlocked).length;
    final total = _demoBadges.length;

    return Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        children: [
          // 1) Baum
          _TreeGrowth(points: _currentPoints, target: _dailyTarget),
          const SizedBox(height: 10),

          // 2) NEU: Abzeichen-Kachel direkt unter dem Baum
          _BadgeEntryTile(
            unlockedCount: unlocked,
            totalCount: total,
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const BadgeDexPage()),
              );
            },
          ),
          const SizedBox(height: 10),

          // 3) Progress-Card
          _ProgressCard(current: _currentPoints, target: _dailyTarget),
          const SizedBox(height: 10),

          // 4) Section-Header „Tägliche Aufgaben“
          _SectionHeaderCard(
            icon: Icons.calendar_today,
            title: 'Tägliche Aufgaben',
            onTap: null,
          ),
          const SizedBox(height: 10),

          // 5) Task-Liste
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
                          ? Colors.lightGreen.withValues(alpha: 0.28)
                          : Colors.black.withValues(alpha: 0.06),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: Colors.black.withValues(alpha: 0.05),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.04),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
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

// ---------- Section-Header-Card ----------
class _SectionHeaderCard extends StatelessWidget {
  const _SectionHeaderCard({
    required this.icon,
    required this.title,
    this.onTap,
  });

  final IconData icon;
  final String title;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: Colors.black.withOpacity(0.06)),
            boxShadow: const [
              BoxShadow(
                color: Color(0x14000000),
                blurRadius: 10,
                offset: Offset(0, 6),
              )
            ],
          ),
          child: Row(
            children: [
              Icon(icon, size: 28),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              if (onTap != null) const Icon(Icons.chevron_right, size: 22),
            ],
          ),
        ),
      ),
    );
  }
}

// ---------- Badge-Entry-Tile ----------
class _BadgeEntryTile extends StatelessWidget {
  const _BadgeEntryTile({
    required this.unlockedCount,
    required this.totalCount,
    required this.onTap,
  });

  final int unlockedCount;
  final int totalCount;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xFFE0D4FF),
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFD7C7FF)),
          ),
          child: Row(
            children: [
              const Icon(Icons.workspace_premium_rounded, size: 28),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Abzeichen',
                  style: GoogleFonts.poppins(
                      fontSize: 16, fontWeight: FontWeight.w800),
                ),
              ),
              Container(
                padding:
                const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(color: Colors.black.withOpacity(0.06)),
                ),
                child: Text(
                  '$unlockedCount / $totalCount',
                  style: GoogleFonts.poppins(
                      fontSize: 13, fontWeight: FontWeight.w800),
                ),
              ),
              const SizedBox(width: 6),
              const Icon(Icons.chevron_right, size: 22),
            ],
          ),
        ),
      ),
    );
  }
}

// ==================== „BadgeDex“-Seite (Vollbild) ====================
class BadgeDexPage extends StatelessWidget {
  const BadgeDexPage({super.key});

  @override
  Widget build(BuildContext context) {
    final unlockedCount = _demoBadges.where((b) => b.unlocked).length;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        title: Text(
          'Abzeichen  •  $unlockedCount / ${_demoBadges.length}',
          style:
          GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w800),
        ),
        centerTitle: true,
        elevation: 0,
      ),
      backgroundColor: const Color(0xFFF8F3FA),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
        child: GridView.builder(
          itemCount: _demoBadges.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 0.82,
          ),
          itemBuilder: (_, i) => _BadgeCell(badge: _demoBadges[i]),
        ),
      ),
    );
  }
}

class _BadgeCell extends StatelessWidget {
  const _BadgeCell({required this.badge});
  final Badge badge;

  Color _rarityBorder() {
    switch (badge.rarity) {
      case BadgeRarity.common:
        return Colors.black.withOpacity(0.10);
      case BadgeRarity.rare:
        return Colors.blueAccent.withOpacity(0.45);
      case BadgeRarity.epic:
        return Colors.purple.withOpacity(0.45);
      case BadgeRarity.legendary:
        return Colors.orange.withOpacity(0.55);
    }
  }

  @override
  Widget build(BuildContext context) {
    final locked = !badge.unlocked;

    return InkWell(
      onTap: () => showModalBottomSheet(
        context: context,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
        ),
        builder: (_) => _BadgeDetailSheet(badge: badge),
      ),
      borderRadius: BorderRadius.circular(14),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: _rarityBorder()),
          boxShadow: const [
            BoxShadow(
              color: Color(0x14000000),
              blurRadius: 10,
              offset: Offset(0, 6),
            )
          ],
        ),
        padding: const EdgeInsets.all(10),
        child: Column(
          children: [
            // Icon-Kreis
            Container(
              height: 58,
              width: 58,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const LinearGradient(
                  colors: [Color(0xFFF7FBF5), Color(0xFFEFF7EA)],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
                border: Border.all(color: Colors.black12),
              ),
              alignment: Alignment.center,
              child: Icon(
                badge.icon,
                size: 28,
                color: locked ? Colors.black26 : Colors.green.shade700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              badge.title,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.poppins(
                fontSize: 12.5,
                fontWeight: FontWeight.w800,
                color: locked ? Colors.black38 : Colors.black87,
              ),
            ),
            const Spacer(),
            // Lock / Unlocked Indicator
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  locked ? Icons.lock_outline_rounded : Icons.check_circle_rounded,
                  size: 16,
                  color: locked ? Colors.black26 : Colors.green,
                ),
                const SizedBox(width: 4),
                Text(
                  locked ? 'Gesperrt' : 'Freigeschaltet',
                  style: GoogleFonts.poppins(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w700,
                    color: locked ? Colors.black38 : Colors.green.shade700,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _BadgeDetailSheet extends StatelessWidget {
  const _BadgeDetailSheet({required this.badge});
  final Badge badge;

  @override
  Widget build(BuildContext context) {
    final locked = !badge.unlocked;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 44,
            height: 5,
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              color: Colors.black12,
              borderRadius: BorderRadius.circular(999),
            ),
          ),
          Text(
            badge.title,
            style:
            GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(
                badge.icon,
                size: 28,
                color: locked ? Colors.black26 : Colors.green.shade700,
              ),
              const SizedBox(width: 8),
              Text(
                _rarityText(badge.rarity),
                style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w700,
                    color: Colors.black.withOpacity(0.7)),
              ),
              const Spacer(),
              Container(
                padding:
                const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: locked ? Colors.black.withOpacity(0.06) : Colors.green.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  locked ? 'Gesperrt' : 'Freigeschaltet',
                  style: GoogleFonts.poppins(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w800,
                      color: locked ? Colors.black54 : Colors.green.shade700),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              badge.description,
              style: GoogleFonts.poppins(
                fontSize: 13.5,
                fontWeight: FontWeight.w600,
                color: Colors.black54,
              ),
            ),
          ),
          const SizedBox(height: 8),
          if (badge.progress != null)
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Fortschritt: ${badge.progress!.current} / ${badge.progress!.target}',
                style: GoogleFonts.poppins(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }

  static String _rarityText(BadgeRarity r) {
    switch (r) {
      case BadgeRarity.common:
        return 'Gewöhnlich';
      case BadgeRarity.rare:
        return 'Selten';
      case BadgeRarity.epic:
        return 'Episch';
      case BadgeRarity.legendary:
        return 'Legendär';
    }
  }
}

// ==================== Badge-Model (Demo) ====================
class Badge {
  final String title;
  final String description;
  final IconData icon;
  final BadgeRarity rarity;
  final bool unlocked;
  final BadgeProgress? progress;

  const Badge({
    required this.title,
    required this.description,
    required this.icon,
    required this.rarity,
    required this.unlocked,
    this.progress,
  });
}

class BadgeProgress {
  final int current;
  final int target;
  const BadgeProgress(this.current, this.target);
}

enum BadgeRarity { common, rare, epic, legendary }

// Demo-Badges – später aus State/Firebase
const List<Badge> _demoBadges = [
  Badge(
    title: 'Erster Schritt',
    description: 'Erledige deine erste Aufgabe.',
    icon: Icons.check_circle_rounded,
    rarity: BadgeRarity.common,
    unlocked: true,
    progress: BadgeProgress(1, 1),
  ),
  Badge(
    title: 'Umweltfreundlich',
    description: 'Spare 5 kg CO₂ in einem Monat.',
    icon: Icons.eco_rounded,
    rarity: BadgeRarity.rare,
    unlocked: false,
    progress: BadgeProgress(2, 5),
  ),
  Badge(
    title: 'Sozial aktiv',
    description: 'Erledige 10 soziale Aufgaben.',
    icon: Icons.group_rounded,
    rarity: BadgeRarity.common,
    unlocked: true,
    progress: BadgeProgress(10, 10),
  ),
  Badge(
    title: 'Konzentrationsmeister',
    description: '3× Deep-Work in einer Woche.',
    icon: Icons.bolt_rounded,
    rarity: BadgeRarity.rare,
    unlocked: false,
    progress: BadgeProgress(1, 3),
  ),
  Badge(
    title: 'Achtsamkeits-Profi',
    description: 'Meditiere an 7 Tagen in Folge.',
    icon: Icons.self_improvement_rounded,
    rarity: BadgeRarity.epic,
    unlocked: false,
    progress: BadgeProgress(3, 7),
  ),
  Badge(
    title: 'Pendlerheld',
    description: 'Fahre 5× mit dem Rad statt Auto.',
    icon: Icons.directions_bike_rounded,
    rarity: BadgeRarity.common,
    unlocked: true,
    progress: BadgeProgress(5, 5),
  ),
  Badge(
    title: 'Wasser statt Plastik',
    description: '10× Leitungswasser statt Plastikflasche.',
    icon: Icons.local_drink_rounded,
    rarity: BadgeRarity.common,
    unlocked: false,
    progress: BadgeProgress(6, 10),
  ),
  Badge(
    title: 'Bücherwurm',
    description: 'Lies 5× 30 Minuten in einer Woche.',
    icon: Icons.menu_book_rounded,
    rarity: BadgeRarity.rare,
    unlocked: false,
    progress: BadgeProgress(2, 5),
  ),
  Badge(
    title: 'Gewohnheits-Champion',
    description: '10 Tage in Folge mindestens 3 Tasks.',
    icon: Icons.stars_rounded,
    rarity: BadgeRarity.legendary,
    unlocked: false,
    progress: BadgeProgress(4, 10),
  ),
  Badge(
    title: 'Hydro-Hero',
    description: 'Trinke 2 Liter Wasser an 7 Tagen.',
    icon: Icons.opacity_rounded,
    rarity: BadgeRarity.common,
    unlocked: false,
    progress: BadgeProgress(3, 7),
  ),
  Badge(
    title: 'Reflexions-Master',
    description: 'Schreibe 5 Reflexionen.',
    icon: Icons.edit_note_rounded,
    rarity: BadgeRarity.rare,
    unlocked: false,
    progress: BadgeProgress(1, 5),
  ),
  Badge(
    title: 'Community-Star',
    description: 'Tritt einer Community bei und poste.',
    icon: Icons.forum_rounded,
    rarity: BadgeRarity.epic,
    unlocked: false,
  ),
];

// ==================== Vorhandene Widgets: Baum + Progress ====================
class _TreeGrowth extends StatelessWidget {
  const _TreeGrowth({required this.points, required this.target});

  final int points;
  final int target;

  @override
  Widget build(BuildContext context) {
    final progress = (points / target).clamp(0.0, 1.0);
    final stage = (points / 5).floor().clamp(0, 5); // 0..5 (bei Ziel 25)

    final String emoji =
    stage >= 4 ? '🌳' : stage >= 2 ? '🌿' : '🌱';

    final double size = lerpDouble(52, 86, progress)!;

    return Container(
      height: 160,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFFEFF7EA),
            Color(0xFFDFF0D8),
          ],
        ),
        border: Border.all(color: Colors.black12),
        boxShadow: const [
          BoxShadow(
            color: Color(0x10000000),
            blurRadius: 14,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Stack(
        children: [
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
          Align(
            alignment: Alignment.lerp(
              const Alignment(0.0, 0.5),
              const Alignment(0.0, 0.2),
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
                key: ValueKey(emoji),
                style: TextStyle(fontSize: size),
              ),
            ),
          ),
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
                      ClipRRect(
                        borderRadius: BorderRadius.circular(999),
                        child: Container(height: barH, color: Colors.white),
                      ),
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
