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
  late List<Release> _filteredReleases = releases;
  late List<String> _filterTypes = createFilterType(releases);
  String _selectedFilter = "";


  List<String> createFilterType(List<Release> releases) {
    List<String> types = [];
    for (var release in releases) {
      if (!types.contains(release.type)) {
        types.add(release.type);
      }
    }
    return types;
  }

  void _filterReleases(String filter) {
    if (filter.isEmpty) {
      setState(() {
        _filteredReleases = releases;
      });
    } else {
      setState(() {
        _filteredReleases = releases.where((release) => release.type == filter).toList();
      });
    }
  }

@override
Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(title: const Text("IDK")),
    body: SingleChildScrollView(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16.0, 0, 8.0, 8.0),
            child: Container(
              width: double.infinity,
              child: Wrap(
                spacing: 8.0,
                runSpacing: 8.0,
                alignment: WrapAlignment.start,
                children: _filterTypes.map((tag) {
                  return ChoiceChip(
                    label: Text(tag),
                    selected: _selectedFilter == tag,
                    onSelected: (selected) {
                      setState(() {
                        _selectedFilter = selected ? tag : "";
                      });
                      _filterReleases(_selectedFilter);
                    },
                  );
                }).toList(),
              ),
            ),
          ),
          ReleaseListView(releases: _filteredReleases, shrinkWrap: false),
        ],
      )
    ),
  );
}}
