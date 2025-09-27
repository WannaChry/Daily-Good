import 'package:flutter/material.dart';

/// Monochrom-grüner Verlauf mit weichen Glow-Orbs.
/// [tint] steuert den Grundton, Standard ist ein frisches Grün.
class FancyLoginBackground extends StatelessWidget {
  final Color tint;
  const FancyLoginBackground({
    super.key,
    this.tint = const Color(0xFF60BFA0), // 🌿 Standard: frisches Grün
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    Color tone(double a) => Color.lerp(Colors.white, tint, a)!;
    // etwas kräftigerer grüner Verlauf
    final top = isDark ? Color.lerp(Colors.black, tint, 0.20)! : tone(0.22);
    final bottom = isDark ? Color.lerp(Colors.black, tint, 0.10)! : tone(0.06);

    return Stack(
      children: [
        // Hintergrund-Verlauf
        Positioned.fill(
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [top, bottom],
              ),
            ),
          ),
        ),
        // Grüne Orbs (alle vom Tint abgeleitet → konsistentes Grading)
        Positioned(top: -60, left: -40, child: _orb(color: tone(0.55).withOpacity(0.40), size: 220)),
        Positioned(top: 120, right: -30, child: _orb(color: tone(0.45).withOpacity(0.32), size: 170)),
        Positioned(bottom: -50, left: 40, child: _orb(color: tone(0.65).withOpacity(0.36), size: 190)),
      ],
    );
  }

  Widget _orb({required Color color, required double size}) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        boxShadow: [BoxShadow(color: color, blurRadius: 90, spreadRadius: 30)],
      ),
    );
  }
}
