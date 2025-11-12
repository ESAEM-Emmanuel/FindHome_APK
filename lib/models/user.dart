// // lib/models/user.dart
// class User {
//   final String id;
//   final String username;
//   final String email;
//   final String role;
//   final String? image;

//   User({
//     required this.id,
//     required this.username,
//     required this.email,
//     required this.role,
//     this.image,
//   });

//   factory User.fromJson(Map<String, dynamic> json) {
//     return User(
//       id: json['id'],
//       username: json['username'],
//       email: json['email'],
//       role: json['role'],
//       image: json['image'],
//     );
//   }
// }
// lib/models/user.dart
import 'dart:convert';

class User {
  final String id;
  final String username;
  final String email;
  final String phone;
  final String image;
  final String role;
  final bool isStaff;
  final String? refNumber;
  final String? birthday;
  final String? gender;

  User({
    required this.id,
    required this.username,
    required this.email,
    required this.phone,
    required this.image,
    required this.role,
    required this.isStaff,
    this.refNumber,
    this.birthday,
    this.gender,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] ?? '',
      username: json['username'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'] ?? '',
      image: json['image'] ?? 'https://cdn.pixabay.com/photo/2015/10/05/22/37/blank-profile-picture-973460_1280.png',
      role: json['role'] ?? 'user',
      isStaff: json['is_staff'] ?? false,
      refNumber: json['refnumber'],
      birthday: json['birthday'],
      gender: json['gender'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'email': email,
      'phone': phone,
      'image': image,
      'role': role,
      'is_staff': isStaff,
      'refnumber': refNumber,
      'birthday': birthday,
      'gender': gender,
    };
  }
}