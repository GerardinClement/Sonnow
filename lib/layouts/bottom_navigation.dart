import 'package:flutter/material.dart';
import 'package:sonnow/models/tab_item.dart';

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
    return Positioned(
      left: 0,
      right: 0,
      bottom: 15,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 6),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          backgroundBlendMode: BlendMode.darken,
          color: Color(0xFF042A2B).withValues(alpha: 0.5),
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
    );
  }
}
