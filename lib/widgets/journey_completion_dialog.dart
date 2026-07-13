import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme.dart';

class JourneyCompletionDialog extends StatelessWidget {
  final int gemsCollected;
  final VoidCallback onStartNewJourney;

  const JourneyCompletionDialog({
    super.key,
    required this.gemsCollected,
    required this.onStartNewJourney,
  });

  static const List<String> _quotes = [
    "Every ending is a new beginning. Honor what was, welcome what will be.",
    "You've completed a full cycle of growth and transformation.",
    "The moon wanes to wax again. Your journey continues.",
    "Each cycle brings you closer to understanding your body's wisdom.",
    "What a beautiful journey you've walked. Ready for the next?",
    "Your body knows its rhythms. Trust the cycle, embrace the change.",
  ];

  String get _randomQuote {
    final random = math.Random();
    return _quotes[random.nextInt(_quotes.length)];
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 360),
        decoration: BoxDecoration(
          color: WommiColors.bg,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Content area
            Container(
              padding: const EdgeInsets.all(28),
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
                    'CYCLE COMPLETE',
                    style: GoogleFonts.spaceMono(
                      fontSize: 10.5,
                      letterSpacing: 2.1,
                      color: WommiColors.rose,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Completed necklace
                  TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0.0, end: 1.0),
                    duration: const Duration(milliseconds: 800),
                    curve: Curves.elasticOut,
                    builder: (context, value, child) {
                      return Transform.scale(
                        scale: value,
                        child: Container(
                          width: 140,
                          height: 140,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: RadialGradient(
                              colors: [
                                Colors.white,
                                WommiColors.goldSoft.withOpacity(0.5),
                                WommiColors.gold.withOpacity(0.3),
                              ],
                            ),
                            border: Border.all(
                              color: WommiColors.gold,
                              width: 3,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: WommiColors.gold.withOpacity(0.3),
                                blurRadius: 30,
                                spreadRadius: 0,
                              ),
                            ],
                          ),
                          child: Stack(
                            children: [
                              // Gems around the circle
                              ..._buildNecklaceGems(gemsCollected),
                              // Center content
                              Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      '$gemsCollected',
                                      style: GoogleFonts.unbounded(
                                        fontSize: 36,
                                        fontWeight: FontWeight.w800,
                                        color: WommiColors.ink,
                                      ),
                                    ),
                                    Text(
                                      gemsCollected == 1 ? 'gem' : 'gems',
                                      style: GoogleFonts.spaceMono(
                                        fontSize: 10,
                                        color: WommiColors.inkDim,
                                        letterSpacing: 0.5,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 24),
                  // Title
                  Text(
                    'Journey Complete',
                    style: GoogleFonts.unbounded(
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                      color: WommiColors.ink,
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Quote
                  Text(
                    _randomQuote,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      color: WommiColors.inkDim,
                      height: 1.6,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ),
            ),
            // Buttons
            Padding(
              padding: const EdgeInsets.all(28),
              child: Column(
                children: [
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: onStartNewJourney,
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
                        'Start New Journey',
                        style: GoogleFonts.unbounded(
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: WommiColors.ink,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        side: BorderSide(color: WommiColors.line, width: 2),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(100),
                        ),
                      ),
                      child: Text(
                        'Continue Journey',
                        style: GoogleFonts.unbounded(
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
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

  List<Widget> _buildNecklaceGems(int count) {
    if (count == 0) return [];

    final maxVisible = 16;
    final gemsToShow = count > maxVisible ? maxVisible : count;
    final List<Widget> gems = [];
    final radius = 55.0;

    for (int i = 0; i < gemsToShow; i++) {
      // Start at the bottom center (+pi/2), same as the shared NecklaceCircle.
      final angle = (i / maxVisible) * 2 * math.pi + (math.pi / 2);
      final x = radius * math.cos(angle);
      final y = radius * math.sin(angle);

      gems.add(
        Positioned(
          left: 70 + x - 8,
          top: 70 + y - 8,
          child: Text(
            '💎',
            style: TextStyle(fontSize: 16),
          ),
        ),
      );
    }

    return gems;
  }
}
