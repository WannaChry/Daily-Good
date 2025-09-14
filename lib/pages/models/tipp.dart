class Tipp {
  String id;
  final String message;

  Tipp({required this.id, required this.message});

  Map<String, dynamic> toJson() => {
    'id': id,
    'message': message,
  };

  factory Tipp.fromJson(Map<String, dynamic> json) => Tipp(
    id: json['id'],
    message: json['message'],
  );
}
