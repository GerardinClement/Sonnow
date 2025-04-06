import 'package:sonnow/models/track.dart';
import 'package:sonnow/models/artist.dart';
import 'package:sonnow/services/musicbrainz_api.dart';

class Release {
  final String id;
  final String title;
  final Artist artist;
  final String date;
  final String type;
  final String primaryReleaseId;
  final List<String> releasesIds;
  late List<Track> tracklist;
  late final String tracklistUrl;
  late String imageUrl;
  late bool isLiked = false;
  late bool toListen = false;


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
    this.tracklistUrl = "",
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
      artist: Artist(name: "", id: "", tag: "", imageUrl: ""),
      date: json['first-release-date']?.toString() ?? "Unknown",
      type: type,
      primaryReleaseId: primaryReleaseId,
      imageUrl: "https://coverartarchive.org/release/$primaryReleaseId/front",
      releasesIds: releasesIds,
    );
  }

  factory Release.fromJson(Map<String, dynamic> json) {
    Map<String, dynamic> release = json['release'];
    List<String> releasesIds = [];
    if (json.containsKey('releases_ids')) {
      for (var release in release['releases_ids']) {
        releasesIds.add(release.toString());
      }
    }

    return Release(
      id: release['release_id']?.toString() ?? "Unknown",
      title: release['title']?.toString() ?? "Unknown",
      artist: Artist(name: "", id: "", tag: "", imageUrl: ""),
      date: release['release_date']?.toString() ?? "Unknown",
      type: release['type']?.toString() ?? "Unknown",
      primaryReleaseId: release['primary_release_id']?.toString() ?? "Unknown",
      imageUrl: release['image_url']?.toString() ?? "Unknown",
      releasesIds: releasesIds,
    );
  }

  Future<void> getGoodImageUrl() async {
    final MusicBrainzApi api = MusicBrainzApi();
    for (var release in releasesIds) {
      if (await api.imageExists("https://coverartarchive.org/release/$release/front")) {
        imageUrl = "https://coverartarchive.org/release/$release/front";
      }
    }
  }

  factory Release.fromJsonDeezer(Map<String, dynamic> json) {
    return Release(
      id: json['id']?.toString() ?? "Unknown",
      title: json['title']?.toString() ?? "Unknown",
      artist: Artist.fromJson(json['artist']),
      date: json['release_date']?.toString() ?? "Unknown",
      type: json['type']?.toString() ?? "Unknown",
      primaryReleaseId: json['id']?.toString() ?? "Unknown",
      imageUrl: json['album']['cover_medium']?.toString() ?? "Unknown",
      releasesIds: [],
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
      primaryReleaseId: "",
      imageUrl: json['cover_medium']?.toString() ?? "Unknown",
      releasesIds: [],
      tracklistUrl: json['tracklist']?.toString() ?? "Unknown",
    );
  }
}