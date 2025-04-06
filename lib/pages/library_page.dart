import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:sonnow/services/user_library_service.dart';
import 'package:sonnow/models/release.dart';
import 'package:sonnow/models/artist.dart';
import 'package:sonnow/views/release_card_view.dart';
import 'package:sonnow/globals.dart';
import 'package:sonnow/pages/list_releases_page.dart';
import 'package:sonnow/pages/list_artists_page.dart';
import 'package:sonnow/pages/artist_page.dart';

class LibraryPage extends StatefulWidget {
  const LibraryPage({super.key});

  @override
  _LibraryPageState createState() => _LibraryPageState();
}

class _LibraryPageState extends State<LibraryPage> with RouteAware {
  UserLibraryService userLibraryService = UserLibraryService();
  List<Release> likedReleases = [];
  List<Release> toListenReleases = [];
  List<Artist> likedArtists = [];

  @override
  void initState() {
    super.initState();
    _fetchUserLibrary();
    libraryRefreshNotifier.addListener(_handleTabChange);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    routeObserver.subscribe(this, ModalRoute.of(context)!);
    _fetchUserLibrary();
  }

  @override
  void dispose() {
    routeObserver.unsubscribe(this);
    libraryRefreshNotifier.removeListener(_handleTabChange);
    super.dispose();
  }

  void _handleTabChange() {
    _fetchUserLibrary();
  }

  Future<void> _fetchUserLibrary() async {
    try {
      final fetchedLikedReleases = await userLibraryService.fetchUserLikedReleases();
      final fetchedToListenReleases = await userLibraryService.fetchUserToListenReleases();
      final fetchedLikedArtists = await userLibraryService.fetchUserLikedArtists();
      if (mounted) {
        setState(() {
          likedReleases = fetchedLikedReleases;
          toListenReleases = fetchedToListenReleases;
          likedArtists = fetchedLikedArtists;
        });
      }
    } catch (e) {
      print(e);
    }
  }

  Widget buildSectionTitle(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: Colors.red),
        const SizedBox(width: 8),
        Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget buildHorizontalList({required Widget list, required bool showMore, required VoidCallback onMore}) {
    return SizedBox(
      height: 200,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(child: list),
          if (showMore)
            Center(
              child: IconButton(
                onPressed: onMore,
                icon: const Icon(Icons.add_circle_outline_sharp),
              ),
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Library")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            buildSectionTitle("Liked", Icons.favorite),
            const SizedBox(height: 10),
            buildHorizontalList(
              list: likedReleases.isNotEmpty
                  ? ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: likedReleases.length > 3 ? 3 : likedReleases.length,
                itemBuilder: (context, index) => ReleaseCard(release: likedReleases[index]),
              )
                  : const Center(child: Text("No liked releases")),
              showMore: likedReleases.length > 3,
              onMore: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ListReleasesPage(releases: likedReleases),
                ),
              ),
            ),
            const SizedBox(height: 20),
            buildSectionTitle("To Listen", Icons.headphones),
            const SizedBox(height: 10),
            buildHorizontalList(
              list: toListenReleases.isNotEmpty
                  ? ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: toListenReleases.length > 3 ? 3 : toListenReleases.length,
                itemBuilder: (context, index) => ReleaseCard(release: toListenReleases[index]),
              )
                  : const Center(child: Text("No releases in to-listen list")),
              showMore: toListenReleases.length > 3,
              onMore: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ListReleasesPage(releases: toListenReleases),
                ),
              ),
            ),
            const SizedBox(height: 20),
            buildSectionTitle("Artists Liked", Icons.person),
            const SizedBox(height: 10),
            buildHorizontalList(
              list: likedArtists.isNotEmpty
                  ? ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: likedArtists.length > 3 ? 3 : likedArtists.length,
                itemBuilder: (context, index) {
                  final artist = likedArtists[index];
                  return InkWell(
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ArtistPage(artist: artist),
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: Column(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(50),
                            child: CachedNetworkImage(
                              imageUrl: artist.imageUrl,
                              width: 60,
                              height: 60,
                              fit: BoxFit.cover,
                              placeholder: (context, url) => const CircularProgressIndicator(),
                              errorWidget: (context, error, stackTrace) => const Icon(Icons.error),
                            ),
                          ),
                          const SizedBox(height: 6),
                          SizedBox(
                            width: 80,
                            child: Text(
                              artist.name,
                              textAlign: TextAlign.center,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              )
                  : const Center(child: Text("No liked artists")),
              showMore: likedArtists.length > 3,
              onMore: () => {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ListArtistsPage(artists: likedArtists),
                  ),
                ),
              }
            ),
          ],
        ),
      ),
    );
  }
}
