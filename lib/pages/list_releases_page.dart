import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:sonnow/views/release_list_view.dart';
import 'package:sonnow/models/release.dart';

class ListReleasesPage extends StatefulWidget {
  final List<Release> releases;
  const ListReleasesPage({super.key, required this.releases});

  @override
  State<ListReleasesPage> createState() => _ListReleasesPageState();
}

class _ListReleasesPageState extends State<ListReleasesPage> {
  late List<Release> releases = widget.releases;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("IDK")),
      body: ReleaseListView(
          releases: releases,
          shrinkWrap: false)
    );
  }
}