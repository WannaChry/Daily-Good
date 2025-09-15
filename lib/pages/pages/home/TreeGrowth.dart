import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// ==================== Vorhandene Widgets: Baum + Progress ====================
class TreeGrowth extends StatelessWidget {
  const TreeGrowth({required this.points, required this.target});

  final int points;
  final int target;

  @override
  Widget build(BuildContext context) {
    final progress = (points / target).clamp(0.0, 1.0);
    final stage = (points / 5).floor().clamp(0, 5); // 0..5 (bei Ziel 25)

    final String emoji =
    stage >= 4 ? '🌳' : stage >= 2 ? '🌿' : '🌱';

    final double size = lerpDouble(52, 86, progress)!;

    return Container(
      height: 160,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFFEFF7EA),
            Color(0xFFDFF0D8),
          ],
        ),
        border: Border.all(color: Colors.black12),
        boxShadow: const [
          BoxShadow(
            color: Color(0x10000000),
            blurRadius: 14,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned.fill(
            child: IgnorePointer(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Colors.white.withOpacity(0.20),
                      Colors.white.withOpacity(0.06),
                    ],
                  ),
                ),
              ),
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              height: 28,
              margin: const EdgeInsets.symmetric(horizontal: 6),
              decoration: BoxDecoration(
                color: const Color(0xFFB9E0B0),
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          Align(
            alignment: Alignment.lerp(
              const Alignment(0.0, 0.5),
              const Alignment(0.0, 0.2),
              progress,
            )!,
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 350),
              switchInCurve: Curves.easeOutBack,
              switchOutCurve: Curves.easeIn,
              transitionBuilder: (child, anim) => ScaleTransition(
                scale: Tween<double>(begin: .92, end: 1).animate(anim),
                child: FadeTransition(opacity: anim, child: child),
              ),
              child: Text(
                emoji,
                key: ValueKey(emoji),
                style: TextStyle(fontSize: size),
              ),
            ),
          ),
          Positioned(
            right: 8,
            top: 8,
            child: Row(
              children: List.generate(5, (i) {
                final active = i < (points / 5).floor();
                return Padding(
                  padding: const EdgeInsets.only(left: 6),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 220),
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: active ? Colors.green.shade500 : Colors.white,
                      border: Border.all(
                        color: active
                            ? Colors.green.shade700
                            : Colors.black.withOpacity(0.08),
                      ),
                      boxShadow: active
                          ? [
                        BoxShadow(
                          color: Colors.green.shade300,
                          blurRadius: 6,
                          spreadRadius: 1,
                        )
                      ]
                          : [],
                    ),
                  ),
                );
              }),
            ),
          ),
          Align(
            alignment: Alignment.topLeft,
            child: Padding(
              padding: const EdgeInsets.only(top: 4, left: 2),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Dein Baum wächst',
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w800,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    points >= target
                        ? 'Maximal gewachsen 🌟'
                        : '${(progress * 100).round()}% des Tagesziels',
                    style: GoogleFonts.poppins(
                      fontSize: 12.5,
                      color: Colors.black.withOpacity(0.65),
                      fontWeight: FontWeight.w600,
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