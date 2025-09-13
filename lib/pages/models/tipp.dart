class Tipp {
  final String message;

  Tipp({required this.message});

  Map<String, dynamic> toJson() => {
    'message': message,
  };

  factory Tipp.fromJson(Map<String, dynamic> json) => Tipp(
    message: json['message'],
  );
}
