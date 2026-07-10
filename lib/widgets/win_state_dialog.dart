import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme.dart';

class WinStateDialog extends StatelessWidget {
  final int currentDay;
  final int gemBalance;
  final int streakDays;
  final VoidCallback onContinue;

  const WinStateDialog({
    super.key,
    required this.currentDay,
    required this.gemBalance,
    required this.streakDays,
    required this.onContinue,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 340),
        decoration: BoxDecoration(
          color: WommiColors.bg,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Content area with gradient background
            Container(
              padding: const EdgeInsets.all(26),
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: const Alignment(0, -0.3),
                  radius: 1.5,
                  colors: [
                    WommiColors.lilac.withOpacity(0.4),
                    WommiColors.bg,
                  ],
                ),
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(24),
                ),
              ),
              child: Column(
                children: [
                  // Eyebrow
                  Text(
                    'DAY $currentDay COMPLETE',
                    style: GoogleFonts.spaceMono(
                      fontSize: 10.5,
                      letterSpacing: 2.1,
                      color: WommiColors.rose,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  const SizedBox(height: 14),
                  // Charm orb with animation
                  TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0.0, end: 1.0),
                    duration: const Duration(milliseconds: 600),
                    curve: Curves.elasticOut,
                    builder: (context, value, child) {
                      return Transform.scale(
                        scale: value,
                        child: Container(
                          width: 118,
                          height: 118,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: RadialGradient(
                              colors: [
                                Colors.white,
                                WommiColors.goldSoft,
                                WommiColors.gold,
                                Color(0xFFB9822E),
                              ],
                              stops: const [0.0, 0.45, 0.78, 1.0],
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: WommiColors.gold.withOpacity(0.4),
                                blurRadius: 40,
                                spreadRadius: 0,
                                offset: const Offset(0, 20),
                              ),
                            ],
                            border: Border.all(
                              color: Colors.white,
                              width: 6,
                            ),
                          ),
                          child: Center(
                            child: Text(
                              '💎',
                              style: TextStyle(fontSize: 40),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 20),
                  // Title
                  Text(
                    'You earned\na new gem!',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.unbounded(
                      fontSize: 23,
                      fontWeight: FontWeight.w800,
                      color: WommiColors.ink,
                      height: 1.25,
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Flavor text
                  Text(
                    'Every small ritual adds up.\nYour consistency creates magic.',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.inter(
                      fontSize: 13.5,
                      color: WommiColors.inkDim,
                      height: 1.6,
                    ),
                  ),
                  const SizedBox(height: 22),
                  // Bangle with gems
                  _buildBangle(),
                  const SizedBox(height: 22),
                  // Stats
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildStat('Streak', '$streakDays days'),
                      const SizedBox(width: 22),
                      _buildStat('Gems', '$gemBalance total'),
                      const SizedBox(width: 22),
                      _buildStat('Cycle', 'day $currentDay'),
                    ],
                  ),
                ],
              ),
            ),
            // Buttons
            Padding(
              padding: const EdgeInsets.all(26),
              child: Column(
                children: [
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: onContinue,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: WommiColors.cyan,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(100),
                        ),
                        elevation: 14,
                        shadowColor: WommiColors.cyan.withOpacity(0.38),
                      ),
                      child: Text(
                        'Continue',
                        style: GoogleFonts.unbounded(
                          fontWeight: FontWeight.w700,
                          fontSize: 13.5,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBangle() {
    final filledGems = gemBalance > 6 ? 6 : gemBalance;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(
          color: WommiColors.line,
          width: 1.5,
        ),
        borderRadius: BorderRadius.circular(100),
        boxShadow: [
          BoxShadow(
            color: WommiColors.ink.withOpacity(0.08),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: List.generate(6, (index) {
          final isFilled = index < filledGems;
          final isNew = index == filledGems - 1;
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 5),
            child: _buildGemSlot(isFilled, isNew),
          );
        }),
      ),
    );
  }

  Widget _buildGemSlot(bool isFilled, bool isNew) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: isNew ? 0.0 : 1.0, end: 1.0),
      duration: Duration(milliseconds: isNew ? 600 : 0),
      curve: Curves.elasticOut,
      builder: (context, value, child) {
        return Transform.scale(
          scale: value,
          child: Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: isFilled
                  ? LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        WommiColors.goldSoft,
                        WommiColors.gold,
                      ],
                    )
                  : null,
              color: isFilled ? null : WommiColors.bgSoft,
              border: Border.all(
                color: isFilled ? WommiColors.gold : Color(0xFFD8D2E8),
                width: 1.5,
                style: isFilled ? BorderStyle.solid : BorderStyle.solid,
              ),
              boxShadow: isNew
                  ? [
                      BoxShadow(
                        color: WommiColors.cyan.withOpacity(0.5),
                        blurRadius: 14,
                        spreadRadius: 2.5,
                      ),
                    ]
                  : null,
            ),
            child: Center(
              child: Text(
                isFilled ? '💎' : '·',
                style: TextStyle(
                  fontSize: isFilled ? 14 : 16,
                  color: isFilled ? Colors.white : WommiColors.inkDim,
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildStat(String label, String value) {
    return Column(
      children: [
        Text(
          label,
          style: GoogleFonts.spaceMono(
            fontSize: 11,
            color: WommiColors.inkDim,
          ),
        ),
        Text(
          value,
          style: GoogleFonts.unbounded(
            fontSize: 15,
            fontWeight: FontWeight.w800,
            color: WommiColors.cyanDark,
          ),
        ),
      ],
    );
  }
}
