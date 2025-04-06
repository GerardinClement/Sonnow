import 'package:flutter/material.dart';
import 'package:sonnow/views/artist_list_view.dart';
import 'package:sonnow/models/artist.dart';

class ListArtistsPage extends StatefulWidget {
  final List<Artist> artists;
  const ListArtistsPage({super.key, required this.artists});

  @override
  State<ListArtistsPage> createState() => _ListArtistsPageState();
}

class _ListArtistsPageState extends State<ListArtistsPage> {
  late List<Artist> artists = widget.artists;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: const Text("IDK")),
        body: ArtistListView(
            artists: artists,
            shrinkWrap: false)
    );
  }
}