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
    required this.onTapDown,
  });

  final String title;
  final String emoji;
  final int points;
  final bool done;
  final VoidCallback onTap;
  final void Function(Offset globalTapPosition) onTapDown;

  @override
  Widget build(BuildContext context) {
    final bg = done ? Colors.green.withOpacity(0.15) : Colors.white;
    final border = done
        ? Colors.green.withOpacity(0.25)
        : Colors.black.withOpacity(0.06);

    return GestureDetector(
      onTapDown: (d) => onTapDown(d.globalPosition),
      child: Material(
        color: bg,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: border),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x14000000),
                  blurRadius: 8,
                  offset: Offset(0, 3),
                )
              ],
            ),
            child: Row(
              children: [
                Container(
                  width: 38,
                  height: 38,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(.06),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(emoji, style: const TextStyle(fontSize: 22)),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    title,
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '$points',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(width: 2),
                    const Icon(Icons.bolt_rounded, size: 18),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
