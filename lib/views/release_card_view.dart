import 'package:flutter/material.dart';
import 'package:sonnow/models/release.dart';
import 'package:sonnow/pages/release_page.dart';

class ReleaseCard extends StatelessWidget {
  final Release release;

  const ReleaseCard({Key? key, required this.release}) : super(key: key);

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
              child: Image.network(
                release.imageUrl,
                width: 100,
                height: 100,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
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
