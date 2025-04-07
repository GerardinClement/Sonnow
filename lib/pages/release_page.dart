import 'package:flutter/material.dart';
import 'package:sonnow/models/release.dart';
import 'package:sonnow/models/artist.dart';
import 'package:sonnow/models/review.dart';
import 'package:sonnow/models/track.dart';
import 'package:sonnow/services/deezer_api.dart';
import 'package:sonnow/services/review_service.dart';
import 'package:flutter_rating_stars/flutter_rating_stars.dart';
import 'package:sonnow/services/user_library_service.dart';
import 'package:sonnow/services/user_library_storage.dart';
import 'package:sonnow/services/user_profile_service.dart';

class ReleasePage extends StatefulWidget {
  final Release release;

  const ReleasePage({super.key, required this.release});

  @override
  _ReleasePageState createState() => _ReleasePageState();
}

class _ReleasePageState extends State<ReleasePage> {
  final ReviewService reviewService = ReviewService();
  final UserLibraryService userLibraryService = UserLibraryService();
  final UserProfileService userProfileService = UserProfileService();

  List<Review> reviews = [];
  late Release release;
  late bool isHighlighted = false;

  @override
  void initState() {
    super.initState();
    release = widget.release;
    _fetchRelease(release);
    _fetchReviews(release.id);
    _fetchLikedReleases();
    _fetchToListenReleases();
  }

  Future<void> _fetchLikedReleases() async {
    try {
      bool releaseLiked = await userLibraryService.checkIfReleaseIsLiked(
        release.id,
      );
      setState(() {
        release.isLiked = releaseLiked;
      });
    } catch (e) {
      print(e);
    }
  }

  Future<void> _fetchToListenReleases() async {
    try {
      bool releaseToListen = await userLibraryService.checkIfReleaseIsToListen(
        release.id,
      );
      setState(() {
        release.toListen = releaseToListen;
      });
    } catch (e) {
      print(e);
    }
  }

  Future<void> _fetchRelease(Release release) async {
    try {
      final List<Track> tracklist = await DeezerApi.getAlbumTracks(release.id);
      release.setTracklist(tracklist);
      isHighlighted = await getIfReleaseIsHighlighted(release.id);
      setState(() {
        isHighlighted = isHighlighted;
        release = release;
      });
    } catch (e) {
      print(e);
    }
  }

  Future<void> _fetchReviews(String id) async {
    try {
      List<Review> result = await reviewService.getReviews(id);
      setState(() {
        reviews = result;
      });
    } catch (e) {
      print(e);
    }
  }

  Future<void> toggleLike() async {
    try {
      if (release.isLiked) {
        await userLibraryService.unlikeRelease(release);
        removeLikedReleasesFromBox(release.id);
      } else {
        await userLibraryService.likeRelease(release);
        addLikedReleasesInBox([release]);
      }

      setState(() {
        release.isLiked = !release.isLiked;
      });
    } catch (e) {
      print(e);
    }
  }

  Future<void> toggleToListen() async {
    try {
      if (release.toListen) {
        await userLibraryService.removeToListenRelease(release);
        removeToListenReleasesFromBox(release.id);
      } else {
        await userLibraryService.addToListenRelease(release);
        addToListenReleasesInBox([release]);
      }

      setState(() {
        release.toListen = !release.toListen;
      });
    } catch (e) {
      print(e);
    }
  }

  void _showReviewForm() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        String content = "";
        double rating = 3.0;

        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
                left: 16,
                right: 16,
                top: 16,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Add a review",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  TextField(
                    decoration: InputDecoration(labelText: "Your review"),
                    maxLines: 3,
                    onChanged: (value) => content = value,
                  ),
                  SizedBox(height: 10),
                  Text("Rate :"),
                  RatingStars(
                    value: rating,
                    onValueChanged: (v) {
                      setModalState(() {
                        rating = v;
                      });
                    },
                    starSize: 30,
                    starColor: Colors.amber,
                    starCount: 5,
                    valueLabelVisibility: false,
                  ),
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      reviewService.postReview(release.id, content, rating);
                      Navigator.pop(context);
                    },

                    child: Text("Save"),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget buildModalTrackDetail(Track track) {
    return SizedBox(
      width: double.infinity,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              track.title,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              track.artist[0].name,
              style: const TextStyle(fontSize: 18, color: Colors.grey),
            ),
            const SizedBox(height: 16),
            const Text(
              "Crédits artistiques:",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            track.artistCredits.isEmpty
                ? const Text("Aucun crédit disponible")
                : Container(
                  constraints: const BoxConstraints(maxHeight: 200),
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: track.artistCredits.length,
                    itemBuilder: (context, index) {
                      return ListTile(
                        dense: true,
                        title: Text(track.artistCredits[index].name),
                        subtitle: Text(track.artistCredits[index].tag),
                      );
                    },
                  ),
                ),
            Container(
              child: ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: track.placeCredits.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    leading: Text(track.placeCredits[index]['type']!),
                    title: Text(track.placeCredits[index]['name']!),
                    subtitle: Text(
                      track.placeCredits[index]['area_name'] != null
                          ? "${track.placeCredits[index]['area_name']}"
                          : "",
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  String getArtistNames(List<Artist> artists) {
    if (artists.length == 1) return artists[0].name;
    if (artists.length > 1) {
      String phrase = "";
      for (int i = 0; i < artists.length; i++) {
        phrase += artists[i].name + (i == artists.length - 1 ? "" : ", ");
      }
      return phrase;
    }
    return "";
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text(release.title),
          actions: [
            IconButton(
              onPressed: () {
                toggleLike();
              },
              icon: Icon(
                release.isLiked ? Icons.favorite : Icons.favorite_border,
              ),
            ),
            IconButton(
              onPressed: () {
                toggleToListen();
              },
              icon: Icon(
                release.toListen
                    ? Icons.add_circle
                    : Icons.add_circle_outline_outlined,
              ),
            ),
            IconButton(
              onPressed: () {
                userProfileService.setHighlightedRelease(release);
              },
              icon: Icon(isHighlighted ? Icons.star : Icons.star_border),
            ),
          ],
        ),
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
                      release.imageUrl,
                      width: 200,
                      height: 200,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return SizedBox(width: 200, height: 200);
                      },
                    ),
                  ),
                  SizedBox(width: 20),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(release.title, style: TextStyle(fontSize: 18)),
                        Text(
                          release.artist.name,
                          style: TextStyle(fontSize: 18),
                        ),
                        Text(release.type, style: TextStyle(fontSize: 18)),
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
                        return InkWell(
                          onTap: () async {
                            print("Display track detail");
                          },
                          child: ListTile(
                            leading: Text(
                              "${release.tracklist[index].position}",
                            ),
                            title: Text(release.tracklist[index].title),
                            subtitle: Text(
                              getArtistNames(release.tracklist[index].artist),
                            ),
                          ),
                        );
                      },
                    ),
                    Column(
                      children: [
                        ElevatedButton(
                          onPressed: _showReviewForm,
                          child: Text("Ajouter un avis"),
                        ),
                        Expanded(
                          child: ListView.builder(
                            itemCount: reviews.length,
                            itemBuilder: (context, index) {
                              return ListTile(
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(reviews[index].content),
                                    RatingStars(
                                      value: reviews[index].rating,
                                      onValueChanged: (v) {},
                                      starSize: 20,
                                      starColor: Colors.amber,
                                      starCount: 5,
                                      valueLabelVisibility: false,
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
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
