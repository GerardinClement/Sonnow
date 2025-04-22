import 'package:sonnow/models/release.dart';
import 'package:sonnow/models/artist.dart';
import 'package:sonnow/models/track.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class DeezerApi {
  static const String baseUrl = "https://api.deezer.com";
  static const String searchEndpoint = "/search";
  static const String albumEndpoint = "/album";
  static const String artistEndpoint = "/artist";
  static const String trackEndpoint = "/track";

  static Future<List<Release>> searchGlobal(String query) async {
    final response = await http.get(
        Uri.parse("$baseUrl$searchEndpoint?q=$query"));

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body)['data'];
      List<Release> res = data.map((item) => Release.fromJsonDeezer(item)).toList();
      List<Release> album = [];
      Set<String> addedAlbumIds = {};

      for (var item in data) {
        String albumId = item['album']['id'].toString();
        if (!addedAlbumIds.contains(albumId)) {
          album.add(Release.fromJsonAlbumFromDeezer(item['album'], item['artist']));
          addedAlbumIds.add(albumId);
        }
      }

      return res + album;
    } else {
      throw Exception("Failed to load releases");
    }
  }

  static Future<List<Artist>> searchArtists(String query) async {
    final response = await http.get(
        Uri.parse("$baseUrl$searchEndpoint/artist?q=$query"));

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body)['data'];
      return data.map((item) => Artist.fromJson(item)).toList();
    } else {
      throw Exception("Failed to load artists");
    }
  }

  static Future<List<Release>> searchAlbums(String query) async {
    final response = await http.get(
        Uri.parse("$baseUrl$searchEndpoint/album?q=$query"));

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body)['data'];
      return data.map((item) => Release.fromJsonAlbumFromDeezer(item, item['artist'])).toList();
    } else {
      throw Exception("Failed to load albums");
    }
  }

  static Future<Release> getAlbum(String id) async {
    final response = await http.get(
        Uri.parse("$baseUrl$albumEndpoint/$id"));

    if (response.statusCode == 200) {
      return Release.fromJsonAlbumDetail(json.decode(response.body));
    } else {
      throw Exception("Failed to load album");
    }
  }

  static Future<List<Track>> getAlbumTracks(String id) async {
    final response = await http.get(
        Uri.parse("$baseUrl/album/$id/tracks"));

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body)['data'];
      final List<Future<Track>> trackFutures =
      data.map((item) => getTrack(item['id'].toString())).toList();

      return await Future.wait(trackFutures);
    } else {
      throw Exception("Failed to load album tracks");
    }
  }

  static Future<Track> getTrack(String trackId) async {
    final response = await http.get(
        Uri.parse("$baseUrl$trackEndpoint/$trackId"));

    if (response.statusCode == 200) {
      return Track.fromDeezerJson(json.decode(response.body));
    } else {
      throw Exception("Failed to load track");
    }
  }

  static Future<List<Release>> getArtistAlbums(Artist artist) async {
    final response = await http.get(
        Uri.parse("$baseUrl$artistEndpoint/${artist.id}/albums"));

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body)['data'];
      return data.map((item) => Release.fromJsonAlbumFromDeezer(item, artist)).toList();
    } else {
      throw Exception("Failed to load artist albums");
    }
  }

  static Future<List<Artist>> getRelatedArtists(Artist artist) async {
    final response = await http.get(
        Uri.parse("$baseUrl$artistEndpoint/${artist.id}/related"));

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body)['data'];
      return data.map((item) => Artist.fromJson(item)).toList();
    } else {
      throw Exception("Failed to load related artists");
    }
  }
}