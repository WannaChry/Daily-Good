import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

//models
import 'package:studyproject/pages/models/task.dart';
import 'package:studyproject/pages/models/task_category.dart';
import 'package:studyproject/pages/models/submodels/categoryTheme.dart';

import 'package:studyproject/pages/second_page/subpages/task_row.dart';
import 'package:studyproject/pages/widgets/suggest_card.dart';
import 'package:studyproject/pages/second_page/subpages/kpiCard.dart';
import 'package:studyproject/pages/second_page/subpages/category_section.dart';
import 'package:studyproject/pages/second_page/subpages/co2_impact_card.dart';
import 'package:studyproject/pages/second_page/subpages/challenge_row.dart';

import 'package:studyproject/pages/constants/goals.dart';

class ActivityPage extends StatefulWidget {
  const ActivityPage({super.key, required this.totalPoints, required this.tasks,});
  final int totalPoints;
  final List<Task> tasks;

  @override
  State<ActivityPage> createState() => _ActivityPageState();
}

class _ActivityPageState extends State<ActivityPage> {

  final List<Task> _tasks = []; // aktuell leer, später kannst du echte Daten laden

  // ---------- Helpers ----------
  List<Task> get _completedTasks =>
      widget.tasks.where((t) => t.isCompleted).toList();

  int get _impactPoints =>
      _completedTasks.fold<int>(0, (sum, t) => sum + t.points);

  double get _savedCo2Kg =>
      _completedTasks.fold<double>(0.0, (sum, t) => sum + t.co2kg);

  Map<Task_category, List<Task>> get _byCategory {
    final map = <Task_category, List<Task>>{};
    for (final t in _completedTasks) {
      map.putIfAbsent(t.category, () => []).add(t);
    }
    return map;
  }

  // aktuell simple Zählung (später per Datum)
  int get _dailyProgress => _completedTasks.length;
  int get _weeklyProgress => _completedTasks.length;
  int get _monthlyProgress => _completedTasks.length;

  void _toggleTask(Task t) {
    HapticFeedback.selectionClick();
    setState(() => t.isCompleted = !t.isCompleted);
  }

  // Vorschlagsfeld
  final TextEditingController _suggestCtrl = TextEditingController();

  void _submitSuggestion() {
    final text = _suggestCtrl.text.trim();
    if (text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Bitte gib einen Vorschlag ein.')),
      );
      return;
    }
    HapticFeedback.lightImpact();
    _suggestCtrl.clear();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Danke! Vorschlag gesendet: "$text"')),
    );
  }

  @override
  void dispose() {
    _suggestCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final textTitle = GoogleFonts.poppins(
      fontSize: 16,
      fontWeight: FontWeight.w800,
      color: Colors.black87,
    );

    return Padding(
      padding: const EdgeInsets.all(16),
      child: ListView(
        children: [
          // ---------- KPI-Karten ----------
          Column(
            children: [
              KpiCard(
                title: 'Impact-Punkte',
                value: _impactPoints.toString(),
                subtitle: 'Summe erledigter Tasks',
                emoji: '✨',
                progress: (_impactPoints / 200).clamp(0.0, 1.0),
              ),
              const SizedBox(height: 14),
              Co2ImpactCard(
                savedKg: _savedCo2Kg,
                monthlyGoalKg: Goals.co2MonthlyGoalKg,
              ),
            ],
          ),
          const SizedBox(height: 14),

          // ---------- Challenges ----------
          Text('Challenges', style: textTitle),
          const SizedBox(height: 8),
          ChallengeRow(
            dailyProgress: _dailyProgress,
            weeklyProgress: _weeklyProgress,
            monthlyProgress: _monthlyProgress,
            dailyTarget: Goals.dailyTarget,
            weeklyTarget: Goals.weeklyTarget,
            monthlyTarget: Goals.monthlyTarget,
          ),
          const SizedBox(height: 16),

          // ---------- Kategorien ----------
          Text('Aufgaben nach Kategorien', style: textTitle),
          const SizedBox(height: 8),
          ...Task_category.values.map((category) {
            final theme = CategoryTheme.themes[category] ??
                const CategoryTheme(color: Colors.white, border: Colors.black12, icon: Icons.category_rounded);
            return CategorySection(
              name: category.name,
              tasks: _completedTasks.where((t) => t.category == category).toList(),
              onToggle: _toggleTask,
              theme: theme,
            );
          }),

          const SizedBox(height: 18),

          // ---------- Eigene Aufgaben vorschlagen ----------
          Text('Eigene Aufgaben vorschlagen', style: textTitle),
          const SizedBox(height: 8),
          SuggestCard(
            controller: _suggestCtrl,
            onSubmit: _submitSuggestion,
          ),

          const SizedBox(height: 80),
        ],
      ),
    );
  }
}