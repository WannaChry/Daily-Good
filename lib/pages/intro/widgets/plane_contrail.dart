import 'dart:math';
import 'package:flutter/material.dart';

/// Einfaches Flugzeug, das LANGSAM von links nach rechts fliegt
/// und kleine Kondensstreifen hinter sich herzieht.
class PlaneContrail extends StatefulWidget {
  final double startX;   // relativ: -0.3..1.3
  final double endX;     // relativ: -0.3..1.3
  final double y;        // 0..1 (Höhe)
  final int seconds;     // Dauer eines Flugs
  final int segments;    // Anzahl Trail-Elemente
  final double spacing;  // Abstand zwischen Elementen (px)

  const PlaneContrail({
    super.key,
    this.startX = -0.35,
    this.endX = 1.35,
    this.y = 0.16,
    this.seconds = 50,
    this.segments = 14,
    this.spacing = 12,
  });

  @override
  State<PlaneContrail> createState() => _PlaneContrailState();
}

class _PlaneContrailState extends State<PlaneContrail> with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: Duration(seconds: widget.seconds))..repeat();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AnimatedBuilder(
      animation: _ctrl,
      builder: (context, _) {
        final v = _ctrl.value;                       // 0..1
        final eased = 0.5 - 0.5 * cos(v * pi);       // smooth in/out
        final x = widget.startX + (widget.endX - widget.startX) * eased;

        // sanftes Schweben
        final bob = sin(v * 2 * pi * 1.1) * 2.4;

        final alignX = (x - 0.5) * 2;
        final alignY = (widget.y - 0.5) * 2;

        // Trail wächst beim Reinfliegen
        final visible = (widget.segments * (eased * 1.4).clamp(0.0, 1.0)).floor();

        return Align(
          alignment: Alignment(alignX, alignY),
          child: Transform.translate(
            offset: Offset(0, bob),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _ContrailBar(count: visible, spacing: widget.spacing, dark: isDark),
                const SizedBox(width: 10),
                const _PlaneIconRight(), // <-- Nase rechts, Leitwerk links (korrekt)
              ],
            ),
          ),
        );
      },
    );
  }
}

class _ContrailBar extends StatelessWidget {
  final int count;
  final double spacing;
  final bool dark;
  const _ContrailBar({required this.count, required this.spacing, required this.dark});

  @override
  Widget build(BuildContext context) {
    final dots = <Widget>[];
    for (int i = count - 1; i >= 0; i--) {
      final t = count == 0 ? 0.0 : i / count;              // 0..1
      final alpha = (dark ? 0.65 : 0.55) * (0.35 + 0.65 * (1 - t));
      final size = 6.0 + 3.0 * (1 - t);
      dots.add(Transform.translate(
        offset: Offset(-i * spacing, 0),
        child: Container(
          width: size, height: size,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(alpha),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(dark ? 0.12 : 0.08),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
        ),
      ));
    }
    return Stack(clipBehavior: Clip.none, children: dots);
  }
}

/// Flugzeug (Nase eindeutig NACH RECHTS, Leitwerk links)
class _PlaneIconRight extends StatelessWidget {
  const _PlaneIconRight();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final fuselage = isDark ? const Color(0xFFEAF0F7) : const Color(0xFFFDFEFF);
    final wing     = isDark ? const Color(0xFFB8C5D8) : const Color(0xFFD9E6F6);
    final window   = const Color(0xFF6BB7FF);

    return SizedBox(
      width: 56,
      height: 26,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Rumpf
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                color: fuselage,
                borderRadius: BorderRadius.circular(14),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.10), blurRadius: 6, offset: const Offset(0, 3))],
              ),
            ),
          ),

          // Leitwerk LINKS (hinten)
          Positioned(
            left: -2, top: -2,
            child: Container(
              width: 10, height: 10,
              decoration: BoxDecoration(color: wing, borderRadius: BorderRadius.circular(4)),
            ),
          ),

          // Hauptflügel mittig
          Positioned(
            left: 20, bottom: -3,
            child: Container(width: 20, height: 8, decoration: BoxDecoration(color: wing, borderRadius: BorderRadius.circular(6))),
          ),

          // Nase RECHTS (vorne)
          Positioned(
            right: -8, top: 5, bottom: 5,
            child: CustomPaint(size: const Size(10, 16), painter: _NosePainter(fuselage)),
          ),

          // Cockpit-Fenster NAHE der Nase
          Positioned(right: 12, top: 6, child: _dot(window, 10)),
        ],
      ),
    );
  }

  Widget _dot(Color c, double s) =>
      Container(width: s, height: s, decoration: BoxDecoration(color: c, shape: BoxShape.circle));
}

class _NosePainter extends CustomPainter {
  final Color color;
  _NosePainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final path = Path()
      ..moveTo(0, 0)
      ..lineTo(size.width, size.height / 2)
      ..lineTo(0, size.height)
      ..close();
    canvas.drawPath(path, Paint()..color = color);
  }

  @override
  bool shouldRepaint(covariant _NosePainter old) => old.color != color;
}
