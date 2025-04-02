import 'dart:ui';
import 'package:sonnow/models/release.dart';

class User {
  final String username;
  final String displayName;
  final String email;
  final String profilePictureUrl;
  final String bio;


  User({
    required this.username,
    required this.displayName,
    required this.email,
    required this.profilePictureUrl,
    required this.bio,

  });

  factory User.fromJson(Map<String, dynamic> json) {
    String username = json['username']?.toString() ?? "Unknown";
    return User(
      username: username,
      displayName: json['display_name']?.toString() ?? username,
      email: json['email']?.toString() ?? "Unknown",
      profilePictureUrl: json['profile_picture']?.toString() ?? "",
      bio: json['bio']?.toString() ?? "",
    );
  }
}