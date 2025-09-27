import 'package:studyproject/pages/models/task.dart';

class User {
  final String id;
  String username;
  String email;
  String password;
  String gender;
  String ageGroup;
  int level;
  int points;
  DateTime joinDate;
  int age;
  String occupation;
  String mood;
  int streak;
  String birthday;
  String role;

  List<Task> completedTasks;
  List<User> friends;

  User({
    required this.id,
    required this.username,
    required this.email,
    required this.password,
    required this.gender,
    required this.ageGroup,
    this.level = 1,
    this.points = 0,
    required this.joinDate,
    required this.age,
    required this.occupation,
    required this.mood,
    required this.streak,
    required this.birthday,
    required this.role,
    List<Task>? completedTasks,
    List<User>? friends,
  })  : completedTasks = completedTasks ?? [],
        friends = friends ?? [];

  /// Punkte hinzufügen und Level prüfen
  void addPoints(int newPoints) {
    points += newPoints;
    checkLevelUp();
  }

  /// Level-Up Logik
  void checkLevelUp() {
    while (points >= level * 100) {
      points -= level * 100; // Punkte werden für Level-Up abgezogen
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

  /// CopyWith für Immutable Updates
  User copyWith({
    String? username,
    String? email,
    String? password,
    String? gender,
    String? ageGroup,
    int? level,
    int? points,
    DateTime? joinDate,
    int? age,
    String? occupation,
    String? mood,
    int? streak,
    String? birthday,
    String? role,
    List<Task>? completedTasks,
    List<User>? friends,
  }) {
    return User(
      id: id,
      username: username ?? this.username,
      email: email ?? this.email,
      password: password ?? this.password,
      gender: gender ?? this.gender,
      ageGroup: ageGroup ?? this.ageGroup,
      level: level ?? this.level,
      points: points ?? this.points,
      joinDate: joinDate ?? this.joinDate,
      age: age ?? this.age,
      occupation: occupation ?? this.occupation,
      mood: mood ?? this.mood,
      streak: streak ?? this.streak,
      birthday: birthday ?? this.birthday,
      role: role ?? this.role,
      completedTasks: completedTasks ?? this.completedTasks,
      friends: friends ?? this.friends,
    );
  }

  /// JSON-Methoden für Firebase
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      username: json['username'],
      email: json['email'],
      password: json['password'],
      gender: json['gender'],
      ageGroup: json['ageGroup'],
      level: json['level'] ?? 1,
      points: json['points'] ?? 0,
      joinDate: DateTime.parse(json['joinDate']),
      age: json['age'],
      occupation: json['occupation'],
      mood: json['mood'],
      streak: json['streak'],
      birthday: json['birthday'],
      role: json['role'],
      completedTasks: (json['completedTasks'] as List<dynamic>?)
          ?.map((t) => Task.fromJson(t))
          .toList() ??
          [],
      friends: [], // Freunde separat laden (z.B. über IDs)
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'email': email,
      'password': password,
      'gender': gender,
      'ageGroup': ageGroup,
      'level': level,
      'points': points,
      'joinDate': joinDate.toIso8601String(),
      'age': age,
      'occupation': occupation,
      'mood': mood,
      'streak': streak,
      'birthday': birthday,
      'role': role,
      'completedTasks': completedTasks.map((t) => t.toJson()).toList(),
      // Freunde am besten über deren IDs speichern
    };
  }
}
