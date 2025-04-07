import 'package:sonnow/models/artist.dart';
import 'package:sonnow/models/release.dart';

class User {
  final String username;
  final String displayName;
  final String email;
  final String profilePictureUrl;
  final String bio;
  final Artist? highlightArtist;
  final Release? highlightRelease;


  User({
    required this.username,
    required this.displayName,
    required this.email,
    required this.profilePictureUrl,
    required this.bio,
    required this.highlightArtist,
    required this.highlightRelease,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    String username = json['username']?.toString() ?? "Unknown";
    return User(
      username: username,
      displayName: json['display_name']?.toString() ?? username,
      email: json['email']?.toString() ?? "Unknown",
      profilePictureUrl: json['profile_picture']?.toString() ?? "",
      bio: json['bio']?.toString() ?? "",
      highlightArtist: json['highlighted_artist'] != null
          ? Artist.fromJson(json['highlighted_artist'])
          : null,
      highlightRelease: json['highlighted_release'] != null
          ? Release.fromJson(json['highlighted_release'])
          : null,
    );
  }
}