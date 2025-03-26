import 'package:flutter/material.dart';
import 'package:sonnow/models/release.dart';
import 'package:sonnow/models/artist.dart';
import 'package:sonnow/services/musicbrainz_api.dart';
import 'package:sonnow/pages/release_page.dart';
import 'package:sonnow/views/release_card_view.dart';

class ArtistPage extends StatefulWidget {
  final String id;

  const ArtistPage({super.key, required this.id});

  @override
  _ArtistPageState createState() => _ArtistPageState();
}

class _ArtistPageState extends State<ArtistPage> {
  final MusicBrainzApi musicApi = MusicBrainzApi();

  Artist artist = Artist(id: "0", name: "Unknown");

  @override
  void initState() {
    super.initState();
    _fetchArtist(widget.id);
  }

  Future<void> _fetchArtist(String id) async {
    try {
      artist = await musicApi.getArtist(id);
      final List<Release> releases = await musicApi.getArtistReleases(artist);
      artist.setReleasesByType(releases);
      setState(() {
        artist = artist;
      });
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Artist Page")),
      body: Padding(
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
              Text("Releases", style: TextStyle(fontSize: 18)),
              SizedBox(height: 8),
              Expanded(
                child: artist.releaseByType.isEmpty
                    ? const Center(child: Text("No result"))
                    : SingleChildScrollView(
                  child: Column(
                    children: artist.releaseByType.entries.map((entry) {
                      String type = entry.key;
                      List<Release> releases = entry.value;

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(type, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                          SizedBox(
                            height: 200, // Set a fixed height for the ListView
                            child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              itemCount: releases.length,
                              itemBuilder: (context, index) {
                                return ReleaseCard(release: releases[index]);
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