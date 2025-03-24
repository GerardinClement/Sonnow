import 'dart:convert';

import 'package:sonnow/models/release.dart';
import 'package:sonnow/models/artist.dart';
import 'package:http/http.dart' as http;

class MusicBrainzApi {
  static const String baseUrl = "https://musicbrainz.org/ws/2/";

  Future<Release> getRelease(String releaseId) async {
    final response = await http.get(
        Uri.parse("${baseUrl}release/$releaseId?inc=recordings+artist-credits&fmt=json")
    );

    if (response.statusCode == 200) {
      Release release = Release.fromJson(json.decode(response.body));
      return release;
    } else {
      throw Exception("Error getting release");
    }
  }

  Future<List<Release>> searchRelease(String releaseName) async {
    final response = await http.get(
        Uri.parse("${baseUrl}release?query=release:$releaseName&fmt=json")
    );

    if (response.statusCode == 200) {
      List<Release> releases = (json.decode(response.body)['releases'] as List)
          .map((release) => Release.fromJson(release))
          .toList();

      return releases;
    } else {
      throw Exception("Error searching release");
    }
  }

  Future<List<Artist>> searchArtist(String artistName) async {
    final response = await http.get(
        Uri.parse("${baseUrl}artist?query=artist:$artistName&fmt=json")
    );

    if (response.statusCode == 200) {
      List<Artist> artists = (json.decode(response.body)['artists'] as List)
          .map((artist) => Artist.fromJson(artist))
          .toList();

      return artists;
    } else {
      throw Exception("Error searching artist");
    }
  }
}