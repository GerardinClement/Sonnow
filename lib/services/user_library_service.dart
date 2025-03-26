import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:sonnow/services/auth_service.dart';

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

  Future<List<String>> fetchUserLikedReleases() async {
    if (!await authService.checkIfLoggedIn())
      throw Exception("User not logged in");

    final csrfToken = await authService.getCsrfToken();
    final token = await authService.getToken("access_token");

    if (token == null) throw Exception("Error with access token");

    final response = await http.get(
      Uri.parse("${baseUrl}liked-releases/"),
      headers: {
        "Content-Type": "application/json",
        "X-CSRFToken": csrfToken,
        "Authorization": "Bearer $token",
        "Cookie": "csrftoken=$csrfToken",
      },
    );

    if (response.statusCode == 200) {
      final List<String> likedReleases =
          (json.decode(response.body) as List)
              .map((release) => release.toString())
              .toList();
      return likedReleases;
    } else {
      throw Exception("Error getting user liked releases");
    }
  }

  Future<void> likeRelease(String releaseId) async {
    if (!await authService.checkIfLoggedIn())
      throw Exception("User not logged in");

    final csrfToken = await authService.getCsrfToken();
    final token = await authService.getToken("access_token");

    if (token == null) throw Exception("Error with access token");
    final response = await http.post(
      Uri.parse("$baseUrl$releaseId/like-release/"),
      headers: {
        "Content-Type": "application/json",
        "X-CSRFToken": csrfToken,
        "Authorization": "Bearer $token",
        "Cookie": "csrftoken=$csrfToken",
      },
    );

    if (response.statusCode != 201) {
      throw Exception("Error liking release");
    }
  }
}
