import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme.dart';
import '../providers/onboarding_provider.dart';
import '../providers/user_state_provider.dart';
import '../providers/repository_provider.dart';
import '../widgets/number_scroll_picker.dart';

class EditCycleDayDialog extends ConsumerStatefulWidget {
  const EditCycleDayDialog({super.key});

  @override
  ConsumerState<EditCycleDayDialog> createState() =>
      _EditCycleDayDialogState();
}

class _EditCycleDayDialogState extends ConsumerState<EditCycleDayDialog> {
  late int _selectedDay;

  @override
  void initState() {
    super.initState();
    // Pre-fill from the actual current day, not the onboarding provider's
    // cycleDay - that's only ever set at onboarding/last edit and goes
    // stale as soon as a day advances, which would otherwise silently
    // reset progress back to it if Save is hit without touching the picker.
    _selectedDay = ref.read(userStateProvider).currentDay;
  }

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
                    'Update Cycle Day',
                    style: GoogleFonts.unbounded(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: WommiColors.ink,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Where are you in your cycle today?',
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
                    onChanged: (value) {
                      setState(() => _selectedDay = value);
                    },
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
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: WommiColors.ink,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        side: BorderSide(color: WommiColors.line, width: 1.5),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(100),
                        ),
                      ),
                      child: Text(
                        'Cancel',
                        style: GoogleFonts.unbounded(
                          fontWeight: FontWeight.w700,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        ref
                            .read(userStateProvider.notifier)
                            .updateCurrentDay(_selectedDay);
                        // Persist so a later login restores this day too,
                        // instead of calculateCurrentCycleDay() recomputing
                        // from the stale startDate saved at onboarding.
                        final onboardingData = ref.read(onboardingProvider);
                        ref.read(repositoryProvider).saveCycleProfile(
                              startDate: DateTime.now()
                                  .subtract(Duration(days: _selectedDay - 1)),
                              cycleLength: 28,
                              ttcStatus: onboardingData.conceptionStatus,
                              ttcMethods: onboardingData.tryingMethods,
                            );
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: WommiColors.cyan,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(100),
                        ),
                        elevation: 8,
                        shadowColor: WommiColors.cyan.withOpacity(0.38),
                      ),
                      child: Text(
                        'Save',
                        style: GoogleFonts.unbounded(
                          fontWeight: FontWeight.w700,
                          fontSize: 13,
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
}
