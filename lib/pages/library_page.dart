import 'package:flutter/material.dart';
import 'package:sonnow/services/user_library_service.dart';

import 'package:sonnow/models/release.dart';
import 'package:sonnow/views/release_card_view.dart';

class LibraryPage extends StatefulWidget {
  const LibraryPage({super.key});

  @override
  _LibraryPageState createState() => _LibraryPageState();
}

class _LibraryPageState extends State<LibraryPage> {
  UserLibraryService userLibraryService = UserLibraryService();
  late List<Release> likedReleases = [];

  @override
  void initState() {
    super.initState();
    _fetchUserLibrary();
  }

  Future<void> _fetchUserLibrary() async {
    try {
      likedReleases = await userLibraryService.fetchUserLikedReleases();
      if (mounted) {
        setState(() {
          likedReleases = likedReleases;
        });
      }
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Text("Library Page"),
          SizedBox(height: 20),
          ListView(
            shrinkWrap: true,
            children: likedReleases.map((release) {
              return ReleaseCard(release: release);
            }).toList(),
          )
        ],
      )
    );
  }
}
