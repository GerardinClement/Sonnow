import 'dart:convert';

import 'package:sonnow/models/release.dart';
import 'package:sonnow/models/artist.dart';
import 'package:sonnow/models/track.dart';
import 'package:http/http.dart' as http;
import 'dart:io';
import 'dart:async';

class MusicBrainzApi {
  static const String baseUrl = "https://musicbrainz.org/ws/2/";

  Future<void> getReleaseTracklist(Release release) async {
    final response = await http.get(
        Uri.parse("${baseUrl}release/${release.primaryReleaseId}?inc=recordings&fmt=json")
    );

    if (response.statusCode == 200) {
      var data = json.decode(response.body);
      List<Track> tracks = (data['media'][0]['tracks'] as List)
          .map((track) => Track.fromJson(track, release.artist))
          .toList();
      release.setTracklist(tracks);

    } else {
      throw Exception("Error getting release");
    }
  }

  Future<Artist> getArtist(String artistId) async {
    final response = await http.get(
        Uri.parse("${baseUrl}artist/$artistId?fmt=json")
    );

    if (response.statusCode == 200) {
      Artist artist = Artist.fromJson(json.decode(response.body));
      var imageUrl = await getArtistImageFromDeezer(artist.name);
      if (imageUrl != null) {
        artist.setImageUrl(imageUrl);
      }
      return artist;
    } else {
      throw Exception("Error getting artist");
    }
  }

  Future<List<Release>> getArtistReleases(Artist artist) async {
    final response = await http.get(
        Uri.parse('${baseUrl}release-group?query=arid:${artist.id}&fmt=json&limit=100')
    );

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      List<Release> releases = (json['release-groups'] as List)
          .map((releaseJson) => Release.fromSearchJson(releaseJson))
          .toList()
          ..sort((a, b) => b.date.compareTo(a.date));

      Future.forEach(releases, (release) async {
        release.getGoodImageUrl();
      });

      return releases;
    } else {
      throw Exception('Failed to load releases');
    }
  }

  Future<List<Release>> searchRelease(String releaseName) async {
    final response = await http.get(
        Uri.parse("${baseUrl}release-group/?query=release:$releaseName&fmt=json&limit=20")
    );

    if (response.statusCode == 200) {
      List<Release> releases = (json.decode(response.body)['release-groups'] as List)
          .map((release) => Release.fromSearchJson(release))
          .toList();

      return releases;
    } else {
      throw Exception("Error searching release");
    }
  }

  Future<List<Artist>> searchArtist(String artistName) async {
    final response = await http.get(
        Uri.parse("${baseUrl}artist?query=artist:$artistName&fmt=json&inc=url-rels&limits=10")
    );

    if (response.statusCode == 200) {
      List<Artist> artists = (json.decode(response.body)['artists'] as List)
          .map((artist) => Artist.fromJson(artist))
          .toList();

      for (var artist in artists) {
        var imageUrl = await getArtistImageFromDeezer(artist.name);
        if (imageUrl != null) {
          artist.setImageUrl(imageUrl);
        }
      }

      return artists;
    } else {
      throw Exception("Error searching artist");
    }
  }

  Future<String?> getArtistImageFromDeezer(String artistName) async {
    final url = 'https://api.deezer.com/search/artist?q=$artistName';

    final response = await http.get(Uri.parse(url));
    if (response.statusCode != 200) return null;

    final data = json.decode(response.body);
    if (data['data'].isEmpty) return null;

    return data['data'][0]['picture_big'];
  }


  Future<bool> imageExists(String url) async {
    try {
      final uri = Uri.parse(url);
      final request = await HttpClient().headUrl(uri);
      final response = await request.close();
      return response.statusCode == HttpStatus.ok;
    } catch (e) {
      return false;
    }
  }

}