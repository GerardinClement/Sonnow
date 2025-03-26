import 'package:flutter/material.dart';
import 'package:sonnow/models/release.dart';
import 'package:sonnow/models/review.dart';
import 'package:sonnow/services/musicbrainz_api.dart';
import 'package:sonnow/services/review_service.dart';
import 'package:flutter_rating_stars/flutter_rating_stars.dart';
import 'package:sonnow/services/user_library_service.dart';

class ReleasePage extends StatefulWidget {
  final Release release;

  const ReleasePage({super.key, required this.release});

  @override
  _ReleasePageState createState() => _ReleasePageState();
}

class _ReleasePageState extends State<ReleasePage> {
  final MusicBrainzApi musicApi = MusicBrainzApi();
  final ReviewService reviewService = ReviewService();
  final UserLibraryService userLibraryService = UserLibraryService();

  List<Review> reviews = [];
  late Release release;

  @override
  void initState() {
    super.initState();
    release = widget.release;
    _fetchRelease(release);
    _fetchReviews(release.id);
    _fetchLikedReleases();
  }

  Future<void> _fetchLikedReleases() async {
    try {
      bool releaseLiked = await userLibraryService.checkIfReleaseIsLiked(release.id);
      setState(() {
        release.isLiked = releaseLiked;
      });

    } catch (e) {
      print(e);
    }
  }

  Future<void> _fetchRelease(Release release) async {
    try {
      await musicApi.getReleaseTracklist(release);
      setState(() {
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
        await userLibraryService.unlikeRelease(release.id);
      } else {
        await userLibraryService.likeRelease(release.id);
      }
      setState(() {
        release.isLiked = !release.isLiked;
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
                      reviewService.postReview(
                        release.id,
                        content,
                        rating,
                      );
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

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
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
                        Text(release.artist, style: TextStyle(fontSize: 18)),
                        Text(release.type, style: TextStyle(fontSize: 18)),
                        Text(release.date, style: TextStyle(fontSize: 18)),
                      ],
                    ),
                  ),
                  SizedBox( width: 20),
                  IconButton(onPressed: () {
                    toggleLike();
                  }, icon: Icon(release.isLiked ? Icons.favorite : Icons.favorite_border)),
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
