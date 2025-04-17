import 'package:sonnow/models/artist.dart';

class Track {
  final String id;
  final String title;
  final List<Artist> artist;
  final String date;
  late List<Artist> artistCredits;
  late List<Map<String, String>> placeCredits;
  final int position;
  String joinPhrase;

  Track({
    required this.id,
    required this.title,
    required this.artist,
    required this.date,
    required this.position,
    this.joinPhrase = "",
  }) {
    artistCredits = [];
    placeCredits = [];
  }

  void setArtistCredits(List<dynamic> credits) {
    artistCredits = [];
    for (var credit in credits) {
      if (credit['target-type'] == 'artist') {
        final Artist artist = Artist.fromJson(credit['artist']);
        if (artistCredits.any((a) => a.name == artist.name && a.tag == artist.tag)) continue;
        artistCredits.add(Artist.fromJson(credit['artist']));
      }
      else if (credit['target-type'] == 'place') {
        final Map<String, String> place = {
          'type': credit['type']?.toString() ?? "Unknown",
          'name': credit['place']['name']?.toString() ?? "Unknown",
          'area_name': credit['place']['area']['name']?.toString() ?? "Unknown",
        };
        if (placeCredits.any((p) => p['name'] == place['name'])) continue;
        placeCredits.add(place);
      }
    }
  }

  factory Track.fromJson(Map<String, dynamic> json) {
    String joinPhrase = "";
    final String id = json['recording']['id']?.toString() ?? "Unknown";
    final List<Artist> artist = [];
    for (var credit in json['artist-credit']) {
      if (credit['artist'] == null) continue;
      if (credit['joinphrase'].isNotEmpty) {
        joinPhrase = credit['joinphrase']?.toString() ?? "";
      }
      artist.add(Artist.fromJson(credit['artist']));
    }
    return Track(
      id: id,
      title: json['title']?.toString() ?? "Unknown",
      artist: artist,
      date: json['date']?.toString() ?? "Unknown",
      position: json['position'] ?? 0,
    );
  }

  factory Track.fromDeezerJson(Map<String, dynamic> json) {
    return Track(
      id: json['id']?.toString() ?? "Unknown",
      title: json['title']?.toString() ?? "Unknown",
      artist: json['contributors'] != null
          ? (json['contributors'] as List).map((e) => Artist.fromJson(e)).toList()
          : [Artist.fromJson(json['artist'])],
      date: json['release_date']?.toString() ?? "Unknown",
      position: json['track_position'] ?? 0,
    );
  }
}