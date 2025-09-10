import 'dart:math';
import 'package:flutter/material.dart';

/// Süße, performante Mini-Landschaft (Wolken, Hügel, wippende Bäume,
/// kleine Fireflies). Keine Assets – nur CustomPaint.
class CuteLandscape extends StatefulWidget {
  const CuteLandscape({
    super.key,
    this.height = 200,
    this.variant = 0, // 0..n – wechselt Farbstimmung
  });

  final double height;
  final int variant;

  @override
  State<CuteLandscape> createState() => _CuteLandscapeState();
}

class _CuteLandscapeState extends State<CuteLandscape>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ac;

  @override
  void initState() {
    super.initState();
    _ac = AnimationController(vsync: this, duration: const Duration(seconds: 8))
      ..repeat();
  }

  @override
  void dispose() {
    _ac.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: AnimatedBuilder(
        animation: _ac,
        builder: (_, __) => CustomPaint(
          painter: _LandscapePainter(t: _ac.value, variant: widget.variant),
          size: Size(double.infinity, widget.height),
        ),
      ),
    );
  }
}

class _LandscapePainter extends CustomPainter {
  _LandscapePainter({required this.t, required this.variant});
  final double t; // 0..1
  final int variant;

  List<Color> get _sky => switch (variant % 4) {
    0 => [const Color(0xFFEFF7EA), const Color(0xFFDFF0D8)],
    1 => [const Color(0xFFE8F0FF), const Color(0xFFD9E3FF)],
    2 => [const Color(0xFFFFEFEF), const Color(0xFFFFD9DF)],
    _ => [const Color(0xFFF4ECFF), const Color(0xFFE6DAFF)],
  };

  Color get _hill1 => switch (variant % 4) {
    0 => const Color(0xFFAAD8A5),
    1 => const Color(0xFFB8D1FF),
    2 => const Color(0xFFFFB8C7),
    _ => const Color(0xFFCAB7FF),
  };

  Color get _hill2 => switch (variant % 4) {
    0 => const Color(0xFF8CC184),
    1 => const Color(0xFF9EBBFF),
    2 => const Color(0xFFFF9DB1),
    _ => const Color(0xFFB09BFF),
  };

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width, h = size.height;

    // Himmel
    final rect = Rect.fromLTWH(0, 0, w, h);
    final sky = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: _sky,
      ).createShader(rect);
    canvas.drawRect(rect, sky);

    // Hügel
    _drawHill(canvas, w, h * .70, amp: 18, color: _hill1, phase: 0.2);
    _drawHill(canvas, w, h * .82, amp: 24, color: _hill2, phase: 0.6);

    // Bäume
    _drawTree(canvas, Offset(w * .18, h * .58), scale: .95);
    _drawTree(canvas, Offset(w * .36, h * .64), scale: 1.15);
    _drawTree(canvas, Offset(w * .62, h * .63), scale: 1.05);
    _drawTree(canvas, Offset(w * .80, h * .57), scale: .9);

    // Wolken
    _drawCloud(canvas, Offset((w * (t % 1.0)), h * .20), 42);
    _drawCloud(canvas, Offset((w * ((t + .35) % 1.0)), h * .28), 28);

    // Fireflies
    _drawFireflies(canvas, w, h);
  }

  void _drawHill(Canvas canvas, double w, double y,
      {required double amp, required Color color, required double phase}) {
    final p = Path()..moveTo(0, y);
    for (int i = 0; i <= 16; i++) {
      final x = w * (i / 16);
      final dy = sin((i / 3.2 + t * 2 + phase) * pi) * amp;
      p.lineTo(x, y + dy);
    }
    p..lineTo(w, w)..lineTo(0, w)..close();
    canvas.drawPath(p, Paint()..color = color);
  }

  void _drawTree(Canvas canvas, Offset base, {double scale = 1.0}) {
    final sway = sin((t * 2 * pi) + base.dx / 80) * 0.04;
    canvas.save();
    canvas.translate(base.dx, base.dy);
    canvas.scale(scale, scale);
    canvas.rotate(sway);

    final trunk = Paint()..color = const Color(0xFF6B4F3B);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(-4, 16, 8, 22),
        const Radius.circular(2),
      ),
      trunk,
    );

    final green = Paint()..color = const Color(0xFF3FAE6B);
    Path tri(double yOffset, double width) => Path()
      ..moveTo(0, yOffset)
      ..lineTo(-width, yOffset + 18)
      ..lineTo(width, yOffset + 18)
      ..close();

    canvas.drawPath(tri(-2, 14), green);
    canvas.drawPath(tri(-10, 18), green);
    canvas.drawPath(tri(-18, 22), green);
    canvas.restore();
  }

  void _drawCloud(Canvas canvas, Offset c, double r) {
    final p = Paint()..color = Colors.white.withOpacity(.85);
    canvas.drawCircle(c + Offset(-r * .6, 0), r * .62, p);
    canvas.drawCircle(c + Offset(0, -r * .18), r * .75, p);
    canvas.drawCircle(c + Offset(r * .6, 0), r * .55, p);
    canvas.drawOval(
      Rect.fromCenter(center: c + Offset(0, r * .55), width: r * 2, height: r * .35),
      Paint()..color = Colors.black12,
    );
  }

  void _drawFireflies(Canvas canvas, double w, double h) {
    final rnd = Random(42);
    final p = Paint()..color = const Color(0xFFFFF59D).withOpacity(.75);
    for (int i = 0; i < 12; i++) {
      final x = (rnd.nextDouble() * w + i * 23) % w;
      final yBase = h * .52 + (i % 3) * 16.0;
      final y = yBase + sin((t * 2 * pi) + i) * 4;
      canvas.drawCircle(Offset(x, y), 1.8, p);
    }
  }

  @override
  bool shouldRepaint(covariant _LandscapePainter old) =>
      old.t != t || old.variant != variant;
}
