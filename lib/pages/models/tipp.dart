class Tipp {
  final String id;
  final String message;

  Tipp({required this.id, required this.message});

  Tipp copyWith({String? message}) {
    return Tipp(
      id: id,
      message: message ?? this.message,
    );
  }

  /// JSON Methoden
  factory Tipp.fromJson(Map<String, dynamic> json) {
    return Tipp(
      id: json['id'],
      message: json['message'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'message': message,
    };
  }
}
