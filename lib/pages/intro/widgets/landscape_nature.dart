import 'dart:math';
import 'package:flutter/material.dart';

class PineTree extends StatelessWidget {
  final double scale;
  const PineTree({super.key, this.scale = 1.0});

  @override
  Widget build(BuildContext context) {
    return Transform.scale(
      scale: scale,
      child: SizedBox(
        width: 90,
        height: 140,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Positioned(
              left: 40, bottom: 0,
              child: Container(
                width: 12, height: 34,
                decoration: BoxDecoration(
                  color: const Color(0xFF7A4E2B),
                  borderRadius: BorderRadius.circular(6),
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.12), blurRadius: 4, offset: const Offset(0, 2))],
                ),
              ),
            ),
            _pineLayer(w: 90, h: 44, y: 24, color: const Color(0xFF2D6B3C)),
            _pineLayer(w: 74, h: 38, y: 48, color: const Color(0xFF36824A)),
            _pineLayer(w: 58, h: 32, y: 70, color: const Color(0xFF3E9A57)),
            Positioned(
              left: 45 - 4, bottom: 104,
              child: Container(width: 8, height: 18, decoration: BoxDecoration(color: const Color(0xFF3E9A57), borderRadius: BorderRadius.circular(4))),
            ),
            _cone(x: 54, yBot: 56, scale: 1.0),
            _cone(x: 30, yBot: 42, scale: 0.9),
            _cone(x: 62, yBot: 80, scale: 0.85),
          ],
        ),
      ),
    );
  }

  Widget _pineLayer({required double w, required double h, required double y, required Color color}) {
    return Positioned(
      left: (90 - w) / 2, bottom: y,
      child: CustomPaint(size: Size(w, h), painter: _TrianglePainter(color)),
    );
  }

  Widget _cone({required double x, required double yBot, required double scale}) {
    return Positioned(
      left: x, bottom: yBot,
      child: Transform.scale(
        scale: scale,
        child: Container(
          width: 10, height: 14,
          decoration: BoxDecoration(
            color: const Color(0xFF8C5A3C),
            borderRadius: BorderRadius.circular(6),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.18), blurRadius: 3, offset: const Offset(0, 1))],
          ),
        ),
      ),
    );
  }
}

class _TrianglePainter extends CustomPainter {
  final Color color;
  _TrianglePainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final path = Path()
      ..moveTo(0, 0)
      ..lineTo(size.width / 2, size.height)
      ..lineTo(size.width, 0)
      ..close();
    final paint = Paint()..color = color;
    canvas.drawPath(path, paint);

    final hl = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter, end: Alignment.bottomCenter,
        colors: [Colors.white.withOpacity(0.04), Colors.white.withOpacity(0.10)],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));
    canvas.drawPath(path, hl);
  }

  @override
  bool shouldRepaint(covariant _TrianglePainter old) => old.color != color;
}

class BerryBush extends StatelessWidget {
  final double scale;
  const BerryBush({super.key, this.scale = 1.0});

  @override
  Widget build(BuildContext context) {
    const greens = [Color(0xFF45A957), Color(0xFF3F9E51), Color(0xFF4FC163)];
    const berry = Color(0xFFDC3B4D);

    Widget ball(Color c, double s, Offset o) => Positioned(
      left: o.dx, top: o.dy,
      child: Container(
        width: s, height: s,
        decoration: BoxDecoration(
          color: c, shape: BoxShape.circle,
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.12), blurRadius: 4, offset: const Offset(0, 2))],
        ),
      ),
    );

    Widget dot(Offset o) =>
        Positioned(left: o.dx, top: o.dy, child: Container(width: 6, height: 6, decoration: const BoxDecoration(color: berry, shape: BoxShape.circle)));

    return Transform.scale(
      scale: scale,
      child: SizedBox(
        width: 90, height: 44,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            ball(greens[1], 34, const Offset(8, 10)),
            ball(greens[0], 40, const Offset(24, 6)),
            ball(greens[2], 30, const Offset(52, 12)),
            dot(const Offset(26, 14)),
            dot(const Offset(58, 18)),
            dot(const Offset(40, 8)),
          ],
        ),
      ),
    );
  }
}

class Pond extends StatelessWidget {
  final double width;
  final double height;
  const Pond({super.key, this.width = 140, this.height = 60});

  @override
  Widget build(BuildContext context) => CustomPaint(size: Size(width, height), painter: _PondPainter());
}

class _PondPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final rect = Rect.fromLTWH(0, 0, size.width, size.height);
    final r = RRect.fromRectAndRadius(rect, const Radius.circular(40));

    final fill = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topLeft, end: Alignment.bottomRight,
        colors: [const Color(0xFFBEE6FF), const Color(0xFF7CC6F5)],
      ).createShader(rect);
    final stroke = Paint()
      ..color = const Color(0xFF4FA7D8)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    canvas.drawRRect(r, fill);
    canvas.drawRRect(r, stroke);

    final glare = Paint()..color = Colors.white.withOpacity(0.35);
    canvas.drawOval(Rect.fromLTWH(size.width * 0.15, size.height * 0.18, size.width * 0.45, size.height * 0.28), glare);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class SwayingGrass extends StatefulWidget {
  final int layers;
  final double height;
  const SwayingGrass({super.key, this.layers = 3, this.height = 80});

  @override
  State<SwayingGrass> createState() => _SwayingGrassState();
}

class _SwayingGrassState extends State<SwayingGrass> with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(seconds: 6))..repeat();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (context, _) => CustomPaint(
        size: Size.infinite,
        painter: _GrassFieldPainter(widget.layers, widget.height, _ctrl.value),
      ),
    );
  }
}

class _GrassFieldPainter extends CustomPainter {
  final int layers;
  final double height;
  final double t;
  _GrassFieldPainter(this.layers, this.height, this.t);

  @override
  void paint(Canvas canvas, Size size) {
    final rnd = Random(42);
    final baseY = size.height;
    final wind = sin(t * 2 * pi) * 0.35;

    for (int layer = 0; layer < layers; layer++) {
      final color = [
        const Color(0xFF4DAE57),
        const Color(0xFF3F984A),
        const Color(0xFF368642),
      ][layer % 3];

      final blades = 24 + layer * 10;
      final hMul = 0.6 + 0.25 * layer;
      final amp = (0.6 + layer * 0.2) * wind;

      for (int i = 0; i < blades; i++) {
        final x = (i / (blades - 1)) * size.width + rnd.nextDouble() * 6 - 3;
        final h = height * (0.45 + rnd.nextDouble() * 0.6) * hMul;
        final sway = amp * (0.8 + rnd.nextDouble() * 0.4);

        final path = Path()
          ..moveTo(x, baseY)
          ..quadraticBezierTo(x + 6 * sway, baseY - h * 0.55, x + 8 * sway, baseY - h)
          ..quadraticBezierTo(x + 3 * sway, baseY - h * 0.35, x, baseY)
          ..close();

        canvas.drawPath(path, Paint()..color = color);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _GrassFieldPainter old) => old.t != t || old.height != height || old.layers != layers;
}

class GrassTuftWave extends StatefulWidget {
  final double width;
  final double height;
  final double speed;
  const GrassTuftWave({super.key, this.width = 80, this.height = 30, this.speed = 1.4});

  @override
  State<GrassTuftWave> createState() => _GrassTuftWaveState();
}

class _GrassTuftWaveState extends State<GrassTuftWave> with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: Duration(milliseconds: (1200 ~/ widget.speed)))
      ..repeat();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (context, _) {
        final s = 0.5 + 0.5 * sin(_ctrl.value * 2 * pi);
        return CustomPaint(size: Size(widget.width, widget.height), painter: _TuftPainter(s));
      },
    );
  }
}

class _TuftPainter extends CustomPainter {
  final double s;
  _TuftPainter(this.s);

  @override
  void paint(Canvas canvas, Size size) {
    final base = const Color(0xFF4AAE56);
    final dark = const Color(0xFF3C8E46);

    for (int i = 0; i < 7; i++) {
      final x = i * (size.width / 6);
      final h = size.height * (0.7 + (i % 2 == 0 ? 0.2 : 0.0));
      final sway = (i.isEven ? -1 : 1) * (0.6 + 0.6 * s);

      final path = Path()
        ..moveTo(x, size.height)
        ..quadraticBezierTo(x + 4 * sway, size.height - h * 0.55, x + 6 * sway, size.height - h)
        ..quadraticBezierTo(x + 2 * sway, size.height - h * 0.35, x, size.height)
        ..close();

      canvas.drawPath(path, Paint()..color = i.isEven ? base : dark);
    }
  }

  @override
  bool shouldRepaint(covariant _TuftPainter old) => old.s != s;
}
