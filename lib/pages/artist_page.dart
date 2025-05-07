import 'package:flutter/material.dart';
import 'package:sonnow/models/artist.dart';
import 'package:sonnow/pages/list_releases_page.dart';
import 'package:sonnow/services/deezer_api.dart';
import 'package:sonnow/services/user_library_storage.dart';
import 'package:sonnow/services/user_profile_service.dart';
import 'package:sonnow/views/release_card_view.dart';
import 'package:sonnow/views/artist_card_view.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:sonnow/services/user_library_service.dart';
import 'package:sonnow/widgets/custom_fab_location.dart';
import 'package:sonnow/widgets/quick_actions_widget.dart';
import 'package:sonnow/widgets/like_animation_widget.dart';

class ArtistPage extends StatefulWidget {
  final Artist artist;

  const ArtistPage({super.key, required this.artist});

  @override
  State<ArtistPage> createState() => _ArtistPageState();
}

class _ArtistPageState extends State<ArtistPage> {
  final UserLibraryService userLibraryService = UserLibraryService();
  final UserProfileService userProfileService = UserProfileService();

  late Artist artist;
  late bool isLoading;
  late bool isHighlighted = false;
  bool _isQuickActionVisible = false;
  late String _errorMessage = "";

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
        artist.isHighlighted = await getIfArtistIsHighlighted(artist.id);
        artist.isLiked = await getIfArtistIsLiked(artist.id);
        artist.releases = await DeezerApi.getArtistAlbums(artist);
        artist.setReleasesByType(artist.releases);
        isHighlighted = await getIfArtistIsHighlighted(artist.id);
        List<Artist> relatedArtists = await DeezerApi.getRelatedArtists(artist);
        artist.setRelatedArtists(relatedArtists);
      }
      if (mounted) {
        setState(() {
          isHighlighted = isHighlighted;
          artist = artist;
          isLoading = false;
        });
      }
    } catch (e) {
      _errorMessage = "Error fetching artist data";
    }
  }

  Future<void> toggleLike() async {
    try {
      if (artist.isLiked) {
        await userLibraryService.unlikedArtist(artist);
        removeLikedArtistsFromBox(artist.id);
      } else {
        await userLibraryService.likeArtist(artist);
        addLikedArtistsInBox([artist]);
      }

      setState(() {
        artist.isLiked = !artist.isLiked;
      });
    } catch (e) {
      _errorMessage = "Error toggling like status";
    }
  }

  Future<void> addHighlightedArtists() async {
    try {
      await userProfileService.setHighlightedArtist(artist);
    } catch (e) {
      _errorMessage = "Error adding highlighted artist";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(kToolbarHeight),
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color.fromRGBO(171, 171, 171, 0.5),
                Color.fromRGBO(171, 171, 171, 0.3),
                Color.fromRGBO(171, 171, 171, 0.2),
                Color.fromRGBO(171, 171, 171, 0.1),
                Color.fromRGBO(171, 171, 171, 0.0),
              ],
            ),
          ),
          child: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
          ),
        ),
      ),
      body: Stack(
        children: [
          isLoading
              ? Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                physics: AlwaysScrollableScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Image sans padding et pleine largeur
                    ClipRRect(
                      child: CachedNetworkImage(
                        imageUrl: artist.imageUrl,
                        width: MediaQuery.of(context).size.width,
                        height: 300,
                        fit: BoxFit.cover,
                        placeholder:
                            (context, url) => SizedBox(
                              width: MediaQuery.of(context).size.width,
                              height: 200,
                            ),
                        errorWidget: (context, error, stackTrace) {
                          return SizedBox(
                            width: MediaQuery.of(context).size.width,
                            height: 200,
                          );
                        },
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                artist.name,
                                style: TextStyle(
                                  fontSize: 32,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Spacer(),
                              GestureDetector(
                                onTap: () {
                                  toggleLike();
                                },
                                child: LikeIconAnimated(
                                  isLiked: artist.isLiked,
                                ),
                              ),
                            ],
                          ),
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
                                      builder:
                                          (context) => ListReleasesPage(
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
                            child: Text(
                              "Album",
                              style: TextStyle(fontSize: 16),
                            ),
                          ),
                          SizedBox(
                            height: 220,
                            child:
                                artist.releaseByType.isEmpty
                                    ? const Center(child: Text("No result"))
                                    : ListView.builder(
                                      scrollDirection: Axis.horizontal,
                                      itemCount:
                                          artist
                                                      .releaseByType['Album']!
                                                      .length >
                                                  15
                                              ? 15
                                              : artist
                                                  .releaseByType['Album']!
                                                  .length,
                                      itemBuilder: (context, index) {
                                        return ReleaseCard(
                                          width: 150,
                                          height: 150,
                                          release:
                                              artist
                                                  .releaseByType['Album']![index],
                                        );
                                      },
                                    ),
                          ),
                          Padding(
                            padding: EdgeInsets.symmetric(vertical: 16),
                            child: Text(
                              "Single",
                              style: TextStyle(fontSize: 16),
                            ),
                          ),
                          SizedBox(
                            height: 220,
                            child:
                                artist.releaseByType.isEmpty
                                    ? const Center(child: Text("No result"))
                                    : ListView.builder(
                                      scrollDirection: Axis.horizontal,
                                      itemCount:
                                          artist
                                                      .releaseByType['Single']!
                                                      .length >
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
                          Padding(
                            padding: EdgeInsets.symmetric(vertical: 16),
                            child: Text(
                              "Related Artists",
                              style: TextStyle(fontSize: 16),
                            ),
                          ),
                          SizedBox(
                            height: 175,
                            child:
                                artist.relatedArtists.isEmpty
                                    ? const Center(child: Text("No result"))
                                    : ListView.builder(
                                      scrollDirection: Axis.horizontal,
                                      itemCount:
                                          artist.relatedArtists.length > 15
                                              ? 15
                                              : artist.relatedArtists.length,
                                      itemBuilder: (context, index) {
                                        return ArtistCard(
                                          artist: artist.relatedArtists[index],
                                        );
                                      },
                                    ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
          if (_isQuickActionVisible)
            Positioned(
              right: 30,
              bottom: 100,
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 10)],
                ),
                child: QuickActions(
                  onLike: toggleLike,
                  onAddToListen: null,
                  onAddHighlight: addHighlightedArtists,
                  openReviewForm: null,
                  isLiked: artist.isLiked,
                  isToListen: null,
                  isHighlighted: artist.isHighlighted,
                ),
              ),
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          setState(() {
            _isQuickActionVisible = !_isQuickActionVisible;
          });
        },
        child: Icon(_isQuickActionVisible ? Icons.close : Icons.add),
      ),
      floatingActionButtonLocation: CustomFabLocation(),
    );
  }
}
