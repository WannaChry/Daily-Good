import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class Co2ImpactCard extends StatelessWidget {
  const Co2ImpactCard({
    super.key,
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