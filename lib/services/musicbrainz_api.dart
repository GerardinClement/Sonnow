import 'dart:convert';

import 'package:sonnow/models/release.dart';
import 'package:sonnow/models/artist.dart';
import 'package:sonnow/models/track.dart';
import 'package:http/http.dart' as http;
import 'dart:io';
import 'dart:async';

class MusicBrainzApi {
  final Map<String, dynamic> _cache = {};
  final Map<String, DateTime> _cacheTimestamps = {};
  final Duration _cacheDuration = Duration(days: 1);

  Future<T> _cachedRequest<T>(String key, Future<T> Function() request) async {
    DateTime lastUpdate = _cacheTimestamps[key] ?? DateTime(0);
    if (_cache.containsKey(key) &&
        DateTime.now().difference(lastUpdate) < _cacheDuration) {
      return _cache[key];
    }

    final result = await request();
    _cache[key] = result;
    _cacheTimestamps[key] = DateTime.now();
    return result;
  }

  static const String baseUrl = "https://musicbrainz.org/ws/2/";

  Future<void> getReleaseTracklist(Release release) async {
    final response = await http.get(
      Uri.parse(
        "${baseUrl}release/${release.primaryReleaseId}?inc=recordings+artist-credits&fmt=json",
      ),
    );

    if (response.statusCode == 200) {
      var data = json.decode(response.body);
      List<Track> tracks =
          (data['media'][0]['tracks'] as List)
              .map((track) => Track.fromJson(track))
              .toList();
      release.setTracklist(tracks);
    } else {
      throw Exception("Error getting release");
    }
  }

  Future<Artist> getArtist(String artistId) async {
    final response = await http.get(
      Uri.parse("${baseUrl}artist/$artistId?fmt=json"),
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

  Future<void> getTrackDetail(Track track) async {
    final response = await http.get(
      Uri.parse(
        "${baseUrl}recording/${track.id}?inc=artist-rels+place-rels+label-rels&fmt=json",
      ),
    );

    if (response.statusCode == 200) {
      var data = json.decode(response.body);
      track.setArtistCredits(data['relations']);
    } else {
      throw Exception("Error getting track");
    }
  }

  Future<void> getArtistReleases(Artist artist) async {
    final response = await http.get(
      Uri.parse(
        '${baseUrl}release-group?query=arid:${artist.id}&fmt=json&limit=100',
      ),
    );

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      List<Release> releases =
          (json['release-groups'] as List)
              .map((releaseJson) => Release.fromSearchJson(releaseJson))
              .toList()
            ..sort((a, b) {
              if (a.date == "unknown") return 1;
              if (b.date == "unknown") return -1;
              return b.date.compareTo(a.date);
            });

      Future.forEach(releases, (release) async {
        release.getGoodImageUrl();
      });

      artist.setReleases(releases);
    } else {
      throw Exception('Failed to load releases');
    }
  }

  Future<List<Release>> searchRelease(String releaseName) async {
    final cacheKey = "searchRelease:$releaseName";

    return _cachedRequest(cacheKey, () async {
      final response = await http.get(
        Uri.parse(
          "${baseUrl}release-group/?query=release:$releaseName&fmt=json&limit=20",
        ),
      );

      if (response.statusCode == 200) {
        List<Release> releases =
            (json.decode(response.body)['release-groups'] as List)
                .map((release) => Release.fromSearchJson(release))
                .toList();

        return releases;
      } else {
        throw Exception("Error searching release");
      }
    });
  }

  Future<List<Artist>> searchArtist(String artistName) async {
    final cacheKey = "searchArtist:$artistName";

    return _cachedRequest(cacheKey, () async {
      final response = await http.get(
        Uri.parse(
          "${baseUrl}artist?query=artist:$artistName&fmt=json&inc=url-rels&limits=10",
        ),
      );

      if (response.statusCode == 200) {
        List<Artist> artists =
            (json.decode(response.body)['artists'] as List)
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
    });
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
