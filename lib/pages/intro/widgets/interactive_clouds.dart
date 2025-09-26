// lib/profil/intro/widgets/interactive_clouds.dart
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Step E: Haptik

/// Drei schwebende Wolken, frei ziehbar.
/// - Während Drag: leichtes Scaling + Rotation (kein Quetschen)
/// - Nach Loslassen: träge Weiterbewegung und sanftes Auslaufen (kein Snap-Back)
class InteractiveClouds extends StatefulWidget {
  const InteractiveClouds({
    super.key,
    this.initial = const [
      Offset(0.18, 0.12),
      Offset(0.78, 0.10),
      Offset(0.25, 0.78),
    ],
    this.sizes = const [160.0, 130.0, 110.0],
    this.floatAmplitude = 6.0,
    this.floatPeriod = const Duration(seconds: 8),
  });

  /// Startpositionen relativ zur Bildschirmgröße (0..1)
  final List<Offset> initial;

  /// Grundgrößen der Wolken
  final List<double> sizes;

  /// Amplitude der „Schwebe“-Bewegung (Pixel)
  final double floatAmplitude;

  /// Dauer eines Float-Zyklus
  final Duration floatPeriod;

  @override
  State<InteractiveClouds> createState() => _InteractiveCloudsState();
}

class _InteractiveCloudsState extends State<InteractiveClouds>
    with TickerProviderStateMixin {
  late final AnimationController _floatCtl =
  AnimationController(vsync: this, duration: widget.floatPeriod)..repeat();

  late final List<_Cloud> _clouds;
  int? _draggingIndex;

  @override
  void initState() {
    super.initState();
    final rnd = math.Random();
    _clouds = List.generate(widget.initial.length, (i) {
      return _Cloud(
        posRel: widget.initial[i],
        baseSize: widget.sizes[i],
        driftPhase: rnd.nextDouble() * 2 * math.pi,
        settleCtl: AnimationController(
          vsync: this,
          duration: const Duration(milliseconds: 900),
        ),
      );
    });
  }

  @override
  void dispose() {
    for (final c in _clouds) {
      c.settleCtl.dispose();
    }
    _floatCtl.dispose();
    super.dispose();
  }

  Offset _clampRel(Offset o) => Offset(o.dx.clamp(0.0, 1.0), o.dy.clamp(0.0, 1.0));

  @override
  Widget build(BuildContext context) {
    final screen = MediaQuery.of(context).size;

    return AnimatedBuilder(
      animation: _floatCtl,
      builder: (_, __) {
        final t = _floatCtl.value * 2 * math.pi; // 0..2π
        return Stack(
          children: List.generate(_clouds.length, (i) {
            final c = _clouds[i];

            // sanftes Floaten (während Drag reduziert)
            final floatY = widget.floatAmplitude *
                math.sin(t + c.driftPhase) *
                (_draggingIndex == i ? 0.15 : 1.0);

            final left = c.posRel.dx * screen.width - c.baseSize / 2;
            final top  = c.posRel.dy * screen.height - c.baseSize / 2 + floatY;

            return Positioned(
              left: left,
              top: top,
              width: c.baseSize,
              height: c.baseSize * 0.72, // Wolken wirken etwas flacher
              child: _CloudDraggable(
                index: i,
                onStart: () {
                  _draggingIndex = i;
                  c.dragScale = 1.02;   // minimal größer beim Drag
                  c.dragAngle = 0.06;   // dezenter „Lean“
                  c.settleCtl.stop();
                },
                onUpdate: (deltaPx) {
                  final rel = Offset(deltaPx.dx / screen.width, deltaPx.dy / screen.height);
                  setState(() => c.posRel = _clampRel(c.posRel + rel));
                },
                onEnd: (velocityPxPerSec) {
                  // Step E: Haptik
                  HapticFeedback.selectionClick();

                  // inertiales Weitergleiten: kleiner Boost in Velocity-Richtung
                  final boostRel = Offset(
                    (velocityPxPerSec.dx / screen.width) * 0.18,
                    (velocityPxPerSec.dy / screen.height) * 0.18,
                  );
                  final start = c.posRel;
                  final target = _clampRel(start + boostRel);

                  final curved = CurvedAnimation(
                    parent: c.settleCtl,
                    curve: Curves.easeOutCubic,
                  );

                  void tick() {
                    setState(() {
                      c.posRel = Offset.lerp(start, target, curved.value)!;
                      c.dragScale = 1.0;
                      c.dragAngle = 0.0;
                    });
                  }

                  void status(AnimationStatus s) {
                    if (s == AnimationStatus.completed) {
                      c.settleCtl.stop();
                      curved.removeListener(tick);
                      curved.removeStatusListener(status);
                      _draggingIndex = null;
                    }
                  }

                  curved.addListener(tick);
                  curved.addStatusListener(status);
                  c.settleCtl.forward(from: 0);
                },
                scale: c.dragScale,
                angle: c.dragAngle,
                child: const _PlainCloud(),
              ),
            );
          }),
        );
      },
    );
  }
}

/// Daten je Wolke
class _Cloud {
  _Cloud({
    required this.posRel,
    required this.baseSize,
    required this.driftPhase,
    required this.settleCtl,
  });

  Offset posRel;
  final double baseSize;
  final double driftPhase;

  // Drag-Style
  double dragScale = 1.0;
  double dragAngle = 0.0;

  // Animation für das Auslaufen nach dem Loslassen
  final AnimationController settleCtl;
}

/// Einfacher Wrapper, der Drag-Events liefert und Transform (Scale/Rotate) anwendet.
class _CloudDraggable extends StatelessWidget {
  const _CloudDraggable({
    required this.index,
    required this.onStart,
    required this.onUpdate,
    required this.onEnd,
    required this.child,
    this.scale = 1.0,
    this.angle = 0.0,
  });

  final int index;
  final VoidCallback onStart;
  final void Function(Offset deltaPx) onUpdate;
  final void Function(Offset velocityPxPerSec) onEnd;
  final Widget child;
  final double scale;
  final double angle;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onPanStart: (_) => onStart(),
      onPanUpdate: (d) => onUpdate(d.delta),
      onPanEnd: (d) => onEnd(d.velocity.pixelsPerSecond),
      child: Transform.rotate(
        angle: angle,
        child: Transform.scale(
          scale: scale,
          child: child,
        ),
      ),
    );
  }
}

/// Wolkenform ohne Gesicht (Gradient + sanfter Schatten)
class _PlainCloud extends StatelessWidget {
  const _PlainCloud();

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _CloudPainter(),
      child: const SizedBox.expand(),
    );
  }
}

class _CloudPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final h = size.height;
    final w = size.width;

    // Wolkenform: mehrere überlappende Kreise + weiche Basis
    final path = Path()
      ..addOval(Rect.fromCircle(center: Offset(w * .30, h * .45), radius: h * .34))
      ..addOval(Rect.fromCircle(center: Offset(w * .48, h * .35), radius: h * .38))
      ..addOval(Rect.fromCircle(center: Offset(w * .66, h * .46), radius: h * .33))
      ..addRRect(RRect.fromRectAndRadius(
        Rect.fromLTWH(w * .18, h * .35, w * .64, h * .38),
        Radius.circular(h * .22),
      ));

    // Schatten
    final shadowPaint = Paint()
      ..color = Colors.black.withOpacity(.08)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 14);
    canvas.save();
    canvas.translate(0, 2);
    canvas.drawPath(path, shadowPaint);
    canvas.restore();

    // Wolke (leichter Glanz)
    final cloudPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFFFFFFFF), Color(0xFFF5F5F5)],
      ).createShader(Offset.zero & size);
    canvas.drawPath(path, cloudPaint);
  }

  @override
  bool shouldRepaint(covariant _CloudPainter oldDelegate) => false;
}
