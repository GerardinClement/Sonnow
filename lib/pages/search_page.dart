import 'dart:async';

import 'package:flutter/material.dart';
import 'package:sonnow/models/artist.dart';
import 'package:sonnow/models/release.dart';
import 'package:sonnow/services/musicbrainz_api.dart';
import 'package:sonnow/views/release_list_view.dart';
import 'package:sonnow/views/artist_list_view.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final MusicBrainzApi musicApi = MusicBrainzApi();
  List<Release> releases = [];
  List<Artist> artists = [];
  Timer? _debounce;
  final List<String> _tags = ['Artist', 'Release'];
  String _selectedTag = "";
  String _searchQuery = "";

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

  Future<void> _fetchRelease(String query) async {
    try {
      List<Release> result = await musicApi.searchRelease(query);
      if (mounted) {
        setState(() {
          releases = result;
        });
      }
    } catch (e) {
      print(e);
      setState(() {
        releases = [];
      });
    }
  }

  Future<void> _fetchArtist(String query) async {
    try {
      List<Artist> result = await musicApi.searchArtist(query);

      if (mounted) {
        setState(() {
          artists = result;
        });
      }
    } catch (e) {
      print(e);
      setState(() {
        artists = [];
      });
    }
  }

  void onSearchChanged(String query) async {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () async {
      if (query.isEmpty) {
        clearSearch();
        return;
      }
      if (_selectedTag == "Artist") await _fetchArtist(query);
      if (_selectedTag == "Release") await _fetchRelease(query);
      if (_selectedTag.isEmpty) {
        Future.wait([
          _fetchArtist(query),
          _fetchRelease(query)
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
                children: _tags.map((tag) {
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
            if (_selectedTag == "Release" || _selectedTag.isEmpty) ...[
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  "Release",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              ReleaseListView(
                releases: releases,
                shrinkWrap: _selectedTag != "Release",
              ),
            ],
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
          ],
        ),
      ),
    );
  }
}