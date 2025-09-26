// lib/profil/profil/home/goals_page.dart
import 'package:flutter/material.dart';

import 'package:studyproject/pages/home/badge_dex_page.dart';
import 'package:studyproject/pages/home/tasks/TreeGrowth.dart';
import 'package:studyproject/pages/home/tasks/SectionHeaderCard.dart';
import 'package:studyproject/pages/home/tasks/progress_card.dart';
import 'package:studyproject/pages/home/tasks/confetti_burst.dart' show showConfettiBurst;
import 'package:studyproject/pages/widgets/task_title.dart' show TaskTile;
//models
import 'package:studyproject/pages/models/task.dart';

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

  final Set<int> _completed = {};
  static const int _dailyTarget = 25;

  int get _truePoints =>
      _completed.fold<int>(0, (sum, i) => sum + widget.tasks[i].points);

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

  void _toggleTask(int i) {
    final before = _displayPoints;
    setState(() {
      if (_completed.contains(i)) {
        _completed.remove(i);
      } else {
        _completed.add(i);
      }
    });
    final after = _truePoints;
    _animatePoints(before, after);

    if (_tapPos != null && !_completed.contains(i)) {
      showConfettiBurst(context, _tapPos!);
      _tapPos = null;
    }
  }

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);

    final tasksToShow = widget.tasks.take(6).toList(); // nur die ersten 6 Tasks

    return Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        children: [
          TreeGrowth(points: _displayPoints, target: _dailyTarget),
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

                return GestureDetector(
                  onTapDown: (details) => _tapPos = details.globalPosition,
                  onTap: () => _toggleTask(i),
                  child: Card(
                    color: isDone ? Colors.green[100] : Colors.white,
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // Task info
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${task.emoji} ${task.title}',
                                style: TextStyle(
                                  fontSize: 16,
                                  decoration: isDone ? TextDecoration.lineThrough : null,
                                ),
                              ),
                              if (task.co2kg > 0)
                                Text(
                                  '${task.co2kg} kg CO₂',
                                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                                ),
                            ],
                          ),
                          // Points
                          Text(
                            '+${task.points} P',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: isDone ? Colors.green : Colors.black,
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
    );
  }
}
