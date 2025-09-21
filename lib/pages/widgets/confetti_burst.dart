// lib/pages/widgets/confetti_burst.dart
import 'dart:math';
import 'package:flutter/material.dart';

/// Explosion aus buntem Konfetti an der globalen Klick-Position.
void showConfettiBurst(BuildContext context, Offset globalTapPosition) {
  final overlay = Overlay.of(context, rootOverlay: true);
  if (overlay == null) return;

  // global -> local, relativ zum Overlay
  final box = overlay.context.findRenderObject() as RenderBox;
  final local = box.globalToLocal(globalTapPosition);

  // Overlay-Ebene einblenden
  late OverlayEntry entry;
  entry = OverlayEntry(
    builder: (_) => Positioned.fill(
      child: _ConfettiLayer(
        origin: local,
        onDone: () => entry.remove(),
      ),
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

    // Partikel anlegen
    _ps = List.generate(80, (_) => _Particle.zero());
    _initParticles();

    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    )
      ..addListener(() {
        _step(1 / 60); // ~60 FPS
        setState(() {});
      })
      ..addStatusListener((s) {
        if (s == AnimationStatus.completed) widget.onDone();
      });

    _ctrl.forward();
  }

  void _initParticles() {
    const baseSpeed = 240.0;
    for (final p in _ps) {
      final angle = rnd.nextDouble() * pi * 2;
      final speed = baseSpeed * (0.55 + rnd.nextDouble());
      p.pos = widget.origin;
      p.vel = Offset(cos(angle) * speed, sin(angle) * speed - 80); // etwas up
      p.size = 6 + rnd.nextDouble() * 10;
      p.color = _palette[rnd.nextInt(_palette.length)];
      p.life = 1.0;
      p.rot = rnd.nextDouble() * pi;
      p.type = _Shape.values[rnd.nextInt(_Shape.values.length)];
    }
  }

  void _step(double dt) {
    // simple Physik
    for (final p in _ps) {
      if (p.life <= 0) continue;
      p.vel += const Offset(0, 650) * dt; // Gravitation
      p.pos += p.vel * dt;
      p.rot += 5 * dt;
      p.life -= 1.1 * dt; // ausfaden
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
      child: CustomPaint(
        painter: _ConfettiPainter(_ps),
      ),
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
  _Shape type = _Shape.circle;

  _Particle.zero();
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

      switch (p.type) {
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
