import 'package:flutter/material.dart';
import 'package:sonnow/models/release.dart';
import 'package:sonnow/services/musicbrainz_api.dart';

class ReleasePage extends StatefulWidget {
  final String id;

  const ReleasePage({super.key, required this.id});

  @override
  _ReleasePageState createState() => _ReleasePageState();
}

class _ReleasePageState extends State<ReleasePage> {
  final MusicBrainzApi musicApi = MusicBrainzApi();
  Release release = Release(
    id: "0",
    title: "Unknown",
    artist: "Unknown",
    date: "Unknown",
  );

  @override
  void initState() {
    super.initState();
    _fetchRelease(widget.id);
  }

  Future<void> _fetchRelease(String id) async {
    try {
      release = await musicApi.getRelease(id);
      setState(() {
        release = release;
      });
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    //TODO A revoir pour faire un scroll unique
    return DefaultTabController(
      length: 2, // Nombre d'onglets
      child: Scaffold(
        appBar: AppBar(title: Text("Release Page")),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      "https://coverartarchive.org/release/${release.id}/front-250",
                      width: 200,
                      height: 200,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return SizedBox(
                          width: 200,
                          height: 200,
                        );
                      },
                    ),
                  ),
                  SizedBox(width: 20),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(release.title, style: TextStyle(fontSize: 18)),
                        Text(release.artist, style: TextStyle(fontSize: 18)),
                        Text(release.date, style: TextStyle(fontSize: 18)),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20),

              TabBar(tabs: [Tab(text: "Tracklist"), Tab(text: "Avis")]),

              Expanded(
                child: TabBarView(
                  children: [
                    ListView.builder(
                      itemCount: release.tracklist.length,
                      itemBuilder: (context, index) {
                        return ListTile(
                          leading: Text("${release.tracklist[index].position}"),
                          title: Text(release.tracklist[index].title),
                        );
                      },
                    ),
                    Center(child: Text("TODO: Avis")),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
