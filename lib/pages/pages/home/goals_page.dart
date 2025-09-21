import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:studyproject/pages/models/AppBadge.dart';
import 'package:studyproject/pages/pages/home/badge_dex_page.dart';
import 'package:studyproject/pages/pages/home/TreeGrowth.dart';
import 'package:studyproject/pages/pages/home/SectionHeaderCard.dart';
import 'package:studyproject/pages/pages/home/progress_card.dart';

import 'package:studyproject/pages/widgets/confetti_burst.dart' show showConfettiBurst;
import 'package:studyproject/pages/widgets/task_title.dart' show TaskTile;

class GoalsPage extends StatefulWidget {
  const GoalsPage({super.key, required this.onPointsChanged});
  final ValueChanged<int> onPointsChanged;

  @override
  State<GoalsPage> createState() => GoalsPageState();
}

class GoalsPageState extends State<GoalsPage>
    with AutomaticKeepAliveClientMixin<GoalsPage>, TickerProviderStateMixin {
  final List<Map<String, dynamic>> tasks = [
    {"text": "Trenne Müll richtig", "points": 5, "emoji": "🗑️"},
    {"text": "Handypause – 3h ohne Handy", "points": 5, "emoji": "📵"},
    {"text": "Halte einer Person die Tür auf", "points": 5, "emoji": "🚪"},
    {"text": "Keine Einwegprodukte verwenden", "points": 10, "emoji": "♻️"},
    {"text": "Leitungswasser statt Plastikflasche", "points": 5, "emoji": "🚰"},
    {"text": "ÖPNV statt Auto", "points": 10, "emoji": "🚌"},
    {"text": "Kleidung spenden/reparieren", "points": 10, "emoji": "🧵"},
    {"text": "Regional kochen", "points": 10, "emoji": "🥦"},
    {"text": "Positives Feedback schreiben", "points": 5, "emoji": "💌"},
  ];

  final Set<int> _completed = {};
  static const int _dailyTarget = 25;

  int get _truePoints =>
      _completed.fold<int>(0, (sum, i) => sum + (tasks[i]['points'] as int));

  late AnimationController _counterCtrl;
  late Animation<int> _counterTween;
  int _displayPoints = 0;

  Offset? _tapPos;

  @override
  void initState() {
    super.initState();
    _counterCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )..addListener(() {
      setState(() => _displayPoints = _counterTween.value);
      widget.onPointsChanged(_displayPoints);
    });
  }

  @override
  void dispose() {
    _counterCtrl.dispose();
    super.dispose();
  }

  void _animatePoints(int from, int to) {
    _counterCtrl.stop();
    _counterTween = IntTween(begin: from, end: to).animate(
      CurvedAnimation(parent: _counterCtrl, curve: Curves.easeOutCubic),
    );
    _counterCtrl
      ..reset()
      ..forward();
  }

  void _toggleTask(int i, bool isDone) {
    final before = _displayPoints;
    setState(() {
      isDone ? _completed.remove(i) : _completed.add(i);
    });
    final after = _truePoints;
    _animatePoints(before, after);

    if (!isDone && _tapPos != null) {
      showConfettiBurst(context, _tapPos!);
    }
  }

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);

    final unlocked = demoBadges.where((b) => b.unlocked).length;
    final total = demoBadges.length;

    return Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        children: [
          TreeGrowth(points: _displayPoints, target: _dailyTarget),
          const SizedBox(height: 10),

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

          ProgressCard(current: _displayPoints, target: _dailyTarget),
          const SizedBox(height: 10),

          const SectionHeaderCard(
            icon: Icons.calendar_today,
            title: 'Tägliche Aufgaben',
          ),
          const SizedBox(height: 10),

          Expanded(
            child: ListView.separated(
              itemCount: tasks.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (context, i) {
                final t = tasks[i];
                final isDone = _completed.contains(i);
                return TaskTile(
                  title: t['text'] as String,
                  emoji: t['emoji'] as String,
                  points: t['points'] as int,
                  done: isDone,
                  onTap: () => _toggleTask(i, isDone),
                  onTapDown: (pos) => _tapPos = pos, // Tap-Position fürs Konfetti
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
