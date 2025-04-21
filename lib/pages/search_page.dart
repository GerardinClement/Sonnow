import 'dart:async';

import 'package:flutter/material.dart';
import 'package:sonnow/models/artist.dart';
import 'package:sonnow/models/release.dart';
import 'package:sonnow/models/user.dart';
import 'package:sonnow/utils.dart';
import 'package:sonnow/views/release_list_view.dart';
import 'package:sonnow/views/artist_list_view.dart';
import 'package:sonnow/views/user_profile_list_view.dart';
import 'package:sonnow/services/deezer_api.dart';
import 'package:sonnow/services/user_profile_service.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final UserProfileService userProfileService = UserProfileService();
  final DeezerApi deezerApi = DeezerApi();
  List<Release> releases = [];
  List<Artist> artists = [];
  List<Release> albums = [];
  List<User> users = [];
  Timer? _debounce;
  final List<String> _tags = ['Artist', 'Album', 'Track', 'User'];
  String _selectedTag = "";
  String _searchQuery = "";
  int _searchId = 0;

  @override
  void initState() {
    super.initState();
  }

  void clearSearch() {
    setState(() {
      releases = [];
      artists = [];
    });
  }

  Future<void> _fetchGlobal(String query, bool limited) async {
    try {
      int searchId = _searchId;
      List<Release> result = await DeezerApi.searchGlobal(query);
      List<Artist> artistsResult = [];
      List<Release> albumsResult = [];
      for (var release in result) {
        if (!artistsResult.any((artist) => artist.id == release.artist.id)) {
          artistsResult.add(release.artist);
        }
        if (release.type == "album") {
          albumsResult.add(release);
        }
      }

      artistsResult = sortArtists(artistsResult, _searchQuery);
      albumsResult = sortReleases(albumsResult, artistsResult[0].name);
      result = sortReleases(result, artistsResult[0].name);
      if (mounted && searchId == _searchId) {
        setState(() {
          releases = result;
          artists = artistsResult;
          albums = albumsResult;
        });
      }
    } catch (e) {
      setState(() {
        releases = [];
      });
    }
  }

  Future<void> _fetchArtist(String query, bool limited) async {
    try {
      int searchId = _searchId;
      List<Artist> result = await DeezerApi.searchArtists(query);

      if (mounted && searchId == _searchId) {
        setState(() {
          artists = result;
        });
      }
    } catch (e) {
      setState(() {
        artists = [];
      });
    }
  }

  Future<void> _fetchAlbum(String query, bool limited) async {
    try {
      int searchId = _searchId;
      List<Release> result = await DeezerApi.searchAlbums(query);

      if (mounted && searchId == _searchId) {
        setState(() {
          albums = result;
        });
      }
    } catch (e) {
      setState(() {
        releases = [];
      });
    }
  }

  Future<void> _fetchUserProfile(String query, bool limited) async {
    try {
      int searchId = _searchId;
      List<User> result = await userProfileService.searchUser(query);

      if (mounted && searchId == _searchId) {
        setState(() {
          users = result;
        });
      }
    } catch (e) {
      setState(() {
        users = [];
      });
    }
  }

  void onSearchChanged(String query) {
    if (query.length < 2) {
      clearSearch();
      return;
    }

    if (_debounce?.isActive ?? false) _debounce!.cancel();

    _debounce = Timer(const Duration(milliseconds: 300), () async {
      print("Searching for: $query");
      _searchId += 1;
      if (_selectedTag == "Artist") await _fetchArtist(query, false);
      if (_selectedTag == "Album") await _fetchAlbum(query, false);
      if (_selectedTag.isEmpty) {
        Future.wait([
          _fetchGlobal(query, true),
          _fetchUserProfile(query, true),
        ]).then((_) {
          if (mounted) {
            setState(() {
              preloadArtistImages(artists);
              preloadReleaseImages(releases);
            });
          }
        });
      }
    });
  }

  Future<void> preloadArtistImages(List<Artist> artists) async {
    for (var artist in artists) {
      precacheImage(NetworkImage(artist.imageUrl), context);
    }
  }

  Future<void> preloadReleaseImages(List<Release> releases) async {
    for (var release in releases) {
      precacheImage(NetworkImage(release.imageUrl), context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Home Page")),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.only(bottom: 100),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextField(
                  decoration: InputDecoration(
                    hintText: 'Search...',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                  ),
                  onChanged: (value) {
                    _searchQuery = value;
                    onSearchChanged(value);
                  },
                ),
              ),
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.fromLTRB(8.0, 0, 8.0, 8.0),
                child: Wrap(
                  spacing: 8.0,
                  children:
                      _tags.map((tag) {
                        return ChoiceChip(
                          label: Text(tag),
                          selected: _selectedTag == tag,
                          onSelected: (selected) {
                            setState(() {
                              _selectedTag = selected ? tag : "";
                            });
                            onSearchChanged(_searchQuery);
                          },
                        );
                      }).toList(),
                ),
              ),
              if (_selectedTag == "Artist" || _selectedTag.isEmpty) ...[
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    "Artists",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
                ArtistListView(
                  artists: artists,
                  shrinkWrap: _selectedTag != "Artist",
                ),
              ],
              if (_selectedTag == "Album" || _selectedTag.isEmpty) ...[
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    "Albums",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
                ReleaseListView(
                  releases: albums,
                  shrinkWrap: _selectedTag != "Album",
                ),
              ],
              if (_selectedTag == "Track" || _selectedTag.isEmpty) ...[
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    "Track",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
                ReleaseListView(
                  releases: releases,
                  shrinkWrap: _selectedTag != "Track",
                ),
              ],
              if (_selectedTag == "User" || _selectedTag.isEmpty) ...[
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    "Users",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
                UserProfileListView(
                  users: users,
                  shrinkWrap: _selectedTag != "User",
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
