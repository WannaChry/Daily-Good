import 'package:flutter/material.dart';
import 'dart:math' as math;

class WindLines extends StatefulWidget {
  const WindLines({
    super.key,
    this.opacity = .18,
    this.color = const Color(0xFFFFFFFF),
    this.speedSec = 14,
    this.layers = 3,
  });

  final double opacity;
  final Color color;
  final int speedSec;
  final int layers;

  @override
  State<WindLines> createState() => _WindLinesState();
}

class _WindLinesState extends State<WindLines> with SingleTickerProviderStateMixin {
  late final AnimationController _ctl =
  AnimationController(vsync: this, duration: Duration(seconds: widget.speedSec))..repeat();

  @override
  void dispose() {
    _ctl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: AnimatedBuilder(
        animation: _ctl,
        builder: (_, __) => CustomPaint(
          painter: _WindPainter(
            t: _ctl.value,
            color: widget.color.withOpacity(widget.opacity),
            layers: widget.layers,
          ),
        ),
      ),
    );
  }
}

class _WindPainter extends CustomPainter {
  _WindPainter({required this.t, required this.color, required this.layers});
  final double t;
  final Color color;
  final int layers;

  @override
  void paint(Canvas canvas, Size size) {
    final base = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    for (var l = 0; l < layers; l++) {
      final y = size.height * (.25 + .25 * l) + math.sin((t + l) * 6.283) * 6;
      final speed = 1.0 + l * .5;
      final x = ((t * speed) % 1.0) * size.width;

      for (var i = 0; i < 3; i++) {
        final dx = x - i * 70;
        final path = Path()
          ..moveTo(dx, y)
          ..cubicTo(dx + 20, y - 6, dx + 40, y + 6, dx + 60, y);
        canvas.drawPath(path, base..strokeWidth = 2.5 - l * .3);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _WindPainter old) =>
      old.t != t || old.color != color || old.layers != layers;
}
