import 'package:sonnow/models/artist.dart';
import 'package:sonnow/models/release.dart';
import 'package:sonnow/models/review.dart';

class User {
  final String id;
  late String username;
  final String displayName;
  late String email;
  final String profilePictureUrl;
  final String bio;
  final Artist? highlightArtist;
  final Release? highlightRelease;
  final List<Review> reviews;
  final List<User> follows;
  final List<User> followers;

  User({
    required this.id,
    required this.displayName,
    required this.profilePictureUrl,
    required this.bio,
    required this.highlightArtist,
    required this.highlightRelease,
    required this.reviews,
    required this.follows,
    required this.followers,
  });

  void setAccountInfo(Map<String, dynamic> json) {
    username = json['username']?.toString() ?? "Unknown";
    email = json['email']?.toString() ?? "Unknown";
  }

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id']?.toString() ?? "Unknown",
      displayName: json['display_name']?.toString() ?? "Unknown",
      profilePictureUrl: json['profile_picture']?.toString() ?? "",
      bio: json['bio']?.toString() ?? "",
      highlightArtist:
          json['highlighted_artist'] != null
              ? Artist.fromJson(json['highlighted_artist'])
              : null,
      highlightRelease:
          json['highlighted_release'] != null
              ? Release.fromJson(json['highlighted_release'])
              : null,
      reviews:
          json['reviews'] != null
              ? List<Review>.from(
                json['reviews'].map((review) => Review.fromJson(review)),
              )
              : [],
      follows:
          json['follows'] != null
              ? List<User>.from(
                json['follows'].map((user) => User.fromJson(user)),
              )
              : [],
      followers:
          json['followers'] != null
              ? List<User>.from(
                json['followers'].map((user) => User.fromJson(user)),
              )
              : [],
    );
  }
}
