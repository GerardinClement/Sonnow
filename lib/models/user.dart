import 'package:sonnow/models/artist.dart';
import 'package:sonnow/models/release.dart';
import 'package:sonnow/models/review.dart';

class User {
  final String id;
  late String username;
  final String displayName;
  late String email;
  final String? profilePictureUrl;
  final String bio;
  final Artist? highlightArtist;
  final Release? highlightRelease;
  final List<Review> reviews;
  final List<User> follows;
  final List<User> followers;
  final List<Release> toListenReleases;
  final List<Release> likedReleases;
  final List<Artist> likedArtists;

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
    required this.toListenReleases,
    required this.likedReleases,
    required this.likedArtists,
  });

  void setAccountInfo(Map<String, dynamic> json) {
    username = json['username']?.toString() ?? "Unknown";
    email = json['email']?.toString() ?? "Unknown";
  }

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id']?.toString() ?? "Unknown",
      displayName: json['display_name']?.toString() ?? "Unknown",
      profilePictureUrl: json['profile_picture']?.toString() ?? null,
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
      toListenReleases:
          json['to_listen_releases'] != null
              ? List<Release>.from(
                json['to_listen_releases'].map((release) => Release.fromJson(release['release'])),
              )
              : [],
      likedReleases:
          json['liked_releases'] != null
              ? List<Release>.from(
                json['liked_releases'].map((release) => Release.fromJson(release['release'])),
              )
              : [],
      likedArtists:
          json['liked_artists'] != null
              ? List<Artist>.from(
                json['liked_artists'].map((artist) => Artist.fromJson(artist['artist'])),
              )
              : [],
    );
  }
}
