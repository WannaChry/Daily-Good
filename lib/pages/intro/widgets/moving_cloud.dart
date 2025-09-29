import 'dart:math';
import 'dart:ui' show lerpDouble;
import 'package:flutter/material.dart';

class MovingCloud extends StatefulWidget {
  final double startX;
  final double endX;
  final double y;
  final double scale;
  final int seconds;

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
        final v = _ctrl.value;
        final eased = 0.5 - 0.5 * cos(v * pi);
        final x = lerpDouble(widget.startX, widget.endX, eased)!;

        return LayoutBuilder(
          builder: (context, c) {
            final alignX = (x - 0.5) * 2;
            final alignY = (widget.y - 0.5) * 2;

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
