import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:studyproject/pages/models/mood.dart';
import 'package:studyproject/pages/home/mood/mood_option.dart';
import 'package:studyproject/pages/home/mood/mood_data.dart'; // ausgelagerte Mood-Liste
import '../services/mood_service.dart';

class MoodCard extends StatefulWidget {
  const MoodCard({super.key});

  @override
  State<MoodCard> createState() => _MoodCardState();
}

class _MoodCardState extends State<MoodCard> {
  int? _selected;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Container(
        width: 300,
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: Colors.white.withOpacity(0.20),
          border: Border.all(color: Colors.white.withOpacity(0.5)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.12),
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
                // Header
                Row(
                  children: [
                    const Expanded(
                      child: Text(
                        'Wie fühlst du dich heute?',
                        style: TextStyle(
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
                // Mood-Optionen
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: List.generate(moods.length, (i) {
                    final data = moods[i];
                    final isSelected = _selected == i;

                    return Expanded(
                      child: GestureDetector(
                        onTap: () async {
                          if (_selected == i) return; // Doppel-Click verhindern
                          setState(() => _selected = i);

                          // Mood in Subcollection speichern
                          final user = FirebaseAuth.instance.currentUser;
                          if (user != null) {
                            final today = DateTime.now();
                            final formattedDate =
                                "${today.day.toString().padLeft(2,'0')}.${today.month.toString().padLeft(2,'0')}.${today.year}";

                            await MoodService.saveMood(user.uid, data.label);
                          }

                          if (context.mounted) Navigator.of(context).pop(i);
                        },
                        child: Container(
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            color: data.color.withOpacity(0.35),
                            borderRadius: BorderRadius.circular(14),
                            border: isSelected
                                ? Border.all(color: Colors.green, width: 3)
                                : null,
                          ),
                          child: Center(
                            child: Text(
                              data.emoji,
                              style: const TextStyle(fontSize: 34),
                            ),
                          ),
                        ),
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
