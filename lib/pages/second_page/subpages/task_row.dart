import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:studyproject/pages/models/task.dart';

class TaskRow extends StatelessWidget {
  const TaskRow({required this.task, required this.onToggle, super.key});
  final Task task;
  final void Function(Task) onToggle;

  @override
  Widget build(BuildContext context) {
    final isDone = task.isCompleted;

    return InkWell(
      onTap: () => onToggle(task),
      borderRadius: BorderRadius.circular(12),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        margin: const EdgeInsets.only(top: 4),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        decoration: BoxDecoration(
          color: isDone ? Colors.white : Colors.white.withOpacity(0.6),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isDone ? Colors.black.withOpacity(0.25) : Colors.black.withOpacity(0.08),
          ),
          boxShadow: isDone
              ? [const BoxShadow(color: Color(0x14000000), blurRadius: 8, offset: Offset(0, 4))]
              : [],
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                task.title,
                style: GoogleFonts.poppins(fontSize: 13.5, fontWeight: FontWeight.w700),
              ),
            ),
            if (task.co2kg > 0)
              Padding(
                padding: const EdgeInsets.only(right: 10),
                child: Row(
                  children: [
                    const Icon(Icons.co2_rounded, size: 14),
                    const SizedBox(width: 2),
                    Text(
                      '-${task.co2kg.toStringAsFixed(1)}kg',
                      style: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.w800),
                    ),
                  ],
                ),
              ),
            Row(
              children: [
                Text('${task.points}', style: GoogleFonts.poppins(fontSize: 13.5, fontWeight: FontWeight.w800)),
                const SizedBox(width: 2),
                const Icon(Icons.bolt_rounded, size: 16),
              ],
            ),
            const SizedBox(width: 8),
            Icon(isDone ? Icons.check_box_rounded : Icons.check_box_outline_blank_rounded, size: 20),
          ],
        ),
      ),
    );
  }
}
