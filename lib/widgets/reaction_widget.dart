import 'package:flutter/material.dart';
import 'package:sonnow/models/review.dart';
import 'package:sonnow/services/review_service.dart';
import 'package:sonnow/themes/app_colors.dart';
import 'package:sonnow/utils.dart';
import 'package:sonnow/pages/profile_page.dart';

class ReactionWidget extends StatefulWidget {
  final List<ReviewReaction> reactions;
  final Review review;

  const ReactionWidget({
    super.key,
    required this.reactions,
    required this.review,
  });

  @override
  State<ReactionWidget> createState() => _ReactionWidgetState();
}

class _ReactionWidgetState extends State<ReactionWidget> {
  final ReviewService reviewService = ReviewService();
  late String? userId;
  late bool isLoading = true;

  @override
  void initState() {
    super.initState();
    getUserId();
  }

  Future<void> getUserId() async {
    userId = await getCurrentUserId();
    if (mounted) {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> toggleReaction(String emoji) async {
    try {
      List<ReviewReaction> emojiReactions =
          widget.reactions
              .where((reaction) => reaction.emoji == emoji)
              .toList();

      ReviewReaction? userReaction;
      if (userId != null &&
          emojiReactions.any((reaction) => reaction.user.id == userId)) {
        userReaction = emojiReactions.firstWhere(
          (reaction) => reaction.user.id == userId,
        );
      }

      if (userReaction != null) {
        await reviewService.deleteReactToReview(widget.review, userReaction);
        widget.reactions.remove(userReaction);
        setState(() {});
      } else {
        ReviewReaction? res = await reviewService.reactToReview(
          widget.review,
          emoji,
        );
        widget.reactions.add(res!);
        setState(() {});
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Error toggling reaction: $e")));
      }
    }
  }

  Future<void> showReactionsUser(String emoji) async {
    List<ReviewReaction> emojiReactions =
        widget.reactions.where((reaction) => reaction.emoji == emoji).toList();

    if (emojiReactions.isNotEmpty) {
      showModalBottomSheet(
        context: context,
        builder: (context) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(padding: const EdgeInsets.all(16.0), child: Text(emoji)),
              Expanded(
                child: ListView.builder(
                  itemCount: emojiReactions.length,
                  itemBuilder: (context, index) {
                    return InkWell(
                      onTap: () {
                        Navigator.of(context).pushReplacement(
                          MaterialPageRoute(
                            builder:
                                (context) => ProfilePage(
                                  user: emojiReactions[index].user,
                                ),
                          ),
                        );
                      },
                      child: ListTile(
                        leading:
                            emojiReactions[index].user.profilePictureUrl != null
                                ? CircleAvatar(
                                  backgroundImage: NetworkImage(
                                    emojiReactions[index]
                                        .user
                                        .profilePictureUrl!,
                                  ),
                                )
                                : const CircleAvatar(child: Icon(Icons.person)),
                        title: Text(emojiReactions[index].user.displayName),
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      );
    }
  }

  bool currentUserReacted(String emoji) {
    return widget.reactions.any(
      (reaction) => reaction.emoji == emoji && reaction.user.id == userId,
    );
  }

  @override
  Widget build(BuildContext context) {
    Map<String, int> emojiCount = {};
    for (var reaction in widget.reactions) {
      emojiCount[reaction.emoji] = (emojiCount[reaction.emoji] ?? 0) + 1;
    }

    return isLoading
        ? const Center(child: CircularProgressIndicator())
        : Wrap(
          spacing: 6.0,
          runSpacing: 6.0,
          children:
              emojiCount.entries.map((entry) {
                return Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(12.0),
                    onTap: () => toggleReaction(entry.key),
                    onLongPress: () => showReactionsUser(entry.key),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8.0,
                        vertical: 4.0,
                      ),
                      decoration: BoxDecoration(
                        color: currentUserReacted(entry.key)
                            ? AppColors.secondary.withAlpha(100)
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(12.0),
                        border: Border.all(
                          color: Theme.of(
                            context,
                          ).dividerColor.withOpacity(0.3),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            entry.key,
                            style: const TextStyle(
                                fontSize: 14.0
                            ),
                          ),
                          const SizedBox(width: 4.0),
                          Text(
                            entry.value.toString(),
                            style: TextStyle(
                              fontSize: 12.0,
                              fontWeight: FontWeight.bold,
                              color: currentUserReacted(entry.key)
                                  ? Colors.white
                                  : AppColors.secondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }).toList(),
        );
  }
}
