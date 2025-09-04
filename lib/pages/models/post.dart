class Post {
  final String id;
  String title;
  String content;
  String authorId; // User-ID des Autors
  DateTime date;

  Post({
    required this.id,
    required this.title,
    required this.content,
    required this.authorId,
    required this.date,
  });

  /// Post bearbeiten
  void editPost({String? newTitle, String? newContent}) {
    if (newTitle != null) {
      title = newTitle;
    }
    if (newContent != null) {
      content = newContent;
    }
  }

  /// JSON: von Firebase laden
  factory Post.fromJson(Map<String, dynamic> json) {
    return Post(
        id: json['id'],
        title: json['title'],
        content: json['content'],
        authorId: json['authorId'],
          date: DateTime.parse(json['date']),
    );}
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'authorId': authorId,
      'date': date.toIso8601String(),
    };
  }

}