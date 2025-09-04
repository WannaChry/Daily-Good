
class Task {
  final String id;
  String title;
  String description;
  int points;
  bool isCompleted;
  DateTime dueDate;
  String assignedToUserId; // Referenz auf User-ID statt direktem Objekt

  Task({
    required this.id,
    required this.title,
    required this.description,
    required this.points,
    this.isCompleted = false,
    required this.dueDate,
    required this.assignedToUserId,
  });

  /// Gibt die Punkte der Aufgabe zurück
  int getPoints() {
    return points;
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
      isCompleted: json['isCompleted'] ?? false,
      dueDate: DateTime.parse(json['dueDate']),
      assignedToUserId: json['assignedToUserId'],
    );
  }

  /// Hilfsmethode: konvertiert Task in JSON (z. B. für Firebase)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'points': points,
      'isCompleted': isCompleted,
      'dueDate': dueDate.toIso8601String(),
      'assignedToUserId': assignedToUserId,
    };
  }
}
