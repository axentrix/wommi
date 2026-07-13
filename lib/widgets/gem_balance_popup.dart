import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme.dart';
import 'necklace_circle.dart';

/// The mini dashboard shown when tapping the gem balance badge on the
/// home screen header - a preview of the necklace being built plus a
/// short explanation of what gems are for.
class GemBalancePopupContent extends StatelessWidget {
  final int gemBalance;
  final int streakDays;

  const GemBalancePopupContent({
    super.key,
    required this.gemBalance,
    required this.streakDays,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 260,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: WommiColors.bg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: WommiColors.line, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: WommiColors.ink.withOpacity(0.12),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          NecklaceCircle(
            diameter: 92,
            gemsCollected: gemBalance,
            borderColor: WommiColors.gold,
            borderWidth: 2.5,
            color: Colors.white,
            countFontSize: 26,
            labelFontSize: 9,
          ),
          const SizedBox(height: 14),
          Text(
            'Collect crystals during your journey to create a necklace of conception charms.',
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              fontSize: 12.5,
              color: WommiColors.inkDim,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _MiniStat(icon: '💎', label: 'GEMS', value: '$gemBalance'),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _MiniStat(icon: '🔥', label: 'STREAK', value: '$streakDays'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MiniStat extends StatelessWidget {
  final String icon;
  final String label;
  final String value;

  const _MiniStat({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        color: WommiColors.bgSoft,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: WommiColors.line, width: 1.5),
      ),
      child: Column(
        children: [
          Text(icon, style: TextStyle(fontSize: 18)),
          const SizedBox(height: 4),
          Text(
            value,
            style: GoogleFonts.unbounded(
              fontSize: 15,
              fontWeight: FontWeight.w800,
              color: WommiColors.ink,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: GoogleFonts.spaceMono(
              fontSize: 8.5,
              letterSpacing: 0.8,
              color: WommiColors.inkDim,
            ),
          ),
        ],
      ),
    );
  }
}
