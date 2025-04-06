import 'package:flutter/material.dart';
import 'package:sonnow/services/musicbrainz_api.dart';
import 'package:sonnow/models/release.dart';
import 'package:sonnow/views/release_list_view.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final MusicBrainzApi musicApi = MusicBrainzApi();
  List<Release> releases = [];

  @override
  void initState() {
    super.initState();
    _fetchLatestReleases();
  }

  Future<void> _fetchLatestReleases() async {
    try {
      List<Release> result = await musicApi.getLatestReleases();
      if (mounted) {
        setState(() {
          releases = result;
        });
      }
    } catch (e) {
      setState(() {
        releases = [];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Sonnow")),
      body: SingleChildScrollView(
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 20, horizontal: 10),
          child: Column(
            children: [
              const Text("Dernières sorties", style: TextStyle(fontSize: 20)),
              ReleaseListView(releases: releases, shrinkWrap: false),
            ],
          ),
        ),
      ),
    );
  }
}
