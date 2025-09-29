import 'dart:ui';
import 'package:flutter/material.dart';
import 'mood_card.dart';

Future<int?> showMoodPicker(BuildContext context) {
  return showGeneralDialog<int>(
    context: context,
    barrierLabel: 'Stimmung',
    barrierDismissible: true,
    transitionDuration: const Duration(milliseconds: 260),
    pageBuilder: (_, __, ___) => const SizedBox.shrink(),
    transitionBuilder: (_, anim, __, ___) {
      final curved = CurvedAnimation(parent: anim, curve: Curves.easeOutCubic);

      return Stack(
        children: [
          Positioned.fill(
            child: GestureDetector(
              onTap: () => Navigator.of(context).pop(null),
              child: AnimatedBuilder(
                animation: curved,
                builder: (_, __) => BackdropFilter(
                  filter: ImageFilter.blur(
                    sigmaX: 10 * curved.value,
                    sigmaY: 10 * curved.value,
                  ),
                  child: Container(
                    color: Colors.black.withOpacity(0.12 * curved.value),
                  ),
                ),
              ),
            ),
          ),
          // Card
          Center(
            child: ScaleTransition(
              scale: Tween<double>(begin: 0.94, end: 1.0).animate(curved),
              child: const MoodCard(),
            ),
          ),
        ],
      );
    },
  );
}
