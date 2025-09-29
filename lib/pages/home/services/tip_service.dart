import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:studyproject/pages/models/tipp.dart';

class TippService {
  static Future<List<Tipp>> fetchTips() async {
    try {
      final snapshot = await FirebaseFirestore.instance.collection('tipps').get();

      if (snapshot.docs.isEmpty) {
        print('[EcoFacts] Keine Tipps in Firestore gefunden.');
        return [];
      }

      final tips = snapshot.docs
          .map((doc) => Tipp.fromJson(doc.data() as Map<String, dynamic>))
          .toList();

      print('[EcoFacts] Erfolgreich ${tips.length} Tipps geladen.');
      return tips;
    } catch (e) {
      print('[EcoFacts] Fehler beim Laden der Tipps: $e');
      return [];
    }
  }
}
