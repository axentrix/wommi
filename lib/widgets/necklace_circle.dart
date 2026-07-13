import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme.dart';

/// A circular "necklace" of gem icons arranged around the rim, with the
/// total count shown in the middle. The first gem is placed at the bottom
/// center, with the rest following around the rim from there.
class NecklaceCircle extends StatelessWidget {
  final double diameter;
  final int gemsCollected;
  final Color borderColor;
  final double borderWidth;
  final Color? color;
  final Gradient? gradient;
  final double countFontSize;
  final double labelFontSize;

  const NecklaceCircle({
    super.key,
    required this.diameter,
    required this.gemsCollected,
    required this.borderColor,
    this.borderWidth = 2.5,
    this.color,
    this.gradient,
    this.countFontSize = 22,
    this.labelFontSize = 7,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: diameter,
      height: diameter,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: borderColor, width: borderWidth),
        color: gradient == null ? (color ?? Colors.white) : null,
        gradient: gradient,
      ),
      child: Stack(
        children: [
          ..._buildNecklaceGems(gemsCollected, diameter),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '$gemsCollected',
                  style: GoogleFonts.unbounded(
                    fontSize: countFontSize,
                    fontWeight: FontWeight.w800,
                    color: WommiColors.ink,
                  ),
                ),
                Text(
                  gemsCollected == 1 ? 'gem' : 'gems',
                  style: GoogleFonts.spaceMono(
                    fontSize: labelFontSize,
                    color: WommiColors.inkDim,
                    letterSpacing: 0.3,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildNecklaceGems(int count, double diameter) {
    if (count == 0) return [];

    final maxVisible = 12;
    final gemsToShow = count > maxVisible ? maxVisible : count;
    final List<Widget> gems = [];
    final center = diameter / 2;
    final radius = diameter * 0.35;
    final gemSize = diameter * 0.12;

    for (int i = 0; i < gemsToShow; i++) {
      // Start at the bottom center (+pi/2) and go around from there,
      // instead of starting at the top.
      final angle = (i / maxVisible) * 2 * math.pi + (math.pi / 2);
      final x = radius * (i % 2 == 0 ? 1.0 : 0.85) * math.cos(angle);
      final y = radius * (i % 2 == 0 ? 1.0 : 0.85) * math.sin(angle);

      gems.add(
        Positioned(
          left: center + x - gemSize / 2,
          top: center + y - gemSize / 2,
          child: Text(
            '💎',
            style: TextStyle(fontSize: gemSize),
          ),
        ),
      );
    }

    return gems;
  }
}
