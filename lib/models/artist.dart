import 'package:sonnow/models/release.dart';

class Artist {
  final String name;
  final String id;
  final String tag;
  late final String imageUrl;
  Map<String, List<Release>> releaseByType = {};
  List<Release> releases = [];
  bool isLiked = false;
  bool isHighlighted = false;

  Artist({
    required this.name,
    required this.id,
    required this.tag,
    required this.imageUrl,
  });

  void setImageUrl(String url) {
    imageUrl = url;
  }

  void setReleases(List<Release> releases) {
    this.releases = releases;
    setReleasesByType(releases);
  }

  void setReleasesByType(List<Release> releases) {
    releaseByType["Album"] = [];
    releaseByType["Single"] = [];

    for (var release in releases) {
      if (release.type == "single") {
        releaseByType["Single"]?.add(release);
      } else {
        releaseByType["Album"]?.add(release);
      }
    }
  }

  factory Artist.fromJson(Map<String, dynamic> json) {
    return Artist(
      name: json['name']?.toString() ?? "Unknown",
      id: json['id']?.toString() ?? "Unknown",
      tag: json['disambiguation']?.toString() ?? "Unknown",
      imageUrl: json['picture_big']?.toString() ?? json['image_url']?.toString() ?? "",
    );
  }
}
