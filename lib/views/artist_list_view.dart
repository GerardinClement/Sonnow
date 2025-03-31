import 'package:flutter/material.dart';
import 'package:sonnow/models/artist.dart';
import 'package:sonnow/pages/artist_page.dart';
import 'package:cached_network_image/cached_network_image.dart';


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
    final itemCount =
        shrinkWrap ? (artists.length < 2 ? artists.length : 2) : artists.length;
    return SizedBox(
      child:
          artists.isEmpty
              ? const Center(child: Text("No result"))
              : ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: itemCount,
                itemBuilder: (context, index) {
                  return InkWell(
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder:
                              (context) => ArtistPage(artist: artists[index]),
                        ),
                      );
                    },
                    child: ListTile(
                      leading: ClipRRect(
                        borderRadius: BorderRadius.circular(100),
                        child: CachedNetworkImage(
                          imageUrl: artists[index].imageUrl,
                          width: 50,
                          height: 50,
                          fit: BoxFit.cover,
                          placeholder: (context, url) => const CircularProgressIndicator(),
                          errorWidget: (context, error, stackTrace) {
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
