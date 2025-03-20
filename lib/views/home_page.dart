import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:sonnow/models/release.dart';
import 'package:sonnow/services/musicbrainz_api.dart';
import 'package:sonnow/views/release_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();

}

class _HomePageState extends State<HomePage> {
  final MusicBrainzApi musicApi = MusicBrainzApi();
  List<Release> releases = [];

  @override
  void initState() {
    super.initState();
    _fetchRelease();
  }

  Future<void> _fetchRelease() async {
    try {
      List<Release> result = await musicApi.searchRelease("temps mort");

      setState(() {
        releases = result;
      });

    } catch (e) {
      print(e);
      setState(() {
        releases = [];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Home Page"),
      ),
      body: releases.isEmpty
        ? Center(child: CircularProgressIndicator())
          :
        ListView.builder(
          itemCount: releases.length,
          itemBuilder: (context, index) {
            return InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ReleasePage(id: releases[index].id),
                  ),
                );
              },
              child: ListTile(
                leading: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    "https://coverartarchive.org/release/${releases[index].id}/front-250",
                    width: 50,
                    height: 50,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return SizedBox(
                        width: 50,
                        height: 50,
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
