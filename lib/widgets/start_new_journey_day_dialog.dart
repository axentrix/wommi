import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme.dart';
import 'number_scroll_picker.dart';

/// Lets the user pick which cycle day their new journey should begin on,
/// defaulting to day 1, instead of always restarting silently at day 1.
class StartNewJourneyDayDialog extends StatefulWidget {
  final ValueChanged<int> onConfirm;

  const StartNewJourneyDayDialog({super.key, required this.onConfirm});

  @override
  State<StartNewJourneyDayDialog> createState() =>
      _StartNewJourneyDayDialogState();
}

class _StartNewJourneyDayDialogState extends State<StartNewJourneyDayDialog> {
  int _selectedDay = 1;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 380),
        decoration: BoxDecoration(
          color: WommiColors.bg,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'New Journey',
                    style: GoogleFonts.unbounded(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: WommiColors.ink,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'From which day do you want to start?',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      color: WommiColors.inkDim,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 24),
                  NumberScrollPicker(
                    minValue: 1,
                    maxValue: 35,
                    initialValue: _selectedDay,
                    onChanged: (value) => setState(() => _selectedDay = value),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'DAY OF CYCLE',
                    style: GoogleFonts.spaceMono(
                      fontSize: 11,
                      letterSpacing: 1.1,
                      color: WommiColors.inkDim,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    widget.onConfirm(_selectedDay);
                  },
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
                    'Start Journey',
                    style: GoogleFonts.unbounded(
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
