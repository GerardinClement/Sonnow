import 'package:flutter/material.dart';
import 'package:sonnow/models/release.dart';
import 'package:sonnow/models/review.dart';
import 'package:sonnow/services/musicbrainz_api.dart';
import 'package:sonnow/services/review_service.dart';
import 'package:flutter_rating_stars/flutter_rating_stars.dart';

class ReleasePage extends StatefulWidget {
  final String id;

  const ReleasePage({super.key, required this.id});

  @override
  _ReleasePageState createState() => _ReleasePageState();
}

class _ReleasePageState extends State<ReleasePage> {
  final MusicBrainzApi musicApi = MusicBrainzApi();
  final ReviewService reviewService = ReviewService();

  List<Review> reviews = [];
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
    _fetchReviews(widget.id);
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

  void _showReviewForm() {
    String content = "";
    double rating = 3.0;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
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
                onValueChanged: (v) => rating = v,
                starSize: 30,
                starColor: Colors.amber,
                starCount: 5,
                valueLabelVisibility: false,
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
                  final review = await reviewService.postReview(
                    release.id,
                    content,
                    rating,
                  );
                  setState(() {
                    reviews.add(review);
                    Navigator.pop(context);
                  });
                },
                child: Text("Save"),
              ),
            ],
          ),
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
                      "https://coverartarchive.org/release/${release.id}/front-250",
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
