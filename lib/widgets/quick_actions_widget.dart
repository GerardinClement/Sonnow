import 'package:flutter/material.dart';

class QuickActions extends StatefulWidget {
  final Function? onLike;
  final Function? onAddToListen;
  final Function? onAddHighlight;
  final Function? openReviewForm;
  final bool? isLiked;
  final bool? isToListen;
  final bool? isHighlighted;

  const QuickActions({
    super.key,
    required this.onLike,
    required this.onAddToListen,
    required this.onAddHighlight,
    required this.openReviewForm,
    required this.isLiked,
    required this.isToListen,
    required this.isHighlighted,
  });

  @override
  State<QuickActions> createState() => _QuickActionsState();
}

class _QuickActionsState extends State<QuickActions> {
  late bool? isLiked;
  late bool? isToListen;
  late bool? isHighlighted;

  @override
  void initState() {
    super.initState();
    isLiked = widget.isLiked;
    isToListen = widget.isToListen;
    isHighlighted = widget.isHighlighted;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        if (widget.openReviewForm != null)
        IconButton(
          icon: Icon(Icons.rate_review),
          onPressed: () {
            if (widget.openReviewForm != null) widget.openReviewForm!();
          },
        ),
        if (isLiked != null)
        IconButton(
          icon: Icon(isLiked! ? Icons.favorite : Icons.favorite_border),
          onPressed: () {
            setState(() {
              isLiked = !isLiked!;
            });
            if(widget.onLike != null) widget.onLike!();
          },
        ),
        if (isToListen != null)
        IconButton(
          icon: Icon(isToListen! ? Icons.playlist_add_check : Icons.playlist_add),
          onPressed: () {
            setState(() {
              isToListen = !isToListen!;
            });
            if(widget.onAddToListen != null) widget.onAddToListen!();
          },
        ),
        if (isHighlighted != null)
        IconButton(
          icon: Icon(isHighlighted! ? Icons.star : Icons.star_border),
          onPressed: () {
            setState(() {
              isHighlighted = !isHighlighted!;
            });
            if(widget.onAddHighlight != null) widget.onAddHighlight!();
          },
        ),
      ],
    );
  }
}