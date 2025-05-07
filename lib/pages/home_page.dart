import 'package:flutter/material.dart';
import 'package:sonnow/models/review.dart';
import 'package:sonnow/models/like_artist.dart';
import 'package:sonnow/models/like_release.dart';
import 'package:sonnow/services/review_service.dart';
import 'package:sonnow/services/user_profile_service.dart';
import 'package:sonnow/views/like_release_card_view.dart';
import 'package:sonnow/views/review_card_view.dart';
import 'package:sonnow/views/like_artist_card_view.dart';
import 'package:sonnow/pages/artist_page.dart';
import 'package:sonnow/pages/release_page.dart';
import 'package:sonnow/pages/profile_page.dart';
import 'package:sonnow/globals.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with RouteAware {
  final UserProfileService userProfileService = UserProfileService();
  final ReviewService reviewService = ReviewService();
  late List<LikeRelease> followedLikedReleases;
  late List<LikeArtist> followedLikedArtists;
  late List<Review> followedReviews;
  late List<Review> mostPopularReviews;
  late List<dynamic> allEvents;
  late bool isLoading = true;

  @override
  void initState() {
    super.initState();
    homeRefreshNotifier.addListener(_handleTabChange);
    _fetchUserFollowedInfo();
  }

  void _handleTabChange() {
    setState(() {
      isLoading = true;
    });
    _fetchUserFollowedInfo();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _fetchUserFollowedInfo();
    routeObserver.subscribe(this, ModalRoute.of(context)!);
  }

  @override
  void dispose() {
    routeObserver.unsubscribe(this);
    userProfileRefreshNotifier.removeListener(_handleTabChange);
    super.dispose();
  }

  Future<void> _fetchUserFollowedInfo() async {
    try {
      followedLikedReleases =
          await userProfileService.getFollowedLikedReleases();
      followedLikedArtists = await userProfileService.getFollowedLikedArtists();
      followedReviews = await userProfileService.getFollowedReviews();
      mostPopularReviews = await reviewService.fetchMostPopularReviews();

      allEvents = [
        ...followedLikedReleases,
        ...followedLikedArtists,
        ...followedReviews,
        ...mostPopularReviews,
      ];

      allEvents.sort((a, b) {
        DateTime dateA =
            a is LikeRelease
                ? a.createdAt
                : a is LikeArtist
                ? a.createdAt
                : a.createdAt;
        DateTime dateB =
            b is LikeRelease
                ? b.createdAt
                : b is LikeArtist
                ? b.createdAt
                : b.createdAt;

        return dateB.compareTo(dateA);
      });

      setState(() {
        isLoading = false;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error fetching followed info: $e")),
        );
      }
    }
  }

  Future<void> fetchFollowedReviews() async {
    try {
      followedReviews = await userProfileService.getFollowedReviews();
      setState(() {
        isLoading = false;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error fetching followed reviews: $e")),
        );
      }
    }
  }

  Future<void> fetchFollowedLikedReleases() async {
    try {
      followedLikedReleases =
          await userProfileService.getFollowedLikedReleases();
      setState(() {
        isLoading = false;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error fetching followed liked releases: $e")),
        );
      }
    }
  }

  Future<void> fetchFollowedLikedArtists() async {
    try {
      followedLikedArtists = await userProfileService.getFollowedLikedArtists();
      setState(() {
        isLoading = false;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error fetching followed liked artists: $e")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body:
          isLoading
              ? const Center(child: CircularProgressIndicator())
              : Container(
                margin: const EdgeInsets.symmetric(vertical: 0, horizontal: 0),
                child: CustomScrollView(
                  slivers: [
                    SliverAppBar(
                      title: const Text("Actualité"),
                      backgroundColor: Colors.transparent.withAlpha(200),
                      floating: true,
                      snap: true,
                      pinned: false,
                    ),
                    // Liste des événements
                    SliverPadding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0), // Ajustez selon vos besoins
                      sliver: SliverList(
                        delegate: SliverChildBuilderDelegate((context, index) {
                          final event = allEvents[index];

                          if (event is LikeRelease) {
                            return LikeReleaseCard(likeRelease: event);
                          } else if (event is LikeArtist) {
                            return LikeArtistCard(likeArtist: event);
                          } else if (event is Review) {
                            return ReviewCard(
                              review: event,
                              displayReleaseCover: true,
                              onSeeProfile: (review) {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => ProfilePage(user: review.user),
                                  ),
                                );
                              },
                              onSeeRelease: (review) {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => ReleasePage(release: review.release),
                                  ),
                                );
                              },
                              onSeeArtist: (review) {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => ArtistPage(
                                      artist: review.release.artist,
                                    ),
                                  ),
                                );
                              },
                            );
                          }
                          return SizedBox.shrink();
                        }, childCount: allEvents.length),
                      ),
                    ),
                    // Espace en bas pour éviter que le contenu soit masqué par la navigation
                    SliverToBoxAdapter(child: SizedBox(height: 100)),
                  ],
                ),
              ),
    );
  }
}
