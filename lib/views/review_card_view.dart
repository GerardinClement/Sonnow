import 'package:flutter/material.dart';
import 'package:sonnow/models/review.dart';
import 'package:sonnow/services/review_service.dart';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:sonnow/widgets/reaction_widget.dart';
import 'package:sonnow/themes/app_colors.dart';
import 'package:intl/intl.dart';
import 'package:sonnow/widgets/frosted_glass_card.dart';

class ReviewCard extends StatefulWidget {
  final Review review;
  final bool displayReleaseCover;
  final Function(Review)? onSeeProfile;
  final Function(Review)? onSeeRelease;
  final Function(Review)? onSeeArtist;

  static ReviewService reviewService = ReviewService();

  const ReviewCard({
    super.key,
    required this.review,
    required this.displayReleaseCover,
    required this.onSeeProfile,
    required this.onSeeRelease,
    required this.onSeeArtist,
  });

  @override
  State<ReviewCard> createState() => _ReviewCardState();
}

class _ReviewCardState extends State<ReviewCard> {
  late final Review review;
  late bool isLoading = true;

  @override
  void initState() {
    super.initState();
    review = widget.review;
  }

  void _showEmojiPicker(BuildContext context, Review review) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
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
                      ReviewReaction? res = await ReviewCard.reviewService
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
              if (widget.onSeeProfile != null)
                ListTile(
                  leading: Icon(Icons.person),
                  title: Text('See profile'),
                  onTap: () async {
                    Navigator.pop(context);
                    widget.onSeeProfile!(review);
                  },
                ),
              if (widget.onSeeRelease != null)
                ListTile(
                  leading: Icon(Icons.album),
                  title: Text('See release'),
                  onTap: () async {
                    Navigator.pop(context);
                    widget.onSeeRelease!(review);
                  },
                ),
              if (widget.onSeeArtist != null)
                ListTile(
                  leading: Icon(Icons.music_note),
                  title: Text('See artist'),
                  onTap: () async {
                    Navigator.pop(context);
                    widget.onSeeArtist!(review);
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
    return FrostedGlassCard(
      margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 0),
      onTap: () {
        showReviewOptions(context, widget.review);
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
                      widget.review.release.imageUrl,
                      width: 50,
                      height: 50,
                      fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(width: 12.0),
                  Expanded(
                    child: ListTile(
                      title: Text(
                        widget.review.release.title,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      subtitle: Text(
                        widget.review.release.artist.name,
                        style: const TextStyle(
                          fontWeight: FontWeight.w400,
                          color: Colors.white70,
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
                      widget.review.user.profilePictureUrl != null
                          ? Image.network(
                            widget.review.user.profilePictureUrl!,
                            width: 50,
                            height: 50,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return const SizedBox(width: 50, height: 50);
                            },
                          )
                          : CircleAvatar(
                            radius: 25,
                            backgroundColor: Colors.grey[300],
                            child: const Icon(
                              Icons.person,
                              size: 30,
                              color: Colors.white,
                            ),
                          ),
                ),
                const SizedBox(width: 12.0),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.review.user.displayName,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 5.0),
                      Wrap(
                        children:
                            widget.review.tags.map((tag) {
                              return Chip(
                                backgroundColor: AppColors.secondary,
                                label: Text(
                                  tag,
                                  style: const TextStyle(
                                    fontSize: 10,
                                    color: AppColors.text,
                                  ),
                                ),
                                padding: EdgeInsets.zero,
                                materialTapTargetSize:
                                    MaterialTapTargetSize.shrinkWrap,
                              );
                            }).toList(),
                      ),
                      const SizedBox(height: 5.0),
                      Text(
                        widget.review.content,
                        style: const TextStyle(color: Colors.white),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Row(
            children: [
              if (widget.review.reactions.isNotEmpty)
                Wrap(
                  spacing: 6.0,
                  children: [
                    ReactionWidget(
                      review: widget.review,
                      reactions: widget.review.reactions,
                    ),
                  ],
                ),
              const Spacer(),
              Padding(
                padding: const EdgeInsets.only(right: 12.0, bottom: 8.0),
                child: Text(
                  DateFormat(
                    'dd/MM/yyyy HH:mm',
                  ).format(review.createdAt.toLocal()),
                  style: const TextStyle(fontSize: 12, color: Colors.white54),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
