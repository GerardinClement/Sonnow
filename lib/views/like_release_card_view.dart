import 'package:flutter/material.dart';
import 'package:sonnow/models/like_release.dart';
import 'package:sonnow/pages/release_page.dart';
import 'package:intl/intl.dart';
import 'package:sonnow/themes/app_colors.dart';
import 'package:sonnow/widgets/frosted_glass_card.dart';

class LikeReleaseCard extends StatelessWidget {
  final LikeRelease likeRelease;

  const LikeReleaseCard({super.key, required this.likeRelease});

  @override
  Widget build(BuildContext context) {
    return FrostedGlassCard(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ReleasePage(release: likeRelease.release),
          ),
        );
      },
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Première ligne : utilisateur et action
            Row(
              children: [
                if (likeRelease.user.profilePictureUrl != null)
                  CircleAvatar(
                    backgroundImage: NetworkImage(
                      likeRelease.user.profilePictureUrl!,
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
                    "${likeRelease.user.displayName} a aimé un album",
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
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(4),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.white.withOpacity(0.2),
                        blurRadius: 15,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: Image.network(
                      likeRelease.release.imageUrl,
                      width: 60,
                      height: 60,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        likeRelease.release.title,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        likeRelease.release.artist.name,
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.white70,
                        ),
                      ),
                    ],
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
                  ).format(likeRelease.createdAt.toLocal()),
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
