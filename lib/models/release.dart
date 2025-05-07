import 'package:sonnow/models/track.dart';
import 'package:sonnow/models/artist.dart';

class Release {
  final String id;
  final String title;
  final Artist artist;
  List<Artist> contributors;
  final String date;
  final String type;
  late int nb_likes;
  late List<Track> tracklist;
  late String imageUrl;
  List<String>? genre;
  late bool isLiked = false;
  late bool toListen = false;
  late bool isHighlighted = false;

  Release({
    required this.id,
    required this.title,
    required this.artist,
    required this.contributors,
    required this.date,
    required this.type,
    required this.imageUrl,
    this.tracklist = const [],
    this.genre,
    this.nb_likes = 0,
  });

  void setTracklist(List<Track> tracks) {
    tracklist = tracks;
  }

  void setContributors(List<Artist> artists) {
    contributors = artists;
  }

  factory Release.fromJson(Map<String, dynamic> json) {
    return Release(
      id: json['id']?.toString() ?? "Unknown",
      title: json['title']?.toString() ?? "Unknown",
      artist:
          json['artist'] != null
              ? Artist.fromJson(json['artist'])
              : Artist(name: "Unknown", id: "Unknown", tag: "", imageUrl: ""),
      contributors:
          json['contributors'] != null
              ? List<Artist>.from(
                json['contributors'].map((artist) => Artist.fromJson(artist)),
              )
              : [],
      date: json['release_date']?.toString() ?? "Unknown",
      type: json['type']?.toString() ?? "Unknown",
      imageUrl: json['image_url']?.toString() ?? "Unknown",
      nb_likes: json['nb_like'] ?? 0,
    );
  }

  factory Release.fromJsonDeezer(Map<String, dynamic> json) {
    return Release(
      id: json['id']?.toString() ?? "Unknown",
      title: json['title']?.toString() ?? "Unknown",
      artist: Artist.fromJson(json['artist']),
      contributors:
          json['contributors'] != null
              ? List<Artist>.from(
                json['contributors'].map((artist) => Artist.fromJson(artist)),
              )
              : [],
      date: json['release_date']?.toString() ?? "Unknown",
      type: json['type']?.toString() ?? "Unknown",
      imageUrl: json['album']['cover_medium']?.toString() ?? "Unknown",
    );
  }

  factory Release.fromJsonAlbumFromDeezer(
    Map<String, dynamic> json,
    dynamic artist,
  ) {
    Artist artistObject;

    if (artist is Artist) {
      artistObject = artist;
    } else if (artist is Map<String, dynamic>) {
      artistObject = Artist.fromJson(artist);
    } else {
      artistObject = Artist(
        name: "Unknown",
        id: "Unknown",
        tag: "",
        imageUrl: "",
      );
    }

    return Release(
      id: json['id']?.toString() ?? "Unknown",
      title: json['title']?.toString() ?? "Unknown",
      artist: artistObject,
      contributors:
          json['contributors'] != null
              ? List<Artist>.from(
                json['contributors'].map((artist) => Artist.fromJson(artist)),
              )
              : [],
      type:
          json['record_type']?.toString() ??
          json['type']?.toString() ??
          "Unknown",
      date: json['release_date']?.toString() ?? "Unknown",
      imageUrl: json['cover_medium']?.toString() ?? "Unknown",
    );
  }

  factory Release.fromJsonAlbumDetail(Map<String, dynamic> json) {
    return Release(
      id: json['id']?.toString() ?? "Unknown",
      title: json['title']?.toString() ?? "Unknown",
      artist: Artist.fromJson(json['artist']),
      contributors:
          json['contributors'] != null
              ? List<Artist>.from(
                json['contributors'].map((artist) => Artist.fromJson(artist)),
              )
              : [],
      type:
          json['record_type']?.toString() ??
          json['type']?.toString() ??
          "Unknown",
      date: json['release_date']?.toString() ?? "Unknown",
      imageUrl: json['cover_big']?.toString() ?? "Unknown",
      genre:
          json['genres']['data'] != null
              ? List<String>.from(
                json['genres']['data'].map((genre) => genre["name"].toString()),
              )
              : [],
    );
  }
}
