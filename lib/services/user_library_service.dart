import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:sonnow/services/auth_service.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:sonnow/services/user_library_storage.dart';
import 'package:sonnow/models/release.dart';
import 'package:sonnow/models/artist.dart';
import 'package:sonnow/utils.dart';

class UserLibraryService {
  final String baseUrl = "http://10.0.2.2:8000/user/library";
  final AuthService authService = AuthService();

  // Methods to manage user liked releases

  Future<List<Release>> fetchUserLikedReleases() async {
    Map<String, String> header = await setRequestHeader();

    final response = await http.get(
      Uri.parse("$baseUrl/liked-releases/"),
      headers: header,
    );

    if (response.statusCode == 200) {
      final responseData = jsonDecode(response.body) as List;

      final List<Release> likedReleases = responseData.map((json) => Release.fromJson(json['release'])).toList();

      return likedReleases;
    } else {
      throw Exception("Error getting user liked releases");
    }
  }

  Future<void> likeRelease(Release release) async {
    Map<String, String> header = await setRequestHeader();

    await getOrCreateRelease(release);
    final response = await http.post(
      Uri.parse("$baseUrl/like-release/${release.id}/"),
      headers: header,
    );

    if (response.statusCode != 201) {
      throw Exception("Error liking release");
    }
  }

  Future<void> unlikeRelease(Release release) async {
    Map<String, String> header = await setRequestHeader();

    final response = await http.delete(
      Uri.parse("$baseUrl/unlike-release/${release.id}/"),
      headers: header,
    );

    if (response.statusCode != 204) {
      throw Exception("Error liking release");
    }
    removeLikedReleasesFromBox(release.id);
  }

  Future<bool> checkIfReleaseIsLiked(String releaseId) async {
    var box = await Hive.openBox("liked_releases");
    return box.containsKey(releaseId);
  }

  // Methods to manage user liked artists

  Future<List<Artist>> fetchUserLikedArtists() async {
    Map<String, String> header = await setRequestHeader();

    final response = await http.get(
      Uri.parse("$baseUrl/liked-artists/"),
      headers: header,
    );

    if (response.statusCode == 200) {
      final responseData = jsonDecode(response.body) as List;

      final List<Artist> likedArtists = responseData.map((json) => Artist.fromJson(json['artist'])).toList();

      return likedArtists;
    } else {
      throw Exception("Error getting user liked artists");
    }
  }

  Future<void> likeArtist(Artist artist) async {
    Map<String, String> header = await setRequestHeader();

    await getOrCreateArtist(artist);
    final response = await http.post(
      Uri.parse("$baseUrl/like-artist/${artist.id}/"),
      headers: header,
    );

    if (response.statusCode != 201) {
      throw Exception("Error when adding artist to liked");
    }
  }

  Future<void> unlikedArtist(Artist artist) async {
    Map<String, String> header = await setRequestHeader();

    final response = await http.delete(
      Uri.parse("$baseUrl/unlike-artist/${artist.id}/"),
      headers: header,
    );

    if (response.statusCode != 204) {
      throw Exception("Error when removing artist from liked");
    }
  }

  Future<bool> checkIfArtistIsLiked(String artistId) async {
    var box = await Hive.openBox("liked_artists");
    return box.containsKey(artistId);
  }

  // Methods to manage user releases to listen

  Future<List<Release>> fetchUserToListenReleases() async {
    Map<String, String> header = await setRequestHeader();

    final response = await http.get(
      Uri.parse("$baseUrl/to-listen/"),
      headers: header,
    );

    if (response.statusCode == 200) {
      final responseData = jsonDecode(response.body) as List;

      final List<Release> likedReleases = responseData.map((json) => Release.fromJson(json['release'])).toList();

      return likedReleases;
    } else {
      throw Exception("Error getting user liked releases");
    }
  }

  Future<void> addToListenRelease(Release release) async {
    Map<String, String> header = await setRequestHeader();

    await getOrCreateRelease(release);
    final response = await http.post(
      Uri.parse("$baseUrl/to-listen/add/${release.id}/"),
      headers: header,
    );

    if (response.statusCode != 201) {
      throw Exception("Error when adding release to listen");
    }
  }

  Future<void> removeToListenRelease(Release release) async {
    Map<String, String> header = await setRequestHeader();

    final response = await http.delete(
      Uri.parse("$baseUrl/to-listen/delete/${release.id}/"),
      headers: header,
    );

    if (response.statusCode != 204) {
      throw Exception("Error when removing release to listen");
    }
    removeLikedReleasesFromBox(release.id);
  }

  Future<bool> checkIfReleaseIsToListen(String releaseId) async {
    var box = await Hive.openBox("to_listen_releases");
    return box.containsKey(releaseId);
  }


  // Methods to get/create release in database

  Future<void> getOrCreateRelease(Release release) async {
    try {
      await getRelease(release);
    } catch (e) {
      await createRelease(release);
    }
  }

  Future<void> getRelease(Release release) async {
    Map<String, String> header = await setRequestHeader();

    final response = await http.get(
      Uri.parse("http://10.0.2.2:8000/release/${release.id}/"),
      headers: header,
    );

    if (response.statusCode == 200) {
      print(response.body);
    } else {
      throw Exception("Error getting release: ${response.statusCode} - ${response.body}");
    }
  }

  Future<void> createRelease(Release release) async {
    Map<String, String> header = await setRequestHeader();

    await getOrCreateArtist(release.artist);
    final response = await http.post(
      Uri.parse("http://10.0.2.2:8000/release/"),
      headers: header,
      body: jsonEncode({
        "id": release.id,
        "title": release.title,
        "artist_id": release.artist.id,
        "release_date": release.date,
        "type": release.type,
        "image_url": release.imageUrl,
      }),
    );

    if (response.statusCode != 201) {
      throw Exception("Error creating release: ${response.statusCode} - ${response.body}");
    }
  }

  // Method to get/create Artist in database

  Future<void> getOrCreateArtist(Artist artist) async {
    try {
      await getArtist(artist);
    } catch (e) {
      await createArtist(artist);
    }
  }

  Future<void> getArtist(Artist artist) async {
    Map<String, String> header = await setRequestHeader();

    final response = await http.get(
      Uri.parse("http://10.0.2.2:8000/artist/${artist.id}/"),
      headers: header,
    );

    if (response.statusCode == 200) {
      print(response.body);
    } else {
      throw Exception("Error getting release: ${response.statusCode} - ${response.body}");
    }
  }

  Future<void> createArtist(Artist artist) async {
    Map<String, String> header = await setRequestHeader();

    final response = await http.post(
      Uri.parse("http://10.0.2.2:8000/artist/"),
      headers: header,
      body: jsonEncode({
        "id": artist.id,
        "name": artist.name,
        "genre": "RAP",
        "image_url": artist.imageUrl,
      }),
    );

    if (response.statusCode != 201) {
      throw Exception("Error creating release: ${response.statusCode} - ${response.body}");
    }
  }
}



