import 'package:sonnow/models/track.dart';
import 'package:sonnow/models/artist.dart';

class Release {
  final String id;
  final String title;
  final Artist artist;
  final String date;
  final String type;
  late List<Track> tracklist;
  late String imageUrl;
  late bool isLiked = false;
  late bool toListen = false;


  Release({
    required this.id,
    required this.title,
    required this.artist,
    required this.date,
    required this.type,
    required this.imageUrl,
    this.tracklist = const [],
  });

  void setTracklist(List<Track> tracks) {
    tracklist = tracks;
  }

  factory Release.fromJson(Map<String, dynamic> json) {
    return Release(
        id: json['release_id']?.toString() ?? "Unknown",
        title: json['title']?.toString() ?? "Unknown",
        artist: Artist.fromJson(json['artist']),
        date: json['release_date']?.toString() ?? "Unknown",
        type: json['type']?.toString() ?? "Unknown",
        imageUrl: json['image_url']?.toString() ?? "Unknown"
    );
  }

  factory Release.fromJsonDeezer(Map<String, dynamic> json) {
    return Release(
      id: json['id']?.toString() ?? "Unknown",
      title: json['title']?.toString() ?? "Unknown",
      artist: Artist.fromJson(json['artist']),
      date: json['release_date']?.toString() ?? "Unknown",
      type: json['type']?.toString() ?? "Unknown",
      imageUrl: json['album']['cover_medium']?.toString() ?? "Unknown",
    );
  }

  factory Release.fromJsonAlbumFromDeezer(Map<String, dynamic> json, dynamic artist) {
    Artist artistObject;

    if (artist is Artist) {
      artistObject = artist;
    } else if (artist is Map<String, dynamic>) {
      artistObject = Artist.fromJson(artist);
    } else {
      artistObject = Artist(name: "Unknown", id: "Unknown", tag: "", imageUrl: "");
    }

    return Release(
      id: json['id']?.toString() ?? "Unknown",
      title: json['title']?.toString() ?? "Unknown",
      artist: artistObject,
      type: json['record_type']?.toString() ?? json['type']?.toString() ?? "Unknown",
      date: json['release_date']?.toString() ?? "Unknown",
      imageUrl: json['cover_medium']?.toString() ?? "Unknown",
    );
  }
}