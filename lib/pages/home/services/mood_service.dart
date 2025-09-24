import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class MoodService {
  static Future<void> saveMood(String uid, String mood) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final today = DateTime.now();
    final formattedDate =
        "${today.day.toString().padLeft(2,'0')}.${today.month.toString().padLeft(2,'0')}.${today.year}";

    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('moods')
          .doc(formattedDate)
          .set({
        'mood': mood,
        'date': formattedDate,
        'timestamp': FieldValue.serverTimestamp(),
      });
      print('Mood gespeichert: $mood am $formattedDate');
    } catch (e) {
      print('Fehler beim Speichern der Mood: $e');
    }
  }
}
