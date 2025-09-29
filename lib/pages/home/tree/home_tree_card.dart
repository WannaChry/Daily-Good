import 'package:flutter/material.dart';
import 'package:studyproject/pages/home/tree/level_progress_card.dart';

class HomeTreeCard extends StatelessWidget {
  final int level;
  final int totalPoints;
  final double progress;

  final double emojiSize;

  const HomeTreeCard({
    super.key,
    required this.level,
    required this.totalPoints,
    required this.progress,
    this.emojiSize = 60,
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
          Text(
            '🌳',
            style: TextStyle(
              fontSize: emojiSize,
              height: 1,
            ),
          ),

          const SizedBox(width: 16),

          Expanded(
            child: LevelProgressCard(
              totalPoints: totalPoints,
            ),
          ),
        ],
      ),
    );
  }
}
