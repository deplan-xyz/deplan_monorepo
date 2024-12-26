import 'package:flutter/material.dart';

class BottomNavBarItem {
  final String iconPath;
  final String activeIconPath;
  final double iconWidth;
  final double iconHeight;
  final String label;

  const BottomNavBarItem({
    required this.iconPath,
    required this.activeIconPath,
    required this.iconWidth,
    required this.iconHeight,
    required this.label,
  });
}

class BottomNavBar extends StatelessWidget {
  final double height;
  final int selectedIndex;
  final Function(int) onTabTapped;
  final List<BottomNavBarItem> items;

  const BottomNavBar({
    super.key,
    required this.height,
    required this.selectedIndex,
    required this.onTabTapped,
    required this.items,
  });

  BottomNavigationBarItem buildBottomNavigationBarItem(
    BottomNavBarItem item,
  ) {
    Widget wrapIcon(Widget icon) {
      return SizedBox(
        width: 30,
        height: 30,
        child: Center(child: icon),
      );
    }

    return BottomNavigationBarItem(
      icon: wrapIcon(
        Image.asset(
          item.iconPath,
          width: item.iconWidth,
          height: item.iconHeight,
        ),
      ),
      activeIcon: wrapIcon(
        Image.asset(
          item.activeIconPath,
          width: item.iconWidth,
          height: item.iconHeight,
        ),
      ),
      label: item.label,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      decoration: BoxDecoration(
        color: Colors.red,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 30,
            offset: const Offset(0, -10),
          ),
        ],
      ),
      child: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        items: items.map(buildBottomNavigationBarItem).toList(),
        currentIndex: selectedIndex,
        onTap: onTabTapped,
      ),
    );
  }
}
