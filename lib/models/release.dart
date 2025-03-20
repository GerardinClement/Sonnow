import 'package:sonnow/models/track.dart';

class Release {
  final String id;
  final String title;
  final String artist;
  final String date;
  late List<Track> tracklist;


  Release({
    required this.id,
    required this.title,
    required this.artist,
    required this.date,
    this.tracklist = const [],
  });

  factory Release.fromJson(Map<String, dynamic> json) {
    String artistName = "Unknown";
    List<Track> tracks = [];

    if (json.containsKey('artist-credit') && json['artist-credit'].isNotEmpty) {
      artistName = json['artist-credit'][0]['name']?.toString() ?? "Unknown";
    }
    if (json.containsKey('media') && json['media'][0].containsKey('tracks')) {
      for (var track in json['media'][0]['tracks']) {
        tracks.add(Track.fromJson(track, artistName));
      }
    }

    return Release(
      id: json['id']?.toString() ?? "Unknown",
      title: json['title']?.toString() ?? "Unknown",
      artist: artistName,
      date: json['date']?.toString() ?? "Unknown",
      tracklist: tracks,
    );
  }
}