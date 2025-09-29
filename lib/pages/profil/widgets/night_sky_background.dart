import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

class NightSkyBackground extends StatefulWidget {
  const NightSkyBackground({
    super.key,
    required this.child,
    this.scrollOffset = 0.0,
    this.viewportExtent = 0.0,
    this.maxScrollExtent = 0.0,
    this.parallax = false,
  });

  final Widget child;
  final double scrollOffset;
  final double viewportExtent;
  final double maxScrollExtent;
  final bool parallax;

  @override
  State<NightSkyBackground> createState() => _NightSkyBackgroundState();
}

class _NightSkyBackgroundState extends State<NightSkyBackground> {
  static const _accentBlue = Color(0xFF97C4FF);

  late final Ticker _ticker;
  double _time = 0.0;

  @override
  void initState() {
    super.initState();
    _ticker = Ticker((elapsed) {
      setState(() {
        _time = elapsed.inMicroseconds / 1e6;
      });
    })..start();
  }

  @override
  void dispose() {
    _ticker.dispose();
    super.dispose();
  }

  double get _scrollPhase {
    final total = widget.viewportExtent + widget.maxScrollExtent;
    if (total <= 0) return 0;
    return (widget.scrollOffset / total) % 1.0;
  }

  @override
  Widget build(BuildContext context) {
    final phase = widget.parallax ? _scrollPhase : 0.0;
    final contentExtent = widget.viewportExtent + widget.maxScrollExtent;

    return Stack(
      fit: StackFit.expand,
      children: [
        CustomPaint(painter: _NightSkyPainter(time: _time, extraPhase: phase)),
        IgnorePointer(
          child: CustomPaint(
            painter: _BalloonFieldPainter(
              time: _time,
              accent: _accentBlue,
              scrollOffset: widget.scrollOffset,
              contentExtent: contentExtent > 0 ? contentExtent : null,
              parallaxPhase: phase,
            ),
          ),
        ),
        widget.child,
      ],
    );
  }
}

// ---------------- Sterne ----------------

class _NightSkyPainter extends CustomPainter {
  _NightSkyPainter({required this.time, required this.extraPhase});
  final double time;
  final double extraPhase;

  static const _bgTop = Color(0xFF0B1023);
  static const _bgBottom = Color(0xFF111B3B);

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final bg = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [_bgTop, _bgBottom],
      ).createShader(rect);
    canvas.drawRect(rect, bg);

    final star = Paint()..style = PaintingStyle.fill;
    const count = 180;
    for (int i = 0; i < count; i++) {
      final dx = (i * 127.3 + extraPhase * 12.0) % size.width;
      final dy = (i * 61.7) % size.height;
      final phase = (i * 0.37) % math.pi;
      final twinkle =
          0.55 + 0.45 * math.sin(2 * math.pi * (0.12 * time) + phase);
      final radius = 0.6 + (i % 5) * 0.28;
      star.color = Colors.white.withValues(alpha: 0.12 + 0.7 * twinkle);
      canvas.drawCircle(Offset(dx, dy), radius, star);
    }
  }

  @override
  bool shouldRepaint(_NightSkyPainter old) =>
      old.time != time || old.extraPhase != extraPhase;
}

// ---------------- Ballons ----------------

class _BalloonFieldPainter extends CustomPainter {
  _BalloonFieldPainter({
    required this.time,
    required this.accent,
    required this.scrollOffset,
    this.contentExtent,
    this.parallaxPhase = 0.0,
  });

  final double time;
  final Color accent;
  final double scrollOffset;
  final double? contentExtent;
  final double parallaxPhase;

  @override
  void paint(Canvas canvas, Size size) {
    const balloons = 12;
    for (int i = 0; i < balloons; i++) {
      _paintBalloon(canvas, size, i);
    }
  }

  void _paintBalloon(Canvas canvas, Size size, int index) {
    final r = math.Random(1000 + index);

    final worldH = (contentExtent ?? size.height);
    const extra = 220.0;       // Start/Ende außerhalb des Screens
    final travel = worldH + 2 * extra;

    // Jede Kugel hat eigene Geschwindigkeit (Zyklen/Sekunde) + Phase:
    final cps = 0.015 + r.nextDouble() * 0.035;
    final seed = r.nextDouble();
    final phase = (time * cps + seed) % 1.0;

    // Von unten (-extra) bis oben (worldH+extra)
    final yWorld = -extra + (1.0 - phase) * travel;
    final yVisible = yWorld - scrollOffset;

    if (yVisible < -extra || yVisible > size.height + extra) return;

    const fadeEdge = 90.0;
    double fade = 1.0;
    if (yVisible < fadeEdge) {
      fade = (yVisible / fadeEdge).clamp(0.0, 1.0);
    } else if (yVisible > size.height - fadeEdge) {
      fade = ((size.height - yVisible) / fadeEdge).clamp(0.0, 1.0);
    }

    // seitlicher Drift
    final baseX = r.nextDouble() * size.width;
    final driftAmp = 18 + r.nextDouble() * 28;
    final x = baseX +
        math.sin(phase * 2 * math.pi * (1.0 + r.nextDouble()) + parallaxPhase * 0.6) *
            driftAmp;
    final scale = 0.7 + r.nextDouble() * 1.0;
    final flameOn = math.sin(phase * 2 * math.pi * 3) > 0.6;

    _drawBalloon(canvas, Offset(x, yVisible), scale, flameOn, fade);
  }

  void _drawBalloon(Canvas canvas, Offset c, double s, bool flameOn, double fade) {
    final w = 26 * s;
    final h = 34 * s;

    final envelope = Paint()..color = Colors.white.withValues(alpha: 0.78 * fade);
    canvas.drawOval(Rect.fromCenter(center: c, width: w, height: h), envelope);

    final topGlow = Paint()
      ..shader = RadialGradient(
        colors: [accent.withValues(alpha: 0.35 * fade), Colors.transparent],
      ).createShader(Rect.fromCircle(center: c.translate(0, -h * 0.18), radius: w));
    canvas.drawCircle(c.translate(0, -h * 0.18), w, topGlow);

    // Korb (braun)
    final basketRect =
    Rect.fromCenter(center: c.translate(0, h * 0.55), width: 10 * s, height: 7 * s);
    final basketPaint = Paint()..color = const Color(0xFF8D5A3B).withValues(alpha: 0.85 * fade);
    canvas.drawRRect(RRect.fromRectAndRadius(basketRect, Radius.circular(2 * s)), basketPaint);

    // Leinen
    final line = Paint()
      ..color = Colors.white70.withValues(alpha: fade)
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;
    canvas.drawLine(c.translate(-w * 0.18, h * 0.18), basketRect.topLeft, line);
    canvas.drawLine(c.translate(w * 0.18, h * 0.18), basketRect.topRight, line);

    // Flamme
    if (flameOn) {
      final flameCenter = c.translate(0, h * 0.33);
      final flame = Paint()
        ..shader = RadialGradient(
          colors: [
            Colors.deepOrange.withValues(alpha: 0.85 * fade),
            Colors.orange.withValues(alpha: 0.4 * fade),
            Colors.transparent
          ],
          stops: const [0.0, 0.45, 1.0],
        ).createShader(Rect.fromCircle(center: flameCenter, radius: 16 * s));
      canvas.drawCircle(flameCenter, 16 * s, flame);
    }
  }

  @override
  bool shouldRepaint(_BalloonFieldPainter old) =>
      old.time != time ||
          old.accent != accent ||
          old.scrollOffset != scrollOffset ||
          old.contentExtent != contentExtent ||
          old.parallaxPhase != parallaxPhase;
}
