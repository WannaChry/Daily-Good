// lib/services/task_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:studyproject/pages/models/task.dart';

class TaskService {
  final _firestore = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  /// Markiert einen Task als erledigt:
  /// 1. isCompleted im lokalen Task-Objekt setzen
  /// 2. Task in der Subcollection `completedTasks` des Users speichern
  Future<void> completeTask(Task task) async {
    final user = _auth.currentUser;
    if (user == null) {
      throw Exception("Kein eingeloggter User gefunden");
    }

    try {
      // Schritt 1: Task lokal updaten
      task.isCompleted = true;

      // Schritt 2: In Subcollection speichern
      final ref = _firestore
          .collection('users')
          .doc(user.uid)
          .collection('completedTasks')
          .doc(task.id);

      await ref.set({
        'id': task.id,
        //'title': task.title,
        //'points': task.points,
        //'co2kg': task.co2kg,
        'completedAt': FieldValue.serverTimestamp(),
      });

      print("[TaskService] Task ${task.id} als erledigt gespeichert");
    } catch (e) {
      print("[TaskService] Fehler beim Speichern: $e");
      rethrow;
    }
  }

  /// Prüfen, ob ein Task für den aktuellen User schon erledigt wurde
  Future<bool> isTaskCompleted(String taskId) async {
    final user = _auth.currentUser;
    if (user == null) return false;

    final doc = await _firestore
        .collection('users')
        .doc(user.uid)
        .collection('completedTasks')
        .doc(taskId)
        .get();

    return doc.exists;
  }
}
