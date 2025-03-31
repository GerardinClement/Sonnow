import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:sonnow/models/release.dart';

Future<void> addLikedReleasesInBox(List<Release> likedReleases) async {
  var box = await Hive.openBox("liked_releases");

  for (var release in likedReleases) {
    box.put(release.id, release.date);
  }
}

Future<void> removeLikedReleasesFromBox(String releaseId) async {
  var box = await Hive.openBox("liked_releases");

  box.delete(releaseId);
}

Future<void> addToListenReleasesInBox(List<Release> toListenReleases) async {
  var box = await Hive.openBox("to_listen_releases");

  for (var release in toListenReleases) {
    box.put(release.id, release.date);
  }
}

Future<void> removeToListenReleasesFromBox(String releaseId) async {
  var box = await Hive.openBox("to_listen_releases");

  box.delete(releaseId);
}