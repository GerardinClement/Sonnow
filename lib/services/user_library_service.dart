import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:sonnow/services/auth_service.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:sonnow/services/user_library_storage.dart';
import 'package:sonnow/models/release.dart';

class UserLibraryService {
  final String baseUrl = "http://10.0.2.2:8000/user/library";
  final AuthService authService = AuthService();

  Future<void> fetchUserLibrary() async {
    final response = await http.get(Uri.parse("$baseUrl/liked_releases/"));

    if (response.statusCode == 200) {
      print(response.body);
    } else {
      throw Exception("Error getting user library");
    }
  }

  Future<Map<String, String>> setRequestHeader() async {
    if (!await authService.checkIfLoggedIn()) throw Exception("User not logged in");

    final csrfToken = await authService.getCsrfToken();
    final token = await authService.getToken("access_token");

    if (token == null) throw Exception("Error with access token");

    return {
      "Content-Type": "application/json",
      "X-CSRFToken": csrfToken,
      "Authorization": "Bearer $token",
      "Cookie": "csrftoken=$csrfToken",
    };
  }

  Future<List<Release>> fetchUserLikedReleases() async {
    Map<String, String> header = await setRequestHeader();

    final response = await http.get(
      Uri.parse("$baseUrl/liked-releases/"),
      headers: header,
    );

    if (response.statusCode == 200) {
      final responseData = jsonDecode(response.body) as List;

      final List<Release> likedReleases = responseData.map((json) => Release.fromJson(json)).toList();

      return likedReleases;
    } else {
      throw Exception("Error getting user liked releases");
    }
  }

  Future<List<Release>> fetchUserToListenReleases() async {
    Map<String, String> header = await setRequestHeader();

    final response = await http.get(
      Uri.parse("$baseUrl/to-listen/"),
      headers: header,
    );

    if (response.statusCode == 200) {
      final responseData = jsonDecode(response.body) as List;

      final List<Release> likedReleases = responseData.map((json) => Release.fromJson(json)).toList();

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


  Future<bool> checkIfReleaseIsLiked(String releaseId) async {
    var box = await Hive.openBox("liked_releases");
    return box.containsKey(releaseId);
  }

  Future<bool> checkIfReleaseIsToListen(String releaseId) async {
    var box = await Hive.openBox("to_listen_releases");
    return box.containsKey(releaseId);
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

    final response = await http.post(
      Uri.parse("http://10.0.2.2:8000/release/"),
      headers: header,
      body: jsonEncode({
        "release_id": release.id,
        "title": release.title,
        "artist": release.artist,
        "release_date": release.date,
        "type": release.type,
        "image_url": release.imageUrl,
        "releases_ids": release.releasesIds,
        "primary_release_id": release.primaryReleaseId,
      }),
    );

    if (response.statusCode != 201) {
      throw Exception("Error creating release: ${response.statusCode} - ${response.body}");
    }
  }
}
