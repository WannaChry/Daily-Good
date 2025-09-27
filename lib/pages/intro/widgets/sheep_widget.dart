import 'dart:math';
import 'package:flutter/material.dart';

/// Stilisiertes Schaf, das hopst und mit kontinuierlicher Zeitbasis weit über die Wiese meandert.
/// Fix: eigener Zeitakkumulator → keine Resets mehr; echtes "Rumlaufen" statt Kreis.
class SheepSprite extends StatefulWidget {
  final double baseX;         // 0..1
  final double baseY;         // 0..1
  final double width;         // Pixelbreite des Schafs
  final double hopSeconds;    // Dauer für eine Hop-Periode
  final double wanderPixels;  // kleines „Tollen“ ±px (lokal)
  final bool flip;            // initiale Blickrichtung
  final double roamX;         // großer Horizontal-Drift (px)
  final double roamY;         // kleiner Vertikal-Drift (px)

  const SheepSprite({
    super.key,
    required this.baseX,
    required this.baseY,
    this.width = 72,
    this.hopSeconds = 3.2,
    this.wanderPixels = 16,
    this.flip = false,
    this.roamX = 160,
    this.roamY = 12,
  });

  @override
  State<SheepSprite> createState() => _SheepSpriteState();
}

class _SheepSpriteState extends State<SheepSprite> with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  final _rand = Random();

  // kontinuierliche Zeit
  late int _lastMs;
  double _elapsed = 0.0; // Sekunden

  // zufällige Startphasen
  late double _pHop;
  late double _pRoamX;
  late double _pRoamY;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: (widget.hopSeconds * 1000).round()),
    )..addListener(_tick)
      ..repeat();

    _lastMs = DateTime.now().millisecondsSinceEpoch;

    _pHop   = _rand.nextDouble() * 2 * pi;
    _pRoamX = _rand.nextDouble() * 2 * pi;
    _pRoamY = _rand.nextDouble() * 2 * pi;
  }

  void _tick() {
    final now = DateTime.now().millisecondsSinceEpoch;
    final dt = (now - _lastMs) / 1000.0;
    _lastMs = now;
    _elapsed += dt; // → kontinuierlich, kein Reset mehr
    setState(() {});
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final v = (_ctrl.value + _pHop / (2 * pi)) % 1.0;

    // Hop (klein) + lokales Wackeln
    final hopY = (sin(v * 2 * pi) * 8).clamp(-8, 8).toDouble();
    final jitterX = sin(v * 2 * pi * 0.8) * widget.wanderPixels;

    // Weit-Drift (verschiedene Frequenzen → keine Kreisbahn)
    final roamX = sin(_pRoamX + _elapsed * 0.18) * widget.roamX;
    final roamY = sin(_pRoamY + _elapsed * 0.13) * widget.roamY;

    // Blickrichtung aus der X-Ableitung
    final dx = 0.18 * cos(_pRoamX + _elapsed * 0.18) * widget.roamX
        + 0.8  * cos(v * 2 * pi * 0.8) * widget.wanderPixels;
    final dynamicFlip = dx < 0;
    final flipNow = widget.flip ^ dynamicFlip;

    // Alignment (0..1 → -1..1)
    final alignX = (widget.baseX - 0.5) * 2;
    final alignY = (widget.baseY - 0.5) * 2;

    return Align(
      alignment: Alignment(alignX, alignY),
      child: Transform.translate(
        offset: Offset(jitterX + roamX, hopY + roamY),
        child: _Sheep(width: widget.width, flip: flipNow, legPhase: v),
      ),
    );
  }
}

class _Sheep extends StatelessWidget {
  final double width;
  final bool flip;
  final double legPhase; // 0..1

  const _Sheep({required this.width, this.flip = false, required this.legPhase});

  @override
  Widget build(BuildContext context) {
    final bodyColor = Colors.white;
    final woolShadow = Colors.black.withOpacity(0.08);
    final headColor = const Color(0xFF333333);
    final earColor = const Color(0xFF444444);

    final scaleX = flip ? -1.0 : 1.0;

    return Transform(
      alignment: Alignment.center,
      transform: Matrix4.diagonal3Values(scaleX, 1, 1),
      child: SizedBox(
        width: width,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            // Schatten
            Positioned(
              left: 8, right: 8, bottom: -4,
              child: Container(
                height: 6,
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),

            // Körper (Wolle)
            Container(
              height: width * 0.62,
              decoration: BoxDecoration(
                color: bodyColor,
                borderRadius: BorderRadius.circular(width * 0.32),
                boxShadow: [BoxShadow(color: woolShadow, blurRadius: 10, offset: const Offset(0, 6))],
              ),
            ),

            // Kopf
            Positioned(
              right: -width * 0.10,
              top: width * 0.10,
              child: Container(
                width: width * 0.34,
                height: width * 0.28,
                decoration: BoxDecoration(
                  color: headColor,
                  borderRadius: BorderRadius.circular(width * 0.12),
                ),
              ),
            ),

            // Ohr
            Positioned(
              right: -width * 0.02,
              top: width * 0.06,
              child: Transform.rotate(
                angle: -0.4,
                child: Container(
                  width: width * 0.14,
                  height: width * 0.08,
                  decoration: BoxDecoration(
                    color: earColor,
                    borderRadius: BorderRadius.circular(width * 0.06),
                  ),
                ),
              ),
            ),

            // Auge
            Positioned(
              right: -width * 0.02 + width * 0.10,
              top: width * 0.14,
              child: Container(
                width: width * 0.05,
                height: width * 0.05,
                decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                child: Center(
                  child: Container(
                    width: width * 0.02,
                    height: width * 0.02,
                    decoration: const BoxDecoration(color: Colors.black, shape: BoxShape.circle),
                  ),
                ),
              ),
            ),

            // Zwei Beine (asynchron)
            Positioned(
              left: width * 0.20,
              bottom: -width * 0.06,
              child: _leg(width, phase: legPhase, offsetPhase: 0.0),
            ),
            Positioned(
              left: width * 0.38,
              bottom: -width * 0.06,
              child: _leg(width, phase: legPhase, offsetPhase: 0.5),
            ),
          ],
        ),
      ),
    );
  }

  Widget _leg(double w, {required double phase, required double offsetPhase}) {
    final p = (phase + offsetPhase) % 1.0;
    final angle = sin(p * 2 * pi) * 0.25;

    return Transform.rotate(
      angle: angle,
      alignment: Alignment.topCenter,
      child: Container(
        width: w * 0.06,
        height: w * 0.22,
        decoration: BoxDecoration(
          color: const Color(0xFF333333),
          borderRadius: BorderRadius.circular(w * 0.02),
        ),
      ),
    );
  }
}
