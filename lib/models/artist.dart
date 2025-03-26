import 'package:sonnow/models/release.dart';

class Artist {
  final String name;
  final String id;
  String imageUrl = "";
  Map<String, List<Release>> releaseByType = {};



  Artist({
    required this.name,
    required this.id,
  });

  void setImageUrl(String url) {
    imageUrl = url;
  }
  void setReleasesByType(List<Release> releases) {
    for (var release in releases) {
      if (releaseByType.containsKey(release.type)) {
        releaseByType[release.type]?.add(release);
      } else {
        releaseByType[release.type] = [release];
      }
    }
  }

  factory Artist.fromJson(Map<String, dynamic> json) {
    return Artist(
      name: json['name']?.toString() ?? "Unknown",
      id: json['id']?.toString() ?? "Unknown",
    );
  }
}