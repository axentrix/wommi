import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme.dart';

class WommiBottomNavigationBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const WommiBottomNavigationBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(
            color: WommiColors.line,
            width: 1,
          ),
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 14),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _NavItem(
                icon: '🗺️',
                label: 'Home',
                isActive: currentIndex == 0,
                onTap: () => onTap(0),
              ),
              _NavItem(
                icon: '⚡',
                label: 'Challenges',
                isActive: currentIndex == 1,
                onTap: () => onTap(1),
              ),
              _NavItem(
                icon: '💎',
                label: 'Achievements',
                isActive: currentIndex == 2,
                onTap: () => onTap(2),
              ),
              _NavItem(
                icon: '👤',
                label: 'Profile',
                isActive: currentIndex == 3,
                onTap: () => onTap(3),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final String icon;
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isActive)
              Container(
                width: 5,
                height: 5,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: WommiColors.cyanDark,
                ),
              )
            else
              Text(
                icon,
                style: TextStyle(fontSize: 18),
              ),
            const SizedBox(height: 4),
            Text(
              label.toUpperCase(),
              style: GoogleFonts.spaceMono(
                fontSize: 9.5,
                letterSpacing: 0.6,
                color: isActive ? WommiColors.cyanDark : WommiColors.inkDim,
                fontWeight: isActive ? FontWeight.w700 : FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
