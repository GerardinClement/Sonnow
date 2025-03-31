import 'package:flutter/material.dart';
import 'package:sonnow/models/release.dart';
import 'package:sonnow/models/artist.dart';
import 'package:sonnow/services/musicbrainz_api.dart';
import 'package:sonnow/views/release_card_view.dart';
import 'package:cached_network_image/cached_network_image.dart';

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
      if (artist.releases.isEmpty) {
        await musicApi.getArtistReleases(artist);
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
                      child: CachedNetworkImage(
                        imageUrl: artist.imageUrl,
                        width: 200,
                        height: 200,
                        fit: BoxFit.cover,
                        placeholder:
                            (context, url) => SizedBox(width: 200, height: 200),
                        errorWidget: (context, error, stackTrace) {
                          return SizedBox(width: 200, height: 200);
                        },
                      ),
                    ),
                    SizedBox(height: 20),
                    Text(artist.name, style: TextStyle(fontSize: 18)),
                    SizedBox(height: 8),
                    SizedBox(
                      height: 150,
                      child:
                          artist.releases.isEmpty
                              ? const Center(child: Text("No result"))
                              : ListView.builder(
                                scrollDirection: Axis.horizontal,
                                itemCount: artist.releases.length > 15 ? 15 : artist.releases.length,
                                itemBuilder: (context, index) {
                                  return ReleaseCard(
                                    release: artist.releases[index],
                                  );
                                },
                              ),
                    ),
                  ],
                ),
              ),
    );
  }
}
