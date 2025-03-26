import 'package:sonnow/models/track.dart';
import 'package:sonnow/services/musicbrainz_api.dart';

class Release {
  final String id;
  final String title;
  final String artist;
  final String date;
  final String type;
  final String primaryReleaseId;
  final List<String> releasesIds;
  late List<Track> tracklist;
  late String imageUrl;


  Release({
    required this.id,
    required this.title,
    required this.artist,
    required this.date,
    required this.type,
    required this.primaryReleaseId,
    required this.imageUrl,
    required this.releasesIds,
    this.tracklist = const [],
  });

  void setTracklist(List<Track> tracks) {
    tracklist = tracks;
  }

  factory Release.fromSearchJson(Map<String, dynamic> json) {
    String artistName = "Unknown";
    String type = "Unknown";
    String id = json['id']?.toString() ?? "Unknown";
    String primaryReleaseId = "";
    List<String> releasesIds = [];

    if (json.containsKey('primary-type') && json['primary-type'].isNotEmpty) {
      type = json['primary-type']?.toString() ?? "Unknown";
    }
    if (json.containsKey('artist-credit') && json['artist-credit'].isNotEmpty) {
      artistName = json['artist-credit'][0]['name']?.toString() ?? "Unknown";
    }
    if (json.containsKey('releases') && json['releases'].isNotEmpty) {
      if (json['releases'][0].containsKey('id')) {
        primaryReleaseId = json['releases'][0]['id']?.toString() ?? "Unknown";
      }
    }
    for (var release in json['releases']) {
      if (release.containsKey('id')) {
        releasesIds.add(release['id']?.toString() ?? "Unknown");
      }
    }

    return Release(
      id: id,
      title: json['title']?.toString() ?? "Unknown",
      artist: artistName,
      date: json['first-release-date']?.toString() ?? "Unknown",
      type: type,
      primaryReleaseId: primaryReleaseId,
      imageUrl: "https://coverartarchive.org/release/${primaryReleaseId}/front",
      releasesIds: releasesIds,
    );
  }

  Future<void> getGoodImageUrl() async {
    final MusicBrainzApi api = MusicBrainzApi();
    for (var release in releasesIds) {
      if (await api.imageExists("https://coverartarchive.org/release/${release}/front")) {
        imageUrl = "https://coverartarchive.org/release/${release}/front";
      }
    }
  }
}