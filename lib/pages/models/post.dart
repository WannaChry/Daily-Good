class Post {
  final String id;
  String title;
  String content;
  String authorId;
  DateTime date;

  Post({
    required this.id,
    required this.title,
    required this.content,
    required this.authorId,
    required this.date,
  });

  void editPost({String? newTitle, String? newContent}) {
    if (newTitle != null) {
      title = newTitle;
    }
    if (newContent != null) {
      content = newContent;
    }
  }

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