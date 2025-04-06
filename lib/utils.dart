import 'package:sonnow/services/auth_service.dart';
import 'package:sonnow/models/artist.dart';
import 'package:sonnow/models/release.dart';

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