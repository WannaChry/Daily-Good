import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class NavBar extends StatelessWidget {
  const NavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  final int currentIndex;
  final ValueChanged<int> onTap;

  // Zielgrößen je Icon
  double _sizeFor(int i) {
    if (i == 0) return 30; // Haus
    if (i == 1) return 36; // Buch
    if (i == 2) return 42; // Community
    if (i == 3) return 30; // User
    return 34;
  }

  @override
  Widget build(BuildContext context) {
    final icons = <String>[
      'assets/icons/home-1-svgrepo-com.svg',
      'assets/icons/book-open-svgrepo-com.svg',
      'assets/icons/group-svgrepo-com.svg',
      'assets/icons/profile-round-1342-svgrepo-com.svg',
    ];

    BottomNavigationBarItem buildItem(String path, int i) {
      Widget buildIcon(bool isActive) {
        final base = _sizeFor(i);
        final size = isActive ? base + 2 : base;

        return Padding(
          padding: const EdgeInsets.only(top: 6),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            curve: Curves.easeOut,
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: isActive ? Colors.black.withOpacity(0.06) : Colors.transparent,
              borderRadius: BorderRadius.circular(999),
            ),
            child: AnimatedScale(
              scale: isActive ? 1.12 : 1.0,           // kleiner „Pop“
              duration: const Duration(milliseconds: 160),
              curve: Curves.easeOut,
              child: AnimatedOpacity(
                opacity: isActive ? 1.0 : 0.9,
                duration: const Duration(milliseconds: 160),
                child: SvgPicture.asset(
                  path,
                  width: size,
                  height: size,
                  fit: BoxFit.contain,
                  colorFilter: const ColorFilter.mode(Colors.black, BlendMode.srcIn),
                ),
              ),
            ),
          ),
        );
      }

      return BottomNavigationBarItem(
        icon: buildIcon(false),
        activeIcon: buildIcon(true),
        label: '',
      );
    }

    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      backgroundColor: Colors.white,
      currentIndex: currentIndex,
      showSelectedLabels: false,
      showUnselectedLabels: false,
      onTap: onTap,
      items: List.generate(icons.length, (i) => buildItem(icons[i], i)),
    );
  }
}
