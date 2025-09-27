import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:studyproject/pages/models/tipp.dart';

class TippService {
  final _firestore = FirebaseFirestore.instance;

  /// Alle Tipps aus Firestore laden
  Future<List<Tipp>> fetchTips() async {
    final snapshot = await _firestore.collection('tipps').get();
    return snapshot.docs
        .map((doc) => Tipp.fromJson(doc.data()))
        .toList();
  }
}
