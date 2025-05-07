import 'package:sonnow/models/release.dart';
import 'package:sonnow/models/user.dart';

class ReviewReaction {
  final String id;
  final String emoji;
  final User user;

  ReviewReaction({required this.id, required this.emoji, required this.user});

  factory ReviewReaction.fromJson(Map<String, dynamic> json) {
    return ReviewReaction(
      id: json['id']?.toString() ?? "Unknown",
      emoji: json['emoji']?.toString() ?? "Unknown",
      user: User.fromJson(json['user']),
    );
  }
}

class Review {
  final String id;
  final Release release;
  final String content;
  final List<String> tags;
  final User user;
  final DateTime createdAt;
  final List<ReviewReaction> reactions;

  Review({
    required this.id,
    required this.release,
    required this.content,
    required this.tags,
    required this.user,
    required this.createdAt,
    this.reactions = const [],
  });

  factory Review.fromJson(Map<String, dynamic> json) {
    return Review(
      id: json['id']?.toString() ?? "Unknown",
      release: Release.fromJson(json['release']),
      content: json['content']?.toString() ?? "Unknown",
      tags:
          json['tags'] != null
              ? List<String>.from(
                json['tags'].map((tag) => tag["content"].toString()),
              )
              : [],
      user: User.fromJson(json['user_profile']),
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at'].toString()) : DateTime.now(),
      reactions:
          json['reactions'] != null
              ? List<ReviewReaction>.from(
                json['reactions'].map(
                  (reaction) => ReviewReaction.fromJson(reaction),
                ),
              )
              : [],
    );
  }
}
