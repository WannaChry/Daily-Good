import 'package:studyproject/pages/models/post.dart';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:studyproject/pages/models/AppBadge.dart';
import 'package:studyproject/pages/pages/home/badge_dex_page.dart';
import 'package:studyproject/pages/pages/home/TreeGrowth.dart';
import 'package:studyproject/pages/pages/home/home.dart';
import 'package:studyproject/pages/pages/home/SectionHeaderCard.dart';

// ==================== Tab 1: Ziele (Home) ====================
class GoalsPage extends StatefulWidget {
  const GoalsPage({super.key, required this.onPointsChanged});
  final ValueChanged<int> onPointsChanged;

  @override
  State<GoalsPage> createState() => GoalsPageState();
}

class GoalsPageState extends State<GoalsPage>
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

    final unlocked = demoBadges.where((b) => b.unlocked).length;
    final total = demoBadges.length;

    return Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        children: [
          // 1) Baum
          TreeGrowth(points: _currentPoints, target: _dailyTarget),
          const SizedBox(height: 10),

          // 2) NEU: Abzeichen-Kachel direkt unter dem Baum
          BadgeEntryTile(
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
          ProgressCard(current: _currentPoints, target: _dailyTarget),
          const SizedBox(height: 10),

          // 4) Section-Header „Tägliche Aufgaben“
          SectionHeaderCard(
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