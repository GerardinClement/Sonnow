import 'package:flutter/material.dart';
import 'package:sonnow/services/user_library_service.dart';
import 'package:sonnow/models/release.dart';
import 'package:sonnow/services/user_library_storage.dart';
import 'package:sonnow/views/release_card_view.dart';
import 'package:sonnow/main.dart';
import 'package:sonnow/globals.dart';
import 'package:sonnow/pages/list_releases_page.dart';

class LibraryPage extends StatefulWidget {
  const LibraryPage({super.key});

  @override
  _LibraryPageState createState() => _LibraryPageState();
}

class _LibraryPageState extends State<LibraryPage> with RouteAware {
  UserLibraryService userLibraryService = UserLibraryService();
  late List<Release> likedReleases = [];
  late List<Release> toListenReleases = [];

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
      likedReleases = await userLibraryService.fetchUserLikedReleases();
      toListenReleases = await userLibraryService.fetchUserToListenReleases();
      if (mounted) {
        setState(() {
          likedReleases = likedReleases;
          toListenReleases = toListenReleases;
        });
      }
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Library")),
      body: Column(
        children: [
          SizedBox(height: 20),
          Row(
            children: [
              Icon(Icons.favorite, color: Colors.red),
              SizedBox(width: 8),
              Text("Liked"),
            ],
          ),
          SizedBox(height: 20),
          SizedBox(
            height: 200,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                likedReleases.isNotEmpty ? Expanded(
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: likedReleases.length > 3 ? 3 : likedReleases.length,
                    itemBuilder: (context, index) {
                      return ReleaseCard(release: likedReleases[index]);
                    },
                  ),
                ): const SizedBox(
                  child: Text("No liked releases"),
                ),
                Center(
                  child: likedReleases.length > 3 ? IconButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ListReleasesPage(releases: likedReleases),
                        ),
                      );
                    },
                    icon: const Icon(Icons.add_circle_outline_sharp),
                  ): const SizedBox(),
                ),
              ],
            ),
          ),
          Row(
            children: [
              Icon(Icons.favorite, color: Colors.red),
              SizedBox(width: 8),
              Text("To Listen"),
            ],
          ),
          SizedBox(height: 20),
          SizedBox(
            height: 200,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                toListenReleases.isNotEmpty ? Expanded(
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: toListenReleases.length > 3 ? 3 : toListenReleases.length,
                    itemBuilder: (context, index) {
                      return ReleaseCard(release: toListenReleases[index]);
                    },
                  ),
                ): const SizedBox(
                  child: Text("No releases add to listen list"),
                ),
                Center(
                  child: toListenReleases.length > 3 ? IconButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ListReleasesPage(releases: toListenReleases),
                        ),
                      );

                    },
                    icon: const Icon(Icons.add_circle_outline_sharp),
                  ): const SizedBox(),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
