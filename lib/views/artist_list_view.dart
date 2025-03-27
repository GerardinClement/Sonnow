import 'package:flutter/material.dart';
import 'package:sonnow/models/artist.dart';
import 'package:sonnow/pages/artist_page.dart';

class ArtistListView extends StatelessWidget {
  final List<Artist> artists;
  final bool shrinkWrap;

  const ArtistListView({
    super.key,
    required this.artists,
    required this.shrinkWrap,
  });

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
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ArtistPage(artist: artists[index]),
                ),
              );
              print("Artist ID: ${artists[index].id}");
            },
            child: ListTile(
              leading: ClipRRect(
                borderRadius: BorderRadius.circular(100),
                child: Image.network(
                  artists[index].imageUrl,
                  width: 50,
                  height: 50,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return const SizedBox(width: 50, height: 50);
                  },
                ),
              ),
              title: Text(artists[index].name),
            ),
          );
        },
      ),
    );
  }
}