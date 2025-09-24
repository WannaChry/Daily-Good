import 'dart:ui';

class MoodData {
  final String label; // z. B. "Sehr gut"
  final String emoji; // z. B. "😃"
  final Color color;  // Hintergrundfarbe für die Mood-Option

  const MoodData({
    required this.label,
    required this.emoji,
    required this.color});
}
