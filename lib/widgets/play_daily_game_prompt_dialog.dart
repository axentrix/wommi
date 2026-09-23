import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme.dart';
import '../models/daily_game.dart';

/// Shown right after the daily-rituals charm popup closes, offering the
/// day's separate mini-game instead of the now-removed "Play daily game"
/// button on the day's info popup (see CycleDayInfoDialog) - the game
/// itself, and its own charm, are unaffected; this is just a new way in.
class PlayDailyGamePromptDialog extends StatelessWidget {
  final VoidCallback onPlay;
  final VoidCallback onNotNow;

  const PlayDailyGamePromptDialog({
    super.key,
    required this.onPlay,
    required this.onNotNow,
  });

  @override
  Widget build(BuildContext context) {
    // Every day currently opens the same game while the rotation through
    // DailyGame's other entries is on hold (see dailyGameForDay) - named
    // here explicitly rather than looked up per-day so this stays honest
    // if that changes before the prompt's copy does.
    const game = DailyGame.luckyWheel;

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
            Container(
              padding: const EdgeInsets.all(28),
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: const Alignment(0, -0.3),
                  radius: 1.5,
                  colors: [
                    WommiColors.goldSoft.withValues(alpha: 0.5),
                    WommiColors.bg,
                  ],
                ),
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(24),
                ),
              ),
              child: Column(
                children: [
                  Text(game.emoji, style: const TextStyle(fontSize: 48)),
                  const SizedBox(height: 16),
                  Text(
                    'Play a daily game?',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.unbounded(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: WommiColors.ink,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Spin the ${game.label} for a shot at a second charm today.',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.inter(
                      fontSize: 13.5,
                      color: WommiColors.inkDim,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
              child: Column(
                children: [
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: onPlay,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: WommiColors.gold,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(100),
                        ),
                        elevation: 14,
                        shadowColor: WommiColors.gold.withValues(alpha: 0.38),
                      ),
                      child: Text(
                        'Play ${game.label}',
                        style: GoogleFonts.unbounded(
                          fontWeight: FontWeight.w700,
                          fontSize: 13.5,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextButton(
                    onPressed: onNotNow,
                    child: Text(
                      'Not now',
                      style: GoogleFonts.unbounded(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: WommiColors.inkDim,
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
}
