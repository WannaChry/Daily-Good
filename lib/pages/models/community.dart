import 'package:studyproject/pages/models/post.dart';

class Community{
  final String id;
  String name;
  String description;
  List<String> members;
  List<Post> posts;

  Community({
    required this.id,
    required this.name,
    required this.description,
    List<String>? members,
    List<Post>? posts,
  })  : members = members ?? [],
        posts = posts ?? [];

  /// User tritt Community bei
  void joinCommunity(String userId) {
    if (!members.contains(userId)) {
      members.add(userId);
    }
  }

  /// Post hinzufügen
  void addPost(Post post) {
    posts.add(post);
  }

  /// JSON: von Firebase laden
  factory Community.fromJson(Map<String, dynamic> json) {
    return Community(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      members: (json['members'] as List<dynamic>?)?.cast<String>() ?? [],
      posts: (json['posts'] as List<dynamic>?)
          ?.map((p) => Post.fromJson(p))
          .toList() ??
          [],
    );
  }

  /// JSON: für Firebase speichern
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'members': members,
      'posts': posts.map((p) => p.toJson()).toList(),
    };
  }
}