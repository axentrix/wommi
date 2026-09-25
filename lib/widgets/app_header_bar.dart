import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme.dart';
import '../models/user_state.dart';

/// The mascot badge + "Day X" + gems/streak stats row shared by the Home
/// and Achievements screens (see the Figma homepage/achievements designs) -
/// [subtitle] is optional since only Home's header shows a cycle-phase line
/// under "Day X"; Achievements omits it.
class AppHeaderBar extends StatelessWidget {
  final UserState userState;
  final String? subtitle;
  final void Function(BuildContext badgeContext) onGemsTap;

  const AppHeaderBar({
    super.key,
    required this.userState,
    this.subtitle,
    required this.onGemsTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Image.asset(
                'assets/images/home/avatar_badge.png',
                width: 36,
                height: 45,
              ),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Day ${userState.currentDay}',
                    style: GoogleFonts.unbounded(
                      fontSize: 32,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                      height: 1,
                    ),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      subtitle!,
                      style: GoogleFonts.mulish(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: WommiColors.homeSubtitlePink,
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
          Row(
            children: [
              Builder(
                builder: (badgeContext) => GestureDetector(
                  onTap: () => onGemsTap(badgeContext),
                  child: StatColumn(
                    image: 'assets/images/home/gem_icon.png',
                    imageSize: 26,
                    value: userState.gemBalance,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              StatColumn(
                image: 'assets/images/home/flame_icon.png',
                imageSize: 29,
                value: userState.streakDays,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// One header stat (gems or streak): icon above a plain count, both
/// centered.
class StatColumn extends StatelessWidget {
  final String image;
  final double imageSize;
  final int value;

  const StatColumn({
    super.key,
    required this.image,
    required this.imageSize,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Image.asset(image, width: imageSize, height: imageSize),
        const SizedBox(height: 4),
        Text(
          '$value',
          style: GoogleFonts.unbounded(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
      ],
    );
  }
}
