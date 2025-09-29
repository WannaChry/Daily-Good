// lib/pages/home/tree/home_tree_card.dart
import 'package:flutter/material.dart';
import 'package:studyproject/pages/home/tasks/TreeGrowth.dart';
import 'package:studyproject/pages/home/tree/level_progress_card.dart';

class HomeTreeCard extends StatelessWidget {
  final int level;
  final int totalPoints;
  final double progress;

  /// Größe des Baum-Emojis (Standard: 60)
  final double emojiSize;

  const HomeTreeCard({
    super.key,
    required this.level,
    required this.totalPoints,
    required this.progress,
    this.emojiSize = 60, // <- leicht größer
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFFEFF7EA), Color(0xFFDFF0D8)],
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
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Baum-Emoji links (Größe über emojiSize steuerbar)
          Text(
            '🌳',
            style: TextStyle(
              fontSize: emojiSize,
              height: 1,
            ),
          ),

          const SizedBox(width: 16),

          // LevelProgressCard rechts
          Expanded(
            child: LevelProgressCard(
              totalPoints: totalPoints,
              // level: level,
              // progress: progress,
            ),
          ),
        ],
      ),
    );
  }
}
