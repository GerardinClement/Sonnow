import 'package:flutter/material.dart';
import 'package:sonnow/pages/artist_page.dart';
import 'package:sonnow/models/artist.dart';
import 'package:cached_network_image/cached_network_image.dart';

class ArtistCard extends StatelessWidget {
  final Artist artist;

  const ArtistCard({
    super.key,
    required this.artist,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) =>
                ArtistPage(
                  artist: artist,
                ),
          ),
        );
      },
      child: Column(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(50),
            child: CachedNetworkImage(
              imageUrl: artist.imageUrl,
              width: 60,
              height: 60,
              fit: BoxFit.cover,
              placeholder:
                  (context, url) =>
              const CircularProgressIndicator(),
              errorWidget:
                  (context, error, stackTrace) =>
              const Icon(Icons.error),
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
    );
  }
}