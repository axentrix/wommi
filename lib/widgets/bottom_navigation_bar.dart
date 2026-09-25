import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';

/// A floating, semi-transparent pill (see the Figma homepage design) with a
/// soft white highlight that slides and resizes to sit snugly behind
/// whichever item is currently active - each item's own rendered size
/// differs (e.g. "Achievements" is wider than "Map"), so the highlight is
/// driven by actually measuring the active item's box each time, rather
/// than a fixed width.
class WommiBottomNavigationBar extends StatefulWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const WommiBottomNavigationBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  State<WommiBottomNavigationBar> createState() =>
      _WommiBottomNavigationBarState();
}

class _NavItemData {
  final String icon;
  final String label;
  const _NavItemData(this.icon, this.label);
}

class _WommiBottomNavigationBarState extends State<WommiBottomNavigationBar> {
  static const _items = [
    _NavItemData('assets/images/home/nav_map.svg', 'Map'),
    _NavItemData('assets/images/home/nav_rituals.svg', 'Daily Rituals'),
    _NavItemData('assets/images/home/nav_achievements.svg', 'Achievements'),
    _NavItemData('assets/images/home/nav_settings.svg', 'Settings'),
  ];

  final _stackKey = GlobalKey();
  final _itemKeys = List.generate(_items.length, (_) => GlobalKey());
  Rect? _indicatorRect;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _measure());
  }

  @override
  void didUpdateWidget(covariant WommiBottomNavigationBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    WidgetsBinding.instance.addPostFrameCallback((_) => _measure());
  }

  /// Finds the active item's box relative to the Stack and updates
  /// [_indicatorRect] if it moved/resized - re-run after every build (post
  /// frame) so a tab switch, a label wrapping differently, or the bar's own
  /// width changing (e.g. window resize) all keep the highlight in sync,
  /// not just an explicit index change.
  void _measure() {
    if (!mounted) return;
    final stackBox =
        _stackKey.currentContext?.findRenderObject() as RenderBox?;
    final itemBox = _itemKeys[widget.currentIndex].currentContext
        ?.findRenderObject() as RenderBox?;
    if (stackBox == null ||
        itemBox == null ||
        !stackBox.attached ||
        !itemBox.attached) {
      return;
    }

    final topLeft = itemBox.localToGlobal(Offset.zero, ancestor: stackBox);
    final rect = topLeft & itemBox.size;
    if (rect != _indicatorRect) {
      setState(() => _indicatorRect = rect);
    }
  }

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) => _measure());

    return SafeArea(
      top: false,
      child: Container(
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.44),
          borderRadius: BorderRadius.circular(888),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF1F0A12).withValues(alpha: 0.06),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Stack(
          key: _stackKey,
          alignment: Alignment.center,
          children: [
            if (_indicatorRect != null)
              AnimatedPositioned(
                duration: const Duration(milliseconds: 280),
                curve: Curves.easeOutCubic,
                left: _indicatorRect!.left,
                top: _indicatorRect!.top,
                width: _indicatorRect!.width,
                height: _indicatorRect!.height,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.20),
                    borderRadius: BorderRadius.circular(13),
                  ),
                ),
              ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: List.generate(_items.length, (index) {
                final item = _items[index];
                return _NavItem(
                  key: _itemKeys[index],
                  icon: item.icon,
                  label: item.label,
                  isActive: widget.currentIndex == index,
                  onTap: () => widget.onTap(index),
                );
              }),
            ),
          ],
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
    super.key,
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
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 34,
              height: 34,
              child: SvgPicture.asset(icon, fit: BoxFit.contain),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: GoogleFonts.mulish(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
