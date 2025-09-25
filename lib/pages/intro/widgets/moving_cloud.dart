import 'dart:math';
import 'dart:ui' show lerpDouble; // <- für lerpDouble
import 'package:flutter/material.dart';

/// Eine stilisierte Wolke, die von links nach rechts driftet und danach looped.
/// Positionsangabe in relativen Koordinaten (-0.5 .. 1.5), y in 0..1.
class MovingCloud extends StatefulWidget {
  final double startX;   // z.B. -0.25 (links außerhalb)
  final double endX;     // z.B. 1.25 (rechts außerhalb)
  final double y;        // 0..1 (Höhe)
  final double scale;    // 0.6 .. 1.2
  final int seconds;     // Dauer für eine komplette Passage

  const MovingCloud({
    super.key,
    required this.startX,
    required this.endX,
    required this.y,
    this.scale = 1.0,
    this.seconds = 60,
  });

  @override
  State<MovingCloud> createState() => _MovingCloudState();
}

class _MovingCloudState extends State<MovingCloud> with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: Duration(seconds: widget.seconds),
    )..repeat();
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
        final v = _ctrl.value; // 0..1
        // Ease in-out für sanftere Bewegung
        final eased = 0.5 - 0.5 * cos(v * pi);
        final x = lerpDouble(widget.startX, widget.endX, eased)!; // -0.25..1.25

        return LayoutBuilder(
          builder: (context, c) {
            // Alignment.x nimmt -1..1 → wir mappen -0.5..1.5 → -1..1
            final alignX = (x - 0.5) * 2;
            final alignY = (widget.y - 0.5) * 2;

            // leichte Auf-/Abbewegung
            final driftYpx = sin(v * 2 * pi) * 8 * widget.scale;

            return Align(
              alignment: Alignment(alignX, alignY),
              child: Transform.translate(
                offset: Offset(0, driftYpx),
                child: Transform.scale(
                  scale: widget.scale,
                  child: _CloudShape(),
                ),
              ),
            );
          },
        );
      },
    );
  }
}

class _CloudShape extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final body = isDark ? const Color(0xFFEDF2F7) : const Color(0xFFF6FAFF);
    final edge = isDark ? Colors.white.withValues(alpha: 0.8) : Colors.black12;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
      decoration: BoxDecoration(
        color: body,
        borderRadius: BorderRadius.circular(40),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.10 : 0.06),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
        border: Border.all(color: edge, width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _bubble(26), const SizedBox(width: 8),
          _bubble(36), const SizedBox(width: 8),
          _bubble(28),
        ],
      ),
    );
  }

  Widget _bubble(double size) => Container(
    width: size, height: size,
    decoration: const BoxDecoration(
      color: Colors.white, shape: BoxShape.circle,
    ),
  );
}
