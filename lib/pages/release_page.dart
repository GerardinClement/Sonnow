import 'package:flutter/material.dart';
import 'package:sonnow/models/release.dart';
import 'package:sonnow/models/artist.dart';
import 'package:sonnow/models/review.dart';
import 'package:sonnow/models/track.dart';
import 'package:sonnow/services/deezer_api.dart';
import 'package:sonnow/services/review_service.dart';
import 'package:sonnow/services/user_library_service.dart';
import 'package:sonnow/services/user_library_storage.dart';
import 'package:sonnow/services/user_profile_service.dart';
import 'package:sonnow/services/sonnow_service.dart';
import 'package:sonnow/pages/artist_page.dart';
import 'package:sonnow/pages/profile_page.dart';
import 'package:sonnow/views/review_list_view.dart';
import 'package:sonnow/views/contributors_list_view.dart';
import 'package:sonnow/widgets/custom_fab_location.dart';
import 'package:sonnow/widgets/quick_actions_widget.dart';
import 'package:sonnow/widgets/like_animation_widget.dart';

class ReleasePage extends StatefulWidget {
  final Release release;

  const ReleasePage({super.key, required this.release});

  @override
  State<ReleasePage> createState() => _ReleasePageState();
}

class _ReleasePageState extends State<ReleasePage> {
  final ReviewService reviewService = ReviewService();
  final UserLibraryService userLibraryService = UserLibraryService();
  final UserProfileService userProfileService = UserProfileService();

  List<Review> reviews = [];
  Map<int, String> tags = {};
  Map<int, String> selectedTags = {};
  late Release release;
  late bool isLoading = true;
  bool _isQuickActionVisible = false;

  @override
  void initState() {
    super.initState();
    release = widget.release;
    _fetchRelease(release.id);
    _fetchTags();
    _fetchReviews(release.id);
  }

  Future<void> _fetchTags() async {
    try {
      Map<int, String> result = await reviewService.getAllTags();
      setState(() {
        tags = result;
      });
    } catch (e) {
      print(e);
    }
  }

  Future<void> _fetchRelease(String releaseId) async {
    try {
      Future.wait([
        DeezerApi.getAlbum(releaseId),
        DeezerApi.getAlbumTracks(releaseId),
        getIfReleaseIsHighlighted(releaseId),
        getIfReleaseIsLiked(releaseId),
        getIfReleaseIsToListen(releaseId),
        SonnowService.getReleaseNumberOfLikes(releaseId),
      ]).then((List<dynamic> results) async {
        Release res = results[0];
        res.setTracklist(results[1]);
        res.isHighlighted = results[2];
        res.isLiked = results[3];
        res.toListen = results[4];
        res.nb_likes = results[5];

        setState(() {
          release = res;
          isLoading = false;
        });
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
        release.nb_likes -= 1;
      } else {
        await userLibraryService.likeRelease(release);
        addLikedReleasesInBox([release]);
        setState(() {
          release.nb_likes += 1;
        });
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

  Future<void> toggleHighlight() async {
    try {
      await userProfileService.setHighlightedRelease(release);
      setState(() {
        release.isHighlighted = !release.isHighlighted;
      });
    } catch (e) {
      print(e);
    }
  }

  Future<void> _showTagsSelectionModal(
    BuildContext context,
    Map<int, String> tags,
    Function(Map<int, String>) onTagsUpdated,
  ) async {
    Map<int, String> tempSelectedTags = Map.from(selectedTags);

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
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
                  const Text(
                    "Select Tags",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  Expanded(
                    child: ListView.builder(
                      itemCount: tags.length,
                      itemBuilder: (context, index) {
                        final tagId = tags.keys.elementAt(index);
                        final tagName = tags[tagId]!;
                        final isSelected = tempSelectedTags.containsKey(tagId);

                        return CheckboxListTile(
                          title: Text(tagName),
                          value: isSelected,
                          onChanged: (bool? value) {
                            setModalState(() {
                              if (value == true) {
                                tempSelectedTags[tagId] = tagName;
                              } else {
                                tempSelectedTags.remove(tagId);
                              }
                            });
                          },
                        );
                      },
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        selectedTags = Map.from(tempSelectedTags);
                      });
                      onTagsUpdated(tempSelectedTags);
                      Navigator.pop(context);
                    },
                    child: const Text("Valider"),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void postReview(
    BuildContext context,
    String content,
    Map<int, String> tags,
  ) async {
    await reviewService.postReview(release, content, tags);
    if (context.mounted) Navigator.pop(context);
    _fetchReviews(release.id);
    setState(() {
      selectedTags = {};
    });
  }

  void displayScaffoldMessenger(BuildContext context, String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  void _showReviewForm() {
    Map<int, String> reviewTags = Map.from(selectedTags);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useRootNavigator: true,
      useSafeArea: true,
      builder: (BuildContext context) {
        String content = "";

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
                  Text("Add Tags"),
                  Wrap(
                    spacing: 8.0,
                    children:
                        reviewTags.entries.map((entry) {
                          return Chip(
                            label: Text(entry.value),
                            onDeleted: () {
                              setModalState(() {
                                reviewTags.remove(entry.key);
                              });
                            },
                          );
                        }).toList(),
                  ),
                  IconButton(
                    onPressed: () async {
                      await _showTagsSelectionModal(context, tags, (
                        updatedTags,
                      ) {
                        setModalState(() {
                          reviewTags = Map.from(updatedTags);
                        });
                      });
                    },
                    icon: const Icon(Icons.add_circle_outline_outlined),
                  ),
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () async {
                      try {
                        postReview(context, content, reviewTags);
                      } catch (e) {
                        if (context.mounted) {
                          displayScaffoldMessenger(
                            context,
                            "Error posting review",
                          );
                        }
                      }
                    },
                    child: Text("Save"),
                  ),
                ],
              ),
            );
          },
        );
      },
    ).then((_) {
      setState(() {
        selectedTags = {};
      });
    });
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
            ListView.builder(
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
    return isLoading
        ? const Center(child: CircularProgressIndicator())
        : DefaultTabController(
          length: 2,
          child: Scaffold(
            extendBodyBehindAppBar: true,
            appBar: PreferredSize(
              preferredSize: Size.fromHeight(kToolbarHeight),
              child: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Color.fromRGBO(171, 171, 171, 0.3),
                      Color.fromRGBO(171, 171, 171, 0.3),
                      Color.fromRGBO(171, 171, 171, 0.2),
                      Color.fromRGBO(171, 171, 171, 0.1),
                      Color.fromRGBO(171, 171, 171, 0.0),
                    ],
                  ),
                ),
                child: AppBar(
                  backgroundColor: Colors.transparent,
                  elevation: 0,
                  leading: IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
              ),
            ),
            body: Stack(
              children: [
                SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Image de couverture
                      Image.network(
                        release.imageUrl,
                        width: MediaQuery.of(context).size.width,
                        height: MediaQuery.of(context).size.width,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return SizedBox(
                            width: MediaQuery.of(context).size.width,
                            height: MediaQuery.of(context).size.width,
                          );
                        },
                      ),
                      const SizedBox(height: 20),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    release.title,
                                    style: const TextStyle(
                                      fontSize: 32,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  release.contributors.isNotEmpty
                                      ? ContributorsList(
                                        contributors: release.contributors,
                                      )
                                      : ContributorsList(
                                        contributors: [release.artist],
                                      ),
                                  Text(
                                    release.date,
                                    style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w300,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                ],
                              ),
                            ),
                            const SizedBox(width: 16),
                            ClipRect(
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                child: GestureDetector(
                                  onTap: () {
                                    toggleLike();
                                  },
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      LikeIconAnimated(isLiked: release.isLiked),
                                      const SizedBox(width: 4),
                                      ClipRect(
                                        child: AnimatedSwitcher(
                                          duration: const Duration(
                                            milliseconds: 300,
                                          ),
                                          transitionBuilder: (
                                            Widget child,
                                            Animation<double> animation,
                                          ) {
                                            final inAnimation = Tween<Offset>(
                                              begin: const Offset(0, 1),
                                              end: Offset.zero,
                                            ).animate(animation);
                                            final outAnimation = Tween<Offset>(
                                              begin: const Offset(0, -1),
                                              end: Offset.zero,
                                            ).animate(animation);

                                            if (child.key ==
                                                ValueKey(release.nb_likes)) {
                                              // Entrant
                                              return SlideTransition(
                                                position: inAnimation,
                                                child: child,
                                              );
                                            } else {
                                              // Sortant
                                              return SlideTransition(
                                                position: outAnimation,
                                                child: child,
                                              );
                                            }
                                          },
                                          child: Text(
                                            release.nb_likes.toString(),
                                            key: ValueKey(release.nb_likes),
                                            style: const TextStyle(height: 1),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      TabBar(
                        tabs: const [Tab(text: "Tracklist"), Tab(text: "Avis")],
                        onTap: (index) => setState(() {}),
                      ),
                      Builder(
                        builder: (context) {
                          final tabController = DefaultTabController.of(
                            context,
                          );
                          if (tabController.index == 0) {
                            // Onglet Tracklist
                            return Padding(
                              padding: EdgeInsets.only(bottom: 100),
                              child: ListView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                padding: EdgeInsets.zero,
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
                                      title: Text(
                                        release.tracklist[index].title,
                                      ),
                                      subtitle: Text(
                                        getArtistNames(
                                          release.tracklist[index].artist,
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            );
                          } else {
                            // Onglet Avis
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                reviews.isEmpty
                                    ? Center(
                                      child: Padding(
                                        padding: const EdgeInsets.all(16),
                                        child: Column(
                                          children: [
                                            const Text("No reviews yet"),
                                            const Text(
                                              "Be the first to review!",
                                            ),
                                            ElevatedButton(
                                              onPressed:
                                                  () => _showReviewForm(),
                                              child: const Text("Add a review"),
                                            ),
                                          ],
                                        ),
                                      ),
                                    )
                                    : Padding(
                                      padding: const EdgeInsets.only(
                                        bottom: 100,
                                      ),
                                      child: ReviewListView(
                                        reviews: reviews,
                                        displayReleaseCover: false,
                                        onSeeProfile: (review) {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder:
                                                  (context) => ProfilePage(
                                                    user: review.user,
                                                  ),
                                            ),
                                          );
                                        },
                                        onSeeRelease: null,
                                        onSeeArtist: (review) {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder:
                                                  (context) => ArtistPage(
                                                    artist:
                                                        review.release.artist,
                                                  ),
                                            ),
                                          );
                                        },
                                      ),
                                    ),
                              ],
                            );
                          }
                        },
                      ),
                    ],
                  ),
                ),

                if (_isQuickActionVisible)
                  Positioned(
                    right: 30,
                    bottom: 160,
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Theme.of(context).cardColor,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(color: Colors.black26, blurRadius: 10),
                        ],
                      ),
                      child: QuickActions(
                        onLike: toggleLike,
                        onAddToListen: toggleToListen,
                        onAddHighlight: toggleHighlight,
                        openReviewForm: _showReviewForm,
                        isLiked: release.isLiked,
                        isToListen: release.toListen,
                        isHighlighted: release.isHighlighted,
                      ),
                    ),
                  ),
              ],
            ),
            floatingActionButton: FloatingActionButton(
              onPressed: () {
                setState(() {
                  _isQuickActionVisible = !_isQuickActionVisible;
                });
              },
              child: Icon(_isQuickActionVisible ? Icons.close : Icons.add),
            ),
            floatingActionButtonLocation: CustomFabLocation(),
          ),
        );
  }
}
