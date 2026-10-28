class User {
  final String id;
  final String email;
  final String username;
  final DateTime? dateJoined;

  User({
    required this.id,
    required this.email,
    required this.username,
    this.dateJoined,
  });

  factory User.fromJson(Map<String, dynamic> json) => User(
        id: json['id'] as String,
        email: json['email'] as String,
        username: json['username'] as String,
        dateJoined: json['date_joined'] != null
            ? DateTime.tryParse(json['date_joined'])
            : null,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'email': email,
        'username': username,
        'date_joined': dateJoined?.toIso8601String(),
      };
}
