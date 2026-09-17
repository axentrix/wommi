import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme.dart';

/// Shown once per app launch (see HomeScreen.initState) when the journey is
/// tracking a menstrual cycle, ovulation still hasn't been marked, and the
/// current day is far enough along (18+) that it's worth double-checking
/// instead of silently assuming - unlike a man or undefined-gender journey,
/// which defaults ovulation to day 14 without asking (see
/// HomeScreen._checkOvulationStatus).
class OvulationCheckDialog extends StatelessWidget {
  final int currentDay;
  final VoidCallback onStillWaiting;
  final VoidCallback onItStarted;

  const OvulationCheckDialog({
    super.key,
    required this.currentDay,
    required this.onStillWaiting,
    required this.onItStarted,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 400),
        decoration: BoxDecoration(
          color: WommiColors.bg,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('🥚', style: TextStyle(fontSize: 48)),
              const SizedBox(height: 16),
              Text(
                'Are you sure ovulation\nhasn\'t started yet?',
                textAlign: TextAlign.center,
                style: GoogleFonts.unbounded(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  height: 1.3,
                  color: WommiColors.ink,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'It\'s day $currentDay and ovulation hasn\'t been marked yet. Let us know if it\'s already happened so the journey stays accurate.',
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  fontSize: 13,
                  color: WommiColors.inkDim,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: onItStarted,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: WommiColors.gold,
                    foregroundColor: WommiColors.ink,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(100),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    'No, it already started',
                    style: GoogleFonts.unbounded(
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: onStillWaiting,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: WommiColors.ink,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    side: BorderSide(color: WommiColors.line, width: 1.5),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(100),
                    ),
                  ),
                  child: Text(
                    'Yes, still waiting',
                    style: GoogleFonts.unbounded(
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
