import 'package:flutter/material.dart';
import 'package:sonnow/models/review.dart';
import 'package:sonnow/services/review_service.dart';
import 'package:sonnow/views/review_card_view.dart';

class ReviewListView extends StatefulWidget {
  final List<Review> reviews;
  final bool displayReleaseCover;
  final Function(Review)? onSeeProfile;
  final Function(Review)? onSeeRelease;
  final Function(Review)? onSeeArtist;

  static ReviewService reviewService = ReviewService();

  const ReviewListView({
    super.key,
    required this.reviews,
    required this.displayReleaseCover,
    required this.onSeeProfile,
    required this.onSeeRelease,
    required this.onSeeArtist,
  });

  @override
  State<ReviewListView> createState() => _ReviewListViewState();
}

class _ReviewListViewState extends State<ReviewListView> {

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
            Review review = widget.reviews[index];
            return ReviewCard(
              review: review,
              displayReleaseCover: widget.displayReleaseCover,
              onSeeProfile: widget.onSeeProfile,
              onSeeRelease: widget.onSeeRelease,
              onSeeArtist: widget.onSeeArtist,
            );
          },
        ),
      ],
    );
  }
}
