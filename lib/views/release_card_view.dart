import 'package:flutter/material.dart';
import 'package:sonnow/models/release.dart';
import 'package:sonnow/pages/release_page.dart';
import 'package:cached_network_image/cached_network_image.dart';

class ReleaseCard extends StatelessWidget {
  final Release release;

  const ReleaseCard({super.key, required this.release});

  void onTap(context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => ReleasePage(release: release)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => onTap(context),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        child: Column(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: CachedNetworkImage(
                imageUrl: release.imageUrl,
                width: 100,
                height: 100,
                fit: BoxFit.cover,
                placeholder: (context, url) => const SizedBox(width: 100, height: 100),
                errorWidget: (context, error, stackTrace) {
                  return const SizedBox(width: 100, height: 100);
                },
              ),
            ),
            SizedBox(height: 8),
            Text(release.title),
          ],
        ),
      ),
    );
  }
}
