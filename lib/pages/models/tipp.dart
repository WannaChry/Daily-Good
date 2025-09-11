class Tipp {
  final String category;
  final String message;

  Tipp({required this.category, required this.message});

  Map<String, dynamic> toJson() => {
    'category': category,
    'message': message,
  };

  factory Tipp.fromJson(Map<String, dynamic> json) => Tipp(
    category: json['category'],
    message: json['message'],
  );
}
