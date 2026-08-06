import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme.dart';
import '../models/charm_rarity.dart';

/// A circular "necklace" of charm beads arranged around the rim, with the
/// total count shown in the middle. The first bead is placed at the bottom
/// center, with the rest following around the rim from there.
///
/// Pass [charms] to render each bead by its actual rarity (normal/rare/
/// legendary get visually distinct beads). When it's null - e.g. for past,
/// completed journeys where only a gem total was ever saved, not a
/// per-charm rarity history - every bead falls back to the old generic 💎
/// look, sized by [gemsCollected] instead.
class NecklaceCircle extends StatelessWidget {
  final double diameter;
  final int gemsCollected;
  final List<CharmRarity>? charms;
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
    this.charms,
    required this.borderColor,
    this.borderWidth = 2.5,
    this.color,
    this.gradient,
    this.countFontSize = 22,
    this.labelFontSize = 7,
  });

  int get _count => charms?.length ?? gemsCollected;

  @override
  Widget build(BuildContext context) {
    final count = _count;
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
          ..._buildNecklaceBeads(diameter),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '$count',
                  style: GoogleFonts.unbounded(
                    fontSize: countFontSize,
                    fontWeight: FontWeight.w800,
                    color: WommiColors.ink,
                  ),
                ),
                Text(
                  count == 1 ? 'gem' : 'gems',
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

  List<Widget> _buildNecklaceBeads(double diameter) {
    final count = _count;
    if (count == 0) return [];

    final maxVisible = 12;
    final beadsToShow = count > maxVisible ? maxVisible : count;
    final List<Widget> beads = [];
    final center = diameter / 2;
    final radius = diameter * 0.35;
    final gemSize = diameter * 0.12;
    // Legendary beads render larger than gemSize (plus a glow) - reserve a
    // fixed envelope per slot so every bead centers on the same rim point
    // regardless of its own rendered size.
    final envelope = gemSize * 1.6;

    for (int i = 0; i < beadsToShow; i++) {
      // Start at the bottom center (+pi/2) and go around from there,
      // instead of starting at the top.
      final angle = (i / maxVisible) * 2 * math.pi + (math.pi / 2);
      final x = radius * (i % 2 == 0 ? 1.0 : 0.85) * math.cos(angle);
      final y = radius * (i % 2 == 0 ? 1.0 : 0.85) * math.sin(angle);

      final rarity = charms != null && i < charms!.length ? charms![i] : null;

      beads.add(
        Positioned(
          left: center + x - envelope / 2,
          top: center + y - envelope / 2,
          width: envelope,
          height: envelope,
          child: Center(
            child: rarity != null
                ? _CharmBead(rarity: rarity, size: gemSize)
                : Text('💎', style: TextStyle(fontSize: gemSize)),
          ),
        ),
      );
    }

    return beads;
  }
}

/// A single bead's appearance, sized and colored by its rarity - a
/// placeholder look until real bead art/Rive assets replace it.
class _CharmBead extends StatelessWidget {
  final CharmRarity rarity;
  final double size;

  const _CharmBead({required this.rarity, required this.size});

  @override
  Widget build(BuildContext context) {
    switch (rarity) {
      case CharmRarity.legendary:
        return Container(
          width: size * 1.3,
          height: size * 1.3,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [WommiColors.gold, Color(0xFFFFF0C4)],
            ),
            boxShadow: [
              BoxShadow(
                color: WommiColors.gold.withOpacity(0.55),
                blurRadius: size * 0.7,
                spreadRadius: size * 0.12,
              ),
            ],
          ),
        );
      case CharmRarity.rare:
        return Container(
          width: size * 1.05,
          height: size * 1.05,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [WommiColors.lilac, WommiColors.cyan],
            ),
            boxShadow: [
              BoxShadow(
                color: WommiColors.lilac.withOpacity(0.4),
                blurRadius: size * 0.35,
              ),
            ],
          ),
        );
      case CharmRarity.normal:
        return Container(
          width: size * 0.8,
          height: size * 0.8,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white,
            border: Border.all(color: WommiColors.line, width: 1.2),
          ),
        );
    }
  }
}
