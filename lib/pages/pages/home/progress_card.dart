import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ProgressCard extends StatelessWidget {
  const ProgressCard({super.key, required this.current, required this.target});

  final int current;
  final int target;

  @override
  Widget build(BuildContext context) {
    final clamped = current > target ? target : current;
    final progress = target == 0 ? 0.0 : (clamped / target).clamp(0.0, 1.0);

    const barH = 22.0;
    const knobR = 8.0;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.lightGreen.withOpacity(0.5),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.bolt_rounded, size: 28),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Erfülle Ziele um Punkte zu sammeln und lasse deine Pflanze wachsen',
                  style: GoogleFonts.poppins(
                    fontSize: 16.5,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          LayoutBuilder(
            builder: (context, c) {
              final w = c.maxWidth;

              return TweenAnimationBuilder<double>(
                tween: Tween<double>(begin: 0.0, end: progress),
                duration: const Duration(milliseconds: 650),
                curve: Curves.easeInOutCubic,
                builder: (context, value, _) {
                  final knobX = (w - 2 * knobR) * value;

                  return Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(999),
                        child: Container(height: barH, color: Colors.white),
                      ),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(999),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Container(
                            height: barH,
                            width: w * value,
                            color: Colors.green.shade400,
                          ),
                        ),
                      ),
                      Positioned(
                        left: knobX,
                        top: (barH - 2 * knobR) / 2,
                        child: AnimatedScale(
                          scale: 1.0,
                          duration: const Duration(milliseconds: 180),
                          child: Container(
                            width: 2 * knobR,
                            height: 2 * knobR,
                            decoration: BoxDecoration(
                              color: Colors.lightGreen.shade400,
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 2),
                            ),
                          ),
                        ),
                      ),
                      Positioned.fill(
                        child: Center(
                          child: AnimatedSwitcher(
                            duration: const Duration(milliseconds: 180),
                            transitionBuilder: (child, a) =>
                                ScaleTransition(scale: a, child: child),
                            child: Text(
                              '$clamped / $target',
                              key: ValueKey(clamped),
                              style: GoogleFonts.poppins(
                                fontSize: 15.5,
                                fontWeight: FontWeight.w800,
                                color: Colors.black.withOpacity(0.85),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }
}