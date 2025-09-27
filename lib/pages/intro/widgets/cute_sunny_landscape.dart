import 'dart:math';
import 'package:flutter/material.dart';
import 'moving_cloud.dart';
import 'sheep_widget.dart';
import 'landscape_nature.dart'; // PineTree / BerryBush / Pond
import 'plane_contrail.dart';  // <-- korrigiertes Flugzeug mit Kondensstreifen

/// Himmel + Sonne + Hügel + Rays + Wolken + Natur (Tannen/Büsche/Teich) + Schafe + Flugzeug (Contrail)
class CuteSunnyLandscape extends StatefulWidget {
  const CuteSunnyLandscape({super.key});

  @override
  State<CuteSunnyLandscape> createState() => _CuteSunnyLandscapeState();
}

class _CuteSunnyLandscapeState extends State<CuteSunnyLandscape> with TickerProviderStateMixin {
  late final AnimationController _sunCtrl;

  @override
  void initState() {
    super.initState();
    _sunCtrl = AnimationController(vsync: this, duration: const Duration(seconds: 18))..repeat();
  }

  @override
  void dispose() {
    _sunCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final skyTop = isDark ? const Color(0xFF0D1020) : const Color(0xFFE8F3FF);
    final skyBottom = isDark ? const Color(0xFF0A0C16) : const Color(0xFFFFFFFF);

    return AnimatedBuilder(
      animation: _sunCtrl,
      builder: (context, _) {
        final t = _sunCtrl.value * 2 * pi;
        const baseX = 0.78, baseY = 0.22;
        final dx = sin(t) * 0.02, dy = cos(t) * 0.01;

        return Stack(
          children: [
            // Himmel
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter, end: Alignment.bottomCenter,
                  colors: [skyTop, skyBottom],
                ),
              ),
            ),

            // Sonne
            LayoutBuilder(
              builder: (context, c) {
                final center = Offset((baseX + dx) * c.maxWidth, (baseY + dy) * c.maxHeight);
                final radius = min(c.maxWidth, c.maxHeight) * 0.42;
                return CustomPaint(
                  painter: _SunGlowPainter(
                    center: center,
                    radius: radius,
                    sunColor: const Color(0xFFFFE066),
                    glowStrength: isDark ? 0.45 : 0.55,
                  ),
                  size: Size.infinite,
                );
              },
            ),

            // Hügel
            Positioned.fill(
              child: CustomPaint(
                painter: _HillsPainter(
                  backColor: const Color(0xFF9BD18B),
                  frontColor: const Color(0xFF69B86A),
                  highlight: Colors.white.withOpacity(isDark ? 0.05 : 0.18),
                ),
              ),
            ),

            // Schimmer am Horizont
            IgnorePointer(
              child: Align(
                alignment: const Alignment(0, 0.35),
                child: Container(
                  width: double.infinity, height: 160,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter, end: Alignment.bottomCenter,
                      colors: [Colors.white.withOpacity(isDark ? 0.06 : 0.18), Colors.transparent],
                    ),
                  ),
                ),
              ),
            ),

            // Wolken
            const MovingCloud(startX: -0.25, endX: 1.25, y: 0.18, scale: 1.0, seconds: 60),
            const MovingCloud(startX: -0.35, endX: 1.15, y: 0.28, scale: 0.85, seconds: 70),
            const MovingCloud(startX: -0.20, endX: 1.30, y: 0.12, scale: 0.7, seconds: 55),

            // ✈️ Flugzeug mit Kondensstreifen (langsam, von links rein)
            const PlaneContrail(
              y: 0.16,
              seconds: 50,
              startX: -0.35,
              endX: 1.35,
              segments: 14,
              spacing: 12,
            ),

            // Natur-Elemente
            const Positioned(left: 22,  bottom: 112, child: PineTree(scale: 1.15)),
            const Positioned(right: 26, bottom: 118, child: PineTree(scale: 1.10)),
            const Positioned(left: 260, bottom: 106, child: PineTree(scale: 0.95)),
            const Positioned(left: 96, bottom: 74, child: Pond(width: 140, height: 60)),
            const Positioned(left: 56, bottom: 96, child: BerryBush(scale: 1.0)),
            const Positioned(right: 86, bottom: 92, child: BerryBush(scale: 1.1)),

            // Schafe – mit Weit-Drift (achte auf aktualisierte sheep_widget.dart)
            const SheepSprite(baseX: 0.22, baseY: 0.90, width: 76, hopSeconds: 3.2, wanderPixels: 18, roamX: 160, roamY: 12),
            const SheepSprite(baseX: 0.52, baseY: 0.89, width: 66, hopSeconds: 3.0, wanderPixels: 22, roamX: 140, roamY: 10, flip: true),
            const SheepSprite(baseX: 0.78, baseY: 0.91, width: 84, hopSeconds: 3.6, wanderPixels: 20, roamX: 180, roamY: 14),
          ],
        );
      },
    );
  }
}

/// SUN painter
class _SunGlowPainter extends CustomPainter {
  final Offset center;
  final double radius;
  final Color sunColor;
  final double glowStrength;

  _SunGlowPainter({required this.center, required this.radius, required this.sunColor, required this.glowStrength});

  @override
  void paint(Canvas canvas, Size size) {
    final glow = RadialGradient(
      colors: [sunColor.withOpacity(glowStrength), sunColor.withOpacity(glowStrength * 0.33), const Color(0x00FFFFFF)],
      stops: const [0.0, 0.35, 1.0],
    );
    final glowPaint = Paint()..shader = glow.createShader(Rect.fromCircle(center: center, radius: radius));
    canvas.drawCircle(center, radius, glowPaint);

    final corePaint = Paint()..color = Color.lerp(Colors.white, sunColor, 0.35)!.withOpacity(0.95);
    canvas.drawCircle(center, radius * 0.16, corePaint);
  }

  @override
  bool shouldRepaint(covariant _SunGlowPainter old) =>
      old.center != center || old.radius != radius || old.sunColor != sunColor || old.glowStrength != glowStrength;
}

/// Hügel
class _HillsPainter extends CustomPainter {
  final Color backColor;
  final Color frontColor;
  final Color highlight;

  _HillsPainter({required this.backColor, required this.frontColor, required this.highlight});

  @override
  void paint(Canvas canvas, Size size) {
    final h = size.height, w = size.width;

    final backPath = Path()
      ..moveTo(0, h * 0.55)
      ..cubicTo(w * 0.20, h * 0.48, w * 0.35, h * 0.62, w * 0.50, h * 0.56)
      ..cubicTo(w * 0.68, h * 0.48, w * 0.80, h * 0.60, w, h * 0.50)
      ..lineTo(w, h)..lineTo(0, h)..close();
    canvas.drawPath(backPath, Paint()..color = backColor);

    final backHighlight = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topRight, end: Alignment.bottomLeft,
        colors: [highlight, const Color(0x00FFFFFF)],
      ).createShader(Rect.fromLTWH(0, h * 0.45, w, h * 0.2));
    canvas.drawPath(backPath, backHighlight);

    final frontPath = Path()
      ..moveTo(0, h * 0.70)
      ..cubicTo(w * 0.18, h * 0.66, w * 0.34, h * 0.82, w * 0.52, h * 0.74)
      ..cubicTo(w * 0.72, h * 0.66, w * 0.86, h * 0.82, w, h * 0.76)
      ..lineTo(w, h)..lineTo(0, h)..close();
    canvas.drawPath(frontPath, Paint()..color = frontColor);

    final frontHighlight = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topRight, end: Alignment.bottomLeft,
        colors: [highlight, const Color(0x00FFFFFF)],
      ).createShader(Rect.fromLTWH(0, h * 0.64, w, h * 0.2));
    canvas.drawPath(frontPath, frontHighlight);
  }

  @override
  bool shouldRepaint(covariant _HillsPainter old) =>
      old.backColor != backColor || old.frontColor != frontColor || old.highlight != highlight;
}
