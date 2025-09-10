import 'dart:async';
import 'package:flutter/material.dart';

/// Splash: Logo zoomt ein, Screen färbt sich per Left→Right-Wipe von schwarz zu grün.
class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ac;
  late final Animation<double> _logoScale;
  late final Animation<double> _logoYOffset;
  late final Animation<double> _wipe; // 0..1 (Breite des grünen Wipes)

  @override
  void initState() {
    super.initState();
    _ac = AnimationController(vsync: this, duration: const Duration(milliseconds: 1600));

    _logoScale = CurvedAnimation(parent: _ac, curve: const Interval(0.0, 0.55, curve: Curves.easeOutBack));
    _logoYOffset = CurvedAnimation(parent: _ac, curve: const Interval(0.0, 0.55, curve: Curves.easeOut));
    _wipe       = CurvedAnimation(parent: _ac, curve: const Interval(0.35, 1.0, curve: Curves.easeInOutCubic));

    _ac.forward();

    Timer(const Duration(milliseconds: 1850), () {
      if (mounted) Navigator.of(context).pushReplacementNamed('/onboarding');
    });
  }

  @override
  void dispose() {
    _ac.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ac,
      builder: (_, __) {
        return Scaffold(
          body: Stack(
            fit: StackFit.expand,
            children: [
              Container(color: Colors.black), // Basis
              Align(
                alignment: Alignment.centerLeft,
                child: FractionallySizedBox(
                  widthFactor: _wipe.value,
                  child: Container(color: const Color(0xFF67A85B)),
                ),
              ),
              Center(
                child: Transform.translate(
                  offset: Offset(0, -18 * _logoYOffset.value),
                  child: Transform.scale(
                    scale: 0.85 + 0.15 * _logoScale.value,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: const [
                        Icon(Icons.spa_rounded, size: 96, color: Colors.white),
                        SizedBox(height: 14),
                        Text(
                          'Daily Good',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w900,
                            fontSize: 28,
                            letterSpacing: .3,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
