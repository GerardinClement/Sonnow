import 'package:flutter/material.dart';
import 'package:sonnow/models/like_artist.dart';
import 'package:sonnow/pages/artist_page.dart';
import 'package:intl/intl.dart';
import 'package:sonnow/widgets/frosted_glass_card.dart';

class LikeArtistCard extends StatelessWidget {
  final LikeArtist likeArtist;

  const LikeArtistCard({super.key, required this.likeArtist});

  @override
  Widget build(BuildContext context) {
    return FrostedGlassCard(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ArtistPage(artist: likeArtist.artist),
          ),
        );
      },
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                if (likeArtist.user.profilePictureUrl != null)
                  CircleAvatar(
                    backgroundImage: NetworkImage(
                      likeArtist.user.profilePictureUrl!,
                    ),
                    radius: 20,
                  )
                else
                  const CircleAvatar(
                    backgroundColor: Colors.grey,
                    radius: 20,
                    child: Icon(Icons.person, color: Colors.white),
                  ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    "${likeArtist.user.displayName} a aimé un artiste",
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                CircleAvatar(
                  backgroundImage: NetworkImage(likeArtist.artist.imageUrl),
                  radius: 30,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    likeArtist.artist.name,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
            Align(
              alignment: Alignment.bottomRight,
              child: Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text(
                  DateFormat(
                    'dd/MM/yyyy HH:mm',
                  ).format(likeArtist.createdAt.toLocal()),
                  style: const TextStyle(fontSize: 12, color: Colors.white54),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
