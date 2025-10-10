// lib/models/user.dart
class User {
  final String id;
  final String username;
  final String email;
  final String role;
  final String? image;

  User({
    required this.id,
    required this.username,
    required this.email,
    required this.role,
    this.image,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      username: json['username'],
      email: json['email'],
      role: json['role'],
      image: json['image'],
    );
  }
}