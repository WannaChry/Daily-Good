import 'package:studyproject/pages/models/task_category.dart';

class Task {
  final String id;
  String title;
  String description;
  int points;
  double co2kg;
  bool isCompleted;
  DateTime dueDate;
  String assignedToUserId; // Referenz auf User-ID statt direktem Objekt
  Task_category category;

  Task({
    required this.id,
    required this.title,
    required this.description,
    required this.points,
    required this.co2kg,
    this.isCompleted = false,
    required this.dueDate,
    required this.assignedToUserId,
    required this.category,
  });

  /// Gibt die Punkte der Aufgabe zurück
  int getPoints() {
    return points;
  }

  double getCo2kg(){
    return co2kg;
  }

  /// Markiert die Aufgabe als erledigt
  void markCompleted() {
    isCompleted = true;
  }

  /// Hilfsmethode: erstellt Task aus JSON (z. B. von Firebase)
  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      points: json['points'],
      co2kg: json['co2kg'],
      isCompleted: json['isCompleted'] ?? false,
      dueDate: DateTime.parse(json['dueDate']),
      assignedToUserId: json['assignedToUserId'],
        category: Task_category.values.firstWhere(
              (e) => e.toString() == 'TaskCategory.${json['category']}',
    ));
  }

  /// Hilfsmethode: konvertiert Task in JSON (z. B. für Firebase)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'points': points,
      'co2kg': co2kg,
      'isCompleted': isCompleted,
      'dueDate': dueDate.toIso8601String(),
      'assignedToUserId': assignedToUserId,
      'category': category.toString().split('.').last,
    };
  }
}
