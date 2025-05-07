import 'package:device_info_plus/device_info_plus.dart';
import 'package:sonnow/services/auth_service.dart';
import 'package:sonnow/models/artist.dart';
import 'package:sonnow/models/release.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter/foundation.dart';


final AuthService authService = AuthService();

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

List<Artist> sortArtists(List<Artist> artists, String query) {
  artists.sort((a, b) {
    final aName = a.name.toLowerCase();
    final bName = b.name.toLowerCase();
    final queryLower = query.toLowerCase();

    if (aName.startsWith(queryLower) && !bName.startsWith(queryLower)) {
      return -1;
    } else if (!aName.startsWith(queryLower) && bName.startsWith(queryLower)) {
      return 1;
    } else {
      return aName.compareTo(bName);
    }
  });

  return artists;
}

List<Release> sortReleases(List<Release> releases, String query) {
  releases.sort((a, b) {
    final aTitle = a.artist.name.toLowerCase();
    final bTitle = b.artist.name.toLowerCase();
    final queryLower = query.toLowerCase();

    if (aTitle.startsWith(queryLower) && !bTitle.startsWith(queryLower)) {
      return -1;
    } else if (!aTitle.startsWith(queryLower) && bTitle.startsWith(queryLower)) {
      return 1;
    } else {
      return aTitle.compareTo(bTitle);
    }
  });

  return releases;
}

Future<String?> getCurrentUserId() async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  final String? currentUserId = prefs.getString("userId");
  return currentUserId;
}

Future<bool> isCurrentUser(String profileId) async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  final String? currentUserId = prefs.getString("userId");
  return currentUserId != null && currentUserId == profileId;
}


Future<bool> isEmulator() async {
  final deviceInfo = DeviceInfoPlugin();
  final androidInfo = await deviceInfo.androidInfo;

  return androidInfo.isPhysicalDevice == false;
}

Future<String> getBaseUrl() async {
  if (kIsWeb) {
    return dotenv.env['BASE_URL_WEB']!;
  } else if(await isEmulator()) {
    return dotenv.env['BASE_URL_EMULATOR']!;
  } else {
    return dotenv.env['BASE_URL_PHYSICAL']!;
  }
}