import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class LevelCard extends StatelessWidget {
  const LevelCard({
    super.key,
    required this.level,
    required this.current,
    required this.needed,
    required this.totalPoints,
    required this.progress,
  });

  final int level;
  final int current;
  final int needed;
  final int totalPoints;
  final double progress;

  @override
  Widget build(BuildContext context) {
    final title = GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w800);
    final label = GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w600);

    const barH = 18.0;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Text('Level $level', style: title),
            Text('$totalPoints Punkte', style: label.copyWith(color: Colors.grey.shade700)),
          ]),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: Stack(
              children: [
                Container(height: barH, color: Colors.white),
                FractionallySizedBox(
                  alignment: Alignment.centerLeft,
                  widthFactor: progress,
                  child: Container(height: barH, color: Colors.green.shade300),
                ),
                Positioned.fill(
                  child: Center(
                    child: Text(
                      '$current / $needed',
                      style: GoogleFonts.poppins(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w700,
                        color: Colors.black.withOpacity(0.8),
                      ),
                    ),
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