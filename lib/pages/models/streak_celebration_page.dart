import 'dart:math';
import 'package:flutter/material.dart';

class StreakCelebrationPage extends StatelessWidget {
  const StreakCelebrationPage({
    super.key,
    required this.currentStreak,
    required this.bestStreak,
    required this.lastCheckIn,
  });

  final int currentStreak;
  final int bestStreak;
  final DateTime lastCheckIn;

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      body: Stack(
        children: [
          const _GreenBackdrop(),
          const _SoftRays(opacity: 0.06),

          SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final maxW = min(constraints.maxWidth, 520.0);
                return Center(
                  child: ConstrainedBox(
                    constraints: BoxConstraints.tightFor(width: maxW),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Column(
                        children: [
                          const SizedBox(height: 44),

                          // Neues, scharfes Medal-Badge (kein Schatten-Blob)
                          const _LeafBadge(size: 146),

                          const SizedBox(height: 30),
                          Text(
                            '$currentStreak',
                            style: const TextStyle(
                              fontSize: 88,
                              height: 0.95,
                              fontWeight: FontWeight.w900,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'DAY STREAK',
                            style: TextStyle(
                              fontSize: 26,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 1.2,
                              color: Colors.white,
                            ),
                          ),

                          const SizedBox(height: 26),
                          _WeekStrip(
                            currentStreak: currentStreak,
                            lastCheckIn: lastCheckIn,
                          ),

                          const SizedBox(height: 16),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 14),
                            child: Text(
                              bestStreak <= 1
                                  ? 'Willkommen zurück! Schön, dass du heute dabei bist – jeder Tag zählt!'
                                  : 'Dein bisheriger Bestwert: $bestStreak Tage. Weiter so – heute zählst du wieder!',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 16,
                                height: 1.35,
                                color: Colors.white.withOpacity(.95),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),

                          const Spacer(),

                          Padding(
                            padding: EdgeInsets.fromLTRB(0, 6, 0, 16 + bottom),
                            child: SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: () => Navigator.of(context)
                                    .pushNamedAndRemoveUntil('/home', (r) => false),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.white,
                                  foregroundColor: Colors.black,
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 16, horizontal: 18),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  elevation: 0,
                                ),
                                child: const Text(
                                  "Let's go!",
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

/// Sanftes grünes Color-Grading
class _GreenBackdrop extends StatelessWidget {
  const _GreenBackdrop();

  @override
  Widget build(BuildContext context) {
    return const Positioned.fill(
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF82D49B),
              Color(0xFF74C68E),
              Color(0xFF5BB97E),
            ],
          ),
        ),
      ),
    );
  }
}

/// Sehr dezente Rays
class _SoftRays extends StatelessWidget {
  const _SoftRays({this.opacity = .06});
  final double opacity;

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: IgnorePointer(
        child: CustomPaint(
          painter: _RaysPainter(opacity: opacity),
        ),
      ),
    );
  }
}

class _RaysPainter extends CustomPainter {
  _RaysPainter({required this.opacity});
  final double opacity;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height * .30);
    final paint = Paint()
      ..isAntiAlias = true
      ..style = PaintingStyle.stroke
      ..strokeWidth = 36
      ..color = Colors.white.withOpacity(opacity);

    const rays = 16;
    final rMax = size.height * .90;
    for (int i = 0; i < rays; i++) {
      final a = (2 * pi / rays) * i;
      final dir = Offset(cos(a), sin(a));
      canvas.drawLine(center, center + dir * rMax, paint);
    }

    final glow = RadialGradient(
      colors: [Colors.white.withOpacity(opacity * 1.15), Colors.transparent],
    ).createShader(Rect.fromCircle(center: center, radius: size.width * .78));
    canvas.drawCircle(center, size.width * .78, Paint()..shader = glow);
  }

  @override
  bool shouldRepaint(covariant _RaysPainter old) => old.opacity != opacity;
}

/// Medal-Badge via CustomPaint (ohne zusätzlichen Overlay-Kreis)
class _LeafBadge extends StatelessWidget {
  const _LeafBadge({required this.size});
  final double size;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(painter: _MedalPainter()),
    );
  }
}

class _MedalPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final c = Offset(size.width / 2, size.height / 2);
    final r = size.width / 2;

    // Basis
    final base = Paint()
      ..isAntiAlias = true
      ..shader = const RadialGradient(
        colors: [Color(0xFFF6FFFA), Color(0xFFE9FBF1)],
        radius: .95,
      ).createShader(Rect.fromCircle(center: c, radius: r));
    canvas.drawCircle(c, r, base);

    // Außenring
    final ring = Paint()
      ..isAntiAlias = true
      ..style = PaintingStyle.stroke
      ..strokeWidth = r * .13
      ..color = const Color(0xFFCFEBDD);
    canvas.drawCircle(c, r * .82, ring);

    // Metallic-Sweep
    final sweep = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = r * .13
      ..shader = SweepGradient(
        startAngle: -pi / 2,
        endAngle: 3 * pi / 2,
        colors: [
          Colors.white.withOpacity(.32),
          Colors.transparent,
          Colors.black.withOpacity(.08),
          Colors.white.withOpacity(.28),
        ],
        stops: const [0.0, 0.45, 0.7, 1.0],
      ).createShader(Rect.fromCircle(center: c, radius: r * .82));
    canvas.drawCircle(c, r * .82, sweep);

    // Innere Platte
    final plate = Paint()
      ..isAntiAlias = true
      ..shader = const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Colors.white, Color(0xFFF2FFF6)],
      ).createShader(Rect.fromCircle(center: c, radius: r * .62));
    canvas.drawCircle(c, r * .62, plate);

    // Innerer, feiner Ring
    final innerRing = Paint()
      ..isAntiAlias = true
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..color = Colors.white.withOpacity(.9);
    canvas.drawCircle(c, r * .62, innerRing);

    // Blatt
    final leafSize = Size(r * 0.88, r * 0.88);
    final leafOffset = Offset(c.dx - leafSize.width / 2, c.dy - leafSize.height / 2 + r * .03);

    final leafPath = Path()
      ..moveTo(leafOffset.dx + leafSize.width * .5, leafOffset.dy)
      ..cubicTo(
        leafOffset.dx + leafSize.width * .92, leafOffset.dy + leafSize.height * .22,
        leafOffset.dx + leafSize.width * .92, leafOffset.dy + leafSize.height * .78,
        leafOffset.dx + leafSize.width * .5,  leafOffset.dy + leafSize.height,
      )
      ..cubicTo(
        leafOffset.dx + leafSize.width * .08, leafOffset.dy + leafSize.height * .78,
        leafOffset.dx + leafSize.width * .08, leafOffset.dy + leafSize.height * .22,
        leafOffset.dx + leafSize.width * .5,  leafOffset.dy,
      )
      ..close();

    // ganz dezenter Schatten
    final shadow = Paint()
      ..isAntiAlias = true
      ..color = Colors.black.withOpacity(.12)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);
    canvas.save();
    canvas.translate(0, 2);
    canvas.drawPath(leafPath, shadow);
    canvas.restore();

    // Füllung
    final leafFill = Paint()
      ..isAntiAlias = true
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Color(0xFF32B765), Color(0xFF23A257)],
      ).createShader(Rect.fromLTWH(leafOffset.dx, leafOffset.dy, leafSize.width, leafSize.height));
    canvas.drawPath(leafPath, leafFill);

    // Weißes Outline
    final leafOutline = Paint()
      ..isAntiAlias = true
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.4
      ..color = Colors.white.withOpacity(.95);
    canvas.drawPath(leafPath, leafOutline);

    // Mittelrippe
    final vein = Paint()
      ..isAntiAlias = true
      ..color = Colors.white
      ..strokeWidth = 3.2
      ..style = PaintingStyle.stroke;
    canvas.drawLine(
      Offset(leafOffset.dx + leafSize.width * .5, leafOffset.dy + leafSize.height * .08),
      Offset(leafOffset.dx + leafSize.width * .5, leafOffset.dy + leafSize.height * .92),
      vein,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Wochentags-Pill mit Checks / Dots
class _WeekStrip extends StatelessWidget {
  const _WeekStrip({
    required this.currentStreak,
    required this.lastCheckIn,
  });

  final int currentStreak;
  final DateTime lastCheckIn;

  static const _labels = ['M', 'D', 'M', 'D', 'F', 'S', 'S']; // Mo→So

  bool _markedFor(int indexMon0) {
    final today = lastCheckIn.weekday - 1; // 0..6
    int left = currentStreak;
    for (int k = 0; k < left; k++) {
      var idx = (today - k) % 7;
      if (idx < 0) idx += 7;
      if (idx == indexMon0) return true;
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(.35)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: List.generate(7, (i) {
          final marked = _markedFor(i);
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                _labels[i],
                style: TextStyle(
                  color: Colors.white.withOpacity(.95),
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: marked ? Colors.white : Colors.white.withOpacity(.22),
                  border: Border.all(
                    color: marked ? Colors.white : Colors.white.withOpacity(.45),
                    width: 1.5,
                  ),
                ),
                child: marked
                    ? const Icon(Icons.check, color: Colors.black, size: 22)
                    : null,
              ),
            ],
          );
        }),
      ),
    );
  }
}
