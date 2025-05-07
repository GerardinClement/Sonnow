import 'package:flutter/material.dart';

class LikeIconAnimated extends StatefulWidget {
  final bool isLiked;
  final Duration duration;

  const LikeIconAnimated({
    Key? key,
    required this.isLiked,
    this.duration = const Duration(milliseconds: 500),
  }) : super(key: key);

  @override
  State<LikeIconAnimated> createState() => _LikeIconAnimatedState();
}

class _LikeIconAnimatedState extends State<LikeIconAnimated>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    );
    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    );
    if (widget.isLiked) {
      _controller.value = 1.0;
    }
  }

  @override
  void didUpdateWidget(covariant LikeIconAnimated oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isLiked != oldWidget.isLiked) {
      if (widget.isLiked) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Icon(
          Icons.favorite_border,
          color: Colors.grey,
          size: 20,
        ),
        AnimatedBuilder(
          animation: _animation,
          builder: (context, child) {
            return ClipOval(
              clipper: _CircleClipper(_animation.value),
              child: child,
            );
          },
          child: Icon(
            Icons.favorite,
            color: Colors.yellow,
            size: 20,
          ),
        ),
      ],
    );
  }
}

class _CircleClipper extends CustomClipper<Rect> {
  final double progress;

  _CircleClipper(this.progress);

  @override
  Rect getClip(Size size) {
    final center = size.center(Offset.zero);
    final radius = size.shortestSide / 2 * progress;
    return Rect.fromCircle(center: center, radius: radius);
  }

  @override
  bool shouldReclip(_CircleClipper oldClipper) {
    return oldClipper.progress != progress;
  }
}
