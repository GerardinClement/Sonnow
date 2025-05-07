import 'dart:ui';
import 'package:flutter/material.dart';

class FrostedGlassCard extends StatelessWidget {
  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsets margin;
  final int opacity;
  final Color? baseColor;

  const FrostedGlassCard({
    super.key,
    required this.child,
    this.onTap,
    this.margin = const EdgeInsets.symmetric(vertical: 8.0),
    this.opacity = 35,
    this.baseColor,
  });

  @override
  Widget build(BuildContext context) {
    final color = baseColor ?? Color(0xFF4F4048);

    return Padding(
      padding: margin,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(15),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onTap,
              child: Container(
                decoration: BoxDecoration(
                  boxShadow: [
                      BoxShadow(
                        color: Colors.white.withOpacity(0.1),
                        blurRadius: 100,
                        spreadRadius: 5,
                        blurStyle: BlurStyle.normal
                      ),
                  ],
                  color: color.withAlpha(opacity),
                ),
                padding: const EdgeInsets.all(12.0),
                child: child,
              ),
            ),
          ),
        ),
      ),
    );
  }
}