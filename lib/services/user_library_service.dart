import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:sonnow/services/auth_service.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:sonnow/services/user_librairy_storage.dart';

class UserLibraryService {
  final String baseUrl = "http://10.0.2.2:8000/user/library/";
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

  Future<Map<String, String>> fetchUserLikedReleases() async {
    Map<String, String> header = await setRequestHeader();

    final response = await http.get(
      Uri.parse("${baseUrl}liked-releases/"),
      headers: header,
    );

    if (response.statusCode == 200) {
      final Map<String, String> likedReleases =
          (json.decode(response.body) as List)
              .fold<Map<String, String>>({}, (map, release) {
                map[release['release_id']] = release['date_added'];
                return map;
              });
      return likedReleases;
    } else {
      throw Exception("Error getting user liked releases");
    }
  }

  Future<bool> checkIfReleaseIsLiked(String releaseId) async {
    var box = await Hive.openBox("liked_releases");
    return box.containsKey(releaseId);
  }

  Future<void> likeRelease(String releaseId) async {
    Map<String, String> header = await setRequestHeader();

    final response = await http.post(
      Uri.parse("$baseUrl$releaseId/like-release/"),
      headers: header,
    );

    if (response.statusCode != 201) {
      throw Exception("Error liking release");
    }
  }

  Future<void> unlikeRelease(String releaseId) async {
    Map<String, String> header = await setRequestHeader();

    final response = await http.delete(
      Uri.parse("$baseUrl$releaseId/liked-release/"),
      headers: header,
    );

    if (response.statusCode != 204) {
      throw Exception("Error liking release");
    }
    removeLikedReleasesFromBox(releaseId);
  }
}
