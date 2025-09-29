import 'dart:math';
import 'package:flutter/material.dart';

class AuroraBackground extends StatefulWidget {
  final List<Color> colors;
  final double intensity;
  final Widget? child;

  const AuroraBackground({
    super.key,
    this.colors = const [
      Color(0xFFEFF7F2),
      Color(0xFFBEE3D3),
      Color(0xFF9ED3C2),
      Color(0xFFF6FAF8),
    ],
    this.intensity = 0.65,
    this.child,
  });

  @override
  State<AuroraBackground> createState() => _AuroraBackgroundState();
}

class _AuroraBackgroundState extends State<AuroraBackground>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 18),
    )..repeat();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: AnimatedBuilder(
        animation: _ctrl,
        builder: (context, _) {
          return CustomPaint(
            painter: _AuroraPainter(
              t: _ctrl.value,
              colors: widget.colors,
              intensity: widget.intensity,
            ),
            child: widget.child,
          );
        },
      ),
    );
  }
}

class _AuroraPainter extends CustomPainter {
  final double t; // 0..1
  final List<Color> colors;
  final double intensity;

  _AuroraPainter({
    required this.t,
    required this.colors,
    required this.intensity,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final bg = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Color.lerp(colors.first, Colors.white, 0.35)!,
          Colors.white,
        ],
      ).createShader(Offset.zero & size);
    canvas.drawRect(Offset.zero & size, bg);

    final w = size.width;
    final h = size.height;
    final r = sqrt(w * w + h * h) * 0.55;

    Offset pos(double ox, double oy, double spx, double spy) {
      final a = t * 2 * pi;
      return Offset(
        ox * w + sin(a * spx) * w * 0.08,
        oy * h + cos(a * spy) * h * 0.06,
      );
    }

    final blobs = <(Offset, Color, List<double>)>[
      (pos(0.2, 0.15, 0.8, 0.6), colors[1], [0.0, intensity * 0.30, 1.0]),
      (pos(0.85, 0.25, 0.6, 0.9), colors[2], [0.0, intensity * 0.22, 1.0]),
      (pos(0.40, 0.85, 0.7, 0.7), colors[1].withOpacity(0.9), [0.0, intensity * 0.18, 1.0]),
    ];

    for (final b in blobs) {
      final (center, c, stops) = b;
      final paint = Paint()
        ..shader = RadialGradient(
          colors: [c.withOpacity(0.55), c.withOpacity(0.18), Colors.transparent],
          stops: stops,
        ).createShader(Rect.fromCircle(center: center, radius: r));
      canvas.drawCircle(center, r, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _AuroraPainter old) =>
      old.t != t || old.colors != colors || old.intensity != intensity;
}
