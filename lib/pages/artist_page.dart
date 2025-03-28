import 'package:flutter/material.dart';
import 'package:sonnow/models/release.dart';
import 'package:sonnow/models/artist.dart';
import 'package:sonnow/services/musicbrainz_api.dart';
import 'package:sonnow/views/release_card_view.dart';

class ArtistPage extends StatefulWidget {
  final Artist artist;

  const ArtistPage({super.key, required this.artist});

  @override
  _ArtistPageState createState() => _ArtistPageState();
}

class _ArtistPageState extends State<ArtistPage> {
  final MusicBrainzApi musicApi = MusicBrainzApi();

  late Artist artist;
  late bool isLoading;

  @override
  void initState() {
    super.initState();
    artist = widget.artist;
    isLoading = true;
    _fetchArtist();
  }

  Future<void> _fetchArtist() async {
    try {
      if (artist.releaseByType.isEmpty) {
          final List<Release> releases = await musicApi.getArtistReleases(artist);
          artist.setReleasesByType(releases);
      }
      if (mounted) {
        setState(() {
          artist = artist;
          isLoading = false;
        });
      }
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Artist Page")),
      body:
          isLoading
              ? Center(child: CircularProgressIndicator())
              : Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(100),
                      child: Image.network(
                        artist.imageUrl,
                        width: 200,
                        height: 200,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return SizedBox(width: 200, height: 200);
                        },
                      ),
                    ),
                    SizedBox(height: 20),
                    Text(artist.name, style: TextStyle(fontSize: 18)),
                    SizedBox(height: 8),
                    Expanded(
                      child:
                          artist.releaseByType.isEmpty
                              ? const Center(child: Text("No result"))
                              : SingleChildScrollView(
                                child: Column(
                                  children:
                                      artist.releaseByType.entries.map((entry) {
                                        String type = entry.key;
                                        List<Release> releases = entry.value;

                                        return Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              type,
                                              style: TextStyle(
                                                fontSize: 18,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            SizedBox(
                                              height:
                                                  200, // Set a fixed height for the ListView
                                              child: ListView.builder(
                                                scrollDirection:
                                                    Axis.horizontal,
                                                itemCount: releases.length < 5 ? releases.length : 5,
                                                itemBuilder: (context, index) {
                                                  return ReleaseCard(
                                                    release: releases[index],
                                                  );
                                                },
                                              ),
                                            ),
                                          ],
                                        );
                                      }).toList(),
                                ),
                              ),
                    ),
                  ],
                ),
              ),
    );
  }
}
