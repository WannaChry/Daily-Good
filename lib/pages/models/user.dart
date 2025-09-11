import 'package:studyproject/pages/models/task.dart';

class User{
  final String id;
  String username;
  String email;
  String sex;
  String ageGroup;
  int level;
  int points;
  DateTime joinDate;
  int age;
  String beruf;

  List<Task> completedTasks;
  List<User> friends;

  User({
    required this.id,
    required this.username,
    required this.email,
    required this.sex,
    required this.ageGroup,
    this.level = 1,
    this.points = 0,
    required this.joinDate,
    required this.age,
    required this.beruf,
    List<Task>? completedTasks,
    List<User>? friends,
    List<String>? joinedCommunities,
}): completedTasks = completedTasks ?? [],
        friends = friends ?? [];
  /// Punkte hinzufügen und Level prüfen
  void addPoints(int newPoints) {
    points += newPoints;
    checkLevelUp();
  }

  /// Level-Up Logik
  void checkLevelUp() {
    if (points >= level * 100) {
      level++;
    }
  }
  /// Task als erledigt markieren
  void completeTask(Task task) {
    if (!task.isCompleted) {
      task.markCompleted();
      completedTasks.add(task);
      addPoints(task.getPoints());
    }
  }

  /// Freund hinzufügen
  void addFriend(User friend) {
    if (!friends.contains(friend)) {
      friends.add(friend);
    }
  }

  /// Freund entfernen
  void removeFriend(User friend) {
    friends.remove(friend);
  }
  /// JSON-Methoden für Firebase
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      username: json['username'],
      email: json['email'],
      sex: json['sex'],
      ageGroup: json['ageGroup'],
      level: json['level'] ?? 1,
      points: json['points'] ?? 0,
      joinDate: DateTime.parse(json['joinDate']),
      age: json['age'],
      beruf: json['beruf'],
      completedTasks: (json['completedTasks'] as List<dynamic>?)
          ?.map((t) => Task.fromJson(t))
          .toList() ??
          [],
      friends: []); // Freunde müsstest du separat laden (IDs statt Objekte)
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'email': email,
      'sex': sex,
      'ageGroup': ageGroup,
      'level': level,
      'points': points,
      'joinDate': joinDate.toIso8601String(),
      'completedTasks': completedTasks.map((t) => t.toJson()).toList(),
      // Freunde abspeichern am besten über deren IDs (nicht hier direkt)
    };
  }


}
