// lib/pages/home/tasks/goals_page.dart
import 'package:flutter/material.dart';
// import 'package:studyproject/pages/home/badge_dex_page.dart'; // (nicht genutzt)
import 'package:studyproject/pages/home/tasks/TreeGrowth.dart';
import 'package:studyproject/pages/home/tasks/SectionHeaderCard.dart';
import 'package:studyproject/pages/home/tasks/progress_card.dart';
import 'package:studyproject/pages/home/tasks/confetti_burst.dart' show showConfettiBurst;
import 'package:studyproject/pages/models/submodels/categoryTheme.dart';
import 'package:studyproject/pages/home/tree/home_tree_card.dart';

// models
import 'package:studyproject/pages/models/task.dart';

// services
import 'package:studyproject/pages/home/services/task_service.dart';

// Hintergrund wie im Profil
import 'package:studyproject/pages/intro/widgets/dailygood_profile_background.dart';

class GoalsPage extends StatefulWidget {
  const GoalsPage({
    super.key,
    required this.onPointsChanged,
    required this.tasks,
  });

  final ValueChanged<int> onPointsChanged;
  final List<Task> tasks;

  @override
  State<GoalsPage> createState() => GoalsPageState();
}

class GoalsPageState extends State<GoalsPage>
    with AutomaticKeepAliveClientMixin<GoalsPage>, SingleTickerProviderStateMixin {
  final TaskService _doTask = TaskService();
  final Set<int> _completed = {};
  static const int _dailyTarget = 25;

  int get _truePoints => _completed.fold<int>(0, (sum, i) => sum + widget.tasks[i].points);

  late final AnimationController _counterCtrl;
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

    _counterTween = IntTween(begin: 0, end: 0).animate(_counterCtrl);
  }

  @override
  void dispose() {
    _counterCtrl.dispose();
    super.dispose();
  }

  void _animatePoints(int from, int to) {
    if (from == to) return;
    _counterCtrl.stop();
    _counterTween = IntTween(begin: from, end: to).animate(
      CurvedAnimation(parent: _counterCtrl, curve: Curves.easeOutCubic),
    );
    _counterCtrl
      ..reset()
      ..forward();
  }

  void _toggleTask(int i) async {
    final before = _displayPoints;
    final task = widget.tasks[i];
    bool justCompleted = false;

    setState(() {
      if (_completed.contains(i)) {
        _completed.remove(i);
        task.isCompleted = false;
      } else {
        _completed.add(i);
        task.isCompleted = true;
        justCompleted = true;
      }
    });

    final after = _truePoints;
    _animatePoints(before, after);

    if (justCompleted) {
      try {
        await _doTask.completeTask(task);
        if (_tapPos != null) {
          showConfettiBurst(context, _tapPos!);
          _tapPos = null;
        }
      } catch (e) {
        // ignore: avoid_print
        print('Fehler beim Speichern des Tasks: $e');
      }
    }
  }

  @override
  bool get wantKeepAlive => true;

  // Pastell-Layer der Karte
  Color _cardFill(Color base, {required bool done}) {
    if (done) return const Color(0xFFEAF6ED); // soft green bei erledigt
    return base.withOpacity(0.08);             // dezenter Tint
  }

  Color _cardBorder(Color base, {required bool done}) {
    return done ? const Color(0xFFB7E0C2) : base.withOpacity(0.24);
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    final tasksToShow = widget.tasks.take(6).toList();

    return DailyGoodProfileBackground(
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            children: [
              HomeTreeCard(
                level: 3,
                totalPoints: _displayPoints,
                progress: _displayPoints / _dailyTarget,
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
                  itemCount: tasksToShow.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (context, i) {
                    final task = tasksToShow[i];
                    final isDone = _completed.contains(i);
                    final theme = CategoryTheme.themes[task.category]!;

                    final fillColor = _cardFill(theme.color, done: isDone);
                    final borderColor = _cardBorder(theme.border, done: isDone);

                    return GestureDetector(
                      onTapDown: (details) => _tapPos = details.globalPosition,
                      onTap: () => _toggleTask(i),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: const [
                            BoxShadow(
                              color: Color(0x12000000),
                              blurRadius: 10,
                              offset: Offset(0, 6),
                            ),
                          ],
                          border: Border.all(color: borderColor, width: 1),
                        ),
                        child: Container(
                          decoration: BoxDecoration(
                            color: fillColor,
                            borderRadius: BorderRadius.circular(11),
                          ),
                          padding: const EdgeInsets.all(12),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              // --- Icon-Badge: Kreis mit Border ---
                              Container(
                                width: 36,
                                height: 36,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: theme.border.withOpacity(0.10),
                                  border: Border.all(
                                    color: isDone ? const Color(0xFF8BD0A2) : theme.border,
                                    width: 1.4,
                                  ),
                                ),
                                child: Icon(
                                  theme.icon,
                                  size: 20,
                                  color: isDone ? const Color(0xFF2E7D32) : theme.border,
                                ),
                              ),

                              const SizedBox(width: 10),

                              // --- Textbereich: bekommt den verfügbaren Platz ---
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Kein Durchstreichen – nur Farbwechsel bei erledigt
                                    Text(
                                      '${task.emoji} ${task.title}',
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      softWrap: true,
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                        color: isDone
                                            ? const Color(0xFF1B5E20) // dunkler grünlicher Ton
                                            : const Color(0xFF1F2937), // neutral/dunkel
                                      ),
                                    ),
                                    if (task.co2kg > 0)
                                      Text(
                                        '${task.co2kg} kg CO₂',
                                        style: const TextStyle(
                                          fontSize: 12,
                                          color: Color(0xFF6B7280),
                                        ),
                                      ),
                                  ],
                                ),
                              ),

                              const SizedBox(width: 10),

                              // --- Punkte-Badge: keine Überläufe mehr ---
                              ConstrainedBox(
                                constraints: const BoxConstraints(minWidth: 64),
                                child: FittedBox(
                                  fit: BoxFit.scaleDown,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 6,
                                    ),
                                    decoration: BoxDecoration(
                                      color: isDone ? const Color(0xFFDEF7E6) : Colors.white,
                                      border: Border.all(
                                        color: isDone ? const Color(0xFF8BD0A2) : borderColor,
                                      ),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Text(
                                      '+${task.points} P',
                                      style: TextStyle(
                                        fontWeight: FontWeight.w800,
                                        fontSize: 15.5, // <- HIER minimal größer machen (z.B. 15.0–16.0)
                                        color: isDone ? const Color(0xFF1B5E20) : const Color(0xFF111827),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
