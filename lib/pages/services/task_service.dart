import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:collection/collection.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:studyproject/pages/models/task.dart';

class TaskService {
  final _firestore = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  /// Markiert einen Task als erledigt:
  Future<void> completeTask(Task task) async {
    final user = _auth.currentUser;
    if (user == null) {
      throw Exception("Kein eingeloggter User gefunden");
    }

    try {
      task.isCompleted = true;

      final ref = _firestore
          .collection('users')
          .doc(user.uid)
          .collection('completedTasks')
          .doc(task.id);

      await ref.set({
        'category': task.category.toString().split('.').last,
        'points': task.points,
        'co2kg': task.co2kg,
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
  Future<void> uncompleteTask(Task task) async {
    final user = _auth.currentUser;
    if (user == null) return;

    task.isCompleted = false;

    await _firestore
        .collection('users')
        .doc(user.uid)
        .collection('completedTasks')
        .doc(task.id)
        .delete();
  }

  Future<void> loadCompletedTasks(List<Task> allTasks) async {
    final user = _auth.currentUser;
    if (user == null) return;

    final snapshot = await _firestore
        .collection('users')
        .doc(user.uid)
        .collection('completedTasks')
        .get();

    for (var doc in snapshot.docs) {
      final task = allTasks.firstWhereOrNull((t) => t.id == doc.id);
      if (task != null) {
        task.isCompleted = true;
      }
    }
  }
  Future<List<Task>> fetchAllTasks() async {
    print('[Tasks] Lade Tasks von Firestore...');
    try {
      final snapshot = await _firestore.collection('tasks').get();

      if (snapshot.docs.isEmpty) {
        print('[Tasks] Keine Dokumente gefunden.');
        return [];
      }

      final loadedTasks = snapshot.docs.map((doc) {
        final data = doc.data();
        if (data == null) {
          print('[Tasks] Dokument ${doc.id} enthält null!');
          return null;
        }
        try {
          return Task.fromJson(data as Map<String, dynamic>);
        } catch (e) {
          print('[Tasks] Fehler beim Mapping von Dokument ${doc.id}: $e');
          return null;
        }
      }).where((t) => t != null).cast<Task>().toList();

      print('[Tasks] ${loadedTasks.length} Tasks geladen.');
      return loadedTasks;
    } catch (e) {
      print('[Tasks] Fehler beim Laden: $e');
      return [];
    }
  }

}
