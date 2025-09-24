import 'package:flutter/material.dart';
import 'package:studyproject/pages/models/mood.dart';

class MoodOption extends StatelessWidget {
  final MoodData data;
  final VoidCallback onTap;

  const MoodOption({super.key, required this.data, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 2),
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: data.color.withOpacity(0.35),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Center(
          child: Text(data.emoji, style: const TextStyle(fontSize: 34)),
        ),
      ),
    );
  }
}
