// lib/pages/subpages/mood_check_dialog.dart
import 'dart:ui' show ImageFilter;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

Future<int?> showMoodCheckDialog(BuildContext context) {
  return showGeneralDialog<int>(
    context: context,
    barrierLabel: 'Stimmung',
    barrierDismissible: true,
    transitionDuration: const Duration(milliseconds: 260),
    pageBuilder: (ctx, anim, secAnim) => const SizedBox.shrink(),
    transitionBuilder: (ctx, anim, secAnim, child) {
      final curved = CurvedAnimation(parent: anim, curve: Curves.easeOutCubic);

      return Stack(
        children: [
          // Hintergrund-Blur + Abdunklung
          Positioned.fill(
            child: AnimatedBuilder(
              animation: curved,
              builder: (_, __) => BackdropFilter(
                filter: ImageFilter.blur(
                  sigmaX: 10 * curved.value,
                  sigmaY: 10 * curved.value,
                ),
                child: Container(
                  color: Colors.black.withValues(alpha: 0.12 * curved.value),
                ),
              ),
            ),
          ),
          // Card in der Mitte
          Center(
            child: ScaleTransition(
              scale: Tween<double>(begin: 0.94, end: 1.0).animate(curved),
              child: const _MoodCard(),
            ),
          ),
        ],
      );
    },
  );
}

class _MoodCard extends StatefulWidget {
  const _MoodCard();

  @override
  State<_MoodCard> createState() => _MoodCardState();
}

class _MoodCardState extends State<_MoodCard> {
  int? _selected;

  // Reihenfolge: sehr schlecht, schlecht, mittel, gut, sehr gut
  final _moods = const [
    _MoodData(emoji: '🤒', color: Color(0xFFE57373)), // sehr schlecht
    _MoodData(emoji: '😕', color: Color(0xFFEF9A9A)), // schlecht
    _MoodData(emoji: '😐', color: Color(0xFFFFE082)), // mittel
    _MoodData(emoji: '🙂', color: Color(0xFFA5D6A7)), // gut
    _MoodData(emoji: '😃', color: Color(0xFF80CBC4)), // sehr gut
  ];

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Container(
        width: 360,
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: Colors.white.withValues(alpha: 0.20),
          border: Border.all(color: Colors.white.withValues(alpha: 0.5)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.12),
              blurRadius: 20,
              offset: const Offset(0, 10),
            )
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Wie fühlst du dich heute?',
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                    InkWell(
                      borderRadius: BorderRadius.circular(999),
                      onTap: () => Navigator.of(context).pop(null),
                      child: const Padding(
                        padding: EdgeInsets.all(6),
                        child: Icon(Icons.close_rounded, size: 22),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),

                // 5 Smileys
                Row(
                  children: List.generate(_moods.length, (i) {
                    final data = _moods[i];
                    final isSel = _selected == i;
                    return Expanded(
                      child: _MoodOption(
                        data: data,
                        selected: isSel,
                        onTap: () {
                          setState(() => _selected = i);
                          Future.delayed(const Duration(milliseconds: 160), () {
                            if (context.mounted) Navigator.of(context).pop(i);
                          });
                        },
                      ),
                    );
                  }),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _MoodOption extends StatefulWidget {
  const _MoodOption({
    required this.data,
    required this.selected,
    required this.onTap,
  });

  final _MoodData data;
  final bool selected;
  final VoidCallback onTap;

  @override
  State<_MoodOption> createState() => _MoodOptionState();
}

class _MoodOptionState extends State<_MoodOption> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final sel = widget.selected;

    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapCancel: () => setState(() => _pressed = false),
      onTapUp: (_) => setState(() => _pressed = false),
      onTap: widget.onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 170),
        margin: const EdgeInsets.symmetric(horizontal: 5),
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 6),
        decoration: BoxDecoration(
          color: sel
              ? widget.data.color.withValues(alpha: 0.35)
              : Colors.white.withValues(alpha: 0.55),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: sel
                ? widget.data.color.withValues(alpha: 0.9)
                : Colors.white.withValues(alpha: 0.7),
            width: sel ? 2 : 1,
          ),
        ),
        child: AnimatedScale(
          duration: const Duration(milliseconds: 140),
          scale: _pressed ? 0.95 : (sel ? 1.06 : 1.0),
          child: Center(
            child: Text(
              widget.data.emoji,
              style: const TextStyle(fontSize: 34),
            ),
          ),
        ),
      ),
    );
  }
}

class _MoodData {
  final String emoji;
  final Color color;
  const _MoodData({required this.emoji, required this.color});
}
