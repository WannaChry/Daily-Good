import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

//models
import 'package:studyproject/pages/models/task.dart';
import 'package:studyproject/pages/models/task_category.dart';
import 'package:studyproject/pages/models/submodels/categoryTheme.dart';

import 'package:studyproject/pages/widgets/task_row.dart';
import 'package:studyproject/pages/widgets/suggest_card.dart';
import 'package:studyproject/pages/widgets/kpiCard.dart';
import 'package:studyproject/pages/widgets/category_section.dart';
import 'package:studyproject/pages/widgets/co2_impact_card.dart';
import 'package:studyproject/pages/widgets/challenge_row.dart';

class ActivityPage extends StatefulWidget {
  const ActivityPage({super.key, required this.totalPoints});
  final int totalPoints;

  @override
  State<ActivityPage> createState() => _ActivityPageState();
}

class _ActivityPageState extends State<ActivityPage> {
  // ---------- Demo-Daten ----------
  final List<Task> _tasks = []; // aktuell leer, später kannst du echte Daten laden

  // Challenge-Ziele (frei anpassbar)
  static const int dailyTarget = 3;
  static const int weeklyTarget = 15;
  static const int monthlyTarget = 50;

  // CO2 Monatsziel (kg CO2)
  static const double co2MonthlyGoalKg = 20.0;

  // ---------- Helpers ----------
  List<Task> get _completedTasks => _tasks.where((t) => t.isCompleted).toList();

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
              _Co2ImpactCard(
                savedKg: _savedCo2Kg,
                monthlyGoalKg: co2MonthlyGoalKg,
              ),
            ],
          ),
          const SizedBox(height: 14),

          // ---------- Challenges ----------
          Text('Challenges', style: textTitle),
          const SizedBox(height: 8),
          _ChallengeRow(
            dailyProgress: _dailyProgress,
            weeklyProgress: _weeklyProgress,
            monthlyProgress: _monthlyProgress,
            dailyTarget: dailyTarget,
            weeklyTarget: weeklyTarget,
            monthlyTarget: monthlyTarget,
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

/* ============================================================================
 *  Zusätzliche Widgets (Co2Card & Challenges)
 * ==========================================================================*/

class _Co2ImpactCard extends StatelessWidget {
  const _Co2ImpactCard({
    required this.savedKg,
    required this.monthlyGoalKg,
  });

  final double savedKg;
  final double monthlyGoalKg;

  @override
  Widget build(BuildContext context) {
    final p = (savedKg / monthlyGoalKg).clamp(0.0, 1.0);
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFFEFF7EA), Color(0xFFDFF0D8)],
        ),
        border: Border.all(color: Colors.black12),
        boxShadow: const [BoxShadow(color: Color(0x1A000000), blurRadius: 12, offset: Offset(0, 6))],
      ),
      child: Row(
        children: [
          SizedBox(
            width: 84,
            height: 84,
            child: Stack(
              fit: StackFit.expand,
              children: [
                CircularProgressIndicator(
                  value: p,
                  strokeWidth: 10,
                  backgroundColor: Colors.white,
                  valueColor: const AlwaysStoppedAnimation<Color>(Colors.green),
                ),
                Center(
                  child: Text(
                    '${(p * 100).round()}%',
                    style: GoogleFonts.poppins(fontWeight: FontWeight.w800, fontSize: 16),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('CO₂-Impact diesen Monat',
                    style: GoogleFonts.poppins(fontWeight: FontWeight.w800, fontSize: 16)),
                const SizedBox(height: 4),
                Text(
                  'Eingespart: ${savedKg.toStringAsFixed(2)} kg  •  Ziel: ${monthlyGoalKg.toStringAsFixed(0)} kg',
                  style: GoogleFonts.poppins(fontSize: 12.5, fontWeight: FontWeight.w600, color: Colors.black54),
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(999),
                  child: LinearProgressIndicator(
                    value: p,
                    minHeight: 14,
                    backgroundColor: Colors.white,
                    color: Colors.green.shade400,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ChallengeRow extends StatelessWidget {
  const _ChallengeRow({
    required this.dailyProgress,
    required this.weeklyProgress,
    required this.monthlyProgress,
    required this.dailyTarget,
    required this.weeklyTarget,
    required this.monthlyTarget,
  });

  final int dailyProgress;
  final int weeklyProgress;
  final int monthlyProgress;
  final int dailyTarget;
  final int weeklyTarget;
  final int monthlyTarget;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: _ChallengeCard(title: 'Tages-Challenge', emoji: '⚡️', progress: dailyProgress, target: dailyTarget)),
        const SizedBox(width: 10),
        Expanded(child: _ChallengeCard(title: 'Wochen-Challenge', emoji: '📅', progress: weeklyProgress, target: weeklyTarget)),
        const SizedBox(width: 10),
        Expanded(child: _ChallengeCard(title: 'Monats-Challenge', emoji: '🏆', progress: monthlyProgress, target: monthlyTarget)),
      ],
    );
  }
}

class _ChallengeCard extends StatelessWidget {
  const _ChallengeCard({
    required this.title,
    required this.emoji,
    required this.progress,
    required this.target,
  });

  final String title;
  final String emoji;
  final int progress;
  final int target;

  @override
  Widget build(BuildContext context) {
    final p = (progress / target).clamp(0.0, 1.0);
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.black.withOpacity(0.06)),
        boxShadow: const [BoxShadow(color: Color(0x14000000), blurRadius: 10, offset: Offset(0, 6))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('$emoji  $title', style: GoogleFonts.poppins(fontWeight: FontWeight.w800, fontSize: 14)),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              value: p,
              minHeight: 12,
              backgroundColor: Colors.grey.shade200,
              color: Colors.green.shade600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '$progress / $target',
            style: GoogleFonts.poppins(fontWeight: FontWeight.w900, fontSize: 16),
          ),
        ],
      ),
    );
  }
}
