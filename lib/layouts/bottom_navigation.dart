import 'package:flutter/material.dart';
import 'package:sonnow/models/tab_item.dart';
import 'dart:ui';

class BottomNavigation extends StatelessWidget {
  final ValueChanged<int> onSelectTab;
  final List<TabItem> tabs;
  final int currentIndex;

  const BottomNavigation({
    super.key,
    required this.onSelectTab,
    required this.tabs,
    required this.currentIndex,
  });

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double navBarWidth = screenWidth * 0.9;

    return Positioned(
      bottom: 15,
      left: (screenWidth - navBarWidth) / 2,
      width: navBarWidth,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(40),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 6),
            decoration: BoxDecoration(
              backgroundBlendMode: BlendMode.darken,
              color: const Color(0xFF042A2B).withAlpha(150),
              borderRadius: BorderRadius.circular(40),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: tabs.map((tab) {
                final int index = tab.index;
                final bool isSelected = index == currentIndex;

                return GestureDetector(
                  onTap: () => onSelectTab(index),
                  child: Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: isSelected ? const Color(0xFFF4E04D) : Colors.transparent,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      tab.icon,
                      color: isSelected ? Colors.black : Colors.white,
                      size: 28,
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ),
      ),
    );
  }
}
