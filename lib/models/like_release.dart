import 'package:sonnow/models/release.dart';
import 'package:sonnow/models/user.dart';

class LikeRelease {
  final String id;
  final Release release;
  final User user;
  final DateTime createdAt;

  LikeRelease({
    required this.id,
    required this.release,
    required this.user,
    required this.createdAt,
  });

  factory LikeRelease.fromJson(Map<String, dynamic> json) {
    return LikeRelease(
      id: json['id']?.toString() ?? "Unknown",
      release: Release.fromJson(json['release']),
      user: User.fromJson(json['user']),
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'].toString())
          : DateTime.now(),
    );
  }
}