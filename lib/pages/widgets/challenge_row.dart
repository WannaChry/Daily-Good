import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ChallengeRow extends StatelessWidget {
  const ChallengeRow({
    super.key,
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
        Expanded(
          child: ChallengeCard(
            title: 'Tages-Challenge',
            emoji: '⚡️',
            progress: dailyProgress,
            target: dailyTarget,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: ChallengeCard(
            title: 'Wochen-Challenge',
            emoji: '📅',
            progress: weeklyProgress,
            target: weeklyTarget,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: ChallengeCard(
            title: 'Monats-Challenge',
            emoji: '🏆',
            progress: monthlyProgress,
            target: monthlyTarget,
          ),
        ),
      ],
    );
  }
}

class ChallengeCard extends StatelessWidget {
  const ChallengeCard({
    super.key,
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
          Text('$progress / $target', style: GoogleFonts.poppins(fontWeight: FontWeight.w900, fontSize: 16)),
        ],
      ),
    );
  }
}
