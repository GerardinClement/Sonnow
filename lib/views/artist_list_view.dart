import 'package:flutter/material.dart';
import 'package:sonnow/models/artist.dart';

class ArtistListView extends StatelessWidget {
  final List<Artist> artists;
  final bool shrinkWrap;

  const ArtistListView({
    Key? key,
    required this.artists,
    required this.shrinkWrap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final itemCount = shrinkWrap ? (artists.length < 2 ? artists.length : 2) : artists.length;
    return SizedBox(
      child: artists.isEmpty
          ? const Center(child: Text("No result"))
          : ListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: itemCount,
        itemBuilder: (context, index) {
          return InkWell(
            onTap: () {
              // Navigator.push(
              //   context,
              //   MaterialPageRoute(
              //     builder: (context) => ArtistsPage(id: artists[index].id),
              //   ),
              // );
              print("Artist ID: ${artists[index].id}");
            },
            child: ListTile(
              // leading: ClipRRect(
              //   borderRadius: BorderRadius.circular(8),
              //   child: Image.network(
              //     "https://coverartarchive.org/release/${releases[index].id}/front-250",
              //     width: 50,
              //     height: 50,
              //     fit: BoxFit.cover,
              //     errorBuilder: (context, error, stackTrace) {
              //       return const SizedBox(width: 50, height: 50);
              //     },
              //   ),
              // ),
              title: Text(artists[index].name),
            ),
          );
        },
      ),
    );
  }
}