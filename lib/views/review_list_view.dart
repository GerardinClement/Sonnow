import 'package:flutter/material.dart';
import 'package:sonnow/models/review.dart';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:sonnow/services/review_service.dart';
import 'package:sonnow/widgets/reaction_widget.dart';

class ReviewListView extends StatefulWidget {
  final List<Review> reviews;
  final bool onProfile;
  final bool displayReleaseCover;
  final Function(Review)? onSeeProfile;
  final Function(Review)? onSeeRelease;
  final Function(Review) onSeeArtist;

  static ReviewService reviewService = ReviewService();

  const ReviewListView({
    super.key,
    required this.reviews,
    required this.onProfile,
    required this.displayReleaseCover,
    required this.onSeeProfile,
    required this.onSeeRelease,
    required this.onSeeArtist,
  });

  @override
  State<ReviewListView> createState() => _ReviewListViewState();
}

class _ReviewListViewState extends State<ReviewListView> {
  void _showEmojiPicker(BuildContext context, Review review) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          height: 300,
          child: Column(
            children: [
              Container(
                padding: EdgeInsets.symmetric(vertical: 8),
                child: Text(
                  'Choisissez une réaction',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              Divider(),
              Expanded(
                child: EmojiPicker(
                  onEmojiSelected: (category, emoji) async {
                    Navigator.pop(context);
                    try {
                      ReviewReaction? res = await ReviewListView.reviewService
                          .reactToReview(review, emoji.emoji);
                      if (res != null) {
                        setState(() {
                          review.reactions.add(res);
                        });
                      }
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Error adding reaction: $e')),
                      );
                    }
                  },
                  config: Config(
                    height: 256,
                    checkPlatformCompatibility: true,
                    emojiViewConfig: EmojiViewConfig(emojiSizeMax: 28 * 1.0),
                    viewOrderConfig: const ViewOrderConfig(
                      top: EmojiPickerItem.categoryBar,
                      middle: EmojiPickerItem.emojiView,
                      bottom: EmojiPickerItem.searchBar,
                    ),
                    skinToneConfig: const SkinToneConfig(),
                    categoryViewConfig: const CategoryViewConfig(),
                    bottomActionBarConfig: const BottomActionBarConfig(),
                    searchViewConfig: const SearchViewConfig(),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void showReviewOptions(BuildContext context, Review review) {
    showModalBottomSheet(
      useRootNavigator: true,
      useSafeArea: true,
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              ListTile(
                leading: Icon(Icons.add_reaction),
                title: Text('Add reaction'),
                onTap: () {
                  Navigator.pop(context);
                  _showEmojiPicker(context, review);
                },
              ),
              if (!widget.onProfile)
                ListTile(
                  leading: Icon(Icons.person),
                  title: Text('See profile'),
                  onTap: () async {
                    Navigator.pop(context);
                    widget.onSeeProfile!(review);
                  },
                ),
              if (widget.onProfile)
                ListTile(
                  leading: Icon(Icons.album),
                  title: Text('See release'),
                  onTap: () async {
                    Navigator.pop(context);
                    widget.onSeeRelease!(review);
                  },
                ),
              ListTile(
                leading: Icon(Icons.music_note),
                title: Text('See artist'),
                onTap: () async {
                  Navigator.pop(context);
                  widget.onSeeArtist(review);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ListView.builder(
          cacheExtent: 500,
          shrinkWrap: true,
          padding: EdgeInsets.zero,
          physics: NeverScrollableScrollPhysics(),
          itemCount: widget.reviews.length,
          itemBuilder: (context, index) {
            return Card(
              margin: const EdgeInsets.symmetric(
                vertical: 8.0,
                horizontal: 12.0,
              ),
              child: InkWell(
                onTap: () {
                  showReviewOptions(context, widget.reviews[index]);
                },
                child: Column(
                  children: [
                    if (widget.displayReleaseCover)
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12.0),
                        child: Row(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.network(
                                widget.reviews[index].release.imageUrl,
                                width: 50,
                                height: 50,
                                fit: BoxFit.cover,
                              ),
                            ),
                            const SizedBox(width: 12.0),
                            Expanded(
                              child: ListTile(
                                title: Text(
                                  widget.reviews[index].release.title,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                subtitle: Text(
                                  widget.reviews[index].release.artist.name,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(25),
                            child:
                                widget.reviews[index].user.profilePictureUrl !=
                                        null
                                    ? Image.network(
                                      widget
                                          .reviews[index]
                                          .user
                                          .profilePictureUrl!,
                                      width: 50,
                                      height: 50,
                                      fit: BoxFit.cover,
                                      errorBuilder: (
                                        context,
                                        error,
                                        stackTrace,
                                      ) {
                                        return const SizedBox(
                                          width: 50,
                                          height: 50,
                                        );
                                      },
                                    )
                                    : CircleAvatar(
                                      radius: 25,
                                      backgroundColor: Colors.grey[300],
                                      child: Icon(
                                        Icons.person,
                                        size: 30,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                          ),
                          const SizedBox(width: 12.0),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  widget.reviews[index].user.displayName,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 5.0),
                                Wrap(
                                  spacing: 5,
                                  runSpacing: 5,
                                  children:
                                      widget.reviews[index].tags.map((tag) {
                                        return Chip(
                                          label: Text(
                                            tag,
                                            style: const TextStyle(
                                              fontSize: 12,
                                            ),
                                          ),
                                          padding: EdgeInsets.zero,
                                          materialTapTargetSize:
                                              MaterialTapTargetSize.shrinkWrap,
                                        );
                                      }).toList(),
                                ),
                                const SizedBox(height: 5.0),
                                Text(widget.reviews[index].content),
                                const SizedBox(height: 5.0),
                                if (widget.reviews[index].reactions.isNotEmpty)
                                  Wrap(
                                    spacing: 6.0,
                                    children: [
                                      ReactionWidget(
                                        review: widget.reviews[index],
                                        reactions:
                                            widget.reviews[index].reactions,
                                      ),
                                    ],
                                  ),
                                const SizedBox(height: 5.0),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}
