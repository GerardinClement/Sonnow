import 'package:flutter/material.dart';
import 'package:sonnow/models/tab_item.dart';

class BottomNavigation extends StatelessWidget {
  final ValueChanged<int> onSelectTab;
  final List<TabItem> tabs;

  const BottomNavigation({super.key, required this.onSelectTab, required this.tabs});

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      items:
          tabs.map(
              (e) => _buildItem(
                index: e.getIndex(),
                icon: e.icon,
                tabName: e.tabName,
              ),
            ).toList(),
      onTap: (index) => onSelectTab(index),
    );
  }

  BottomNavigationBarItem _buildItem({required IconData icon, required String tabName, required int index}) {
    return BottomNavigationBarItem(
      icon: Icon(icon, color: Colors.blue),
      label: tabName,
    );
  }
}
