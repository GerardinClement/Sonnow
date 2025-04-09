import 'package:sonnow/models/release.dart';
import 'package:sonnow/models/user.dart';

class Review {
  final Release release;
  final String content;
  final List<String> tags;
  final User user;
  final String date;

  Review({
    required this.release,
    required this.content,
    required this.tags,
    required this.user,
    required this.date,
  });

  factory Review.fromJson(Map<String, dynamic> json) {
    return Review(
      release: Release.fromJson(json['release']),
      content: json['content']?.toString() ?? "Unknown",
      tags: json['tags'] != null
          ? List<String>.from(json['tags'].map((tag) => tag["content"].toString()))
          : [],
      user: User.fromJson(json['user_profile']),
      date: json['date']?.toString() ?? "Unknown",
    );
  }
}