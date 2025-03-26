import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';

Future<void> addLikedReleasesInBox(Map<String, String> likedReleases) async {
  var box = await Hive.openBox("liked_releases");

  likedReleases.forEach((releaseId, dateAdded) {
    box.put(releaseId, dateAdded);
  });
}

Future<void> removeLikedReleasesFromBox(String releaseId) async {
  var box = await Hive.openBox("liked_releases");

  box.delete(releaseId);
}