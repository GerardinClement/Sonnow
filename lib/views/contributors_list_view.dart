import 'package:flutter/material.dart';
import 'package:sonnow/models/artist.dart';
import 'package:sonnow/pages/artist_page.dart';

class ContributorsList extends StatelessWidget {
  final List<Artist> contributors;

  const ContributorsList({super.key, required this.contributors});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: contributors.map((contributor) {
        return InkWell(
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => ArtistPage(artist: contributor),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 4.0),
            child: Row(
              children: [
                CircleAvatar(
                  backgroundImage: NetworkImage(contributor.imageUrl),
                  radius: 15,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    contributor.name,
                    style: const TextStyle(fontSize: 18),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}