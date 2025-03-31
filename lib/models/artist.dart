import 'package:sonnow/models/release.dart';

class Artist {
  final String name;
  final String id;
  final String tag;
  String imageUrl = "";
  Map<String, List<Release>> releaseByType = {};
  List<Release> releases = [];

  Artist({required this.name, required this.id, required this.tag});

  void setImageUrl(String url) {
    imageUrl = url;
  }

  void setReleases(List<Release> releases) {
    this.releases = releases;
    setReleasesByType(releases);
  }

  void setReleasesByType(List<Release> releases) {
    for (var release in releases) {
      if (releaseByType.containsKey(release.type)) {
        releaseByType[release.type]?.add(release);
      } else {
        releaseByType[release.type] = [release];
      }
    }

    releaseByType = Map.fromEntries(
      releaseByType.entries.toList()..sort((a, b) {
        const order = ['single', 'ep', 'album'];
        return order.indexOf(a.key).compareTo(order.indexOf(b.key));
      }),
    );
  }

  factory Artist.fromJson(Map<String, dynamic> json) {
    return Artist(
      name: json['name']?.toString() ?? "Unknown",
      id: json['id']?.toString() ?? "Unknown",
      tag: json['disambiguation']?.toString() ?? "Unknown",
    );
  }
}
