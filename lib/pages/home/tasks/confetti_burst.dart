import 'dart:math';
import 'package:flutter/material.dart';

void showConfettiBurst(BuildContext context, Offset globalTapPosition) {
  final overlay = Overlay.of(context, rootOverlay: true);
  if (overlay == null) return;

  final box = overlay.context.findRenderObject() as RenderBox;
  final local = box.globalToLocal(globalTapPosition);

  late OverlayEntry entry;
  entry = OverlayEntry(
    builder: (_) => Positioned.fill(
      child: _ConfettiLayer(origin: local, onDone: () => entry.remove()),
    ),
  );
  overlay.insert(entry);
}

class _ConfettiLayer extends StatefulWidget {
  const _ConfettiLayer({required this.origin, required this.onDone});
  final Offset origin;
  final VoidCallback onDone;

  @override
  State<_ConfettiLayer> createState() => _ConfettiLayerState();
}

class _ConfettiLayerState extends State<_ConfettiLayer>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final List<_Particle> _ps;
  final rnd = Random();

  @override
  void initState() {
    super.initState();

    _ps = List.generate(80, (_) => _Particle());
    _resetParticles();

    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    )
      ..addListener(() {
        _tick(1 / 60);
        setState(() {});
      })
      ..addStatusListener((s) {
        if (s == AnimationStatus.completed) widget.onDone();
      });

    _ctrl.forward();
  }

  void _resetParticles() {
    const base = 240.0;
    for (final p in _ps) {
      final a = rnd.nextDouble() * pi * 2;
      final v = base * (0.55 + rnd.nextDouble());
      p.pos = widget.origin;
      p.vel = Offset(cos(a) * v, sin(a) * v - 80);
      p.size = 6 + rnd.nextDouble() * 10;
      p.color = _palette[rnd.nextInt(_palette.length)];
      p.life = 1;
      p.rot = rnd.nextDouble() * pi;
      p.shape = _Shape.values[rnd.nextInt(_Shape.values.length)];
    }
  }

  void _tick(double dt) {
    for (final p in _ps) {
      if (p.life <= 0) continue;
      p.vel += const Offset(0, 650) * dt;
      p.pos += p.vel * dt;
      p.rot += 5 * dt;
      p.life -= 1.1 * dt;
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      ignoring: true,
      child: CustomPaint(painter: _ConfettiPainter(_ps)),
    );
  }
}

enum _Shape { circle, rect, triangle }

class _Particle {
  Offset pos = Offset.zero;
  Offset vel = Offset.zero;
  double size = 8;
  double life = 1;
  double rot = 0;
  Color color = Colors.red;
  _Shape shape = _Shape.circle;
}

const _palette = <Color>[
  Color(0xFFE53935), // rot
  Color(0xFFFFB300), // amber
  Color(0xFF43A047), // grün
  Color(0xFF1E88E5), // blau
  Color(0xFF8E24AA), // lila
  Color(0xFFFF7043), // orange
];

class _ConfettiPainter extends CustomPainter {
  _ConfettiPainter(this.ps);
  final List<_Particle> ps;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..isAntiAlias = true;

    for (final p in ps) {
      if (p.life <= 0) continue;
      paint.color = p.color.withOpacity(p.life.clamp(0, 1));
      final s = p.size;

      canvas.save();
      canvas.translate(p.pos.dx, p.pos.dy);
      canvas.rotate(p.rot);

      switch (p.shape) {
        case _Shape.circle:
          canvas.drawCircle(Offset.zero, s / 2, paint);
          break;
        case _Shape.rect:
          canvas.drawRRect(
            RRect.fromRectAndRadius(
              Rect.fromCenter(center: Offset.zero, width: s, height: s * .7),
              const Radius.circular(2),
            ),
            paint,
          );
          break;
        case _Shape.triangle:
          final path = Path()
            ..moveTo(0, -s / 2)
            ..lineTo(s / 2, s / 2)
            ..lineTo(-s / 2, s / 2)
            ..close();
          canvas.drawPath(path, paint);
          break;
      }

      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant _ConfettiPainter oldDelegate) => true;
}
