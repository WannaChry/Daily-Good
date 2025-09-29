// lib/pages/widgets/dailygood_profile_background.dart
import 'package:flutter/material.dart';

/// Ruhiger Pastell-Hintergrund für Profil/Account.
/// - Kein Scroll-/Animations-Coupling
/// - Heller Verlauf + 3 weiche Farbblobs (Pastell)
class DailyGoodProfileBackground extends StatelessWidget {
  const DailyGoodProfileBackground({
    super.key,
    required this.child,
    this.top = const Color(0xFFF7FAFF),     // sehr helles Blau
    this.bottom = const Color(0xFFFFFFFF),  // weiß
    this.blobA = const Color(0xFFDDE8FF),   // Pastellblau
    this.blobB = const Color(0xFFEDE4FF),   // Pastelllila
    this.blobC = const Color(0xFFD9F3EE),   // Pastelltürkis
  });

  final Widget child;
  final Color top, bottom, blobA, blobB, blobC;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _PastelPainter(top, bottom, blobA, blobB, blobC),
      child: child,
    );
  }
}

class _PastelPainter extends CustomPainter {
  _PastelPainter(this.top, this.bottom, this.a, this.b, this.c);
  final Color top, bottom, a, b, c;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;

    // Grundverlauf (oben sehr helles Blau -> unten Weiß)
    final bg = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [top, bottom],
      ).createShader(rect);
    canvas.drawRect(rect, bg);

    // Zarte Farbblobs (weiche Radialverläufe)
    void blob(Offset center, double radius, Color color, double alpha) {
      final p = Paint()
        ..shader = RadialGradient(
          colors: [
            color.withValues(alpha: alpha),
            color.withValues(alpha: 0.0),
          ],
        ).createShader(Rect.fromCircle(center: center, radius: radius));
      canvas.drawCircle(center, radius, p);
    }

    // Positionierung dezent über die Seite verteilt
    final L = size.longestSide;
    blob(Offset(size.width * .18, size.height * .22), L * .38, a, 0.22);
    blob(Offset(size.width * .84, size.height * .30), L * .32, b, 0.18);
    blob(Offset(size.width * .58, size.height * .80), L * .40, c, 0.20);
  }

  @override
  bool shouldRepaint(covariant _PastelPainter old) =>
      old.top != top || old.bottom != bottom || old.a != a || old.b != b || old.c != c;
}
