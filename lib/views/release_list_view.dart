import 'package:flutter/material.dart';
import 'package:sonnow/models/release.dart';
import 'package:sonnow/pages/release_page.dart';

class ReleaseListView extends StatelessWidget {
  final List<Release> releases;
  final bool shrinkWrap;

  const ReleaseListView({
    super.key,
    required this.releases,
    required this.shrinkWrap,
  });

  @override
  Widget build(BuildContext context) {
    final itemCount = shrinkWrap ? (releases.length < 2 ? releases.length : 2) : releases.length;
    return SizedBox(
      child: releases.isEmpty
          ? const Center(child: Text("No result"))
          :  ListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: itemCount,
        itemBuilder: (context, index) {
          return InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ReleasePage(release: releases[index]),
                ),
              );
            },
            child: ListTile(
              leading: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  releases[index].imageUrl,
                  width: 50,
                  height: 50,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    releases[index].getGoodImageUrl();
                    return Image.network(
                      releases[index].imageUrl,
                        width: 50,
                        height: 50,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return const SizedBox(width: 50, height: 50);
                        },
                    );
                  },
                ),
              ),
              title: Text(releases[index].title),
              subtitle: Text(releases[index].artist),
            ),
          );
        },
      ),
    );
  }
}