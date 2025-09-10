import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

class ActivityPage extends StatefulWidget {
  const ActivityPage({super.key, required this.totalPoints});
  final int totalPoints;

  @override
  State<ActivityPage> createState() => _ActivityPageState();
}

class _ActivityPageState extends State<ActivityPage> {
  // ---------- Demo-Daten ----------
  final List<ActivityTask> _tasks = [
    // Sozial 🌍
    ActivityTask(category: 'Sozial', title: 'Jemandem helfen', points: 5, co2Kg: 0),
    ActivityTask(category: 'Sozial', title: 'Danke-Nachricht senden', points: 5, co2Kg: 0),
    ActivityTask(category: 'Sozial', title: 'Zeit mit Familie/Freunden', points: 10, co2Kg: 0),

    // Ökologisch 🌱
    ActivityTask(category: 'Ökologisch', title: 'Fahrrad statt Auto', points: 10, co2Kg: 2.0),
    ActivityTask(category: 'Ökologisch', title: 'Leitungswasser statt Plastik', points: 5, co2Kg: 0.1),
    ActivityTask(category: 'Ökologisch', title: 'Müll vermeiden / Mehrweg', points: 10, co2Kg: 0.5),

    // Gesundheit 💪
    ActivityTask(category: 'Gesundheit', title: '10.000 Schritte', points: 10, co2Kg: 0),
    ActivityTask(category: 'Gesundheit', title: 'Atemübung 5 Min', points: 5, co2Kg: 0),
    ActivityTask(category: 'Gesundheit', title: '2 Liter Wasser trinken', points: 5, co2Kg: 0),

    // Achtsamkeit 🧘
    ActivityTask(category: 'Achtsamkeit', title: '10 Min Meditation', points: 5, co2Kg: 0),
    ActivityTask(category: 'Achtsamkeit', title: 'Reflexion schreiben', points: 5, co2Kg: 0),
    ActivityTask(category: 'Achtsamkeit', title: '30 Min lesen', points: 10, co2Kg: 0),

    // Produktivität ✅
    ActivityTask(category: 'Produktivität', title: 'Deep-Work 30 Min', points: 10, co2Kg: 0),
    ActivityTask(category: 'Produktivität', title: 'Inbox Zero', points: 5, co2Kg: 0),
    ActivityTask(category: 'Produktivität', title: 'To-Do Liste geplant', points: 5, co2Kg: 0),

    // Lernen 📚
    ActivityTask(category: 'Lernen', title: '1 Kapitel Fachbuch', points: 10, co2Kg: 0),
    ActivityTask(category: 'Lernen', title: 'Kurzer Online-Kurs', points: 10, co2Kg: 0),
    ActivityTask(category: 'Lernen', title: 'Notizen wiederholen', points: 5, co2Kg: 0),

    // Personalisierte Aufgaben ⭐ (neu)
    ActivityTask(category: 'Personalisierte Aufgaben', title: '10 Min spazieren gehen', points: 5, co2Kg: 0),
    ActivityTask(category: 'Personalisierte Aufgaben', title: '15 Min Hobby-Zeit', points: 5, co2Kg: 0),
    ActivityTask(category: 'Personalisierte Aufgaben', title: '3 Tagesziele notieren', points: 5, co2Kg: 0),
  ];

  // Challenge-Ziele (frei anpassbar)
  static const int dailyTarget = 3;
  static const int weeklyTarget = 15;
  static const int monthlyTarget = 50;

  // CO2 Monatsziel (kg CO2)
  static const double co2MonthlyGoalKg = 20.0;

  // Kategorie-Theme (Farben & Icons)
  final Map<String, CategoryTheme> categoryTheme = {
    'Sozial': CategoryTheme(color: Color(0xFFE8F4FF), border: Color(0xFFB3DAFF), icon: Icons.group_rounded),
    'Ökologisch': CategoryTheme(color: Color(0xFFEFF7EA), border: Color(0xFFB8E2B0), icon: Icons.eco_rounded),
    'Gesundheit': CategoryTheme(color: Color(0xFFFFF3E0), border: Color(0xFFFFD59B), icon: Icons.fitness_center_rounded),
    'Achtsamkeit': CategoryTheme(color: Color(0xFFF4ECFF), border: Color(0xFFD7C7FF), icon: Icons.self_improvement_rounded),
    'Produktivität': CategoryTheme(color: Color(0xFFFFEEF0), border: Color(0xFFF8B8C1), icon: Icons.task_alt_rounded),
    'Lernen': CategoryTheme(color: Color(0xFFEFF3FF), border: Color(0xFFBECDFE), icon: Icons.menu_book_rounded),

    // Neu: Personalisierte Aufgaben – Pastellrosé
    'Personalisierte Aufgaben': CategoryTheme(
      color: Color(0xFFFFF1F4),
      border: Color(0xFFFFD6DE),
      icon: Icons.auto_awesome_rounded,
    ),
  };

  // ---------- Helpers ----------
  int get _completedCount => _tasks.where((t) => t.done).length;

  int get _impactPoints =>
      _tasks.where((t) => t.done).fold<int>(0, (sum, t) => sum + t.points);

  double get _savedCo2Kg =>
      _tasks.where((t) => t.done).fold<double>(0.0, (sum, t) => sum + t.co2Kg);

  Map<String, List<ActivityTask>> get _byCategory {
    final map = <String, List<ActivityTask>>{};
    for (final t in _tasks) {
      map.putIfAbsent(t.category, () => []).add(t);
    }
    return map;
  }

  // aktuell simple Zählung (später per Datum)
  int get _dailyProgress => _completedCount;
  int get _weeklyProgress => _completedCount;
  int get _monthlyProgress => _completedCount;

  void _toggleTask(ActivityTask t) {
    HapticFeedback.selectionClick();
    setState(() => t.done = !t.done);
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
          // ---------- KPI-Karten untereinander ----------
          Column(
            children: [
              _KpiCard(
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
          ..._byCategory.entries.map((e) {
            final theme = categoryTheme[e.key] ??
                const CategoryTheme(color: Colors.white, border: Colors.black12, icon: Icons.category_rounded);
            return _CategorySection(
              name: e.key,
              tasks: e.value,
              onToggle: _toggleTask,
              theme: theme,
            );
          }),

          const SizedBox(height: 18),

          // ---------- Eigene Aufgaben vorschlagen (neu) ----------
          Text('Eigene Aufgaben vorschlagen', style: textTitle),
          const SizedBox(height: 8),
          _SuggestCard(
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
 *  MODELS
 * ==========================================================================*/
class ActivityTask {
  ActivityTask({
    required this.category,
    required this.title,
    required this.points,
    required this.co2Kg,
    this.done = false,
  });

  final String category;
  final String title;
  final int points;
  final double co2Kg; // > 0 nur bei ökologischen Tasks
  bool done;
}

class CategoryTheme {
  const CategoryTheme({
    required this.color,
    required this.border,
    required this.icon,
  });
  final Color color;
  final Color border;
  final IconData icon;
}

/* ============================================================================
 *  WIDGETS
 * ==========================================================================*/

class _KpiCard extends StatelessWidget {
  const _KpiCard({
    required this.title,
    required this.value,
    required this.subtitle,
    required this.emoji,
    required this.progress,
  });

  final String title;
  final String value;
  final String subtitle;
  final String emoji;
  final double progress;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: Colors.white,
        border: Border.all(color: Colors.black12),
        boxShadow: const [BoxShadow(color: Color(0x14000000), blurRadius: 10, offset: Offset(0, 6))],
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
                  value: progress,
                  strokeWidth: 10,
                  backgroundColor: Colors.grey.shade200,
                  valueColor: const AlwaysStoppedAnimation<Color>(Colors.blueAccent),
                ),
                Center(
                  child: Text(emoji, style: const TextStyle(fontSize: 22)),
                ),
              ],
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: GoogleFonts.poppins(fontWeight: FontWeight.w800, fontSize: 16)),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: GoogleFonts.poppins(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w600,
                    color: Colors.black.withOpacity(0.65),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  value,
                  style: GoogleFonts.poppins(fontSize: 24, fontWeight: FontWeight.w900),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

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

class _CategorySection extends StatelessWidget {
  const _CategorySection({
    required this.name,
    required this.tasks,
    required this.onToggle,
    required this.theme,
  });

  final String name;
  final List<ActivityTask> tasks;
  final void Function(ActivityTask) onToggle;
  final CategoryTheme theme;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: theme.color,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: theme.border),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(horizontal: 12),
          childrenPadding: const EdgeInsets.only(left: 12, right: 12, bottom: 12, top: 0),
          shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
          leading: Icon(theme.icon, size: 26),
          title: Text(
            name,
            style: GoogleFonts.poppins(fontWeight: FontWeight.w800, fontSize: 16),
          ),
          children: [
            Column(children: tasks.map((t) => _TaskRow(task: t, onToggle: onToggle)).toList())
          ],
        ),
      ),
    );
  }
}

class _TaskRow extends StatelessWidget {
  const _TaskRow({required this.task, required this.onToggle});
  final ActivityTask task;
  final void Function(ActivityTask) onToggle;

  @override
  Widget build(BuildContext context) {
    final isDone = task.done;

    return InkWell(
      onTap: () => onToggle(task),
      borderRadius: BorderRadius.circular(12),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        margin: const EdgeInsets.only(top: 8),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        decoration: BoxDecoration(
          color: isDone ? Colors.white : Colors.white.withOpacity(0.6),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isDone ? Colors.black.withOpacity(0.25) : Colors.black.withOpacity(0.08),
          ),
          boxShadow: isDone
              ? [const BoxShadow(color: Color(0x14000000), blurRadius: 8, offset: Offset(0, 4))]
              : [],
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                task.title,
                style: GoogleFonts.poppins(fontSize: 15.5, fontWeight: FontWeight.w700),
              ),
            ),
            if (task.co2Kg > 0)
              Padding(
                padding: const EdgeInsets.only(right: 10),
                child: Row(
                  children: [
                    const Icon(Icons.co2_rounded, size: 18),
                    const SizedBox(width: 2),
                    Text(
                      '-${task.co2Kg.toStringAsFixed(1)}kg',
                      style: GoogleFonts.poppins(fontSize: 12.5, fontWeight: FontWeight.w800),
                    ),
                  ],
                ),
              ),
            Row(
              children: [
                Text('${task.points}', style: GoogleFonts.poppins(fontSize: 15.5, fontWeight: FontWeight.w800)),
                const SizedBox(width: 2),
                const Icon(Icons.bolt_rounded, size: 20),
              ],
            ),
            const SizedBox(width: 8),
            Icon(isDone ? Icons.check_box_rounded : Icons.check_box_outline_blank_rounded, size: 26),
          ],
        ),
      ),
    );
  }
}

// ---------- Vorschlags-Card (neu) ----------
class _SuggestCard extends StatelessWidget {
  const _SuggestCard({
    required this.controller,
    required this.onSubmit,
  });

  final TextEditingController controller;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.black.withOpacity(0.08)),
        borderRadius: BorderRadius.circular(14),
        boxShadow: const [BoxShadow(color: Color(0x14000000), blurRadius: 8, offset: Offset(0, 6))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Hast du eine coole Idee? Teile sie mit uns – vielleicht wird daraus eine neue Aufgabe für alle.',
            style: GoogleFonts.poppins(fontSize: 13.5, fontWeight: FontWeight.w600, color: Colors.black54),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: controller,
            textInputAction: TextInputAction.send,
            onSubmitted: (_) => onSubmit(),
            decoration: InputDecoration(
              hintText: 'Dein Vorschlag (z. B. „Mit dem Rad zur Arbeit“)',
              hintStyle: GoogleFonts.poppins(fontSize: 14, color: Colors.black45, fontWeight: FontWeight.w600),
              filled: true,
              fillColor: Colors.black.withOpacity(0.03),
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.black.withOpacity(0.08)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.black.withOpacity(0.08)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Colors.black87, width: 1),
              ),
            ),
          ),
          const SizedBox(height: 10),
          Align(
            alignment: Alignment.centerRight,
            child: ElevatedButton.icon(
              onPressed: onSubmit,
              icon: const Icon(Icons.send_rounded, size: 18),
              label: const Text('Vorschlag senden'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
