import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:sonnow/models/release.dart';
import 'package:sonnow/models/artist.dart';
import 'package:sonnow/models/user.dart';

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

Future<void> addLikedArtistsInBox(List<Artist> likedArtists) async {
  var box = await Hive.openBox("liked_artists");

  for (var artist in likedArtists) {
    box.put(artist.id, true);
  }
}

Future<bool> getIfArtistIsHighlighted(String artistId) async {
  var box = await Hive.openBox("user_profile");

  return box.get("user_highlight_artist") == artistId;
}

Future<bool> getIfReleaseIsHighlighted(String releaseId) async {
  var box = await Hive.openBox("user_profile");

  return box.get("user_highlight_release") == releaseId;
}

Future<void> addHighlightReleaseInBox(Release release) async {
  var box = await Hive.openBox("user_profile");

  box.put("user_highlight_release", release.id);
}

Future<void> addHighlightArtistInBox(Artist artist) async {
  var box = await Hive.openBox("user_profile");

  box.put("user_highlight_artist", artist.id);
}

Future<void> removeHighlightReleaseFromBox() async {
  var box = await Hive.openBox("user_profile");

  box.delete("user_highlight_release");
}

Future<void> removeHighlightArtistFromBox() async {
  var box = await Hive.openBox("user_profile");

  box.delete("user_highlight_artist");
}

Future<void> removeLikedArtistsFromBox(String artistId) async {
  var box = await Hive.openBox("liked_artists");

  box.delete(artistId);
}

Future<void> clearAllBoxes() async {
  clearToListenReleasesBox()
      .then((_) => clearLikedReleasesBox())
      .then((_) => clearLikedArtistsBox());
}

Future<void> clearToListenReleasesBox() async {
  var toListenReleasesBox = await Hive.openBox("to_listen_releases");
  await toListenReleasesBox.clear();
}

Future<void> clearLikedReleasesBox() async {
  var likedReleasesBox = await Hive.openBox("liked_releases");
  await likedReleasesBox.clear();
}

Future<void> clearLikedArtistsBox() async {
  var likedArtistsBox = await Hive.openBox("liked_artists");
  await likedArtistsBox.clear();
}