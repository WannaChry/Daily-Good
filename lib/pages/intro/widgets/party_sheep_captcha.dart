import 'dart:math';
import 'package:flutter/material.dart';

/// USP-Captcha: kleine Schafe spazieren.
/// Aufgabe: "Wie viele Schafe spazieren?"
/// Jetzt mit dynamischer Anzahl 1..10 (per Refresh neu).
class PartySheepCaptcha extends StatefulWidget {
  final ValueChanged<int> onNewAnswer;
  final VoidCallback? onRefreshed;
  final int minCount;
  final int maxCount;
  final double fieldHeight;

  const PartySheepCaptcha({
    super.key,
    required this.onNewAnswer,
    this.onRefreshed,
    this.minCount = 1,
    this.maxCount = 10,
    this.fieldHeight = 90,
  });

  @override
  State<PartySheepCaptcha> createState() => _PartySheepCaptchaState();
}

class _PartySheepCaptchaState extends State<PartySheepCaptcha> with TickerProviderStateMixin {
  final _rnd = Random();
  late List<_SheepAnim> _sheep;

  @override
  void initState() {
    super.initState();
    _generate();
  }

  void _generate() {
    final total = widget.minCount + _rnd.nextInt(widget.maxCount - widget.minCount + 1);
    _sheep = List.generate(total, (i) {
      final speed = 0.7 + _rnd.nextDouble() * 0.9;       // 0.7..1.6
      final amp = 8.0 + _rnd.nextDouble() * 16.0;        // 8..24 px
      final phase = _rnd.nextDouble() * 2 * pi;
      final bobAmp = 1.5 + _rnd.nextDouble() * 1.8;      // 1.5..3.3 px
      final seedX = _rnd.nextDouble();                   // 0..1
      final lane  = _rnd.nextInt(3);                     // 3 Spuren
      final laneJitter = (_rnd.nextDouble() - 0.5) * 6.0;
      return _SheepAnim(
        speed: speed, amp: amp, phase: phase, bobAmp: bobAmp,
        seedX: seedX, lane: lane, laneJitter: laneJitter,
      );
    });

    widget.onNewAnswer(_sheep.length);
    widget.onRefreshed?.call();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final border = theme.colorScheme.outlineVariant.withOpacity(0.6);

    return Container(
      // ⬇️ oben weniger Padding
      padding: const EdgeInsets.fromLTRB(14, 8, 14, 14),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            const Text('Captcha', style: TextStyle(fontWeight: FontWeight.w700)),
            const Spacer(),
            IconButton(
              onPressed: _generate,
              tooltip: 'Neu laden',
              icon: const Icon(Icons.refresh_rounded),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
            ),
          ]),
          // ⬇️ kleinere Abstände
          const SizedBox(height: 2),
          Text('Wie viele Schafe spazieren?', style: theme.textTheme.bodyMedium),
          const SizedBox(height: 6),

          SizedBox(
            height: widget.fieldHeight,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Stack(
                children: [
                  // Wiese
                  Positioned.fill(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter, end: Alignment.bottomCenter,
                          colors: [const Color(0xFFEFFAEF), const Color(0xFFD9F3D9)],
                        ),
                      ),
                    ),
                  ),
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: Container(height: 2, color: const Color(0xFF97D497)),
                  ),
                  LayoutBuilder(
                    builder: (context, c) => Stack(
                      children: _sheep.map((s) => _SheepSpriteTiny(
                        anim: s, vsync: this,
                        fieldWidth: c.maxWidth, fieldHeight: widget.fieldHeight,
                      )).toList(),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SheepAnim {
  final double speed, amp, phase, bobAmp, seedX, laneJitter;
  final int lane;
  _SheepAnim({
    required this.speed, required this.amp, required this.phase, required this.bobAmp,
    required this.seedX, required this.lane, required this.laneJitter,
  });
}

class _SheepSpriteTiny extends StatefulWidget {
  final _SheepAnim anim;
  final TickerProvider vsync;
  final double fieldWidth, fieldHeight;
  const _SheepSpriteTiny({
    required this.anim, required this.vsync, required this.fieldWidth, required this.fieldHeight,
  });

  @override
  State<_SheepSpriteTiny> createState() => _SheepSpriteTinyState();
}

class _SheepSpriteTinyState extends State<_SheepSpriteTiny> with SingleTickerProviderStateMixin {
  late final AnimationController _c =
  AnimationController(vsync: widget.vsync, duration: const Duration(seconds: 6))..repeat();

  @override
  void dispose() { _c.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final a = widget.anim; final w = widget.fieldWidth; final h = widget.fieldHeight;
    final lanes = [h * 0.58, h * 0.66, h * 0.74];

    return AnimatedBuilder(
      animation: _c,
      builder: (context, _) {
        final t = _c.value * 2 * pi;
        final baseX = 12.0 + a.seedX * (w - 24.0);
        final x = baseX + sin(t * a.speed + a.phase) * a.amp;
        final baseY = lanes[a.lane] + a.laneJitter;
        final y = baseY + sin(t * (a.speed * 1.6) + a.phase) * a.bobAmp;
        final flip = cos(t * a.speed + a.phase) < 0;

        return Positioned(
          left: x, top: y - 10,
          child: Transform(
            alignment: Alignment.center,
            transform: Matrix4.diagonal3Values(flip ? -1 : 1, 1, 1),
            child: _tinySheep(),
          ),
        );
      },
    );
  }

  Widget _tinySheep() => SizedBox(
    width: 20, height: 14,
    child: Stack(
      clipBehavior: Clip.none,
      children: [
        Positioned.fill(
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 2, offset: const Offset(0, 1))],
            ),
          ),
        ),
        Positioned(right: -3, top: 3, child: _dot(const Color(0xFF333333), 7)),
        Positioned(right: 0.5, top: 5, child: _dot(Colors.white, 3)),
        Positioned(right: 1.3, top: 6.2, child: _dot(Colors.black, 1.6)),
        Positioned(left: 5, bottom: -2, child: _leg()),
        Positioned(left: 9, bottom: -2, child: _leg()),
      ],
    ),
  );

  Widget _dot(Color c, double s) => Container(width: s, height: s, decoration: BoxDecoration(color: c, shape: BoxShape.circle));
  Widget _leg() => Container(width: 1.6, height: 5, color: const Color(0xFF333333));
}
