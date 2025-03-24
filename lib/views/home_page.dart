import 'dart:async';

import 'package:flutter/material.dart';
import 'package:sonnow/models/release.dart';
import 'package:sonnow/services/musicbrainz_api.dart';
import 'package:sonnow/views/release_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final MusicBrainzApi musicApi = MusicBrainzApi();
  List<Release> releases = [];
  Timer? _debounce;
  final List<String> _tags = ['Title', 'Artist', 'Release'];
  String _selectedTag = "";

  @override
  void initState() {
    super.initState();
    _fetchRelease("temps mort");
  }

  Future<void> _fetchRelease(String query) async {
    try {
      List<Release> result = await musicApi.searchRelease(query);

      setState(() {
        releases = result;
      });
    } catch (e) {
      print(e);
      setState(() {
        releases = [];
      });
    }
  }

  void onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(seconds: 1), () {
      _fetchRelease(query);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Home Page"),
      ),
      body: Column(
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
                onSearchChanged(value);
              },
            ),
          ),
          const SizedBox(height: 8),
          Padding(
              padding: const EdgeInsets.fromLTRB(8.0, 0, 8.0, 8.0),
              child:
                Align(
                  alignment: Alignment.centerLeft,
                  child:
                    Wrap(
                      spacing: 8.0,
                      children: _tags.map((tag) {
                        return ChoiceChip(
                          label: Text(tag),
                          selected: _selectedTag == tag,
                          onSelected: (selected) {
                            setState(() {
                              _selectedTag = selected ? tag: "";
                            });
                          },
                        );
                      }).toList(),
                    ),
                ),
          ),
          Expanded( // Doit être dans Column
            child: ListView.builder(
              itemCount: releases.length,
              itemBuilder: (context, index) {
                return InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ReleasePage(id: releases[index].id),
                      ),
                    );
                  },
                  child: ListTile(
                    leading: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        "https://coverartarchive.org/release/${releases[index].id}/front-250",
                        width: 50,
                        height: 50,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return const SizedBox(
                            width: 50,
                            height: 50,
                          );
                        },
                      ),
                    ),
                    title: Text(releases[index].title),
                    subtitle: Text(releases[index].artist),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

