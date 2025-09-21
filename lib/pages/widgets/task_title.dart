import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class TaskTile extends StatelessWidget {
  const TaskTile({
    super.key,
    required this.title,
    required this.emoji,
    required this.points,
    required this.done,
    required this.onTap,
    this.onTapDown,
  });

  final String title;
  final String emoji;
  final int points;
  final bool done;
  final VoidCallback onTap;
  /// Bekommt die **globale** Tap-Position (für Konfetti)
  final ValueChanged<Offset>? onTapDown;

  @override
  Widget build(BuildContext context) {
    final base = GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w700);
    final pts  = GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w800);

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: (details) => onTapDown?.call(details.globalPosition),
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: done
              ? const Color(0xFF66BB6A).withOpacity(.22) // transparent grün
              : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.black.withOpacity(0.06)),
          boxShadow: const [
            BoxShadow(
              color: Color(0x14000000),
              blurRadius: 10,
              offset: Offset(0, 6),
            )
          ],
        ),
        child: Row(
          children: [
            // Emoji-Kästchen
            Container(
              width: 40,
              height: 40,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(.06),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(emoji, style: const TextStyle(fontSize: 22)),
            ),
            const SizedBox(width: 10),

            // Titel
            Expanded(
              child: Text(
                title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: base.copyWith(
                  // kein Durchstreichen mehr
                  color: done ? Colors.black.withOpacity(.65) : Colors.black,
                ),
              ),
            ),

            const SizedBox(width: 8),

            // Punkte
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('$points', style: pts),
                const SizedBox(width: 2),
                const Icon(Icons.bolt_rounded, size: 20),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
