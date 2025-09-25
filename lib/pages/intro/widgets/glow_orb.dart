// lib/pages/intro/widgets/background/glow_orb.dart
import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';

/// Ein weicher, glühender Kreis, der sanft driftet.
/// Positionierung mit relativen x/y (0..1). Kein Positioned nötig.
class GlowOrb extends StatefulWidget {
  final double size;
  final double x;        // 0..1
  final double y;        // 0..1
  final double speedSec; // größer = langsamer Drift
  final double blur;     // Weichzeichnung
  final double opacity;

  const GlowOrb({
    super.key,
    required this.size,
    required this.x,
    required this.y,
    this.speedSec = 24,
    this.blur = 16,
    this.opacity = 0.32,
  });

  @override
  State<GlowOrb> createState() => _GlowOrbState();
}

class _GlowOrbState extends State<GlowOrb> with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: Duration(seconds: widget.speedSec.toInt()),
    )..repeat();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme.primary;

    // Alignment aus relativen (0..1) Koordinaten ableiten: (-1..1)
    final baseAlignment = Alignment(widget.x * 2 - 1, widget.y * 2 - 1);

    return AnimatedBuilder(
      animation: _ctrl,
      builder: (context, _) {
        final t = _ctrl.value * 2 * pi;
        // sanfter Drift in Alignment-Raum (Prozent, nicht Pixel)
        final driftX = sin(t) * 0.015; // ~1.5% der Breite
        final driftY = cos(t) * 0.015;

        return LayoutBuilder(
          builder: (context, c) {
            // Pixel-Offset für den Drift (wirkt natürlicher als nur Alignment)
            final px = c.maxWidth * driftX;
            final py = c.maxHeight * driftY;

            return Align(
              alignment: baseAlignment,
              child: Transform.translate(
                offset: Offset(px, py),
                child: IgnorePointer(
                  ignoring: true,
                  child: ImageFiltered(
                    imageFilter: ImageFilter.blur(sigmaX: widget.blur, sigmaY: widget.blur),
                    child: Container(
                      width: widget.size,
                      height: widget.size,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(
                          colors: [
                            color.withOpacity(widget.opacity),
                            color.withOpacity(0.0),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}
