import 'package:flutter/material.dart';
import 'package:sonnow/models/artist.dart';
import 'package:sonnow/pages/list_releases_page.dart';
import 'package:sonnow/services/deezer_api.dart';
import 'package:sonnow/services/musicbrainz_api.dart';
import 'package:sonnow/services/user_library_storage.dart';
import 'package:sonnow/views/release_card_view.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:sonnow/services/user_library_service.dart';

class ArtistPage extends StatefulWidget {
  final Artist artist;

  const ArtistPage({super.key, required this.artist});

  @override
  _ArtistPageState createState() => _ArtistPageState();
}

class _ArtistPageState extends State<ArtistPage> {
  final MusicBrainzApi musicApi = MusicBrainzApi();
  final UserLibraryService userLibraryService = UserLibraryService();

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
        artist.releases = await DeezerApi.getArtistAlbums(artist);
        artist.setReleasesByType(artist.releases);
        print("Artist releases: ${artist.releases}");
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

  Future<void> toggleLike() async {
    try {
      if (artist.isLiked) {
        await userLibraryService.unlikedArtist(artist);
        removeLikedArtistsFromBox(artist.id);
      } else {
        await userLibraryService.likeArtist(artist);
        addLikedArtistsInBox([artist.id]);
      }

      setState(() {
        artist.isLiked = !artist.isLiked;
      });
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Artist Page"),
        actions: [
          IconButton(
            onPressed: () {
              toggleLike();
            },
            icon: Icon(artist.isLiked ? Icons.favorite : Icons.favorite_border),
          ),
        ],
      ),
      body:
          isLoading
              ? Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                child: Padding(
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
                              (context, url) =>
                                  SizedBox(width: 200, height: 200),
                          errorWidget: (context, error, stackTrace) {
                            return SizedBox(width: 200, height: 200);
                          },
                        ),
                      ),
                      SizedBox(height: 20),
                      Text(artist.name, style: TextStyle(fontSize: 18)),
                      Row(
                        children: [
                          Padding(
                            padding: EdgeInsets.symmetric(vertical: 8),
                            child: Text(
                              "Discography",
                              style: TextStyle(fontSize: 20),
                            ),
                          ),
                          Spacer(),
                          ElevatedButton(
                            onPressed: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) => ListReleasesPage(
                                    releases: artist.releases,
                                  ),
                                ),
                              );
                            },
                            child: Text("See all"),
                          ),
                        ],
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(vertical: 8),
                        child: Text("Album", style: TextStyle(fontSize: 16)),
                      ),
                      SizedBox(
                        height: 150,
                        child:
                            artist.releaseByType.isEmpty
                                ? const Center(child: Text("No result"))
                                : ListView.builder(
                                  scrollDirection: Axis.horizontal,
                                  itemCount:
                                      artist.releaseByType['Album']!.length > 15
                                          ? 15
                                          : artist
                                              .releaseByType['Album']!
                                              .length,
                                  itemBuilder: (context, index) {
                                    return ReleaseCard(
                                      release:
                                          artist.releaseByType['Album']![index],
                                    );
                                  },
                                ),
                      ),
                      SizedBox(height: 8),
                      Padding(
                        padding: EdgeInsets.symmetric(vertical: 16),
                        child: Text("Single", style: TextStyle(fontSize: 16)),
                      ),
                      SizedBox(
                        height: 150,
                        child:
                            artist.releaseByType.isEmpty
                                ? const Center(child: Text("No result"))
                                : ListView.builder(
                                  scrollDirection: Axis.horizontal,
                                  itemCount:
                                      artist.releaseByType['Single']!.length >
                                              15
                                          ? 15
                                          : artist
                                              .releaseByType['Single']!
                                              .length,
                                  itemBuilder: (context, index) {
                                    return ReleaseCard(
                                      release:
                                          artist
                                              .releaseByType['Single']![index],
                                    );
                                  },
                                ),
                      ),
                    ],
                  ),
                ),
              ),
    );
  }
}
