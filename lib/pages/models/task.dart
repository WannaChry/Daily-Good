import 'package:studyproject/pages/models/task_category.dart';

class Task {
  final String id;
  String title;
  String description;
  int points;
  double co2kg;
  bool isCompleted;

  final String emoji;
  Task_category category;

  Task({
    required this.id,
    required this.title,
    required this.description,
    required this.points,
    required this.co2kg,
    this.isCompleted = false,
    required this.emoji,
    required this.category,
  });
  void markCompleted() {
    isCompleted = true;
  }

  /// Optional: Task wieder auf "nicht erledigt" setzen
  void markUncompleted() {
    isCompleted = false;
  }
  int getPoints() {
    return points;
  }

  Task copyWith({
    String? title,
    String? description,
    int? points,
    double? co2kg,
    bool? isCompleted,
    String? emoji,
    Task_category? category,
  }) {
    return Task(
      id: id,
      title: title ?? this.title,
      description: description ?? this.description,
      points: points ?? this.points,
      co2kg: co2kg ?? this.co2kg,
      isCompleted: isCompleted ?? this.isCompleted,
      emoji: emoji ?? this.emoji,
      category: category ?? this.category,
    );
  }

  /// JSON Methoden
  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      points: json['points'],
      co2kg: json['co2kg']?.toDouble() ?? 0.0,
      isCompleted: json['isCompleted'] ?? false,
      emoji: json['emoji'],
      category: Task_category.values.firstWhere(
              (e) => e.toString() == 'Task_category.${json['category']}'),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'points': points,
      'co2kg': co2kg,
      'isCompleted': isCompleted,
      'emoji': emoji,
      'category': category.toString().split('.').last,
    };
  }
}
